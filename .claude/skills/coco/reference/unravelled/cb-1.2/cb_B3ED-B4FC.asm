; Color BASIC 1.2 -- $B3ED-$B4FC
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: INTCNV=$B3ED, IN COEFPT. RETURN RESULT IN ACCD, BS ERROR IF > $FFFF=$, MEM=$B4EE, GIVABF=$B4F4

* CONVERT FPA0 TO A SIGNED TWO BYTE INTEGER; RETURN VALUE IN ACCD
B3ED  BD B1 43          INTCNV   JSR   LB143               ; 'TM' ERROR IF STRING VARIABLE
B3F0  96 4F                      LDA   FP0EXP              ; GET FPA0 EXPONENT
B3F2  81 90                      CMPA  #$90                ; * COMPARE TO 32768 - LARGEST INTEGER EXPONENT AND
B3F4  25 08                      BCS   LB3FE               ; * BRANCH IF FPA0 < 32768
B3F6  8E B3 DF                   LDX   #LB3DF              ; POINT X TO FP VALUE OF -32768
B3F9  BD BC 96                   JSR   LBC96               ; COMPARE -32768 TO FPA0
B3FC  26 4C                      BNE   LB44A               ; 'FC' ERROR IF NOT =
B3FE  BD BC C8          LB3FE    JSR   LBCC8               ; CONVERT FPA0 TO A TWO BYTE INTEGER
B401  DC 52                      LDD   FPA0+2              ; GET THE INTEGER
B403  39                         RTS
* EVALUATE AN ARRAY VARIABLE
B404  DC 05             LB404    LDD   DIMFLG              ; GET ARRAY FLAG AND VARIABLE TYPE
B406  34 06                      PSHS  B,A                 ; SAVE THEM ON STACK
B408  12                         NOP                       ; DEAD SPACE CAUSED BY 1.2 REVISION
B409  5F                         CLRB                      ; RESET DIMENSION COUNTER
B40A  9E 37             LB40A    LDX   VARNAM              ; GET VARIABLE NAME
B40C  34 14                      PSHS  X,B                 ; SAVE VARIABLE NAME AND DIMENSION COUNTER
B40E  8D D4                      BSR   LB3E4               ; EVALUATE EXPRESSION (DIMENSlON LENGTH)
B410  35 34                      PULS  B,X,Y               ; PULL OFF VARIABLE NAME, DIMENSlON COUNTER,
* ARRAY FLAG
B412  9F 37                      STX   VARNAM              ; SAVE VARIABLE NAME AND VARIABLE TYPE
B414  DE 52                      LDU   FPA0+2              ; GET DIMENSION LENGTH
B416  34 60                      PSHS  U,Y                 ; SAVE DIMENSION LENGTH, ARRAY FLAG, VARIABLE TYPE
B418  5C                         INCB                      ; INCREASE DIMENSION COUNTER
B419  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
B41B  81 2C                      CMPA  #',                 ; CHECK FOR ANOTHER DIMENSION
B41D  27 EB                      BEQ   LB40A               ; BRANCH IF MORE
B41F  D7 03                      STB   TMPLOC              ; SAVE DIMENSION COUNTER
B421  BD B2 67                   JSR   LB267               ; SYNTAX CHECK FOR A ')'
B424  35 06                      PULS  A,B                 ; * RESTORE VARIABLE TYPE AND ARRAY
B426  DD 05                      STD   DIMFLG              ; * FLAG - LEAVE DIMENSION LENGTH ON STACK
B428  9E 1D                      LDX   ARYTAB              ; GET START OF ARRAYS
B42A  9C 1F             LB42A    CMPX  ARYEND              ; COMPARE TO END OF ARRAYS
B42C  27 21                      BEQ   LB44F               ; BRANCH IF NO MATCH FOUND
B42E  DC 37                      LDD   VARNAM              ; GET VARIABLE IN QUESTION
B430  10 A3 84                   CMPD  ,X                  ; COMPARE TO CURRENT VARIABLE
B433  27 06                      BEQ   LB43B               ; BRANCH IF =
B435  EC 02                      LDD   2,X                 ; GET OFFSET TO NEXT ARRAY VARIABLE
B437  30 8B                      LEAX  D,X                 ; ADD TO CURRENT POINTER
B439  20 EF                      BRA   LB42A               ; KEEP SEARCHING
B43B  C6 12             LB43B    LDB   #2*9                ; 'REDIMENSIONED ARRAY' ERROR
B43D  96 05                      LDA   DIMFLG              ; * TEST ARRAY FLAG - IF <>0 YOU ARE TRYING
B43F  26 0B                      BNE   LB44C               ; * TO REDIMENSION AN ARRAY
B441  D6 03                      LDB   TMPLOC              ; GET NUMBER OF DIMENSIONS IN ARRAY
B443  E1 04                      CMPB  4,X                 ; COMPARE TO THIS ARRAYS DIMENSIONS
B445  27 59                      BEQ   LB4A0               ; BRANCH IF =
B447  C6 10             LB447    LDB   #8*2                ; 'BAD SUBSCRIPT'
B449  8C                         FCB   SKP2                ; SKIP TWO BYTES
B44A  C6 08             LB44A    LDB   #4*2                ; 'ILLEGAL FUNCTION CALL'
B44C  7E AC 46          LB44C    JMP   LAC46               ; JUMP TO ERROR SERVICING ROUTINE

* INSERT A NEW ARRAY INTO ARRAY VARIABLES
* EACH SET OF ARRAY VARIABLES IS PRECEEDED BY A DE-
* SCRIPTOR BLOCK COMPOSED OF 5+2*N BYTES WHERE N IS THE
* NUMBER OF DIMENSIONS IN THE ARRAY. THE BLOCK IS DEFINED
* AS FOLLOWS: BYTES 0,1:VARIABLE'S NAME; 2,3:TOTAL LENGTH
* OF ARRAY ITEMS AND DESCRIPTOR BLOCK; 4:NUMBER OF DIMEN-
* ISIONS; 5,6:LENGTH OF DIMENSION 1; 7,8:LENGTH OF DIMEN-
* SION 2;… 4+N,5+N:LENGTH OF DIMENSION N.

B44F  CC 00 05          LB44F    LDD   #5                  ; * 5 BYTES/ARRAY ENTRY SAVE AT COEFPT
B452  DD 64                      STD   COEFPT              ; *
B454  DC 37                      LDD   VARNAM              ; = GET NAME OF ARRAY AND SAVE IN
B456  ED 84                      STD   ,X                  ; = FIRST 2 BYTES OF DESCRIPTOR
B458  D6 03                      LDB   TMPLOC              ; GET NUMBER OF DIMENSIONS AND SAVE IN
B45A  E7 04                      STB   4,X                 ; * 5TH BYTE OF DESCRIPTOR
B45C  BD AC 33                   JSR   LAC33               ; CHECK FOR ROOM FOR DESCRIPTOR IN FREE RAM
B45F  9F 41                      STX   V41                 ; TEMPORARILY SAVE DESCRIPTOR ADDRESS
B461  C6 0B             LB461    LDB   #11                 ; * DEFAULT DIMENSION VALUE:X(10)
B463  4F                         CLRA                      ; *
B464  0D 05                      TST   DIMFLG              ; = CHECK ARRAY FLAG AND BRANCH IF
B466  27 05                      BEQ   LB46D               ; = NOT DIMENSIONING AN ARRAY
B468  35 06                      PULS  A,B                 ; GET DIMENSION LENGTH
B46A  C3 00 01                   ADDD  #1                  ; ADD ONE (X(0) HAS A LENGTH OF ONE)
B46D  ED 05             LB46D    STD   5,X                 ; SAVE LENGTH OF ARRAY DIMENSION
B46F  8D 5D                      BSR   LB4CE               ; MULTIPLY ACCUM ARRAY SIZE NUMBER LENGTH
* OF NEW DIMENSION
B471  DD 64                      STD   COEFPT              ; TEMP STORE NEW CURRENT ACCUMULATED ARRAY SIZE
B473  30 02                      LEAX  2,X                 ; BUMP POINTER UP TWO
B475  0A 03                      DEC   TMPLOC              ; * DECREMENT DIMENSION COUNTER AND BRANCH IF
B477  26 E8                      BNE   LB461               ; * NOT DONE WITH ALL DIMENSIONS
B479  9F 0F                      STX   TEMPTR              ; SAVE ADDRESS OF (END OF ARRAY DESCRIPTOR - 5)
B47B  D3 0F                      ADDD  TEMPTR              ; ADD TOTAL SIZE OF NEW ARRAY
B47D  10 25 F7 C3                LBCS  LAC44               ; 'OM' ERROR IF > $FFFF
B481  1F 01                      TFR   D,X                 ; SAVE END OF ARRAY IN X
B483  BD AC 37                   JSR   LAC37               ; MAKE SURE THERE IS ENOUGH FREE RAM FOR ARRAY
B486  83 00 35                   SUBD  #STKBUF-5           ; SUBTRACT OUT THE (STACK BUFFER - 5)
B489  DD 1F                      STD   ARYEND              ; SAVE NEW END OF ARRAYS
B48B  4F                         CLRA                      ; ZERO = TERMINATOR BYTE
B48C  30 1F             LB48C    LEAX  -1,X                ; * STORE TWO TERMINATOR BYTES AT
B48E  A7 05                      STA   5,X                 ; * THE END OF THE ARRAY DESCRIPTOR
B490  9C 0F                      CMPX  TEMPTR              ; *
B492  26 F8                      BNE   LB48C               ; *
B494  9E 41                      LDX   V41                 ; GET ADDRESS OF START OF DESCRIPTOR
B496  96 1F                      LDA   ARYEND              ; GET MSB OF END OF ARRAYS; LSB ALREADY THERE
B498  93 41                      SUBD  V41                 ; SUBTRACT OUT ADDRESS OF START OF DESCRIPTOR
B49A  ED 02                      STD   2,X                 ; SAVE LENGTH OF (ARRAY AND DESCRIPTOR)
B49C  96 05                      LDA   DIMFLG              ; * GET ARRAY FLAG AND BRANCH
B49E  26 2D                      BNE   LB4CD               ; * BACK IF DIMENSIONING
* CALCULATE POINTER TO CORRECT ELEMENT
B4A0  E6 04             LB4A0    LDB   4,X                 ; GET THE NUMBER OF DIMENSIONS
B4A2  D7 03                      STB   TMPLOC              ; TEMPORARILY SAVE
B4A4  4F                         CLRA                      ; * INITIALIZE POINTER
B4A5  5F                         CLRB                      ; * TO ZERO
B4A6  DD 64             LB4A6    STD   COEFPT              ; SAVE ACCUMULATED POINTER
B4A8  35 06                      PULS  A,B                 ; * PULL DIMENSION ARGUMENT OFF THE
B4AA  DD 52                      STD   FPA0+2              ; * STACK AND SAVE IT
B4AC  10 A3 05                   CMPD  5,X                 ; COMPARE TO STORED 'DIM' ARGUMENT
B4AF  24 3A                      BCC   LB4EB               ; 'BS' ERROR IF > = "DIM" ARGUMENT
B4B1  DE 64                      LDU   COEFPT              ; * GET ACCUMULATED POINTER AND
B4B3  27 04                      BEQ   LB4B9               ; * BRANCH IF 1ST DIMENSION
B4B5  8D 17                      BSR   LB4CE               ; = MULTIPLY ACCUMULATED POINTER AND DIMENSION
B4B7  D3 52                      ADDD  FPA0+2              ; = LENGTH AND ADD TO CURRENT ARGUMENT
B4B9  30 02             LB4B9    LEAX  2,X                 ; MOVE POINTER TO NEXT DIMENSION
B4BB  0A 03                      DEC   TMPLOC              ; * DECREMENT DIMENSION COUNTER AND
B4BD  26 E7                      BNE   LB4A6               ; * BRANCH IF ANY DIMENSIONS LEFT
* MULTIPLY ACCD BY 5 - 5 BYTES/ARRAY VALUE
B4BF  ED E3                      STD   ,--S
B4C1  58                         ASLB
B4C2  49                         ROLA                      ; TIMES 2
B4C3  58                         ASLB
B4C4  49                         ROLA                      ; TIMES 4
B4C5  E3 E1                      ADDD  ,S++                ; TIMES 5
B4C7  30 8B                      LEAX  D,X                 ; ADD OFFSET TO START OF ARRAY
B4C9  30 05                      LEAX  5,X                 ; ADJUST POINTER FOR SIZE OF DESCRIPTOR
B4CB  9F 39                      STX   VARPTR              ; SAVE POINTER TO ARRAY VALUE
B4CD  39                LB4CD    RTS
* MULTIPLY 2 BYTE NUMBER IN 5,X BY THE 2 BYTE NUMBER
                        IN COEFPT. RETURN RESULT IN ACCD, BS ERROR IF > $FFFF
B4CE  86 10             LB4CE    LDA   #16                 ; 16 SHIFTS TO DO A MULTIPLY
B4D0  97 45                      STA   V45                 ; SHIFT COUNTER
B4D2  EC 05                      LDD   5,X                 ; * GET SIZE OF DIMENSION
B4D4  DD 17                      STD   BOTSTK              ; * AND SAVE IT
B4D6  4F                         CLRA                      ; * ZERO
B4D7  5F                         CLRB                      ; * ACCD
B4D8  58                LB4D8    ASLB                      ; = SHIFT ACCB LEFT
B4D9  49                         ROLA                      ; = ONE BIT
B4DA  25 0F                      BCS   LB4EB               ; 'BS' ERROR IF CARRY
B4DC  08 65                      ASL   COEFPT+1            ; * SHIFT MULTIPLICAND LEFT ONE
B4DE  09 64                      ROL   COEFPT              ; * BIT - ADD MULTIPLIER TO ACCUMULATOR
B4E0  24 04                      BCC   LB4E6               ; * IF CARRY <> 0
B4E2  D3 17                      ADDD  BOTSTK              ; ADD MULTIPLIER TO ACCD
B4E4  25 05                      BCS   LB4EB               ; 'BS' ERROR IF CARRY (>$FFFF)
B4E6  0A 45             LB4E6    DEC   V45                 ; * DECREMENT SHIFT COUNTER
B4E8  26 EE                      BNE   LB4D8               ; * IF NOT DONE
B4EA  39                         RTS
B4EB  7E B4 47          LB4EB    JMP   LB447               ; 'BS' ERROR
*
* MEM
* THIS IS NOT A TRUE INDICATOR OF FREE MEMORY BECAUSE
* BASIC REQUIRES A STKBUF SIZE BUFFER FOR THE STACK
* FOR WHICH MEM DOES NOT ALLOW.
*
B4EE  1F 40             MEM      TFR   S,D                 ; PUT STACK POINTER INTO ACCD
B4F0  93 1F                      SUBD  ARYEND              ; SUBTRACT END OF ARRAYS
B4F2  21                         FCB   SKP1                ; SKIP ONE BYTE
*CONVERT THE VALUE IN ACCB INTO A FP NUMBER IN FPA0
B4F3  4F                LB4F3    CLRA                      ; CLEAR MS BYTE OF ACCD
* CONVERT THE VALUE IN ACCD INTO A FLOATING POINT NUMBER IN FPA0
B4F4  0F 06             GIVABF   CLR   VALTYP              ; SET VARIABLE TYPE TO NUMERIC
B4F6  DD 50                      STD   FPA0                ; SAVE ACCD IN TOP OF FACA
B4F8  C6 90                      LDB   #$90                ; EXPONENT REQUIRED IF THE TOP TWO BYTES
* OF FPA0 ARE TO BE TREATED AS AN INTEGER IN FPA0
B4FA  7E BC 82                   JMP   LBC82               ; CONVERT THE REST OF FPA0 TO AN INTEGER
