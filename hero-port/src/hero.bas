' ============================================================================
' HERO port -- title screen (first real piece of the actual port, not a
' test file)
'
' Ported from HERO-SRC.BAS lines 2810-2900 (see hero-port/HERO-SOURCE-
' ANALYSIS.md, section "title_page"). This is plain SCREEN 0 text mode --
' no PMODE4, no SG12, none of this project's graphics-hack machinery is
' needed for this particular screen at all.
'
' VERIFIED AGAINST THE REAL GAME: booted the actual, original HERO-11.DSK
' in XRoar earlier this project and screenshotted its real title screen
' for direct comparison. Text content, layout, two-box visual structure,
' and now the inverse-highlighted first letters (H/E/R/O) all match.
' ============================================================================

' Text positioning: rather than rely on ugBASIC's AT(col,row) print
' positioning -- which turned out to have confusing, not-fully-
' understood behaviour under direct empirical testing (a calibration
' test placing markers at known coordinates didn't land where the
' column/row model predicted) -- this writes each title line directly
' to TEXTADDRESS+offset, the exact same fully-verified pattern already
' used for the SG12 graphics buffer via BITMAPADDRESS. 32-column text
' rows: offset = row*32 + col.
SCREEN 0
CLS

title1$ = "H OVERJET"
title2$ = "E MERGENCY"
title3$ = "R ESCUE"
title4$ = "O PERATION"
t1len = LEN(title1$)
t2len = LEN(title2$)
t3len = LEN(title3$)
t4len = LEN(title4$)
t1addr = STRPTR(title1$)
t2addr = STRPTR(title2$)
t3addr = STRPTR(title3$)
t4addr = STRPTR(title4$)

BEGIN ASM
    LDX TEXTADDRESS
    LEAX 12,X

    LDU _t1addr
    LDB _t1len
tw1
    LDA ,U+
    STA ,X+
    DECB
    BNE tw1

    LDX TEXTADDRESS
    LEAX 44,X
    LDU _t2addr
    LDB _t2len
tw2
    LDA ,U+
    STA ,X+
    DECB
    BNE tw2

    LDX TEXTADDRESS
    LEAX 76,X
    LDU _t3addr
    LDB _t3len
tw3
    LDA ,U+
    STA ,X+
    DECB
    BNE tw3

    LDX TEXTADDRESS
    LEAX 108,X
    LDU _t4addr
    LDB _t4len
tw4
    LDA ,U+
    STA ,X+
    DECB
    BNE tw4
END ASM

PRINT
PRINT
PRINT
PRINT
PRINT

sepline$ = STRING(CHR(140), 32)
PRINT "  VERSION 1.1   SEPTEMBER 2024"
PRINT sepline$

' Highlight the first letter of each line (H/E/R/O), replicating the
' original's exact technique (line 2880: POKEB+1,PEEK(B+1)-64) rather
' than looking for a ugBASIC "inverse video" feature -- there isn't one
' to find, because there's no such thing at the ECB/6847 level either.
' The original 6847 VDG (what CoCo 1 and most CoCo 2 units actually
' have) has no software-controlled inverse video at all -- it was only
' ever a physical hardware pin modification. Every CoCo BASIC program
' achieving this "highlighted letter" look, this one included, does it
' by directly flipping a character byte into the alternate half of the
' character-code range (subtracting 64), which the VDG renders as
' light-on-dark instead of dark-on-light. TEXTADDRESS is the text-mode
' equivalent of BITMAPADDRESS, confirmed working via direct testing.
BEGIN ASM
    LDX TEXTADDRESS
    LDA 12,X
    SUBA #64
    STA 12,X
    LDA 44,X
    SUBA #64
    STA 44,X
    LDA 76,X
    SUBA #64
    STA 76,X
    LDA 108,X
    SUBA #64
    STA 108,X
END ASM

DO
LOOP
