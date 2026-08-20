' ============================================================================
' sg12_border_illusion_test.bas  (v3 -- thin borders, matching corners)
'
' Goal: a coloured border hugging a line of text -- something literally
' impossible in plain 32x16 VDG text mode, since real text mode has
' exactly one byte per character cell and no way to give a cell a partial
' colour fringe. Built entirely on real, verified hardware/software
' behaviour, not guesswork -- see the git history of this file and
' hero-port/upstream-reports/ for the investigation that got here,
' including three separate real ugBASIC bugs found and worked around
' along the way.
'
' THE SEMIGRAPHICS BYTE FORMAT (verified against a real, cycle-accurate
' MC6847 emulator implementation -- github.com/floooh/chips,
' chips/mc6847.h, _mc6847_decode_scanline()):
'   bit 7    = 1 for a semigraphics character (0 = ordinary ASCII/alnum)
'   bits 6-4 = colour: 0=green 1=yellow 2=blue 3=red 4=buff 5=cyan
'              6=magenta 7=orange
'   bits 3-0 = four quadrants, each independently "coloured" (1) or
'              black (0): bit3=top-left bit2=top-right bit1=bottom-left
'              bit0=bottom-right
'   solid yellow block          (all 4 quadrants on)   = $9F
'   black-left / yellow-right   (bits 3,1 off; 2,0 on) = $95
'   yellow-left / black-right   (bits 3,1 on; 2,0 off) = $9A
'
' "MOD GROUP" (person's term, and a good one): confirmed empirically that
' 6 identical rows of screen memory render as one complete, solid visual
' line under this SG12 configuration -- not the MC6847 datasheet's usual
' "12 scanlines per character cell" figure. A 12-row block gave a clean
' but genuinely doubled result; 6 gave one clean line. Row alignment
' matters: every block's start row needs to be a multiple of 6, or the
' next block inherits a bad phase.
'
' TWO REFINEMENTS IN THIS VERSION, both suggested directly in
' conversation and both confirmed working on the first real try:
'
' 1. PARTIAL MOD-GROUP ILLUMINATION. Earlier versions lit the *entire*
'    6-row group solid yellow for the top/bottom borders, making them
'    look like thick bars rather than thin lines. Since each border sits
'    right next to the text block, only the rows of its group nearest
'    the text actually need to be lit -- the top border lights its
'    *last* 3 rows (closest to the text below it), the bottom border
'    lights its *first* 3 rows (closest to the text above it). The other
'    3 rows in each group are left completely untouched, so they show
'    whatever's already there (the CLS background) rather than being
'    explicitly blanked -- confirmed this blends seamlessly, no visible
'    seam between the border and the surrounding background.
'
' 2. MATCHING CORNER BYTES. The middle text row's left/right edges use
'    half-coloured stripe bytes ($95, $9A), not solid blocks -- so a
'    solid $9F block at the same columns in the top/bottom border rows
'    looked visually inconsistent with the thin stripe descending from
'    it (a "fat corner meeting a thin edge" mismatch). Fixed by using
'    the *same* $95/$9A bytes as the first/last byte of every top/bottom
'    row too, with solid $9F only in the columns between them -- this
'    makes the whole frame read as one continuous, deliberate shape.
'
' THE STRPTR()-BASED COPY MECHANISM (see git history / upstream-reports
' for the two bugs this works around): store byte patterns as ordinary
' BASIC strings, get their address with STRPTR(), and copy with a loop
' alternating LDA (read) / STA (write) so there's never more than one
' STA per loop iteration in the source text -- immune to the peephole
' optimizer's auto-increment bug. For the solid-fill portions, a single
' byte is read repeatedly via LDA ,U (no auto-increment on the *source*)
' while only the destination (,X+) advances -- sidesteps a second bug
' (string concatenation chains longer than ~15 operations silently
' corrupt the result) by never needing a long source string at all.
' ============================================================================

PMODE 4, 1
CLS

' Corner/stripe bytes, matching the ones used in the text row below.
leftstripe$ = CHR$(149)
fillbyte$ = CHR$(159)
rightstripe$ = CHR$(154)
leftaddr = STRPTR(leftstripe$)
filladdr = STRPTR(fillbyte$)
rightaddr = STRPTR(rightstripe$)

' Text flanked by thin colour stripes. Ordinary ASCII text renders as
' real alphanumeric characters (bit 7 clear), not semigraphics. Only 2
' concatenation operations here, well clear of the chain-length bug.
middata$ = CHR$(149) + "HIGH SCORE: 8675309" + CHR$(154)
midaddr = STRPTR(middata$)

BEGIN ASM
    LDX BITMAPADDRESS

    ; --- top border: skip the first 3 rows of this 6-row group (left as
    ; background), then light the last 3 with matching corner bytes ---
    LEAX 96,X
    LDY #3
topborder
    PSHS X,Y
    LDU _leftaddr
    LDA ,U
    STA ,X+
    LDU _filladdr
    LDB #19
tbfill1
    LDA ,U
    STA ,X+
    DECB
    BNE tbfill1
    LDU _rightaddr
    LDA ,U
    STA ,X+
    PULS X,Y
    LEAX 32,X
    LEAY -1,Y
    BNE topborder

    ; --- middle: text + side stripes, full 6-row group (text needs the
    ; whole group to render as legible characters, unlike a solid fill) ---
    LDY #6
midrow
    PSHS X,Y
    LDU _midaddr
    LDB #21
midcopy
    LDA ,U+
    STA ,X+
    DECB
    BNE midcopy
    PULS X,Y
    LEAX 32,X
    LEAY -1,Y
    BNE midrow

    ; --- bottom border: light the first 3 rows, then skip the remaining
    ; 3 (left as background) ---
    LDY #3
botborder
    PSHS X,Y
    LDU _leftaddr
    LDA ,U
    STA ,X+
    LDU _filladdr
    LDB #19
tbfill2
    LDA ,U
    STA ,X+
    DECB
    BNE tbfill2
    LDU _rightaddr
    LDA ,U
    STA ,X+
    PULS X,Y
    LEAX 32,X
    LEAY -1,Y
    BNE botborder
    LEAX 96,X
END ASM

WAIT VBL

' --- THE SG12 HACK -- see sg12_hypothesis_test.bas for the full
' explanation of why POKE is replaced with inline assembly here too.
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

DO
LOOP
