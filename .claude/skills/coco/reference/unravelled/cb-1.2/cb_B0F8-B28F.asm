; Color BASIC 1.2 -- $B0F8-$B28F
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: NEXT=$B0F8

* NEXT
B0F8  26 04             NEXT     BNE   LB0FE               ; BRANCH IF ARGUMENT GIVEN
B0FA  9E 8A                      LDX   ZERO                ; X = 0: DEFAULT FOR NO ARGUMENT
B0FC  20 03                      BRA   LB101
B0FE  BD B3 57          LB0FE    JSR   LB357               ; EVALUATE AN ALPHA EXPRESSION
B101  9F 3B             LB101    STX   VARDES              ; SAVE VARIABLE DESCRIPTOR POINTER
B103  BD AB F9                   JSR   LABF9               ; GO SCAN FOR 'FOR/NEXT' DATA ON STACK
B106  27 04                      BEQ   LB10C               ; BRANCH IF DATA FOUND
B108  C6 00                      LDB   #0                  ; 'NEXT WITHOUT FOR' ERROR (SHOULD BE CLRB)
B10A  20 47             LB10A    BRA   LB153               ; PROCESS ERROR
B10C  1F 14             LB10C    TFR   X,S                 ; POINT S TO START OF 'FOR/NEXT' DATA
B10E  30 03                      LEAX  3,X                 ; POINT X TO FP VALUE OF STEP
B110  BD BC 14                   JSR   LBC14               ; COPY A FP NUMBER FROM (X) TO FPA0
B113  A6 68                      LDA   8,S                 ; GET THE DIRECTION OF STEP
B115  97 54                      STA   FP0SGN              ; SAVE IT AS THE SIGN OF FPA0
B117  9E 3B                      LDX   VARDES              ; POINT (X) TO INDEX VARIABLE DESCRIPTOR
B119  BD B9 C2                   JSR   LB9C2               ; ADD (X) TO FPA0 (STEP TO INDEX)
B11C  BD BC 33                   JSR   LBC33               ; PACK FPA0 AND STORE IT IN ADDRESS
* CONTAINED IN VARDES
B11F  30 69                      LEAX  9,S                 ; POINT (X) TO TERMINAL VALUE OF INDEX
B121  BD BC 96                   JSR   LBC96               ; COMPARE CURRENT INDEX VALUE TO TERMINAL VALUE OF INDEX
B124  E0 68                      SUBB  8,S                 ; ACCB = 0 IF TERMINAL VALUE=CURRENT VALUE AND STEP=0 OR IF
* STEP IS POSITIVE AND CURRENT VALUE>TERMINAL VALUE OR
* STEP IS NEGATIVE AND CURRENT VALUE<TERMINAL VALUE
B126  27 0C                      BEQ   LB134               ; BRANCH IF 'FOR/NEXT' LOOP DONE
B128  AE 6E                      LDX   14,S                ; * GET LINE NUMBER AND
B12A  9F 68                      STX   CURLIN              ; * BASIC POINTER OF
B12C  AE E8 10                   LDX   16,S                ; * STATEMENT FOLLOWING THE
B12F  9F A6                      STX   CHARAD              ; * PROPER FOR STATEMENT
B131  7E AD 9E          LB131    JMP   LAD9E               ; JUMP BACK TO COMMAND INTEPR. LOOP
B134  32 E8 12          LB134    LEAS  18,S                ; PULL THE 'FOR-NEXT' DATA OFF THE STACK
B137  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
B139  81 2C                      CMPA  #',                 ; CHECK FOR ANOTHER ARGUMENT
B13B  26 F4                      BNE   LB131               ; RETURN IF NONE
B13D  9D 9F                      JSR   GETNCH              ; GET NEXT CHARACTER FROM BASIC
B13F  8D BD                      BSR   LB0FE               ; BSR SIMULATES A CALL TO 'NEXT' FROM COMMAND LOOP

* EVALUATE A NUMERIC EXPRESSION
B141  8D 13             LB141    BSR   LB156               ; EVALUATE EXPRESSION AND DO A TYPE CHECK FOR NUMERIC
B143  1C FE             LB143    ANDCC #$FE                ; CLEAR CARRY FLAG
B145  7D                LB145    FCB   $7D                 ; OP CODE OF TST $1A01 - SKIP TWO BYTES (DO
* NOT CHANGE CARRY FLAG)
B146  1A 01             LB146    ORCC  #1                  ; SET CARRY

* STRING TYPE MODE CHECK - IF ENTERED AT LB146 THEN VALTYP PLUS IS 'TM' ERROR
* NUMERIC TYPE MODE CHECK - IF ENTERED AT LB143 THEN VALTYP MINUS IS 'TM' ERROR
* IF ENTERED AT LB148, A TYPE CHECK IS DONE ON VALTYP
* IF ENTERED WITH CARRY SET, THEN 'TM' ERROR IF NUMERIC
* IF ENTERED WITH CARRY CLEAR, THEN 'TM' ERROR IF STRING.
B148  0D 06             LB148    TST   VALTYP              ; TEST TYPE FLAG; DO NOT CHANGE CARRY
B14A  25 03                      BCS   LB14F               ; BRANCH IF STRING
B14C  2A 99                      BPL   LB0E7               ; RETURN ON PLUS
B14E  8C                         FCB   SKP2                ; SKIP 2 BYTES - 'TM' ERROR
B14F  2B 96             LB14F    BMI   LB0E7               ; RETURN ON MINUS
B151  C6 18                      LDB   #12*2               ; 'TYPE M1SMATCH' ERROR
B153  7E AC 46          LB153    JMP   LAC46               ; PROCESS ERROR
* EVALUATE EXPRESSION
B156  8D 6E             LB156    BSR   LB1C6               ; BACK UP INPUT POINTER
B158  4F                         CLRA                      ; END OF OPERATION PRECEDENCE FLAG
B159  8C                         FCB   SKP2                ; SKIP TWO BYTES
B15A  34 04             LB15A    PSHS  B                   ; SAVE FLAG (RELATIONAL OPERATOR FLAG)
B15C  34 02                      PSHS  A                   ; SAVE FLAG (PRECEDENCE FLAG)
B15E  C6 01                      LDB   #1                  ; *
B160  BD AC 33                   JSR   LAC33               ; * SEE IF ROOM IN FREE RAM FOR (B) WORDS
B163  BD B2 23                   JSR   LB223               ; GO EVALUATE AN EXPRESSION
B166  0F 3F                      CLR   TRELFL              ; RESET RELATIONAL OPERATOR FLAG
B168  9D A5             LB168    JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
* CHECK FOR RELATIONAL OPERATORS
B16A  80 B2             LB16A    SUBA  #$B2                ; TOKEN FOR >
B16C  25 13                      BCS   LB181               ; BRANCH IF LESS THAN RELATIONAL OPERATORS
B16E  81 03                      CMPA  #3                  ; *
B170  24 0F                      BCC   LB181               ; * BRANCH IF GREATER THAN RELATIONAL OPERATORS
B172  81 01                      CMPA  #1                  ; SET CARRY IF '>'
B174  49                         ROLA                      ; CARRY TO BIT 0
B175  98 3F                      EORA  TRELFL              ; * CARRY SET IF
B177  91 3F                      CMPA  TRELFL              ; * TRELFL = ACCA
B179  25 64                      BCS   LB1DF               ; BRANCH IF SYNTAX ERROR : == << OR >>
B17B  97 3F                      STA   TRELFL              ; BIT 0: >, BIT 1 =, BIT 2: <  SAVE DESIRED RELATIONAL COMPARISON
B17D  9D 9F                      JSR   GETNCH              ; GET AN INPUT CHARACTER
B17F  20 E9                      BRA   LB16A               ; CHECK FOR ANOTHER RELATIONAL OPERATOR
*
B181  D6 3F             LB181    LDB   TRELFL              ; GET RELATIONAL OPERATOR FLAG
B183  26 33                      BNE   LB1B8               ; BRANCH IF RELATIONAL COMPARISON
B185  10 24 00 6B                LBCC  LB1F4               ; BRANCH IF > RELATIONAL OPERATOR
B189  8B 07                      ADDA  #7                  ; SEVEN ARITHMETIC/LOGICAL OPERATORS
B18B  24 67                      BCC   LB1F4               ; BRANCH IF NOT ARITHMETIC/LOGICAL OPERATOR
B18D  99 06                      ADCA  VALTYP              ; ADD CARRY, NUMERIC FLAG AND MODIFIED TOKEN NUMBER
B18F  10 27 04 7C                LBEQ  LB60F               ; BRANCH IF VALTYP = FF, AND ACCA = '+' TOKEN -
; CONCATENATE TWO STRINGS
B193  89 FF                      ADCA  #-1                 ; RESTORE ARITHMETIC/LOGICAL OPERATOR NUMBER
B195  34 02                      PSHS  A                   ; * STORE OPERATOR NUMBER ON STACK; MULTIPLY IT BY 2
B197  48                         ASLA                      ; * THEN ADD THE STORED STACK DATA = MULTIPLY
B198  AB E0                      ADDA  ,S+                 ; * X 3; 3 BYTE/TABLE ENTRY
B19A  8E AA 51                   LDX   #LAA51              ; JUMP TABLE FOR ARITHMETIC & LOGICAL OPERATORS
B19D  30 86                      LEAX  A,X                 ; POINT X TO PROPER TABLE
B19F  35 02             LB19F    PULS  A                   ; GET PRECEDENCE FLAG FROM STACK
B1A1  A1 84                      CMPA  ,X                  ; COMPARE TO CURRENT OPERATOR
B1A3  24 55                      BCC   LB1FA               ; BRANCH IF STACK OPERATOR > CURRENT OPERATOR
B1A5  8D 9C                      BSR   LB143               ; 'TM' ERROR IF VARIABLE TYPE = STRING

* OPERATION BEING PROCESSED IS OF HIGHER PRECEDENCE THAN THE PREVIOUS OPERATION.
B1A7  34 02             LB1A7    PSHS  A                   ; SAVE PRECEDENCE FLAG
B1A9  8D 29                      BSR   LB1D4               ; PUSH OPERATOR ROUTINE ADDRESS AND FPA0 ONTO STACK
B1AB  9E 3D                      LDX   RELPTR              ; GET POINTER TO ARITHMETIC/LOGICAL TABLE ENTRY FOR
* LAST CALCULATED OPERATION
B1AD  35 02                      PULS  A                   ; GET PRECEDENCE FLAG OF PREVIOUS OPERATION
B1AF  26 1D                      BNE   LB1CE               ; BRANCH IF NOT END OF OPERATION
B1B1  4D                         TSTA                      ; CHECK TYPE OF PRECEDENCE FLAG
B1B2  10 27 00 6A                LBEQ  >LB220              ; BRANCH IF END OF EXPRESSION OR SUB-EXPRESSION
B1B6  20 4B                      BRA   LB203               ; EVALUATE AN OPERATION
* DO A RELATIONAL COMPARISON HERE
B1B8  08 06             LB1B8    ASL   VALTYP              ; BIT 7 OF TYPE FLAG TO CARRY
B1BA  59                         ROLB                      ; SHIFT RELATIONAL FLAG LEFT - VALTYP TO BIT 0
B1BB  8D 09                      BSR   LB1C6               ; MOVE THE INPUT POINTER BACK ONE
B1BD  8E B1 CB                   LDX   #LB1CB              ; POINT X TO RELATIONAL COMPARISON JUMP TABLE
B1C0  D7 3F                      STB   TRELFL              ; SAVE RELATIONAL COMPARISON DATA
B1C2  0F 06                      CLR   VALTYP              ; SET VARIABLE TYPE TO NUMERIC
B1C4  20 D9                      BRA   LB19F               ; PERFORM OPERATION OR SAVE ON STACK

B1C6  9E A6             LB1C6    LDX   CHARAD              ; * GET BASIC'S INPUT POINTER AND
B1C8  7E AE BB                   JMP   LAEBB               ; * MOVE IT BACK ONE
* RELATIONAL COMPARISON JUMP TABLE
B1CB  64                LB1CB    FCB   $64                 ; RELATIONAL COMPARISON FLAG
B1CC  B2 F4             LB1CC    FDB   LB2F4               ; JUMP ADDRESS

B1CE  A1 84             LB1CE    CMPA  ,X                  ; COMPARE PRECEDENCE OF LAST DONE OPERATION TO
* NEXT TO BE DONE OPERATION
B1D0  24 31                      BCC   LB203               ; EVALUATE OPERATION IF LOWER PRECEDENCE
B1D2  20 D3                      BRA   LB1A7               ; PUSH OPERATION DATA ON STACK IF HIGHER PRECEDENCE

* PUSH OPERATOR EVALUATION ADDRESS AND FPA0 ONTO STACK AND EVALUATE ANOTHER EXPR
B1D4  EC 01             LB1D4    LDD   1,X                 ; GET ADDRESS OF OPERATOR ROUTINE
B1D6  34 06                      PSHS  B,A                 ; SAVE IT ON THE STACK
B1D8  8D 08                      BSR   LB1E2               ; PUSH FPA0 ONTO STACK
B1DA  D6 3F                      LDB   TRELFL              ; GET BACK RELATIONAL OPERATOR FLAG
B1DC  16 FF 7B                   LBRA  LB15A               ; EVALUATE ANOTHER EXPRESSION
B1DF  7E B2 77          LB1DF    JMP   LB277               ; 'SYNTAX ERROR'
* PUSH FPA0 ONTO THE STACK.  ,S = EXPONENT
* 1-2,S =HIGH ORDER MANTISSA  3-4,S = LOW ORDER MANTISSA
* 5,S = SIGN  RETURN WITH PRECEDENCE CODE IN ACCA
B1E2  D6 54             LB1E2    LDB   FP0SGN              ; GET SIGN OF FPA0 MANTISSA
B1E4  A6 84                      LDA   ,X                  ; GET PRECEDENCE CODE TO ACCA
B1E6  35 20             LB1E6    PULS  Y                   ; GET RETURN ADDRESS FROM STACK & PUT IT IN Y
B1E8  34 04                      PSHS  B                   ; SAVE ACCB ON STACK
B1EA  D6 4F             LB1EA    LDB   FP0EXP              ; * PUSH FPA0 ONTO THE STACK
B1EC  9E 50                      LDX   FPA0                ; *
B1EE  DE 52                      LDU   FPA0+2              ; *
B1F0  34 54                      PSHS  U,X,B               ; *
B1F2  6E A4                      JMP   ,Y                  ; JUMP TO ADDRESS IN Y

* BRANCH HERE IF NON-OPERATOR CHARACTER FOUND - USUALLY ')' OR END OF LINE
B1F4  9E 8A             LB1F4    LDX   ZERO                ; POINT X TO DUMMY VALUE (ZERO)
B1F6  A6 E0                      LDA   ,S+                 ; GET PRECEDENCE FLAG FROM STACK
B1F8  27 26                      BEQ   LB220               ; BRANCH IF END OF EXPRESSION
B1FA  81 64             LB1FA    CMPA  #$64                ; * CHECK FOR RELATIONAL COMPARISON FLAG
B1FC  27 03                      BEQ   LB201               ; * AND BRANCH IF RELATIONAL COMPARISON
B1FE  BD B1 43                   JSR   LB143               ; 'TM' ERROR IF VARIABLE TYPE = STRING
B201  9F 3D             LB201    STX   RELPTR              ; SAVE POINTER TO OPERATOR ROUTINE
B203  35 04             LB203    PULS  B                   ; GET RELATIONAL OPERATOR FLAG FROM STACK
B205  81 5A                      CMPA  #$5A                ; CHECK FOR 'NOT' OPERATOR
B207  27 19                      BEQ   LB222               ; RETURN IF 'NOT' - NO RELATIONAL COMPARISON
B209  81 7D                      CMPA  #$7D                ; CHECK FOR NEGATION (UNARY) FLAG
B20B  27 15                      BEQ   LB222               ; RETURN IF NEGATION - NO RELATIONAL COMPARISON

* EVALUATE AN OPERATION. EIGHT BYTES WILL BE STORED ON STACK, FIRST SIX BYTES
* ARE A TEMPORARY FLOATING POINT RESULT THEN THE ADDRESS OF ROUTINE WHICH
* WILL EVALUATE THE OPERATION. THE RTS AT END OF ROUTINE WILL VECTOR
* TO EVALUATING ROUTINE.
B20D  54                         LSRB                      ; = ROTATE VALTYP BIT INTO CARRY
B20E  D7 0A                      STB   RELFLG              ; = FLAG AND SAVE NEW RELFLG
B210  35 52                      PULS  A,X,U               ; * PULL A FP VALUE OFF OF THE STACK
B212  97 5C                      STA   FP1EXP              ; * AND SAVE IT IN FPA1
B214  9F 5D                      STX   FPA1                ; *
B216  DF 5F                      STU   FPA1+2              ; *
B218  35 04                      PULS  B                   ; = GET MANTISSA SIGN AND
B21A  D7 61                      STB   FP1SGN              ; = SAVE IT IN FPA1
B21C  D8 54                      EORB  FP0SGN              ; EOR IT WITH FPA1 MANTISSA SIGN
B21E  D7 62                      STB   RESSGN              ; SAVE IT IN RESULT SIGN BYTE
B220  D6 4F             LB220    LDB   FP0EXP              ; GET EXPONENT OF FPA0
B222  39                LB222    RTS

B223  BD 01 8B          LB223    JSR   RVEC15              ; HOOK INTO RAM
B226  0F 06                      CLR   VALTYP              ; INITIALIZE TYPE FLAG TO NUMERIC
B228  9D 9F                      JSR   GETNCH              ; GET AN INPUT CHAR
B22A  24 03                      BCC   LB22F               ; BRANCH IF NOT NUMERIC
B22C  7E BD 12          LB22C    JMP   LBD12               ; CONVERT ASCII STRING TO FLOATING POINT -
* RETURN RESULT IN FPA0
* PROCESS A NON NUMERIC FIRST CHARACTER
B22F  BD B3 A2          LB22F    JSR   LB3A2               ; SET CARRY IF NOT ALPHA
B232  24 50                      BCC   LB284               ; BRANCH IF ALPHA CHARACTER
B234  81 2E                      CMPA  #'.                 ; IS IT '.' (DECIMAL POINT)?
B236  27 F4                      BEQ   LB22C               ; CONVERT ASCII STRING TO FLOATING POINT
B238  81 AC                      CMPA  #$AC                ; MINUS TOKEN
B23A  27 40                      BEQ   LB27C               ; YES - GO PROCESS THE MINUS OPERATOR
B23C  81 AB                      CMPA  #$AB                ; PLUS TOKEN
B23E  27 E3                      BEQ   LB223               ; YES - GET ANOTHER CHARACTER
B240  81 22                      CMPA  #'"                 ; STRING DELIMITER?
B242  26 0A                      BNE   LB24E               ; NO
B244  9E A6             LB244    LDX   CHARAD              ; CURRENT BASIC POINTER TO X
B246  BD B5 18                   JSR   LB518               ; SAVE STRING ON STRING STACK
B249  9E 64             LB249    LDX   COEFPT              ; * GET ADDRESS OF END OF STRING AND
B24B  9F A6                      STX   CHARAD              ; * PUT BASIC'S INPUT POINTER THERE
B24D  39                         RTS
B24E  81 A8             LB24E    CMPA  #$A8                ; NOT TOKEN?
B250  26 0D                      BNE   LB25F               ; NO
* PROCESS THE NOT OPERATOR
B252  86 5A                      LDA   #$5A                ; 'NOT' PRECEDENCE FLAG
B254  BD B1 5A                   JSR   LB15A               ; PROCESS OPERATION FOLLOWING 'NOT'
B257  BD B3 ED                   JSR   INTCNV              ; CONVERT FPA0 TO INTEGER IN ACCD
B25A  43                         COMA                      ; * 'NOT' THE INTEGER
B25B  53                         COMB                      ; *
B25C  7E B4 F4                   JMP   GIVABF              ; CONVERT ACCD TO FLOATING POINT (FPA0)
B25F  4C                LB25F    INCA                      ; CHECK FOR TOKENS PRECEEDED BY 5FF
B260  27 2E                      BEQ   LB290               ; IT WAS PRECEEDED BY 5FF
B262  8D 06             LB262    BSR   LB26A               ; SYNTAX CHECK FOR A '('
B264  BD B1 56                   JSR   LB156               ; EVALUATE EXPRESSIONS WITHIN PARENTHESES AT
* HIGHEST PRECEDENCE
B267  C6 29             LB267    LDB   #')                 ; SYNTAX CHECK FOR ')'
B269  8C                         FCB   SKP2                ; SKIP 2 BYTES
B26A  C6 28             LB26A    LDB   #'(                 ; SYNTAX CHECK FOR '('
B26C  8C                         FCB   SKP2                ; SKIP 2 BYTES
B26D  C6 2C             LB26D    LDB   #',                 ; SYNTAX CHECK FOR COMMA
B26F  E1 9F 00 A6       LB26F    CMPB  [CHARAD]            ; * COMPARE ACCB TO CURRENT INPUT
B273  26 02                      BNE   LB277               ; * CHARACTER - SYNTAX ERROR IF NO MATCH
B275  0E 9F                      JMP   GETNCH              ; GET A CHARACTER FROM BASIC
B277  C6 02             LB277    LDB   #2*1                ; SYNTAX ERROR
B279  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER

* PROCESS THE MINUS (UNARY) OPERATOR
B27C  86 7D             LB27C    LDA   #$7D                ; MINUS (UNARY) PRECEDENCE FLAG
B27E  BD B1 5A                   JSR   LB15A               ; PROCESS OPERATION FOLLOWING 'UNARY' NEGATION
B281  7E BE E9                   JMP   LBEE9               ; CHANGE SIGN OF FPA0 MANTISSA

* EVALUATE ALPHA EXPRESSION
B284  BD B3 57          LB284    JSR   LB357               ; FIND THE DESCRIPTOR ADDRESS OF A VARIABLE
B287  9F 52                      STX   FPA0+2              ; SAVE DESCRIPTOR ADDRESS IN FPA0
B289  96 06                      LDA   VALTYP              ; TEST VARIABLE TYPE
B28B  26 95                      BNE   LB222               ; RETURN IF STRING
B28D  7E BC 14                   JMP   LBC14               ; COPY A FP NUMBER FROM (X) TO FPA0
