---
name: coco3
description: Use when working with TRS-80 Color Computer 3 (CoCo 3) specific hardware — the GIME chip, banked/MMU memory (128K/512K), the extra graphics modes and 64-color palette, or Super Extended Color BASIC (SECB). Requires the coco skill for base machine and BASIC-interpreter knowledge shared with CoCo 1/2 — this skill covers only what's genuinely new or different on the CoCo 3.
---

# CoCo 3 reference skill

The CoCo 3 keeps the same 6809 CPU and the same Color BASIC interpreter
core as the CoCo 1/2 (see the **coco** skill for that shared foundation —
tokenizer behavior, RAM hook vectors, 6809 techniques, and the base
memory map all still apply). What's genuinely new is the **GIME chip**
(replacing the SAM entirely), proper bank-switched MMU memory, new
display modes, and a 64-color palette. This skill covers only that delta.

## Reference files

- **`reference/gime.md`** — GIME chip register map (`$FF90`-`$FFAF`):
  interrupt control, video mode/resolution/border registers, MMU task
  registers.
- **`reference/memory-banking.md`** — how the MMU replaces the CoCo 1/2's
  simple ROM/RAM toggle with genuine bank-switched pages for 128K/512K.
- **`reference/display-and-color.md`** — new graphics modes and the
  64-color palette (RGB vs composite/CMP monitor color values).
- **`reference/secb-differences.md`** — what's different in Super
  Extended Color BASIC vs Extended Color BASIC, pointing at the
  `Differences SECB` / `DIFFERENCES SECB` reference tabs.

- **`reference/reset-and-rom-copy.md`** — BASIC runs from a RAM copy of
  the ROMs; why POKE patches to BASIC survive a plain RESET; how
  CTRL+ALT+RESET (the authors' picture) forces a fresh ROM copy.

## Reference data

The full SECB disassembly and reference tables live in the coco skill, in
`../coco/reference/unravelled/` (read its `README.md` first for the line
format and lookup method):
- `secb/` — full SECB ROM disassembly, chunked at routine boundaries,
  with an `INDEX.md`; bytes and labels verified against the genuine ROM
- `memory-map-secb.asm`, `routines-secb.txt`, `SYMBOLS.txt` (grep it)
- `tables/rom-routines-secb.txt`, `tables/data-tables-secb.txt`,
  `tables/differences-secb.txt`
- `tables/gime-chip.txt` (full register detail; this skill's `gime.md` is
  a curated subset)
- `tables/coco3-colors.txt` (full 64-color table, RGB and composite values)
- `tables/charset-coco3.txt` (hi-res text character set)

## When something seems like a CoCo 1/2 vs CoCo 3 discrepancy

Check `secb-differences.md` and
`../coco/reference/unravelled/tables/differences-secb.txt` first — many apparent "bugs" in ported code
are actually genuine behavioral differences between BASIC dialects, not
compiler or logic errors. The **coco** skill's `ugbasic-compiler-notes.md`
is written from CoCo 1/2 (ECB) testing; re-verify anything
timing/hardware-register-sensitive against real CoCo 3 GIME behavior
before assuming it transfers unchanged.
