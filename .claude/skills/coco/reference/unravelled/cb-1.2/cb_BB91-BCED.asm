; Color BASIC 1.2 -- $BB91-$BCED
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: SGN=$BC7A, ABS=$BC93

* DIVIDE FPA1 BY FPA0
BB91  27 73             LBB91    BEQ   LBC06               ; '/0' DIVIDE BY ZERO ERROR
BB93  00 4F                      NEG   FP0EXP              ; GET EXPONENT OF RECIPROCAL OF DIVISOR
BB95  8D B1                      BSR   LBB48               ; CALCULATE EXPONENT OF QUOTIENT
BB97  0C 4F                      INC   FP0EXP              ; INCREMENT EXPONENT
BB99  27 CC                      BEQ   LBB67               ; 'OV' OVERFLOW ERROR
BB9B  8E 00 13                   LDX   #FPA2               ; POINT X TO MANTISSA OF FPA2 - HOLD
* TEMPORARY QUOTIENT IN FPA2
BB9E  C6 04                      LDB   #4                  ; 5 BYTE DIVIDE
BBA0  D7 03                      STB   TMPLOC              ; SAVE BYTE COUNTER
BBA2  C6 01                      LDB   #1                  ; SHIFT COUNTER-AND TEMPORARY QUOTIENT BYTE
* COMPARE FPA0 MANTISSA TO FPA1 MANTISSA -
* SET CARRY FLAG IF FPA1 >= FPA0
BBA4  96 50             LBBA4    LDA   FPA0                ; * COMPARE THE TWO MS BYTES
BBA6  91 5D                      CMPA  FPA1                ; * OF FPA0 AND FPA1 AND
BBA8  26 13                      BNE   LBBBD               ; * BRANCH IF <>
BBAA  96 51                      LDA   FPA0+1              ; = COMPARE THE NUMBER 2
BBAC  91 5E                      CMPA  FPA1+1              ; = BYTES AND
BBAE  26 0D                      BNE   LBBBD               ; = BRANCH IF <>
BBB0  96 52                      LDA   FPA0+2              ; * COMPARE THE NUMBER 3
BBB2  91 5F                      CMPA  FPA1+2              ; * BYTES AND
BBB4  26 07                      BNE   LBBBD               ; * BRANCH IF <>
BBB6  96 53                      LDA   FPA0+3              ; = COMPARE THE LS BYTES
BBB8  91 60                      CMPA  FPA1+3              ; = AND BRANCH
BBBA  26 01                      BNE   LBBBD               ; = IF <>
BBBC  43                         COMA                      ; SET CARRY FLAG IF FPA0 = FPA1
BBBD  1F A8             LBBBD    TFR   CC,A                ; SAVE CARRY FLAG STATUS IN ACCA; CARRY
* CLEAR IF FPA0 > FPA1
BBBF  59                         ROLB                      ; ROTATE CARRY INTO TEMPORARY QUOTIENT BYTE
BBC0  24 0A                      BCC   LBBCC               ; CARRY WILL BE SET AFTER 8 SHIFTS
BBC2  E7 80                      STB   ,X+                 ; SAVE TEMPORARY QUOTIENT
BBC4  0A 03                      DEC   TMPLOC              ; DECREMENT BYTE COUNTER
BBC6  2B 34                      BMI   LBBFC               ; BRANCH IF DONE
BBC8  27 2E                      BEQ   LBBF8               ; BRANCH IF LAST BYTE
BBCA  C6 01                      LDB   #1                  ; RESET SHIFT COUNTER AND TEMPORARY QUOTIENT BYTE
BBCC  1F 8A             LBBCC    TFR   A,CC                ; RESTORE CARRY FLAG AND
BBCE  25 0E                      BCS   LBBDE               ; BRANCH IF FPA0 =< FPA1
BBD0  08 60             LBBD0    ASL   FPA1+3              ; * SHIFT FPA1 MANTISSA 1 BIT TO LEFT
BBD2  09 5F                      ROL   FPA1+2              ; *
BBD4  09 5E                      ROL   FPA1+1              ; *
BBD6  09 5D                      ROL   FPA1                ; *
BBD8  25 E3                      BCS   LBBBD               ; BRANCH IF CARRY - ADD ONE TO PARTIAL QUOTIENT
BBDA  2B C8                      BMI   LBBA4               ; IF MSB OF HIGH ORDER MANTISSA BYTE IS
* SET, CHECK THE MAGNITUDES OF FPA0, FPA1
BBDC  20 DF                      BRA   LBBBD               ; CARRY IS CLEAR, CHECK ANOTHER BIT
* SUBTRACT FPA0 FROM FPA1 - LEAVE RESULT IN FPA1
BBDE  96 60             LBBDE    LDA   FPA1+3              ; * SUBTRACT THE LS BYTES OF MANTISSA
BBE0  90 53                      SUBA  FPA0+3              ; *
BBE2  97 60                      STA   FPA1+3              ; *
BBE4  96 5F                      LDA   FPA1+2              ; = THEN THE NEXT BYTE
BBE6  92 52                      SBCA  FPA0+2              ; =
BBE8  97 5F                      STA   FPA1+2              ; =
BBEA  96 5E                      LDA   FPA1+1              ; * AND THE NEXT
BBEC  92 51                      SBCA  FPA0+1              ; *
BBEE  97 5E                      STA   FPA1+1              ; *
BBF0  96 5D                      LDA   FPA1                ; = AND FINALLY, THE MS BYTE OF MANTISSA
BBF2  92 50                      SBCA  FPA0                ; =
BBF4  97 5D                      STA   FPA1                ; =
BBF6  20 D8                      BRA   LBBD0               ; GO SHIFT FPA1
BBF8  C6 40             LBBF8    LDB   #$40                ; USE ONLY TWO BITS OF THE LAST BYTE (FIFTH)
BBFA  20 D0                      BRA   LBBCC               ; GO SHIFT THE LAST BYTE
BBFC  56                LBBFC    RORB                      ; * SHIFT CARRY (ALWAYS SET HERE) INTO
BBFD  56                         RORB                      ; * BIT 5 AND MOVE
BBFE  56                         RORB                      ; * BITS 1,0 TO BITS 7,6
BBFF  D7 63                      STB   FPSBYT              ; SAVE SUB BYTE
BC01  8D 08                      BSR   LBC0B               ; MOVE MANTISSA OF FPA2 TO FPA0
BC03  7E BA 1C                   JMP   LBA1C               ; NORMALIZE FPA0
BC06  C6 14             LBC06    LDB   #2*10               ; '/0' ERROR
BC08  7E AC 46                   JMP   LAC46               ; PROCESS THE ERROR
* COPY MANTISSA FROM FPA2 TO FPA0
BC0B  9E 13             LBC0B    LDX   FPA2                ; * MOVE TOP 2 BYTES
BC0D  9F 50                      STX   FPA0                ; *
BC0F  9E 15                      LDX   FPA2+2              ; = MOVE BOTTOM 2 BYTES
BC11  9F 52                      STX   FPA0+2              ; =
BC13  39                         RTS
* COPY A PACKED FP NUMBER FROM (X) TO FPA0
BC14  34 02             LBC14    PSHS  A                   ; SAVE ACCA
BC16  EC 01                      LDD   1,X                 ; GET TOP TWO MANTISSA BYTES
BC18  97 54                      STA   FP0SGN              ; SAVE MS BYTE OF MANTISSA AS MANTISSA SIGN
BC1A  8A 80                      ORA   #$80                ; UNPACK MS BYTE
BC1C  DD 50                      STD   FPA0                ; SAVE UNPACKED TOP 2 MANTISSA BYTES
BC1E  0F 63                      CLR   FPSBYT              ; CLEAR MANTISSA SUB BYTE
BC20  E6 84                      LDB   ,X                  ; GET EXPONENT TO ACCB
BC22  AE 03                      LDX   3,X                 ; * MOVE LAST 2
BC24  9F 52                      STX   FPA0+2              ; * MANTISSA BYTES
BC26  D7 4F                      STB   FP0EXP              ; SAVE EXPONENT
BC28  35 82                      PULS  A,PC                ; RESTORE ACCA AND RETURN

BC2A  8E 00 45          LBC2A    LDX   #V45                ; POINT X TO MANTISSA OF FPA4
BC2D  20 06                      BRA   LBC35               ; MOVE FPA0 TO FPA4
BC2F  8E 00 40          LBC2F    LDX   #V40                ; POINT X TO MANTISSA OF FPA3
BC32  8C                         FCB   SKP2                ; SKIP TWO BYTES
BC33  9E 3B             LBC33    LDX   VARDES              ; POINT X TO VARIABLE DESCRIPTOR IN VARDES
* PACK FPA0 AND MOVE IT TO ADDRESS IN X
BC35  96 4F             LBC35    LDA   FP0EXP              ; * COPY EXPONENT
BC37  A7 84                      STA   ,X                  ; *
BC39  96 54                      LDA   FP0SGN              ; GET MANTISSA SIGN BIT
BC3B  8A 7F                      ORA   #$7F                ; MASK THE BOTTOM 7 BITS
BC3D  94 50                      ANDA  FPA0                ; AND BIT 7 OF MANTISSA SIGN INTO BIT 7 OF MS BYTE
BC3F  A7 01                      STA   1,X                 ; SAVE MS BYTE
BC41  96 51                      LDA   FPA0+1              ; * MOVE 2ND MANTISSA BYTE
BC43  A7 02                      STA   2,X                 ; *
BC45  DE 52                      LDU   FPA0+2              ; = MOVE BOTTOM 2 MANTISSA BYTES
BC47  EF 03                      STU   3,X                 ; =
BC49  39                         RTS
* MOVE FPA1 TO FPA0 RETURN W/MANTISSA SIGN IN ACCA
BC4A  96 61             LBC4A    LDA   FP1SGN              ; * COPY MANTISSA SIGN FROM
BC4C  97 54             LBC4C    STA   FP0SGN              ; * FPA1 TO FPA0
BC4E  9E 5C                      LDX   FP1EXP              ; = COPY EXPONENT + MS BYTE FROM
BC50  9F 4F                      STX   FP0EXP              ; = FPA1 TO FPA0
BC52  0F 63                      CLR   FPSBYT              ; CLEAR MANTISSA SUB BYTE
BC54  96 5E                      LDA   FPA1+1              ; * COPY 2ND MANTISSA BYTE
BC56  97 51                      STA   FPA0+1              ; * FROM FPA1 TO FPA0
BC58  96 54                      LDA   FP0SGN              ; GET MANTISSA SIGN
BC5A  9E 5F                      LDX   FPA1+2              ; * COPY 3RD AND 4TH MANTISSA BYTE
BC5C  9F 52                      STX   FPA0+2              ; * FROM FPA1 TO FPA0
BC5E  39                         RTS
* TRANSFER FPA0 TO FPA1
BC5F  DC 4F             LBC5F    LDD   FP0EXP              ; * TRANSFER EXPONENT & MS BYTE
BC61  DD 5C                      STD   FP1EXP              ; *
BC63  9E 51                      LDX   FPA0+1              ; = TRANSFER MIDDLE TWO BYTES
BC65  9F 5E                      STX   FPA1+1              ; =
BC67  9E 53                      LDX   FPA0+3              ; * TRANSFER BOTTOM TWO BYTES
BC69  9F 60                      STX   FPA1+3              ; *
BC6B  4D                         TSTA                      ; SET FLAGS ACCORDING TO EXPONENT
BC6C  39                         RTS
* CHECK FPA0; RETURN ACCB = 0 IF FPA0 = 0,
* ACCB = $FF IF FPA0 = NEGATIVE, ACCB = 1 IF FPA0 = POSITIVE
BC6D  D6 4F             LBC6D    LDB   FP0EXP              ; GET EXPONENT
BC6F  27 08                      BEQ   LBC79               ; BRANCH IF FPA0 = 0
BC71  D6 54             LBC71    LDB   FP0SGN              ; GET SIGN OF MANTISSA
BC73  59                LBC73    ROLB                      ; BIT 7 TO CARRY
BC74  C6 FF                      LDB   #$FF                ; NEGATIVE FLAG
BC76  25 01                      BCS   LBC79               ; BRANCH IF NEGATIVE MANTISSA
BC78  50                         NEGB                      ; ACCB = 1 IF POSITIVE MANTISSA
BC79  39                LBC79    RTS

* SGN
BC7A  8D F1             SGN      BSR   LBC6D               ; SET ACCB ACCORDING TO SIGN OF FPA0
* CONVERT A SIGNED NUMBER IN ACCB INTO A FLOATING POINT NUMBER
BC7C  D7 50             LBC7C    STB   FPA0                ; SAVE ACCB IN FPA0
BC7E  0F 51                      CLR   FPA0+1              ; CLEAR NUMBER 2 MANTISSA BYTE OF FPA0
BC80  C6 88                      LDB   #$88                ; EXPONENT REQUIRED IF FPA0 IS TO BE AN INTEGER
BC82  96 50             LBC82    LDA   FPA0                ; GET MS BYTE OF MANTISSA
BC84  80 80                      SUBA  #$80                ; SET CARRY IF POSITIVE MANTISSA
BC86  D7 4F             LBC86    STB   FP0EXP              ; SAVE EXPONENT
BC88  DC 8A                      LDD   ZERO                ; * ZERO OUT ACCD AND
BC8A  DD 52                      STD   FPA0+2              ; * BOTTOM HALF OF FPA0
BC8C  97 63                      STA   FPSBYT              ; CLEAR SUB BYTE
BC8E  97 54                      STA   FP0SGN              ; CLEAR SIGN OF FPA0 MANTISSA
BC90  7E BA 18                   JMP   LBA18               ; GO NORMALIZE FPA0

* ABS
BC93  0F 54             ABS      CLR   FP0SGN              ; FORCE MANTISSA SIGN OF FPA0 POSITIVE
BC95  39                         RTS
* COMPARE A PACKED FLOATING POINT NUMBER POINTED TO
* BY (X) TO AN UNPACKED FP NUMBER IN FPA0. RETURN
* ZERO FLAG SET AND ACCB = 0, IF EQUAL; ACCB = 1 IF
* FPA0 > (X); ACCB = $FF IF FPA0 < (X)
BC96  E6 84             LBC96    LDB   ,X                  ; CHECK EXPONENT OF (X)
BC98  27 D3                      BEQ   LBC6D               ; BRANCH IF FPA = 0
BC9A  E6 01                      LDB   1,X                 ; GET MS BYTE OF MANTISSA OF (X)
BC9C  D8 54                      EORB  FP0SGN              ; EOR WITH SIGN OF FPA0
BC9E  2B D1                      BMI   LBC71               ; BRANCH IF SIGNS NOT =
* COMPARE FPA0 WITH FP NUMBER POINTED TO BY (X).
* FPA0 IS NORMALIZED, (X) IS PACKED.
BCA0  D6 4F             LBCA0    LDB   FP0EXP              ; * GET EXPONENT OF
BCA2  E1 84                      CMPB  ,X                  ; * FPA0, COMPARE TO EXPONENT OF
BCA4  26 1D                      BNE   LBCC3               ; * (X) AND BRANCH IF <>.
BCA6  E6 01                      LDB   1,X                 ; * GET MS BYTE OF (X), KEEP ONLY
BCA8  CA 7F                      ORB   #$7F                ; * THE SIGN BIT - 'AND' THE BOTTOM 7
BCAA  D4 50                      ANDB  FPA0                ; * BITS OF FPA0 INTO ACCB
BCAC  E1 01                      CMPB  1,X                 ; = COMPARE THE BOTTOM 7 BITS OF THE MANTISSA
BCAE  26 13                      BNE   LBCC3               ; = MS BYTE AND BRANCH IF <>
BCB0  D6 51                      LDB   FPA0+1              ; * COMPARE 2ND BYTE
BCB2  E1 02                      CMPB  2,X                 ; * OF MANTISSA,
BCB4  26 0D                      BNE   LBCC3               ; * BRANCH IF <>
BCB6  D6 52                      LDB   FPA0+2              ; = COMPARE 3RD BYTE
BCB8  E1 03                      CMPB  3,X                 ; = OF MANTISSA,
BCBA  26 07                      BNE   LBCC3               ; = BRANCH IF <>
BCBC  D6 53                      LDB   FPA0+3              ; * SUBTRACT LS BYTE
BCBE  E0 04                      SUBB  4,X                 ; * OF (X) FROM LS BYTE OF
BCC0  26 01                      BNE   LBCC3               ; * FPA0, BRANCH IF <>
BCC2  39                         RTS                       ;   RETURN IF FP (X) = FPA0
BCC3  56                LBCC3    RORB                      ; SHIFT CARRY TO BIT 7; CARRY SET IF FPA0 < (X)
BCC4  D8 54                      EORB  FP0SGN              ; TOGGLE SIZE COMPARISON BIT IF FPA0 IS NEGATIVE
BCC6  20 AB                      BRA   LBC73               ; GO SET ACCB ACCORDING TO COMPARISON
* DE-NORMALIZE FPA0 : SHIFT THE MANTISSA UNTIL THE BINARY POINT IS TO THE RIGHT
* OF THE LEAST SIGNIFICANT BYTE OF THE MANTISSA
BCC8  D6 4F             LBCC8    LDB   FP0EXP              ; GET EXPONENT OF FPA0
BCCA  27 3D                      BEQ   LBD09               ; ZERO MANTISSA IF FPA0 = 0
BCCC  C0 A0                      SUBB  #$A0                ; SUBTRACT $A0 FROM FPA0 EXPONENT T THIS WILL YIELD
* THE NUMBER OF SHIFTS REQUIRED TO DENORMALIZE FPA0. WHEN
* THE EXPONENT OF FPA0 IS = ZERO, THEN THE BINARY POINT
* WILL BE TO THE RIGHT OF THE MANTISSA
BCCE  96 54                      LDA   FP0SGN              ; TEST SIGN OF FPA0 MANTISSA
BCD0  2A 05                      BPL   LBCD7               ; BRANCH IF POSITIVE
BCD2  03 5B                      COM   FPCARY              ; COMPLEMENT CARRY IN BYTE
BCD4  BD BA 7B                   JSR   LBA7B               ; NEGATE MANTISSA OF FPA0
BCD7  8E 00 4F          LBCD7    LDX   #FP0EXP             ; POINT X TO FPA0
BCDA  C1 F8                      CMPB  #-8                 ; EXPONENT DIFFERENCE < -8?
BCDC  2E 06                      BGT   LBCE4               ; YES
BCDE  BD BA AE                   JSR   LBAAE               ; SHIFT FPA0 RIGHT UNTIL FPA0 EXPONENT = $A0
BCE1  0F 5B                      CLR   FPCARY              ; CLEAR CARRY IN BYTE
BCE3  39                         RTS
BCE4  0F 5B             LBCE4    CLR   FPCARY              ; CLEAR CARRY IN BYTE
BCE6  96 54                      LDA   FP0SGN              ; * GET SIGN OF FPA0 MANTISSA
BCE8  49                         ROLA                      ; * ROTATE IT INTO THE CARRY FLAG
BCE9  06 50                      ROR   FPA0                ; ROTATE CARRY (MANTISSA SIGN) INTO BIT 7
* OF LS BYTE OF MANTISSA
BCEB  7E BA BA                   JMP   LBABA               ; DE-NORMALIZE FPA0
