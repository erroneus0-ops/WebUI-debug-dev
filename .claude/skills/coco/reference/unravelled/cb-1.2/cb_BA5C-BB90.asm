; Color BASIC 1.2 -- $BA5C-$BB90
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: BA5C=$BA5C, $ THE RIGHT (B) TIMES. OVERFLOW RETAINED IN ACCA.=$

BA5C  25 08             BA5C     BCS   LBA66               ; BRANCH IF MANTISSA OVERFLOW
BA5E  08 63                      ASL   FPSBYT              ; SUB BYTE BIT 7 TO CARRY - USE AS ROUND-OFF
* FLAG (TRUNCATE THE REST OF SUB BYTE)
BA60  86 00                      LDA   #0                  ; CLRA, BUT DO NOT CHANGE CARRY FLAG
BA62  97 63                      STA   FPSBYT              ; CLEAR THE SUB BYTE
BA64  20 0C                      BRA   LBA72               ; GO ROUND-OFF RESULT
BA66  0C 4F             LBA66    INC   FP0EXP              ; INCREMENT EXPONENT - MULTIPLY BY 2
BA68  27 28                      BEQ   LBA92               ; OVERFLOW ERROR IF CARRY PAST $FF
BA6A  06 50                      ROR   FPA0                ; * SHIFT MANTISSA
BA6C  06 51                      ROR   FPA0+1              ; * ONE TO
BA6E  06 52                      ROR   FPA0+2              ; * THE RIGHT -
BA70  06 53                      ROR   FPA0+3              ; * DIVIDE BY TWO
BA72  24 04             LBA72    BCC   LBA78               ; BRANCH IF NO ROUND-OFF NEEDED
BA74  8D 0D                      BSR   LBA83               ; ADD ONE TO MANTISSA - ROUND OFF
BA76  27 EE                      BEQ   LBA66               ; BRANCH iF OVERFLOW - MANTISSA = 0
BA78  39                LBA78    RTS
* NEGATE FPA0 MANTISSA
BA79  03 54             LBA79    COM   FP0SGN              ; TOGGLE SIGN OF MANTISSA
BA7B  03 50             LBA7B    COM   FPA0                ; * COMPLEMENT ALL 4 MANTISSA BYTES
BA7D  03 51                      COM   FPA0+1              ; *
BA7F  03 52                      COM   FPA0+2              ; *
BA81  03 53                      COM   FPA0+3              ; *
* ADD ONE TO FPA0 MANTISSA
BA83  9E 52             LBA83    LDX   FPA0+2              ; * GET BOTTOM 2 MANTISSA
BA85  30 01                      LEAX  1,X                 ; * BYTES, ADD ONE TO
BA87  9F 52                      STX   FPA0+2              ; * THEM AND SAVE THEM
BA89  26 06                      BNE   LBA91               ; BRANCH IF NO OVERFLOW
BA8B  9E 50                      LDX   FPA0                ; * IF OVERFLOW ADD ONE
BA8D  30 01                      LEAX  1,X                 ; * TO TOP 2 MANTISSA
BA8F  9F 50                      STX   FPA0                ; * BYTES AND SAVE THEM
BA91  39                LBA91    RTS
BA92  C6 0A             LBA92    LDB   #2*5                ; 'OV' OVERFLOW ERROR
BA94  7E AC 46                   JMP   LAC46               ; PROCESS AN ERROR
BA97  8E 00 12          LBA97    LDX   #FPA2-1             ; POINT X TO FPA2
* SHIFT FPA POINTED TO BY (X) TO
* THE RIGHT -(B) TIMES. EXIT WITH
* ACCA CONTAINING DATA SHIFTED OUT
* TO THE RIGHT (SUB BYTE) AND THE DATA
* SHIFTED IN FROM THE LEFT WILL COME FROM FPCARY
BA9A  A6 04             LBA9A    LDA   4,X                 ; GET LS BYTE OF MANTISSA (X)
BA9C  97 63                      STA   FPSBYT              ; SAVE IN FPA SUB BYTE
BA9E  A6 03                      LDA   3,X                 ; * SHIFT THE NEXT THREE BYTES OF THE
BAA0  A7 04                      STA   4,X                 ; * MANTISSA RIGHT ONE COMPLETE BYTE.
BAA2  A6 02                      LDA   2,X                 ; *
BAA4  A7 03                      STA   3,X                 ; *
BAA6  A6 01                      LDA   1,X                 ; *
BAA8  A7 02                      STA   2,X                 ; *
BAAA  96 5B                      LDA   FPCARY              ; GET THE CARRY IN BYTE
BAAC  A7 01                      STA   1,X                 ; STORE AS THE MS MANTISSA BYTE OF (X)
BAAE  CB 08             LBAAE    ADDB  #8                  ; ADD 8 TO DIFFERENCE OF EXPONENTS
BAB0  2F E8                      BLE   LBA9A               ; BRANCH IF EXPONENT DIFFERENCE < -8
BAB2  96 63                      LDA   FPSBYT              ; GET FPA SUB BYTE
BAB4  C0 08                      SUBB  #8                  ; CAST OUT THE 8 ADDED IN ABOVE
BAB6  27 0C                      BEQ   LBAC4               ; BRANCH IF EXPONENT DIFFERENCE = 0
* SHIFT MANTISSA POINTED TO BY (X) TO
                        $ THE RIGHT (B) TIMES. OVERFLOW RETAINED IN ACCA.
BAB8  67 01             LBAB8    ASR   1,X                 ; * SHIFT MANTISSA AND SUB BYTE ONE BIT TO THE RIGHT
BABA  66 02             LBABA    ROR   2,X                 ; *
BABC  66 03                      ROR   3,X                 ; *
BABE  66 04                      ROR   4,X                 ; *
BAC0  46                         RORA                      ; *
BAC1  5C                         INCB                      ; ADD ONE TO EXPONENT DIFFERENCE
BAC2  26 F4                      BNE   LBAB8               ; BRANCH IF EXPONENTS NOT =
BAC4  39                LBAC4    RTS
BAC5  81 00 00 00 00    LBAC5    FCB   $81,$00,$00,$00,$00 ; FLOATING POINT CONSTANT 1.0

* ARITHMETIC OPERATION (*) JUMPS HERE - MULTIPLY
* FPA0 BY (X) - RETURN PRODUCT IN FPA0
BACA  8D 63             LBACA    BSR   LBB2F               ; MOVE PACKED FPA FROM (X) TO FPA1
BACC  27 60                      BEQ   LBB2E               ; BRANCH IF EXPONENT OF FPA0 = 0
BACE  8D 78                      BSR   LBB48               ; CALCULATE EXPONENT OF PRODUCT
* MULTIPLY FPA0 MANTISSA BY FPA1. NORMALIZE
* HIGH ORDER BYTES OF PRODUCT IN FPA0. THE
* LOW ORDER FOUR BYTES OF THE PRODUCT WILL
* BE STORED IN VAB-VAE.
BAD0  86 00             LBAD0    LDA   #0                  ; * ZERO OUT MANTISSA OF FPA2
BAD2  97 13                      STA   FPA2                ; *
BAD4  97 14                      STA   FPA2+1              ; *
BAD6  97 15                      STA   FPA2+2              ; *
BAD8  97 16                      STA   FPA2+3              ; *
BADA  D6 53                      LDB   FPA0+3              ; GET LS BYTE OF FPA0
BADC  8D 22                      BSR   LBB00               ; MULTIPLY BY FPA1
BADE  D6 63                      LDB   FPSBYT              ; * TEMPORARILY SAVE SUB BYTE 4
BAE0  D7 AE                      STB   VAE                 ; *
BAE2  D6 52                      LDB   FPA0+2              ; GET NUMBER 3 MANTISSA BYTE OF FPA0
BAE4  8D 1A                      BSR   LBB00               ; MULTIPLY BY FPA1
BAE6  D6 63                      LDB   FPSBYT              ; * TEMPORARILY SAVE SUB BYTE 3
BAE8  D7 AD                      STB   VAD                 ; *
BAEA  D6 51                      LDB   FPA0+1              ; GET NUMBER 2 MANTISSA BYTE OF FPA0
BAEC  8D 12                      BSR   LBB00               ; MULTIPLY BY FPA1
BAEE  D6 63                      LDB   FPSBYT              ; * TEMPORARILY SAVE SUB BYTE 2
BAF0  D7 AC                      STB   VAC                 ; *
BAF2  D6 50                      LDB   FPA0                ; GET MS BYTE OF FPA0 MANTISSA
BAF4  8D 0C                      BSR   LBB02               ; MULTIPLY BY FPA1
BAF6  D6 63                      LDB   FPSBYT              ; * TEMPORARILY SAVE SUB BYTE 1
BAF8  D7 AB                      STB   VAB                 ; *
BAFA  BD BC 0B                   JSR   LBC0B               ; COPY MANTISSA FROM FPA2 TO FPA0
BAFD  7E BA 1C                   JMP   LBA1C               ; NORMALIZE FPA0
BB00  27 95             LBB00    BEQ   LBA97               ; SHIFT FPA2 ONE BYTE TO RIGHT
BB02  43                LBB02    COMA                      ; SET CARRY FLAG
* MULTIPLY FPA1 MANTISSA BY ACCB AND
* ADD PRODUCT TO FPA2 MANTISSA
BB03  96 13             LBB03    LDA   FPA2                ; GET FPA2 MS BYTE
BB05  56                         RORB                      ; ROTATE CARRY FLAG INTO SHIFT COUNTER;
* DATA BIT INTO CARRY
BB06  27 26                      BEQ   LBB2E               ; BRANCH WHEN 8 SHIFTS DONE
BB08  24 16                      BCC   LBB20               ; DO NOT ADD FPA1 IF DATA BIT = 0
BB0A  96 16                      LDA   FPA2+3              ; * ADD MANTISSA LS BYTE
BB0C  9B 60                      ADDA  FPA1+3              ; *
BB0E  97 16                      STA   FPA2+3              ; *
BB10  96 15                      LDA   FPA2+2              ; = ADD MANTISSA NUMBER 3 BYTE
BB12  99 5F                      ADCA  FPA1+2              ; =
BB14  97 15                      STA   FPA2+2              ; =
BB16  96 14                      LDA   FPA2+1              ; * ADD MANTISSA NUMBER 2 BYTE
BB18  99 5E                      ADCA  FPA1+1              ; *
BB1A  97 14                      STA   FPA2+1              ; *
BB1C  96 13                      LDA   FPA2                ; = ADD MANTISSA MS BYTE
BB1E  99 5D                      ADCA  FPA1                ; =
BB20  46                LBB20    RORA                      ; * ROTATE CARRY INTO MS BYTE
BB21  97 13                      STA   FPA2                ; *
BB23  06 14                      ROR   FPA2+1              ; = ROTATE FPA2 ONE BIT TO THE RIGHT
BB25  06 15                      ROR   FPA2+2              ; =
BB27  06 16                      ROR   FPA2+3              ; =
BB29  06 63                      ROR   FPSBYT              ; =
BB2B  4F                         CLRA                      ; CLEAR CARRY FLAG
BB2C  20 D5                      BRA   LBB03               ; KEEP LOOPING
BB2E  39                LBB2E    RTS
* UNPACK A FP NUMBER FROM (X) TO FPA1
BB2F  EC 01             LBB2F    LDD   1,X                 ; GET TWO MSB BYTES OF MANTISSA FROM
; FPA POINTED TO BY X
BB31  97 61                      STA   FP1SGN              ; SAVE PACKED MANTISSA SIGN BYTE
BB33  8A 80                      ORA   #$80                ; FORCE BIT 7 OF MSB MANTISSA = 1
BB35  DD 5D                      STD   FPA1                ; SAVE 2 MSB BYTES IN FPA1
BB37  D6 61                      LDB   FP1SGN              ; * GET PACKED MANTISSA SIGN BYTE. EOR W/FPA0
BB39  D8 54                      EORB  FP0SGN              ; * SIGN - NEW SIGN POSITION IF BOTH OLD SIGNS ALIKE,
BB3B  D7 62                      STB   RESSGN              ; * NEG IF BOTH OLD SIGNS DIFF. SAVE ADJUSTED
* * MANTISSA SIGN BYTE
BB3D  EC 03                      LDD   3,X                 ; = GET 2 LSB BYTES OF MANTISSA
BB3F  DD 5F                      STD   FPA1+2              ; = AND PUT IN FPA1
BB41  A6 84                      LDA   ,X                  ; * GET EXPONENT FROM (X) AND
BB43  97 5C                      STA   FP1EXP              ; * PUT IN EXPONENT OF FPA1
BB45  D6 4F                      LDB   FP0EXP              ; GET EXPONENT OF FPA0
BB47  39                         RTS
* CALCULATE EXPONENT FOR PRODUCT OF FPA0 & FPA1
* ENTER WITH EXPONENT OF FPA1 IN ACCA
BB48  4D                LBB48    TSTA                      ; TEST EXPONENT OF FPA1
BB49  27 16                      BEQ   LBB61               ; PURGE RETURN ADDRESS & SET FPA0 = 0
BB4B  9B 4F                      ADDA  FP0EXP              ; ADD FPA1 EXPONENT TO FPA0 EXPONENT
BB4D  46                         RORA                      ; ROTATE CARRY INTO BIT 7; BIT 0 INTO CARRY
BB4E  49                         ROLA                      ; SET OVERFLOW FLAG
BB4F  28 10                      BVC   LBB61               ; BRANCH IF EXPONENT TOO LARGE OR SMALL
BB51  8B 80                      ADDA  #$80                ; ADD $80 BIAS TO EXPONENT
BB53  97 4F                      STA   FP0EXP              ; SAVE NEW EXPONENT
BB55  27 0C                      BEQ   LBB63               ; SET FPA0
BB57  96 62                      LDA   RESSGN              ; GET MANTISSA SIGN
BB59  97 54                      STA   FP0SGN              ; SAVE AS MANTISSA SIGN OF FPA0
BB5B  39                         RTS
* IF FPA0 = POSITIVE THEN 'OV' ERROR IF FPA0
* = IS NEGATIVE THEN FPA0 = 0
BB5C  96 54             LBB5C    LDA   FP0SGN              ; GET MANTISSA SIGN OF FPA0
BB5E  43                         COMA                      ; CHANGE SIGN OF FPA0 MANTISSA
BB5F  20 02                      BRA   LBB63
BB61  32 62             LBB61    LEAS  2,S                 ; PURGE RETURN ADDRESS FROM STACK
BB63  10 2A FE D2       LBB63    LBPL  LBA39               ; ZERO FPA0 MANTISSA SIGN & EXPONENT
BB67  7E BA 92          LBB67    JMP   LBA92               ; 'OV' OVERFLOW ERROR
* FAST MULTIPLY BY 10 AND LEAVE RESULT IN FPA0
BB6A  BD BC 5F          LBB6A    JSR   LBC5F               ; TRANSFER FPA0 TO FPA1
BB6D  27 0D                      BEQ   LBB7C               ; BRANCH IF EXPONENT = 0
BB6F  8B 02                      ADDA  #2                  ; ADD 2 TO EXPONENT (TIMES 4)
BB71  25 F4                      BCS   LBB67               ; 'OV' ERROR IF EXPONENT > $FF
BB73  0F 62                      CLR   RESSGN              ; CLEAR RESULT SIGN BYTE
BB75  BD B9 CD                   JSR   LB9CD               ; ADD FPA1 TO FPA0 (TIMES 5)
BB78  0C 4F                      INC   FP0EXP              ; ADD ONE TO EXPONENT (TIMES 10)
BB7A  27 EB                      BEQ   LBB67               ; 'OV' ERROR IF EXPONENT > $FF
BB7C  39                LBB7C    RTS
BB7D  84 20 00 00 00    LBB7D    FCB   $84,$20,$00,$00,$00 ; FLOATING POINT CONSTANT 10
* DIVIDE FPA0 BY 10
BB82  BD BC 5F          LBB82    JSR   LBC5F               ; MOVE FPA0 TO FPA1
BB85  8E BB 7D                   LDX   #LBB7D              ; POINT TO FLOATING POINT CONSTANT 10
BB88  5F                         CLRB                      ; ZERO MANTISSA SIGN BYTE
BB89  D7 62             LBB89    STB   RESSGN              ; STORE THE QUOTIENT MANTISSA SIGN BYTE
BB8B  BD BC 14                   JSR   LBC14               ; UNPACK AN FP NUMBER FROM (X) INTO FPA0
BB8E  8C                         FCB   SKP2                ; SKIP TWO BYTES
* DIVIDE (X) BY FPA0-LEAVE NORMALIZED QUOTIENT IN FPA0
BB8F  8D 9E             LBB8F    BSR   LBB2F               ; GET FP NUMBER FROM (X) TO FPA1

* ARITHMETIC OPERATION (/) JUMPS HERE. DIVIDE FPA1 BY FPA0 (ENTER WITH
* EXPONENT OF FPA1 IN ACCA AND FLAGS SET BY TSTA)
