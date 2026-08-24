# SECB (Super Extended Color BASIC) vs ECB — what's actually different

Source: `../../coco/reference/xls-conversion/reference-tabs/differences-secb.csv`
(titled internally "BASIC 1.2/EXTENDED 1.1 vs COLOR EXTENDED 2.0
DIFFERENCES" — "Color Extended 2.0" is the CoCo 3's SECB). This tab is
laid out as a literal patch list: every section of code where the CoCo 3
ROM differs from the CB 1.2 / ECB 1.1 base, given as address + assembled
bytes/directive, so a CB/ECB disassembly annotation can be updated to
also describe the CoCo 3 ROM.

## How to use this

This is the authoritative source for "is X actually different on CoCo 3,
or does CoCo 1/2 documentation still apply unchanged." Before assuming
any CoCo 1/2 BASIC-interpreter behavior documented in the **coco**
skill's `basic-interpreter.md` carries over unchanged to SECB, check
whether the relevant address range appears here.

Example real entries (address, label, directive, meaning):

| Address | Label | Content |
|---|---|---|
| `$80C0` | `XBWMST` | `FCB $FF` — patched so a reset does *not* fall through to warm-start at this exact point (CoCo 1/2 behavior explicitly disabled here) |
| `$80E8` | `L80E8` | Text string `'EXTENDED COLOR BASIC 2.0'` — the CoCo 3's own version banner, replacing the CB/ECB one |
| `$8100`-`$8139` | — | Copyright/license string block, CoCo-3-specific wording |

The tab continues with further patch blocks (`PATCH1`, `PATCH13`, etc.)
— each one a self-contained diff against the base ROM at a specific
address. Read the full CSV directly for the complete patch list rather
than assuming this file's excerpt is exhaustive.

## Practical implication for porting

If something in a ported program depends on exact CB/ECB ROM behavior at
a specific address (rather than going through a documented BASIC
keyword/routine), **check this differences tab first** — the CoCo 3
genuinely patches specific bytes/routines rather than just adding new
ones alongside the old, so an address-level assumption carried over
from CoCo 1/2 work can be silently wrong on a CoCo 3 even when the
BASIC-language-level behavior looks identical.

## Related tabs for the other ROM revisions

- `differences-cb-1.0.csv`, `differences-cb-1.1.csv` — CB revision-to-
  revision differences (relevant to the **coco** skill directly, not
  CoCo-3-specific)
- `differences-ecb.csv` — ECB revision differences

Cross-reference these if working with anything version-specific — the
**coco** skill's `basic-interpreter.md` notes that the well-known
`&H95AC` T1-lowercase poke breaks specifically because of this kind of
revision-to-revision address drift, which these tabs document directly.
