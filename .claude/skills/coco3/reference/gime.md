# GIME chip register map

Source: `../../coco/reference/xls-conversion/reference-tabs/gime-chip.csv`
(full detail — this is the curated subset covering the most commonly
needed registers). The GIME's registers are mapped into the I/O page
(`$FF00`-`$FFFF`), always present in the logical address space regardless
of MMU state. `$FF90`-`$FFBF` is the direct link to the GIME chip itself.

## `$FF90` — Initialization Register 0 (INIT0)

| Bit | Name | Meaning |
|---|---|---|
| 7 | `COCO` | 1 = Color Computer compatible mode |
| 6 | `MMUEN` | 1 = MMU enabled (CoCo compat mode = 0) |
| 5 | `IEN` | 1 = chip IRQ output enabled |
| 4 | `FEN` | 1 = chip FIRQ output enabled |
| 3 | `MC3` | 1 = RAM at `$FEFF` is constant |
| 2 | `MC2` | 1 = `$FF40`-`4F` external; 0 = internal |
| 1-0 | `MC1`/`MC0` | ROM map control (see below) |

ROM mapping from `MC1`/`MC0`:

| MC1 | MC0 | Mapping |
|---|---|---|
| 0 | X | 16K internal, 16K external |
| 1 | 0 | 32K internal |
| 1 | 1 | 32K external (except vectors) |

## `$FF91` — Initialization Register 1 (INIT1)

| Bit | Name | Meaning |
|---|---|---|
| 5 | `TINS` | timer clock: 1 = 70ns, 0 = 63.5µs |
| 0 | `TR` | MMU task register select |

## `$FF92` / `$FF93` — IRQ / FIRQ Enable-Status (IRQENR / FIRQENR)

Same bit layout for both registers — one controls IRQ, the other FIRQ:

| Bit | Name | Source |
|---|---|---|
| 5 | `TMR` | Timer |
| 4 | `HBORD` | Horizontal border |
| 3 | `VBORD` | Vertical border |
| 2 | `EI2` | RS-232 serial port |
| 1 | `EI1` | Keyboard |
| 0 | `EI0` | Cartridge port |

## `$FF94`/`$FF95` — Timer Register (MSB/LSB)

12-bit timer value: bits 0-3 of `$FF94` are the most significant 4 bits,
`$FF95` is the least significant 8 bits.

## `$FF98` — Video Mode Register

## `$FF99` — Video Resolution Register

## `$FF9A` — Border Register

(See `display-and-color.md` for how these interact with the palette and
graphics modes — this file covers register *addresses*, not mode
semantics.)

## `$FFA0`-`$FFA7` — MMU Task Register 0

## `$FFA8`-`$FFAF` — MMU Task Register 1

Two independent 8-page task registers, each mapping the CPU's 8K logical
pages to physical RAM blocks — this is the real mechanism behind
128K/512K banked memory on the CoCo 3, replacing the CoCo 1/2 SAM's
simple all-or-nothing ROM/RAM toggle entirely. See
`memory-banking.md` for how task switching (`INIT1`'s `TR` bit) and these
two register blocks work together in practice.
