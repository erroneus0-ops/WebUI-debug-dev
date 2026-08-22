# CoCo hardware & Color BASIC internals -- verified reference

A collection of real, empirically-verified CoCo/6809 findings that came out of
a detour from the HERO port work, kept here because none of it was
documented in one place anywhere, and all of it was confirmed directly
(real disassembly, real assembled test routines run in XRoar) rather than
taken on faith from any single source.

## 1. The T1 lowercase hack -- the real pokes, and why the "classic" address didn't work

**The two pokes that actually work, confirmed directly by Ciaran Anscomb
(author of XRoar) and independently verified here:**

```basic
POKE 359,57
POKE &HFF22,16
```

- `POKE &HFF22,16` sets bit 4 of PIA1 Port B, switching the 6847T1 VDG into
  its alternate/lowercase character set. Confirmed via direct pixel-level
  screenshot comparison: raw `POKE`d values 0-31 render as genuine,
  correctly-shaped lowercase letters (visible descenders on `g`/`j`), not
  just inverted uppercase.
- `POKE 359,57` writes `$39` (the 6809 `RTS` opcode) over the first byte of
  a documented RAM hook. This is the piece that stops the mode from
  reverting the instant anything gets printed.

### Why `359` and not the address a well-known blog post uses (`&H95AC`)

An older, widely-circulated hack pokes `&H95AC` directly. That address is
real -- it's the exact routine that resets the display mode -- but it has
two independent reasons it can fail:

1. **It's a specific byte offset inside one ROM revision's own code.**
   `359` is a documented, stable structural entry point (see below); `$95AC`
   is wherever one specific compile of Extended Color BASIC happened to
   place that logic. A different ROM revision can shift this by even one
   byte and silently miss.
2. **It requires "64K/all-RAM mode" to even be possible.** Confirmed
   directly: `PEEK(38316)` (= `$95AC`) returned `52` both before and after
   `POKE 38316,255` -- the write silently did nothing, because in normal
   operation `$95AC` is genuine, read-only ROM. `52` decimal is `$34` hex,
   which matches the disassembly's own first byte at that address exactly
   (`PSHS X,B,A`), cross-validating the disassembly, the live `PEEK`, and
   the explanation all at once.

### The full, real call chain (confirmed via direct disassembly)

Traced through an actual "Color BASIC Unravelled"-style disassembly
spreadsheet (34 tabs covering CB/ECB/SECB/DECB across multiple versions --
see the repo root, `Unravelled II.xls`):

```
$167 (359)   CONSOLE OUT RAM hook -- one of 25 documented 3-byte JMP
             vectors starting at $15E, designed specifically so
             Extended/Disk BASIC ROMs can redirect Color BASIC's own
             behaviour without patching the base ROM. Confirmed via
             direct PEEK: originally holds JMP $CC1C ($7E,$CC,$1C).
    |
    v
$CC1C  DVEC3 (Disk Extended Color BASIC 1.1)
       TST DEVNUM
       LBLE XVEC3          ; branch onward if not a disk file
       [... else: write byte to a disk FCB, unrelated to screen output]
    |
    v
$8273  XVEC3 (Extended Color BASIC 1.1)
       TST DEVNUM
       LBEQ L95AC          ; BRANCH IF SCREEN
       [... else: check DLOAD/cassette special cases]
    |
    v
$95AC  L95AC
       PSHS X,B,A
       LDX #SAM+8
       STA 10,X / STA $08,X / ... (reset SAM display page to $400)
       STA $-02,X / ... (reset SAM's VDG to alpha-numeric mode)
       LDA PIA1+2
       ANDA #$07           ; <-- clears bits 3-7, INCLUDING our T1 bit
       STA PIA1+2
       PULS A,B,X,PC
```

`POKE 359,57` overwrites the very first byte of the very first link in
this chain with `RTS`, so nothing downstream -- including the `ANDA #$07`
that stomps the T1 mode bit -- ever runs again, for any character output,
regardless of which ROM revision put what at which address further down.

This also explains why ordinary text still displays correctly even
though this whole chain never runs: the chain is purely a *defensive
reset* ("make sure text mode is standard before this next character"),
not the actual character-drawing logic -- that lives elsewhere,
untouched by this patch.

## 2. 64K / "all-RAM" mode

Confirmed directly from the disassembly's own memory-map documentation:

| Address | Name | Effect |
|---|---|---|
| `$FFDE` (65502) | `ROMCLR` | disables ROM (all-RAM mode) |
| `$FFDF` (65503) | `ROMSET` | enables ROM (normal mode) |

These are address-triggered SAM registers -- the value written doesn't
matter, only the act of accessing that address.

**Important, and easy to get wrong: you cannot just flip this bit once.**
The RAM sitting "underneath" the ROM mapping starts out as genuine
uninitialized garbage. If the CPU is actively executing code from that
same address range (which, if you've just switched ROM off, it now
reads as garbage) it crashes on the very next instruction fetch.

The real, documented technique (found in a period-accurate CoCo hacking
resource, for transferring cartridge software to disk) copies the ROM
into the underlying RAM one word at a time, toggling modes for each
individual word:

```asm
        ORG $7000
START   ORCC  #$50      ; interrupts OFF -- critical, an interrupt firing
                         ; mid-toggle could hit a handler expecting a
                         ; consistent memory state
        LDX   #$8000    ; start of ROM
LOOP    STA   $FFDF     ; force ROM mode
        LDD   ,X        ; read from ROM
        STA   $FFDE     ; force RAM mode
        STD   ,X++      ; write the same data back to the same address
        CMPX  #$E000    ; end of CoCo 1/2 ROM space
        BNE   LOOP
```

The copy routine itself runs from `$7000`, deliberately *outside* the
range being toggled, so the CPU is always executing stable, unaffected
code -- it never executes instructions *from* the region being flipped
back and forth, only reads/writes data there.

**Note on our own testing:** a plain `POKE &HFFDE,0` in this specific
XRoar `coco2bus` build did *not* actually switch modes (confirmed via a
before/after `PEEK`/`POKE` write-test showing no change at all). Real,
open, unresolved question -- worth checking whether this is an XRoar
`coco2bus` emulation gap (similar to the T1-font `EXT`-signal gap found
elsewhere in this project) or something else, before relying on
`$FFDE`/`$FFDF` in any XRoar-based work.

## 3. The SAM chip -- the complete register map, and how it all connects

Confirmed directly from the same disassembly source as the ROM/RAM
registers above. The SAM (Synchronous Address Multiplexer) exposes its
entire configuration through one contiguous block, `$FFC0`-`$FFDF`,
following the identical address-triggered latch pattern throughout: each
adjacent pair of addresses is "clear this one bit" / "set this one bit"
-- the value written doesn't matter, only which of the two addresses
gets touched.

```
$FFC0/C1   V0CLR/V0SET   -- video mode bit 0  |
$FFC2/C3   V1CLR/V1SET   -- video mode bit 1  |- 3-bit "V" field (8 modes)
$FFC4/C5   V2CLR/V2SET   -- video mode bit 2  |

$FFC6/C7   F0CLR/F0SET   -- display-offset bit 0  |
$FFC8/C9   F1CLR/F1SET   -- bit 1                  |
$FFCA/CB   F2CLR/F2SET   -- bit 2                  |- 7-bit "F" field
$FFCC/CD   F3CLR/F3SET   -- bit 3                  |  (display start page)
$FFCE/CF   F4CLR/F4SET   -- bit 4                  |
$FFD0/D1   F5CLR/F5SET   -- bit 5                  |
$FFD2/D3   F6CLR/F6SET   -- bit 6                  |

$FFD4-D7   reserved
$FFD8/D9   R1CLR/R1SET   -- CPU rate: 0.89MHz / 1.78MHz
$FFDA-DD   reserved
$FFDE/DF   ROMCLR/ROMSET -- ROM/RAM select (section 2, above)
```

**What the `V` and `F` fields actually control, precisely:** these two
fields together are the complete answer to "which physical bytes of RAM
does the screen currently show" -- but this is entirely independent of
whatever address the CPU itself happens to be reading or writing at any
given moment. The VDG has its own internal address counter, used purely
to fetch display data, and `V`/`F` are what configure that counter, not
the CPU's addressing at all.
- `F` (7 bits, 128 values) selects the VDG's *starting* address for each
  frame, in fixed-size page increments across the full 64K space --
  this is exactly what `PMODE`'s page argument and `PCOPY` are
  convenient BASIC-level wrappers around.
- `V` (3 bits, 8 values) selects the *increment pattern* -- how many
  bytes of RAM the counter advances per scanline, matching each
  display mode's actual bandwidth needs (a 32-column text row needs far
  less data per line than a 256-pixel colour graphics row, so different
  modes need genuinely different advancement rates to stay in sync with
  the screen).

**This is the exact same mechanism the SG12 hack (the very first thing
this whole project was built on) uses.** SG12's "V-mode binary 100"
is nothing more than a specific combination of these same three V bits:
`V2SET` (`$FFC5`), `V1CLR` (`$FFC2`), `V0CLR` (`$FFC0`) -- the same
address-triggered latches, just landing on an undocumented display
timing pattern instead of one of the officially-supported modes.

**Scope, stated honestly:** this is the complete picture for a *stock*
CoCo 1/2 -- one SAM chip, a plain, unexpanded 64K address space, one
simple all-or-nothing ROM/RAM toggle. Real memory-expansion hardware for
128K/512K CoCo 1/2 machines adds its own bank-switching schemes on top
of this, and the CoCo 3's GIME chip replaces the SAM entirely with a
genuinely more elaborate MMU offering proper bank-switched pages rather
than one simple toggle -- both are real, further layers of complexity
this section doesn't attempt to cover.

## 4. The real `DOS` command -- a fixed track, a two-byte signature, and a jump into the unknown

Confirmed directly by tracing `DOSCOM` (`$DF00`, the actual entry point
typing `DOS` reaches) through the same disassembly used throughout this
document. The mechanism is genuinely simple, and genuinely open-ended:

```
$DF00  DOSCOM  SWI3                ; software interrupt -- a context/setup
                                    ; step; execution continues normally at
                                    ; the next instruction once it returns
$DF02          CLR   TMPLOC        ; reset sector counter
$DF04          LDD   #DOSBUF       ; RAM load address for sector data
   ...
$DF1B          LDA   #34           ; TRACK NUMBER (34) -- fixed, hardcoded
   ...                             ; reads sectors 1 through 18 (SECMAX) --
                                    ; the entire track -- into DOSBUF,
                                    ; advancing the load address by 256
                                    ; bytes (one sector) after each
                                    ; successful read
$DF38          LDD   DOSBUF        ; first two bytes of what was loaded
$DF3B          CMPD  #'OS'         ; does it start with "OS" (OS-9's own
                                    ; boot signature)?
$DF3F          LBEQ  DOSBUF+2      ; if so, JUMP DIRECTLY into the loaded
                                    ; code -- no further validation at all
```

That's the entire mechanism. `DOS` reads the complete, fixed track 34 (all
18 sectors) into a RAM buffer, checks whether the very first two bytes
spell `"OS"`, and if they do, transfers control straight into whatever
follows -- nothing else about the loaded content is checked or assumed.
This was OS-9's real, official bootstrap path onto the CoCo, but the
mechanism itself doesn't know or care that it's OS-9 specifically: format
any disk with your own code starting with the bytes `'O','S'` at track
34/sector 1, and typing `DOS` will load and execute it, unconditionally.
Precisely as simple, and as wide open, as it sounds.

**Two real, documented bugs in Tandy's own shipped ROM, found in this
same short routine** (flagged directly in the disassembly's own
comments, not found independently here): a `STA` at `$DF19` where a
16-bit `STD` was clearly intended (storing only half of a 16-bit value
into the disk-controller variables), and an `ADDA #$01` at `$DF23` doing
what a plain `INCA` would have done more simply. Real, shipped, official
ROM -- not immune to the same kind of small, easy-to-miss mistakes this
whole project has spent so much time finding elsewhere.

**Future idea, noted here so it doesn't get lost:** this is a genuinely
fun, period-correct way to launch the HERO port once it exists as a real
program on a real disk image -- format the game's `.dsk` so track
34/sector 1 starts with `'O'`,`'S'` followed by a bootstrap that jumps
into the game itself, and typing `DOS` at a bare `OK` prompt becomes a
real, working way to start playing. Matches exactly how software of this
era actually got launched, rather than a modern `LOADM`/`EXEC` sequence
standing in for it.

## 5. Stack blasting -- fast 6809 memory copy, and its real gotchas

A real, historically-used technique (the article citing it specifically
mentions *Defender*, a 1Mhz-6809-based arcade game, using this for
drawing all on-screen sprites) for moving memory faster than
`LD?`/`ST?` with auto-increment allows -- `PULS`/`PSHS` (or the `U`-stack
equivalents) with a large register list move up to 9 bytes in one
instruction instead of 2 bytes per LD/ST pair.

### The core mechanic: same-address round trip needs no correction at all

For the specific case this project actually needed -- reading ROM and
writing RAM at the *same* address -- the naive-looking approach is
already exactly correct, with no compensating adjustment:

```asm
LDS   #addr
PULS  <reglist>     ; reads `reglist`'s total byte count from addr;
                     ; S advances forward by that same amount
PSHS  <reglist>     ; writes the SAME data back; S returns to EXACTLY
                     ; its starting value
```

This works because `PULS` and `PSHS` process a given register list in
*exactly opposite, fixed hardware order* (`PULS`: `CC,A,B,DP,X,Y,U,PC`
low-to-high; `PSHS`: the reverse, high-to-low), and because source and
destination are numerically identical here, the two reversals -- the
pointer's direction, and the register-processing order -- cancel each
other out perfectly. Confirmed directly via a real assembled test
routine and a live before/after byte comparison in XRoar:

```
BEFORE: 11 22 33 44
AFTER:  11 22 33 44
FINALS: 28928  EXPECT: 28928   (S returned to exactly its starting address)
```

**This is a special case, not the general rule.** If source and
destination are genuinely *different*, independently-advancing regions
(e.g. copying a background image to the screen), the mirroring does
*not* cancel out on its own, and naively advancing both pointers the
same direction at the same rate scrambles the data (documented
independently: "Even with interrupts masked, this does not do the
trick... look at what happens when you repeat!"). The real fix for that
case sets the *destination* pointer to the **far end** of its range
(since `PSHS` walks backward), so its reverse-order writes and the
loop's forward progress cancel out correctly across the whole copy:

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

### Real gotchas found by actually testing this, not just reading about it

- **You must save and restore the real stack pointer around the hijacked
  `S` usage.** If code reached via `EXEC`/`JSR`/`BSR` repurposes `S`
  without first saving it, the return address that was pushed there
  automatically gets abandoned -- the final `RTS` pops garbage and
  crashes. Confirmed the hard way: the very first version of this test
  crashed the emulator into a garbled semigraphics display; adding
  `STS REALS` at entry and `LDS REALS` before the final `RTS` fixed it
  completely.
- **Code/data placement matters when using `EXEC`.** Placing a data value
  (like a persistent position counter) *before* the actual entry point in
  memory, then `EXEC`ing the very start of that block, makes the CPU try
  to execute the data as instructions. Data belongs *after* all code, or
  `EXEC` needs to target the real entry point specifically past it.
- **A register used as part of the blasted payload can't simultaneously
  track loop position.** Once `PULS D,X,Y,U` runs, `X` holds ROM *data*,
  not an address anymore. A multi-chunk copy loop needs a separate,
  persistent tracker (untouched by the blast) to remember "where am I,"
  reloaded fresh each iteration:

  ```asm
    LOOP1   LDS   CURPOS      ; S = current address (source AND dest)
            [ROM mode]
            PULS  <reglist>   ; read chunk; S advances; registers now hold DATA
            [RAM mode]
            PSHS  <reglist>   ; write chunk back; S returns to CURPOS exactly
            LDX   CURPOS      ; reload position from the untouched tracker
            LEAX  chunksize,X
            STX   CURPOS
            CMPX  #ENDADDR
            BNE   LOOP1
  ```

  Confirmed via a real 3-chunk (24-byte) loop test: all 24 bytes
  preserved exactly, and the tracker landed precisely on the expected
  end address after all iterations.
- **`PULS ...,PC` at the end of a subroutine replaces a separate `RTS`.**
  Since `JSR`/`BSR` push a return address before entry, and `PSHS`/`PULS`
  process their list in a fixed order with `PC` last, including `PC` in
  the final `PULS` list both restores the last register *and* performs
  the return in one instruction -- no separate `RTS` needed.
- **Direct Page (`,DP`) addressing for a position tracker is a speed
  optimization, not a correctness requirement.** It costs one address
  byte instead of two per access (extended addressing), which matters
  because a position tracker like `CURPOS` gets touched on every single
  loop iteration -- for a real 24K ROM copy at 8 bytes/chunk, that's
  ~3000 iterations, each saving a byte and a cycle. A variable touched
  once wouldn't be worth arranging DP for; a hot-loop variable touched
  thousands of times clearly is.

### A reusable technique: testing real machine code from BASIC via DATA/POKE/EXEC

Every stack-blast test above (and the T1-lowercase pokes) was verified
using the same reliable pattern -- real 6809 assembly, assembled with a
real assembler (`asm6809`) to get exact, correct opcodes rather than
hand-encoding them, then injected into real Color BASIC running in
XRoar:

```basic
10 DATA <byte>,<byte>,<byte>,...        ' exact assembled object code
20 FOR I=0 TO N: READ B: POKE &H7000+I,B: NEXT
30 <set up test data, PEEK "before" state>
40 EXEC &H7000
50 <PEEK "after" state, compare>
```

This sidesteps ugBASIC's various inline-assembly quirks entirely (see
`hero-port/upstream-reports/`) by testing real 6809 semantics directly
against real Color BASIC, with nothing else in between.

## 6. Control codes: what `PRINT`/`CHR$` actually does with values 0-31

Explored via the character-map diagnostic in
`hero-port/coco-basic-internals/demos.bas` (Demo 2) -- `POKE`ing every
value 0-255 directly into screen memory alongside `PRINT`ing the same
values via `CHR$()`, to see where the two diverge.

**Only two control codes have any real functional effect at all:**

- **`CHR$(8)` (backspace)** -- doesn't draw anything at its own screen
  position; instead, it erases exactly the *one* character immediately
  behind the current cursor position with a space.
- **`CHR$(13)` (carriage return / Enter)** -- clears from the current
  cursor position all the way to the end of the current screen line.

Every other value in the 0-31 range is simply, genuinely non-printing --
confirmed properly, not just inferred.

### A methodology correction worth stating plainly

The first pass at this (sweeping `CHR$(0)` through `CHR$(127)`
sequentially across one continuous row) showed values 13 through 31 *all*
appearing as a uniform "wiped" block, which looked at first like "none of
14-31 have a visible glyph." That conclusion was correct, but the test
that produced it couldn't actually have told the difference between two
very different situations: "code 20 has no glyph of its own" versus "code
20 has a perfectly normal glyph, but code 13's clear-to-end-of-line effect
wiped it before anyone looked." Sweeping every value in one row means
`CHR$(13)`'s side effect necessarily contaminates every value tested after
it in that same pass.

Re-tested properly: each of `CHR$(14)` through `CHR$(31)` printed on its
own isolated screen row, with nothing printed before it on that row that
could cascade into it. Result: still nothing visible for any of them --
confirming the original conclusion, but now for the right reason, from a
test that could actually distinguish the two cases rather than one that
happened to land on the right answer by coincidence.

Practical upshot for anything that builds strings containing raw byte
values rather than pure literal text: `CHR$(8)` and `CHR$(13)` are the
only two values in the 0-31 range that will ever do anything other than
silently vanish -- everything else in that range is safe to treat as
inert if it shows up unintentionally, and neither of those two can be
treated as "just another character" if it shows up unintentionally.


Found and precisely isolated while writing test harnesses for the above:

## 7. Classic Color BASIC tokenizer quirks

- **No `ELSE` support at all.** `IF cond THEN stmt ELSE stmt` produces a
  flat `?SN ERROR` (Syntax error) in this ROM (Disk Extended Color BASIC
  1.1) -- confirmed with the simplest possible case
  (`IFA=BTHENC=5ELSEC=6`). Use two separate `IF` statements instead
  (`IF cond THEN stmt` / `IF NOT-cond THEN stmt`).
- **A variable name directly touching a following keyword, with no
  space, gets swallowed whole.** `IFX=YTHEN...` fails; `IFX=Y THEN...`
  works. The mechanism, precisely isolated by testing several variations
  (a literal number before `THEN` works fine; a single-letter variable
  fails; a full two-letter variable *also* fails, ruling out a simpler
  "variables only reserve 2 significant characters" theory):

  **The tokenizer reads an entire unbroken run of letters as one
  candidate word first, and only afterward checks whether that whole
  word matches a keyword.** `CDTHEN` gets read straight through as one
  six-letter run; since `CDTHEN` isn't itself a recognized keyword, the
  *entire run* falls back to being treated as one variable name (with
  only the first couple of characters actually mattering for storage/
  lookup -- a separate, later concern). The parser never reconsiders
  splitting the tail of what it already consumed off as a separate
  keyword -- by the time `THEN` would need to be recognized, its letters
  are already inside the variable name token. A digit immediately before
  a keyword never has this problem, since digits and letters are
  unambiguously different token classes -- the run simply stops the
  moment the character class changes.
  - Practical rule: always leave a space between a variable reference and
    a following keyword. Doesn't matter for keywords following a
    *number*, or following an *operator* directly (like `=`, `<`, `>`)
    on their own -- only matters when a run of letters (a variable name)
    would otherwise run directly into a run of letters (a keyword).
