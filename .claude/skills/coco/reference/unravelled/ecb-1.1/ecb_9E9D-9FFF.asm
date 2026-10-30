; Extended Color BASIC 1.1 -- $9E9D-$9FFF
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: CIRCLE=$9E9D

*
* CIRCLE
* THE CIRCLE IS ACTUALLY DRAWN AS A 64 SIDED
* POLYGON.  IT IS COMPOSED OF 64 'LINE' COMMANDS
9E9D  81 40             CIRCLE   CMPA  #'@'                ; CHECK FOR @ SIGN
9E9F  26 02                      BNE   L9EA3               ; SKIP IF NOT
9EA1  9D 9F                      JSR   GETNCH              ; GET ANOTHER CHARACTER FROM BASIC
9EA3  BD 95 22          L9EA3    JSR   L9522               ; GET MAX HOR & VER COORD VALUES AND PUT THEM IN VD3 AND VD5
9EA6  BD 93 B2                   JSR   L93B2               ; GET HOR & VER CENTER COORDS AND PUT IN HORBEG,VERBEG
9EA9  BD 93 1D                   JSR   L931D               ; NORMALIZE START COORDS FOR PROPER PMODE
9EAC  AE C4                      LDX   ,U                  ; GET HOR COORD
9EAE  9F CB                      STX   VCB                 ; SAVE IT
9EB0  AE 42                      LDX   $02,U               ; GET VERT COORD
9EB2  9F CD                      STX   VCD                 ; SAVE IT
9EB4  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
9EB7  BD B7 3D                   JSR   LB73D               ; EVALUATE EXPRESSION RETURN VALUE IN X
9EBA  CE 00 CF                   LDU   #VCF                ; POINT U TO TEMP DATA STORAGE
9EBD  AF C4                      STX   ,U                  ; SAVE RADIUS
9EBF  BD 93 20                   JSR   L9320               ; NORMALIZE RADIUS
9EC2  86 01                      LDA   #$01                ; SET TO PSET
9EC4  97 C2                      STA   SETFLG              ; SAVE PSET/PRESET FLAG
9EC6  BD 95 81                   JSR   L9581               ; GO EVALUATE COLOR EXPRESSION AND SAVE IN WCOLOR
9EC9  8E 01 00                   LDX   #$100               ; HEIGHT/WIDTH RATIO DEFAULT VALUE
9ECC  9D A5                      JSR   GETCCH              ; GET AN INPUT CHARACTER FROM BASIC
9ECE  27 0F                      BEQ   L9EDF               ; BRANCH IF NONE
9ED0  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
9ED3  BD B1 41                   JSR   LB141               ; EVALUATE EXPRESSION
9ED6  96 4F                      LDA   FP0EXP              ; *GET FPA0 EXPONENT, ADD 8 TO IT AND RESAVE IT - THIS
9ED8  8B 08                      ADDA  #$08                ; *WILL EFFECTIVELY MULTIPLY FPA0 BY 256.
9EDA  97 4F                      STA   FP0EXP              ; *
9EDC  BD B7 40                   JSR   LB740               ; EVALUATE EXPRESSION, RETURN VALUE IN X
9EDF  96 B6             L9EDF    LDA   PMODE               ; GET CURRENT PMODE VALUE
9EE1  85 02                      BITA  #$02                ; TEST FOR PMODE 0,1,4
9EE3  27 04                      BEQ   L9EE9               ; BRANCH IF SO
9EE5  1F 10                      TFR   X,D                 ; * MULT X BY 2 -FOR PMODES 2,3 THE HOR PIXELS ARE 2X AS LONG AS
9EE7  30 8B                      LEAX  D,X                 ; * PMODES 0,1,4; MULT HW RATIO BY 2 TO COMPENSATE
9EE9  9F D1             L9EE9    STX   VD1                 ; SAVE HW RATIO
9EEB  C6 01                      LDB   #$01                ; *
9EED  D7 C2                      STB   SETFLG              ; *SET PSET/PRESET FLAG TO PSET
9EEF  D7 D8                      STB   VD8                 ; FIRST TIME FLAG - SET TO 0 AFTER ARC DRAWN
9EF1  BD 9F E2                   JSR   L9FE2               ; EVALUATE CIRCLE START POINT (OCTANT, SUBARC)
9EF4  34 06                      PSHS  B,A                 ; SAVE START POINT
9EF6  BD 9F E2                   JSR   L9FE2               ; EVALUATE CIRCLE END POINT (OCTANT, SUBARC)
9EF9  DD D9                      STD   VD9                 ; SAVE END POINT
9EFB  35 06                      PULS  A,B                 ; GET START POINT
9EFD  34 06             L9EFD    PSHS  B,A                 ; STORE CURRENT CIRCLE POSITION
9EFF  9E C3                      LDX   HOREND              ; * MOVE HOR, VER COORDS FROM HOREND,VEREND TO
9F01  9F BD                      STX   HORBEG              ; * HORBEG, VERBEG R MOVE OLD END COORDINATES
9F03  9E C5                      LDX   VEREND              ; * NEW START COORDINATES
9F05  9F BF                      STX   VERBEG              ; *
9F07  CE 9E 7B                   LDU   #L9E79+2            ; POINT TO TABLE OF SINES & COSINES
9F0A  84 01                      ANDA  #$01                ; =GET OCTANT NUMBER
9F0C  27 03                      BEQ   L9F11               ; =BRANCH IF EVEN
9F0E  50                         NEGB                      ; *
9F0F  CB 08                      ADDB  #$08                ; *CONVERT 0-7 TO 8-1 FOR ODD OCTANT NUMBERS
9F11  58                L9F11    ASLB                      ; =
9F12  58                         ASLB                      ; =FOUR BYTES/TABLE ENTRY
9F13  33 C5                      LEAU  B,U                 ; POINT U TO CORRECT TABLE ENTRY
9F15  34 40                      PSHS  U                   ; SAVE SIN/COS TABLE ENTRY
9F17  BD 9F A7                   JSR   L9FA7               ; CALCULATE HORIZ OFFSET
9F1A  35 40                      PULS  U                   ; GET SIN/COS TABLE PTR
9F1C  33 5E                      LEAU  $-02,U              ; MOVE TO COSINE (VERT)
9F1E  34 10                      PSHS  X                   ; SAVE HORIZ OFFSET
9F20  BD 9F A7                   JSR   L9FA7               ; CALCULATE VERT OFFSET
9F23  35 20                      PULS  Y                   ; PUT HORIZ OFFSET IN Y
9F25  A6 E4                      LDA   ,S                  ; *
9F27  84 03                      ANDA  #$03                ; *
9F29  27 06                      BEQ   L9F31               ; *BRANCH IF OCTANT 0,3,4,7
9F2B  81 03                      CMPA  #$03                ; *
9F2D  27 02                      BEQ   L9F31               ; *BRANCH IF OCTANT 0,3,4,7
9F2F  1E 12                      EXG   X,Y                 ; SWAP HOR AND VERT OFFSETS
9F31  9F C3             L9F31    STX   HOREND              ; SAVE HORIZ OFFSET
* THE HW RATIO WILL ONLY MODIFY THE VERT COORD
9F33  1F 21                      TFR   Y,X                 ; LOAD X WITH THE CALCULATED VERT OFFSET
9F35  DC D1                      LDD   VD1                 ; GET HW RATIO
9F37  BD 9F B5                   JSR   >L9FB5              ; MULT VERT OFFSET BY HW RATIO
9F3A  1F 20                      TFR   Y,D                 ; TRANSFER THE PRODUCT TO ACCD
9F3C  4D                         TSTA                      ; CHECK OVERFLOW FLAG AND GET MSB RESULT
9F3D  10 26 15 09                LBNE  LB44A               ; 'FC' ERROR IF RESULT > 255
9F41  D7 C5                      STB   VEREND              ; SAVE DELTA VER MBS
9F43  1F 30                      TFR   U,D                 ; LSB RESULT TO ACCA
9F45  97 C6                      STA   VEREND+1            ; SAVE DELTA VER LSB
9F47  A6 E4                      LDA   ,S                  ; *
9F49  81 02                      CMPA  #$02                ; * BRANCH IF OCTANT = 0,1,6,7 (SUBARC HOR END
9F4B  25 0E                      BLO   L9F5B               ; * POINT >= HOR CENTER)
9F4D  81 06                      CMPA  #$06                ; = BRANCH IF OCTANT = 0,1,6,7 (SUSARC HOR END
9F4F  24 0A                      BCC   L9F5B               ; = POINT >= HOR CENTER)
9F51  DC CB                      LDD   VCB                 ; GET HOR COORD OF CENTER
9F53  93 C3                      SUBD  HOREND              ; SUBTRACT HORIZONTAL DIFFERENCE
9F55  24 11                      BCC   L9F68               ; BRANCH IF NO UNDERFLOW
9F57  4F                         CLRA                      ; *
9F58  5F                         CLRB                      ; * IF NEW HOR < 0, FORCE IT TO BE 0
9F59  20 0D                      BRA   L9F68               ; SAVE NEW COORD
9F5B  DC CB             L9F5B    LDD   VCB                 ; GET HOR COORD OF CENTER
9F5D  D3 C3                      ADDD  HOREND              ; ADD HORIZONTAL DIFFERENCE
9F5F  25 05                      BLO   L9F66               ; BRANCH IF OVERFLOW
9F61  10 93 D3                   CMPD  VD3                 ; COMPARE TO MAX HOR COORD
9F64  25 02                      BLO   L9F68               ; BRANCH IF < MAX HOR
9F66  DC D3             L9F66    LDD   VD3                 ; GET MAX HOR COORD
9F68  DD C3             L9F68    STD   HOREND              ; SAVE NEW HORIZ SU8ARC END COORD
9F6A  A6 E4                      LDA   ,S                  ; *
9F6C  81 04                      CMPA  #$04                ; * BRANCH IF OCTANT = 0,1,2,3 (SUBARC VERT END
9F6E  25 0A                      BLO   L9F7A               ; * POINT >= VERT CENTER)
9F70  DC CD                      LDD   VCD                 ; GET VER COORD OF CENTER
9F72  93 C5                      SUBD  VEREND              ; SUBTRACT VERTICAL DIFFERENCE
9F74  24 11                      BCC   L9F87               ; BRANCH IF NO UNDERFIOW
9F76  4F                         CLRA                      ; *
9F77  5F                         CLRB                      ; *IF NEW VERT < 0, FORCE IT TO BE 0
9F78  20 0D                      BRA   L9F87               ; SAVE NEW COORD
9F7A  DC CD             L9F7A    LDD   VCD                 ; GET VER COORD OF CENTER
9F7C  D3 C5                      ADDD  VEREND              ; ADD VERTICAL DIFFERENCE
9F7E  25 05                      BLO   L9F85               ; BRANCH IF OVERFLOW
9F80  10 93 D5                   CMPD  VD5                 ; COMPARE TO MAX VERT COORD
9F83  25 02                      BLO   L9F87               ; BRANCH IF < MAX VER
9F85  DC D5             L9F85    LDD   VD5                 ; GET MAX VERT COORD
9F87  DD C5             L9F87    STD   VEREND              ; SAVE NEW VERT SUSARC END COORD
9F89  0D D8                      TST   VD8                 ; CHECK FIRST TIME FLAG
9F8B  26 02                      BNE   L9F8F               ; *DO NOT DRAW A LINE FIRST TIME THRU -
* *BECAUSE THE FIRST TIME YOU WOULD DRAW A LINE
* *FROM THE CENTER TO THE FIRST POINT ON THE CIRCLE
9F8D  8D 50                      BSR   L9FDF               ; DRAW A LINE
9F8F  35 06             L9F8F    PULS  A,B                 ; GET END COORDS
9F91  04 D8                      LSR   VD8                 ; SHIFT FIRST TIME FLAG
9F93  25 05                      BLO   L9F9A               ; DO NOT CHECK FOR END POINT AFTER DRAWING FIRST ARC
9F95  10 93 D9                   CMPD  VD9                 ; COMPARE CURRENT POSITION TO END POINT
9F98  27 0C                      BEQ   L9FA6               ; CIRCLE DRAWING FINISHED
* INCREMENT SUBARC CTR, IF > 7 THEN INCR OCTANT CTR
9F9A  5C                L9F9A    INCB                      ; INCR SUBARC CTR
9F9B  C1 08                      CMPB  #$08                ; > 7?
9F9D  26 04                      BNE   L9FA3               ; NO
9F9F  4C                         INCA                      ; INCR OCTANT CTR
9FA0  5F                         CLRB                      ; RESET SUBARC CTR
9FA1  84 07                      ANDA  #$07                ; *KEEP IN RANGE OF 0-7; ONCE ACCA = B, THIS WILL MAKE ACCA = 0,
* *SO THE END POINT WILL BE (0,0) AND THE CIRCLE ROUTINE WILL END.
9FA3  7E 9E FD          L9FA3    JMP   L9EFD               ; KEEP DRAWING CIRCLE
9FA6  39                L9FA6    RTS                       ; EXIT CIRCLE ROUTINE
* MULTIPLY RADIUS BY SIN/COS VALUE AND RETURN OFFSET IN X
9FA7  9E CF             L9FA7    LDX   VCF                 ; GET RADIUS
9FA9  EC C4                      LDD   ,U                  ; GET SIN/COS TABLE MODIFIER
9FAB  27 07                      BEQ   L9FB4               ; BRANCH IF = 0 - OFFSET = RADIUS
9FAD  83 00 01                   SUBD  #1                  ; SUBTR 1
9FB0  8D 03                      BSR   L9FB5               ; MULT RADIUS BY SIN/COS
9FB2  1F 21                      TFR   Y,X                 ; RETURN RESULT IN X REG
9FB4  39                L9FB4    RTS
* MULTIPLY (UNSIGNED) TWO 16 BIT NUMBERS TOGETHER -
* ENTER WITH ONE NUMBER IN ACCD, THE OTHER IN X
* REG. THE 4 BYTE PRODUCT WILL BE STORED IN 4,S-7,S
* (Y, U REG ON THE STACK). I.E. (AA AB) X (XH XL) =
* 256*AA*XH+16*(AA*XL+AB*XH)+AB*XL. THE 2 BYTE
* MULTIPLIER AND MULTIPLICAND ARE TREATED AS A 1
* BYTE INTEGER PART (MSB) WITH A 1 BYTE FRACTIONAL PART (LSB)
9FB5  34 76             L9FB5    PSHS  U,Y,X,B,A           ; SAVE REGISTERS AND RESERVE STORAGE SPACE ON THE STACK
9FB7  6F 64                      CLR   $04,S               ; RESET OVERFLOW FLAG
9FB9  A6 63                      LDA   $03,S               ; =
9FBB  3D                         MUL                       ; =
9FBC  ED 66                      STD   $06,S               ; = CALCULATE ACCB*XL, STORE RESULT IN 6,S
9FBE  EC 61                      LDD   $01,S               ; *
9FC0  3D                         MUL                       ; * CALCULATE ACCB*XH
9FC1  EB 66                      ADDB  $06,S               ; =
9FC3  89 00                      ADCA  #$00                ; =
9FC5  ED 65                      STD   $05,S               ; = ADD THE CARRY FROM THE 1ST MUL TO THE RESULT OF THE 2ND MUL
9FC7  E6 E4                      LDB   ,S                  ; *
9FC9  A6 63                      LDA   $03,S               ; *
9FCB  3D                         MUL                       ; * CALCULATE ACCA*XL
9FCC  E3 65                      ADDD  $05,S               ; =
9FCE  ED 65                      STD   $05,S               ; = ADD RESULT TO TOTAL OF 2 PREVIOUS MULTS
9FD0  24 02                      BCC   L9FD4               ; BRANCH IF NO OVERFLOW
9FD2  6C 64                      INC   $04,S               ; SET OVERFLOW FLAG (ACCD > $FFFF)
9FD4  A6 E4             L9FD4    LDA   ,S                  ; *
9FD6  E6 62                      LDB   $02,S               ; *
9FD8  3D                         MUL                       ; * CALCULATE ACCA*XH
9FD9  E3 64                      ADDD  $04,S               ; =
9FDB  ED 64                      STD   $04,S               ; = ADD TO PREVIOUS RESULT
9FDD  35 F6                      PULS  A,B,X,Y,U,PC        ; RETURN RESULT IN U,Y
9FDF  7E 94 A1          L9FDF    JMP   L94A1               ; GO DRAW A LINE FROM (HORBEG,VERBEG) TO (HOREND,VEREND)

* CALCULATE START OR END POINT WHICH IS A NUMBER FROM
* 0 TO 63 SAVED AS AN OCTANT NUMBER (0-7) AND A SUBARC NUMBER (0-7)
9FE2  5F                L9FE2    CLRB                      ; DEFAULT VALUE OF ZERO
9FE3  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHAR
9FE5  27 11                      BEQ   L9FF8               ; BRANCH IF NONE
9FE7  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
9FEA  BD B1 41                   JSR   LB141               ; EVALUATE NUMERIC EXPRESSION
9FED  96 4F                      LDA   FP0EXP              ; GET EXPONENT OF FPA0
9FEF  8B 06                      ADDA  #$06                ; ADD 6 TO EXPONENT - MULTIPLY EXPONENT BY 64
9FF1  97 4F                      STA   FP0EXP              ; RESAVE EXPONENT
9FF3  BD B7 0E                   JSR   LB70E               ; CONVERT FPA0 TO INTEGER IN ACCB
9FF6  C4 3F                      ANDB  #$3F                ; MAX VALUE OF 63
9FF8  1F 98             L9FF8    TFR   B,A                 ; SAVE VALUE IN ACCA ALSO
9FFA  C4 07                      ANDB  #$07                ; NOW ACCB CONTAINS SUBARC NUMBER
9FFC  44                         LSRA                      ; *
9FFD  44                         LSRA                      ; *
9FFE  44                         LSRA                      ; * DIVIDE ACCA BY EIGHT - OCTANT NUMBER
9FFF  39                         RTS
