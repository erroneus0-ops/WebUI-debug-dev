' SAUCER.BAS -- classic flying saucer in SG12 (GMODE 7)
' Three layered sprites: ARC_BOTTOM (white rim), ARC_TOP (yellow hull),
' DOME (blue dome, 2-frame blink, toggled on a timer independent of
' motion). Sprites generated with:
'   PNGtoCCSB -g7 -s0 ARC_TOP.png
'   PNGtoCCSB -g7 -s0 ARC_BOTTOM.png
'   PNGtoCCSB -g7 -s0 -a2 DOME.png
' Footprints are large relative to the 64x96 SG12 playfield (56x36 /
' 56x32 / 24x32), so motion here is a gentle vertical hover within a
' narrow, bounds-checked range rather than a full bounce -- there
' isn't meaningful spare room otherwise. Layer offsets (32/52 below)
' are a first approximation for stacking the three pieces into one
' silhouette; may want a pixel or two of adjustment once seen live.
DIM SY AS INTEGER, VY AS INTEGER
DIM SX AS INTEGER, DOMEX AS INTEGER
DIM BLINKCOUNT AS INTEGER, BLINKFRAME AS INTEGER

Sprite_Load "ARC_BOTTOM.asm", 0
Sprite_Load "ARC_TOP.asm", 1
Sprite_Load "DOME.asm", 2, 2

GMODE 7,1
GMODE 7,0
GCLS 0
SCREEN 1,0
GCOPY 0,1

SX = 4
DOMEX = 20
SY = 52
VY = 1
BLINKCOUNT = 0
BLINKFRAME = 0

MainLoop:
SPRITE LOCATE 0, SX, SY
SPRITE BACKUP 0
SPRITE SHOW 0, 0

SPRITE LOCATE 1, SX, SY - 32
SPRITE BACKUP 1
SPRITE SHOW 1, 0

SPRITE LOCATE 2, DOMEX, SY - 52
SPRITE BACKUP 2
SPRITE SHOW 2, BLINKFRAME

WAIT VBL

SPRITE ERASE 2
SPRITE ERASE 1
SPRITE ERASE 0

SY = SY + VY
IF SY < 52 THEN SY = 52 : VY = -VY
IF SY > 63 THEN SY = 63 : VY = -VY

BLINKCOUNT = BLINKCOUNT + 1
IF BLINKCOUNT > 8 THEN BLINKCOUNT = 0 : BLINKFRAME = 1 - BLINKFRAME

GOTO MainLoop
