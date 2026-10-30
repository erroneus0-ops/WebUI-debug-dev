---
name: coco
description: Use when working with TRS-80 Color Computer (CoCo 1/2) hardware, Color BASIC / Extended Color BASIC / Disk Extended Color BASIC internals, 6809 assembly on the CoCo, or compiled-BASIC toolchains (ugBASIC, BASIC-to-6809) targeting the CoCo. Includes the complete, ROM-verified Color BASIC Unravelled disassemblies (Color/Extended/Disk/Super Extended BASIC). Use it whenever a question involves a CoCo ROM routine or address, a PEEK/POKE/EXEC target, BASIC internals, or 6809 code that calls into or patches the ROM. Covers memory map, SAM/PIA registers, display modes, the BASIC tokenizer/interpreter, ROM call chains, and known ugBASIC compiler quirks. For CoCo 3-specific hardware (GIME chip, banked memory, extra display modes), use the coco3 skill instead or in addition.
---

# CoCo (TRS-80 Color Computer 1/2) reference skill

This skill packages verified, empirically-confirmed knowledge about the
stock CoCo 1/2 machine and its BASIC dialects, plus the complete
*Color BASIC Unravelled* ROM disassemblies as plain-text listings whose
bytes and labels have been verified against genuine ROM images.

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
- **`reference/conventions.md`** — 6809 assembler directives and
  conventions used in the listings (`EQU`, `RMB`, `FDB`, `FCC`, `SETDP`,
  direct-page `<` and extended `>` operand prefixes).
- **`reference/unravelled/`** — the full Unravelled disassemblies of
  Color BASIC 1.2, Extended 1.1, Disk 1.0 and 1.1, and Super Extended
  (CoCo 3), plus memory maps, routine tables, a global symbol index and the
  book's other tables. **Read `unravelled/README.md` first**: it explains
  the line format and lookup method, and records the verification.
- **`reference/CoCo Hardware Reference v2.pdf`** — hardware reference
  document. PDF is costly to read; check the markdown files above first and
  open this only for detail they don't cover.

## How to look something up

1. **A name** (routine, label, RAM variable): `grep -w NAME
   reference/unravelled/SYMBOLS.txt` gives its address and the file that
   defines it. Open only that file.
2. **An address**: `grep -rn "^A01F " reference/unravelled/cb-1.2/` (use
   the folder for the ROM in question), or for RAM `grep -w 0033
   reference/unravelled/SYMBOLS.txt`.
3. **A task** ("how does BASIC read the keyboard"): `grep -i` the
   `reference/unravelled/routines-*.txt` files (one routine per line), then
   open the listing chunk for the address it gives.
4. Never read a whole listing folder, `SYMBOLS.txt` or a memory map in
   full. Each listing chunk is about 260 lines, sized to be read whole.
5. Check the curated notes above first: many common questions (T1
   lowercase hack, 64K/all-RAM mode, the SAM register map, tokenizer
   quirks) are already answered there with the full traced call chain.

## Scope note

This skill covers the stock CoCo 1/2: one SAM chip, a plain 64K address
space, a simple all-or-nothing ROM/RAM toggle. The CoCo 3's GIME chip
replaces the SAM with a genuinely more elaborate banked-MMU system, and
adds new display modes and a 64-color palette — see the **coco3** skill
for that hardware and for Super Extended Color BASIC (SECB)-specific
behavior beyond what's noted here.
