; Color BASIC 1.2 -- $B290-$B3EC
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: DIM=$B34E

* EVALUATING A SECONDARY TOKEN
B290  9D 9F             LB290    JSR   GETNCH              ; GET AN INPUT CHARACTER (SECONDARY TOKEN)
B292  1F 89                      TFR   A,B                 ; SAVE IT IN ACCB
B294  58                         ASLB                      ; X2 & BET RID OF BIT 7
B295  9D 9F                      JSR   GETNCH              ; GET ANOTHER INPUT CHARACTER
B297  C1 26                      CMPB  #2*19               ; 19 SECONDARY FUNCTIONS IN BASIC
B299  23 04                      BLS   LB29F               ; BRANCH IF COLOR BASIC TOKEN
B29B  6E 9F 01 32                JMP   [COMVEC+18]         ; JUMP TO EXBAS SECONDARY TOKEN HANDLER
B29F  34 04             LB29F    PSHS  B                   ; SAVE TOKEN OFFSET ON STACK
B2A1  C1 1C                      CMPB  #2*14               ; CHECK FOR NUMERIC ARGUMENT TOKEN
B2A3  25 22                      BCS   LB2C7               ; DO SECONDARIES $8D (JOYSTK) OR LESS
B2A5  C1 24                      CMPB  #2*18               ; *
B2A7  24 20                      BCC   LB2C9               ; * DO SECONDARIES $92 (INKEY$) OR >
B2A9  8D BF                      BSR   LB26A               ; SYNTAX CHECK FOR A '('
B2AB  A6 E4                      LDA   ,S                  ; GET TOKEN NUMBER
B2AD  81 22                      CMPA  #2*17               ; CHECK FOR 'POINT' COMMAND
B2AF  24 18                      BCC   LB2C9               ; DO POINT COMMAND ($91)
* DO SECONDARIES $8E, $8F, $90 (LEFT$, RIGHT$, MID$)
B2B1  BD B1 56                   JSR   LB156               ; EVALUATE FIRST STRING IN ARGUMENT
B2B4  8D B7                      BSR   LB26D               ; SYNTAX CHECK FOR A COMMA
B2B6  BD B1 46                   JSR   LB146               ; 'TM' ERROR IF NUMERIC VARiABLE
B2B9  35 02                      PULS  A                   ; GET TOKEN OFFSET FROM STACK
B2BB  DE 52                      LDU   FPA0+2              ; POINT U TO STRING DESCRIPTOR
B2BD  34 42                      PSHS  U,A                 ; SAVE TOKEN OFFSET AND DESCRIPTOR ADDRESS
B2BF  BD B7 0B                   JSR   LB70B               ; EVALUATE FIRST NUMERIC ARGUMENT
B2C2  35 02                      PULS  A                   ; GET TOKEN OFFSET FROM STACK
B2C4  34 06                      PSHS  B,A                 ; SAVE TOKEN OFFSET AND NUMERIC ARGUMENT
B2C6  8E                         FCB   $8E                 ; OP CODE OF LDX# - SKlP 2 BYTES
B2C7  8D 99             LB2C7    BSR   LB262               ; SYNTAX CHECK FOR A '('
B2C9  35 04             LB2C9    PULS  B                   ; GET TOKEN OFFSET
B2CB  BE 01 28                   LDX   COMVEC+8            ; GET SECONDARY FUNCTION JUMP TABLE ADDRESS
B2CE  3A                LB2CE    ABX                       ; ADD IN COMMAND OFFSET
*
* HERE IS WHERE WE BRANCH TO A SECONDARY FUNCTION
B2CF  AD 94                      JSR   [,X]                ; GO DO AN SECONDARY FUNCTION
B2D1  7E B1 43                   JMP   LB143               ; 'TM' ERROR IF VARIABLE TYPE = STRING

* LOGICAL OPERATOR 'OR' JUMPS HERE
B2D4  86                LB2D4    FCB   SKP1LD              ; SKIP ONE BYTE - 'OR' FLAG = $4F

* LOGICAL OPERATOR 'AND' JUMPS HERE
B2D5  4F                LB2D5    CLRA                      ; AND FLAG = 0
B2D6  97 03                      STA   TMPLOC              ; AND/OR FLAG
B2D8  BD B3 ED                   JSR   INTCNV              ; CONVERT FPA0 INTO AN INTEGER IN ACCD
B2DB  DD 01                      STD   CHARAC              ; TEMP SAVE ACCD
B2DD  BD BC 4A                   JSR   LBC4A               ; MOVE FPA1 TO FPA0
B2E0  BD B3 ED                   JSR   INTCNV              ; CONVERT FPA0 INTO AN INTEGER IN ACCD
B2E3  0D 03                      TST   TMPLOC              ; CHECK AND/OR FLAG
B2E5  26 06                      BNE   LB2ED               ; BRANCH IF OR
B2E7  94 01                      ANDA  CHARAC              ; * 'AND' ACCD WITH FPA0 INTEGER
B2E9  D4 02                      ANDB  ENDCHR              ; * STORED IN ENDCHR
B2EB  20 04                      BRA   LB2F1               ; CONVERT TO FP
B2ED  9A 01             LB2ED    ORA   CHARAC              ; * 'OR' ACCD WITH FPA0 INTEGER
B2EF  DA 02                      ORB   ENDCHR              ; * STORED IN CHARAC
B2F1  7E B4 F4          LB2F1    JMP   GIVABF              ; CONVERT THE VALUE IN ACCD INTO A FP NUMBER

* RELATIONAL COMPARISON PROCESS HANDLER
B2F4  BD B1 48                   JSR   LB148               ; 'TM' ERROR IF TYPE MISMATCH
B2F7  26 10                      BNE   LB309               ; BRANCH IF STRING VARIABLE
B2F9  96 61                      LDA   FP1SGN              ; * 'PACK' THE MANTISSA
B2FB  8A 7F                      ORA   #$7F                ; * SIGN OF FPA1 INTO
B2FD  94 5D                      ANDA  FPA1                ; * BIT 7 OF THE
B2FF  97 5D                      STA   FPA1                ; * MANTISSA MS BYTE
B301  8E 00 5C                   LDX   #FP1EXP             ; POINT X TO FPA1
B304  BD BC 96                   JSR   LBC96               ; COMPARE FPA0 TO FPA1
B307  20 36                      BRA   LB33F               ; CHECK TRUTH OF RELATIONAL COMPARISON

* RELATIONAL COMPARISON OF STRINGS
B309  0F 06             LB309    CLR   VALTYP              ; SET VARIABLE TYPE TO NUMERIC
B30B  0A 3F                      DEC   TRELFL              ; REMOVE STRING TYPE FLAG (BIT0=1 FOR STRINGS) FROM THE
* DESIRED RELATIONAL COMPARISON DATA
B30D  BD B6 57                   JSR   LB657               ; GET LENGTH AND ADDRESS OF STRING WHOSE
* DESCRIPTOR ADDRESS IS IN THE BOTTOM OF FPA0
B310  D7 56                      STB   STRDES              ; * SAVE LENGTH AND ADDRESS IN TEMPORARY
B312  9F 58                      STX   STRDES+2            ; * DESCRIPTOR (STRING B)
B314  9E 5F                      LDX   FPA1+2              ; = RETURN LENGTH AND ADDRESS OF STRING
B316  BD B6 59                   JSR   LB659               ; = WHOSE DESCRIPTOR ADDRESS IS STORED IN FPA1+2
B319  96 56                      LDA   STRDES              ; LOAD ACCA WITH LENGTH OF STRING B
B31B  34 04                      PSHS  B                   ; SAVE LENGTH A ON STACK
B31D  A0 E0                      SUBA  ,S+                 ; SUBTRACT LENGTH A FROM LENGTH B
B31F  27 07                      BEQ   LB328               ; BRANCH IF STRINGS OF EQUAL LENGTH
B321  86 01                      LDA   #1                  ; TRUE FLAG
B323  24 03                      BCC   LB328               ; TRUE IF LENGTH B > LENGTH A
B325  D6 56                      LDB   STRDES              ; LOAD ACCB WITH LENGTH B
B327  40                         NEGA                      ; SET FLAG = FALSE (1FF)
B328  97 54             LB328    STA   FP0SGN              ; SAVE TRUE/FALSE FLAG
B32A  DE 58                      LDU   STRDES+2            ; POINT U TO START OF STRING
B32C  5C                         INCB                      ; COMPENSATE FOR THE DECB BELOW
* ENTER WITH ACCB CONTAINING LENGTH OF SHORTER STRING
B32D  5A                LB32D    DECB                      ; DECREMENT SHORTER STRING LENGTH
B32E  26 04                      BNE   LB334               ; BRANCH IF ALL OF STRING NOT COMPARED
B330  D6 54                      LDB   FP0SGN              ; GET TRUE/FALSE FLAB
B332  20 0B                      BRA   LB33F               ; CHECK TRUTH OF RELATIONAL COMPARISON
B334  A6 80             LB334    LDA   ,X+                 ; GET A BYTE FROM STRING A
B336  A1 C0                      CMPA  ,U+                 ; COMPARE TO STRING B
B338  27 F3                      BEQ   LB32D               ; CHECK ANOTHER CHARACTER IF =
B33A  C6 FF                      LDB   #$FF                ; FALSE FLAG IF STRING A > B
B33C  24 01                      BCC   LB33F               ; BRANCH IF STRING A > STRING B
B33E  50                         NEGB                      ; SET FLAG = TRUE

* DETERMINE TRUTH OF COMPARISON - RETURN RESULT IN FPA0
B33F  CB 01             LB33F    ADDB  #1                  ; CONVERT $FF,0,1 TO 0,1,2
B341  59                         ROLB                      ; NOW IT'S 1,2,4 FOR > = <
B342  D4 0A                      ANDB  RELFLG              ; 'AND' THE ACTUAL COMPARISON WITH THE DESIRED -
; COMPARISON
B344  27 02                      BEQ   LB348               ; BRANCH IF FALSE (NO MATCHING BITS)
B346  C6 FF                      LDB   #$FF                ; TRUE FLAG
B348  7E BC 7C          LB348    JMP   LBC7C               ; CONVERT ACCB INTO FP NUMBER IN FPA0

* DIM
B34B  BD B2 6D          LB34B    JSR   LB26D               ; SYNTAX CHECK FOR COMMA
B34E  C6 01             DIM      LDB   #1                  ; DIMENSION FLAG
B350  8D 08                      BSR   LB35A               ; SAVE ARRAY SPACE FOR THIS VARIABLE
B352  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
B354  26 F5                      BNE   LB34B               ; KEEP DIMENSIONING IF NOT END OF LINE
B356  39                         RTS
* EVALUATE A VARIABLE - RETURN X AND
* VARPTR POINTING TO VARIABLE DESCRIPTOR
* EACH VARIABLE REQUIRES 7 BYTES - THE FIRST TWO
* BYTES ARE THE VARIABLE NAME AND THE NEXT 5
* BYTES ARE THE DESCRIPTOR. IF BIT 7 OF THE
* FIRST BYTE OF VARlABLE NAME IS SET, THE
* VARIABLE IS A DEF FN VARIABLE. IF BIT 7 OF
* THE SECOND BYTE OF VARIABLE NAME IS SET, THE
* VARIABLE IS A STRING, OTHERWISE THE VARIABLE
* IS NUMERIC.
* IF THE VARIABLE IS NOT FOUND, A ZERO VARIABLE IS
* INSERTED INTO THE VARIABLE SPACE
B357  5F                LB357    CLRB                      ; DIMENSION FLAG = 0; DO NOT SET UP AN ARRAY
B358  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
B35A  D7 05             LB35A    STB   DIMFLG              ; SAVE ARRAY FLAG
B35C  97 37             LB35C    STA   VARNAM              ; SAVE INPUT CHARACTER [label LB35C moved here from $B35E: the ROM bytes of the code that references it point here]
* ENTRY POINT FOR DEF FN VARIABLE SEARCH
B35E  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
B360  8D 40                      BSR   LB3A2               ; SET CARRY IF NOT ALPHA
B362  10 25 FF 11                LBCS  LB277               ; SYNTAX ERROR IF NOT ALPHA
B366  5F                         CLRB                      ; DEFAULT 2ND VARIABLE CHARACTER TO ZERO
B367  D7 06                      STB   VALTYP              ; SET VARIABLE TYPE TO NUMERIC
B369  9D 9F                      JSR   GETNCH              ; GET ANOTHER CHARACTER FROM BASIC
B36B  25 04                      BCS   LB371               ; BRANCH IF NUMERIC (2ND CHARACTER IN
* VARIABLE MAY BE NUMERIC)
B36D  8D 33                      BSR   LB3A2               ; SET CARRY IF NOT ALPHA
B36F  25 0A                      BCS   LB37B               ; BRANCH IF NOT ALPHA
B371  1F 89             LB371    TFR   A,B                 ; SAVE 2ND CHARACTER IN ACCB
* READ INPUT CHARACTERS UNTIL A NON ALPHA OR
* NON NUMERIC IS FOUND - IGNORE ALL CHARACTERS
* IN VARIABLE NAME AFTER THE 1ST TWO
B373  9D 9F             LB373    JSR   GETNCH              ; GET AN INPUT CHARACTER
B375  25 FC                      BCS   LB373               ; BRANCH IF NUMERIC
B377  8D 29                      BSR   LB3A2               ; SET CARRY IF NOT ALPHA
B379  24 F8                      BCC   LB373               ; BRANCH IF ALPHA
B37B  81 24             LB37B    CMPA  #'$                 ; CHECK FOR A STRING VARIABLE
B37D  26 06                      BNE   LB385               ; BRANCH IF IT IS NOT A STRING
B37F  03 06                      COM   VALTYP              ; SET VARIABLE TYPE TO STRING
B381  CB 80                      ADDB  #$80                ; SET BIT 7 OF 2ND CHARACTER (STRING)
B383  9D 9F                      JSR   GETNCH              ; GET AN INPUT CHARACTER
B385  D7 38             LB385    STB   VARNAM+1            ; SAVE 2ND CHARACTER IN VARNAM+1
B387  9A 08                      ORA   ARYDIS              ; OR IN THE ARRAY DISABLE FLAG - IF = $80,
* DON'T SEARCH FOR VARIABLES IN THE ARRAYS
B389  80 28                      SUBA  #'(                 ; IS THIS AN ARRAY VARIABLE?
B38B  10 27 00 75                LBEQ  >LB404              ; BRANCH IF IT IS
B38F  0F 08                      CLR   ARYDIS              ; RESET THE ARRAY DISABLE FLAG
B391  9E 1B                      LDX   VARTAB              ; POINT X TO THE START OF VARIABLES
B393  DC 37                      LDD   VARNAM              ; GET VARIABLE IN QUESTION
B395  9C 1D             LB395    CMPX  ARYTAB              ; COMPARE X TO THE END OF VARIABLES
B397  27 12                      BEQ   LB3AB               ; BRANCH IF END OF VARIABLES
B399  10 A3 81                   CMPD  ,X++                ; * COMPARE VARIABLE IN QUESTION TO CURRENT
B39C  27 3E                      BEQ   LB3DC               ; * VARIABLE AND BRANCH IF MATCH
B39E  30 05                      LEAX  5,X                 ; = MOVE POINTER TO NEXT VARIABLE AND
B3A0  20 F3                      BRA   LB395               ; = KEEP LOOKING

* SET CARRY IF NOT UPPER CASE ALPHA
B3A2  81 41             LB3A2    CMPA  #'A                 ; * CARRY SET IF < 'A'
B3A4  25 04                      BCS   LB3AA               ; *
B3A6  80 5B                      SUBA  #'Z+1               ; =
B3A8  80 A5                      SUBA  #-('Z+1)            ; = CARRY CLEAR IF <= 'Z'
B3AA  39                LB3AA    RTS
* PUT A NEW VARIABLE IN TABLE OF VARIABLES
B3AB  8E 00 8A          LB3AB    LDX   #ZERO               ; POINT X TO ZERO LOCATION
B3AE  EE E4                      LDU   ,S                  ; GET CURRENT RETURN ADDRESS
B3B0  11 83 B2 87                CMPU  #LB287              ; DID WE COME FROM 'EVALUATE ALPHA EXPR'?
B3B4  27 28                      BEQ   LB3DE               ; YES - RETURN A ZERO VALUE
B3B6  DC 1F                      LDD   ARYEND              ; * GET END OF ARRAYS ADDRESS AND
B3B8  DD 43                      STD   V43                 ; * SAVE IT AT V43
B3BA  C3 00 07                   ADDD  #7                  ; = ADD 7 TO END OF ARRAYS (EACH
B3BD  DD 41                      STD   V41                 ; = VARIABLE = 7 BYTES) AND SAVE AT V41
B3BF  9E 1D                      LDX   ARYTAB              ; * GET END OF VARIABLES AND SAVE AT V47
B3C1  9F 47                      STX   V47                 ; *
B3C3  BD AC 1E                   JSR   LAC1E               ; MAKE A SEVEN BYTE SLOT FOR NEW VARIABLE AT
* TOP OF VARIABLES
B3C6  9E 41                      LDX   V41                 ; = GET NEW END OF ARRAYS AND SAVE IT
B3C8  9F 1F                      STX   ARYEND              ; =
B3CA  9E 45                      LDX   V45                 ; * GET NEW END OF VARIABLES AND SAVE IT
B3CC  9F 1D                      STX   ARYTAB              ; *
B3CE  9E 47                      LDX   V47                 ; GET OLD END OF VARIABLES
B3D0  DC 37                      LDD   VARNAM              ; GET NEW VARIABLE NAME
B3D2  ED 81                      STD   ,X++                ; SAVE VARIABLE NAME
B3D4  4F                         CLRA                      ; * ZERO OUT THE FP VALUE OF THE NUMERIC
B3D5  5F                         CLRB                      ; * VARIABLE OR THE LENGTH AND ADDRESS
B3D6  ED 84                      STD   ,X                  ; * OF A STRING VARIABLE
B3D8  ED 02                      STD   2,X                 ; *
B3DA  A7 04                      STA   4,X                 ; *
B3DC  9F 39             LB3DC    STX   VARPTR              ; STORE ADDRESS OF VARIABLE VALUE
B3DE  39                LB3DE    RTS
*
B3DF  90 80 00 00 00    LB3DF    FCB   $90,$80,$00,$00,$00 ; * FLOATING POINT -32768
* SMALLEST SIGNED TWO BYTE INTEGER
*
B3E4  9D 9F             LB3E4    JSR   GETNCH              ; GET AN INPUT CHARACTER FROM BASIC
B3E6  BD B1 41          LB3E6    JSR   LB141               ; GO EVALUATE NUMERIC EXPRESSION
B3E9  96 54             LB3E9    LDA   FP0SGN              ; GET FPA0 MANTISSA SIGN
B3EB  2B 5D                      BMI   LB44A               ; 'FC' ERROR IF NEGATIVE NUMBER
