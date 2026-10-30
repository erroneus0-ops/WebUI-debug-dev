; Color BASIC 1.2 -- $AD47-$AEE2
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: FOR=$AD47, RESTOR=$ADE4, END=$AE02, STOP=$AE09, CONT=$AE30, CLEAR=$AE41, RUN=$AE75, GO=$AE86, RETURN=$AEC0, DATA=$AEE0, ELSE=$

* SINCE THE STACK WAS RESET
*
* FOR
*
* THE FOR COMMAND WILL STORE 18 BYTES ON THE STACK FOR
* EACH FOR-NEXT LOOP WHICH IS BEING PROCESSED. THESE
* BYTES ARE DEFINED AS FOLLOWS: 0- $80 (FOR FLAG);
*   1,2=INDEX VARIABLE DESCRIPTOR POINTER; 3-7=FP VALUE OF STEP;
*     8=STEP DIRECTION: $FF IF NEGATIVE; 0 IF ZERO; 1 IF POSITIVE;
*  9-13=FP VALUE OF 'TO' PARAMETER;
* 14,15=CURRENT LINE NUMBER; 16,17=RAM ADDRESS OF THE END
*       OF THE LINE CONTAINING THE 'FOR' STATEMENT
AD47  86 80             FOR      LDA   #$80                ; * SAVE THE DISABLE ARRAY FLAG IN VO8
AD49  97 08                      STA   ARYDIS              ; * DO NOT ALLOW THE INDEX VARIABLE TO BE AN ARRAY
AD4B  BD AF 89                   JSR   LET                 ; SET INDEX VARIABLE TO INITIAL VALUE
AD4E  BD AB F9                   JSR   LABF9               ; SEARCH THE STACK FOR 'FOR/NEXT' DATA
AD51  32 62                      LEAS  2,S                 ; PURGE RETURN ADDRESS OFF OF THE STACK
AD53  26 04                      BNE   LAD59               ; BRANCH IF INDEX VARIABLE NOT ALREADY BEING USED
AD55  9E 0F                      LDX   TEMPTR              ; GET (ADDRESS + 18) OF MATCHED 'FOR/NEXT' DATA
AD57  32 85                      LEAS  B,X                 ; MOVE THE STACK POINTER TO THE BEGINNING OF THE
* MATCHED 'FOR/NEXT' DATA SO THE NEW DATA WILL
* OVERLAY THE OLD DATA. THIS WILL ALSO DESTROY
* ALL OF THE 'RETURN' AND 'FOR/NEXT' DATA BELOW
* THIS POINT ON THE STACK
AD59  C6 09             LAD59    LDB   #$09                ; * CHECK FOR ROOM FOR 18 BYTES
AD5B  BD AC 33                   JSR   LAC33               ; * IN FREE RAM
AD5E  BD AE E8                   JSR   LAEE8               ; GET ADDR OF END OF SUBLINE IN X
AD61  DC 68                      LDD   CURLIN              ; GET CURRENT LINE NUMBER
AD63  34 16                      PSHS  X,B,A               ; SAVE LINE ADDR AND LINE NUMBER ON STACK
AD65  C6 A5                      LDB   #$A5                ; TOKEN FOR 'TO'
AD67  BD B2 6F                   JSR   LB26F               ; SYNTAX CHECK FOR 'TO'
AD6A  BD B1 43                   JSR   LB143               ; 'TM' ERROR IF INDEX VARIABLE SET TO STRING
AD6D  BD B1 41                   JSR   LB141               ; EVALUATE EXPRESSION
*
AD70  D6 54                      LDB   FP0SGN              ; GET FPA0 MANTISSA SIGN
AD72  CA 7F                      ORB   #$7F                ; FORM A MASK TO SAVE DATA BITS OF HIGH ORDER MANTISSA
AD74  D4 50                      ANDB  FPA0                ; PUT THE MANTISSA SIGN IN BIT 7 OF HIGH ORDER MANTISSA
AD76  D7 50                      STB   FPA0                ; SAVE THE PACKED HIGH ORDER MANTISSA
AD78  10 8E AD 7F                LDY   #LAD7F              ; LOAD FOLLOWING ADDRESS INTO Y AS A RETURN
AD7C  7E B1 EA                   JMP   LB1EA               ; ADDRESS - PUSH FPA0 ONTO THE STACK
AD7F  8E BA C5          LAD7F    LDX   #LBAC5              ; POINT X TO FLOATING POINT NUMBER 1.0 (DEFAULT STEP VALUE)
AD82  BD BC 14                   JSR   LBC14               ; MOVE (X) TO FPA0
AD85  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
AD87  81 A9                      CMPA  #$A9                ; STEP TOKEN
AD89  26 05                      BNE   LAD90               ; BRANCH IF NO 'STEP' VALUE
AD8B  9D 9F                      JSR   GETNCH              ; GET A CHARACTER FROM BASIC
AD8D  BD B1 41                   JSR   LB141               ; EVALUATE NUMERIC EXPRESSION
AD90  BD BC 6D          LAD90    JSR   LBC6D               ; CHECK STATUS OF FPA0
AD93  BD B1 E6                   JSR   LB1E6               ; SAVE STATUS AND FPA0 ON THE STACK
AD96  DC 3B                      LDD   VARDES              ; * GET DESCRIPTOR POINTER FOR THE 'STEP'
AD98  34 06                      PSHS  B,A                 ; * VARIABLE AND SAVE IT ON THE STACK
AD9A  86 80                      LDA   #$80                ; = GET THE 'FOR' FLAG AND
AD9C  34 02                      PSHS  A                   ; = SAVE IT ON THE STACK
*
* MAIN COMMAND INTERPRETATION LOOP
AD9E  BD 01 9A          LAD9E    JSR   RVEC20              ; HOOK INTO RAM
ADA1  1C AF                      ANDCC #$AF                ; ENABLE IRQ,FIRQ
ADA3  8D 46                      BSR   LADEB               ; CHECK FOR KEYBOARD BREAK
ADA5  9E A6                      LDX   CHARAD              ; GET BASIC'S INPUT POINTER
ADA7  9F 2F                      STX   TINPTR              ; SAVE IT
ADA9  A6 80                      LDA   ,X+                 ; GET CURRENT INPUT CHAR & MOVE POINTER
ADAB  27 07                      BEQ   LADB4               ; BRANCH IF END OF LINE
ADAD  81 3A                      CMPA  #':                 ; CHECK FOR LINE SEPARATOR
ADAF  27 0F                      BEQ   LADC0               ; BRANCH IF COLON
ADB1  7E B2 77          LADB1    JMP   LB277               ; 'SYNTAX ERROR'-IF NOT LINE SEPARATOR
ADB4  A6 81             LADB4    LDA   ,X++                ; GET MS BYTE OF ADDRESS OF NEXT BASIC LINE
ADB6  97 00                      STA   ENDFLG              ; SAVE IN STOP/END FLAG - CAUSE A STOP IF
* NEXT LINE ADDRESS IS < $8000; CAUSE
* AN END IF ADDRESS > $8000
ADB8  27 5B                      BEQ   LAE15               ; BRANCH TO 'STOP' - END OF PROGRAM
ADBA  EC 80                      LDD   ,X+                 ; GET CURRENT LINE NUMBER
ADBC  DD 68                      STD   CURLIN              ; SAVE IN CURLIN
ADBE  9F A6                      STX   CHARAD              ; SAVE ADDRESS OF FIRST BYTE OF LINE
ADC0  9D 9F             LADC0    JSR   GETNCH              ; GET A CHARACTER FROM BASIC
ADC2  8D 02                      BSR   LADC6               ; GO PROCESS COMMAND
ADC4  20 D8                      BRA   LAD9E               ; GO BACK TO MAIN LOOP
ADC6  27 78             LADC6    BEQ   LAE40               ; RETURN IF END OF LINE
ADC8  4D                         TSTA                      ; CHECK FOR TOKEN - BIT 7 SET (NEGATIVE)
ADC9  10 2A 01 BC                LBPL  LET                 ; BRANCH IF NOT A TOKEN - GO DO A 'LET' WHICH
* IS THE 'DEFAULT' TOKEN FOR MICROSOFT BASIC
ADCD  81 A3                      CMPA  #$A3                ; SKIPF TOKEN - HIGHEST EXECUTABLE COMMAND IN BASIC
ADCF  22 0B                      BHI   LADDC               ; BRANCH IF > A BASIC COMMAND
ADD1  BE 01 23                   LDX   COMVEC+3            ; GET ADDRESS OF BASIC'S COMMAND TABLE
ADD4  48                LADD4    ASLA                      ; X2 (2 BYTE/JUMP ADDRESS) & DISCARD BIT 7
ADD5  1F 89                      TFR   A,B                 ; SAVE COMMAND OFFSET IN ACCB
ADD7  3A                         ABX                       ; NON X POINTS TO COMMAND JUMP ADDR
ADD8  9D 9F                      JSR   GETNCH              ; GET AN INPUT CHAR
*
* HERE IS WHERE WE BRANCH TO DO A 'COMMAND'
ADDA  6E 94                      JMP   [,X]                ; GO DO A COMMAND
ADDC  81 B4             LADDC    CMPA  #$B4                ; $B4 IS HIGHEST BASIC TOKEN
ADDE  23 D1                      BLS   LADB1               ; 'SYNTAX ERROR' IF NON-EXECUTABLE TOKEN
ADE0  6E 9F 01 2D                JMP   [COMVEC+13]         ; JUMP TO AN EX BAS COMMAND
*
* RESTORE
ADE4  9E 19             RESTOR   LDX   TXTTAB              ; BEGINNING OF PROGRAM ADDRESS
ADE6  30 1F                      LEAX  -1,X                ; MOVE TO ONE BYTE BEFORE PROGRAM
ADE8  9F 33             LADE8    STX   DATPTR              ; SAVE NEW DATA POINTER
ADEA  39                         RTS
*
* BREAK CHECK
ADEB  BD A1 C1          LADEB    JSR   LA1C1               ; GET A KEYSTROKE ENTRY
ADEE  27 0A                      BEQ   LADFA               ; RETURN IF NO INPUT
ADF0  81 03             LADF0    CMPA  #3                  ; CONTROL C? (BREAK)
ADF2  27 15                      BEQ   STOP                ; YES
ADF4  81 13                      CMPA  #$13                ; CONTROL S? (PAUSE)
ADF6  27 03                      BEQ   LADFB               ; YES
ADF8  97 87                      STA   IKEYIM              ; SAVE KEYSTROKE IN INKEY IMAGE
ADFA  39                LADFA    RTS
ADFB  BD A1 CB          LADFB    JSR   KEYIN               ; GET A KEY
ADFE  27 FB                      BEQ   LADFB               ; BRANCH IF NO KEY DOWN
AE00  20 EE                      BRA   LADF0               ; CONTINUE - DO A BREAK CHECK
*
* END
AE02  BD A4 26          END      JSR   LA426               ; CLOSE FILES
AE05  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHAR
AE07  20 02                      BRA   LAE0B
*
* STOP
AE09  1A 01             STOP     ORCC  #$01                ; SET CARRY FLAG
AE0B  26 33             LAE0B    BNE   LAE40               ; BRANCH IF ARGUMENT EXISTS
AE0D  9E A6                      LDX   CHARAD              ; * SAVE CURRENT POSITION OF
AE0F  9F 2F                      STX   TINPTR              ; * BASIC'S INPUT POINTER
AE11  06 00             LAE11    ROR   ENDFLG              ; ROTATE CARRY INTO BIT 7 OF STOP/END FLAG
AE13  32 62                      LEAS  2,S                 ; PURGE RETURN ADDRESS OFF STACK
AE15  9E 68             LAE15    LDX   CURLIN              ; GET CURRENT LINE NUMBER
AE17  8C FF FF                   CMPX  #$FFFF              ; DIRECT MODE?
AE1A  27 06                      BEQ   LAE22               ; YES
AE1C  9F 29                      STX   OLDTXT              ; SAVE CURRENT LINE NUMBER
AE1E  9E 2F                      LDX   TINPTR              ; * GET AND SAVE CURRENT POSITION
AE20  9F 2D                      STX   OLDPTR              ; * OF BASIC'S INPUT POINTER
AE22  0F 6F             LAE22    CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
AE24  8E AB F1                   LDX   #LABF2-1            ; POINT TO CR, 'BREAK' MESSAGE
AE27  0D 00                      TST   ENDFLG              ; CHECK STOP/END FLAG
AE29  10 2A FE 46                LBPL  LAC73               ; BRANCH TO MAIN LOOP OF BASIC IF END
AE2D  7E AC 68                   JMP   LAC68               ; PRINT 'BREAK AT ####' AND GO TO
* BASIC'S MAIN LOOP IF 'STOP'

* CONT
AE30  26 0E             CONT     BNE   LAE40               ; RETURN IF ARGUMENT GIVEN
AE32  C6 20                      LDB   #2*16               ; 'CAN'T CONTINUE' ERROR
AE34  9E 2D                      LDX   OLDPTR              ; GET CONTINUE ADDRESS (INPUT POINTER)
AE36  10 27 FE 0C                LBEQ  LAC46               ; 'CN' ERROR IF CONTINUE ADDRESS = 0
AE3A  9F A6                      STX   CHARAD              ; RESET BASIC'S INPUT POINTER
AE3C  9E 29                      LDX   OLDTXT              ; GET LINE NUMBER
AE3E  9F 68                      STX   CURLIN              ; RESET CURRENT LINE NUMBER
AE40  39                LAE40    RTS
*
* CLEAR
AE41  27 2C             CLEAR    BEQ   LAE6F               ; BRANCH IF NO ARGUMENT
AE43  BD B3 E6                   JSR   LB3E6               ; EVALUATE ARGUMENT
AE46  34 06                      PSHS  B,A                 ; SAVE AMOUNT OF STRING SPACE ON STACK
AE48  9E 27                      LDX   MEMSIZ              ; GET CURRENT TOP OF CLEARED SPACE
AE4A  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
AE4C  27 0C                      BEQ   LAE5A               ; BRANCH IF NO NEW TOP OF CLEARED SPACE
AE4E  BD B2 6D                   JSR   LB26D               ; SYNTAX CHECK FOR COMMA
AE51  BD B7 3D                   JSR   LB73D               ; EVALUATE EXPRESSlON; RETURN VALUE IN X
AE54  30 1F                      LEAX  -1,X                ; X = TOP OF CLEARED SPACE
AE56  9C 74                      CMPX  TOPRAM              ; COMPARE TO TOP OF RAM
AE58  22 18                      BHI   LAE72               ; 'OM' ERROR IF > TOP OF RAM
AE5A  1F 10             LAE5A    TFR   X,D                 ; ACCD = TOP OF CLEARED SPACE
AE5C  A3 E1                      SUBD  ,S++                ; SUBTRACT OUT AMOUNT OF CLEARED SPACE
AE5E  25 12                      BCS   LAE72               ; 'OM' ERROR IF FREE MEM < 0
AE60  1F 03                      TFR   D,U                 ; U = BOTTOM OF CLEARED SPACE
AE62  83 00 3A                   SUBD  #STKBUF             ; SUBTRACT OUT STACK BUFFER
AE65  25 0B                      BCS   LAE72               ; 'OM' ERROR IF FREE MEM < 0
AE67  93 1B                      SUBD  VARTAB              ; SUBTRACT OUT START OF VARIABLES
AE69  25 07                      BCS   LAE72               ; 'OM' ERROR IF FREE MEM < 0
AE6B  DF 21                      STU   FRETOP              ; SAVE NEW BOTTOM OF CLEARED SPACE
AE6D  9F 27                      STX   MEMSIZ              ; SAVE NEW TOP OF CLEARED SPACE
AE6F  7E AD 26          LAE6F    JMP   LAD26               ; ERASE ALL VARIABLES, INITIALIZE POINTERS, ETC
AE72  7E AC 44          LAE72    JMP   LAC44               ; 'OM' ERROR
*
* RUN
AE75  BD 01 94          RUN      JSR   RVEC18              ; HOOK INTO RAM
AE78  BD A4 26                   JSR   LA426               ; CLOSE ANY OPEN FILES
AE7B  9D A5                      JSR   GETCCH              ; * GET CURRENT INPUT CHARACTER
AE7D  10 27 FE A0                LBEQ  LAD21               ; * IF NO LINE NUMBER
AE81  BD AD 26                   JSR   LAD26               ; ERASE ALL VARIABLES
AE84  20 19                      BRA   LAE9F               ; 'GOTO' THE RUN ADDRESS
*
* GO
AE86  1F 89             GO       TFR   A,B                 ; SAVE INPUT CHARACTER IN ACCB
AE88  9D 9F             LAE88    JSR   GETNCH              ; GET A CHARACTER FROM BASIC
AE8A  C1 A5                      CMPB  #$A5                ; 'TO' TOKEN
AE8C  27 16                      BEQ   LAEA4               ; BRANCH IF GOTO
AE8E  C1 A6                      CMPB  #$A6                ; 'SUB' TOKEN
AE90  26 45                      BNE   LAED7               ; 'SYNTAX ERROR' IF NEITHER
AE92  C6 03                      LDB   #3                  ; =ROOM FOR 6
AE94  BD AC 33                   JSR   LAC33               ; =BYTES ON STACK?
AE97  DE A6                      LDU   CHARAD              ; * SAVE CURRENT BASIC INPUT POINTER, LINE
AE99  9E 68                      LDX   CURLIN              ; * NUMBER AND SUB TOKEN ON STACK
AE9B  86 A6                      LDA   #$A6                ; *
AE9D  34 52                      PSHS  U,X,A               ; *
AE9F  8D 03             LAE9F    BSR   LAEA4               ; GO DO A 'GOTO'
AEA1  7E AD 9E                   JMP   LAD9E               ; JUMP BACK TO BASIC'S MAIN LOOP
* GOTO
AEA4  9D A5             LAEA4    JSR   GETCCH              ; GET CURRENT INPUT CHAR
AEA6  BD AF 67                   JSR   LAF67               ; GET LINE NUMBER TO BINARY IN BINVAL
AEA9  8D 40                      BSR   LAEEB               ; ADVANCE BASIC'S POINTER TO END OF LINE
AEAB  30 01                      LEAX  $01,X               ; POINT TO START OF NEXT LINE
AEAD  DC 2B                      LDD   BINVAL              ; GET THE LINE NUMBER TO RUN
AEAF  10 93 68                   CMPD  CURLIN              ; COMPARE TO CURRENT LINE NUMBER
AEB2  22 02                      BHI   LAEB6               ; IF REO'D LINE NUMBER IS > CURRENT LINE NUMBER,
* DON'T START LOOKING FROM
* START OF PROGRAM
AEB4  9E 19                      LDX   TXTTAB              ; BEGINNING OF PROGRAM
AEB6  BD AD 05          LAEB6    JSR   LAD05               ; GO FIND A LINE NUMBER
AEB9  25 17                      BCS   LAED2               ; 'UNDEFINED LINE NUMBER'
AEBB  30 1F             LAEBB    LEAX  -1,X                ; MOVE BACK TO JUST BEFORE START OF LINE
AEBD  9F A6                      STX   CHARAD              ; RESET BASIC'S INPUT POINTER
AEBF  39                LAEBF    RTS
*
* RETURN
AEC0  26 FD             RETURN   BNE   LAEBF               ; EXIT ROUTINE IF ARGUMENT GIVEN
AEC2  86 FF                      LDA   #$FF                ; * PUT AN ILLEGAL VARIABLE NAME IN FIRST BYTE OF
AEC4  97 3B                      STA   VARDES              ; * VARDES WHICH WILL CAUSE 'FOR/NEXT' DATA ON THE
* STACK TO BE IGNORED
AEC6  BD AB F9                   JSR   LABF9               ; CHECK FOR RETURN DATA ON THE STACK
AEC9  1F 14                      TFR   X,S                 ; RESET STACK POINTER - PURGE TWO RETURN ADDRESSES
* FROM THE STACK
AECB  81 26                      CMPA  #$A6-$80            ; SUB TOKEN - $80
AECD  27 0B                      BEQ   LAEDA               ; BRANCH IF 'RETURN' FROM SUBROUTINE
AECF  C6 04                      LDB   #2*2                ; ERROR #2 'RETURN WITHOUT GOSUB'
AED1  8C                         FCB   SKP2                ; SKIP TWO BYTES
AED2  C6 0E             LAED2    LDB   #7*2                ; ERROR #7 'UNDEFINED LINE NUMBER'
AED4  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER
AED7  7E B2 77          LAED7    JMP   LB277               ; 'SYNTAX ERROR'
AEDA  35 52             LAEDA    PULS  A,X,U               ; * RESTORE VALUES OF CURRENT LINE NUMBER AND
AEDC  9F 68                      STX   CURLIN              ; * BASIC'S INPUT POINTER FOR THIS SUBROUTINE
AEDE  DF A6                      STU   CHARAD              ; * AND LOAD ACCA WITH SUB TOKEN ($A6)
*
* DATA
AEE0  8D 06             DATA     BSR   LAEE8               ; MOVE INPUT POINTER TO END OF SUBLINE OR LINE
AEE2  8C                         FCB   SKP2                ; SKIP 2 BYTES

* REM, ELSE
                        ELSE
