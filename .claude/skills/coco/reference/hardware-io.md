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
- `V` (3 bits) selects the increment pattern — how often the counter
  fetches a new byte per scanline.

### The real, complete `V2 V1 V0` table (confirmed from XRoar's own
source and cross-checked against Tim Lindner's CoCo/GIME memory-map
reference)

```
V2 V1 V0   Buffer size   Display modes
 0  0  0     512         AI (alphanumeric), SG4, SG6
 0  0  1    1024         G1C, G1R
 0  1  0    2048         G2C, SG8
 0  1  1    1536         G2R
 1  0  0    3072         G3C, SG12
 1  0  1    3072         G3R
 1  1  0    6144         G6R, G6C, SG24
 1  1  1    (not used)
```

**Important, and easy to get wrong: SG4 and SG6 share the exact same `V`
value (`000`).** The SAM's V-field only controls address-timing (how
often a byte is fetched); it does *not* by itself distinguish every
named mode. The SG4-vs-SG6 distinction, and text-vs-graphics generally,
comes from a **separate** chip and register — see the VDG section below.
This is the concrete reason "the SAM" and "the VDG" have to be understood
as two genuinely separate jobs, not one combined "display mode" concept.

The undocumented SG12 mode (used by the HERO port's original game) is the
`100` row above — a real, structural combination of these bits, just one
Tandy never documented as a supported BASIC-level mode. Same mechanism as
every officially-supported mode, no special-case wiring involved.

### `PMODE` number -> VDG name -> SAM `V` / VDG `GM` bits (confirmed
directly from ugBASIC's own `ugbc/src/hw/6847.c` register-configuration
code, 2026-08-26 -- not inferred from naming patterns)

```
PMODE  VDG name              Resolution  Colors  VRAM   SAM V(2,1,0)  GM(2,1,0)
  0    Resolution Graphics 2  128x96      2      1536   0,1,1 (011)   0,1,1
  1    Color Graphics 3       128x96      4      3072   1,0,0 (100)   1,0,0
  2    Resolution Graphics 3  128x192     2      3072   1,0,1 (101)   1,0,1
  3    Color Graphics 6       128x192     4      6144   1,1,0 (110)   1,1,0
  4    Resolution Graphics 6  256x192     2      6144   1,1,0 (110)   1,1,1
```

Two things worth being precise about, confirmed by this table rather
than assumed:

- **`PMODE3` and `PMODE4` genuinely share the identical SAM `V` value**
  (`110`) -- they differ *only* in the VDG's `GM0` bit (the last digit
  of the `GM` triplet), which controls bit-depth/color interpretation,
  not scanline-fetch timing. Any scanline-grouping or timing behaviour
  (e.g. the "6 rows = 1 visual line" MOD-group finding used throughout
  this project's SG12 work) that holds for one holds for the other --
  confirmed architecturally (separate SAM vs VDG registers) and now
  confirmed by the actual register values matching exactly.
- **`PMODE1` (Color Graphics 3) shares its SAM `V` value (`100`) with
  SG12 itself.** SG12 isn't a mode disconnected from the standard
  `PMODE` numbers -- it's the *same* SAM timing as `PMODE1`, just with
  different VDG `GM`/mode-select configuration to get the undocumented
  semigraphics-12 interpretation instead of ordinary 4-color Color
  Graphics 3. This is the concrete reason SG12 work in this project
  starts from `PMODE1`-adjacent register pokes, not from scratch.

### The VDG's own register — text/graphics, palette, and inversion (all
one register, `$FF22`/PIA1 "B side")

Confirmed directly in XRoar's own machine-specific source
(`dragon_update_vdg_mode`): all of CSS, GM, and the alpha/graphics select
live in the *same* register already used for the T1-lowercase EXT bit —
not four separate registers, one register with four separate purposes
packed into it:

```
bit 3 (0x08)   CSS   -- green/amber select (text border colour, etc.)
bit 4 (0x10)   EXT   -- character set selection (the T1-lowercase bit;
                         see basic-interpreter.md)
bits 4-6 (0x70) GM   -- 3-bit graphics mode; GM & 2 specifically drives
                         inverse_text
bit 7 (0x80)   nA_G  -- alpha/semigraphics mode vs. true bitmap graphics
```

Clean architectural split, confirmed rather than assumed: **PIA1
controls how the VDG interprets whatever byte it's currently looking
at** (palette, text-vs-graphics, inversion) — entirely separate from
**the SAM**, which only controls which byte gets fetched and when (the
`V2V1V0` table above). Two chips, two genuinely distinct jobs — most of
what makes SG4/SG8/SG12/SG24 behave the way they do falls directly out of
these two chips not being told the same thing at the same time.

### Why a text character can render showing any row, not just its top
(confirmed by tracing the actual render loop, not inferred from symptoms)

The VDG's scanline counter (`row`, range 0-11) is **free-running** —
it increments every scanline and wraps after 11, *completely
independent* of how often a new byte actually gets fetched. A new byte
is only fetched when `row % nLPR == 0` (`nLPR` = 12 for standard SG4/text
— fetch once per full character height). In faster-fetching modes,
`nLPR` is smaller, so that condition is true more often.

The consequence: `row` never resets when a new byte is fetched — it just
keeps counting on its own schedule, oblivious to whether the current byte
is old or new. If a text character happens to get fetched at the moment
`row` is sitting at 6, the glyph lookup becomes `font[code*12 + 6]` —
row 6 of that letter, a horizontal slice through its *middle*, not row 0.
Which row renders for any given character is purely a function of *when*
in the free-running 0-11 cycle that byte happened to get fetched — not
anything about the character itself.

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
