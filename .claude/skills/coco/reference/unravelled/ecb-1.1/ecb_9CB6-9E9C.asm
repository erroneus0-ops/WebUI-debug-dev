; Extended Color BASIC 1.1 -- $9CB6-$9E9C
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: DRAW=$9CB6

9CB6  9E 8A             DRAW     LDX   ZERO                ; * X=0. ACCB=1; END OF DRAW COMMAND LINE VALUES -
9CB8  C6 01                      LDB   #$01                ; * WHEN THESE VALUES ARE PULLED OFF THE
9CBA  34 14                      PSHS  X,B                 ; * STACK, THE DRAW COMMAND WILL END
9CBC  D7 C2                      STB   SETFLG              ; SET PSET/PRESET FLAG TO PSET
9CBE  9F D5                      STX   VD5                 ; CLEAR UPDATE FLAG AND DRAW FLAG
9CC0  BD 95 9A                   JSR   L959A               ; SET ACTIVE COLOR BYTE
9CC3  BD B1 56                   JSR   LB156               ; EVALUATE EXPRESSION
9CC6  BD B6 54          L9CC6    JSR   LB654               ; GET THE LENGTH AND ADDRESS OF THE COMMAND STRING
9CC9  20 08                      BRA   L9CD3               ; INTERPRET THE COMMAND STRING
9CCB  BD 9B 98          L9CCB    JSR   L9B98               ; GET NEXT CHARACTER FROM COMMAND LINE
9CCE  7E 9B BE                   JMP   L9BBE               ; EVALUATE A DECIMAL VALUE IN COMMAND LINE
9CD1  35 14             L9CD1    PULS  B,X                 ; GET NEXT COMMAND LINE TO BE INTERPRETED OFF THE STACK
9CD3  D7 D8             L9CD3    STB   VD8                 ; SET COMMAND LENGTH CTR
9CD5  27 FA                      BEQ   L9CD1               ; GET NEW COMMAND LINE IF 0
9CD7  9F D9                      STX   VD9                 ; SET COMMAND LINE ADDRESS
9CD9  10 27 00 EA                LBEQ  L9DC7               ; EXIT ROUTINE IF ADDRESS = 0
9CDD  0D D8             L9CDD    TST   VD8                 ; TEST COMMAND LENGTH CTR
9CDF  27 F0                      BEQ   L9CD1               ; GET NEW LINE IF 0
9CE1  BD 9B 98                   JSR   L9B98               ; GET A COMMAND CHAR
9CE4  81 3B                      CMPA  #';'                ; CHECK FOR SEMICOLON
9CE6  27 F5                      BEQ   L9CDD               ; IGNORE SEMICOLONS
9CE8  81 27                      CMPA  #'''                ; CHECK FOR APOSTROPHES
9CEA  27 F1                      BEQ   L9CDD               ; IGNORE APOSTROPHES
9CEC  81 4E                      CMPA  #'N'                ; UPDATE CHECK?
9CEE  26 04                      BNE   L9CF4               ; NO
9CF0  03 D5                      COM   VD5                 ; TOGGLE UPDATE FLAG 0 = UPDATE, FF = NO UPDATE
9CF2  20 E9                      BRA   L9CDD               ; GET NEXT COMMAND
9CF4  81 42             L9CF4    CMPA  #'B'                ; CHECK DRAW FLAG?
9CF6  26 04                      BNE   L9CFC               ; NO
9CF8  03 D6                      COM   VD6                 ; TOGGLE DRAW FLAG 0 = DRAW LINE, FF = DON'T DRAW LINE
9CFA  20 E1                      BRA   L9CDD               ; GET NEXT COMMAND
9CFC  81 58             L9CFC    CMPA  #'X'                ; SUBSTRING?
9CFE  10 27 00 96                LBEQ  L9D98               ; GO EXECUTE A COMMAND
9D02  81 4D                      CMPA  #'M'                ; MOVE THE DRAW POSITION ?
9D04  10 27 01 2A                LBEQ  L9E32               ; YES; GO MOVE IT
9D08  34 02                      PSHS  A                   ; SAVE CURRENT COMMAND
9D0A  C6 01                      LDB   #$01                ; DEFAULT VALUE IF NO NUMBER FOLLOWS COMMAND
9D0C  0D D8                      TST   VD8                 ; CHECK COMMAND LENGTH CTR
9D0E  27 11                      BEQ   L9D21               ; BRANCH IF NO COMMANDS LEFT
9D10  BD 9B 98                   JSR   L9B98               ; GET A COMMAND CHAR
9D13  BD B3 A2                   JSR   LB3A2               ; SET CARRY IF NOT ALPHA
9D16  34 01                      PSHS  CC                  ; SAVE CARRY FLAG
9D18  BD 9B E2                   JSR   L9BE2               ; MOVE COMMAND POINTER BACK ONE
9D1B  35 01                      PULS  CC                  ; RESTORE CARRY FLAG
9D1D  24 02                      BCC   L9D21               ; BRANCH IF NEXT COMMAND IS ALPHA
9D1F  8D AA                      BSR   L9CCB               ; EVALUATE A DECIMAL COMMAND LINE VALUE - RETURN VALUE IN ACCB
9D21  35 02             L9D21    PULS  A                   ; GET CURRENT COMMAND BACK
9D23  81 43                      CMPA  #'C'                ; CHANGE COLOR?
9D25  27 28                      BEQ   L9D4F               ; YES
9D27  81 41                      CMPA  #'A'                ; CHANGE ANGLE?
9D29  27 2E                      BEQ   L9D59               ; YES
9D2B  81 53                      CMPA  #'S'                ; CHANGE SCALE?
9D2D  27 32                      BEQ   L9D61               ; YES
9D2F  81 55                      CMPA  #'U'                ; GO UP?
9D31  27 5C                      BEQ   L9D8F               ; YES
9D33  81 44                      CMPA  #'D'                ; GO DOWN?
9D35  27 55                      BEQ   L9D8C               ; YES
9D37  81 4C                      CMPA  #'L'                ; GO LEFT?
9D39  27 4C                      BEQ   L9D87               ; YES
9D3B  81 52                      CMPA  #'R'                ; GO RIGHT?
9D3D  27 43                      BEQ   L9D82               ; YES
9D3F  80 45                      SUBA  #'E'                ; MASK OFF ASCII FOR LETTER E-H COMMAND CHECKS
9D41  27 2F                      BEQ   L9D72               ; BRANCH IF E (45 DEGREES)
9D43  4A                         DECA                      ; *
9D44  27 27                      BEQ   L9D6D               ; *BRANCH IF F (135 DEGREES)
9D46  4A                         DECA                      ; =
9D47  27 32                      BEQ   L9D7B               ; =BRANCH IF G (225 DEGREES)
9D49  4A                         DECA                      ; *
9D4A  27 1D                      BEQ   L9D69               ; *BRANCH IF H (31S DEGREES)
9D4C  7E B4 4A          L9D4C    JMP   LB44A               ; 'FC' ERROR IF ILLEGAL COMMAND

* CHANGE COLOR
9D4F  BD 95 5D          L9D4F    JSR   L955D               ; ADJUST COLOR CODE FOR PROPER PMODE
9D52  D7 B2                      STB   FORCOL              ; SAVE NEW FOREGROUND COLOR
9D54  BD 95 9A                   JSR   L959A               ; SET COLOR BYTES (WCOLOR,ALLCOL)
9D57  20 84             L9D57    BRA   L9CDD               ; GO PROCESS ANOTHER COMMAND
* CHANGE ANGLE
9D59  C1 04             L9D59    CMPB  #$04                ; ONLY 0-3 ARE LEGAL
9D5B  24 EF                      BCC   L9D4C               ; 'FC' ERROR IF ANGLE NUMBER > 3
9D5D  D7 E8                      STB   ANGLE               ; SAVE DRAW ANGLE
9D5F  20 F6                      BRA   L9D57               ; GO PROCESS ANOTHER COMMAND
* CHANGE SCALE
9D61  C1 3F             L9D61    CMPB  #63                 ; ONLY 0-63 ARE LEGAL
9D63  24 E7                      BCC   L9D4C               ; 'FC' ERROR IF SCALE > 63
9D65  D7 E9                      STB   SCALE               ; SAVE DRAW SCALE
9D67  20 EE                      BRA   L9D57               ; GO PROCESS ANOTHER COMMAND

* 315 DEGREES
9D69  4F                L9D69    CLRA                      ; *NEGATE ACCD - MAKE HORIZONTAL
9D6A  8D 58                      BSR   L9DC4               ; *DIFFERENCE NEGATIVE
9D6C  21                L9D6C    FCB   SKP1                ; SKIP ONE BYTE - KEEP HORIZONTAL DIFFERENCE NEGATIVE
* 135 DEGREES
9D6D  4F                L9D6D    CLRA                      ; CLEAR MS BYTE OF HORIZONTAL DIFFERENCE
9D6E  1F 01                      TFR   D,X                 ; COPY HORIZONTAL DIFFERENCE TO VERTICAL DIFFERENCE
9D70  20 59                      BRA   L9DCB               ; GO MOVE THE DRAW POSITION
* 45 DEGREES
9D72  4F                L9D72    CLRA                      ; CLEAR MS BYTE OF HORIZONTAL DIFFERENCE
9D73  1F 01                      TFR   D,X                 ; COPY HORIZONTAL DIFFERENCE TO VERTICAL DIFFERENCE
9D75  8D 4D                      BSR   L9DC4               ; NEGATE ACCD - MAKE HORIZONTAL DIFFERENCE NEGATIVE
9D77  1E 01                      EXG   D,X                 ; EXCHANGE HORIZONTAL AND VERTICAL DIFFERENCES
9D79  20 50                      BRA   L9DCB               ; GO MOVE THE DRAW POSITION
* 225 DEGREES
9D7B  4F                L9D7B    CLRA                      ; CLEAR MS BYTE OF HORIZONTAL DIFFERENCE
9D7C  1F 01                      TFR   D,X                 ; COPY HORIZONTAL DIFFERENCE TO VERTICAL DIFFERENCE
9D7E  8D 44                      BSR   L9DC4               ; NEGATE ACCD - MAKE HORIZONTAL DIFFERENCE NEGATIVE
9D80  20 49                      BRA   L9DCB               ; GO MOVE THE DRAW POSITION
* GO RIGHT
9D82  4F                L9D82    CLRA                      ; CLEAR MS BYTE OF HORIZONTAL DIFFERENCE
9D83  9E 8A             L9D83    LDX   ZERO                ; X = 0; VERT DIFF = 0
9D85  20 44                      BRA   L9DCB               ; GO MOVE THE DRAW POSITION
* GO LEFT
9D87  4F                L9D87    CLRA                      ; *NEGATE ACCD - MAKE THE HORIZONTAL
9D88  8D 3A                      BSR   L9DC4               ; *DIFFERENCE NEGATIVE
9D8A  20 F7                      BRA   L9D83               ; MAKE VERTICAL DIFFERENCE ZERO AND MOVE THE DRAW POSITION
* GO DOWN
9D8C  4F                L9D8C    CLRA                      ; CLEAR MS BYTE OF HORIZONTAL DIFFERENCE
9D8D  20 03                      BRA   L9D92               ; *MAKE VERTICAL DIFFERENCE = 0, EXCHANGE HORIZONTAL AND
* *VERTICAL DIFFERENCES AND MOVE THE DRAW POSTION
* GO UP
9D8F  4F                L9D8F    CLRA                      ; *NEGATE ACCD - MAKE THE HORIZONTAL
9D90  8D 32                      BSR   L9DC4               ; *DIFFERENCE NEGATIVE
9D92  9E 8A             L9D92    LDX   ZERO                ; X = 0; HORZ DIFF = 0
9D94  1E 10                      EXG   X,D                 ; EXCHANGE THE HORIZONTAL AND VERTICAL DIFFERENCES
9D96  20 33                      BRA   L9DCB               ; GO MOVE THE DRAW POSITION
* EXECUTE A COMMAND SUB STRING
9D98  BD 9C 1B          L9D98    JSR   L9C1B               ; INTERPRET CURRENT COMMAND AS IF IT WERE A BASIC VARIABLE
9D9B  C6 02                      LDB   #$02                ; =
9D9D  BD AC 33                   JSR   LAC33               ; =FOUR BYTES OF FREE RAM LEFT?
9DA0  D6 D8                      LDB   VD8                 ; *
9DA2  9E D9                      LDX   VD9                 ; * GET CURRENT COMMAND LENGTH AND POINTER
9DA4  34 14                      PSHS  X,B                 ; * AND SAVE THEM ON THE STACK
9DA6  7E 9C C6                   JMP   L9CC6               ; EVALUATE NUMERICAL VALUE IN COMMAND LINE
* MULTIPLY HOR OR VER DIFFERENCE BY SCALE FACTOR.
* DIVIDE PRODUCT BY 4 AND RETURN VALUE IN ACCD
9DA9  D6 E9             L9DA9    LDB   SCALE               ; GET DRAW SCALE AND BRANCH IF ZERO - THIS WILL CAUSE A
9DAB  27 1B                      BEQ   L9DC8               ; ZERO DEFAULT TO FULL SCALE
9DAD  4F                         CLRA                      ; CLEAR MS BYTE
9DAE  1E 01                      EXG   D,X                 ; EXCHANGE DIFFERENCE AND SCALE FACTOR
9DB0  A7 E2                      STA   ,-S                 ; SAVE MS BYTE OF DIFFERENCE ON STACK (SIGN INFORMATION)
9DB2  2A 02                      BPL   L9DB6               ; BRANCH IF POSITIVE DIFFERENCE
9DB4  8D 0D                      BSR   L9DC3               ; NEGATE ACCD
9DB6  BD 9F B5          L9DB6    JSR   L9FB5               ; MULT DIFFERENCE BY SCALE FACTOR
9DB9  1F 30                      TFR   U,D                 ; SAVE 2 MS BYTES IN ACCD
9DBB  44                         LSRA                      ; *
9DBC  56                         RORB                      ; *
9DBD  44                L9DBD    LSRA                      ; *
9DBE  56                         RORB                      ; *DIVIDE ACCD BY 4 - EACH SCALE INCREMENT IS 1/4 FULL SCALE
9DBF  6D E0                      TST   ,S+                 ; =CHECK SIGN OF ORIGINAL DIFFERENCE AND
9DC1  2A 04                      BPL   L9DC7               ; =RETURN IF POSITIVE
* NEGATE ACCUMULATOR D
9DC3  40                L9DC3    NEGA
9DC4  50                L9DC4    NEGB                      ; *
9DC5  82 00                      SBCA  #$00                ; * NEGATE ACCUMULATOR D IF ACCA=0
9DC7  39                L9DC7    RTS
9DC8  1F 10             L9DC8    TFR   X,D                 ; TRANSFER UNCHANGED DIFFERENCE TO ACCD
9DCA  39                         RTS
* MOVE THE DRAW POSITION - ADD THE ORTHOGONAL DIFFERENCES
* IN ACCD (HORIZONTAL) AND X (VERTICAL) TO
* THE CURRENT POSITION; DRAW A LINE AFTER THE MOVE
9DCB  34 06             L9DCB    PSHS  B,A                 ; SAVE HORIZ DIFFERENCE
9DCD  8D DA                      BSR   L9DA9               ; APPLY SCALE FACTOR TO VERTICAL
9DCF  35 10                      PULS  X                   ; GET HORIZ DIFFERENCE
9DD1  34 06                      PSHS  B,A                 ; SAVE VERT DIFFERENCE
9DD3  8D D4                      BSR   L9DA9               ; APPLY SCALE FACTOR TO HORIZONTAL
9DD5  35 10                      PULS  X                   ; GET VERT DIFFERENCE
9DD7  10 9E E8                   LDY   ANGLE               ; * GET THE DRAW ANGLE AND SCALE AND SAVE THEM ON
9DDA  34 20                      PSHS  Y                   ; * THE STACK; USE Y BECAUSE IT IS THE ONLY UNUSED REGISTER
9DDC  6D E4             L9DDC    TST   ,S                  ; CHECK DRAW ANGLE
9DDE  27 08                      BEQ   L9DE8               ; BRANCH IF NO ANGLE
9DE0  1E 10                      EXG   X,D                 ; EXCH HOR AND VER DIFFERENCES
9DE2  8D DF                      BSR   L9DC3               ; NEGATE ACCD
9DE4  6A E4                      DEC   ,S                  ; DECR ANGLE
9DE6  20 F4                      BRA   L9DDC               ; CHECK ANGLE AGAIN
9DE8  35 20             L9DE8    PULS  Y                   ; PULL ANGLE AND SCALE OFF THE STACK
9DEA  DE 8A                      LDU   ZERO                ; U = 0; DEFAULT HOR END POSITION = 0
9DEC  D3 C7                      ADDD  HORDEF              ; ADD DIFFERENCE TO HORIZ START
9DEE  2B 02                      BMI   L9DF2               ; HORIZ COORD = 0 IF RESULT IS NEG
9DF0  1F 03                      TFR   D,U                 ; SAVE HOR END POSITION IN U
9DF2  1F 10             L9DF2    TFR   X,D                 ; PUT VERT DIFFERENCE IN ACCD
9DF4  9E 8A                      LDX   ZERO                ; X = 0; DEFAULT VER END POSITION = 0
9DF6  D3 C9                      ADDD  VERDEF              ; ADD DIFFERENCE TO VER START
9DF8  2B 02                      BMI   L9DFC               ; VER COORD = 0 IF RESULT IS NEG
9DFA  1F 01                      TFR   D,X                 ; SAVE VERT END POSITION IN X

* MOVE THE DRAW POSITION; ENTER WITH ABSOLUTE HORIZONTAL POSITION
* IN U REGISTER AND ABSOLUTE VERTICAL POSITlON IN X REGISTER.
9DFC  11 83 01 00       L9DFC    CMPU  #256                ; IS HORIZ COORD WITHIN RANGE?
9E00  25 03                      BLO   L9E05               ; YES
9E02  CE 00 FF                   LDU   #255                ; NO - FORCE TO MAX VALUE
9E05  8C 00 C0          L9E05    CMPX  #192                ; IS VERT COORD WITHIN RANGE?
9E08  25 03                      BLO   L9E0D               ; YES
9E0A  8E 00 BF                   LDX   #191                ; NO - FORCE TO MAX VALUE
9E0D  DC C7             L9E0D    LDD   HORDEF              ; *
9E0F  DD BD                      STD   HORBEG              ; *
9E11  DC C9                      LDD   VERDEF              ; * COPY THE HOR AND VER POINTERS
9E13  DD BF                      STD   VERBEG              ; * INTO THE DRAW LINE START POSITION
9E15  9F C5                      STX   VEREND              ; =
9E17  DF C3                      STU   HOREND              ; = SET THE DRAW LINE END POSITION
9E19  0D D5                      TST   VD5                 ; CHECK UPDATE FLAG
9E1B  26 04                      BNE   L9E21               ; BRANCH IF NO UPDATE
9E1D  9F C9                      STX   VERDEF              ; *
9E1F  DF C7                      STU   HORDEF              ; * UPDATE POSITION OF DRAW POINTER
9E21  BD 94 20          L9E21    JSR   L9420               ; NORMALIZE COORDS IN HOREND, VEREND AND HORBEG,VERBEG
9E24  0D D6                      TST   VD6                 ; GET DRAW FLAG
9E26  26 03                      BNE   L9E2B               ; BRANCH IF NO DRAW
9E28  BD 94 A1                   JSR   L94A1               ; DRAW A LINE FROM (HORBEG,VERBEG) TO (HOREND,VEREND)
9E2B  0F D5             L9E2B    CLR   VD5                 ; RESET UPDATE FLAG
9E2D  0F D6                      CLR   VD6                 ; RESET DRAW FLAG
9E2F  7E 9C DD                   JMP   L9CDD               ; GO GET ANOTHER COMMAND

* SET THE DRAW POSITION
9E32  BD 9B 98          L9E32    JSR   L9B98               ; GET A CHAR FROM COMMAND LINE
9E35  34 02                      PSHS  A                   ; SAVE CHARACTER
9E37  BD 9E 5E                   JSR   >L9E5E              ; EVALUATE HORIZ DIFFERENCE
9E3A  34 06                      PSHS  B,A                 ; SAVE IT ON STACK
9E3C  BD 9B 98                   JSR   L9B98               ; GET A CHAR FROM COMMAND LINE
9E3F  81 2C                      CMPA  #','                ; CHECK FOR COMMA
9E41  10 26 FF 07                LBNE  L9D4C               ; 'FC' ERROR IF NO COMMA
9E45  BD 9E 5B                   JSR   >L9E5B              ; EVALUATE VERT DIFFERENCE
9E48  1F 01                      TFR   D,X                 ; SAVE VERT DIFFERENCE IN X
9E4A  35 40                      PULS  U                   ; GET HORIZ DIFFERENCE IN U
9E4C  35 02                      PULS  A                   ; GET FIRST COMMAND CHARACTER
9E4E  81 2B                      CMPA  #'+'                ; *IF FIRST COMMAND CHAR WAS EITHER + OR -, TREAT
9E50  27 04                      BEQ   L9E56               ; *THE VALUES IN U & X AS DIFFERENCES AND MOVE
9E52  81 2D                      CMPA  #'-'                ; *POINTER, OTHERWISE TREAT U & X AS AN ABSOLUTE
9E54  26 A6                      BNE   L9DFC               ; *POSITION AND MOVE THE CURRENT POSITION THERE.
9E56  1F 30             L9E56    TFR   U,D                 ; PUT HORIZ DIFFERENCE IN ACCD
9E58  7E 9D CB                   JMP   L9DCB               ; GO MOVE THE DRAW POSITION

9E5B  BD 9B 98          L9E5B    JSR   L9B98               ; GET A CHAR FROM COMMAND LINE
9E5E  81 2B             L9E5E    CMPA  #'+'                ; *CHECK FOR A LEADING PLUS SIGN (RELATIVE MOTION)
9E60  27 07                      BEQ   L9E69               ; *AND BRANCH IF RELATIVE
9E62  81 2D                      CMPA  #'-'                ; =CHECK FOR A LEADING MINUS SIGN (RELATIVE MOTION)
9E64  27 04                      BEQ   L9E6A               ; =AND BRANCH IF RELATIVE
9E66  BD 9B E2                   JSR   L9BE2               ; MOVE COMMAND STRING BACK ONE IF NOT RELATIVE MOTION
9E69  4F                L9E69    CLRA                      ; ACCA = 0 IS '+'; ACCA <> 0 IS '-'
9E6A  34 02             L9E6A    PSHS  A                   ; SAVE ADD/SUB FLAG
9E6C  BD 9C CB                   JSR   L9CCB               ; EVALUATE DECIMAL NUMBER IN COMMAND STRING - RETURN VALUE IN ACCB
*
9E6F  35 02                      PULS  A                   ; GET ADD/SUB FLAG
9E71  4D                         TSTA                      ; CHECK IT, 0:ADD, <> 0:SUB
9E72  27 04                      BEQ   L9E78               ; RETURN IF ADD
9E74  4F                         CLRA                      ; *
9E75  50                         NEGB                      ; *
9E76  82 00                      SBCA  #$00                ; *NEGATE ACCB INTO A TWO BYTE SIGNED VALUE IN ACCD
9E78  39                L9E78    RTS
*
* TABLE OF SINES AND COSINES FOR CIRCLE
*
9E79  00 00 00 01       L9E79    FDB   $0000,$0001         ; SUBARC 0
9E7D  FE C5 19 19       L9E7D    FDB   $FEC5,$1919         ; SUBARC 1
9E81  FB 16 31 F2       L9E81    FDB   $FB16,$31F2         ; SUBARC 2
9E85  F4 FB 4A 51       L9E85    FDB   $F4FB,$4A51         ; SUBARC 3
9E89  EC 84 61 F9       L9E89    FDB   $EC84,$61F9         ; SUBARC 4
9E8D  E1 C7 78 AE       L9E8D    FDB   $E1C7,$78AE         ; SUBARC 5
9E91  D4 DC 8E 3B       L9E91    FDB   $D4DC,$8E3B         ; SUBARC 6
9E95  C5 E5 A2 69       L9E95    FDB   $C5E5,$A269         ; SUBARC 7
9E99  B5 06 B5 06       L9E99    FDB   $B506,$B506         ; SUBARC 8
