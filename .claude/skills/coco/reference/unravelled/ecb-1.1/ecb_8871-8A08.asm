; Extended Color BASIC 1.1 -- $8871-$8A08
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: DEF=$8871, XVEC17=$88F0, XIRQSV=$894C, TIMER=$8968, DEL=$8970

* DEF
8871  AE 9F 00 A6       DEF      LDX   [CHARAD]            ; GET TWO INPUT CHARS
8875  8C FF 83                   CMPX  #$FF83              ; TOKEN FOR USR
8878  10 27 00 93                LBEQ  L890F               ; BRANCH IF DEF USR
887C  8D 23                      BSR   L88A1               ; GET DESCRIPTOR ADDRESS FOR FN VARIABLE NAME
887E  8D E6                      BSR   L8866               ; DON'T ALLOW DEF FN IF IN DIRECT MODE
8880  BD B2 6A                   JSR   LB26A               ; SYNTAX CHECK FOR '('
8883  C6 80                      LDB   #$80                ; * GET THE FLAG TO INDICATE ARRAY VARIABLE SEARCH DISABLE
8885  D7 08                      STB   ARYDIS              ; * AND SAVE IT IN THE ARRAY DISABLE FLAG
8887  BD B3 57                   JSR   LB357               ; GET VARIABLE DESCRIPTOR
888A  8D 25                      BSR   L88B1               ; 'TM' ERROR IF STRING
888C  BD B2 67                   JSR   LB267               ; SYNTAX CHECK FOR ')'
888F  C6 B3                      LDB   #$B3                ; TOKEN FOR '='
8891  BD B2 6F                   JSR   LB26F               ; DO A SYNTAX CHECK FOR =
8894  9E 4B                      LDX   V4B                 ; GET THE ADDRESS OF THE FN NAME DESCRIPTOR
8896  DC A6                      LDD   CHARAD              ; * GET THE CURRENT INPUT POINTER ADDRESS AND
8898  ED 84                      STD   ,X                  ; * SAVE IT IN FIRST 2 BYTES OF THE DESCRIPTOR
889A  DC 39                      LDD   VARPTR              ; = GET THE DESCRIPTOR ADDRESS OF THE ARGUMENT
889C  ED 02                      STD   $02,X               ; = VARIABLE AND SAVE IT IN THE DESCRIPTOR OF THE FN NAME
889E  7E AE E0                   JMP   LAEE0               ; MOVE INPUT POINTER TO END OF LINE OR SUBLINE
88A1  C6 CC             L88A1    LDB   #$CC                ; TOKEN FOR FN
88A3  BD B2 6F                   JSR   LB26F               ; DO A SYNTAX CHECK FOR FN
88A6  C6 80                      LDB   #$80                ; * GET THE FLAG TO INDICATE ARRAY VARIABLE SEARCH DISABLE FLAG
88A8  D7 08                      STB   ARYDIS              ; * AND SAVE IT IN ARRAY VARIABLE FLAG
88AA  8A 80                      ORA   #$80                ; SET BIT 7 OF CURRENT INPUT CHARACTER TO INDICATE AN FN VARIABLE
88AC  BD B3 5C                   JSR   LB35C               ; * GET THE DESCRIPTOR ADDRESS OF THIS
88AF  9F 4B                      STX   V4B                 ; * VARIABLE AND SAVE IT IN V4B
88B1  7E B1 43          L88B1    JMP   LB143               ; 'TM' ERROR IF STRING VARIABLE
* EVALUATE AN FN CALL
88B4  8D EB             L88B4    BSR   L88A1               ; * GET THE DESCRIPTOR OF THE FN NAME
88B6  34 10                      PSHS  X                   ; * VARIABLE AND SAVE IT ON THE STACK
88B8  BD B2 62                   JSR   LB262               ; SYNTAX CHECK FOR '(' & EVALUATE EXPR
88BB  8D F4                      BSR   L88B1               ; 'TM' ERROR IF STRING VARIABLE
88BD  35 40                      PULS  U                   ; POINT U TO FN NAME DESCRIPTOR
88BF  C6 32                      LDB   #2*25               ; 'UNDEFINED FUNCTION CALL' ERROR
88C1  AE 42                      LDX   $02,U               ; POINT X TO ARGUMENT VARIABLE DESCRIPTOR
88C3  27 A9                      BEQ   L886E               ; BRANCH TO ERROR HANDLER
88C5  10 9E A6                   LDY   CHARAD              ; SAVE CURRENT INPUT POINTER IN Y
88C8  EE C4                      LDU   ,U                  ; * POINT U TO START OF FN FORMULA AND
88CA  DF A6                      STU   CHARAD              ; * SAVE IT IN INPUT POINTER
88CC  A6 04                      LDA   $04,X               ; = GET FP VALUE OF
88CE  34 02                      PSHS  A                   ; = ARGUMENT VARIABLE, CURRENT INPUT
88D0  EC 84                      LDD   ,X                  ; = POINTER, AND ADDRESS OF START
88D2  EE 02                      LDU   $02,X               ; = OF FN FORMULA AND SAVE
88D4  34 76                      PSHS  U,Y,X,B,A           ; = THEM ON THE STACK
88D6  BD BC 35                   JSR   LBC35               ; PACK FPA0 AND SAVE IT IN (X)
88D9  BD B1 41          L88D9    JSR   LB141               ; EVALUATE FN EXPRESSION
88DC  35 76                      PULS  A,B,X,Y,U           ; RESTORE REGISTERS
88DE  ED 84                      STD   ,X                  ; * GET THE FP
88E0  EF 02                      STU   $02,X               ; * VALUE OF THE ARGUMENT
88E2  35 02                      PULS  A                   ; * VARIABLE OFF OF THE
88E4  A7 04                      STA   $04,X               ; * STACK AND RE-SAVE IT
88E6  9D A5                      JSR   GETCCH              ; GET FINAL CHARACTER OF THE FN FORMULA
88E8  10 26 29 8B                LBNE  LB277               ; 'SYNTAX' ERROR IF NOT END OF LINE
88EC  10 9F A6                   STY   CHARAD              ; RESTORE INPUT POINTER
88EF  39                L88EF    RTS

* ERROR DRIVER RAM HOOK
88F0  C1 32             XVEC17   CMPB  #2*25               ; CHECK FOR EXBAS ERROR NUMBER
88F2  25 FB                      BLO   L88EF               ; BRANCH IF < EXBAS ERROR
88F4  BD A7 E9                   JSR   LA7E9               ; TURN CASSETTE MOTOR OFF
88F7  BD A9 74                   JSR   LA974               ; DISABLE ANALOG MULTIPLEXER
88FA  BD AD 33                   JSR   LAD33               ; DO PART OF A NEW
88FD  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
88FF  BD B9 5C                   JSR   LB95C               ; MOVE CURSOR TO START OF NEXT LINE
8902  BD B9 AF                   JSR   LB9AF               ; SEND A '?' TO CONSOLE OUT
8905  8E 88 D9                   LDX   #L890B-25*2         ; POINT X TO EXBAS ERRORS
8908  7E AC 60                   JMP   LAC60               ; PROCESS ERROR

* ADDITIONAL ERROR MESSAGES ADDED BY EXTENDED BASIC

890B  55 46             L890B    FCC   'UF'                ; 25 UNDEFINED FUNCTION (FN) CALL
890D  4E 45             L890D    FCC   'NE'                ; 26 FILE NOT FOUND

* DEF USR
890F  9D 9F             L890F    JSR   GETNCH              ; SKIP PAST SECOND BYTE OF DEF USR TOKEN
8911  8D 09                      BSR   L891C               ; GET FN NUMBER
8913  34 10                      PSHS  X                   ; SAVE FN EXEC ADDRESS STORAGE LOC
8915  8D 2D                      BSR   L8944               ; CALCULATE EXEC ADDRESS
8917  35 40                      PULS  U                   ; GET FN EXEC ADDRESS STORAGE LOC
8919  AF C4                      STX   ,U                  ; SAVE EXEC ADDRESS
891B  39                         RTS
891C  5F                L891C    CLRB                      ; DEFAULT TO USR0 IF NO ARGUMENT
891D  9D 9F                      JSR   GETNCH              ; GET A CHARACTER FROM BASIC
891F  24 06                      BCC   L8927               ; BRANCH IF NOT NUMERIC
8921  80 30                      SUBA  #'0'                ; MASK OFF ASCII
8923  1F 89                      TFR   A,B                 ; SAVE USR NUMBER IN ACCB
8925  9D 9F                      JSR   GETNCH              ; GET A CHARACTER FROM BASIC
8927  9E B0             L8927    LDX   USRADR              ; GET ADDRESS OF STORAGE LOCs FOR USR ADDRESS
8929  58                         ASLB                      ; X2 - 2 BYTES/USR ADDRESS
892A  3A                         ABX                       ; ADD OFFSET TO START ADDRESS OF STORAGE LOCs
892B  39                         RTS
* PROCESS A USR CALL
892C  8D EE             L892C    BSR   L891C               ; GET STORAGE LOC OF EXEC ADDRESS FOR USR N
892E  AE 84                      LDX   ,X                  ; * GET EXEC ADDRESS AND
8930  34 10                      PSHS  X                   ; * PUSH IT ONTO STACK
8932  BD B2 62                   JSR   LB262               ; SYNTAX CHECK FOR '(' & EVALUATE EXPR
8935  8E 00 4F                   LDX   #FP0EXP             ; POINT X TO FPA0
8938  96 06                      LDA   VALTYP              ; GET VARIABLE TYPE
893A  27 07                      BEQ   L8943               ; BRANCH IF NUMERIC, STRING IF <> 0
893C  BD B6 57                   JSR   LB657               ; GET LENGTH & ADDRESS OF STRING VARIABLE
893F  9E 52                      LDX   FPA0+2              ; GET POINTER TO STRING DESCRIPTOR
8941  96 06                      LDA   VALTYP              ; GET VARIABLE TYPE
8943  39                L8943    RTS                       ; JUMP TO USR ROUTINE (PSHS X ABOVE)
8944  C6 B3             L8944    LDB   #$B3                ; TOKEN FOR '='
8946  BD B2 6F                   JSR   LB26F               ; DO A SYNTAX CHECK FOR =
8949  7E B7 3D                   JMP   LB73D               ; EVALUATE EXPRESSION, RETURN VALUE IN X

* EXTENDED BASIC'S IRQ ROUTINE

894C  B6 FF 03          XIRQSV   LDA   PIA0+3              ; GET PIA0, PORT B CONTROL REGISTER
894F  2B 01                      BMI   L8952               ; BRANCH IF 60 HZ INTERRUPT
8951  3B                         RTI                       ; RETURN IF 63.5 MICROSECOND INTERRUPT
8952  B6 FF 02          L8952    LDA   PIA0+2              ; RESET PIA INTERRUPT FLAG
8955  BE 01 12          L8955    LDX   TIMVAL              ; GET REAL TIME CLOCK
8958  30 01                      LEAX  $01,X               ; INCREMENT IT
895A  BF 01 12                   STX   TIMVAL              ; SAVE IT
895D  7E 9C 3E                   JMP   L9C3E               ; GO CHECK SOME MORE STUFF

8960  9D 9F             L8960    JSR   GETNCH              ; GET A CHARACTER FROM BASIC
8962  8D E0                      BSR   L8944               ; GET NEW TIMER VALUE
8964  BF 01 12                   STX   TIMVAL              ; SET TIMER COUNTER
8967  39                         RTS

* TIMER
8968  BE 01 12          TIMER    LDX   TIMVAL              ; GET TIMER VALUE
896B  9F 52                      STX   FPA0+2              ; SAVE TIMER VALUE IN BOTTOM OF FPA0
896D  7E 88 0E                   JMP   L880E               ; CONVERT BALANCE OF FPA0 TO POSITIVE INTEGER

* DEL
8970  10 27 2A D6       DEL      LBEQ  LB44A               ; FC' ERROR IF NO ARGUMENT
8974  BD AF 67                   JSR   LAF67               ; CONVERT A DECIMAL BASiC NUMBER TO BINARY
8977  BD AD 01                   JSR   LAD01               ; FIND RAM ADDRESS OF START OF A BASIC LINE
897A  9F D3                      STX   VD3                 ; SAVE RAM ADDRESS OF STARTING LINE NUMBER
897C  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
897E  27 10                      BEQ   L8990               ; BRANCH IF END OF LINE
8980  81 AC                      CMPA  #$AC                ; TOKEN FOR '-'
8982  26 3B                      BNE   L89BF               ; TERMINATE COMMAND IF LINE NUMBER NOT FOLLOWED BY '-'
8984  9D 9F                      JSR   GETNCH              ; GET A CHARACTER FROM BASIC
8986  27 04                      BEQ   L898C               ; IF END OF LINE, USE DEFAULT ENDING LINE NUMBER
8988  8D 24                      BSR   L89AE               ; * CONVERT ENDING LINE NUMBER TO BINARY
898A  20 04                      BRA   L8990               ; * AND SAVE IT IN BINVAL
898C  86 FF             L898C    LDA   #$FF                ; = USE $FFXX AS DEFAULT ENDING
898E  97 2B                      STA   BINVAL              ; = LINE NUMBER - SAVE IT IN BINVAL
8990  DE D3             L8990    LDU   VD3                 ; POINT U TO STARTING LINE NUMBER ADDRESS
8992  8C                L8992    FCB   SKP2                ; SKIP TWO BYTES
8993  EE C4             L8993    LDU   ,U                  ; POINT U TO START OF NEXT LINE
8995  EC C4                      LDD   ,U                  ; CHECK FOR END OF PROGRAM
8997  27 06                      BEQ   L899F               ; BRANCH IF END OF PROGRAM
8999  EC 42                      LDD   $02,U               ; LOAD ACCD WITH THIS LINE'S NUMBER
899B  93 2B                      SUBD  BINVAL              ; SUBTRACT ENDING LINE NUMBER ADDRESS
899D  23 F4                      BLS   L8993               ; BRANCH IF = < ENDING LINE NUMBER
899F  9E D3             L899F    LDX   VD3                 ; GET STARTING LINE NUMBER
89A1  8D 15                      BSR   L89B8               ; MOVE (U) TO (X) UNTIL END OF PROGRAM
89A3  BD AD 21                   JSR   LAD21               ; RESET BASIC'S INPUT POINTER AND ERASE VARIABLES
89A6  9E D3                      LDX   VD3                 ; GET STARTING LINE NUMBER ADDRESS
89A8  BD AC F1                   JSR   LACF1               ; RECOMPUTE START OF NEXT LINE ADDRESSES
89AB  7E AC 73                   JMP   LAC73               ; JUMP TO BASIC'S MAIN COMMAND LOOP
89AE  BD AF 67          L89AE    JSR   LAF67               ; GO GET LINE NUMBER CONVERTED TO BINARY
89B1  7E A5 C7                   JMP   LA5C7               ; MAKE SURE THERE'S NO MORE ON THIS LINE
89B4  A6 C0             L89B4    LDA   ,U+                 ; GET A BYTE FROM (U)
89B6  A7 80                      STA   ,X+                 ; MOVE THE BYTE TO (X)
89B8  11 93 1B          L89B8    CMPU  VARTAB              ; COMPARE TO END OF BASIC
89BB  26 F7                      BNE   L89B4               ; BRANCH IF NOT AT END
89BD  9F 1B                      STX   VARTAB              ; SAVE (X) AS NEW END OF BASIC
89BF  39                L89BF    RTS

* LINE INPUT
89C0  BD 88 66          L89C0    JSR   L8866               ; 'BS' ERROR IF IN DIRECT MODE
89C3  9D 9F                      JSR   GETNCH              ; GET A CHAR FROM BASIC
89C5  81 23                      CMPA  #'#'                ; * CHECK FOR DEVICE NUMBER FLAG AND
89C7  26 09                      BNE   L89D2               ; * BRANCH IF NOT THERE
89C9  BD A5 A5                   JSR   LA5A5               ; CHECK FOR VALID DEVICE NUMBER
89CC  BD A3 ED                   JSR   LA3ED               ; CHECK FOR OPEN FILE
89CF  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
89D2  81 22             L89D2    CMPA  #'"'                ; CHECK FOR PROMPT STRING
89D4  26 0B                      BNE   L89E1               ; BRANCH IF NO PROMPT STRING
89D6  BD B2 44                   JSR   LB244               ; STRIP OFF PROMPT STRING & PUT IT ON STRING STACK
89D9  C6 3B                      LDB   #';'                ; *
89DB  BD B2 6F                   JSR   LB26F               ; * DO A SYNTAX CHECK FOR;
89DE  BD B9 9F                   JSR   LB99F               ; REMOVE PROMPT STRING FROM STRING STACK & SEND TO CONSOLE OUT
89E1  32 7E             L89E1    LEAS  $-02,S              ; RESERVE TWO STORAGE SLOTS ON STACK
89E3  BD B0 35                   JSR   LB035               ; INPUT A LINE FROM CURRENT INPUT DEVICE
89E6  32 62                      LEAS  $02,S               ; CLEAN UP THE STACK
89E8  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
89EA  BD B3 57                   JSR   LB357               ; SEARCH FOR A VARIABLE
89ED  9F 3B                      STX   VARDES              ; SAVE POINTER TO VARIABLE DESCRIPTOR
89EF  BD B1 46                   JSR   LB146               ;  'TM' ERROR IF VARIABLE TYPE = NUMERIC
89F2  8E 02 DC                   LDX   #LINBUF             ; POINT X TO THE STRING BUFFER WHERE THE INPUT STRING WAS STORED
89F5  4F                         CLRA                      ; TERMINATOR CHARACTER 0 (END OF LINE)
89F6  BD B5 1A                   JSR   LB51A               ; PARSE THE INPUT STRING AND STORE IT IN THE STRING SPACE
89F9  7E AF A4                   JMP   LAFA4               ; REMOVE DESCRIPTOR FROM STRING STACK
89FC  BD AF 67          L89FC    JSR   LAF67               ; STRIP A DECIMAL NUMBER FROM BASIC INPUT LINE
89FF  9E 2B                      LDX   BINVAL              ; GET BINARY VALUE
8A01  39                         RTS
8A02  9E D1             L8A02    LDX   VD1                 ; GET CURRENT OLD NUMBER BEING RENUMBERED
8A04  9F 2B             L8A04    STX   BINVAL              ; SAVE THE LINE NUMBER BEING SEARCHED FOR
8A06  7E AD 01                   JMP   LAD01               ; GO FIND THE LINE NUMBER IN BASIC PROGRAM
