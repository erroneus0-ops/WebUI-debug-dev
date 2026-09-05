' SAUCER.BAS -- one small flying-saucer sprite in SG12 (GMODE 7)
' Same bounce pattern as BALLDEMO.BAS (full-screen X/Y bounce), same
' rough scale as the ball sprite -- one sprite object whose dome band
' cycles through 5 colours as it moves.
'
' 5 frames, not 6: confirmed by direct local bisection (2026-09-04/05)
' that 6 frames (23569-byte compiled program) hits a real, hard LOADM
' size ceiling somewhere between 21625 and 23569 bytes -- traced all
' the way to Disk Extended Color BASIC's own error-dispatch code
' ($D6FD-$D709 in the real ROM) computing error #20 (IO ERROR), not an
' address-range problem (this program never gets anywhere near $8000,
' let alone $C000). Same category of constraint as ugBASIC's own
' documented ~8960-byte LOADM chunking limit explored earlier in this
' project -- just a different threshold, and BasTo6809 doesn't appear
' to auto-chunk large single-sprite programs the way ugBASIC does.
' 5 frames (21625 bytes) confirmed booting correctly.
'
' Sprite generated with:
'   PNGtoCCSB -g7 -s0 -a5 SAUCER_SPR.png
DIM BX AS INTEGER, BY AS INTEGER
DIM VX AS INTEGER, VY AS INTEGER
DIM FRAMECOUNT AS INTEGER, FRAME AS INTEGER

Sprite_Load "SAUCER_SPR.asm", 0, 5

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

BX = BX + VX
BY = BY + VY

IF BX < 0 THEN BX = 0 : VX = -VX
IF BX > 43 THEN BX = 43 : VX = -VX
IF BY < 0 THEN BY = 0 : VY = -VY
IF BY > 67 THEN BY = 67 : VY = -VY

FRAMECOUNT = FRAMECOUNT + 1
IF FRAMECOUNT > 3 THEN FRAMECOUNT = 0 : FRAME = FRAME + 1
IF FRAME > 4 THEN FRAME = 0

GOTO MainLoop
