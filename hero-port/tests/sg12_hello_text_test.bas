' ============================================================================
' sg12_hello_text_test.bas
'
' PURPOSE
' -------
' A second, independent validation of the SG12 hypothesis, suggested
' directly by conversation with the person testing this: rather than just
' drawing a rectangle and eyeballing whether the colours/shapes change,
' write recognisable ASCII text bytes into the framebuffer and see if
' actual legible letters render once the SG12 flip is applied.
'
' WHY REPEAT THE SAME BYTES ACROSS MULTIPLE ROWS
' -----------------------------------------------
' SG12 works by letting the VDG's character-generator ROM read *different*
' byte data on each of the repeated scanline passes it normally uses to
' build up one character's full height (see the CocoVGA documentation
' quoted earlier in this project: "the 6847 text and semigraphics mode
' attempts to read the same row of data 12 times per full text/semigraphics
' character row... it is possible to address different data in each row to
' produce SG8, SG12, SG24"). If we only write one row's worth of "HELLO!"
' bytes, each of those repeated scanline reads will see *different*
' underlying data (whatever happened to be at that memory offset), and the
' result will look like our first test's screenshot: recognisable
' character-glyph *fragments*, vertically sliced, not whole letters.
'
' To get one coherent, solid "HELLO!" rendered as real, whole letters, the
' *same* six ASCII bytes need to be written at the *same* column offset,
' repeated across however many physical scanline rows correspond to one
' logical SG12 character row. The exact repeat factor isn't something
' this project has pinned down precisely yet, so this writes the string
' redundantly across 16 rows (comfortably covering any plausible repeat
' count) rather than guessing a single specific number.
'
' HOW THE ADDRESS IS FOUND
' ------------------------
' BITMAPADDRESS is a real symbol ugbc.coco itself emits into the generated
' assembly (confirmed by grepping a compiled .asm file directly -- it's
' loaded via `LDX BITMAPADDRESS` throughout the compiler's own graphics
' primitive code), giving the runtime address of the current bitmap
' buffer. Using it directly in our inline assembly means this doesn't
' depend on guessing or hardcoding a specific literal address, which would
' be fragile across ugBASIC versions/memory configurations.
' ============================================================================

PMODE 4, 1
CLS

BEGIN ASM
    LDX BITMAPADDRESS
    LDB #16
hellorow
    PSHS X
    LDA #72
    STA ,X+
    LDA #69
    STA ,X+
    LDA #76
    STA ,X+
    LDA #76
    STA ,X+
    LDA #79
    STA ,X+
    LDA #33
    STA ,X+
    PULS X
    LEAX 32,X
    DECB
    BNE hellorow
END ASM

WAIT VBL

' --- THE SG12 HACK, same as sg12_hypothesis_test.bas -- see that file for
' the full explanation of why POKE is replaced with inline assembly here.
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
