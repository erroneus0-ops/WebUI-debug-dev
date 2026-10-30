; Color BASIC 1.2 -- $BCEE-$BE4A
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: INT=$BCEE

* INT
* THE INT STATEMENT WILL "DENORMALIZE" FPA0 - THAT IS IT WILL SHIFT THE BINARY POINT
* TO THE EXTREME RIGHT OF THE MANTISSA TO FORCE ITS EXPONENT TO BE $AO. ONCE
* THIS IS DONE THE MANTISSA OF FPA0 WILL CONTAIN THE FOUR LEAST SIGNIFICANT
* BYTES OF THE INTEGER PORTION OF FPA0. AT THE CONCLUSION OF THE DE-NORMALIZATION
* ONLY THE INTEGER PORTION OF FPA0 WILL REMAIN.
*
BCEE  D6 4F             INT      LDB   FP0EXP              ; GET EXPONENT OF FPA0
BCF0  C1 A0                      CMPB  #$A0                ; LARGEST POSSIBLE INTEGER EXPONENT
BCF2  24 1D                      BCC   LBD11               ; RETURN IF FPA0 >= 32768
BCF4  8D D2                      BSR   LBCC8               ; SHIFT THE BINARY POINT ONE TO THE RIGHT OF THE
* LS BYTE OF THE FPA0 MANTISSA
BCF6  D7 63                      STB   FPSBYT              ; ACCB = 0: ZERO OUT THE SUB BYTE
BCF8  96 54                      LDA   FP0SGN              ; GET MANTISSA SIGN
BCFA  D7 54                      STB   FP0SGN              ; FORCE MANTISSA SIGN TO BE POSITIVE
BCFC  80 80                      SUBA  #$80                ; SET CARRY IF MANTISSA
BCFE  86 A0                      LDA   #$A0                ; * GET DENORMALIZED EXPONENT AND
BD00  97 4F                      STA   FP0EXP              ; * SAVE IT IN FPA0 EXPONENT
BD02  96 53                      LDA   FPA0+3              ; = GET LS BYTE OF FPA0 AND
BD04  97 01                      STA   CHARAC              ; = SAVE IT IN CHARAC
BD06  7E BA 18                   JMP   LBA18               ; NORMALIZE FPA0

BD09  D7 50             LBD09    STB   FPA0                ; * LOAD MANTISSA OF FPA0 WITH CONTENTS OF ACCB
BD0B  D7 51                      STB   FPA0+1              ; *
BD0D  D7 52                      STB   FPA0+2              ; *
BD0F  D7 53                      STB   FPA0+3              ; *
BD11  39                LBD11    RTS                       ; *

* CONVERT ASCII STRING TO FLOATING POINT
BD12  9E 8A             LBD12    LDX   ZERO                ; (X) = 0
BD14  9F 54                      STX   FP0SGN              ; * ZERO OUT FPA0 & THE SIGN FLAG (COEFCT)
BD16  9F 4F                      STX   FP0EXP              ; *
BD18  9F 51                      STX   FPA0+1              ; *
BD1A  9F 52                      STX   FPA0+2              ; *
BD1C  9F 47                      STX   V47                 ; INITIALIZE EXPONENT & EXPONENT SIGN FLAG TO ZERO
BD1E  9F 45                      STX   V45                 ; INITIALIZE RIGHT DECIMAL CTR & DECIMAL PT FLAG TO 0
BD20  25 64                      BCS   LBD86               ; IF CARRY SET (NUMERIC CHARACTER), ASSUME ACCA CONTAINS FIRST
* NUMERIC CHAR, SIGN IS POSITIVE AND SKIP THE RAM HOOK
BD22  BD 01 97                   JSR   RVEC19              ; HOOK INTO RAM
BD25  81 2D                      CMPA  #'-                 ; * CHECK FOR A LEADING MINUS SIGN AND BRANCH
BD27  26 04                      BNE   LBD2D               ; * IF NO MINUS SIGN
BD29  03 55                      COM   COEFCT              ; TOGGLE SIGN; 0 = +; FF = -
BD2B  20 04                      BRA   LBD31               ; INTERPRET THE REST OF THE STRING
BD2D  81 2B             LBD2D    CMPA  #'+                 ; * CHECK FOR LEADING PLUS SlGN AND BRANCH
BD2F  26 04                      BNE   LBD35               ; * IF NOT A PLUS SIGN
BD31  9D 9F             LBD31    JSR   GETNCH              ; GET NEXT INPUT CHARACTER FROM BASIC
BD33  25 51                      BCS   LBD86               ; BRANCH IF NUMERIC CHARACTER
BD35  81 2E             LBD35    CMPA  #'.                 ; DECIMAL POlNT?
BD37  27 28                      BEQ   LBD61               ; YES
BD39  81 45                      CMPA  #'E                 ; "E" SHORTHAND FORM (SCIENTIFIC NOTATION)?
BD3B  26 28                      BNE   LBD65               ; NO
* EVALUATE EXPONENT OF EXPONENTIAL FORMAT
BD3D  9D 9F                      JSR   GETNCH              ; GET NEXT INPUT CHARACTER FROM BASIC
BD3F  25 64                      BCS   LBDA5               ; BRANCH IF NUMERIC
BD41  81 AC                      CMPA  #$AC                ; MINUS TOKEN?
BD43  27 0E                      BEQ   LBD53               ; YES
BD45  81 2D                      CMPA  #'-                 ; ASCII MINUS?
BD47  27 0A                      BEQ   LBD53               ; YES
BD49  81 AB                      CMPA  #$AB                ; PLUS TOKEN?
BD4B  27 08                      BEQ   LBD55               ; YES
BD4D  81 2B                      CMPA  #'+                 ; ASCII PLUS?
BD4F  27 04                      BEQ   LBD55               ; YES
BD51  20 06                      BRA   LBD59               ; BRANCH IF NO SIGN FOUND
BD53  03 48             LBD53    COM   V48                 ; SET EXPONENT SIGN FLAG TO NEGATIVE
* STRIP A DECIMAL NUMBER FROM BASIC LINE, CONVERT IT TO BINARY IN V47
BD55  9D 9F             LBD55    JSR   GETNCH              ; GET NEXT INPUT CHARACTER FROM BASIC
BD57  25 4C                      BCS   LBDA5               ; IF NUMERIC CHARACTER, CONVERT TO BINARY
BD59  0D 48             LBD59    TST   V48                 ; * CHECK EXPONENT SIGN FLAG
BD5B  27 08                      BEQ   LBD65               ; * AND BRANCH IF POSITIVE
BD5D  00 47                      NEG   V47                 ; NEGATE VALUE OF EXPONENT
BD5F  20 04                      BRA   LBD65
BD61  03 46             LBD61    COM   V46                 ; *TOGGLE DECIMAL PT FLAG AND INTERPRET ANOTHER
BD63  26 CC                      BNE   LBD31               ; *CHARACTER IF <> 0 - TERMINATE INTERPRETATION
* IF SECOND DECIMAL POINT
* ADJUST FPA0 FOR THE DECIMAL EXPONENT IN V47
BD65  96 47             LBD65    LDA   V47                 ; * GET EXPONENT, SUBTRACT THE NUMBER OF
BD67  90 45                      SUBA  V45                 ; * PLACES TO THE RIGHT OF DECIMAL POINT
BD69  97 47                      STA   V47                 ; * AND RESAVE IT.
BD6B  27 12                      BEQ   LBD7F               ; EXIT ROUTINE IF ADJUSTED EXPONENT = ZERO
BD6D  2A 09                      BPL   LBD78               ; BRANCH IF POSITIVE EXPONENT
BD6F  BD BB 82          LBD6F    JSR   LBB82               ; DIVIDE FPA0 BY 10
BD72  0C 47                      INC   V47                 ; INCREMENT EXPONENT COUNTER (MULTIPLY BY 10)
BD74  26 F9                      BNE   LBD6F               ; KEEP MULTIPLYING
BD76  20 07                      BRA   LBD7F               ; EXIT ROUTINE
BD78  BD BB 6A          LBD78    JSR   LBB6A               ; MULTIPLY FPA0 BY 10
BD7B  0A 47                      DEC   V47                 ; DECREMENT EXPONENT COUNTER (DIVIDE BY 10)
BD7D  26 F9                      BNE   LBD78               ; KEEP MULTIPLYING
BD7F  96 55             LBD7F    LDA   COEFCT              ; GET THE SIGN FLAG
BD81  2A 8E                      BPL   LBD11               ; RETURN IF POSITIVE
BD83  7E BE E9                   JMP   LBEE9               ; TOGGLE MANTISSA SIGN OF FPA0, IF NEGATIVE
*MULTIPLY FPA0 BY TEN AND ADD ACCA TO THE RESULT
BD86  D6 45             LBD86    LDB   V45                 ; *GET THE RIGHT DECIMAL COUNTER AND SUBTRACT
BD88  D0 46                      SUBB  V46                 ; *THE DECIMAL POINT FLAG FROM IT. IF DECIMAL POINT
BD8A  D7 45                      STB   V45                 ; *FLAG=0, NOTHING HAPPENS. IF DECIMAL POINT FLAG IS
* -1, THEN RIGHT DECIMAL COUNTER IS INCREMENTED BY ONE
BD8C  34 02                      PSHS  A                   ; SAVE NEW DIGIT ON STACK
BD8E  BD BB 6A                   JSR   LBB6A               ; MULTIPLY FPA0 BY 10
BD91  35 04                      PULS  B                   ; GET NEW DIGIT BACK
BD93  C0 30                      SUBB  #'0                 ; MASK OFF ASCII
BD95  8D 02                      BSR   LBD99               ; ADD ACCB TO FPA0
BD97  20 98                      BRA   LBD31               ; GET ANOTHER CHARACTER FROM BASIC
BD99  BD BC 2F          LBD99    JSR   LBC2F               ; PACK FPA0 AND SAVE IT IN FPA3
BD9C  BD BC 7C                   JSR   LBC7C               ; CONVERT ACCB TO FP NUMBER IN FPA0
BD9F  8E 00 40                   LDX   #V40                ; * ADD FPA0 TO
BDA2  7E B9 C2                   JMP   LB9C2               ; * FPA3
* MULTIPLY V47 BY 10 AND ADD TO ASCII NUMBER IN
* ACCA - SAVE BINARY RESULT IN V47
BDA5  D6 47             LBDA5    LDB   V47
BDA7  58                         ASLB                      ; TIMES 2
BDA8  58                         ASLB                      ; TIMES 4
BDA9  DB 47                      ADDB  V47                 ; ADD 1 = TIMES 5
BDAB  58                         ASLB                      ; TIMES 10
BDAC  80 30                      SUBA  #'0                 ; *MASK OFF ASCII FROM ACCA, PUSH
BDAE  34 04                      PSHS  B                   ; *RESULT ONTO THE STACK AND
BDB0  AB E0                      ADDA  ,S+                 ; ADD lT TO ACCB
BDB2  97 47                      STA   V47                 ; SAVE IN V47
BDB4  20 9F                      BRA   LBD55               ; INTERPRET ANOTHER CHARACTER
*
BDB6  9B 3E BC 1F FD    LBDB6    FCB   $9B,$3E,$BC,$1F,$FD ; * 99999999.9
BDBB  9E 6E 6B 27 FD    LBDBB    FCB   $9E,$6E,$6B,$27,$FD ; * 999999999
BDC0  9E 6E 6B 28 00    LBDC0    FCB   $9E,$6E,$6B,$28,$00 ; * 1E + 09
*
BDC5  8E AB E7          LBDC5    LDX   #LABE8-1            ; POINT X TO " IN " MESSAGE
BDC8  8D 0C                      BSR   LBDD6               ; COPY A STRING FROM (X) TO CONSOLE OUT
BDCA  DC 68                      LDD   CURLIN              ; GET CURRENT BASIC LINE NUMBER TO ACCD
* CONVERT VALUE IN ACCD INTO A DECIMAL NUMBER
* AND PRINT IT TO CONSOLE OUT
BDCC  DD 50             LBDCC    STD   FPA0                ; SAVE ACCD IN TOP HALF OF FPA0
BDCE  C6 90                      LDB   #$90                ; REQ'D EXPONENT IF TOP HALF OF ACCD = INTEGER
BDD0  43                         COMA                      ; SET CARRY FLAG - FORCE POSITIVE MANTISSA
BDD1  BD BC 86                   JSR   LBC86               ; ZERO BOTTOM HALF AND SIGN OF FPA0, THEN
* SAVE EXPONENT AND NORMALIZE IT
BDD4  8D 03                      BSR   LBDD9               ; CONVERT FP NUMBER TO ASCII STRING
BDD6  7E B9 9C          LBDD6    JMP   LB99C               ; COPY A STRING FROM (X) TO CONSOLE OUT

* CONVERT FP NUMBER TO ASCII STRING
BDD9  CE 03 DA          LBDD9    LDU   #STRBUF+3           ; POINT U TO BUFFER WHICH WILL NOT CAUSE
* THE STRING TO BE STORED IN STRING SPACE
BDDC  86 20             LBDDC    LDA   #SPACE              ; SPACE = DEFAULT SIGN FOR POSITIVE #
BDDE  D6 54                      LDB   FP0SGN              ; GET SIGN OF FPA0
BDE0  2A 02                      BPL   LBDE4               ; BRANCH IF POSITIVE
BDE2  86 2D                      LDA   #'-                 ; ASCII MINUS SIGN
BDE4  A7 C0             LBDE4    STA   ,U+                 ; STORE SIGN OF NUMBER
BDE6  DF 64                      STU   COEFPT              ; SAVE BUFFER POINTER
BDE8  97 54                      STA   FP0SGN              ; SAVE SIGN (IN ASCII)
BDEA  86 30                      LDA   #'0                 ; ASCII ZERO IF EXPONENT = 0
BDEC  D6 4F                      LDB   FP0EXP              ; GET FPA0 EXPONENT
BDEE  10 27 00 C6                LBEQ  LBEB8               ; BRANCH IF FPA0 = 0
BDF2  4F                         CLRA                      ; BASE 10 EXPONENT=0 FOR FP NUMBER > 1
BDF3  C1 80                      CMPB  #$80                ; CHECK EXPONENT
BDF5  22 08                      BHI   LBDFF               ; BRANCH IF FP NUMBER > 1
* IF FPA0 < 1.0, MULTIPLY IT BY 1E+09 TO SPEED UP THE CONVERSION PROCESS
BDF7  8E BD C0                   LDX   #LBDC0              ; POINT X TO FP 1E+09
BDFA  BD BA CA                   JSR   LBACA               ; MULTIPLY FPA0 BY (X)
BDFD  86 F7                      LDA   #-9                 ; BASE 10 EXPONENT = -9
BDFF  97 45             LBDFF    STA   V45                 ; BASE 10 EXPONENT
* PSEUDO - NORMALIZE THE FP NUMBER TO A VALUE IN THE RANGE
* OF 999,999,999 RO 99,999,999.9 - THIS IS THE LARGEST
* NUMBER RANGE IN WHICH ALL OF THE DIGITS ARE
* SIGNIFICANT WHICH CAN BE DISPLAYED WITHOUT USING
* SCIENTIFIC NOTATION
BE01  8E BD BB          LBE01    LDX   #LBDBB              ; POINT X TO FP 999,999,999
BE04  BD BC A0                   JSR   LBCA0               ; COMPARE FPA0 TO 999,999,999
BE07  2E 0F                      BGT   LBE18               ; BRANCH IF > 999,999,999
BE09  8E BD B6          LBE09    LDX   #LBDB6              ; POINT X TO FP 99,999,999.9
BE0C  BD BC A0                   JSR   LBCA0               ; COMPARE FPA0 TO 99,999,999.9
BE0F  2E 0E                      BGT   LBE1F               ; BRANCH IF > 99,999,999.9 (IN RANGE)
BE11  BD BB 6A                   JSR   LBB6A               ; MULTIPLY FPA0 BY 10
BE14  0A 45                      DEC   V45                 ; SUBTRACT ONE FROM DECIMAL OFFSET
BE16  20 F1                      BRA   LBE09               ; PSEUDO - NORMALIZE SOME MORE
BE18  BD BB 82          LBE18    JSR   LBB82               ; DIVIDE FPA0 BY 10
BE1B  0C 45                      INC   V45                 ; ADD ONE TO BASE 10 EXPONENT
BE1D  20 E2                      BRA   LBE01               ; PSEUDO - NORMALIZE SOME MORE
BE1F  BD B9 B4          LBE1F    JSR   LB9B4               ; ADD .5 TO FPA0 (ROUND OFF)
BE22  BD BC C8                   JSR   LBCC8               ; CONVERT FPA0 TO AN INTEGER
BE25  C6 01                      LDB   #1                  ; DEFAULT DECIMAL POINT FLAG (FORCE IMMED DECIMAL PT)
BE27  96 45                      LDA   V45                 ; * GET BASE 10 EXPONENT AND ADD TEN TO IT
BE29  8B 0A                      ADDA  #9+1                ; * (NUMBER 'NORMALIZED' TO 9 PLACES & DECIMAL PT)
BE2B  2B 09                      BMI   LBE36               ; BRANCH IF NUMBER < 1.0
BE2D  81 0B                      CMPA  #9+2                ; NINE PLACES MAY BE DISPLAYED WITHOUT
* USING SCIENTIFIC NOTATION
BE2F  24 05                      BCC   LBE36               ; BRANCH IF SCIENTIFIC NOTATION REQUIRED
BE31  4A                         DECA                      ; * SUBTRACT 1 FROM MODIFIED BASE 10 EXPONENT CTR
BE32  1F 89                      TFR   A,B                 ; * AND SAVE IT IN ACCB (DECiMAL POINT FLAG)
BE34  86 02                      LDA   #2                  ; FORCE EXPONENT = 0 - DON'T USE SCIENTIFIC NOTATION
BE36  4A                LBE36    DECA                      ; * SUBTRACT TWO (WITHOUT AFFECTING CARRY)
BE37  4A                         DECA                      ; * FROM BASE 10 EXPONENT
BE38  97 47                      STA   V47                 ; SAVE EXPONENT - ZERO EXPONENT = DO NOT DISPLAY
* IN SCIENTIFIC NOTATION
BE3A  D7 45                      STB   V45                 ; DECIMAL POINT FLAG - NUMBER OF PLACES TO
* LEFT OF DECIMAL POINT
BE3C  2E 0D                      BGT   LBE4B               ; BRANCH IF >= 1
BE3E  DE 64                      LDU   COEFPT              ; POINT U TO THE STRING BUFFER
BE40  86 2E                      LDA   #'.                 ; * STORE A PERIOD
BE42  A7 C0                      STA   ,U+                 ; * IN THE BUFFER
BE44  5D                         TSTB                      ; CHECK DECIMAL POINT FLAG
BE45  27 04                      BEQ   LBE4B               ; BRANCH IF NOTHING TO LEFT OF DECIMAL POINT
BE47  86 30                      LDA   #'0                 ; * STORE A ZERO
BE49  A7 C0                      STA   ,U+                 ; * IN THE BUFFER
