' ============================================================================
' sg12_border_illusion_test.bas  (v2 -- STRPTR-based, not hand-unrolled ASM)
'
' Same visual goal as the original version of this file: a coloured border
' hugging a line of text, something literally impossible in plain 32x16
' VDG text mode. This version fixes a real bug discovered while building
' the first one -- see hero-port/upstream-reports/
' ugbasic-peephole-autoincrement-bug.md for the full writeup.
'
' THE BUG (found the hard way): ugBASIC's peephole optimizer's dead-store
' elimination pass doesn't understand that ,X+ auto-increments the address
' on every store -- it silently comments out most repeated "STA ,X+"
' instructions in a row, thinking they're redundant writes to the same
' address. A hand-unrolled loop like:
'   LDA #$9F
'   STA ,X+
'   STA ,X+
'   STA ,X+   <- these get silently deleted
'   ...
' only actually writes 1 byte where N were intended, with no warning.
'
' THE FIX (suggested directly in conversation): store the byte pattern as
' an ordinary BASIC string, get its real memory address with STRPTR(),
' and copy it with a loop that ALTERNATES between LDA (read source) and
' STA (write dest) -- since there's only one STA per loop iteration in
' the actual source text, the peephole rule (which matches consecutive
' STORE,STORE pairs) never has anything to match against. Not a
' workaround via a flag (-p 0) -- the bug structurally cannot trigger
' with this pattern, confirmed via direct testing (grepped the generated
' .asm: zero peephole interference near the copy loop, and the resulting
' byte pattern renders correctly in XRoar).
'
' Important syntax note (also found the hard way): STRPTR() must be
' resolved into a plain BASIC variable *before* the ASM block -- calling
' STRPTR(x$) directly inside BEGIN ASM...END ASM fails, because ugBASIC
' passes inline assembly straight through to asm6809 without evaluating
' BASIC function calls inside it ("error: symbol 'STRPTR' not defined").
' Referencing an already-resolved BASIC variable by its underscore-
' prefixed name (_srcaddr) inside the ASM block is the correct pattern,
' matching how VARPTR is used in ugBASIC's own manual examples.
'
' A THIRD bug found while building this file: chaining more than ~15
' string concatenation ("+") operations in one expression silently
' corrupts something (confirmed via direct bisection: 15 chained CHR$()
' terms works, 16 breaks completely -- and it's specifically about
' *chained operation count*, not final string length, since a 20-char
' string built from only 3 concatenations of literal substrings works
' fine). The practical fix used below: since all bytes in a solid-colour
' row are identical anyway, there's no need for a long source string at
' all -- read a single byte repeatedly via LDA ,U (no auto-increment on
' the *source*) while only the destination (,X+) advances. This sidesteps
' the concatenation-length bug entirely rather than working around it.
' ============================================================================

PMODE 4, 1
CLS

' Solid yellow row (semigraphics byte $9F = %10011111: flag set, colour=
' yellow, all 4 quadrants on). Only ONE byte is needed as a source -- all
' 21 destination bytes are identical, so the source pointer is read
' repeatedly WITHOUT auto-increment (LDA ,U not LDA ,U+) while only the
' destination advances. This also sidesteps a second real bug found
' while building this test (see the note below) rather than needing a
' long source string at all.
yellowbyte$ = CHR$(159)
yellowaddr = STRPTR(yellowbyte$)

' Text flanked by thin colour stripes: $95 (black-left/yellow-right) then
' ordinary ASCII text (renders as real alphanumeric characters, not
' semigraphics -- bit 7 is clear on printable ASCII), then $9A
' (yellow-left/black-right). Only 2 concatenation operations here, well
' clear of the threshold below.
middata$ = CHR$(149) + "HIGH SCORE: 8675309" + CHR$(154)
midaddr = STRPTR(middata$)

BEGIN ASM
    LDX BITMAPADDRESS

    ; --- top border: 6 rows (confirmed empirically as the real repeat
    ; unit for this rendering -- see the file this replaces for the "why
    ; 6, not the datasheet's usual 12" investigation notes) ---
    LDY #6
topborder
    PSHS X,Y
    LDU _yellowaddr
    LDB #21
tbcopy1
    LDA ,U
    STA ,X+
    DECB
    BNE tbcopy1
    PULS X,Y
    LEAX 32,X
    LEAY -1,Y
    BNE topborder

    ; --- middle: text + side stripes, 6 rows ---
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

    ; --- bottom border: 6 rows, same source string reused ---
    LDY #6
botborder
    PSHS X,Y
    LDU _yellowaddr
    LDB #21
tbcopy2
    LDA ,U
    STA ,X+
    DECB
    BNE tbcopy2
    PULS X,Y
    LEAX 32,X
    LEAY -1,Y
    BNE botborder
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
