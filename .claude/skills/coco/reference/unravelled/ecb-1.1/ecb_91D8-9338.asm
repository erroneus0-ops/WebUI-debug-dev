; Extended Color BASIC 1.1 -- $91D8-$9338
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: (none -- local labels only)

* IF FPA0 < 1.0, MULTIPLY IT BY 1E+09 UNTIL IT IS >= 1
91D8  8E BD C0                   LDX   #LBDC0              ; POINT X TO FP NUMBER (1E+09)
91DB  BD BA CA                   JSR   LBACA               ; MULTIPLY FPA0 BY 1E+09
91DE  96 47                      LDA   V47                 ; GET EXPONENT OFFSET
91E0  80 09                      SUBA  #$09                ; SUBTRACT 9 (BECAUSE WE MULTIPLIED BY 1E+09 ABOVE)
91E2  20 EC                      BRA   L91D0               ; CHECK TO SEE IF > 1.0
91E4  BD BB 82          L91E4    JSR   LBB82               ; DIVIDE FPA0 BY 10
91E7  0C 47                      INC   V47                 ; INCREMENT EXPONENT OFFSET
91E9  8E BD BB          L91E9    LDX   #LBDBB              ; POINT X TO FP NUMBER (999,999,999)
91EC  BD BC A0                   JSR   LBCA0               ; COMPARE FPA0 TO X
91EF  2E F3                      BGT   L91E4               ; BRANCH IF FPA0 > 999,999,999
91F1  8E BD B6          L91F1    LDX   #LBDB6              ; POINT X TO FP NUMBER (99,999,999.9)
91F4  BD BC A0                   JSR   LBCA0               ; COMPARE FPA0 TO X
91F7  2E 07                      BGT   L9200               ; RETURN IF 999,999,999 > FPA0 > 99,999,999.9
91F9  BD BB 6A                   JSR   LBB6A               ; MULTIPLY FPA0 BY 10
91FC  0A 47                      DEC   V47                 ; DECREMENT EXPONENT OFFSET
91FE  20 F1                      BRA   L91F1               ; KEEP UNNORMALIZING
9200  35 C0             L9200    PULS  U,PC                ; RESTORE BUFFER POINTER AND RETURN
*
* CONVERT FPA0 INTO AN INTEGER, THEN DECODE IT
* INTO A DECIMAL ASCII STRING IN THE BUFFER
9202  34 40             L9202    PSHS  U                   ; SAVE BUFFER POINTER
9204  BD B9 B4                   JSR   LB9B4               ; ADD .5 TO FPA0 (ROUND OFF)
9207  BD BC C8                   JSR   LBCC8               ; CONVERT FPA0 TO INTEGER FORMAT
920A  35 40                      PULS  U                   ; RESTORE BUFFER POINTER
*
* CONVERT FPA0 INTO A DECIMAL ASCII STRING
920C  8E BE C5                   LDX   #LBEC5              ; POINT X TO UNNORMALIZED POWERS OF 10
920F  C6 80                      LDB   #$80                ; INITIALIZE DIGIT COUNTER TO 0 + $80.
* BIT 7 SET IS USED TO INDICATE THAT THE POWER OF 10 MANTISSA
* IS NEGATIVE. WHEN YOU 'ADD' A NEGATIVE MANTISSA, IT IS
* THE SAME AS SUBTRACTING A POSITIVE ONE AND BIT 7 OF ACCB
* IS HOW THIS ROUTINE KNOWS THAT A 'SUBTRACTION' IS OCCURRING.
9211  8D 36             L9211    BSR   L9249               ; CHECK FOR COMMA INSERTION
9213  96 53             L9213    LDA   FPA0+3              ; * 'ADD' A POWER OF 10 MANTISSA TO FPA0.
9215  AB 03                      ADDA  $03,X               ; * IF THE MANTISSA IS NEGATIVE, A SUBTRACTION
9217  97 53                      STA   FPA0+3              ; * WILL BE WHAT REALLY TAKES PLACE.
9219  96 52                      LDA   FPA0+2              ; *
921B  A9 02                      ADCA  $02,X               ; *
921D  97 52                      STA   FPA0+2              ; *
921F  96 51                      LDA   FPA0+1              ; *
9221  A9 01                      ADCA  $01,X               ; *
9223  97 51                      STA   FPA0+1              ; *
9225  96 50                      LDA   FPA0                ; *
9227  A9 84                      ADCA  ,X                  ; *
9229  97 50                      STA   FPA0                ; *
922B  5C                         INCB                      ; ADD ONE TO DIGIT COUNTER
922C  56                         RORB                      ; ROTATE CARRY INTO BIT 7
922D  59                         ROLB                      ; * SET OVERFLOW FLAG - BRANCH IF CARRY SET AND
922E  28 E3                      BVC   L9213               ; * ADDING MANTISSA OR CARRY CLEAR AND SUBTRACTING MANTISSA
9230  24 03                      BCC   L9235               ; BRANCH IF SUBTRACTING MANTISSA
9232  C0 0B                      SUBB  #10+1               ; * TAKE THE 9'S COMPLEMENT
9234  50                         NEGB                      ; * IF ADDING MANTISSA
9235  CB 2F             L9235    ADDB  #'0'-1              ; ADD IN ASCII OFFSET
9237  30 04                      LEAX  $04,X               ; MOVE TO NEXT POWER OF 10 MANTISSA
9239  1F 98                      TFR   B,A                 ; SAVE DIGIT IN ACCA
923B  84 7F                      ANDA  #$7F                ; MASK OFF ADD/SUBTRACT FLAG (BIT 7)
923D  A7 C0                      STA   ,U+                 ; STORE DIGIT IN BUFFER
923F  53                         COMB                      ; TOGGLE ADD/SUBTRACT FLAG
9240  C4 80                      ANDB  #$80                ; MASK OFF EVERYTHING BUT ADD/SUB FLAG
9242  8C BE E9                   CMPX  #LBEE9              ; COMPARE TO END OF UNNORMALIZED POWERS OF 10
9245  26 CA                      BNE   L9211               ; BRANCH IF NOT DONE
9247  6F C4                      CLR   ,U                  ; PUT A ZERO AT END OF INTEGER

* DECREMENT DECIMAL POINT COUNTER AND CHECK FOR COMMA INSERTION
9249  0A 45             L9249    DEC   V45                 ; DECREMENT DECIMAL POINT COUNTER
924B  26 09                      BNE   L9256               ; NOT TIME FOR DECIMAL POINT
924D  DF 39             L924D    STU   VARPTR              ; SAVE BUFFER POINTER-POSITION OF THE DECIMAL POINT
924F  86 2E                      LDA   #'.'                ; * STORE A DECIMAL
9251  A7 C0                      STA   ,U+                 ; * POINT IN THE OUTPUT BUFFER
9253  0F D7                      CLR   VD7                 ; =CLEAR COMMA COUNTER - NOW IT WILL TAKE 255
* =DECREMENTS BEFORE ANOTHER COMMA WILL BE INSERTED
9255  39                         RTS
9256  0A D7             L9256    DEC   VD7                 ; DECREMENT COMMA COUNTER
9258  26 08                      BNE   L9262               ; RETURN IF NOT TIME FOR COMMA
925A  86 03                      LDA   #$03                ; * RESET COMMA COUNTER TO 3; THREE
925C  97 D7                      STA   VD7                 ; * DIGITS BETWEEN COMMAS
925E  86 2C                      LDA   #','                ; = PUT A COMMA INTO
9260  A7 C0                      STA   ,U+                 ; = THE BUFFER
9262  39                L9262    RTS

* INITIALIZE DECIMAL POINT AND COMMA COUNTERS
9263  96 47             L9263    LDA   V47                 ; GET THE BASE 10 EXPONENT OFFSET
9265  8B 0A                      ADDA  #10                 ; * ADD 10 (FPA0 WAS 'NORMALIZED' TO 9 PLACES LEFT
9267  97 45                      STA   V45                 ; * OF DECIMAL POINT) - SAVE IN DECIMAL POINT COUNTER
9269  4C                         INCA                      ; ADD ONE FOR THE DECIMAL POINT
926A  80 03             L926A    SUBA  #$03                ; = DIVIDE DECIMAL POINT COUNTER BY 3; LEAVE
926C  24 FC                      BCC   L926A               ; = THE REMAINDER IN ACCA
926E  8B 05                      ADDA  #$05                ; CONVERT REMAINDER INTO A NUMBER FROM 1-3
9270  97 D7                      STA   VD7                 ; SAVE COMMA COUNTER
9272  96 DA                      LDA   VDA                 ; GET STATUS BYTE
9274  84 40                      ANDA  #$40                ; CHECK FOR COMMA FLAG
9276  26 02                      BNE   L927A               ; BRANCH IF COMMA FLAG ACTIVE
9278  97 D7                      STA   VD7                 ; CLEAR COMMA COUNTER - 255 DIGITS OUTPUT BEFORE A COMMA
927A  39                L927A    RTS
*
* INSERT ACCA ZEROES INTO THE BUFFER
927B  34 02             L927B    PSHS  A                   ; SAVE ZEROES COUNTER
927D  8D CA                      BSR   L9249               ; CHECK FOR DECIMAL POINT
927F  35 02                      PULS  A                   ; RESTORE ZEROES COUNTER
9281  4A                L9281    DECA                      ; * DECREMENT ZEROES COUNTER AND
9282  2B 0A                      BMI   L928E               ; * RETURN IF < 0
9284  34 02                      PSHS  A                   ; SAVE ZEROES COUNTER
9286  86 30                      LDA   #'0'                ; * PUT A ZERO INTO
9288  A7 C0                      STA   ,U+                 ; * THE BUFFER
928A  A6 E0                      LDA   ,S+                 ; RESTORE THE ZEROES COUNTER
928C  26 ED                      BNE   L927B               ; BRANCH IF NOT DONE
928E  39                L928E    RTS

******* GRAPHICS PACKAGE ********

* GET THE ADDRESS OF THE ROUTINE WHICH
* WILL CONVERT HOR & VER COORDINATES INTO
* AN ABSOLUTE RAM ADDRESS AND PIXEL MASK
* DEPENDING UPON THE CURRENT PMODE AND
* RETURN THE ADDRESS IN U.
*
928F  CE 92 9C          L928F    LDU   #L929C              ; JUMP TABLE ADDRESS TO U
9292  96 B6                      LDA   PMODE               ; GET PMODE VALUE
9294  48                         ASLA                      ; MUL ACCA X2 - 2 BYTES PER ADDRESS
9295  EE C6                      LDU   A,U                 ; GET JUMP ADDRESS
9297  39                         RTS
*
* CONVERT VER COORD (VERBEG) & NOR COORD (HORBEG) INTO
* ABSOLUTE SCREEN ADDR IN X AND PIXEL MASK IN ACCA.
9298  8D F5             L9298    BSR   L928F               ; GO GET JUMP ADDRESS
929A  6E C4                      JMP   ,U                  ; GO TO IT
*
* JUMP TABLE -- HOR, VER COORD CONVERSION
929C  92 A6             L929C    FDB   L92A6               ; PMODE 0
929E  92 C2             L929E    FDB   L92C2               ; PMODE 1
92A0  92 A6             L92A0    FDB   L92A6               ; PMODE 2
92A2  92 C2             L92A2    FDB   L92C2               ; PMODE 3
92A4  92 A6             L92A4    FDB   L92A6               ; PMODE 4
*
* HOR, VER COORD CONVERSION ROUTINE FOR 2
* COLOR HIRES GRAPHICS MODES
92A6  34 44             L92A6    PSHS  U,B                 ; SAVE REGISTERS
92A8  D6 B9                      LDB   HORBYT              ; GET NUMBER BYTES/HOR GRAPHIC ROW
92AA  96 C0                      LDA   VERBEG+1            ; GET VERTICAL COORDINATE
92AC  3D                         MUL                       ; CALCULATE VERTICAL BYTE OFFSET
92AD  D3 BA                      ADDD  BEGGRP              ; ADD IN START OF GRAPHIC PAGE
92AF  1F 01                      TFR   D,X                 ; SAVE TEMP VALUE IN X REG
92B1  D6 BE                      LDB   HORBEG+1            ; GET HORIZONTAL COORDINATE
92B3  54                         LSRB                      ; * THREE LSRBS EQUALS DIVIDE BY 8 -
92B4  54                         LSRB                      ; * IN THE TWO COLOR MODE THERE ARE
92B5  54                         LSRB                      ; * 8 PIXELS/BYTE
92B6  3A                         ABX                       ; ADD HOR BYTE OFFSET
92B7  96 BE                      LDA   HORBEG+1            ; GET HORIZONTAL COORDINATE
92B9  84 07                      ANDA  #$07                ; *KEEP ONLY BITS 0-2, WHICH CONTAIN THE NUMBER
* *OF THE PIXEL IN THE BYTE
92BB  CE 92 DD                   LDU   #L92DD              ; POINT U TO MASK LOOKUP TABLE
92BE  A6 C6                      LDA   A,U                 ; *GET PIXEL MASK - THE MASK WILL HAVE ONE BIT SET WHICH
* *CORRESPONDS TO THE PIXEL SELECTED.
92C0  35 C4                      PULS  B,U,PC              ; RESTORE REGISTERS
*
* HOR, VER COORDINATE CONVERSION ROUTINE
* FOR 4 COLOR HI RES GRAPHICS MODES
92C2  34 44             L92C2    PSHS  U,B                 ; SAVE REGISTERS
92C4  D6 B9                      LDB   HORBYT              ; GET NUMBER BYTES/HOR GRAPHIC ROW
92C6  96 C0                      LDA   VERBEG+1            ; GET VERTICAL COORDINATE
92C8  3D                         MUL                       ; CALCULATE VERTICAL OFFSET
92C9  D3 BA                      ADDD  BEGGRP              ; ADD THE START OF GRAPHIC PAGE
92CB  1F 01                      TFR   D,X                 ; SAVE IN X REGISTER
92CD  D6 BE                      LDB   HORBEG+1            ; GET HORIZONTAL COORDINATE
92CF  54                         LSRB                      ; TWO LSRBS = DIVIDE BY 4; IN THE 4
92D0  54                         LSRB                      ; COLOR MODE THERE ARE 4 PIXELS/BYTE
92D1  3A                         ABX                       ; ADD HORIZONTAL BYTE OFFSET
92D2  96 BE                      LDA   HORBEG+1            ; GET HORIZONTAL COORDINATE
92D4  84 03                      ANDA  #$03                ; *KEEP ONLY BITS 0,1 WHICH CONTAIN THE NUMBER OF THE PIXEL
* *TO CHANGE (4 COLOR)
92D6  CE 92 E5                   LDU   #L92E5              ; POINT U TO MASK LOOKUP TABLE
92D9  A6 C6                      LDA   A,U                 ; GET THE MASK FOR THE PROPER PIXEL
92DB  35 C4                      PULS  B,U,PC              ; RESTORE REGISTERS AND RETURN

* 2 COLOR MODE PIXEL MASKS
92DD  80 40 20 10 08 04 L92DD    FCB   $80,$40,$20,$10,$08,$04
92E3  02 01                      FCB   $02,$01

* 4 COLOR MODE PIXEL MASKS
92E5  C0 30 0C 03       L92E5    FCB   $C0,$30,$0C,$03

* MOVE X REG DOWN ONE GRAPHIC ROW
92E9  D6 B9             L92E9    LDB   HORBYT              ; GET NUMBER BYTES/HOR ROW
92EB  3A                         ABX                       ; ADD TO ABSOLUTE SCREEN POSITION
92EC  39                         RTS
*
* ENTER W/ABSOLUTE SCREEN POSITION IN X, THE PIXEL
* MASK IN ACCA - ADJUST X AND ACCA TO THE NEXT
* PIXEL TO THE RIGHT IN THE TWO COLOR MODE.
92ED  44                L92ED    LSRA                      ; SHIFT ONE BIT TO RIGHT
92EE  24 03                      BCC   L92F3               ; BRANCH IF IN SAME BYTE
92F0  46                         RORA                      ; IF YOU HAVE MOVED TO NEXT BYTE, SET BIT 7 IN ACCA
92F1  30 01                      LEAX  $01,X               ; AND ADD ONE TO X.
92F3  39                L92F3    RTS
*
*
* MOVE ABSOLUTE SCREEN ADDRESS OF CURRENT
* HOR, VER COORD ONE TO RIGHT AND ADJUST
* THE PIXEL MASK FOR THE 4 COLOR MODE
92F4  44                L92F4    LSRA                      ; SHIFT MASK ONE BIT TO RIGHT
92F5  24 F6                      BCC   L92ED               ; SHIFT RIGHT AGAIN IF SAME BYTE
92F7  86 C0                      LDA   #$C0                ; SET PIXEL #3 IF NEW BYTE
92F9  30 01                      LEAX  $01,X               ; ADD ONE TO ABS SCREEN POSITION
92FB  39                         RTS
*
* EVALUATE TWO EXPRESSIONS - PUT THE FIRST
* VALUE (HOR COORD) IN HORBEG AND THE
* SECOND (VER COORD) IN VERBEG.
92FC  BD B7 34          L92FC    JSR   LB734               ; *EVALUATE TWO EXPRESSIONS FROM THE BASIC LINE -
* *RETURN WITH THE 1ST VALUE IN BINVAL AND THE 2ND IN ACCB
92FF  10 8E 00 BD                LDY   #HORBEG             ; POINT Y TO TEMP STORAGE LOC
9303  C1 C0             L9303    CMPB  #192                ; IS VERT COORD > 191?
9305  25 02                      BLO   L9309               ; NO
9307  C6 BF                      LDB   #191                ; FORCE VER COORD TO 191
9309  4F                L9309    CLRA                      ; HIGH ORDER BYTE OF VER COORD
930A  ED 22                      STD   $02,Y               ; SAVE VERTICAL COORDINATE
930C  DC 2B                      LDD   BINVAL              ; GET RAW HORIZONTAL COORDINATE
930E  10 83 01 00                CMPD  #256                ; IS IT WITHIN RANGE?
9312  25 03                      BLO   L9317               ; YES
9314  CC 00 FF                   LDD   #255                ; FORCE IT TO 255 IF NOT IN RANGE
9317  ED A4             L9317    STD   ,Y                  ; SAVE HORIZONTAL COORDINATE
9319  39                         RTS

* NORMALIZE HORIZONTAL AND VERTICAL COORDINATES FOR THE PROPER PHODE
* RETURN NORMALIZED VALUES IN (HORBEG,VERBEG)
931A  BD 92 FC          L931A    JSR   >L92FC              ; GO GET HOR & VER COORDINATES
931D  CE 00 BD          L931D    LDU   #HORBEG             ; POINT U TO HOR & VER COORDS
9320  96 B6             L9320    LDA   PMODE               ; GET PHODE
9322  81 02                      CMPA  #$02                ; CHECK MODE
9324  24 06                      BCC   L932C               ; BRANCH IF > 1
9326  EC 42                      LDD   $02,U               ; GET THE VERT COORD
9328  44                         LSRA                      ; *DIVIDE ACCD BY TWO SINCE
9329  56                         RORB                      ; *PMODES 0&1 HAVE ONLY 96 VERT BLOCKS
932A  ED 42                      STD   $02,U               ; SAVE NEW VERT COORD
932C  96 B6             L932C    LDA   PMODE               ; GET PMODE
932E  81 04                      CMPA  #$04                ; CHECK PMODE
9330  24 06                      BCC   L9338               ; BRANCH IF PMODE = 4
9332  EC C4                      LDD   ,U                  ; GET HOR COORD
9334  44                         LSRA                      ; * DIVIDE HORIZONTAL COORDINATE
9335  56                         RORB                      ; * BY 2-PMODES 0,1,2,3 HAVE ONLY 128 HOR BLOCKS
9336  ED C4                      STD   ,U                  ; SAVE NEW HOR COORD
9338  39                L9338    RTS
