' ============================================================================
' sg12_hypothesis_test.bas
'
' PURPOSE
' -------
' This is NOT part of the HERO port itself. It is a standalone test to
' validate a specific technical hypothesis before committing to the full
' port:
'
'   Claim: ugBASIC's PMODE 4 (real coco C source: targets/coco/pmode.c maps
'   this to BITMAP_MODE_RESOLUTION6, 256x192, 2 colours -- matching real
'   CoCo PMODE4 exactly, monochrome) uses the *real* Motorola 6847 byte
'   layout for that resolution, because it has to render correctly on
'   real/emulated 6847 hardware. If true, we should be able to reproduce
'   Nick Marentes' original SG12 trick by hand -- draw normally in PMODE 4,
'   then POKE the same PIA/SAM registers he used, and the *same bytes*
'   should be reinterpreted by the VDG as 8-colour SG12, with no corruption.
'
' NOTE ON SYNTAX (v2 of this file): the first version of this test used
' DECB/Dragon-style graphics syntax (BOX (x,y)-(x2,y2),colour,BF and a
' two-argument SCREEN mode,colorset) copied from habit rather than checked
' against ugBASIC's own grammar. That failed to compile ("syntax error,
' unexpected comma") on the very first line (SCREEN 1,0) -- confirmed via
' real CI run 32381711618. Checked properly this time:
'   - SCREEN on this target takes exactly ONE argument (coco/screen_mode.c:
'     "void screen_mode(Environment*, int _mode)") -- no colorset param,
'     so it's dropped entirely below; PMODE's own C source
'     (coco/pmode.c) calls c6847_screen_mode_enable() internally, so PMODE
'     alone both selects *and* displays the mode.
'   - BOX syntax (per ugbasic.iwashere.eu/manual/graphics) is
'     "BOX x1,y1 TO x2,y2" -- outline only, no confirmed fill-suffix syntax,
'     so a filled rectangle is built here from LINE calls instead (syntax
'     confirmed from the real "3D ROTATING CUBE" example:
'     ugbasic.iwashere.eu/example/contrib_cube -- "LINE x1,y1 TO x2,y2,WHITE").
'   - WAIT VBL (bare, no argument) confirmed from the same cube example.
'
' Original technique (from HERO-SRC.BAS, v1.1, line 230):
'   SCREEN1,0:POKE&HFF9C,9:POKE&HFF22,0:POKE&HFFC5,1:POKE&HFFC2,1:POKE&HFFC0,1
'
' Register meanings:
'   $FF22 bit 7 (nA_G)   = 0   -> VDG stays in a semigraphics mode
'   $FF9C                = 9   -> VDG mode register value used by Nick's hack
'   $FFC0/$FFC2/$FFC5    = 1   -> SAM V-mode bits driven to binary 100 = SG12
' ============================================================================

PMODE 4, 1
CLS
INK 1

' Fill a rectangle by drawing solid horizontal lines -- avoids relying on
' unconfirmed BOX fill syntax. PMODE 4 is 2-colour (monochrome), so plain
' numeric ink index 1 is used rather than a named colour constant.
FOR y = 40 TO 100
    LINE 40, y TO 100, y, 1
NEXT

' Give a human or a CI screenshot step something to look at pre-flip.
WAIT VBL

' --- THE HACK, replicated by hand ---------------------------------------
' If ugbc's PMODE 4 buffer is byte-for-byte real 6847 layout, this should
' recolour the box (into SG12's 8-colour palette) without corrupting its
' shape. If not, expect visual noise/garbage in the same screen region.
'
' NOTE ON THIS BLOCK (v3): POKE is broken for the coco target in this
' ugBASIC release (1.18.1) -- confirmed via minimal repro: even a single
' bare `POKE 4096, 9` as the entire program fails to compile (silent
' internal failure, only a spurious "WARNING W001 - Multiplication could
' loose precision" printed, no real error, zero output). Verified locally
' across several isolation steps, not guessed. Filed upstream; in the
' meantime, using inline 6809 assembly instead of POKE sidesteps whatever
' BASIC-level code-generation path is broken, since assembly text is
' passed straight through to asm6809 untouched (per ugBASIC's own manual:
' "the assembly language is not interpreted by the compiler but passed
' 'as is' to the assembler"). Real 6809/asm6809 syntax: $ for hex, # for
' immediate -- not BASIC's &H.
BEGIN ASM
    LDA #9
    STA $FF9C
    CLRA
    STA $FF22
    LDA #1
    STA $FFC5
    STA $FFC2
    STA $FFC0
END ASM

WAIT VBL

' Park here so a CI step has a stable frame to screenshot.
DO
LOOP
