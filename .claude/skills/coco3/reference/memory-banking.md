# CoCo 3 memory banking (MMU)

**Confidence note:** unlike most of the `coco` skill's content, this file
is derived from the GIME register documentation in
`gime-chip.csv` (i.e. from Tandy/Microware's own spec as transcribed in
the disassembly), not from the same kind of direct empirical
PEEK/POKE/disassembly-trace verification used for the CoCo 1/2 material.
Treat mechanics described here as "documented," not "independently
confirmed" — verify against real hardware/emulator behavior before
relying on precise semantics for something banking-sensitive.

## Why the CoCo 3 needs this at all

The CoCo 1/2 SAM chip has one address space and one simple all-or-nothing
ROM/RAM toggle (`$FFDE`/`$FFDF` — see the **coco** skill's
`hardware-io.md`). That's sufficient for 64K total. The CoCo 3 supports
128K or 512K of RAM, which cannot fit in the CPU's 64K logical address
space at once — the GIME's MMU exists to map 8K logical pages to
different physical RAM blocks ("banks"), swappable under program control.

## The two task registers

- `$FFA0`-`$FFA7` — MMU Task Register 0 (8 bytes, one per 8K logical
  page)
- `$FFA8`-`$FFAF` — MMU Task Register 1 (same, second bank)

`INIT1`'s (`$FF91`) `TR` bit (bit 0) selects which of the two task
registers is currently active. Each byte in the active task register
maps one 8K logical page (the CPU's normal 64K address space is 8 such
pages) to a specific 8K physical block of the larger RAM pool.

## Practical implications for porting/writing code

- Code or data that needs to persist across a bank switch must either
  live in a logical page that isn't being remapped, or be copied/restored
  explicitly around the switch — the same general caution as the CoCo
  1/2 ROM/RAM toggle (don't execute from a region you're about to remap
  out from under yourself), but now per-8K-page rather than all-or-
  nothing.
- `MMUEN` (`INIT0` bit 6) must be set for the MMU to actually be active;
  in `COCO`-compatible mode the machine behaves like a plain CoCo 1/2
  with no banking.
- Check `../../coco/reference/xls-conversion/reference-tabs/gime-chip.csv`
  directly for any bit-level detail not covered above — this file is
  intentionally the commonly-needed subset, not the full spec transcript.
