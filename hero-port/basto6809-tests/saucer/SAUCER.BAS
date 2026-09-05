' SAUCER.BAS -- one small flying-saucer sprite in SG12 (GMODE 7)
' Same bounce pattern as BALLDEMO.BAS (full-screen X/Y bounce). One
' sprite whose dome band cycles colour as it moves.
'
' Proportions updated 2026-09-05: disc is now ~2x the dome's width
' (previously disproportionately dome-heavy). Widening cost real byte
' budget against the same LOADM ceiling documented below -- dropped
' from 5 colour frames to 2 (red, yellow) to fit. This is exactly the
' frame-vs-size tradeoff flagged as worth fixing properly: PNGtoCCSB's
' -aN multi-frame approach stores a full duplicate bitmap per colour,
' so every added colour costs a whole sprite's worth of bytes again.
' The real fix -- planned, not yet built -- is a small hand-written
' inline-assembly routine that rotates the colour bits of the existing
' stored bytes in place (mask out bits 4-6, OR in the new colour),
' using a second reference copy of the sprite to know which bytes are
' shape vs background. That approach costs one sprite's worth of bytes
' total, regardless of how many colours cycle through it -- unlike
' this multi-frame version, which pays the LOADM ceiling tax again for
' every colour added.
'
' The LOADM ceiling itself, for reference: 6 frames of the *original*
' (narrower) art (23569 bytes) reliably fails with ?IO ERROR; 5 frames
' (21625 bytes) reliably works. Confirmed by direct bisection via a
' local XRoar build pinned to the same commit CI uses, full instruction
' trace to Disk Extended Color BASIC's own error-dispatch code
' ($D6FD-$D709) computing error #20 (IO ERROR) -- not an address-range
' problem, disproven directly (this program never gets near $8000).
' At this new wider scale, 3 frames (23547 bytes) still fails; 2 frames
' (20075 bytes) works, confirmed the same way.
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
