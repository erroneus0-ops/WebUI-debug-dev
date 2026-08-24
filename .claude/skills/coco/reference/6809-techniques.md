# Verified 6809 techniques on the CoCo

Distilled from `hero-port/COCO-BASIC-INTERNALS.md`. Each technique below
was confirmed by assembling real 6809 code (with `asm6809`, not
hand-encoded opcodes) and running it in XRoar against real Color BASIC.

## Testing real machine code from BASIC — the reliable pattern

Every technique below (and the T1-lowercase patch in
`basic-interpreter.md`) was verified with this pattern, which sidesteps
compiler-specific inline-assembly quirks entirely by testing real 6809
semantics directly:

```basic
10 DATA <byte>,<byte>,<byte>,...        ' exact assembled object code
20 FOR I=0 TO N: READ B: POKE &H7000+I,B: NEXT
30 <set up test data, PEEK "before" state>
40 EXEC &H7000
50 <PEEK "after" state, compare>
```

Use this whenever you need ground truth about what real 6809 code does
on a real CoCo, independent of whatever a higher-level compiler (ugBASIC,
BASIC-to-6809) might generate for the equivalent construct.

## Stack blasting — fast memory copy via `PULS`/`PSHS`

A historically-used technique (cited from an article about *Defender*'s
sprite drawing on 6809 hardware) for moving memory faster than `LD?`/
`ST?` with auto-increment allows: `PULS`/`PSHS` (or the `U`-stack
equivalents) move up to 9 bytes in one instruction instead of 2 bytes per
load/store pair.

### Same-address round trip needs no correction

For reading and writing the *same* address (e.g. ROM→RAM copy at a fixed
location), the naive approach is already exactly correct:

```asm
LDS   #addr
PULS  <reglist>     ; reads reglist's total byte count from addr;
                     ; S advances forward by that same amount
PSHS  <reglist>     ; writes the SAME data back; S returns to EXACTLY
                     ; its starting value
```

This works because `PULS` and `PSHS` process a register list in exactly
opposite, fixed hardware order (`PULS`: `CC,A,B,DP,X,Y,U,PC` low-to-high;
`PSHS`: the reverse) — with source and destination numerically
identical, the pointer-direction reversal and the register-order reversal
cancel out perfectly. Confirmed via a real assembled test: before/after
byte comparison identical, stack pointer returned to exactly its
starting address.

### Different source and destination — the mirroring does NOT cancel

If source and destination are genuinely different, independently-
advancing regions (e.g. copying a background image to the screen), naive
same-direction advancement scrambles the data. The fix: set the
*destination* pointer to the **far end** of its range (since `PSHS` walks
backward), so its reverse-order writes and the loop's forward progress
cancel out correctly across the whole copy:

```asm
STS  TempMem
LDS  #$5C3F      ; destination: bottom-right of the screen (far end!)
LDU  #$C000      ; source: start of the data
Copy_bg1:
    PULU D,X,Y,DP   ; source advances forward
    PSHS D,X,Y,DP   ; destination advances backward
    CMPU #$DC35
    BLO  Copy_bg1
LDS  TempMem
PULS D,X,Y,DP,PC
```

### Real gotchas (found by testing, not just reading about it)

- **Save/restore the real stack pointer around hijacked `S` usage.** Code
  reached via `EXEC`/`JSR`/`BSR` that repurposes `S` without first saving
  it abandons the pushed return address — the final `RTS` pops garbage
  and crashes. Fix: `STS REALS` at entry, `LDS REALS` before the final
  `RTS`.
- **Data placement matters with `EXEC`.** A data value (e.g. a position
  counter) placed *before* the entry point in memory, then `EXEC`ed from
  the block's start, makes the CPU try to execute the data as
  instructions. Data belongs after all code, or `EXEC` must target the
  real entry point specifically.
- **A register used in the blasted payload can't simultaneously track
  loop position.** Once `PULS D,X,Y,U` runs, `X` holds ROM *data*, not an
  address. A multi-chunk copy loop needs a separate, untouched tracker:

  ```asm
    LOOP1   LDS   CURPOS      ; S = current address (source AND dest)
            [ROM mode]
            PULS  <reglist>   ; read chunk; registers now hold DATA
            [RAM mode]
            PSHS  <reglist>   ; write chunk back; S returns to CURPOS
            LDX   CURPOS      ; reload position from the untouched tracker
            LEAX  chunksize,X
            STX   CURPOS
            CMPX  #ENDADDR
            BNE   LOOP1
  ```

  Confirmed via a real 3-chunk (24-byte) test: all bytes preserved
  exactly, tracker landed on the expected end address.

- **`PULS ...,PC` at the end of a subroutine replaces a separate `RTS`.**
  Since `JSR`/`BSR` push a return address, including `PC` in the final
  `PULS` list both restores the last register and performs the return in
  one instruction.
- **Direct Page (`,DP`) addressing for a position tracker is a speed
  optimization, not a correctness requirement** — worth it for a variable
  touched thousands of times in a hot loop (one address byte instead of
  two per access), not worth arranging for a variable touched once.

## Safe ROM→RAM copying (the full `full_rom_migrate` pattern)

See `hero-port/coco-basic-internals/full_rom_migrate.asm` and
`stackblast_multichunk.asm` in the main repo for complete, working
assembled examples combining the ROM/RAM toggle (`hardware-io.md`) with
the multi-chunk stack-blast tracker pattern above — real code, not just
described technique.

## The `DOS` command boot mechanism

Traced through `DOSCOM` (`$DF00`): reads the entire fixed track 34 (all
18 sectors) into RAM at `DOSBUF` (`$2600`), checks whether the first two
loaded bytes spell `"OS"`, and if so jumps directly into whatever follows
— no further validation. This was OS-9's real bootstrap path, but the
mechanism itself doesn't know or care it's OS-9 specifically: any disk
formatted with your own code starting `'O','S'` at track 34/sector 1 will
load and run via a bare `DOS` command at the `OK` prompt. A genuinely
period-correct way to launch a finished program from a real disk image,
as an alternative to a modern `LOADM`/`EXEC` sequence.

Two real bugs exist in Tandy's own shipped ROM in this same routine (`STA`
at `$DF19` where a 16-bit `STD` was clearly intended; `ADDA #$01` at
`$DF23` doing what a plain `INCA` would do) — flagged directly in the
disassembly's own comments.
