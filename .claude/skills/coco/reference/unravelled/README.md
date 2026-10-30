# Unravelled ROM disassemblies — Claude-friendly edition

The complete commented disassemblies from the *Color BASIC Unravelled* series
(Spectral Associates; revised by Walter K. Zydhek), converted from
`Unravelled II.xls` into plain text built for `grep` and for reading one
small file at a time.

**Don't read whole folders, and don't read `SYMBOLS.txt` or the memory maps
whole.** Find the right file first (table below), then read only that one.

## How to look something up

| You have | Do this |
|---|---|
| A label or variable name (`DATPTR`, `KEYIN`, `LA0E2`) | `grep -w NAME SYMBOLS.txt` → its address and the exact file that defines it |
| A ROM address (`$A01F`) | `grep -rn "^A01F " <rom-folder>/`, or pick the chunk from the folder's `INDEX.md` (filenames carry the range: `cb_A000-A1CA.asm`) |
| A RAM address (a POKE/PEEK target like `$33`) | `grep -w 0033 SYMBOLS.txt` (shows every name at that address) |
| A task ("read a key", "print a character") | `grep -i` the `routines-*.txt` files: one routine per line, with registers modified and a plain-English description |
| A version difference | `tables/differences-*.txt` |

## Which ROM is which

| Folder | ROM | Address range | SHA-1 of genuine ROM |
|---|---|---|---|
| `cb-1.2/` | Color BASIC 1.2 | $A000-$BFFF | 0f14dc46c647510eb0b7bd3f53e33da07907d04f |
| `ecb-1.1/` | Extended Color BASIC 1.1 | $8000-$9FFF | ad927fb4f30746d820cb8b860ebb585e7f095dea |
| `decb-1.0/` | Disk Extended Color BASIC 1.0 | $C000-$DFFF | 04115be3f97952b9d9310b52f806d04f80b40d03 |
| `decb-1.1/` | Disk Extended Color BASIC 1.1 | $C000-$DFFF | 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1 |
| `secb/` | Super Extended Color BASIC 2.0 (CoCo 3) | $C000-$FFFF image | 9a05652fd80ab87219102800fe6a44a4ecacd8c3 |

The CoCo 3's lower half (Color BASIC 2.0 / Extended 2.0) is not a separate
listing: it is CB 1.2 + ECB 1.1 with the patches in
`tables/differences-secb.txt` applied. Much of the SECB code at $E000+ is
copied to RAM and runs there.

## Listing line format

```
ADDR  OBJECT BYTES      LABEL    OP    OPERAND             ; COMMENT
A01F  A6 84                      LDA   ,X                  ; GET FIRST BYTE OF WARM START ADDR
A027  31 8C E4          RESVEC   LEAY  LA00E,PC            ; POINT Y TO WARM START CHECK CODE
84B1  BD 84 46                   JSR   >LOG                ; GET NATURAL LOGARITHM OF FPA0
* lines starting with * are the book's block comments
```

- Addresses and bytes are hex without `$`. The 6809 is **big-endian**: a
  2-byte value at `$nn` has its high byte at `$nn` and its low byte at `$nn+1`.
- On `EQU` lines the first column is the constant's **value**, not an address.
- `>` before an operand marks forced extended addressing, as in the book.
- `Lxxxx` labels are the disassembler's local labels, named for their address.
- Comments are the book's own wording. Some begin with `*` or `=`, which in the
  book group a comment that spans several lines.

## Verification: why the bytes and labels can be trusted

**Bytes.** Every object byte in all five listings was compared with the
genuine ROM image (the SHA-1 hashes above match MAME's known-good dumps).
CB 1.2, ECB 1.1, DECB 1.1 and SECB matched with **zero** errors. In DECB 1.0,
26 spreadsheet lines carried stale bytes copied from 1.1. Those lines now hold
the real ROM bytes, and each says so in its comment
(`[bytes corrected to match genuine ROM; spreadsheet had ...]`):

| Addr | Spreadsheet had | ROM (now) | Line |
|---|---|---|---|
| $C155 | 32 | 31 | `FCB CYEAR` |
| $C1DB | CC A9 | CB CF | `FDB DIR` |
| $C1DD | CE C5 | CD E9 | `FDB DRIVE` |
| $C1DF | D0 BC | CF E0 | `FDB FIELD` |
| $C1E1 | D1 5C | D0 80 | `FDB FILES` |
| $C1E3 | C6 EF | C6 C2 | `FDB KILL` |
| $C1E5 | CA 48 | C9 9A | `FDB LOAD` |
| $C1E7 | D1 02 | D0 26 | `FDB LSET` |
| $C1E9 | CA 39 | C9 8B | `FDB MERGE` |
| $C1EB | D0 1B | CF 3F | `FDB RENAME` |
| $C1ED | D1 01 | D0 25 | `FDB RSET` |
| $C1EF | C9 E0 | C9 32 | `FDB SAVE` |
| $C1F1 | D0 66 | CF 8A | `FDB WRITE` |
| $C1F3 | D7 4E | D6 5B | `FDB VERIFY` |
| $C1F5 | D2 33 | D1 46 | `FDB UNLOAD` |
| $C1F7 | D5 99 | D4 AB | `FDB DSKINI` |
| $C1F9 | D2 62 | D1 75 | `FDB BACKUP` |
| $C1FB | D3 B9 | D2 CC | `FDB COPY` |
| $C1FD | D4 ED | D3 FF | `FDB DSKI` |
| $C1FF | D5 62 | D4 74 | `FDB DSKO` |
| $C214 | CD F4 | CD 1A | `FDB CVN` |
| $C216 | CE 9C | CD C0 | `FDB FREE` |
| $C218 | CE 10 | CD 36 | `FDB LOC` |
| $C21A | CE 37 | CD 5B | `FDB LOF` |
| $C21C | CE 02 | CD 28 | `FDB MKN$` |
| $D212 | 86 33 | 86 03 | `LDA #$03` |

**Labels.** Every branch, JSR/JMP and vector-table entry encodes its target
address in the verified bytes, so each referenced label's position can be
checked against the code that uses it. All 2,632 referenced label definitions were
checked, and all agree with the ROM after these fixes. Four
labels sat one line off in the spreadsheet and have been moved to the address
the code proves; each moved line says so in its comment:

| Listing | Label | Spreadsheet put it at | Code proves it is at |
|---|---|---|---|
| CB 1.2 | LB35C | $B35E | $B35C |
| CB 1.2 | LB51A | $B51C | $B51A |
| DECB 1.1 | DOSINI | $DF46 | $DF4C |
| DECB 1.1 | LDF36 | $DF2F | $DF36 |

The book's separate symbol-table tabs also disagree with the listings in two
places. `SYMBOLS.txt` follows the verified listing:

| Name | Tab | Symbol tab says | Verified listing |
|---|---|---|---|
| COLOR | Symbols ECB 1.1 | $9542 | $9546 |
| RESET | Symbols ECB 1.1 | $FFFE | $A8B1 |

(`COLOR` at $9546 is proven by the ECB command dispatch table entry `FDB COLOR`
= `95 46`. `RESET` in that tab is probably the reset *vector* at $FFFE rather
than the routine.)

Regions of the ROM images the book does not list: DECB 1.0 $D7DD-$DFFF,
DECB 1.1 $D8D0-$DEFF and $DF59-$DFFF, SECB $C36C-$DFFF and $FA0C-$FFFF.
Most of the SECB gap is data, not code: `AUTHPIC` ($C405-$DC04, $1800 bytes)
is the digitized picture of the SECB authors that CTRL+ALT+RESET displays as a
256x192 two-color image (see `LC1F0` in `secb/secb_C1D6-C255.asm`).

## Known errors in the book's own comments

- Memory maps: `ROMCLR` (`$FFDE`) is commented "ROM DISABLED" and `ROMSET`
  (`$FFDF`) "ROM ENABLED". **Backwards.** The ROM's own code at `$C1B1`
  (SECB) enables ROM with `$FFDE` and disables it with `$FFDF`.

## Other files

- `SYMBOLS.txt` — every label, one per line (~3,800). Grep it.
- `memory-map-{cb,ecb,secb,decb}.asm` — constants and RAM/direct-page
  variables with their addresses. The ECB, SECB and DECB maps are supersets
  of the CB map. Grep these too; they are long.
- `routines-*.txt`, `floating-point-routines-cb.txt` — callable routines, one per line.
- `tables/` — the book's other tables as aligned text: data tables (where
  each ROM table and message lives), version differences, error-entry jump
  points, the SECB ROM call table, GIME registers, the CoCo 3 palette, the
  CoCo 3 hi-res character set, and the VDG ASCII charts.

Regenerate with `tools/unravelled/` in the repository root (see its README).
