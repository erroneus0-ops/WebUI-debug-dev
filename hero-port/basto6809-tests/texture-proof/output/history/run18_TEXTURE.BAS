' TEXTURE.BAS -- hand-authored per-row quadrant texture, bypassing
' PNGtoCCSB entirely, to test whether SG12's real per-row detail
' (confirmed present in HERO's own screen memory) is reachable when
' writing bytes directly rather than through the tool's aspect-
' corrected import pipeline (which duplicates one source row into 4
' identical memory rows, confirmed unable to produce this).
'
' Bit mapping confirmed from mc6847.c (via this project's own VDG
' simulator): bit3=topLeft, bit2=topRight, bit1=botLeft, bit0=botRight.
' Alternating two diagonal patterns row-by-row for a herringbone/brick
' weave, colour 4 (red, matching HERO's own brick pillar):
'   $C9 = semigraphics(1) | colour4(0100) | topLeft+botRight (1001)
'   $C6 = semigraphics(1) | colour4(0100) | topRight+botLeft (0110)
GMODE 7,1
GMODE 7,0
GCLS 0
SCREEN 1,0
GCOPY 0,1
' ADDASSEM:
        LDX   #$0E00+15      ; screen base + column 15
        LDU   #20            ; 20 rows of texture
        LDA   #$C9
TexLoop:
        STA   ,X
        LEAX  32,X            ; next screen row
        EORA  #$0F            ; flip the pattern bits: $C9<->$C6
        LEAU  -1,U
        CMPU  #0
        BNE   TexLoop
' ENDASSEM:
KeyLoop:
A$ = INKEY$
IF A$ <> "" THEN END
GOTO KeyLoop
