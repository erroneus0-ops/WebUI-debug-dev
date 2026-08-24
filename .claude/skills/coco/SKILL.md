---
name: coco
description: Use when working with TRS-80 Color Computer (CoCo 1/2) hardware, Color BASIC / Extended Color BASIC / Disk Extended Color BASIC internals, 6809 assembly on the CoCo, or compiled-BASIC toolchains (ugBASIC, BASIC-to-6809) targeting the CoCo. Covers memory map, SAM/PIA registers, display modes, the BASIC tokenizer/interpreter, ROM call chains, and known ugBASIC compiler quirks. For CoCo 3-specific hardware (GIME chip, banked memory, extra display modes), use the coco3 skill instead or in addition.
---

# CoCo (TRS-80 Color Computer 1/2) reference skill

This skill packages verified, empirically-confirmed knowledge about the
stock CoCo 1/2 machine and its BASIC dialects, plus a full disassembly
reference converted from `Unravelled II.xls` into plain CSV for direct
lookup (no spreadsheet library needed).

**Load only what the current task needs — this file is the index, not the
content.** Each reference file below is self-contained.

## What CoCo BASIC actually is

Color BASIC (and its Extended/Disk extensions) is *not* an operating
system in the modern sense — no process model, no filesystem abstraction,
no privilege separation. It's an interpreter loop plus a flat set of ROM
subroutines for hardware access, wired together through documented
jump-vector tables so that Extended/Disk BASIC ROMs can redirect Color
BASIC's own behavior without patching the base ROM. Reading the
disassembly means reading "what routine does what," not "what does the OS
abstract away" — there is no abstraction layer to find.

## Reference files (load as needed)

- **`reference/memory-map.md`** — RAM/ROM layout, zero-page variables,
  key fixed addresses (BASIC pointers, buffers, vectors).
- **`reference/hardware-io.md`** — SAM and PIA registers: display mode
  bits, ROM/RAM toggle, cassette, joystick, sound, serial.
- **`reference/basic-interpreter.md`** — tokenizer (`CRUNCH`) behavior,
  keyword-matching quirks, control-code (`CHR$`) behavior, RAM hook
  vectors used for redirecting BASIC's own routines.
- **`reference/6809-techniques.md`** — verified low-level techniques
  (stack-blasting fast memory copy, safe ROM→RAM patching, testing real
  machine code from BASIC via `DATA`/`POKE`/`EXEC`).
- **`reference/ugbasic-compiler-notes.md`** — known ugBASIC compiler bugs
  and workarounds when targeting the `coco` platform, found while porting
  a real BASIC program to it.
- **`reference/conventions.md`** — how to read the disassembly CSVs
  (column layout, `EQU`/`FDB`/`ORG` conventions used throughout).
- **`reference/xls-conversion/`** — the full disassembly, converted from
  `Unravelled II.xls`. Small tabs (memory maps, routine indexes, symbol
  tables, differences between ROM versions, ASCII charts) are single CSV
  files under `xls-conversion/reference-tabs/`. The four large full-ROM
  listings (`CB 1.2`, `ECB 1.1`, `SECB`, `DECB 1.1`/`DECB 1.0`) are
  chunked by address range under `xls-conversion/listings/<tab>/`, each
  with its own `INDEX.md` mapping address range → chunk file. See
  `xls-conversion/MANIFEST.md` for the full tab-to-file map.

## How to look something up

1. Know roughly what you need: a named routine/variable (check
   `reference-tabs/routines-*.csv` or `symbols-*.csv` first — much
   smaller than the full listing), or a specific address (go straight to
   the relevant listing's `INDEX.md` to find the right chunk).
2. Only read the one chunk file that covers the address range you need —
   never read a whole `listings/<tab>/` directory's chunks at once.
3. Cross-check against `reference/COCO-BASIC-INTERNALS.md`-derived notes
   above first — many common questions (T1 lowercase hack, 64K/all-RAM
   mode, the SAM register map, tokenizer quirks) are already answered
   there with the full traced call chain, not just a raw listing row.

## Scope note

This skill covers the stock CoCo 1/2: one SAM chip, a plain 64K address
space, a simple all-or-nothing ROM/RAM toggle. The CoCo 3's GIME chip
replaces the SAM with a genuinely more elaborate banked-MMU system, and
adds new display modes and a 64-color palette — see the **coco3** skill
for that hardware and for Super Extended Color BASIC (SECB)-specific
behavior beyond what's noted here.
