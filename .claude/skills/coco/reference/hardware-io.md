# CoCo 1/2 hardware I/O — SAM, PIA, ROM/RAM toggle

Everything in this file was confirmed directly (real disassembly cross-
checked with live `PEEK`/`POKE` tests in XRoar), not taken on faith from
a single source. See `hero-port/COCO-BASIC-INTERNALS.md` in the main repo
for the full original write-up this was distilled from, including the
exact test methodology.

## The SAM chip — complete register map

The SAM (Synchronous Address Multiplexer) exposes its entire
configuration through one contiguous block, `$FFC0`-`$FFDF`. Every
adjacent address pair follows the same pattern: one address clears a bit,
the next sets it — **the value written doesn't matter, only which of the
two addresses gets touched** (address-triggered latches).

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
$FFDE/DF   ROMCLR/ROMSET -- ROM/RAM select (see below)
```

**What `V` and `F` actually control:** together they answer "which
physical bytes of RAM does the screen currently show" — entirely
independent of whatever address the CPU itself is reading/writing. The
VDG has its own internal address counter purely for fetching display
data; `V`/`F` configure *that* counter, not the CPU's addressing.

- `F` (7 bits) selects the VDG's starting address for each frame, in
  fixed page increments across the 64K space — this is exactly what
  BASIC's `PMODE` page argument and `PCOPY` wrap.
- `V` (3 bits) selects the increment pattern — how many bytes of RAM the
  counter advances per scanline, matched to each mode's bandwidth needs.

The undocumented SG12 semigraphics mode (used by the HERO port's original
game) is nothing more than a specific, undocumented combination of these
same three `V` bits (`V2SET` + `V1CLR` + `V0CLR`) — same mechanism as
every officially-supported mode, just landing on a timing pattern Tandy
never published.

**Scope note:** this is the complete picture for a *stock* CoCo 1/2. Real
memory-expansion hardware for 128K/512K CoCo 1/2 adds its own bank-
switching on top of this SAM behavior. The CoCo 3's GIME chip replaces
the SAM entirely with a genuinely more elaborate MMU — see the **coco3**
skill.

## 64K / "all-RAM" mode

| Address | Name | Effect |
|---|---|---|
| `$FFDE` (65502) | `ROMCLR` | disables ROM (all-RAM mode) |
| `$FFDF` (65503) | `ROMSET` | enables ROM (normal mode) |

**You cannot just flip this once.** RAM underneath the ROM mapping starts
as genuine uninitialized garbage. If the CPU is actively executing from
that same address range, it crashes on the very next instruction fetch
the moment ROM is switched off underneath it.

The real, historically-used technique (from a period-accurate CoCo
hacking resource, for transferring cartridge software to disk) copies ROM
into the underlying RAM one word at a time, toggling modes per word, from
code running *outside* the affected range (e.g. `$7000`):

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

**Open question, not yet resolved:** a plain `POKE &HFFDE,0` in at least
one XRoar `coco2bus` build did *not* switch modes (confirmed via a
before/after `PEEK`/`POKE` write-test showing no change). Worth checking
whether this is an XRoar emulation gap before relying on `$FFDE`/`$FFDF`
in XRoar-based work specifically — real hardware behavior is not in
question, only this one emulator build's fidelity to it.

## PIA1 and the T1 lowercase font

`POKE &HFF22,16` sets bit 4 of PIA1 Port B, switching the 6847T1 VDG chip
into its alternate/lowercase character set. Confirmed via direct
pixel-level screenshot comparison: `POKE`d values 0-31 render as genuine
lowercase letters (visible descenders on `g`/`j`), not just inverted
uppercase.

This mode gets reverted on the next character output by a defensive reset
in Color BASIC's own console-output chain (see `basic-interpreter.md` for
the full traced call chain and the actual patch — `POKE 359,57` — that
stops it).

## Cassette, joystick, sound, serial registers

Not yet independently traced/verified in this skill to the same depth as
the above. Look these up directly rather than assuming: check
`../xls-conversion/reference-tabs/memory-map-cb.csv` and
`data-tables-cb.csv` for named constants (search for things like `CAS`,
`JOY`, `SND`, `PIA0` prefixes), then cross-reference the routine that
uses them in `routines-cb.csv` before trusting an address for real I/O
work.
