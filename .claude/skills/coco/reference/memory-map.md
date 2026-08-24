# CoCo memory map (stock CoCo 1/2)

Source: `Memory Map CB` / `Memory Map ECB` / `Memory Map SECB` / `Memory Map
DECB` tabs, converted to
`../xls-conversion/reference-tabs/memory-map-{cb,ecb,secb,decb}.csv`. Full
detail (all ~670-1,067 rows per tab) lives there — this file is the
commonly-needed subset with context, not a full copy.

## ROM regions

| Address | Name | Meaning |
|---|---|---|
| `$8000` | `EXBAS` | Extended Color BASIC ROM start |
| `$A000` | `BASIC` | Color BASIC ROM start |
| `$C000` | `ROMPAK` | Cartridge ROM pack space |

## Key zero-page variables (start of RAM, `$0000` up)

These are the interpreter's own working state — most BASIC-level bugs or
quirks trace back to one of these:

| Address | Name | Meaning |
|---|---|---|
| `$00` | `ENDFLG` | STOP/END flag: positive = STOP, negative = END |
| `$01` | `CHARAC` | terminator flag 1 |
| `$02` | `ENDCUR` | terminator flag 2 |
| `$03` | `TMPLOC` | scratch variable |
| `$04` | `IFCTR` | IF counter — how many IF statements in a line |
| `$05` | `DIMFLG` | array flag: 0 = evaluate, 1 = dimensioning |
| `$06` | `VALTYP` | type flag: 0 = numeric, `$FF` = string |
| `$07` | `GARBFL` | string-space garbage-collection housekeeping flag |
| `$08` | `ARYDIS` | disable array search (0 = allow search) |
| `$09` | `INPFLG` | input flag: READ = 0, INPUT ≠ 0 |
| `$0A` | `RELFLG` | relational operator flag |
| `$0B`-`$0C` | `TEMPPT` | temporary string stack pointer |
| `$0D`-`$0E` | `LASTPT` | address of last-used string stack address |

## Other named constants worth knowing

| Address/value | Name | Meaning |
|---|---|---|
| `8` | `BS` | backspace |
| `$D` | `CR` | Enter key |
| `$1B` | `ESC` | escape code |
| `$A` | `LF` | line feed |
| `$C` | `FORMF` | form feed |
| `$20` | `SPACE` | space |
| `58` | `STKBUF` | stack buffer room |
| `$45E` | `DEBDEL` | debounce delay |
| `250` | `LBUFMX` | max characters in a BASIC line |
| `$2600` | `DOSBUF` | RAM load location for the `DOS` command (see
  `hardware-io.md` / `6809-techniques.md` for the actual `DOS` boot
  mechanism traced through this buffer) |
| `18` | `SECMAX` | max sectors per track |
| `35` | `TRKMAX` | max tracks |
| `256` | `SECLEN` | sector length in bytes |

## Register block (memory-mapped hardware)

| Address | Name | Meaning |
|---|---|---|
| `$FF00` | `PIA0` | Peripheral Interface Adapter #0 |
| `$FF20` | `PIA1` | Peripheral Interface Adapter #1 |
| `$FF20` | `DA` | digital/analog converter (alias of `PIA1+0`) |
| `$FF40` | `DSKREG` | disk control register |
| `$FF48` | `FDCREG` | 1793 floppy disk controller register |
| `$FFC0` | `SAMREG` | SAM control register block start |

See `hardware-io.md` for the full SAM/PIA register breakdown (display
mode bits, ROM/RAM toggle, etc).

## RAM hook vector table

Starting at `$15E`, Color BASIC exposes 25 documented 3-byte `JMP` vectors
specifically so Extended/Disk BASIC ROMs can redirect Color BASIC's own
behavior without patching the base ROM. `$167` (decimal 359) is one of
these — the `CONSOLE OUT` hook, originally holding `JMP $CC1C`. See
`basic-interpreter.md` for the full traced call chain through this
vector (used by the T1-lowercase-font technique, among other things).

## Looking up more

- Full memory map CSVs (all constants, not just the ones above):
  `../xls-conversion/reference-tabs/memory-map-cb.csv` (CB),
  `memory-map-ecb.csv` (ECB), `memory-map-secb.csv` (SECB, CoCo 3's Super
  Extended Color BASIC — see the **coco3** skill for CoCo 3-specific
  detail), `memory-map-decb.csv` (Disk Extended Color BASIC).
- For actual ROM routine addresses and what they do, see
  `../xls-conversion/reference-tabs/routines-{cb,ecb,secb,decb}.csv`
  first (small, indexed) before going to the full listings.
