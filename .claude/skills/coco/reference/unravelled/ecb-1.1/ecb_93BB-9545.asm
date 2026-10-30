; Extended Color BASIC 1.1 -- $93BB-$9545
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: LINE=$93BB, PCLS=$9532

* LINE
93BB  81 89             LINE     CMPA  #$89                ; 'INPUT' TOKEN
93BD  10 27 F5 FF                LBEQ  L89C0               ; GO DO 'LINE INPUT' COMMAND
93C1  81 28                      CMPA  #'('                ; CHECK FOR '('
93C3  27 09                      BEQ   L93CE               ; GO LOOK FOR START AND END POINTS
93C5  81 AC                      CMPA  #$AC                ; CHECK TOKEN FOR MINUS SIGN
93C7  27 05                      BEQ   L93CE               ; GO GET START AND END POINTS
93C9  C6 40                      LDB   #'@'                ; CHECK FOR @ SIGN
93CB  BD B2 6F                   JSR   LB26F               ; DO A SYNTAX CHECK
93CE  BD 93 8F          L93CE    JSR   >L938F              ; GET STARTING AND ENDING COORDINATES
93D1  9E C3                      LDX   HOREND              ; GET ENDING HORIZ COORDINATE
93D3  9F C7                      STX   HORDEF              ; PUT IN LAST USED HOR END POINT
93D5  9E C5                      LDX   VEREND              ; GET ENDING VER COORD
93D7  9F C9                      STX   VERDEF              ; PUT IN LAST USED VER END POINT
93D9  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
93DC  81 BE                      CMPA  #$BE                ; PRESET TOKEN?
93DE  27 09                      BEQ   L93E9               ; YES
93E0  81 BD                      CMPA  #$BD                ; PSET TOKEN?
93E2  10 26 1E 91                LBNE  LB277               ; 'SYNTAX ERROR' IF NOT PSET OR PRESET
93E6  C6 01                      LDB   #$01                ; PSET FLAG
93E8  86                L93E8    FCB   SKP1LD              ; SKIP ONE BYTE, LOAD ACCA WITH $5F
93E9  5F                L93E9    CLRB                      ; PRESET FLAG
93EA  34 04                      PSHS  B                   ; SAVE PSET/PRESET FLAG
93EC  9D 9F                      JSR   GETNCH              ; GET ANOTHER CHAR
93EE  BD 94 20                   JSR   >L9420              ; NORMALIZE START/END COORDS
93F1  35 04                      PULS  B                   ; GET PSET/PRESET FLAG
93F3  D7 C2                      STB   SETFLG              ; SAVE IT
93F5  BD 95 9A                   JSR   L959A               ; SET ACTIVE COLOR BYTE
93F8  9D A5                      JSR   GETCCH              ; GET ANOTHER CHARACTER
93FA  10 27 00 A3                LBEQ  L94A1               ; BRANCH IF NO BOX TO BE DRAWN
93FE  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
9401  C6 42                      LDB   #'B'                ; 'BOX'?
9403  BD B2 6F                   JSR   LB26F               ; GO DO A SYNTAX CHECK FOR A 'B'
9406  26 21                      BNE   L9429               ; FOUND A 'B' AND SOMETHING FOLLOWS
9408  8D 3A                      BSR   L9444               ; DRAW A HORIZ LINE
940A  8D 62                      BSR   L946E               ; DRAW A VERTICAL LINE
940C  9E BD                      LDX   HORBEG              ; GET HOR START COORD
940E  34 10                      PSHS  X                   ; SAVE IT ON STACK
9410  9E C3                      LDX   HOREND              ; * GET HORIZONTAL END COORDINATE AND
9412  9F BD                      STX   HORBEG              ; * PUT THEM IN HORIZONTAL START COORDINATE
9414  8D 58                      BSR   L946E               ; DRAW VERTICAL LINE
9416  35 10                      PULS  X                   ; GET THE PREVIOUS HORIZONTAL START COORDINATE
9418  9F BD                      STX   HORBEG              ; RESTORE IT
941A  9E C5                      LDX   VEREND              ; GET VER END COORD
941C  9F BF                      STX   VERBEG              ; PUT INTO START
941E  20 24                      BRA   L9444               ; DRAW HORIZ LINE
* NORMALIZE START COORDS IN (HORBEG,VERBEG) & END COORDS IN (HOREND,VEREND)
9420  BD 93 1D          L9420    JSR   L931D               ; NORMALIZE COORDS IN (HORBEG,VERBEG)
9423  CE 00 C3                   LDU   #HOREND             ; =
9426  7E 93 20                   JMP   L9320               ; = NORMALIZE COORDS IN (HOREND,VEREND)
9429  C6 46             L9429    LDB   #'F'                ; *
942B  BD B2 6F                   JSR   LB26F               ; *GO DO A SYNTAX CHECK FOR AN 'F'
942E  20 04                      BRA   L9434               ; 'FILL' THE BOX
9430  30 1F             L9430    LEAX  $-01,X              ; MOVE VER COORD UP ONE
9432  9F BF             L9432    STX   VERBEG              ; SAVE NEW VERTICAL START COORDINATE

* DRAW A SERIES OF HORIZONTAL LINES FROM VER START TO VER END
9434  BD 94 44          L9434    JSR   >L9444              ; DRAW A HORIZ LINE
9437  9E BF                      LDX   VERBEG              ; GET START VER COORD
9439  9C C5                      CMPX  VEREND              ; COMPARE TO END VER COORD
943B  27 06                      BEQ   L9443               ; RETURN IF EQUAL
943D  24 F1                      BCC   L9430               ; BRANCH IF START HOR > END HOR
943F  30 01                      LEAX  $01,X               ; MOVE HOR COORD DOWN ONE
9441  20 EF                      BRA   L9432               ; KEEP DRAWING LINES
9443  39                L9443    RTS                       ; WASTED BYTE - SHOULD USE L946B INSTEAD
* DRAW A HORIZONTAL LINE FROM HOREND TO HORBEG
* AT VER COORD VERBEG; COLOR IN ALLCOL
9444  9E BD             L9444    LDX   HORBEG              ; GET STARTING COORDS
9446  34 10                      PSHS  X                   ; SAVE 'EM
9448  BD 97 1D                   JSR   L971D               ; GET ABSOLUTE VALUE OF HOREND - HORBEG (HORIZONTAL COORDINATE)
944B  24 04                      BCC   L9451               ; BRANCH IF END > START
944D  9E C3                      LDX   HOREND              ; * TRANSFER END COORD TO START
944F  9F BD                      STX   HORBEG              ; *
9451  1F 02             L9451    TFR   D,Y                 ; SAVE DIFFERENCE IN Y
9453  31 21                      LEAY  $01,Y               ; ADD ONE TO DIFFERENCE - TURN ON STARTING & ENDING COORDS
9455  BD 92 98                   JSR   L9298               ; GET ABS SCREEN POS TO X AND PIXEL MASK TO ACCA
9458  35 40                      PULS  U                   ; GET START COORDS
945A  DF BD                      STU   HORBEG              ; RESTORE THEM
945C  8D 36                      BSR   L9494               ; POINT U TO ROUTINE TO MOVE PIXEL POINTERS TO RIGHT
945E  97 D7             L945E    STA   VD7                 ; SAVE PIXEL MASK
9460  BD 93 77                   JSR   L9377               ; TURN ON PIXEL
9463  96 D7                      LDA   VD7                 ; GET OLD PIXEL MASK
9465  AD C4                      JSR   ,U                  ; MOVE TO NEXT ONE TO RIGHT
9467  31 3F                      LEAY  $-01,Y              ; DEC COUNTER
9469  26 F3                      BNE   L945E               ; LOOP IF NOT DONE
946B  39                L946B    RTS
946C  35 06             L946C    PULS  A,B                 ; CLEAN UP STACK

* DRAW A VERTICAL LINE FROM VEREND TO VERBEG AT HOR COORD HORBEG
946E  DC BF             L946E    LDD   VERBEG              ; GET END COORDS
9470  34 06                      PSHS  B,A                 ; SAVE THEM
9472  BD 97 10                   JSR   L9710               ; CALCULATE ABSOLUTE VALUE OF VEREND-VERBEG
9475  24 04                      BCC   L947B               ; BRANCH IF END COORD > START COORD
9477  9E C5                      LDX   VEREND              ; *
9479  9F BF                      STX   VERBEG              ; *SWITCH VER COORDS IF END COORD IS TO RIGHT OF START
947B  1F 02             L947B    TFR   D,Y                 ; LENGTH OF LINE TO Y
947D  31 21                      LEAY  $01,Y               ; SET BOTH START AND END COORDS
947F  BD 92 98                   JSR   L9298               ; GET ABSOLUTE SCREEN POS TO X, MASK TO ACCA
9482  35 40                      PULS  U                   ; GET END COORD
9484  DF BF                      STU   VERBEG              ; RESTORE THEM
9486  8D 15                      BSR   L949D               ; POINT U TO ROUTINE TO MOVE DOWN ONE ROW
9488  20 D4                      BRA   L945E               ; DRAW VERT LINE
*
* JUMP TABLE OF ADDRESSES OF ROUTINES WHICH WILL MOVE THE
* ABSOLUTE SCREEN ADDRESS POINTER ONE PIXEL TO THE RIGHT.
948A  92 ED             L948A    FDB   L92ED               ; PMODE 0
948C  92 F4             L948C    FDB   L92F4               ; PMODE 1
948E  92 ED             L948E    FDB   L92ED               ; PMODE 2
9490  92 F4             L9490    FDB   L92F4               ; PMODE 3
9492  92 ED             L9492    FDB   L92ED               ; PMODE 4

* POINT U TO ROUTINE WHICH WILL MOVE PIXEL ONE TO RIGHT
9494  CE 94 8A          L9494    LDU   #L948A              ; POINT TO JUMP TABLE
9497  D6 B6                      LDB   PMODE               ; GET PMODE VALUE
9499  58                         ASLB                      ; X2
949A  EE C5                      LDU   B,U                 ; GET JUMP ADDRESS
949C  39                         RTS
949D  CE 92 E9          L949D    LDU   #L92E9              ; POINT U TO ROUTINE TO MOVE ABS POS DOWN ONE ROW
94A0  39                         RTS

* DRAW LINE FROM (HORBEG.VERBEG) TO (HOREND,VEREND)
94A1  10 8E 95 0D       L94A1    LDY   #L950D              ; POINT Y TO INCR VERBEG
94A5  BD 97 10                   JSR   L9710               ; CALCULATE VEREND - VERBEG (VERTICAL DIFFERENCE)
94A8  10 27 FF 98                LBEQ  >L9444              ; DRAW A HORIZONTAL LINE IF DELTA V = 0
94AC  24 04                      BCC   L94B2               ; BRANCH IF VER END COORD > VER START COORD
94AE  10 8E 95 1B                LDY   #L951B              ; POINT Y TO DECR VER COORD (VERBEG)
94B2  34 06             L94B2    PSHS  B,A                 ; SAVE DELTA V
94B4  CE 95 06                   LDU   #L9506              ; POINT U TO INCR HOR COORD
94B7  BD 97 1D                   JSR   L971D               ; CALCULATE HOREND-HORBEG (HOR DIFFERENCE)
94BA  27 B0                      BEQ   L946C               ; DRAW A VERTICAL LINE IF DELTA H = 0
94BC  24 03                      BCC   L94C1               ; BRANCH IF HOR END COORD > HOR START COORD
94BE  CE 95 14                   LDU   #L9514              ; POINT U TO DECR HOR COORD
94C1  10 A3 E4          L94C1    CMPD  ,S                  ; COMPARE DELTA H TO DELTA V
94C4  35 10                      PULS  X                   ; PUT DELTA V IN X
94C6  24 04                      BCC   L94CC               ; BRANCH IF DELTA H > DELTA V
94C8  1E 32                      EXG   U,Y                 ; SWAP CHANGE HOR & CHANGE VER ADDRESS
94CA  1E 01                      EXG   D,X                 ; EXCHANGE DELTA HOR & DELTA VER
94CC  34 46             L94CC    PSHS  U,B,A               ; *SAVE THE LARGER OF DELTA V, DELTA H
* *AND THE INCREMENT/DECREMENT ADDRESS
94CE  34 06                      PSHS  B,A                 ; SAVE WHICHEVER IS LARGER OF DELTA V, DELTA H
94D0  44                         LSRA                      ; *
94D1  56                         RORB                      ; * DIVIDE BY 2, SHIFT ACCD RIGHT ONE BIT
94D2  25 09                      BLO   L94DD               ; BRANCH IF ODD NUMBER
94D4  11 83 95 0E                CMPU  #L950D+1            ; SEE IF INCR OR DECR
94D8  25 03                      BLO   L94DD               ; BRANCH IF INCR
94DA  83 00 01                   SUBD  #1                  ; SUBTRACT 1 IF DECREMENT
94DD  34 16             L94DD    PSHS  X,B,A               ; *SAVE SMALLEST DELTA (X) AND INITIAL MINOR COORDINATE
; *INCREMENT COUNTER WHICH IS 1/2 OF LARGEST DELTA
94DF  BD 92 8F                   JSR   L928F               ; POINT U TO PROPER COORDINATE TO SCREEN CONVERSION ROUTINE

* DRAW THE LINE HERE - AT THIS POINT THE STACK HAS THE DRAW DATA ON IT

* 0 1,S=MINOR COORDINATE INCREMENT COUNTER
* 2 3,S=ASSOLUTE VALUE OF THE SMALLEST DELTA COORDINATE
* 4 5,S=ABSOLUTE VALUE OF THE LARGEST DELTA COORDINATE
* 6 7,S=LARGEST COORDINATE COUNTER (HOW MANY TIMES THROUGH THE DRAW
*       LOOP. INITIALLY SET TO ABSOLUTE VALUE OF LARGEST DELTA COORD
* 8 9,S=ADDRESS OF THE ROUTINE WHICH WILL INCREMENT OR DECREMENT
*       THE LARGEST DELTA COORDINATE

94E2  AD C4             L94E2    JSR   ,U                  ; CONVERT (X,Y) COORDINATES TO ABSOLUTE SCREEN ADDRESS
94E4  BD 93 77                   JSR   L9377               ; TURN ON A PIXEL
94E7  AE 66                      LDX   $06,S               ; GET DISTANCE COUNTER
94E9  27 17                      BEQ   L9502               ; BRANCH IF LINE IS COMPLETELY DRAWN
94EB  30 1F                      LEAX  $-01,X              ; DECR ONE
94ED  AF 66                      STX   $06,S               ; SAVE IT
94EF  AD F8 08                   JSR   [$08,S]             ; INCR/DECR COORDINATE-WHICH HAS THE LARGEST DELTA
94F2  EC E4                      LDD   ,S                  ; GET THE MIHOR COORDINATE INCREMENT COUNTER
94F4  E3 62                      ADDD  $02,S               ; ADD THE SMALLEST DIFFERENCE
94F6  ED E4                      STD   ,S                  ; SAVE NEW MINOR COORDINATE INCREMENT COUNTER
94F8  A3 64                      SUBD  $04,S               ; *SUBTR OUT THE LARGEST DIFFERENCE AND
94FA  25 E6                      BLO   L94E2               ; *BRANCH IF RESULT NOT > LARGEST DIFFERENCE
94FC  ED E4                      STD   ,S                  ; IF >=, THEN STORE NEW MIHOR COORDINATE INCREMENT
94FE  AD A4                      JSR   ,Y                  ; INCREMENT/DECREMENT COORDINATE WHICH HAS THE SMALLEST DELTA
9500  20 E0                      BRA   L94E2               ; KEEP GOING
9502  35 10             L9502    PULS  X                   ; *
9504  35 F6                      PULS  A,B,X,Y,U,PC        ; *CLEAN UP THE STACK AND RETURN
*
* THESE ROUTINES ARE USED TO INCREMENT OR DECREMENT THE
* HORIZONTAL & VERTICAL COORDINATES. THEY NEED TO BE KEPT
* IN THIS ORDER (INCR,INCR,DECR,DECR).

* INCR HORBEG (HOR COORD)
9506  9E BD             L9506    LDX   HORBEG              ; GET COORDINATE
9508  30 01                      LEAX  $01,X               ; ADD ONE
950A  9F BD                      STX   HORBEG              ; SAVE COORDINATE
950C  39                         RTS
* INCR VERBEG (VER COORD)
950D  9E BF             L950D    LDX   VERBEG              ; GET COORDINATE
950F  30 01                      LEAX  $01,X               ; ADD ONE
9511  9F BF                      STX   VERBEG              ; SAVE COORDINATE
9513  39                         RTS
* DECR HORSES (HOR COORD)
9514  9E BD             L9514    LDX   HORBEG              ; GET COORDINATE
9516  30 1F                      LEAX  $-01,X              ; SUBTRACT ONE
9518  9F BD                      STX   HORBEG              ; SAVE COORDINATE
951A  39                         RTS
* DECR VERBEG (VER COORD)
951B  9E BF             L951B    LDX   VERBEG              ; GET COORDINATE
951D  30 1F                      LEAX  $-01,X              ; SUBTRACT ONE
951F  9F BF                      STX   VERBEG              ; SAVE COORDINATE
9521  39                         RTS
*
* GET MAXIMUM VALUE OF HOR/VER COORDINATES
* NORMALIZED FOR PROPER PMODE.  RETURN VALUES
* HOR = VD3  VER = VD5
9522  CE 00 D3          L9522    LDU   #VD3                ; POINT U TO TEMP STORAGE AREA (VD3)
9525  8E 00 FF                   LDX   #255                ; MAXIMUM VALUE HORIZONTAL COORD (255)
9528  AF C4                      STX   ,U                  ; SAVE IT
952A  8E 00 BF                   LDX   #191                ; MAXIMUM VALUE VERTICAL COORD (191)
952D  AF 42                      STX   $02,U               ; SAVE IT
952F  7E 93 20                   JMP   L9320               ; GO CONVERT THEM TO PROPER PMODE

* PCLS
9532  27 0E             PCLS     BEQ   L9542               ; CLEAR TO BACKGROUND COLOR IF NO ARGUMENT
9534  8D 24                      BSR   L955A               ; EVALUATE EXPRESSION, CONVERT TO PROPER COLOR CODE
9536  86 55             L9536    LDA   #$55                ; CONSIDER EACH BYTE AS 4 GROUPS OF 2 BIT SUB-NIBBLES
9538  3D                         MUL                       ; MULT BY COLOR
9539  9E BA                      LDX   BEGGRP              ; GET STARTING ADOR
953B  E7 80             L953B    STB   ,X+                 ; SET BYTE TO PROPER COLOR
953D  9C B7                      CMPX  ENDGRP              ; AT END OF GRAPHIC PAGE?
953F  26 FA                      BNE   L953B               ; NO
9541  39                         RTS
9542  D6 B3             L9542    LDB   BAKCOL              ; GET BACKGROUND COLOR
9544  20 F0                      BRA   L9536
