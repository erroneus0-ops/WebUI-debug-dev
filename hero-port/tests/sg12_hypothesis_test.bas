' ============================================================================
' sg12_hypothesis_test.bas
'
' PURPOSE
' -------
' This is NOT part of the HERO port itself. It is a standalone test to
' validate a specific technical hypothesis before committing to the full
' port:
'
'   Claim: ugBASIC's PMODE 4 (256x192, "Resolution 6") on the `coco` target
'   uses the *real* Motorola 6847 byte layout for that resolution (32 bytes
'   per row x 192 rows = 6144 bytes), because it has to render correctly on
'   real/emulated 6847 hardware. If true, we should be able to reproduce
'   Nick Marentes' original SG12 trick by hand -- draw normally in PMODE 4,
'   then POKE the same PIA/SAM registers he used, and the *same bytes*
'   should be reinterpreted by the VDG as 8-color SG12, with no corruption.
'
' If this works, the sprite still looks intact (just recolored) after the
' POKEs. If the hypothesis is wrong -- e.g. ugBASIC uses a different
' internal byte layout for this mode -- we'd expect to see garbage/noise
' instead of a clean recolor.
'
' This program deliberately does nothing "game-like." It draws one solid
' box with PUT IMAGE, flips the mode, and stops, so a screenshot after a
' fixed frame count is enough to judge success or failure by eye (and by a
' simple pixel-color check against a few known screen offsets in CI).
'
' Original technique (from HERO-SRC.BAS, v1.1, line 230):
'   SCREEN1,0:POKE&HFF9C,9:POKE&HFF22,0:POKE&HFFC5,1:POKE&HFFC2,1:POKE&HFFC0,1
'
' Register meanings (see PR description / hero-port/docs for the long
' version):
'   $FF22 bit 7 (nA_G)   = 0   -> VDG stays in a semigraphics mode
'   $FF9C                = 9   -> VDG mode register value used by Nick's hack
'   $FFC0/$FFC2/$FFC5    = 1   -> SAM V-mode bits driven to binary 100 = SG12
' ============================================================================

SCREEN 1, 0
PMODE 4, 1

' Draw a plain filled rectangle we can visually and programmatically check
' before and after the mode flip. Using native ugBASIC graphics primitives
' rather than a converted sprite, to isolate the *memory layout* question
' from any separate question about the sprite pipeline.
BOX (40, 40) - (100, 100), 1, BF

' Give a human or a CI screenshot step something to look at pre-flip.
WAIT VBL

' --- THE HACK, replicated by hand ---------------------------------------
' If ugbc's PMODE 4 buffer is byte-for-byte real 6847 layout, this should
' recolor the box (into SG12's 8-color palette) without corrupting its
' shape. If not, expect visual noise/garbage in the same screen region.
POKE &HFF9C, 9
POKE &HFF22, 0
POKE &HFFC5, 1
POKE &HFFC2, 1
POKE &HFFC0, 1

WAIT VBL

' Park here so a CI step has a stable frame to screenshot.
DO
LOOP
