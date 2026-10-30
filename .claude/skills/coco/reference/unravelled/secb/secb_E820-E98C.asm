; Super Extended Color BASIC 2.0 (CoCo 3) -- $E820-$E98C
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: G2BITBIX=$E820, G4BITPIX=$E83F, HPOINT=$E85C, HLINE=$E882

E820  34 44             G2BITBIX PSHS  U,B                 ; SAVE REGISTERS
E822  D6 B9                      LDB   HORBYT              ; GET THE NUMBER OF BYTES/ROW
E824  96 C0                      LDA   VERBEG+1            ; GET THE VERTICAL COORDINATE
E826  3D                         MUL                       ; NOW ACCD CONTAINS THE ROW OFFSET IN BYTES FROM THE TOP OF SCREEN
E827  C3 20 00                   ADDD  #HRESSCRN           ; ADD THE ROW OFFSET TO THE START OF THE SCREEN
E82A  1F 01                      TFR   D,X                 ; X CONTAINS THE ADDRESS OF THE START OF THE ROW CONTAINING A PIXEL
E82C  DC BD                      LDD   HORBEG              ; GET THE HORIZONTAL COORDINATE
E82E  44                         LSRA
E82F  56                         RORB
E830  44                         LSRA                      ; * DIVIDE HORIZONTAL COORDINATE BY FOUR - THERE ARE 4 PIXELS PER BYTE
E831  56                         RORB                      ; * ACCD CONTAINS THE COLUMN OFFSET TO THE PIXEL IN BYTES
E832  30 8B                      LEAX  D,X                 ; ADD THE COLUMN OFFSET - X POINTS TO THE BYTE CONTAINING THE PIXEL
E834  96 BE                      LDA   HORBEG+1            ; GET THE LEAST SIGNIFICANT BYTE OF THE HORIZONTAL COORDINATE
E836  84 03                      ANDA  #$03                ; KEEP BITS 0,1 WHICH ARE THE PIXEL POSITION IN THE BYTE
E838  CE E7 F9                   LDU   #PIX2MASK           ; POINT TO THE TABLE OF FOUR COLOR PIXEL MASKS
E83B  A6 C6                      LDA   A,U                 ; GET THE CORRECT PIXEL MASK
E83D  35 C4                      PULS  B,U,PC              ; RESTORE THE REGISTERS

E83F  34 44             G4BITPIX PSHS  U,B                 ; SAVE REGISTERS
E841  D6 B9                      LDB   HORBYT              ; GET THE NUMBER OF BYTES/ROW
E843  96 C0                      LDA   VERBEG+1            ; GET THE VERTICAL COORDINATE
E845  3D                         MUL                       ; NOW ACCD CONTAINS THE ROW OFFSET IN BYTES FROM THE TOP OF SCREEN
E846  C3 20 00                   ADDD  #HRESSCRN           ; ADD THE ROW OFFSET TO THE START OF THE SCREEN
E849  1F 01                      TFR   D,X                 ; X CONTAINS THE ADDRESS OF THE START OF THE ROW CONTAINING A PIXEL
E84B  DC BD                      LDD   HORBEG              ; GET THE HORIZONTAL COORDINATE
E84D  44                         LSRA                      ; * DIVIDE HORIZONTAL COORDINATE BY TWO - THERE ARE 2 PIXELS PER BYTE
E84E  56                         RORB                      ; * ACCD CONTAINS THE COLUMN OFFSET TO THE PIXEL IN BYTES
E84F  30 8B                      LEAX  D,X                 ; ADD THE COLUMN OFFSET - X POINTS TO THE BYTE CONTAINING THE PIXEL
E851  96 BE                      LDA   HORBEG+1            ; GET THE LEAST SIGNIFICANT BYTE OF THE HORIZONTAL COORDINATE
E853  84 01                      ANDA  #$01                ; KEEP BITS 0 WHICH IS THE PIXEL POSITION IN THE BYTE
E855  CE E7 FD                   LDU   #PIX4MASK           ; POINT TO THE TABLE OF 16 COLOR PIXEL MASKS
E858  A6 C6                      LDA   A,U                 ; GET THE CORRECT PIXEL MASK
E85A  35 C4                      PULS  B,U,PC              ; RESTORE THE REGISTERS

* HPOINT
E85C  0D E6             HPOINT   TST   HRMODE              ; CHECK FOR HI-RES GRAPHICS MODE
E85E  10 27 FE 8D                LBEQ  LE6EF               ; 'HR' ERROR IF NOT GRAPHICS
E862  BD B2 6A                   JSR   LB26A               ; SYNTAX CHECK FOR '('
E865  BD E7 AA                   JSR   LE7AA               ; EVALUATE TWO EXPRESSIONS (X,Y COORDS)
E868  BD B2 67                   JSR   LB267               ; SYNTAX CHECK FOR ')'
E86B  BD E1 19                   JSR   SELTASK1            ; SELECT TASK REGSTER 1
E86E  BD E7 DA                   JSR   HCALPOS             ; POINT X TO PIXEL, ACCA CONTAINS MASK
E871  1F 89                      TFR   A,B                 ; PUT MASK IN ACCB
E873  E4 84                      ANDB  ,X                  ; MASK OFF ALL BUT DESIRED PIXEL
E875  44                LE875    LSRA                      ; SHIFT MASK TO THE RIGHT
E876  25 03                      BCS   LE87B               ; STOP SHIFTING IF DATA IS RIGHT JUSTIFIED
E878  54                         LSRB                      ; SHIFT PIXEL TO THE RIGHT
E879  20 FA                      BRA   LE875               ; KEEP SHIFTING UNTIL DATA IS RIGHT JUSTIFIED
E87B  BD B4 F3          LE87B    JSR   LB4F3               ; CONVERT ACCB INTO A FLOATING POINT NUMBER
E87E  BD E0 FF                   JSR   SELTASK0            ; SELECT TASK REGISTER 0
E881  39                         RTS

* HLINE
E882  0D E6             HLINE    TST   HRMODE              ; CHECK HI-RES GRAPHICS MODE
E884  10 27 FE 67                LBEQ  LE6EF               ; 'HR' ERROR IF NOT GRAPHICS
E888  10 21 17 74                LBRN  RAMLINK             ; RAM HOOK
E88C  81 28                      CMPA  #'('                ; CHECK FOR '('
E88E  27 09                      BEQ   LE899               ; GO LOOK FOR START AND END POINTS
E890  81 AC                      CMPA  #$AC                ; CHECK FOR MINUS SIGN TOKEN
E892  27 05                      BEQ   LE899               ; BRANCH IF NO STARTING POINTS GIVEN
E894  C6 40                      LDB   #'@'                ; CHECK FOR '@' SIGN
E896  BD B2 6F                   JSR   LB26F               ; GO DO A SYNTAX CHECK
E899  BD E9 E1          LE899    JSR   LE9E1               ; GET STARTING AND ENDING COORDINATES
E89C  9E C3                      LDX   HOREND              ; GET ENDING HORIZONTAL COORDINATE
E89E  9F C7                      STX   HORDEF              ; PUT IN LAST USED HORIZONTAL END POINT
E8A0  9E C5                      LDX   VEREND              ; GET ENDING VERTICAL COORDINATE
E8A2  9F C9                      STX   VERDEF              ; PUT IN LAST USED VERTICAL END POINT
E8A4  BD B2 6D                   JSR   SYNCOMMA            ; DO A SYNTAX CHECK FOR A COMMA
E8A7  81 BE                      CMPA  #$BE                ; PRESET TOKEN?
E8A9  27 09                      BEQ   LE8B4               ; BRANCK IF YES
E8AB  81 BD                      CMPA  #$BD                ; PSET TOKEN?
E8AD  10 26 C9 C6                LBNE  LB277               ; 'SYNTAX' ERROR IF NOT PSET OR PRESET
E8B1  C6 01                      LDB   #$01                ; PSET FLAG
E8B3  86                LE8B3    FCB   SKP1LD              ; OP CODE FOR LDA #; EFFECTIVELY SKIP NEXT INSTRUCTION
E8B4  5F                LE8B4    CLRB                      ; PRESET FLAG
E8B5  34 04                      PSHS  B                   ; SAVE PSET/PRESET FLAG
E8B7  9D 9F                      JSR   GETNCH              ; GET NEXT CHARACTER FROM BASIC'S INPUT LINE
E8B9  BD EA 0D                   JSR   LEA0D               ; NORMALIZE START/END COORDS
E8BC  35 04                      PULS  B                   ; GET PSET/PRESET FLAG
E8BE  D7 C2                      STB   SETFLG              ; SAVE IT
E8C0  BD E7 31                   JSR   LE731               ; SET ACTIVE COLOR BYTE
E8C3  9D A5                      JSR   GETCCH              ; GET BASIC'S CURRENT INPUT CHARACTER
E8C5  10 27 00 85                LBEQ  LE94E               ; BRANCH IF NO BOX TO BE DRAWN
E8C9  BD B2 6D                   JSR   SYNCOMMA            ; DO A SYNTAX CHECK FOR A COMMA
E8CC  C6 42                      LDB   #'B'                ; DRAW A BOX?
E8CE  BD B2 6F                   JSR   LB26F               ; GO DO A SYNTAX CHECK FOR A 'B'
E8D1  26 18                      BNE   LE8EB               ; FOUND A 'B' AND SOMETHING FOLLOWS
E8D3  8D 31                      BSR   LE906               ; DRAW A HORIZONTAL LINE
E8D5  8D 5A                      BSR   LE931               ; DRAW A VERTICAL LINE
E8D7  9E BD                      LDX   HORBEG              ; GET HORIZONTAL START COORD
E8D9  34 10                      PSHS  X                   ; SAVE IT ON THE STACK
E8DB  9E C3                      LDX   HOREND              ; GET HORIZONTAL END COORDINATE
E8DD  9F BD                      STX   HORBEG              ; PUT IN HORIZONTAL START COORDINATE
E8DF  8D 50                      BSR   LE931               ; DRAW A VERTICAL LINE
E8E1  35 10                      PULS  X                   ; GET THE PREVIOUS HORIZONTAL START COORDINATE
E8E3  9F BD                      STX   HORBEG              ; RESTORE IT
E8E5  9E C5                      LDX   VEREND              ; GET VERTICAL END COORDINATE
E8E7  9F BF                      STX   VERBEG              ; PUT INTO START COORD
E8E9  20 1B                      BRA   LE906               ; DRAW A HORIZONTAL LINE
E8EB  C6 46             LE8EB    LDB   #'F'                ; CHECK FOR FILL OPTION
E8ED  BD B2 6F                   JSR   LB26F               ; GO DO A SYNTAX CHECK FOR AN 'F'
E8F0  20 04                      BRA   LE8F6               ; GO 'FILL' THE BOX
E8F2  30 1F             LE8F2    LEAX  $-01,X              ; MOVE VERTICAL COORD UP ONE
E8F4  9F BF             LE8F4    STX   VERBEG              ; SAVE THE NEW VERTICAL START COORDINATE
* DRAW A SERIES OF HORIZONTAL LINES FROM VERTICAL START TO VERTICAL END
E8F6  BD E9 06          LE8F6    JSR   LE906               ; DRAW A HORIZONTAL LINE
E8F9  9E BF                      LDX   VERBEG              ; GET START VERTICAL COORD
E8FB  9C C5                      CMPX  VEREND              ; COMPARE TO END VERTICAL COORD
E8FD  27 06                      BEQ   LE905               ; RETURN IF EQUAL
E8FF  24 F1                      BCC   LE8F2               ; BRANCH IF START HORIZONTAL > END HORIZONTAL
E901  30 01                      LEAX  $01,X               ; MOVE HORIZONTAL COORD DOWN ONE
E903  20 EF                      BRA   LE8F4               ; KEEP DRAWING LINES
E905  39                LE905    RTS
* DRAW A HORIZONTAL LINE FROM HOREND TO HORBEG AT VERTICAL COORD VERBEG; COLOR IN ALLCOL
E906  9E BD             LE906    LDX   HORBEG              ; GET STARTING COORDINATES
E908  34 10                      PSHS  X                   ; SAVE 'EM
E90A  BD E9 DB                   JSR   LE9DB               ; GET ABSOLUTE VALUE OF HOREND-HORBEG (HORIZONTAL COORD)
E90D  24 04                      BCC   LE913               ; BRANCH IF END > START
E90F  9E C3                      LDX   HOREND              ; GET END COORD
E911  9F BD                      STX   HORBEG              ; MAKE IT THE START COORD
E913  1F 02             LE913    TFR   D,Y                 ; SAVE DIFFERENCE IN Y
E915  31 21                      LEAY  $01,Y               ; ADD ONE TO DIFFERENCE - TURN ON STARTING AND ENDING COORDS
E917  BD E7 DA                   JSR   HCALPOS             ; GET ABSOLUTE SCREEN ADDRESS IN X AND PIXEL MASK IN ACCA
E91A  35 40                      PULS  U                   ; GET START COORDS
E91C  DF BD                      STU   HORBEG              ; RESTORE THEM
E91E  17 00 F5                   LBSR  LEA16               ; POINT U TO ROUTINE TO MOVE PIXEL POINTERS TO RIGHT
E921  97 D7             LE921    STA   VD7                 ; SAVEL PIXEL MASK
E923  BD E7 88                   JSR   LE788               ; TURN ON PIXEL
E926  96 D7                      LDA   VD7                 ; GET OLD PIXEL MASK
E928  AD C4                      JSR   ,U                  ; MOVE TO NEXT ONE TO RIGHT
E92A  31 3F                      LEAY  $-01,Y              ; DEC COUNTER
E92C  26 F3                      BNE   LE921               ; LOOP IF NOT DONE
E92E  39                         RTS
E92F  35 06             LE92F    PULS  A,B                 ; CLEAN UP STACK
* DRAW A VERTICAL LINE FROM VEREND TO VERBEG AT HORIZONTAL COORD HORBEG
E931  DC BF             LE931    LDD   VERBEG              ; GET END VERTICAL COORDS
E933  34 06                      PSHS  B,A                 ; SAVE 'EM
E935  BD E9 CD                   JSR   LE9CD               ; CALCULATE ABSOLUTE VALUE OF VEREND-VERBEG
E938  24 04                      BCC   LE93E               ; BRANCH IF END COORD > START COORD
E93A  9E C5                      LDX   VEREND              ; GET VERTICAL END COORDINATE
E93C  9F BF                      STX   VERBEG              ; MAKE IT THE START COORD IF END COORD WAS RIGHT OF START
E93E  1F 02             LE93E    TFR   D,Y                 ; LENGTH OF LINE TO Y
E940  31 21                      LEAY  $01,Y               ; SET BOTH START AND END COORDS
E942  BD E7 DA                   JSR   HCALPOS             ; GET ABSOLUTE SCREEN ADDRESS IN X AND PIXEL MASK IN ACCA
E945  35 40                      PULS  U                   ; GET END COORDS
E947  DF BF                      STU   VERBEG              ; RESTORE THEM
E949  17 00 D5                   LBSR  LEA21               ; POINT U TO ROUTINE TO MOVE DOWN ONE ROW
E94C  20 D3                      BRA   LE921               ; DRAW A VERTICAL LINE

* DRAW A LINE FROM (HORBEG, VERBEG) TO (HOREND, VEREND)
E94E  10 8E E9 B8       LE94E    LDY   #LE9B8              ; POINT Y TO INCREMENT VERBEG (VERTICAL START COORD)
E952  BD E9 CD                   JSR   LE9CD               ; CALCULATE VERTICAL DIFFERENCE (VEREND-VERBEG)
E955  27 AF                      BEQ   LE906               ; DRAW A HORIZONTAL LINE IF DELTA V=0
E957  24 04                      BCC   LE95D               ; BRANCH IF VERTICAL END COORD > VERTICAL START COORD
E959  10 8E E9 C6                LDY   #LE9C6              ; POINT Y TO DECR VERTICAL COORD
E95D  34 06             LE95D    PSHS  B,A                 ; SAVE DELTA V
E95F  CE E9 B1                   LDU   #LE9B1              ; POINT U TO INCR HORIZONTAL COORD
E962  BD E9 DB                   JSR   LE9DB               ; CALCULATE HORIZONTAL DIFFERENCE (HOREND-HORBEG)
E965  27 C8                      BEQ   LE92F               ; DRAW A VERTICAL LINE IF DELTA H=0
E967  24 03                      BCC   LE96C               ; BRANCH IF HORIZONTAL END COORD > HORIZONTAL START COORD
E969  CE E9 BF                   LDU   #LE9BF              ; POINT U TO DECR HORIZONTAL COORD
E96C  10 A3 E4          LE96C    CMPD  ,S                  ; COMPARE DELTA H TO DELTA V
E96F  35 10                      PULS  X                   ; PUT DELTA V IN X
E971  24 04                      BCC   LE977               ; BRANCH IF DELTA H > DELTA V
E973  1E 32                      EXG   U,Y                 ; SWAP CHANGE HORIZONTAL AND CHANGE VERTICAL ADDRESS
E975  1E 01                      EXG   D,X                 ; EXCHANGE DELTA HORIZONTAL AND DELTA VERTICAL
E977  34 46             LE977    PSHS  U,B,A               ; SAVE THE LARGER OF DELTA V, DELTA H AND INCR/DECR ADDRESS
E979  34 06                      PSHS  B,A                 ; SAVE THE LARGER OF DELTA V, DELTA H
E97B  44                         LSRA
E97C  56                         RORB                      ; DIVIDE BY 2, SHIFT ACCD RIGHT ONE BIT
E97D  25 09                      BCS   LE988               ; BRANCH IF ODD NUMBER
E97F  11 83 E9 B9                CMPU  #LE9B9              ; SEE IF INCR OR DECR
E983  25 03                      BCS   LE988               ; BRANCH IF INCR
E985  83 00 01                   SUBD  #1                  ; SUBTRACT ONE IF DECR
E988  34 16             LE988    PSHS  X,B,A               ; SAVE SMALLEST DELTA (X) AND INITIAL MINOR COORDINATE
* INCREMENT COUNTER WHICH IS 1/2 OF LARGEST DELTA
E98A  BD E7 E6                   JSR   LE7E6               ; POINT U TO PROPER COORDINATE TO SCREEN CONVERSION ROUTINE
