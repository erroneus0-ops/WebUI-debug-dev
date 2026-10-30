; Super Extended Color BASIC 2.0 (CoCo 3) -- $F4CC-$F6AC
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: NEGACCD=$F4CC, WIDTH=$F636, COL32=$F652, COL40=$F65C, COL80=$F679

* NEGATE ACCD
F4CC  40                NEGACCD  NEGA
F4CD  50                         NEGB
F4CE  82 00                      SBCA  #$00                ; NEGATE ACCD
F4D0  39                LF4D0    RTS
F4D1  1F 10             LF4D1    TFR   X,D                 ; TRANSFER UNCHANGED DIFFERENCE TO ACCD
F4D3  39                         RTS

* MOVE THE DRAW POSITION - ADD THE ORTHOGONAL DIFFERENCES IN ACCD (HORIZONTAL)
* AND X (VERTICAL) TO THE CURRENT POSITION; DRAW A LINE AFTER THE MOVE
F4D4  34 06             LF4D4    PSHS  B,A                 ; SAVE THE HORIZONTAL DIFFERENCE
F4D6  8D DA                      BSR   LF4B2               ; APPLY SCALE FACTOR TO VERTICAL
F4D8  35 10                      PULS  X                   ; GET HORIZONTAL DIFFERENCE
F4DA  34 06                      PSHS  B,A                 ; SAVE THE VERTICAL DIFFERENCE
F4DC  8D D4                      BSR   LF4B2               ; APPLY THE SCALE FACTOR TO HORIZONTAL
F4DE  35 10                      PULS  X                   ; GET THE VERTICAL DIFFERENCE
F4E0  10 9E E8                   LDY   ANGLE               ; GET DRAW ANGLE AND SCALE
F4E3  34 20                      PSHS  Y                   ; SAVE THEM ON THE STACK
F4E5  6D E4             LF4E5    TST   ,S                  ; CHECK DRAW ANGLE
F4E7  27 08                      BEQ   LF4F1               ; BRANCH IF NO ANGLE
F4E9  1E 10                      EXG   X,D                 ; SWAP HORIZONTAL AND VERTICAL DIFFERENCES
F4EB  8D DF                      BSR   NEGACCD             ; NEGATE ACCD
F4ED  6A E4                      DEC   ,S                  ; DECR ANGLE
F4EF  20 F4                      BRA   LF4E5               ; CHECK ANGLE AGAIN
F4F1  35 20             LF4F1    PULS  Y                   ; PULL ANGLE AND SCALE OFF OF THE STACK
F4F3  CE 00 00                   LDU   #0                  ; DEFAULT HORIZONTAL END POSITION TO 0
F4F6  D3 C7                      ADDD  HORDEF              ; ADD DIFFERENCE TO HORIZONTAL START
F4F8  2B 02                      BMI   LF4FC               ; GO FORCE HORIZONTAL COORD TO 0 IF RESULT IS NEGATIVE
F4FA  1F 03                      TFR   D,U                 ; SAVE HORIZONTAL END POSITION IN U
F4FC  1F 10             LF4FC    TFR   X,D                 ; PUT DIFFERENCE IN ACCD
F4FE  8E 00 00                   LDX   #0                  ; DEFAULT THE VERTICAL END POSITION TO 0
F501  D3 C9                      ADDD  VERDEF              ; ADD THE DIFFERENCE TO VERTICAL START
F503  2B 02                      BMI   LF507               ; VERTICAL COORD = 0 IF RESULT IS NEGATIVE
F505  1F 01                      TFR   D,X                 ; SAVE VERTICAL POSITION IN X
* MOVE THE DRAW POSITION; ENTER WITH ABSOLUTE HORIZONTAL POSITION
* IN U REGISTER AND ABSOULTE VERTICAL POSITION IN X REGISTER.
F507  11 83 02 80       LF507    CMPU  #640                ; COMPARE TO MAX HORIZONTAL COORDINATE
F50B  25 03                      BCS   LF510               ; BRANCH IF WITHIN RANGE
F50D  CE 02 7F                   LDU   #640-1              ; FORCE MAXIMUM VALUE IF NOT
F510  96 E6             LF510    LDA   HRMODE              ; GET HI-RES GRAPHICS MODE
F512  81 02                      CMPA  #$02                ; SEE WHICH ONE
F514  2E 09                      BGT   LF51F               ; BRANCH IF MODE 3 OR 4
F516  11 83 01 40                CMPU  #320                ; MAX HORIZONTAL COORD FOR 320x192 MODES (1 AND 2)
F51A  25 03                      BCS   LF51F               ; BRANCH IF WITHIN LIMITS
F51C  CE 01 3F                   LDU   #320-1              ; FORCE TO MAXIMUM IF NOT
F51F  8C 00 C0          LF51F    CMPX  #192                ; IS VERTICAL COORD WITHIN RANGE?
F522  25 03                      BCS   LF527               ; BRANCH IF IT IS
F524  8E 00 BF                   LDX   #192-1              ; FORCE TO MAXIMUM IF NOT
F527  DC C7             LF527    LDD   HORDEF              ; GET LAST HORIZONTAL POSITION
F529  DD BD                      STD   HORBEG              ; MAKE IT THE HORIZONTAL START
F52B  DC C9                      LDD   VERDEF              ; GET LAST VERTICAL POSITION
F52D  DD BF                      STD   VERBEG              ; MAKE IT THE VERTICAL START
F52F  9F C5                      STX   VEREND              ; SAVE VERTICAL END COORD
F531  DF C3                      STU   HOREND              ; SAVE HORIZONTAL END COORDINATE
F533  0D D5                      TST   VD5                 ; CHECK UPDATE FLAG
F535  26 04                      BNE   LF53B               ; BRANCH IF NO UPDATE
F537  9F C9                      STX   VERDEF              ; UPDATE VERTICAL POSITION OF DRAW POINTER
F539  DF C7                      STU   HORDEF              ; DO THE SAME WITH THE HORIZONTAL DRAW POINTER
F53B  BD EA 0D          LF53B    JSR   LEA0D               ; NORMALIZE COORDS IN HOREND,VEREND AND HORBEG,VERBEG
F53E  0D D6                      TST   VD6                 ; CHECK DRAW FLAG
F540  26 03                      BNE   LF545               ; BRANCH IF NO DRAW
F542  BD E9 4E                   JSR   LE94E               ; DRAWLINE FROM (HORBEG,VERBEG) TO (HOREND,VEREND)
F545  0F D5             LF545    CLR   VD5                 ; RESET UPDATE FLAG
F547  0F D6                      CLR   VD6                 ; RESET DRAW FLAG
F549  7E F3 CF                   JMP   LF3CF               ; GO GET ANOTHER COMMAND

* SET THE DRAW POSITION
F54C  BD F5 91          LF54C    JSR   LF591               ; GET A CHAR FROM COMMAND LINE
F54F  34 02                      PSHS  A                   ; SAVE IT
F551  BD F5 78                   JSR   LF578               ; EVALUATE THE HORIZONTAL DIFFERENCE
F554  34 06                      PSHS  B,A                 ; SAVE IT ON THE STACK
F556  BD F5 91                   JSR   LF591               ; GET A CHAR FROM COMMAND LINE
F559  81 2C                      CMPA  #','                ; CHECK FOR COMMA
F55B  10 26 BE EB                LBNE  ILLFUNC             ; ILLEGAL FUCNTION CALL ERROR IF NO COMMA
F55F  BD F5 75                   JSR   LF575               ; EVALUATE THE VERTICAL DIFFERENCE
F562  1F 01                      TFR   D,X                 ; SAVE VERTICAL DIFFERENCE IN X
F564  35 40                      PULS  U                   ; GET HORIZONTAL DIFFERENCE IN U
F566  35 02                      PULS  A                   ; GET FIRST COMMAND CHARACTER
F568  81 2B                      CMPA  #'+'                ; CHECK FOR PLUS
F56A  27 04                      BEQ   LF570               ; TREAT VALUES IN X AND U AS DIFFERENCES AND MOVE POINTER
F56C  81 2D                      CMPA  #'-'                ; CHECK FOR MINUS
F56E  26 97                      BNE   LF507               ; IF NOT '+' OR '-', MOVE THE POINTER TO THE COORDINATES IN U AND ACCD
F570  1F 30             LF570    TFR   U,D                 ; PUT HORIZONTAL DIFFERENCE IN ACCD; X CONTAINS THE VERTICAL DIFFERENCE
F572  7E F4 D4                   JMP   LF4D4               ; GOMOVE THE DRAW POSITION
F575  BD F5 91          LF575    JSR   LF591               ; GET A CHAR FROM COMMAND LINE
F578  81 2B             LF578    CMPA  #'+'                ; CHECK FOR LEADING + (RELATIVE MOTION)
F57A  27 07                      BEQ   LF583               ; BRANCH IF RELATIVE
F57C  81 2D                      CMPA  #'-'                ; DO THE SAME FOR THE MINUS SIGN
F57E  27 04                      BEQ   LF584               ; BRANCH IF RELATIVE
F580  BD F5 F2                   JSR   LF5F2               ; MOVE COMMAND STRING BACK ONE IF NOT RELATIVE MOTION
F583  4F                LF583    CLRA                      ; IF ACCA=0, THEN '+'; IF ACCA <> 0, THEN '-'
F584  34 02             LF584    PSHS  A                   ; SAVE ADD/SUB FLAG; 0=ADD, <> 0 = SUBTRACT
F586  BD F3 BD                   JSR   LF3BD               ; EVALUATE DECIMAL NUMBER IN COMMAND STRING - RETURN VALUE IN ACCD
F589  6D E0                      TST   ,S+                 ; CHECK THE ADD/SUBTRACT FLAG AND CLEAN UP THE STACK
F58B  27 03                      BEQ   LF590               ; BRANCH IF ADD
* THIS IS A BUG; SHOULD BE JSR NEGACCD INSTEAD OF THE NEXT TWO INSTRUCTIONS
F58D  50                         NEGB
F58E  82 00                      SBCA  #$00
F590  39                LF590    RTS

* GET NEXT COMMAND - RETURN VALUE IN ACCA
F591  34 10             LF591    PSHS  X                   ; SAVE X REGISTER
F593  0D D8             LF593    TST   VD8                 ; CHECK COMMAND COUNTER
F595  10 27 BE B1                LBEQ  ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR IF NO COMMAND DATA LEFT
F599  9E D9                      LDX   VD9                 ; GET COMMAND ADDRESS
F59B  A6 80                      LDA   ,X+                 ; GET COMMAND
F59D  9F D9                      STX   VD9                 ; SAVE NEW COMMAND ADDRESS
F59F  0A D8                      DEC   VD8                 ; DECREMENT COMMAND COUNTER
F5A1  81 20                      CMPA  #SPACE              ; CHECK FOR BLANK
F5A3  27 EE                      BEQ   LF593               ; IGNORE BLANKS
F5A5  35 90                      PULS  X,PC                ; RESTORE X REGISTER AND RETURN

F5A7  81 3D             LF5A7    CMPA  #'='                ; CHECK FOR A VARIABLE EQUATE
F5A9  26 0B                      BNE   LF5B6               ; BRANCH IF NOT VARIABLE EQUATE
F5AB  34 60                      PSHS  U,Y                 ; SAVE REGISTERS
F5AD  8D 62                      BSR   LF611               ; INTERPRET THE VARIABLE IN THE COMMAND LINE
F5AF  BD B3 E9                   JSR   LB3E9               ; CONVERT VARIABLE INTO A POSITIVE INTEGER IN ACCD
F5B2  DD D3                      STD   VD3                 ; SAVE THE SUBCOMMAND VALUE
F5B4  35 E0                      PULS  Y,U,PC              ; RESTORE REGISTERS AND RETURN
F5B6  BD F6 08          LF5B6    JSR   LF608               ; CLEAR CARRY IF NUMERIC
F5B9  10 25 BE 8D                LBCS  ILLFUNC             ; ILLEGAL FUNCTION CALL IF NOT NUMERIC
F5BD  0F D3                      CLR   VD3                 ; *
F5BF  0F D4                      CLR   VD4                 ; * INITIALIZE THE SUBCOMMAND VALUE TO ZERO
* STRIP A DECIMAL ASCII VALUE FROM THE COMMAND STRING AND RETURN THE BINARY VALUE IN VD3
F5C1  80 30             LF5C1    SUBA  #'0'                ; MASK OFF ASCII
F5C3  97 D7                      STA   VD7                 ; SAVE TEMPORARILY
F5C5  DC D3                      LDD   VD3                 ; GET THE CURRENT SUBCOMMAND VALUE
F5C7  8D 34                      BSR   LF5FD               ; MULTIPLY ACCD BY 10
F5C9  DB D7                      ADDB  VD7                 ; ADD THE CURRENT DIGIT
F5CB  89 00                      ADCA  #$00                ; PROPAGATE THE CARRY
F5CD  DD D3                      STD   VD3                 ; SAVE THE NEW SUBCOMMAND VALUE
F5CF  96 E6                      LDA   HRMODE              ; GET THE HI-RES GRAPHICS MODE
F5D1  81 02                      CMPA  #$02                ; IS IT A 640 OR 320 BYTES/PIXEL ROW MODE?
F5D3  2E 05                      BGT   LF5DA               ; BRANCH IF 640 PIXELS/HORIZONTAL ROW MODE
F5D5  CC 01 3F                   LDD   #320-1              ; MAXIMUM HORIZONTAL PIXELS IN THE 320 PIXEL MODE
F5D8  20 03                      BRA   LF5DD
F5DA  CC 02 7F          LF5DA    LDD   #640-1              ; MAXIMUM HORIZONTAL PIXELS IN THE 640 PIXEL MODE
F5DD  10 93 D3          LF5DD    CMPD  VD3                 ; COMPARE THE SUBCOMMAND TO THE MAXIMUM PERMISSABLE
F5E0  10 2D BE 66                LBLT  ILLFUNC             ; ILLEGAL FUNCTION CALL IF SUBCOMMAND TOO BIG
F5E4  DC D3                      LDD   VD3                 ; THIS INSTRUCTION IS USELESS
F5E6  0D D8                      TST   VD8                 ; CHECK THE COMMAND COUNTER
F5E8  27 10                      BEQ   LF5FA               ; BRANCH IF NO COMMANDS LEFT
F5EA  BD F5 91                   JSR   LF591               ; GET ANOTHER COMMAND
F5ED  BD F6 08                   JSR   LF608               ; CLEAR CARRY IF NUMERIC
F5F0  24 CF                      BCC   LF5C1               ; BRANCH IF MORE NUMERIC DATA TO CONVERT
F5F2  0C D8             LF5F2    INC   VD8                 ; ADD ONE TO THE COMMAND COUNTER
F5F4  9E D9                      LDX   VD9                 ; *
F5F6  30 1F                      LEAX  $-01,X              ; *
F5F8  9F D9                      STX   VD9                 ; * MOVE THE COMMAND STRING BACK ONE
F5FA  DC D3             LF5FA    LDD   VD3                 ; LOAD ACCD WITH THE VALUE OF THE SUBCOMMAND
F5FC  39                         RTS

* MULTIPLY ACCD BY TEN
F5FD  58                LF5FD    ALSB
F5FE  49                         ROLA                      ; MULTIPLY ACCD BY 2
F5FF  34 06                      PSHS  B,A                 ; SAVE ACCD TIME 2
F601  58                         ALSB
F602  49                         ROLA
F603  58                         ALSB
F604  49                         ROLA                      ; NOW ACCD = ACCD * 8
F605  E3 E1                      ADDD  ,S++                ; ADD ACCD*2; THE RESULT IS NOW ACCD*10
F607  39                         RTS

* CLEAR THE CARRY FLAG IF ACCA CONTAINS A NUMERIC ASCII VALUE ($30-$39)
F608  81 30             LF608    CMPA  #'0'
F60A  25 04                      BCS   LF610               ; RETURN IF LESS THAN ASCII ZERO
F60C  80 3A                      SUBA  #'9'+1
F60E  80 C6                      SUBA  #-('9'+1)           ; SET CARRY IF NOT 0-9
F610  39                LF610    RTS
* INTERPRET THE CURRENT COMMAND STRING AS IF IT WERE A BASIC VARIABLE
F611  9E D9             LF611    LDX   VD9                 ; GET THE COMMAND POINTER
F613  34 10                      PSHS  X                   ; SAVE IT
F615  BD F5 91                   JSR   LF591               ; GET A COMMAND STRING CHARACTER
F618  BD B3 A2                   JSR   LB3A2               ; SET CARRY IF NOT UPPER CASE ALPHA
F61B  10 25 BE 2B                LBCS  ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR IF NOT ALPHA - ILLEGAL VARIABLE NAME
F61F  BD F5 91          LF61F    JSR   LF591               ; GET COMMAND STRING CHARACTER
F622  81 3B                      CMPA  #';'                ; CHECK FOR A SEMICOLON (SUBCOMMAND SEPARATOR)
F624  26 F9                      BNE   LF61F               ; LOOP UNTIL SEMICOLON FOUND
F626  35 10                      PULS  X                   ; GET THE START OF THE VARIABLE NAME
F628  DE A6                      LDU   CHARAD              ; GET THE CURRENT ADDRESS OF THE VARIABLE NAME
F62A  34 40                      PSHS  U                   ; SAVE IT
F62C  9F A6                      STX   CHARAD              ; PUT THE COMMAND POINTER IN PLACE OF BASIC'S INPUT POINTER
F62E  BD B2 84                   JSR   LB284               ; EVALUATE AN ALPHA EXPRESSION
F631  35 10                      PULS  X                   ; GET BASIC'S POINTER BACK
F633  9F A6                      STX   CHARAD              ; RESTORE BASIC'S INPUT POINTER
F635  39                         RTS

* WIDTH
F636  0F E6             WIDTH    CLR   HRMODE              ; TURN OFF HI-RES GRAPHICS MODE
F638  10 21 09 C4                LBRN  RAMLINK             ; RAM HOOK
F63C  81 00                      CMPA  #$00                ; TEST FOR END OF LINE - NO ARGUMENT GIVEN
F63E  27 0F                      BEQ   LF64F               ; 'FC' ERROR IF NO ARGUMENT
F640  BD B7 0B                   JSR   EVALEXPB            ; EVALUATE EXPRESSION, RETURN VALUE IN ACCB
F643  C1 20                      CMPB  #32                 ; 32 COLUMNS
F645  27 0B                      BEQ   COL32
F647  C1 28                      CMPB  #40                 ; 40 COLUMNS
F649  27 11                      BEQ   COL40
F64B  C1 50                      CMPB  #80                 ; 80 COLUMNS
F64D  27 2A                      BEQ   COL80
F64F  7E B4 4A          LF64F    JMP   ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR

* 32 COLUMNS
F652  4F                COL32    CLRA                      ; 32 COLUMN MODE FLAG
F653  97 E7                      STA   HRWIDTH             ; SAVE THE HI-RES TEXT MODE
F655  BD A9 28                   JSR   LA928               ; CLEAR THE 32 COLUMN SCREEN
F658  17 E9 BE                   LBSR  SETTEXT             ; SETUP THE VIDEO MODE REGISTERS
F65B  39                         RTS

* 40 COLUMNS
F65C  86 01             COL40    LDA   #$01                ; 40 COLUMN MODE FLAG
F65E  97 E7                      STA   HRWIDTH             ; SAVE THE HI-RES TEXT MODE
F660  17 01 0F                   LBSR  LF772               ; PUT THE HI-RES TEXT SCREEN INTO THE LOGICAL ADDRESS SPACE
F663  86 28                      LDA   #40                 ; 40 COLUMNS
F665  C6 18                      LDB   #ROWMAX             ; MAXIMUM NUMBER OF ROWS
F667  FD FE 04                   STD   H.COLUMN            ; SAVE THE NUMBER OF COLUMNS AND ROWS
F66A  CC 27 80                   LDD   #HRSCREEN+40*ROWMAX*2 ; END OF THE HI-RES TEXT SCREEN

F66D  FD FE 06          LF66D    STD   H.DISPEN            ; SAVE THE END OF THE HI-RES TEXT SCREEN
F670  8D 1A                      BSR   LF68C               ; RESET HI-RES TEXT SCREEN
F672  17 01 03                   LBSR  LF778               ; PUT BLOCK 7.1 INTO LOGICAL BLOCK 1
F675  17 E9 A1                   LBSR  SETTEXT             ; SETUP THE VIDEO MODE REGISTERS
F678  39                         RTS

* 80 COLUMNS
F679  86 02             COL80    LDA   #$02                ; 80 COLUMN MODE FLAG
F67B  97 E7                      STA   HRWIDTH             ; SAVE THE HI-RES TEXT MODE
F67D  17 00 F2                   LBSR  LF772               ; PUT THE HI-RES TEXT SCREEN INTO THE LOGICAL ADDRESS SPACE
F680  86 50                      LDA   #80                 ; 80 COLUMNS
F682  C6 18                      LDB   #ROWMAX             ; MAXIMUM NUMBER OF ROWS
F684  FD FE 04                   STD   H.COLUMN            ; SAVE THE NUMBER OF COLUMNS AND ROWS
F687  CC 2F 00                   LDD   #HRSCREEN+80*ROWMAX*2 ; END OF THE HI-RES TEXT SCREEN
F68A  20 E1                      BRA   LF66D

F68C  8E 20 00          LF68C    LDX   #HRESSCRN           ; POINT X TO THE TOP OF THE HI-RES TEXT SCREEN
F68F  10 21 09 6D                LBRN  RAMLINK             ; RAM HOOK
F693  BF FE 00                   STX   H.CRSLOC            ; SAVE THE START OF THE HI-RES TEXT SCREEN
F696  86 20                      LDA   #SPACE              ; INITIALIZE CHARACTERS TO SPACES
F698  F6 FE 08                   LDB   H.CRSATT            ; GET THE CHARACTER ATTRIBUTES
F69B  ED 81             LF69B    STD   ,X++                ; SAVE THE CHARACTER AND ATTRIBUTES IN HI-RES TEXT SCREEN
F69D  BC FE 06                   CMPX  H.DISPEN            ; COMPARE TO THE END OF HI-RES TEXT SCREEN
F6A0  25 F9                      BCS   LF69B               ; LOOP UNTIL ALL MEMORY INITIALIZED
F6A2  8E 20 00                   LDX   #HRESSCRN           ; RESET X TO THE TOP OF THE SCREEN
F6A5  4F                         CLRA
F6A6  B7 FE 02                   STA   H.CURSX             ; SET THE CURSOR X COORDINATE (COLUMN) TO ZERO
F6A9  B7 FE 03                   STA   H.CURSY             ; SET THE CURSOR Y COORDIANTE (ROW) TO ZERO
F6AC  39                         RTS
