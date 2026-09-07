' SAUCER.BAS -- one small flying-saucer sprite in SG12 (GMODE 7)
' Same bounce pattern as BALLDEMO.BAS. One sprite whose dome band
' cycles colour (red/yellow) as it moves; space bar exits (INKEY$).
'
' Proportions (2026-09-05, second pass): disc widened to ~2x the
' dome's width. First pass at this also grew the sprite one row
' taller (7->8) by accident; this version restores the exact original
' height (7) -- width-only change, as asked. Frame count still 2
' (not the earlier 5/6) because width alone already spends real
' budget against the known LOADM ceiling (documented in git history --
' see commit fixing "5 frames not 6"); this is the width/colour-count
' tradeoff the planned in-place colour-rotation rewrite would remove.
'
' Space-bar exit: added per request, using the documented INKEY$
' function exactly as the manual describes it. NOT verified booting
' end-to-end -- XRoar's -type flag is a ROM-call interception hook
' (per its own --help text), and this compiler's INKEY$ reads the PIA
' keyboard hardware directly, bypassing ROM entirely (consistent with
' "doesn't use any ROM calls" -- see README). -type structurally can't
' reach it; a real test needs genuine SDL keyboard-event injection
' against a live display, not attempted here.
'
' Sprite generated with:
'   PNGtoCCSB -g7 -s0 -a2 SAUCER_SPR.png
DIM BX AS INTEGER, BY AS INTEGER
DIM VX AS INTEGER, VY AS INTEGER
DIM FRAMECOUNT AS INTEGER, FRAME AS INTEGER
Sprite_Load "SAUCER_SPR.asm", 0, 2
GMODE 7,1
GMODE 7,0
GCLS 0
SCREEN 1,0
GCOPY 0,1
BX = 0
BY = 0
VX = 1
VY = 1
FRAMECOUNT = 0
FRAME = 0
MainLoop:
SPRITE LOCATE 0, BX, BY
SPRITE BACKUP 0
SPRITE SHOW 0, FRAME
WAIT VBL
SPRITE ERASE 0
A$ = INKEY$
IF A$ = " " THEN END
BX = BX + VX
BY = BY + VY
IF BX < 0 THEN BX = 0 : VX = -VX
IF BX > 23 THEN BX = 23 : VX = -VX
IF BY < 0 THEN BY = 0 : VY = -VY
IF BY > 63 THEN BY = 63 : VY = -VY
FRAMECOUNT = FRAMECOUNT + 1
IF FRAMECOUNT > 3 THEN FRAMECOUNT = 0 : FRAME = FRAME + 1
IF FRAME > 1 THEN FRAME = 0
GOTO MainLoop
