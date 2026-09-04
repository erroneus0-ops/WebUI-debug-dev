' SAUCER.BAS -- one small flying-saucer sprite in SG12 (GMODE 7)
' Same bounce pattern as BALLDEMO.BAS (full-screen X/Y bounce), same
' rough scale as the ball sprite -- just one sprite object, whose dome
' band cycles through 6 colours as it moves, instead of a static shape.
' Sprite generated with:
'   PNGtoCCSB -g7 -s0 -a6 SAUCER_SPR.png
DIM BX AS INTEGER, BY AS INTEGER
DIM VX AS INTEGER, VY AS INTEGER
DIM FRAMECOUNT AS INTEGER, FRAME AS INTEGER

Sprite_Load "SAUCER_SPR.asm", 0, 6

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
IF FRAME > 5 THEN FRAME = 0

GOTO MainLoop
