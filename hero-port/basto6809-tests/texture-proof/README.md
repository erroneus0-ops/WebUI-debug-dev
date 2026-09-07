# Proof: SG12 supports per-row texture detail PNGtoCCSB's stock pipeline can't reach

No `sprites.txt` here deliberately -- this program writes directly to
the SG12 screen buffer via inline assembly, bypassing `Sprite_Load`/
`PNGtoCCSB` entirely. Not built by the standard CI demo loop; a
standalone proof-of-concept.

## Why this exists

Comparing a real screenshot of HERO's level 1 against a direct memory
dump of its screen data (via this project's own VDG-simulating hex
dump) revealed HERO's brick-textured pillar uses a small, deliberate
vocabulary of quadrant patterns that **change row-by-row** -- genuine
independent detail at the single-scanline level.

Checked directly against `PNGtoCCSB.bas`'s own source
(`BASIC-To-6809/Source_Code/PNGtoCCSB.bas`, the aspect-ratio
compensation block, `Case 7`): SG12 sprites get
`SemiAspectNumerator=4, SemiAspectDenominator=1`, meaning **one source
PNG pixel is deliberately duplicated into 4 identical memory rows** --
correct, reasoned aspect-ratio behaviour for importing ordinary square-
pixel artwork (an SG12 memory row is physically only 2 real scanlines
tall; 4 duplicated rows @ 2 scanlines each approximates a square
pixel). Confirmed by directly counting compiled `STA` operations
between `LEAX 32,X` row-advances in a real compiled sprite and
cross-referencing against the known source pixel grid -- every source
row's opaque-pixel count appears exactly 4 times in a row in the
compiled output.

This means the stock tool, as designed, cannot produce HERO-style
per-row-varying texture -- not a bug, a real gap between what the
tool's import pipeline targets (ordinary art) and what the hardware
can actually do (independent row-level detail).

## What this program proves

Pokes 20 real, independent SG12 screen bytes directly, alternating two
quadrant patterns every single row (no duplication):

```
$C9 = semigraphics | colour 4 | topLeft+botRight  (diagonal \)
$C6 = semigraphics | colour 4 | topRight+botLeft  (diagonal /)
```

Quadrant bit mapping confirmed authoritative from this project's own
VDG simulator (traced directly from `mc6847.c`): bit3=topLeft,
bit2=topRight, bit1=botLeft, bit0=botRight.

**Confirmed working two ways:**
- Direct memory read (`wasm_read_byte` across all 20 rows) shows the
  real, alternating sequence `$C9,$C6,$C9,$C6,...` -- genuine
  independent rows, not 4-at-a-time duplication.
- Visually: a real zigzag/herringbone weave, structurally distinct
  from a solid block or anything PNGtoCCSB's duplicated-row output
  could produce.

One open item: colour 4 rendered white in this test rather than the
expected red -- the colour-index-to-real-colour mapping used here
hasn't been independently confirmed, doesn't affect the structural
point (genuine per-row detail), but worth pinning down before reusing
this for an actual HERO-matching brick texture.

## Next steps (not yet done)

- Confirm the real colour-index mapping.
- Build an actual reusable "brick pillar" texture matching HERO's
  visual style, not just a proof-of-concept zigzag.
- Consider drafting a specific, narrow feature request for Glen: an
  optional flag (e.g. `-raw`) that skips PNGtoCCSB's aspect-duplication
  step and writes source rows 1:1 to memory rows, for cases where an
  artist wants direct per-row control instead of automatic
  square-pixel correction. This proof-of-concept is the concrete
  before/after evidence such a request would point to.
