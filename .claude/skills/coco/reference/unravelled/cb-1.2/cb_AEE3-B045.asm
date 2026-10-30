; Color BASIC 1.2 -- $AEE3-$B045
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: REM=$AEE3, IF=$AF14, ON=$AF42, LET=$AF89, INPUT=$AFF5

AEE3  8D 06             REM      BSR   LAEEB               ; MOVE INPUT POINTER TO END OF LINE
AEE5  9F A6                      STX   CHARAD              ; RESET BASIC'S INPUT POINTER
AEE7  39                LAEE7    RTS
* ADVANCE INPUT POINTER TO END OF SUBLINE OR LINE
AEE8  C6 3A             LAEE8    LDB   #':                 ; COLON = SUBLINE TERMINATOR CHARACTER
AEEA  86                LAEEA    FCB   SKP1LD              ; SKPILD SKIP ONE BYTE; LDA #$5F
* ADVANCE BASIC'S INPUT POINTER TO END OF
* LINE - RETURN ADDRESS OF END OF LINE+1 IN X
AEEB  5F                LAEEB    CLRB                      ; 0 = LINE TERMINATOR CHARACTER
AEEC  D7 01                      STB   CHARAC              ; TEMP STORE PRIMARY TERMINATOR CHARACTER
AEEE  5F                         CLRB                      ; 0 (END OF LINE) = ALTERNATE TERM. CHAR.
AEEF  9E A6                      LDX   CHARAD              ; LOAD X W/BASIC'S INPUT POINTER
AEF1  1F 98             LAEF1    TFR   B,A                 ; * CHANGE TERMINATOR CHARACTER
AEF3  D6 01                      LDB   CHARAC              ; * FROM ACCB TO CHARAC - SAVE OLD TERMINATOR
* IN CHARAC
AEF5  97 01                      STA   CHARAC              ; SWAP PRIMARY AND SECONDARY TERMINATORS
AEF7  A6 84             LAEF7    LDA   ,X                  ; GET NEXT INPUT CHARACTER
AEF9  27 EC                      BEQ   LAEE7               ; RETURN IF 0 (END OF LINE)
AEFB  34 04                      PSHS  B                   ; SAVE TERMINATOR ON STACK
AEFD  A1 E0                      CMPA  ,S+                 ; COMPARE TO INPUT CHARACTER
AEFF  27 E6                      BEQ   LAEE7               ; RETURN IF EQUAL
AF01  30 01                      LEAX  1,X                 ; MOVE POINTER UP ONE
AF03  81 22                      CMPA  #'"                 ; CHECK FOR DOUBLE QUOTES
AF05  27 EA                      BEQ   LAEF1               ; BRANCH IF " - TOGGLE TERMINATOR CHARACTERS
AF07  4C                         INCA                      ; * CHECK FOR $FF AND BRANCH IF
AF08  26 02                      BNE   LAF0C               ; * NOT SECONDARY TOKEN
AF0A  30 01                      LEAX  1,X                 ; MOVE INPUT POINTER 1 MORE IF SECONDARY
AF0C  81 86             LAF0C    CMPA  #$85+1              ; TOKEN FOR IF?
AF0E  26 E7                      BNE   LAEF7               ; NO - GET ANOTHER INPUT CHARACTER
AF10  0C 04                      INC   IFCTR               ; INCREMENT IF COUNTER - KEEP TRACK OF HOW MANY
* 'IF' STATEMENTS ARE NESTED IN ONE LINE
AF12  20 E3                      BRA   LAEF7               ; GET ANOTHER INPUT CHARACTER

* IF
AF14  BD B1 41          IF       JSR   LB141               ; EVALUATE NUMERIC EXPRESSION
AF17  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
AF19  81 81                      CMPA  #$81                ; TOKEN FOR GO
AF1B  27 05                      BEQ   LAF22               ; TREAT 'GO' THE SAME AS 'THEN'
AF1D  C6 A7                      LDB   #$A7                ; TOKEN FOR THEN
AF1F  BD B2 6F                   JSR   LB26F               ; DO A SYNTAX CHECK ON ACCB
AF22  96 4F             LAF22    LDA   FP0EXP              ; CHECK FOR TRUE/FALSE - FALSE IF FPA0 EXPONENT = ZERO
AF24  26 13                      BNE   LAF39               ; BRANCH IF CONDITION TRUE
AF26  0F 04                      CLR   IFCTR               ; CLEAR FLAG - KEEP TRACK OF WHICH NESTED ELSE STATEMENT
* TO SEARCH FOR IN NESTED 'IF' LOOPS
AF28  8D B6             LAF28    BSR   DATA                ; MOVE BASIC'S POINTER TO END OF SUBLINE
AF2A  4D                         TSTA                      ; * CHECK TO SEE IF END OF LINE OR SUBLINE
AF2B  27 BA                      BEQ   LAEE7               ; * AND RETURN IF END OF LINE
AF2D  9D 9F                      JSR   GETNCH              ; GET AN INPUT CHARACTER FROM BASIC
AF2F  81 84                      CMPA  #$84                ; TOKEN FOR ELSE
AF31  26 F5                      BNE   LAF28               ; IGNORE ALL DATA EXCEPT 'ELSE' UNTIL
* END OF LINE (ZERO BYTE)
AF33  0A 04                      DEC   IFCTR               ; CHECK TO SEE IF YOU MUST SEARCH ANOTHER SUBLINE
AF35  2A F1                      BPL   LAF28               ; BRANCH TO SEARCH ANOTHER SUBLINE FOR 'ELSE'
AF37  9D 9F                      JSR   GETNCH              ; GET AN INPUT CHARACTER FROM BASIC
AF39  9D A5             LAF39    JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
AF3B  10 25 FF 65                LBCS  LAEA4               ; BRANCH TO 'GOTO' IF NUMERIC CHARACTER
AF3F  7E AD C6                   JMP   LADC6               ; RETURN TO MAIN INTERPRETATION LOOP

* ON
AF42  BD B7 0B          ON       JSR   LB70B               ; EVALUATE EXPRESSION
AF45  C6 81                      LDB   #$81                ; TOKEN FOR GO
AF47  BD B2 6F                   JSR   LB26F               ; SYNTAX CHECK FOR GO
AF4A  34 02                      PSHS  A                   ; SAVE NEW TOKEN (TO,SUB)
AF4C  81 A6                      CMPA  #$A6                ; TOKEN FOR SUB?
AF4E  27 04                      BEQ   LAF54               ; YES
AF50  81 A5                      CMPA  #$A5                ; TOKEN FOR TO?
AF52  26 83             LAF52    BNE   LAED7               ; 'SYNTAX' ERROR IF NOT 'SUB' OR 'TO'
AF54  0A 53             LAF54    DEC   FPA0+3              ; DECREMENT IS BYTE OF MANTISSA OF FPA0 - THIS
* IS THE ARGUMENT OF THE 'ON' STATEMENT
AF56  26 05                      BNE   LAF5D               ; BRANCH IF NOT AT THE PROPER GOTO OR GOSUB LINE NUMBER
AF58  35 04                      PULS  B                   ; GET BACK THE TOKEN FOLLOWING 'GO'
AF5A  7E AE 88                   JMP   LAE88               ; GO DO A 'GOTO' OR 'GOSUB'
AF5D  9D 9F             LAF5D    JSR   GETNCH              ; GET A CHARACTER FROM BASIC
AF5F  8D 06                      BSR   LAF67               ; CONVERT BASIC LINE NUMBER TO BINARY
AF61  81 2C                      CMPA  #',                 ; IS CHARACTER FOLLOWING LINE NUMBER A COMMA?
AF63  27 EF                      BEQ   LAF54               ; YES
AF65  35 84                      PULS  B,PC                ; IF NOT, FALL THROUGH TO NEXT COMMAND
AF67  9E 8A             LAF67    LDX   ZERO                ; DEFAULT LINE NUMBER OF ZERO
AF69  9F 2B                      STX   BINVAL              ; SAVE IT IN BINVAL
*
* CONVERT LINE NUMBER TO BINARY - RETURN VALUE IN BINVAL
*
AF6B  24 61             LAF6B    BCC   LAFCE               ; RETURN IF NOT NUMERIC CHARACTER
AF6D  80 30                      SUBA  #'0                 ; MASK OFF ASCII
AF6F  97 01                      STA   CHARAC              ; SAVE DIGIT IN VO1
AF71  DC 2B                      LDD   BINVAL              ; GET ACCUMULATED LINE NUMBER VALUE
AF73  81 18                      CMPA  #24                 ; LARGEST LINE NUMBER IS $F9FF (63999) -
* (24*256+255)*10+9
AF75  22 DB                      BHI   LAF52               ; 'SYNTAX' ERROR IF TOO BIG
* MULT ACCD X 10
AF77  58                         ASLB                      ; *
AF78  49                         ROLA                      ; * TIMES 2
AF79  58                         ASLB                      ; =
AF7A  49                         ROLA                      ; = TIMES 4
AF7B  D3 2B                      ADDD  BINVAL              ; ADD 1 = TIMES 5
AF7D  58                         ASLB                      ; *
AF7E  49                         ROLA                      ; * TIMES 10
AF7F  DB 01                      ADDB  CHARAC              ; ADD NEXT DIGIT
AF81  89 00                      ADCA  #0                  ; PROPAGATE CARRY
AF83  DD 2B                      STD   BINVAL              ; SAVE NEW ACCUMULATED LINE NUMBER
AF85  9D 9F                      JSR   GETNCH              ; GET NEXT CHARACTER FROM BASIC
AF87  20 E2                      BRA   LAF6B               ; LOOP- PROCESS NEXT DIGIT
*
* LET (EXBAS)
* EVALUATE A NON-TOKEN EXPRESSION
* TARGET = REPLACEMENT
AF89  BD B3 57          LET      JSR   LB357               ; FIND TARGET VARIABLE DESCRIPTOR
AF8C  9F 3B                      STX   VARDES              ; SAVE DESCRIPTOR ADDRESS OF 1ST EXPRESSION
AF8E  C6 B3                      LDB   #$B3                ; TOKEN FOR "="
AF90  BD B2 6F                   JSR   LB26F               ; DO A SYNTAX CHECK FOR '='
AF93  96 06                      LDA   VALTYP              ; * GET VARIABLE TYPE AND
AF95  34 02                      PSHS  A                   ; * SAVE ON THE STACK
AF97  BD B1 56                   JSR   LB156               ; EVALUATE EXPRESSION
AF9A  35 02                      PULS  A                   ; * REGET VARIABLE TYPE OF 1ST EXPRESSION AND
AF9C  46                         RORA                      ; * SET CARRY IF STRING
AF9D  BD B1 48                   JSR   LB148               ; TYPE CHECK-TM ERROR IF VARIABLE TYPES ON
* BOTH SIDES OF EQUALS SIGN NOT THE SAME
AFA0  10 27 0C 8F                LBEQ  LBC33               ; GO PUT FPA0 INTO VARIABLE DESCRIPTOR IF NUMERIC
* MOVE A STRING WHOSE DESCRIPTOR IS LOCATED AT
* FPA0+2 INTO THE STRING SPACE. TRANSFER THE
* DESCRIPTOR ADDRESS TO THE ADDRESS IN VARDES
* DON'T MOVE THE STRING IF IT IS ALREADY IN THE
* STRING SPACE. REMOVE DESCRIPTOR FROM STRING
* STACK IF IT IS LAST ONE ON THE STACK
AFA4  9E 52             LAFA4    LDX   FPA0+2              ; POINT X TO DESCRIPTOR OF REPLACEMENT STRING
AFA6  DC 21                      LDD   FRETOP              ; LOAD ACCD WITH START OF STRING SPACE
AFA8  10 A3 02                   CMPD  2,X                 ; IS THE STRING IN STRING SPACE?
AFAB  24 11                      BCC   LAFBE               ; BRANCH IF IT'S NOT IN THE STRING SPACE
AFAD  9C 1B                      CMPX  VARTAB              ; COMPARE DESCRIPTOR ADDRESS TO START OF VARIABLES
AFAF  25 0D                      BCS   LAFBE               ; BRANCH IF DESCRIPTOR ADDRESS NOT IN VARIABLES
AFB1  E6 84             LAFB1    LDB   ,X                  ; GET LENGTH OF REPLACEMENT STRING
AFB3  BD B5 0D                   JSR   LB50D               ; RESERVE ACCB BYTES OF STRING SPACE
AFB6  9E 4D                      LDX   V4D                 ; GET DESCRIPTOR ADDRESS BACK
AFB8  BD B6 43                   JSR   LB643               ; MOVE STRING INTO STRING SPACE
AFBB  8E 00 56                   LDX   #STRDES             ; POINT X TO TEMP STRING DESCRIPTOR ADDRESS
AFBE  9F 4D             LAFBE    STX   V4D                 ; SAVE STRING DESCRIPTOR ADDRESS IN V4D
AFC0  BD B6 75                   JSR   LB675               ; REMOVE STRING DESCRIPTOR IF LAST ONE
* ON STRING STACK
AFC3  DE 4D                      LDU   V4D                 ; POINT U TO REPLACEMENT DESCRIPTOR ADDRESS
AFC5  9E 3B                      LDX   VARDES              ; GET TARGET DESCRIPTOR ADDRESS
AFC7  37 26                      PULU  A,B,Y               ; GET LENGTH AND START OF REPLACEMENT STRING
AFC9  A7 84                      STA   ,X                  ; * SAVE STRING LENGTH AND START IN
AFCB  10 AF 02                   STY   2,X                 ; * TARGET DESCRIPTOR LOCATION
AFCE  39                LAFCE    RTS

AFCF  3F 52 45 44 4F    LAFCF    FCC   '?REDO'             ; ?REDO MESSAGE
AFD4  0D 00                      FCB   CR,$00

AFD6  C6 22             LAFD6    LDB   #2*17               ; 'BAD FILE DATA' ERROR
AFD8  0D 6F                      TST   DEVNUM              ; CHECK DEVICE NUMBER AND BRANCH
AFDA  27 03                      BEQ   LAFDF               ; IF SET TO SCREEN
AFDC  7E AC 46          LAFDC    JMP   LAC46               ; JMP TO ERROR HANDLER
AFDF  96 09             LAFDF    LDA   INPFLG              ; = GET THE INPUT FLAG AND BRANCH
AFE1  27 07                      BEQ   LAFEA               ; = IF 'INPUT'
AFE3  9E 31                      LDX   DATTXT              ; * GET LINE NUMBER WHERE THE ERROR OCCURRED
AFE5  9F 68                      STX   CURLIN              ; * AND USE IT AS THE CURRENT LINE NUMBER
AFE7  7E B2 77                   JMP   LB277               ; 'SYNTAX ERROR'
AFEA  8E AF CE          LAFEA    LDX   #LAFCF-1            ; * POINT X TO '?REDO' AND PRINT
AFED  BD B9 9C                   JSR   LB99C               ; * IT ON THE SCREEN
AFF0  9E 2F                      LDX   TINPTR              ; = GET THE SAVED ABSOLUTE ADDRESS OF
AFF2  9F A6                      STX   CHARAD              ; = INPUT POINTER AND RESTORE IT
AFF4  39                         RTS
*
* INPUT
AFF5  C6 16             INPUT    LDB   #11*2               ; 'ID' ERROR
AFF7  9E 68                      LDX   CURLIN              ; GET CURRENT LINE NUMBER
AFF9  30 01                      LEAX  1,X                 ; ADD ONE
AFFB  27 DF                      BEQ   LAFDC               ; 'ID' ERROR BRANCH IF DIRECT MODE
AFFD  8D 03                      BSR   LB002               ; GET SOME INPUT DATA
AFFF  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
B001  39                         RTS
B002  81 23             LB002    CMPA  #'#                 ; CHECK FOR DEVICE NUMBER
B004  26 09                      BNE   LB00F               ; NO DEVICE NUMBER GIVEN
B006  BD A5 A5                   JSR   LA5A5               ; CHECK SYNTAX AND GET DEVICE NUMBER
B009  BD A3 ED                   JSR   LA3ED               ; CHECK FOR VALID INPUT FILE
B00C  BD B2 6D                   JSR   LB26D               ; SYNTAX CHECK FOR COMMA
B00F  81 22             LB00F    CMPA  #'"                 ; CHECK FOR PROMPT STRING DELIMITER
B011  26 0B                      BNE   LB01E               ; BRANCH IF NO PROMPT STRING
B013  BD B2 44                   JSR   LB244               ; PUT PROMPT STRING ON STRING STACK
B016  C6 3B                      LDB   #';                 ; *
B018  BD B2 6F                   JSR   LB26F               ; * DO A SYNTAX CHECK FOR SEMICOLON
B01B  BD B9 9F                   JSR   LB99F               ; PRINT MESSAGE TO CONSOLE OUT
B01E  8E 02 DC          LB01E    LDX   #LINBUF             ; POINT TO BASIC'S LINE BUFFER
B021  6F 84                      CLR   ,X                  ; CLEAR 1ST BYTE - FLAG TO INDICATE NO DATA
* IN LINE BUFFER
B023  0D 6F                      TST   DEVNUM              ; CHECK DEVICE NUMBER
B025  26 22                      BNE   LB049               ; BRANCH IF NOT SET TO SCREEN
B027  8D 06                      BSR   LB02F               ; INPUT A STRING TO LINE BUFFER
B029  C6 2C                      LDB   #',                 ; * INSERT A COMMA AT THE END
B02B  E7 84                      STB   ,X                  ; * OF THE LINE INPUT BUFFER
B02D  20 1A                      BRA   LB049
* FILL BASIC'S LINE INPUT BUFFER CONSOLE IN
B02F  BD B9 AF          LB02F    JSR   LB9AF               ; SEND A "?" TO CONSOLE OUT
B032  BD B9 AC                   JSR   LB9AC               ; SEND A 'SPACE' TO CONSOLE OUT
B035  BD A3 90          LB035    JSR   LA390               ; GO READ IN A BASIC LINE
B038  24 05                      BCC   LB03F               ; BRANCH IF ENTER KEY ENDED ENTRY
B03A  32 64                      LEAS  4,S                 ; PURGE TWO RETURN ADDRESSES OFF THE STACK
B03C  7E AE 11                   JMP   LAE11               ; GO DO A 'STOP' IF BREAK KEY ENDED LINE ENTRY
B03F  C6 2E             LB03F    LDB   #2*23               ; 'INPUT PAST END OF FILE' ERROR
B041  0D 70                      TST   CINBFL              ; CHECK FOR MORE CHARACTERS IN CONSOLE IN BUFFER
B043  26 97                      BNE   LAFDC               ; 'IE' ERROR IF EMPTY
B045  39                         RTS
