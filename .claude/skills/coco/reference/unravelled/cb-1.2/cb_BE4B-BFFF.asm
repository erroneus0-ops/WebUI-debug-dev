; Color BASIC 1.2 -- $BE4B-$BFFF
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: RND=$BF1F, RSEED=$BF74, SIN=$BF78

* CONVERT FPA0 INTO A STRING OF ASCII DIGITS
BE4B  8E BE C5          LBE4B    LDX   #LBEC5              ; POINT X TO FP POWER OF 10 MANTISSA
BE4E  C6 80                      LDB   #0+$80              ; INITIALIZE DIGIT COUNTER TO 0+$80
* BIT 7 SET IS USED TO INDICATE THAT THE POWER OF 10 MANTISSA
* IS NEGATIVE. WHEN YOU 'ADD' A NEGATIVE MANTISSA, IT IS
* THE SAME AS SUBTRACTING A POSITIVE ONE AND BIT 7 OF ACCB IS HOW
* THE ROUTINE KNOWS THAT A 'SUBTRACTION' IS OCCURING.
BE50  96 53             LBE50    LDA   FPA0+3              ; * ADD MANTISSA LS
BE52  AB 03                      ADDA  3,X                 ; * BYTE OF FPA0
BE54  97 53                      STA   FPA0+3              ; * AND (X)
BE56  96 52                      LDA   FPA0+2              ; = ADD MANTISSA
BE58  A9 02                      ADCA  2,X                 ; = NUMBER 3 BYTE OF
BE5A  97 52                      STA   FPA0+2              ; = FPA0 AND (X)
BE5C  96 51                      LDA   FPA0+1              ; * ADD MANTISSA
BE5E  A9 01                      ADCA  1,X                 ; * NUMBER 2 BYTE OF
BE60  97 51                      STA   FPA0+1              ; * FPA0 AND (X)
BE62  96 50                      LDA   FPA0                ; = ADD MANTISSA
BE64  A9 84                      ADCA  ,X                  ; = MS BYTE OF
BE66  97 50                      STA   FPA0                ; = FPA0 AND (X)
BE68  5C                         INCB                      ; ADD ONE TO DIGIT COUNTER
BE69  56                         RORB                      ; ROTATE CARRY INTO BIT 7
BE6A  59                         ROLB                      ; *SET OVERFLOW FLAG AND BRANCH IF CARRY = 1 AND
BE6B  28 E3                      BVC   LBE50               ; *POSITIVE MANTISSA OR CARRY = 0 AND NEG MANTISSA
BE6D  24 03                      BCC   LBE72               ; BRANCH IF NEGATIVE MANTISSA
BE6F  C0 0B                      SUBB  #10+1               ; * TAKE THE 9'S COMPLEMENT IF
BE71  50                         NEGB                      ; * ADDING MANTISSA
BE72  CB 2F             LBE72    ADDB  #'0-1               ; ADD ASCII OFFSET TO DIGIT
BE74  30 04                      LEAX  4,X                 ; MOVE TO NEXT POWER OF 10 MANTISSA
BE76  1F 98                      TFR   B,A                 ; SAVE DIGIT IN ACCA
BE78  84 7F                      ANDA  #$7F                ; MASK OFF BIT 7 (ADD/SUBTRACT FLAG)
BE7A  A7 C0                      STA   ,U+                 ; STORE DIGIT IN STRING BUFFER
BE7C  0A 45                      DEC   V45                 ; DECREMENT DECIMAL POINT FLAG
BE7E  26 04                      BNE   LBE84               ; BRANCH IF NOT TIME FOR DECIMAL POINT
BE80  86 2E                      LDA   #'.                 ; * STORE DECIMAL POINT IN
BE82  A7 C0                      STA   ,U+                 ; * STRING BUFFER
BE84  53                LBE84    COMB                      ; TOGGLE BIT 7 (ADD/SUBTRACT FLAG)
BE85  C4 80                      ANDB  #$80                ; MASK OFF ALL BUT ADD/SUBTRACT FLAG
BE87  8C BE E9                   CMPX  #LBEC5+9*4          ; COMPARE X TO END OF MANTISSA TABLE
BE8A  26 C4                      BNE   LBE50               ; BRANCH IF NOT AT END OF TABLE
* BLANK TRAILING ZEROS AND STORE EXPONENT IF ANY
BE8C  A6 C2             LBE8C    LDA   ,-U                 ; GET THE LAST CHARACTER; MOVE POINTER BACK
BE8E  81 30                      CMPA  #'0                 ; WAS IT A ZERO?
BE90  27 FA                      BEQ   LBE8C               ; IGNORE TRAILING ZEROS IF SO
BE92  81 2E                      CMPA  #'.                 ; CHECK FOR DECIMAL POINT
BE94  26 02                      BNE   LBE98               ; BRANCH IF NOT DECIMAL POINT
BE96  33 5F                      LEAU  -1,U                ; STEP OVER THE DECIMAL POINT
BE98  86 2B             LBE98    LDA   #'+                 ; ASCII PLUS SIGN
BE9A  D6 47                      LDB   V47                 ; GET SCIENTIFIC NOTATION EXPONENT
BE9C  27 1C                      BEQ   LBEBA               ; BRANCH IF NOT SCIENTIFIC NOTATION
BE9E  2A 03                      BPL   LBEA3               ; BRANCH IF POSITIVE EXPONENT
BEA0  86 2D                      LDA   #'-                 ; ASCII MINUS SIGN
BEA2  50                         NEGB                      ; NEGATE EXPONENT IF NEGATIVE
BEA3  A7 42             LBEA3    STA   2,U                 ; STORE EXPONENT SIGN IN STRING
BEA5  86 45                      LDA   #'E                 ; * GET ASCII 'E' (SCIENTIFIC NOTATION
BEA7  A7 41                      STA   1,U                 ; * FLAG) AND SAVE IT IN THE STRING
BEA9  86 2F                      LDA   #'0-1               ; INITIALIZE ACCA TO ASCII ZERO
* CONVERT BINARY VALUE IN ACCB TO DECIMAL
* ASCII NUMBER (< 100) IN ACCD
BEAB  4C                LBEAB    INCA                      ; ADD ONE TO 10'S DIGIT OF EXPONENT
BEAC  C0 0A                      SUBB  #10                 ; SUBTRACT 10 FROM ACCB
BEAE  24 FB                      BCC   LBEAB               ; ADD 1 TO 10'S DIGIT IF NO CARRY
BEB0  CB 3A                      ADDB  #'9+1               ; CONVERT UNITS DIGIT TO ASCII
BEB2  ED 43                      STD   3,U                 ; SAVE EXPONENT IN STRING
BEB4  6F 45                      CLR   5,U                 ; CLEAR LAST BYTE (TERMINATOR)
BEB6  20 04                      BRA   LBEBC               ; GO RESET POINTER
BEB8  A7 C4             LBEB8    STA   ,U                  ; STORE LAST CHARACTER
BEBA  6F 41             LBEBA    CLR   1,U                 ; CLEAR LAST BYTE (TERMINATOR - REQUIRED BY
* PRINT SUBROUTINES)
BEBC  8E 03 DA          LBEBC    LDX   #STRBUF+3           ; RESET POINTER TO START OF BUFFER
BEBF  39                         RTS
*
BEC0  80 00 00 00 00    LBEC0    FCB   $80,$00,$00,$00,$00 ; FLOATING POINT .5
*
*** TABLE OF UNNORMALIZED POWERS OF 10
BEC5  FA 0A 1F 00       LBEC5    FCB   $FA,$0A,$1F,$00     ; -100000000
BEC9  00 98 96 80       LBEC9    FCB   $00,$98,$96,$80     ;  10000000
BECD  FF F0 BD C0       LBECD    FCB   $FF,$F0,$BD,$C0     ; -1000000
BED1  00 01 86 A0       LBED1    FCB   $00,$01,$86,$A0     ;  100000
BED5  FF FF D8 F0       LBED5    FCB   $FF,$FF,$D8,$F0     ; -10000
BED9  00 00 03 E8       LBED9    FCB   $00,$00,$03,$E8     ;  1000
BEDD  FF FF FF 9C       LBEDD    FCB   $FF,$FF,$FF,$9C     ; -100
BEE1  00 00 00 0A       LBEE1    FCB   $00,$00,$00,$0A     ;  10
BEE5  FF FF FF FF       LBEE5    FCB   $FF,$FF,$FF,$FF     ; -1
*
*
BEE9  96 4F             LBEE9    LDA   FP0EXP              ; GET EXPONENT OF FPA0
BEEB  27 02                      BEQ   LBEEF               ; BRANCH IF FPA0 = 0
BEED  03 54                      COM   FP0SGN              ; TOGGLE MANTISSA SIGN OF FPA0
BEEF  39                LBEEF    RTS
* EXPAND A POLYNOMIAL OF THE FORM
* AQ+BQ**3+CQ**5+DQ**7.... WHERE Q = FPA0
* AND THE X REGISTER POINTS TO A TABLE OF
* COEFFICIENTS A,B,C,D....
BEF0  9F 64             LBEF0    STX   COEFPT              ; SAVE COEFFICIENT TABLE POINTER
BEF2  BD BC 2F                   JSR   LBC2F               ; MOVE FPA0 TO FPA3
BEF5  8D 05                      BSR   LBEFC               ; MULTIPLY FPA3 BY FPA0
BEF7  8D 08                      BSR   LBF01               ; EXPAND POLYNOMIAL
BEF9  8E 00 40                   LDX   #V40                ; POINT X TO FPA3
BEFC  7E BA CA          LBEFC    JMP   LBACA               ; MULTIPLY (X) BY FPA0

* CALCULATE THE VALUE OF AN EXPANDED POLYNOMIAL
* EXPRESSION. ENTER WITH (X) POINTING TO A TABLE
* OF COEFFICIENTS, THE FIRST BYTE OF WHICH IS THE
* NUMBER OF (COEFFICIENTS-1) FOLLOWED BY THAT NUMBER
* OF PACKED FLOATING POINT NUMBERS. THE
* POLYNOMIAL IS EVALUATED AS FOLLOWS: VALUE =
* (((FPA0*Y0+Y1)*FPA0+Y2)*FPA0…YN)
BEFF  9F 64             LBEFF    STX   COEFPT              ; SAVE COEFFICIENT TABLE POINTER
BF01  BD BC 2A          LBF01    JSR   LBC2A               ; MOVE FPA0 TO FPA4
BF04  9E 64                      LDX   COEFPT              ; GET THE COEFFICIENT POINTER
BF06  E6 80                      LDB   ,X+                 ; GET THE TOP OF COEFFICIENT TABLE TO
BF08  D7 55                      STB   COEFCT              ; * USE AND STORE IT IN TEMPORARY COUNTER
BF0A  9F 64                      STX   COEFPT              ; SAVE NEW COEFFICIENT POINTER
BF0C  8D EE             LBF0C    BSR   LBEFC               ; MULTIPLY (X) BY FPA0
BF0E  9E 64                      LDX   COEFPT              ; *GET COEFFICIENT POINTER
BF10  30 05                      LEAX  5,X                 ; *MOVE TO NEXT FP NUMBER
BF12  9F 64                      STX   COEFPT              ; *SAVE NEW COEFFICIENT POINTER
BF14  BD B9 C2                   JSR   LB9C2               ; ADD (X) AND FPA0
BF17  8E 00 45                   LDX   #V45                ; POINT (X) TO FPA4
BF1A  0A 55                      DEC   COEFCT              ; DECREMENT TEMP COUNTER
BF1C  26 EE                      BNE   LBF0C               ; BRANCH IF MORE COEFFICIENTS LEFT
BF1E  39                         RTS

* RND
BF1F  BD BC 6D          RND      JSR   LBC6D               ; TEST FPA0
BF22  2B 21                      BMI   LBF45               ; BRANCH IF FPA0 = NEGATIVE
BF24  27 15                      BEQ   LBF3B               ; BRANCH IF FPA0 = 0
BF26  8D 10                      BSR   LBF38               ; CONVERT FPA0 TO AN INTEGER
BF28  BD BC 2F                   JSR   LBC2F               ; PACK FPA0 TO FPA3
BF2B  8D 0E                      BSR   LBF3B               ; GET A RANDOM NUMBER: FPA0 < 1.0
BF2D  8E 00 40                   LDX   #V40                ; POINT (X) TO FPA3
BF30  8D CA                      BSR   LBEFC               ; MULTIPLY (X) BY FPA0
BF32  8E BA C5                   LDX   #LBAC5              ; POINT (X) TO FP VALUE OF 1.0
BF35  BD B9 C2                   JSR   LB9C2               ; ADD 1.0 TO FPA0
BF38  7E BC EE          LBF38    JMP   INT                 ; CONVERT FPA0 TO AN INTEGER
* CALCULATE A RANDOM NUMBER IN THE RANGE 0.0 < X <= 1.0
BF3B  BE 01 16          LBF3B    LDX   RVSEED+1            ; * MOVE VARIABLE
BF3E  9F 50                      STX   FPA0                ; * RANDOM NUMBER
BF40  BE 01 18                   LDX   RVSEED+3            ; * SEED TO
BF43  9F 52                      STX   FPA0+2              ; * FPA0
BF45  BE BF 74          LBF45    LDX   RSEED               ; = MOVE FIXED
BF48  9F 5D                      STX   FPA1                ; = RANDOM NUMBER
BF4A  BE BF 76                   LDX   RSEED+2             ; = SEED TO
BF4D  9F 5F                      STX   FPA1+2              ; = MANTISSA OF FPA0
BF4F  BD BA D0                   JSR   LBAD0               ; MULTIPLY FPA0 X FPA1
BF52  DC AD                      LDD   VAD                 ; GET THE TWO LOWEST ORDER PRODUCT BYTES
BF54  C3 65 8B                   ADDD  #$658B              ; ADD A CONSTANT
BF57  FD 01 18                   STD   RVSEED+3            ; SAVE NEW LOW ORDER VARIABLE RANDOM # SEED
BF5A  DD 52                      STD   FPA0+2              ; SAVE NEW LOW ORDER BYTES OF FPA0 MANTISSA
BF5C  DC AB                      LDD   VAB                 ; GET 2 MORE LOW ORDER PRODUCT BYTES
BF5E  C9 B0                      ADCB  #$B0                ; ADD A CONSTANT
BF60  89 05                      ADCA  #5                  ; ADD A CONSTANT
BF62  FD 01 16                   STD   RVSEED+1            ; SAVE NEW HIGH ORDER VARIABLE RANDOM # SEED
BF65  DD 50                      STD   FPA0                ; SAVE NEW HIGH ORDER FPA0 MANTISSA
BF67  0F 54                      CLR   FP0SGN              ; FORCE FPA0 MANTISSA = POSITIVE
BF69  86 80                      LDA   #$80                ; * SET FPA0 BIASED EXPONENT
BF6B  97 4F                      STA   FP0EXP              ; * TO 0 1 < FPA0 < 0
BF6D  96 15                      LDA   FPA2+2              ; GET A BYTE FROM FPA2 (MORE RANDOMNESS)
BF6F  97 63                      STA   FPSBYT              ; SAVE AS SUB BYTE
BF71  7E BA 1C                   JMP   LBA1C               ; NORMALIZE FPA0
*
BF74  40 E6             RSEED    FDB   $40E6               ; *CONSTANT RANDOM NUMBER GENERATOR SEED
BF76  4D AB                      FDB   $4DAB               ; *

* SIN
* THE SIN FUNCTION REQUIRES AN ARGUMENT IN RADIANS AND WILL REPEAT ITSELF EVERY
* 2*PI RADIANS. THE ARGUMENT IS DIVIDED BY 2*PI AND ONLY THE FRACTIONAL PART IS
* RETAINED. SINCE THE ARGUMENT WAS DIVIDED BY 2*P1, THE COEFFICIENTS MUST BE
* MULTIPLIED BY THE APPROPRIATE POWER OF 2*PI.

* SIN IS EVALUATED USING THE TRIGONOMETRIC IDENTITIES BELOW:
* SIN(X)=SIN(PI-X) & -SIN(PI/2-X)=SIN((3*PI)/2+X)
BF78  BD BC 5F          SIN      JSR   LBC5F               ; COPY FPA0 TO FPA1
BF7B  8E BF BD                   LDX   #LBFBD              ; POINT (X) TO 2*PI
BF7E  D6 61                      LDB   FP1SGN              ; *GET MANTISSA SIGN OF FPA1
BF80  BD BB 89                   JSR   LBB89               ; *AND DIVIDE FPA0 BY 2*PI
BF83  BD BC 5F                   JSR   LBC5F               ; COPY FPA0 TO FPA1
BF86  8D B0                      BSR   LBF38               ; CONVERT FPA0 TO AN INTEGER
BF88  0F 62                      CLR   RESSGN              ; SET RESULT SIGN = POSITIVE
BF8A  96 5C                      LDA   FP1EXP              ; *GET EXPONENT OF FPA1
BF8C  D6 4F                      LDB   FP0EXP              ; *GET EXPONENT OF FPA0
BF8E  BD B9 BC                   JSR   LB9BC               ; *SUBTRACT FPA0 FROM FPA1
*NOW FPA0 CONTAINS ONLY THE FRACTIONAL PART OF ARGUMENT/2*PI
BF91  8E BF C2                   LDX   #LBFC2              ; POINT X TO FP (.25)
BF94  BD B9 B9                   JSR   LB9B9               ; SUBTRACT FPA0 FROM .25 (PI/2)
BF97  96 54                      LDA   FP0SGN              ; GET MANTISSA SIGN OF FPA0
BF99  34 02                      PSHS  A                   ; SAVE IT ON STACK
BF9B  2A 09                      BPL   LBFA6               ; BRANCH IF MANTISSA POSITIVE
BF9D  BD B9 B4                   JSR   LB9B4               ; ADD .5 (PI) TO FPA0
BFA0  96 54                      LDA   FP0SGN              ; GET SIGN OF FPA0
BFA2  2B 05                      BMI   LBFA9               ; BRANCH IF NEGATIVE
BFA4  03 0A                      COM   RELFLG              ; COM IF +(3*PI)/2 >= ARGUMENT >+ PI/2 (QUADRANT FLAG)
BFA6  BD BE E9          LBFA6    JSR   LBEE9               ; TOGGLE MANTISSA SIGN OF FPA0
BFA9  8E BF C2          LBFA9    LDX   #LBFC2              ; POINT X TO FP (.25)
BFAC  BD B9 C2                   JSR   LB9C2               ; ADD .25 (PI/2) TO FPA0
BFAF  35 02                      PULS  A                   ; GET OLD MANTISSA SIGN
BFB1  4D                         TSTA                      ; * BRANCH IF OLD
BFB2  2A 03                      BPL   LBFB7               ; * SIGN WAS POSITIVE
BFB4  BD BE E9                   JSR   LBEE9               ; TOGGLE MANTISSA SIGN
BFB7  8E BF C7          LBFB7    LDX   #LBFC7              ; POINT X TO TABLE OF COEFFICIENTS
BFBA  7E BE F0                   JMP   LBEF0               ; GO CALCULATE POLYNOMIAL VALUE

BFBD  83 49 0F DA A2    LBFBD    FCB   $83,$49,$0F,$DA,$A2 ; 6.28318531 (2*PI)
BFC2  7F 00 00 00 00    LBFC2    FCB   $7F,$00,$00,$00,$00 ; .25

* MODIFIED TAYLOR SERIES SIN COEFFICIENTS
BFC7  05                LBFC7    FCB   6-1                 ; SIX COEFFICIENTS
BFC8  84 E6 1A 2D 1B    LBFC8    FCB   $84,$E6,$1A,$2D,$1B ; * -((2*PI)**11)/11!
BFCD  86 28 07 FB F8    LBFC8    FCB   $86,$28,$07,$FB,$F8 ; *  ((2*PI)**9)/9!
BFD2  87 99 68 89 01    LBFD2    FCB   $87,$99,$68,$89,$01 ; * -((2*PI)**7)/7!
BFD7  87 23 35 DF E1    LBFD7    FCB   $87,$23,$35,$DF,$E1 ; *  ((2*PI)**5)/5!
BFDC  86 A5 5D E7 28    LBFDC    FCB   $86,$A5,$5D,$E7,$28 ; * -((2*PI)**3)/3!
BFE1  83 49 0F DA A2    LBFE1    FCB   $83,$49,$0F,$DA,$A2 ; *    2*PI

BFE6  A1 54 46 8F 13 8F LBFE6    FCB   $A1,$54,$46,$8F,$13 ; UNUSED GARBAGE BYTES
BFEC  52 43 89 CD                FCB   $8F,$52,$43,$89,$CD ; UNUSED GARBAGE BYTES

* INTERRUPT VECTORS
BFF0  A6 81             LBFF0    FDB   LA681               ; RESERVED
BFF2  01 00             LBFF2    FDB   SW3VEC              ; SWI3
BFF4  01 03             LBFF4    FDB   SW2VEC              ; SWI2
BFF6  01 0F             LBFF6    FDB   FRQVEC              ; FIRQ
BFF8  01 0C             LBFF8    FDB   IRQVEC              ; IRQ
BFFA  01 06             LBFFA    FDB   SWIVEC              ; SWI
BFFC  01 09             LBFFC    FDB   NMIVEC              ; NMI
BFFE  A0 27             LBFFE    FDB   RESVEC              ; RESET
