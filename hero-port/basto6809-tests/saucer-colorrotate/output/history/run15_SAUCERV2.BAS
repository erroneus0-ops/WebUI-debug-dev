' SAUCERV2.BAS -- in-place colour rotation, not PNGtoCCSB duplicate frames.
' One sprite, one compiled copy of its pixel data. The dome's colour
' bits get self-modified directly in the sprite's own compiled draw
' routine (SAUCER_ONE_0_0..SAUCER_ONE_0_1) before each redraw, instead
' of switching between pre-baked colour frames -- avoids the LOADM
' size ceiling entirely (confirmed: every dome cell currently holds
' the identical byte $BF -- semigraphics flag + colour 3 + full
' pattern -- so this is a flat find-and-replace, no per-pixel mask
' table needed, since colour and shape live in separate bit fields
' and every dome cell already shares one value).
' X position fixed deliberately -- moving would eventually cross a
' byte-alignment boundary and start using the sprite's OTHER compiled
' variant (SAUCER_ONE_0_1), which this recolour routine doesn't touch.
' Bounces in Y only for this version.
DIM BY AS INTEGER, VY AS INTEGER
DIM DOMECUR AS INTEGER, DOMENEXT AS INTEGER
DIM COLORIDX AS INTEGER, FRAMECOUNT AS INTEGER

Sprite_Load "SAUCER_ONE.asm", 0

GMODE 7,1
GMODE 7,0
GCLS 0
SCREEN 1,0
GCOPY 0,1

BY = 0
VY = 1
DOMECUR = &HBF
COLORIDX = 0
FRAMECOUNT = 0

MainLoop:
SPRITE LOCATE 0, 10, BY
SPRITE BACKUP 0
SPRITE SHOW 0, 0
WAIT VBL
SPRITE ERASE 0

A$ = INKEY$
IF A$ <> "" THEN END

BY = BY + VY
IF BY < 0 THEN BY = 0 : VY = -VY
IF BY > 67 THEN BY = 67 : VY = -VY

FRAMECOUNT = FRAMECOUNT + 1
IF FRAMECOUNT > 6 THEN GOSUB 9000
GOTO MainLoop

9000 REM -- recolour the dome in place --
FRAMECOUNT = 0
COLORIDX = COLORIDX + 1
IF COLORIDX > 6 THEN COLORIDX = 0
IF COLORIDX = 0 THEN DOMENEXT = &H8F
IF COLORIDX = 1 THEN DOMENEXT = &H9F
IF COLORIDX = 2 THEN DOMENEXT = &HAF
IF COLORIDX = 3 THEN DOMENEXT = &HBF
IF COLORIDX = 4 THEN DOMENEXT = &HDF
IF COLORIDX = 5 THEN DOMENEXT = &HEF
IF COLORIDX = 6 THEN DOMENEXT = &HFF
' ADDASSEM:
        LDA   _Var_DOMENEXT+1
        LDX   #SAUCER_ONE_0_0
RecolorScan:
        CMPX  #SAUCER_ONE_0_1
        BEQ   RecolorDone
        LDB   ,X
        CMPB  _Var_DOMECUR+1
        BNE   RecolorSkip
        STA   ,X
RecolorSkip:
        LEAX  1,X
        BRA   RecolorScan
RecolorDone:
' ENDASSEM:
DOMECUR = DOMENEXT
RETURN
