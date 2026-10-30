; Super Extended Color BASIC 2.0 (CoCo 3) -- $EA49-$EBF4
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: HCIRCLE=$EA49, CIRCDATA=$EB99

* HCIRCLE
EA49  0D E6             HCIRCLE  TST   HRMODE              ; CHECK HI-RES GRAPHICS MODE
EA4B  10 27 FC A0                LBEQ  LE6EF               ; BRANCH IF NOT HI-RES GRAPHICS
EA4F  10 21 15 AD                LBRN  RAMLINK             ; RAM HOOK
EA53  81 40                      CMPA  #'@'                ; CHECK FOR @ SIGN (HCIRCLE@ IS LEGAL SYNTAX)
EA55  26 02                      BNE   LEA59               ; BRANCH IF NOT
EA57  9D 9F                      JSR   GETNCH              ; GET THE NEXT CHARACTER FROM BASIC'S INPUT LINE
EA59  BD EB 60          LEA59    JSR   LEB60               ; GET MAX HORIZONTAL & VERTICAL COORD VALUES AND PUT THEM IN VD3 & VD5
EA5C  BD EA 04                   JSR   LEA04               ; GET HORIZONTAL & VERTICAL CENTER COORDS AND PUT THEM IN VBD AND VBF
EA5F  BD E7 AD                   JSR   LE7AD               ; NORMALIZE START COORDS FOR PROPER HI-RES GRAPHICS MODE
EA62  AE C4                      LDX   ,U                  ; GET HORIZONTAL COORD
EA64  9F CB                      STX   VCB                 ; SAVE IT
EA66  AE 42                      LDX   $02,U               ; GET VERTICAL COORD
EA68  9F CD                      STX   VCD                 ; SAVE IT
EA6A  BD B2 6D                   JSR   SYNCOMMA            ; DO A SYNTAX CHECK FOR A COMMA
EA6D  BD B7 3D                   JSR   LB73D               ; EVALUATE EXPRESSION, RETURN VALUE IN X
EA70  CE 00 CF                   LDU   #VCF                ; POINT U TO TEMP DATA STORAGE
EA73  AF C4                      STX   ,U                  ; SAVE RADIUS
EA75  BD E7 B0                   JSR   LE7B0               ; NOW A JSR TO AN RTS; WAS A CALL TO A NORMALIZATION ROUTINE
EA78  86 01                      LDA   #$01                ; PSET FLAG
EA7A  97 C2                      STA   SETFLG              ; SAVE PSET/PRESET FLAG
EA7C  BD E7 18                   JSR   LE718               ; GO EVALUATE COLOR EXPRESSION AND SAVE VALUE
EA7F  8E 01 00                   LDX   #$100               ; DEFAULT HEIGHT/WIDTH RATIO
EA82  9D A5                      JSR   GETCCH              ; GET BASIC'S CURRENT INPUT CHARACTER
EA84  27 0F                      BEQ   LEA95               ; BRANCH IF NONE
EA86  BD B2 6D                   JSR   SYNCOMMA            ; DO A SYNTAX CHECK FOR A COMMA
EA89  BD B1 41                   JSR   LB141               ; EVALUATE A NUMERIC EXPRESSION
EA8C  96 4F                      LDA   FP0EXP              ; GET FPA0 EXPONENT
EA8E  8B 08                      ADDA  #$08                ; ADD 8 TO IT (EFFECTIVELY MULTIPLIES BY 256)
EA90  97 4F                      STA   FP0EXP              ; SAVE NEW VALUE
EA92  BD B7 40                   JSR   LB740               ; EVALUATE EXPRESSION, RETURN VALUE IN X
EA95  96 E6             LEA95    LDA   HRMODE              ; GET CURRENT HI-RES GRAPHICS MODE
EA97  81 02                      CMPA  #$02                ; SEE WHICH MODE IT IS
EA99  22 04                      BHI   LEA9F               ; BRANCH IF HSCREEN 4
EA9B  1F 10                      TFR   X,D                 ; PREPARE TO DOUBLE THE HEIGHT/WIDTH RATIO FOR MODES 0-2
EA9D  30 8B                      LEAX  D,X                 ; DOUBLE H/W RATIO TO COMPENSATE FOR HORIZONTAL PIXEL SIZE
EA9F  9F D1             LEA9F    STX   VD1                 ; SAVE H/W RATIO
EAA1  C6 01                      LDB   #$01                ; CODE FOR PSET
EAA3  D7 C2                      STB   SETFLG              ; SET PSET/PRESET FLAG TO PSET
EAA5  D7 D8                      STB   VD8                 ; FIRST TIME FLAG - SET TO 0 AFTER ARC DRAWN
EAA7  BD EB 7B                   JSR   LEB7B               ; EVALUATE CIRCLE START POINT (OCTANT, SUBARC)
EAAA  34 06                      PSHS  B,A                 ; SAVE START POINT
EAAC  BD EB 7B                   JSR   LEB7B               ; EVALUATE CIRCLE END POINT (OCTANT, SUBARC)
EAAF  DD D9                      STD   VD9                 ; SAVE END POINT
EAB1  35 06                      PULS  A,B                 ; GET BACK START POINT
EAB3  34 06             LEAB3    PSHS  B,A                 ; STORE CURRENT CIRCLE POSITION
EAB5  9E C3                      LDX   HOREND              ; GET END HORIZONTAL COORD
EAB7  9F BD                      STX   HORBEG              ; MAKE IT THE NEW START
EAB9  9E C5                      LDX   VEREND              ; GET END VERTICAL COORD
EABB  9F BF                      STX   VERBEG              ; MAKE IT THE NEW START
EABD  CE EB 9B                   LDU   #LEB9B              ; POINT TO TABLE OF SINES AND COSINES
EAC0  84 01                      ANDA  #$01                ; TEST OCTANT NUMBER
EAC2  27 03                      BEQ   LEAC7               ; BRANCH IF EVEN
EAC4  50                         NEGB
EAC5  CB 08                      ADDB  #$08                ; CONVERT 0-7 TO 8-1 FOR ODD OCTANT NUMBERS
EAC7  58                LEAC7    ALSB                      ; MUL BY 2
EAC8  58                         ALSB                      ; DO IT AGAIN (FOUR BYTES PER TABLE ENTRY)
EAC9  33 C5                      LEAU  B,U                 ; POINT TO CORRECT TABLE ENTRY
EACB  34 40                      PSHS  U                   ; SAVE SIN/COS TABLE ENTRY
EACD  BD EB BD                   JSR   LEBBD               ; CALCULATE HORIZONTAL OFFSET
EAD0  35 40                      PULS  U                   ; GET BACK SIN/COS TABLE POINTER
EAD2  33 5E                      LEAU  $-02,U              ; MOVE TO COSINE (VERTICAL)
EAD4  34 10                      PSHS  X                   ; SAVE HORIZONTAL OFFSET
EAD6  BD EB BD                   JSR   LEBBD               ; CALCULATE VERTICAL OFFSET
EAD9  35 20                      PULS  Y                   ; PUT HORIZONTAL OFFSET IN Y
EADB  A6 E4                      LDA   ,S                  ; GET OCTANT NUMBER
EADD  84 03                      ANDA  #$03                ; MASK OFF BOTTOM TWO BITS
EADF  27 06                      BEQ   LEAE7               ; BRANCH IF OCTANT 0 OR 4
EAE1  81 03                      CMPA  #$03                ; NOW SEE IF BOTH BITS WERE SET
EAE3  27 02                      BEQ   LEAE7               ; BRANCH IF OCTANT 3 OR 7
EAE5  1E 12                      EXG   X,Y                 ; SWAP HORIZONTAL AND VERTICAL OFFSETS
EAE7  9F C3             LEAE7    STX   HOREND              ; SAVE HORIZONTAL OFFSET
* H/W RATIO WILL ONLY MODIFY THE VERTICAL COORD
EAE9  1F 20                      TFR   Y,D                 ; PUT CALCULATED VERTICAL OFFSET INTO ACCD
EAEB  44                         LSRA
EAEC  56                         RORB                      ; DIVIDE OFFSET BY 2
EAED  9E D1                      LDX   VD1                 ; GET H/W RATIO
EAEF  BD EB CB                   JSR   LEBCB               ; MULT VERTICAL OFFSET BY H/W RATIO
EAF2  1F 20                      TFR   Y,D                 ; TRANSFER PRODUCT TO ACCD
EAF4  4D                         TSTA                      ; CHECK OVERFLOW AND GET MS BYTE RESULT
EAF5  10 26 C9 51                LBNE  ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR (RESULT > 255)
EAF9  D7 C5                      STB   VEREND              ; SAVE DELTA VERTICAL MS BYTE
EAFB  1F 30                      TFR   U,D                 ; LS BYTE RESULT TO ACCA
EAFD  97 C6                      STA   VEREND+1            ; SAVE DELTA VERTICAL LS BYTE
EAFF  A6 E4                      LDA   ,S                  ; GET OCTANT NUMBER
EB01  81 02                      CMPA  #$02                ; CHECK FOR OCTANT 0,1,6,7
EB03  25 0E                      BCS   LEB13               ; BRANCH IF SUBARC HORIZONTAL END POINT >= HORIZONTAL CENTER
EB05  81 06                      CMPA  #$06                ; MORE CHECKS FOR OCTANT 0,1,6,7
EB07  24 0A                      BCC   LEB13               ; BRANCH IF SUBARC HORIZONTAL END POINT >= HORIZONTAL CENTER
EB09  DC CB                      LDD   VCB                 ; GET HORIZONTAL COORD OF CENTER
EB0B  93 C3                      SUBD  HOREND              ; SUBTRACT HORIZONTAL DIFFERENCE
EB0D  24 11                      BCC   LEB20               ; BRANCH IF NO UNDERFLOW
EB0F  4F                         CLRA
EB10  5F                         CLRB                      ; FORCE COORD TO 0 IF RESULT WAS LESS THAN 0
EB11  20 0D                      BRA   LEB20               ; SAVE NEW COORD
EB13  DC CB             LEB13    LDD   VCB                 ; GET HORIZONTAL COORD OF CENTER
EB15  D3 C3                      ADDD  HOREND              ; ADD HORIZONTAL DIFFERENCE
EB17  25 05                      BCS   LEB1E               ; BRANCH IF OVERFLOW
EB19  10 93 D3                   CMPD  VD3                 ; COMPARE TO MAX HORIZONTAL COORDINATE
EB1C  25 02                      BCS   LEB20               ; BRANCH IF < MAX HOR
EB1E  DC D3             LEB1E    LDD   VD3                 ; GET MAX HORIZONTAL COORD
EB20  DD C3             LEB20    STD   HOREND              ; SAVE NEW HORIZONTAL SUBARC END COORD
EB22  A6 E4                      LDA   ,S                  ; GET OCTANT NUMBER
EB24  81 04                      CMPA  #$04                ; CHECK FOR OCTANT 0,1,2 OR 3
EB26  25 0A                      BCS   LEB32               ; BRANCH IF SUBARC VERTICAL END POINT >= VERTICAL CENTER
EB28  DC CD                      LDD   VCD                 ; GET VERTICAL COORD OF CENTER
EB2A  93 C5                      SUBD  VEREND              ; SUBTRACT VERTICAL DIFFERENCE
EB2C  24 11                      BCC   LEB3F               ; BRANCH IF NO UNDERFLOW
EB2E  4F                         CLRA
EB2F  5F                         CLRB                      ; FORCE NEW VERTICAL TO 0 IF MINUS
EB30  20 0D                      BRA   LEB3F               ; SAVE NEW COORD
EB32  DC CD             LEB32    LDD   VCD                 ; GET VERTICAL COORD OF CENTER
EB34  D3 C5                      ADDD  VEREND              ; ADD VERTICAL DIFFERENCE
EB36  25 05                      BCS   LEB3D               ; BRANCH IF OVERFLOW
EB38  10 93 D5                   CMPD  VD5                 ; COMPARE TO MAX VERTICAL COORD
EB3B  25 02                      BCS   LEB3F               ; BRANCH IF < MAX VER
EB3D  DC D5             LEB3D    LDD   VD5                 ; GET MAX VERTICAL COORD
EB3F  DD C5             LEB3F    STD   VEREND              ; SAVE NEW VERTICAL SUBARC END COORD
EB41  0D D8                      TST   VD8                 ; CHECK FIRST TIME FLAG
EB43  26 03                      BNE   LEB48               ; DO NOT DRAWE A LINE FIRST TIME THROUGH -
; BECAUSE THE FIRST TIME YOU WOULD DRAW A LINE
; FROM THE CENTER TO THE FIRST POINT ON THE CIRCLE
EB45  17 FE 06                   LBSR  LE94E               ; DRAW A LINE
EB48  35 06             LEB48    PULS  A,B                 ; GET END COORDS
EB4A  04 D8                      LSR   VD8                 ; SHIFT FIRST TIME FLAG
EB4C  25 05                      BCS   LEB53               ; DO NOT CHECK FOR END POINT AFTER DRAWING FIRST ARC
EB4E  10 93 D9                   CMPD  VD9                 ; COMPARE CURRENT POSITION TO END POINT
EB51  27 0C                      BEQ   LEB5F               ; BRANCH IF CIRCLE DRAWING IS FINISHED
* INCREMENT SUBARC CTR, IF . 7 THEN INC OCTANT CTR
EB53  5C                LEB53    INCB                      ; INC SUBARC COUNTER
EB54  C1 08                      CMPB  #$08                ; > 7?
EB56  26 04                      BNE   LEB5C               ; BRANCH IF NOT
EB58  4C                         INCA                      ; INCR OCTANT COUNTER
EB59  5F                         CLRB                      ; RESET SUBARC COUNTER
EB5A  84 07                      ANDA  #$07                ; KEEP IN RANGE OF 0-7; ONCE ACCA=ACCB, THIS WILL MAKE ACCA=0
; SO THE END POINT WILL BE (0,0) AND THE CIRCLE ROUTINE WILL END
EB5C  7E EA B3          LEB5C    JMP   LEAB3               ; KEEP DRAWING THE CIRCLE
EB5F  39                LEB5F    RTS                       ; EXIT CIRCLE ROUTINE

* GET MAXIMUM VALUE OF HORIZONTAL & VERTICAL COORDINATES NORMALIZED FOR
* PROPER GRAPHICS MODE. RETURN VALUES: HORIZONTAL IN VD3, VERTICAL IN VD5
EB60  CE 00 D3          LEB60    LDU   #VD3                ; POINT U TO STORAGE AREA
EB63  8E 02 7F                   LDX   #640-1              ; GET MAXIMUM HORIZONTAL COORD
EB66  AF C4                      STX   ,U                  ; SAVE IT
EB68  96 E6                      LDA   HRMODE              ; GET CURRENT GRAPHICS MODE
EB6A  81 02                      CMPA  #$02                ; SEE WHICH MODE
EB6C  2E 05                      BGT   LEB73               ; BRANCH IF MODES 3 OR 4
EB6E  8E 01 3F                   LDX   #320-1              ; MAXIMUM VALUE FOR HORIZONTAL COORD IN MODES 1 AND 2
EB71  AF C4                      STX   ,U                  ; SAVE IT
EB73  8E 00 BF          LEB73    LDX   #192-1              ; GET THE MAXIMUM VERTICAL COORD
EB76  AF 42                      STX   $02,U               ; SAVE IT
EB78  7E E7 B0                   JMP   LE7B0               ; JUMP TO AN RTS; ONCE WAS A NORMALIZATION ROUTINE

* EVALUATE CIRCLE START POINT (OCTANT, SUBARC)
* CALCULATE START OF END POINT WHICH IS A NUMBER FROM
* 0-63 SAVED AS AN OCTANT NUMBER (0-7) AND SUBARC NUMBER (0-7)
EB7B  5F                LEB7B    CLRB                      ; SET DEFAULT VALUE TO 0
EB7C  9D A5                      JSR   GETCCH              ; GET BASIC'S CURRENT INPUT CHARACTER
EB7E  27 11                      BEQ   LEB91               ; BRANCH IF NONE
EB80  BD B2 6D                   JSR   SYNCOMMA            ; DO A SYNTAX CHECK FOR A COMMA
EB83  BD B1 41                   JSR   LB141               ; EVALUATE A NUMERIC EXPRESSION
EB86  96 4F                      LDA   FP0EXP              ; GET EXPONENT OF FPA0
EB88  8B 06                      ADDA  #$06                ; ADD 6 TO EXPONENT - MULTIPLY EXPONENT BY 64
EB8A  97 4F                      STA   FP0EXP              ; RESAVE IT
EB8C  BD B7 0E                   JSR   LB70E               ; CONVERT FPA0 TO INTEGER IN ACCB
EB8F  C4 3F                      ANDB  #$3F                ; FORCE MAX VALUE OF 63
EB91  1F 98             LEB91    TFR   B,A                 ; SAVE VALUE IN ACCA ALSO
EB93  C4 07                      ANDB  #$07                ; NOW ACCB CONTAINS SUBARC NUMBER
EB95  44                         LSRA
EB96  44                         LSRA
EB97  44                         LSRA                      ; DIVIDE ACCA BY 8 - OCTANT NUMBER
EB98  39                         RTS

EB99  00 00 00 01       CIRCDATA FDB   $0000,$0001         ; SUBARC 0
EB9D  FE C5 19 19       LEB9D    FDB   $FEC5,$1919         ; SUBARC 1
EBA1  FB 16 31 F2       LEBA1    FDB   $FB16,$31F2         ; SUBARC 2
EBA5  F4 FB 4A 51       LEBA5    FDB   $F4FB,$4A51         ; SUBARC 3
EBA9  EC 84 61 F9       LEBA9    FDB   $EC84,$61F9         ; SUBARC 4
EBAD  E1 C7 78 AE       LEBAB    FDB   $E1C7,$78AE         ; SUBARC 5
EBB1  D4 DC 8E 3B       LEBAF    FDB   $D4DC,$8E3B         ; SUBARC 6
EBB5  C5 E5 A2 69       LEBB5    FDB   $C5E5,$A269         ; SUBARC 7
EBB9  B5 06 B5 06       LEBB9    FDB   $B506,$B506         ; SUBARC 8

* MULTIPLY RADIUS BY SIN/COS VALUE AND RETURN OFFSET IN X
EBBD  9E CF             LEBBD    LDX   VCF                 ; GET RADIUS
EBBF  EC C4                      LDD   ,U                  ; GET SIN/COS TABLE MODIFIER
EBC1  27 07                      BEQ   LEBCA               ; BRANCH IF 0 (OFFSET = RADIUS)
EBC3  83 00 01                   SUBD  #1                  ; SUBTRACT ONE
EBC6  8D 03                      BSR   LEBCB               ; MULTIPLY RADIUS BY SIN/COS
EBC8  1F 21                      TFR   Y,X                 ; RETURN RESULT IN X
EBCA  39                LEBCA    RTS

* MULTIPLY (UNSIGNED) TWO 16 BIT NUMBERS TOGETHER -
* ENTER WITH ONE NUMBER IN ACCD, THE OTHER IN X REGISTER
* THE 4 BYTE PRODUCT WILL BE STORED IN 4,S - 7,S
* (Y, U REGISTERS ON THE STACK). I.E. (AA AB) x (XH,XL)=
* 256 * AA * XH + 16 * (AA * XL + AB * HX) + AB * XL. THE TWO BYTE
* MULTIPLIER AND THE MULTIPLICAND ARE TREATED AS A 1
* BYTE INTEGER PART (MSB) WITH A 1 BYTE FRACTIONAL PART (LSB)

EBCB  34 76             LEBCB    PSHS  U,Y,X,B,A           ; SAVE REGISTERS AND RESERVE STORAGE SPACE ON THE STACK
EBCD  6F 64                      CLR   $04,S               ; RESET OVERFLOW FLAG
EBCF  A6 63                      LDA   $03,S               ; =
EBD1  3D                         MUL                       ; =
EBD2  ED 66                      STD   $06,S               ; = CALCULATE ACCB*XL, STORE RESULT IN 6,S
EBD4  EC 61                      LDD   $01,S               ; *
EBD6  3D                         MUL                       ; * CALCULATE ACCB*XH
EBD7  EB 66                      ADDB  $06,S               ; *
EBD9  89 00                      ADCA  #$00                ; =
EBDB  ED 65                      STD   $05,S               ; = ADD THE CARRY FROM THE 1ST MUL  TO THE RESULT OF THE 2ND MUL
EBDD  E6 E4                      LDB   ,S                  ; *
EBDF  A6 63                      LDA   $03,S               ; *
EBE1  3D                         MUL                       ; * CALCULATE ACCA*XL
EBE2  E3 65                      ADDD  $05,S               ; =
EBE4  ED 65                      STD   $05,S               ; = ADD RESULT TO TOTAL OF 2 PREVIOUS MULTS
EBE6  24 02                      BCC   LEBEA               ; BRANCH IF NO OVERFLOW
EBE8  6C 64                      INC   $04,S               ; SET OVERFLOW FLAG (ACCD > $FFFF)
EBEA  A6 E4             LEBEA    LDA   ,S                  ; *
EBEC  E6 62                      LDB   $02,S               ; *
EBEE  3D                         MUL                       ; * CALCULATE ACCA*XH
EBEF  E3 64                      ADDD  $04,S               ; =
EBF1  ED 64                      STD   $04,S               ; = ADD TO PREVIOUS RESULT
EBF3  35 F6                      PULS  A,B,X,Y,U,PC        ; RETURN WITH RESULT IN U AND Y
