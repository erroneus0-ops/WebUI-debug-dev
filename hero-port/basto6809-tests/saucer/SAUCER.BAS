' SAUCER.BAS -- classic flying saucer in SG12 (GMODE 7)
' Two layered sprites: BODY (merged yellow-top/white-bottom hull, one
' sprite instead of two -- cuts one sprite's worth of backup/restore
' overhead versus the original 3-sprite version, which compiled to an
' address range spanning into $C000+, the Disk Extended Color BASIC
' ROM's own territory, and failed to LOADM with ?IO ERROR) and DOME
' (blue dome, 2-frame blink, toggled on a timer independent of motion).
' Sprites generated with:
'   PNGtoCCSB -g7 -s0 BODY.png
'   PNGtoCCSB -g7 -s0 -a2 DOME.png
' Motion is a gentle vertical hover within a narrow, bounds-checked
' range -- footprints are large relative to the 64x96 SG12 playfield,
' not much spare room otherwise.
DIM SY AS INTEGER, VY AS INTEGER
DIM SX AS INTEGER, DOMEX AS INTEGER
DIM BLINKCOUNT AS INTEGER, BLINKFRAME AS INTEGER

Sprite_Load "BODY.asm", 0
Sprite_Load "DOME.asm", 1, 2

GMODE 7,1
GMODE 7,0
GCLS 0
SCREEN 1,0
GCOPY 0,1

SX = 4
DOMEX = 20
SY = 20
VY = 1
BLINKCOUNT = 0
BLINKFRAME = 0

MainLoop:
SPRITE LOCATE 0, SX, SY
SPRITE BACKUP 0
SPRITE SHOW 0, 0

SPRITE LOCATE 1, DOMEX, SY - 20
SPRITE BACKUP 1
SPRITE SHOW 1, BLINKFRAME

WAIT VBL

SPRITE ERASE 1
SPRITE ERASE 0

SY = SY + VY
IF SY < 20 THEN SY = 20 : VY = -VY
IF SY > 31 THEN SY = 31 : VY = -VY

BLINKCOUNT = BLINKCOUNT + 1
IF BLINKCOUNT > 8 THEN BLINKCOUNT = 0 : BLINKFRAME = 1 - BLINKFRAME

GOTO MainLoop
