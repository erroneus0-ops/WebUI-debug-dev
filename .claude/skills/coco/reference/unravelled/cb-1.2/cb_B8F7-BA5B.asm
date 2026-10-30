; Color BASIC 1.2 -- $B8F7-$BA5B
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: PRINT=$B8F7

* PRINT
B8F7  27 5F             PRINT    BEQ   LB958               ; BRANCH IF NO ARGUMENT
B8F9  8D 03                      BSR   LB8FE               ; CHECK FOR ALL PRINT OPTIONS
B8FB  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
B8FD  39                         RTS
B8FE  81 40             LB8FE    CMPA  #'@                 ; CHECK FOR PRINT @
B900  26 05                      BNE   LB907               ; NOT PRINT @
B902  BD A5 54                   JSR   LA554               ; MOVE CURSOR TO PROPER PRINT LOCATION
B905  20 0A                      BRA   LB911               ; GO PRINT THE DATA
B907  81 23             LB907    CMPA  #'#                 ; CHECK FOR PRINT NUMBER
B909  26 0D                      BNE   LB918               ; NOT PRINT#
B90B  BD A5 A5                   JSR   LA5A5               ; CHECK FOR A VALID DEVICE NUMBER
B90E  BD A4 06                   JSR   LA406               ; CHECK FOR A VALID OUTPUT FILE
B911  9D A5             LB911    JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
B913  27 43                      BEQ   LB958               ; BRANCH IF END OF LINE
B915  BD B2 6D                   JSR   LB26D               ; SYNTAX CHECK FOR COMMA
B918  BD 01 79          LB918    JSR   RVEC9               ; HOOK INTO RAM
B91B  27 48             LB91B    BEQ   LB965               ; RETURN IF END OF LINE
B91D  81 A4             LB91D    CMPA  #$A4                ; TOKEN FOR TAB( ?
B91F  27 5D                      BEQ   LB97E               ; YES
B921  81 2C                      CMPA  #',                 ; COMMA?
B923  27 41                      BEQ   LB966               ; YES - ADVANCE TO NEXT TAB FIELD
B925  81 3B                      CMPA  #';                 ; SEMICOLON?
B927  27 6E                      BEQ   LB997               ; YES - DO NOT ADVANCE CURSOR
B929  BD B1 56                   JSR   LB156               ; EVALUATE EXPRESSION
B92C  96 06                      LDA   VALTYP              ; * GET VARIABLE TYPE AND
B92E  34 02                      PSHS  A                   ; * SAVE IT ON THE STACK
B930  26 06                      BNE   LB938               ; BRANCH IF STRING VARIABLE
B932  BD BD D9                   JSR   LBDD9               ; CONVERT FP NUMBER TO AN ASCII STRING
B935  BD B5 16                   JSR   LB516               ; PARSE A STRING FROM (X-1) AND PUT
* DESCRIPTOR ON STRING STACK
B938  8D 65             LB938    BSR   LB99F               ; PRINT STRING POINTED TO BY X
B93A  35 04                      PULS  B                   ; GET VARIABLE TYPE BACK
B93C  BD A3 5F                   JSR   LA35F               ; SET UP TAB WIDTH ZONE, ETC
B93F  0D 6E                      TST   PRTDEV              ; * CHECK THE PRINT DEVICE
B941  27 06                      BEQ   LB949               ; * AND BRANCH IF NOT CASSETTE
B943  8D 13                      BSR   LB958               ; SEND A CARRIAGE RETURN TO CONSOLE OUT
B945  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
B947  20 D2                      BRA   LB91B               ; CHECK FOR MORE PRINT DATA
B949  5D                LB949    TSTB                      ; CHECK CURRENT PRINT POSITION
B94A  26 08                      BNE   LB954               ; BRANCH IF NOT AT START OF LINE
B94C  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
B94E  81 2C                      CMPA  #',                 ; COMMA?
B950  27 14                      BEQ   LB966               ; SKIP TO NEXT TAB FIELD
B952  8D 58                      BSR   LB9AC               ; SEND A SPACE TO CONSOLE OUT
B954  9D A5             LB954    JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
B956  26 C5                      BNE   LB91D               ; BRANCH IF NOT END OF LINE
B958  86 0D             LB958    LDA   #CR                 ; * SEND A CR TO
B95A  20 55                      BRA   LB9B1               ; * CONSOLE OUT
B95C  BD A3 5F          LB95C    JSR   LA35F               ; SET UP TAB WIDTH, ZONE ETC
B95F  27 F7                      BEQ   LB958               ; BRANCH IF WIDTH = ZERO
B961  96 6C                      LDA   DEVPOS              ; GET PRINT POSITION
B963  26 F3                      BNE   LB958               ; BRANCH IF NOT AT START OF LINE
B965  39                LB965    RTS
* SKIP TO NEXT TAB FIELD
B966  BD A3 5F          LB966    JSR   LA35F               ; SET UP TAB WIDTH, ZONE ETC
B969  27 0A                      BEQ   LB975               ; BRANCH IF LINE WIDTH = 0 (CASSETTE)
B96B  D6 6C                      LDB   DEVPOS              ; GET CURRENT POSITION
B96D  D1 6B                      CMPB  DEVLCF              ; COMPARE TO LAST TAB ZONE
B96F  25 06                      BCS   LB977               ; BRANCH IF < LAST TAB ZONE
B971  8D E5                      BSR   LB958               ; SEND A CARRIAGE RETURN TO CONSOLE OUT
B973  20 22                      BRA   LB997               ; GET MORE DATA
B975  D6 6C             LB975    LDB   DEVPOS              ; *
B977  D0 6A             LB977    SUBB  DEVCFW              ; * SUBTRACT TAB FIELD WIDTH FROM CURRENT
B979  24 FC                      BCC   LB977               ; * POSITION UNTIL CARRY SET - NEGATING THE
B97B  50                         NEGB                      ; * REMAINDER LEAVES THE NUMBER OF SPACES TO NEXT
* * TAB ZONE IN ACCB
B97C  20 10                      BRA   LB98E               ; GO ADVANCE TO NEXT TAB ZONE

* PRINT TAB(
B97E  BD B7 09          LB97E    JSR   LB709               ; EVALUATE EXPRESSION - RETURN VALUE IN B
B981  81 29                      CMPA  #')                 ; * 'SYNTAX' ERROR IF NOT ')'
B983  10 26 F8 F0                LBNE  LB277               ; *
B987  BD A3 5F                   JSR   LA35F               ; SET UP TAB WIDTH, ZONE ETC
B98A  D0 6C                      SUBB  DEVPOS              ; GET DIFFERENCE OF PRINT POSITION & TAB POSITION
B98C  23 09                      BLS   LB997               ; BRANCH IF TAB POSITION < CURRENT POSITION
B98E  0D 6E             LB98E    TST   PRTDEV              ; * GET PRINT DEVICE NUMBER AND
B990  26 05                      BNE   LB997               ; * BRANCH IF CASSETTE
B992  8D 18             LB992    BSR   LB9AC               ; SEND A SPACE TO CONSOLE OUT
B994  5A                         DECB                      ; DECREMENT DIFFERENCE COUNT
B995  26 FB                      BNE   LB992               ; BRANCH UNTIL CURRENT POSITION = TAB POSITION
B997  9D 9F             LB997    JSR   GETNCH              ; GET NEXT CHARACTER FROM BASIC
B999  7E B9 1B                   JMP   LB91B               ; LOOK FOR MORE PRINT DATA
* COPY A STRING FROM (X) TO CONSOLE OUT
B99C  BD B5 18          LB99C    JSR   LB518               ; PARSE A STRING FROM X AND PUT
* DESCRIPTOR ON STRING STACK
B99F  BD B6 57          LB99F    JSR   LB657               ; GET LENGTH OF STRING AND REMOVE
* DESCRIPTOR FROM STRING STACK
B9A2  5C                         INCB                      ; COMPENSATE FOR DECB BELOW
B9A3  5A                LB9A3    DECB                      ; DECREMENT COUNTER
B9A4  27 BF                      BEQ   LB965               ; EXIT ROUTINE
B9A6  A6 80                      LDA   ,X+                 ; GET A CHARACTER FROM X
B9A8  8D 07                      BSR   LB9B1               ; SEND TO CONSOLE OUT
B9AA  20 F7                      BRA   LB9A3               ; KEEP LOOPING
B9AC  86 20             LB9AC    LDA   #SPACE              ; SPACE TO CONSOLE OUT
B9AE  8C                         FCB   SKP2                ; SKIP NEXT TWO BYTES
B9AF  86 3F             LB9AF    LDA   #'?                 ; QUESTION MARK TO CONSOLE OUT
B9B1  7E A2 82          LB9B1    JMP   PUTCHR              ; JUMP TO CONSOLE OUT

* FLOATING POINT MATH PACKAGE

* ADD .5 TO FPA0
B9B4  8E BE C0          LB9B4    LDX   #LBEC0              ; FLOATING POINT CONSTANT (.5)
B9B7  20 09                      BRA   LB9C2               ; ADD .5 TO FPA0
* SUBTRACT FPA0 FROM FP NUMBER POINTED
* TO BY (X), LEAVE RESULT IN FPA0
B9B9  BD BB 2F          LB9B9    JSR   LBB2F               ; COPY PACKED FP DATA FROM (X) TO FPA1

* ARITHMETIC OPERATION (-) JUMPS HERE - SUBTRACT FPA0 FROM FPA1 (ENTER
* WITH EXPONENT OF FPA0 IN ACCB AND EXPONENT OF FPA1 IN ACCA)
B9BC  03 54             LB9BC    COM   FP0SGN              ; CHANGE MANTISSA SIGN OF FPA0
B9BE  03 62                      COM   RESSGN              ; REVERSE RESULT SIGN FLAG
B9C0  20 03                      BRA   LB9C5               ; GO ADD FPA1 AND FPA0
* ADD FP NUMBER POINTED TO BY
* (X) TO FPA0 - LEAVE RESULT IN FPA0
B9C2  BD BB 2F          LB9C2    JSR   LBB2F               ; UNPACK PACKED FP DATA FROM (X) TO
* FPA1; RETURN EXPONENT OF FPA1 IN ACCA

* ARITHMETIC OPERATION (+) JUMPS HERE - ADD FPA0 TO
* FPA1 (ENTER WITH EXPONENT OF FPA0 IN ACCB AND EXPONENT OF FPA1 IN ACCA
B9C5  5D                LB9C5    TSTB                      ; CHECK EXPONENT OF FPA0
B9C6  10 27 02 80                LBEQ  LBC4A               ; COPY FPA1 TO FPA0 IF FPA0 =  0
B9CA  8E 00 5C                   LDX   #FP1EXP             ; POINT X TO FPA1
B9CD  1F 89             LB9CD    TFR   A,B                 ; PUT EXPONENT OF FPA1 INTO ACCB
B9CF  5D                         TSTB                      ; CHECK EXPONENT
B9D0  27 6C                      BEQ   LBA3E               ; RETURN IF EXPONENT = 0 (ADDING 0 TO FPA0)
B9D2  D0 4F                      SUBB  FP0EXP              ; SUBTRACT EXPONENT OF FPA0 FROM EXPONENT OF FPA1
B9D4  27 69                      BEQ   LBA3F               ; BRANCH IF EXPONENTS ARE EQUAL
B9D6  25 0A                      BCS   LB9E2               ; BRANCH IF EXPONENT FPA0 > FPA1
B9D8  97 4F                      STA   FP0EXP              ; REPLACE FPA0 EXPONENT WITH FPA1 EXPONENT
B9DA  96 61                      LDA   FP1SGN              ; * REPLACE FPA0 MANTISSA SIGN
B9DC  97 54                      STA   FP0SGN              ; * WITH FPA1 MANTISSA SIGN
B9DE  8E 00 4F                   LDX   #FP0EXP             ; POINT X TO FPA0
B9E1  50                         NEGB                      ; NEGATE DIFFERENCE OF EXPONENTS
B9E2  C1 F8             LB9E2    CMPB  #-8                 ; TEST DIFFERENCE OF EXPONENTS
B9E4  2F 59                      BLE   LBA3F               ; BRANCH IF DIFFERENCE OF EXPONENTS <= 8
B9E6  4F                         CLRA                      ; CLEAR OVERFLOW BYTE
B9E7  64 01                      LSR   1,X                 ; SHIFT MS BYTE OF MANTISSA; BIT 7 = 0
B9E9  BD BA BA                   JSR   LBABA               ; GO SHIFT MANTISSA OF (X) TO THE RIGHT (B) TIMES
B9EC  D6 62             LB9EC    LDB   RESSGN              ; GET SIGN FLAG
B9EE  2A 0B                      BPL   LB9FB               ; BRANCH IF FPA0 AND FPA1 SIGNS ARE THE SAME
B9F0  63 01                      COM   1,X                 ; * COMPLEMENT MANTISSA POINTED
B9F2  63 02                      COM   2,X                 ; * TO BY (X) THE
B9F4  63 03                      COM   3,X                 ; * ADCA BELOW WILL
B9F6  63 04                      COM   4,X                 ; * CONVERT THIS OPERATION
B9F8  43                         COMA                      ; * INTO A NEG (MANTISSA)
B9F9  89 00                      ADCA  #0                  ; ADD ONE TO ACCA - COMA ALWAYS SETS THE CARRY FLAG
* THE PREVIOUS TWO BYTES MAY BE REPLACED BY A NEGA
*
* ADD MANTISSAS OF FPA0 AND FPA1, PUT RESULT IN FPA0
B9FB  97 63             LB9FB    STA   FPSBYT              ; SAVE FPA SUB BYTE
B9FD  96 53                      LDA   FPA0+3              ; * ADD LS BYTE
B9FF  99 60                      ADCA  FPA1+3              ; * OF MANTISSA
BA01  97 53                      STA   FPA0+3              ; SAVE IN FPA0 LSB
BA03  96 52                      LDA   FPA0+2              ; * ADD NEXT BYTE
BA05  99 5F                      ADCA  FPA1+2              ; * OF MANTISSA
BA07  97 52                      STA   FPA0+2              ; SAVE IN FPA0
BA09  96 51                      LDA   FPA0+1              ; * ADD NEXT BYTE
BA0B  99 5E                      ADCA  FPA1+1              ; * OF MANTISSA
BA0D  97 51                      STA   FPA0+1              ; SAVE IN FPA0
BA0F  96 50                      LDA   FPA0                ; * ADD MS BYTE
BA11  99 5D                      ADCA  FPA1                ; * OF MANTISSA
BA13  97 50                      STA   FPA0                ; SAVE IN FPA0
BA15  5D                         TSTB                      ; TEST SIGN FLAG
BA16  2A 44                      BPL   LBA5C               ; BRANCH IF FPA0 & FPA1 SIGNS WERE ALIKE
BA18  25 02             LBA18    BCS   LBA1C               ; BRANCH IF POSITIVE MANTISSA
BA1A  8D 5D                      BSR   LBA79               ; NEGATE FPA0 MANTISSA

* NORMALIZE FPA0
BA1C  5F                LBA1C    CLRB                      ; CLEAR TEMPORARY EXPONENT ACCUMULATOR
BA1D  96 50             LBA1D    LDA   FPA0                ; TEST MSB OF MANTISSA
BA1F  26 2E                      BNE   LBA4F               ; BRANCH IF <> 0
BA21  96 51                      LDA   FPA0+1              ; * IF THE MSB IS
BA23  97 50                      STA   FPA0                ; * 0, THEN SHIFT THE
BA25  96 52                      LDA   FPA0+2              ; * MANTISSA A WHOLE BYTE
BA27  97 51                      STA   FPA0+1              ; * AT A TIME. THIS
BA29  96 53                      LDA   FPA0+3              ; * IS FASTER THAN ONE
BA2B  97 52                      STA   FPA0+2              ; * BIT AT A TIME
BA2D  96 63                      LDA   FPSBYT              ; * BUT USES MORE MEMORY.
BA2F  97 53                      STA   FPA0+3              ; * FPSBYT, THE CARRY IN
BA31  0F 63                      CLR   FPSBYT              ; * BYTE, REPLACES THE MATISSA LSB.
BA33  CB 08                      ADDB  #8                  ; SHIFTING ONE BYTE = 8 BIT SHIFTS; ADD 8 TO EXPONENT
BA35  C1 28                      CMPB  #5*8                ; CHECK FOR 5 SHIFTS
BA37  2D E4                      BLT   LBA1D               ; BRANCH IF < 5 SHIFTS, IF > 5, THEN MANTISSA = 0
BA39  4F                LBA39    CLRA                      ; A ZERO EXPONENT = 0 FLOATING POINT
BA3A  97 4F             LBA3A    STA   FP0EXP              ; ZERO OUT THE EXPONENT
BA3C  97 54                      STA   FP0SGN              ; ZERO OUT THE MANTISSA SIGN
BA3E  39                LBA3E    RTS
BA3F  8D 6D             LBA3F    BSR   LBAAE               ; SHIFT FPA0 MANTISSA TO RIGHT
BA41  5F                         CLRB                      ; CLEAR CARRY FLAG
BA42  20 A8                      BRA   LB9EC
* SHIFT FPA0 LEFT ONE BIT UNTIL BIT 7
* OF MATISSA MS BYTE = 1
BA44  5C                LBA44    INCB                      ; ADD ONE TO EXPONENT ACCUMULATOR
BA45  08 63                      ASL   FPSBYT              ; SHIFT SUB BYTE ONE LEFT
BA47  09 53                      ROL   FPA0+3              ; SHIFT LS BYTE
BA49  09 52                      ROL   FPA0+2              ; SHIFT NS BYTE
BA4B  09 51                      ROL   FPA0+1              ; SHIFT NS BYTE
BA4D  09 50                      ROL   FPA0                ; SHIFT MS BYTE
BA4F  2A F3             LBA4F    BPL   LBA44               ; BRANCH IF NOT YET NORMALIZED
BA51  96 4F                      LDA   FP0EXP              ; GET CURRENT EXPONENT
BA53  34 04                      PSHS  B                   ; SAVE EXPONENT MODIFIER CAUSED BY NORMALIZATION
BA55  A0 E0                      SUBA  ,S+                 ; SUBTRACT ACCUMULATED EXPONENT MODIFIER
BA57  97 4F                      STA   FP0EXP              ; SAVE AS NEW EXPONENT
BA59  23 DE                      BLS   LBA39               ; SET FPA0 = 0 IF THE NORMALIZATION CAUSED
* MORE OR EQUAL NUMBER OF LEFT SHIFTS THAN THE
* SIZE OF THE EXPONENT
BA5B  8C                         FCB   SKP2                ; SKIP 2 BYTES
