' SAUCER_STRUGGLE.BAS -- the original, over-literal 3-sprite attempt
' at "flying saucer with a dome, top arc, bottom arc" -- before the
' user clarified they meant ONE sprite with a color-changing region.
' Preserved here as a labeled historical artifact, not a live demo.
' This is the version that failed: compiles to $1E42-$C99F, well past
' the real (now understood) LOADM size ceiling of ~23569 bytes -- this
' file alone is ~40KB. At the time, the failure was misdiagnosed as an
' address-range ($C000+) problem; it was always just total size.
DIM SY AS INTEGER, VY AS INTEGER
DIM SX AS INTEGER, DOMEX AS INTEGER

Sprite_Load "ARC_BOTTOM.asm", 0
Sprite_Load "ARC_TOP.asm", 1
Sprite_Load "DOME_ORIGINAL.asm", 2, 2

GMODE 7,1
GMODE 7,0
GCLS 0
SCREEN 1,0
GCOPY 0,1

SX = 4
DOMEX = 20
SY = 52
VY = 1

MainLoop:
SPRITE LOCATE 0, SX, SY
SPRITE BACKUP 0
SPRITE SHOW 0, 0

SPRITE LOCATE 1, SX, SY - 32
SPRITE BACKUP 1
SPRITE SHOW 1, 0

SPRITE LOCATE 2, DOMEX, SY - 52
SPRITE BACKUP 2
SPRITE SHOW 2, 0

WAIT VBL

SPRITE ERASE 2
SPRITE ERASE 1
SPRITE ERASE 0

SY = SY + VY
IF SY < 52 THEN SY = 52 : VY = -VY
IF SY > 63 THEN SY = 63 : VY = -VY

GOTO MainLoop
