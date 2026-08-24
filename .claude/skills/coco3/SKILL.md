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

## Reference data

Full SECB disassembly and reference tabs are converted the same way as
the coco skill's material — see `../coco/reference/xls-conversion/`:
- `reference-tabs/memory-map-secb.csv`, `symbols-secb.csv`,
  `routines-secb.csv`, `rom-routines-secb.csv`, `data-tables-secb.csv`,
  `differences-secb.csv` / `DIFFERENCES-SECB.csv`
- `reference-tabs/gime-chip.csv` (full register detail, this skill's
  `gime.md` is a curated subset)
- `reference-tabs/coco-3-colors.csv` (full 64-color table, RGB and
  composite values)
- `listings/secb/` — full SECB ROM disassembly, chunked by address range
  with an `INDEX.md` (same pattern as the coco skill's listings)

## When something seems like a CoCo 1/2 vs CoCo 3 discrepancy

Check `secb-differences.md` and the `differences-secb.csv` /
`DIFFERENCES-SECB.csv` tabs first — many apparent "bugs" in ported code
are actually genuine behavioral differences between BASIC dialects, not
compiler or logic errors. The **coco** skill's `ugbasic-compiler-notes.md`
is written from CoCo 1/2 (ECB) testing; re-verify anything
timing/hardware-register-sensitive against real CoCo 3 GIME behavior
before assuming it transfers unchanged.
