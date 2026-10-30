; Extended Color BASIC 1.1 -- $8286-$847F
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: XVEC8=$8286, XVEC18=$829C, XVEC20=$82B9, XVEC23=$8304, COS=$8378, TAN=$8381, ATN=$83B0, LOG=$8446

* CLOSE FILES RAM HOOK - THIS CODE CORRECTS A
* BUG IN 1.0 BASIC WHICH WAS FIXED BY 1.1 BASIC
8286  96 6F             XVEC8    LDA   DEVNUM              ; GET DEVICE NUMBER
8288  4C                         INCA                      ; CHECK FOR CASSETTE
8289  26 FA                      BNE   L8285               ; RETURN IF NOT CASSETTE
828B  96 78                      LDA   FILSTA              ; GET FILE STATUS
828D  81 02                      CMPA  #$02                ; OPEN FOR OUTPUT?
828F  26 F4                      BNE   L8285               ; RETURN IF NOT OPEN FOR OUTPUT
8291  96 79                      LDA   CINCTR              ; GET CHARACTER BUFFER COUNTER
8293  26 F0                      BNE   L8285               ; RETURN IF NOT EMPTY
8295  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
8297  32 62                      LEAS  $02,S               ; GET RETURN ADDRESS OFF OF STACK
8299  7E A4 44                   JMP   LA444               ; WRITE END OF FILE TAPE BLOCK
* RUN RAM HOOK
829C  CC BA 42          XVEC18   LDD   #$BA42              ; MID HIGH VALUE + MID LOW VALUE
829F  DD DF                      STD   VOLHI               ; INITIALIZE PLAY VOLUME
82A1  86 02                      LDA   #$02
82A3  97 E2                      STA   TEMPO               ; INITIALIZE TEMPO TO 2
82A5  97 DE                      STA   OCTAVE              ; INITIALIZE OCTAVE TO 3
82A7  48                         ASLA                      ; X2
82A8  97 E1                      STA   NOTELN              ; INITIALIZE NOTE LENGTH TO 5
82AA  0F E5                      CLR   DOTVAL              ; LEAR NOTE TIMER SCALE FACTOR
82AC  DC 8A                      LDD   ZERO                ; ZERO ACCD
82AE  DD E8                      STD   ANGLE               ; INITIALIZE DRAW ANGLE AND SCALE TO 1
82B0  C6 80                      LDB   #128                ; * INITIALIZE HORIZONTAL DEFAULT
82B2  DD C7                      STD   HORDEF              ; * COORDINATE TO MID POSITION
82B4  C6 60                      LDB   #96                 ; = INITIALIZE VERTICAL DEFAULT
82B6  DD C9                      STD   VERDEF              ; = COORDINATE TO MID POSITION
82B8  39                         RTS
* COMMAND INTERPRETATION LOOP RAM HOOK
82B9  32 62             XVEC20   LEAS  $02,S               ; PURGE RETURN ADDRESS FROM STACK
82BB  1C AF             L82BB    ANDCC #$AF                ; ENABLE INTERRUPTS
82BD  BD AD EB                   JSR   LADEB               ; CHECK FOR KEYBOARD BREAK
82C0  9E A6                      LDX   CHARAD              ; * GET CURRENT BASIC LINE
82C2  9F 2F                      STX   TINPTR              ; * POINTER AND SAVE IT
82C4  A6 80                      LDA   ,X+                 ; GET CURRENT INPUT CHARACTER AND ADVANCE POINTER
82C6  27 07                      BEQ   L82CF               ; BRANCH IF END OF LINE
82C8  81 3A                      CMPA  #':'                ; CHECK FOR COLON
82CA  27 25                      BEQ   L82F1               ; CONTINUE INTERPRETING IF COLON
82CC  7E B2 77                   JMP   LB277               ; SNYTAX ERROR - COLON ONLY LEGAL LINE SEPARATOR
82CF  A6 81             L82CF    LDA   ,X++                ; * GET 1ST BYTE OF ADDRESS OF NEXT
82D1  97 00                      STA   ENDFLG              ; * BASIC LINE AND SAVE IT
82D3  26 03                      BNE   L82D8               ; BRANCH IF NOT END OF PROGRAM
82D5  7E AE 15                   JMP   LAE15               ; RETURN TO DIRECT MODE - PRINT OK
82D8  EC 80             L82D8    LDD   ,X+                 ; GET LINE NUMBER OF NEXT LINE
82DA  DD 68                      STD   CURLIN              ; SAVE LINE NUMBER
82DC  9F A6                      STX   CHARAD              ; SAVE ADDRESS NEXT BYTE TO INTERPRET
82DE  96 AF                      LDA   TRCFLG              ; TEST THE TRACE FLAG
82E0  27 0F                      BEQ   L82F1               ; BRANCH IF TRACE OFF
82E2  86 5B                      LDA   #$5B                ; <LEFT HAND MARKER FOR TRON LINE NUMBER
82E4  BD A2 82                   JSR   LA282               ; OUTPUT A CHARACTER
82E7  96 68                      LDA   CURLIN              ; GET MS BYTE OF LINE NUMBER
82E9  BD BD CC                   JSR   LBDCC               ; CONVERT ACCD TO DECIMAL AND PRINT ON SCREEN
82EC  86 5D                      LDA   #$5D                ; > RIGHT HAND MARKER FOR TRON LINE NUMBER
82EE  BD A2 82                   JSR   LA282               ; OUTPUT A CHARACTER
82F1  9D 9F             L82F1    JSR   GETNCH              ; GET A CHARACTER FROM BASIC
82F3  1F A9                      TFR   CC,B                ; SAVE STATUS IN ACCB
82F5  81 98                      CMPA  #$98                ; CSAVE TOKEN
82F7  27 1D                      BEQ   L8316               ; GO DO A CSAVE
82F9  81 97                      CMPA  #$97                ; CLOAD TOKEN
82FB  27 14                      BEQ   L8311               ; PROCESS CLOAD
82FD  1F 9A                      TFR   B,CC                ; GET STATUS REG BACK
82FF  BD AD C6                   JSR   LADC6               ; LINK BACK TO BASIC'S INTERPRETATION LOOP
8302  20 B7                      BRA   L82BB               ; GO TO MAIN INTERPRETATION LOOP
* CRUNCH RAM HOOK
8304  AE 62             XVEC23   LDX   $02,S               ; *CHECK TO SEE IF THE ROUTINE CALLING 'CRUNCH'
8306  8C AC 9D                   CMPX  #LAC9D              ; *IS COMING FROM THE MAIN LOOP IN BASIC
8309  26 05                      BNE   L8310               ; *AND BRANCH IF NOT
830B  8E 82 F1                   LDX   #L82F1              ; =IF IT IS, DO NOT RETURN TO COLOR BASIC
830E  AF 62                      STX   $02,S               ; =BUT TO THE EXBAS PATCH INSTEAD
8310  39                L8310    RTS
8311  BD 8C 62          L8311    JSR   L8C62               ; CHECK EXBAS CLOAD HANDLER
8314  20 A5                      BRA   L82BB               ; GO TO MAIN INTERPRETATION LOOP
8316  8D 02             L8316    BSR   L831A               ; DO A CSAVE
8318  20 A1                      BRA   L82BB               ; GO TO MAIN INTERPRETATION LOOP
831A  9D 9F             L831A    JSR   GETNCH              ; GET A CHAR FROM BASIC
831C  81 4D                      CMPA  #'M'                ; CHECK FOR CSAVEM
831E  10 26 21 2A                LBNE  LA44C               ; BRANCH IF IT'S NOT CSAVEM
* CSAVEM
8322  9D 9F                      JSR   GETNCH              ; GET A CHAR FROM BASIC
8324  BD A5 78                   JSR   LA578               ; GET NAME OF FILE FROM BASIC
8327  8D 43                      BSR   L836C               ; GO GET THE START ADDRESS
8329  BF 01 E7                   STX   CASBUF+13           ; PUT IT IN HEADER BUFFER
832C  8D 3E                      BSR   L836C               ; GO GET END ADDRESS
832E  AC 62                      CMPX  $02,S               ; COMPARE TO START ADDRESS
8330  10 25 31 16                LBCS  LB44A               ; 'FC' ERROR IF START > END
8334  8D 36                      BSR   L836C               ; GO GET XFER ADDRESS
8336  BF 01 E5                   STX   CASBUF+11           ; PUT IT IN HEADER BUFFER
8339  9D A5                      JSR   GETCCH              ; GET NEW CHARACTER
833B  26 D3                      BNE   L8310               ; RETURN IF NOT END OF LINE
833D  86 02                      LDA   #$02                ; FILE TYPE (MACHINE LANGUAGE)
833F  9E 8A                      LDX   ZERO                ; X = 0000 FILE MODE AND ASCII FLAG
8341  BD A6 5F                   JSR   LA65F               ; WRITE HEADER BLOCK
8344  0F 78                      CLR   FILSTA              ; CLOSE CASSETTE FILES
8346  0C 7C                      INC   BLKTYP              ; BLOCK TYPE = 1
8348  BD A7 D8                   JSR   LA7D8               ; GO WRITE LEADER
834B  AE 64                      LDX   $04,S               ; GET STARTING ADDRESS
834D  9F 7E             L834D    STX   CBUFAD              ; STORE BUFFER START ADOR
834F  86 FF                      LDA   #255                ; BLOCK SIZE = 2SS
8351  97 7D                      STA   BLKLEN              ; STORE IN BLOCK SIZE
8353  EC 62                      LDD   $02,S               ; GET ENDING ADDRESS
8355  93 7E                      SUBD  CBUFAD              ; SUBTRACT START ADDRESS
8357  24 05                      BCC   L835E               ; BRANCH IF MORE TO BE WRITTEN
8359  32 66                      LEAS  $06,S               ; CLEAN UP STACK
835B  7E A4 91                   JMP   LA491               ; WRITE FINAL BLOCK
835E  10 83 00 FF       L835E    CMPD  #$00FF              ; AT LEAST 1 FULL BLK LEFT?
8362  24 03                      BCC   L8367               ; YES
8364  5C                         INCB                      ; NO - PUT WHAT'S LEFT IN BLKLEN
8365  D7 7D                      STB   BLKLEN              ; BUFFER SIZE
8367  BD A7 F4          L8367    JSR   LA7F4               ; WRITE A BLOCK
836A  20 E1                      BRA   L834D               ; GO DO SOME MORE
836C  BD B2 6D          L836C    JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
836F  BD B7 3D                   JSR   LB73D               ; EVAL EXPR - RETURN VALUE IN X
8372  EE E4                      LDU   ,S                  ; SAVE RETURN ADDRESS IN U
8374  AF E4                      STX   ,S                  ; PUT THE EXPRESSION ON THE STACK
8376  1F 35                      TFR   U,PC                ; 'RETURN' TO CALLING ADDRESS

* COS
* THE VALUE OF COS(X) IS DETERMINED BY THE TRIG IDENTITY COS(X)=SIN((PI/2)+X)
8378  8E 83 AB          COS      LDX   #L83AB              ; POINT X TO FP CONSTANT (P1/2)
837B  BD B9 C2                   JSR   LB9C2               ; ADD FPA0 TO (X)
837E  7E BF 78          L837E    JMP   LBF78               ; JUMP TO SIN ROUTINE

* TAN
* THE VALUE OF TAN(X) IS DETERMINED BY THE TRIG IDENTITY TAN(X)=SIN(X)/COS(X)
8381  BD BC 2F          TAN      JSR   LBC2F               ; PACK FPA0 AND MOVE IT TO FPA3
8384  0F 0A                      CLR   RELFLG              ; RESET QUADRANT FLAG
8386  8D F6                      BSR   L837E               ; CALCULATE SIN OF ARGUMENT
8388  8E 00 4A                   LDX   #V4A                ; POINT X TO FPA5
838B  BD BC 35                   JSR   LBC35               ; PACK FPA0 AND MOVE IT TO FPA5
838E  8E 00 40                   LDX   #V40                ; POINT X TO FPA3
8391  BD BC 14                   JSR   LBC14               ; MOVE FPA3 TO FPA0
8394  0F 54                      CLR   FP0SGN              ; FORCE FPA0 MANTISSA TO BE POSITIVE
8396  96 0A                      LDA   RELFLG              ; GET THE QUADRANT FLAG - COS NEGATIVE IN QUADS 2,3
8398  8D 0C                      BSR   L83A6               ; CALCULATE VALUE OF COS(FPA0)
839A  0D 4F                      TST   FP0EXP              ; CHECK EXPONENT OF FPA0
839C  10 27 36 F2                LBEQ  LBA92               ; 'OV' ERROR IF COS(X)=0
83A0  8E 00 4A                   LDX   #V4A                ; POINT X TO FPA5
83A3  7E BB 8F          L83A3    JMP   LBB8F               ; DIVIDE (X) BY FPA0 - SIN(X)/COS(X)
83A6  34 02             L83A6    PSHS  A                   ; SAVE SIGN FLAG ON STACK
83A8  7E BF A6                   JMP   LBFA6               ; EXPAND POLYNOMIAL

83AB  81 49 0F DA A2    L83AB    FCB   $81,$49,$0F,$DA,$A2 ; 1.57079633 (PI/2)

* ATN
* A 12 TERM TAYLOR SERIES IS USED TO EVALUATE THE
* ARCTAN EXPRESSION.  TWO DIFFERENT FORMULI ARE USED
* TO EVALUATE THE EXPRESSION DEPENDING UPON
* WHETHER OR NOT THE ARGUMENT SQUARED IS > OR < 1.0

* IF X**2<1 THEN ATN=X-(X**3)/3+(X**5)/5-(X**7)/7………..
* IF X**2>=1 THEN ATN=PI/2-(1/X-1/((X**3)*3)+(1/((X**5)*5)-………)

83B0  96 54             ATN      LDA   FP0SGN              ; * GET THE SIGN OF THE MANTISSA AND
83B2  34 02                      PSHS  A                   ; * SAVE IT ON THE STACK
83B4  2A 02                      BPL   L83B8               ; BRANCH IF POSITIVE MANTISSA
83B6  8D 24                      BSR   L83DC               ; CHANGE SIGN OF FPA0
83B8  96 4F             L83B8    LDA   FP0EXP              ; * GET EXPONENT OF FPA0 AND
83BA  34 02                      PSHS  A                   ; * SAVE IT ON THE STACK
83BC  81 81                      CMPA  #$81                ; IS FPAO < 1.0?
83BE  25 05                      BLO   L83C5               ; YES
83C0  8E BA C5                   LDX   #LBAC5              ; POINT X TO FP CONSTANT 1.0
83C3  8D DE                      BSR   L83A3               ; GET RECIPROCAL OF FPA0
83C5  8E 83 E0          L83C5    LDX   #L83E0              ; POINT (X) TO TAYLOR SERIES COEFFICIENTS
83C8  BD BE F0                   JSR   LBEF0               ; EXPAND POLYNOMIAL
83CB  35 02                      PULS  A                   ; GET EXPONENT OF ARGUMENT
83CD  81 81                      CMPA  #$81                ; WAS ARGUMENT < 1.0?
83CF  25 06                      BLO   L83D7               ; YES
83D1  8E 83 AB                   LDX   #L83AB              ; POINT (X) TO FP NUMBER (PI/2)
83D4  BD B9 B9                   JSR   LB9B9               ; SUBTRACT FPA0 FROM (PI/2)
83D7  35 02             L83D7    PULS  A                   ; * GET SIGN OF INITIAL ARGUMENT MANTISSA
83D9  4D                         TSTA                      ; * AND SET FLAGS ACCORDING TO IT
83DA  2A 03                      BPL   L83DF               ; RETURN IF ARGUMENT WAS POSITIVE
83DC  7E BE E9          L83DC    JMP   LBEE9               ; CHANGE MANTISSA SIGN OF FPA0
83DF  39                L83DF    RTS
*
* TCHEBYSHEV MODIFIED TAYLOR SERIES COEFFICIENTS FOR ARCTANGENT
83E0  0B                L83E0    FCB   $0B                 ; TWELVE COEFFICIENTS
83E1  76 B3 83 BD D3    L83E1    FCB   $76,$B3,$83,$BD,$D3 ; -6.84793912E-04 1/23
83E6  79 1E F4 A6 F5    L83E6    FCB   $79,$1E,$F4,$A6,$F5 ; +4.85094216E-03 1/21
83EB  7B 83 FC B0 10    L83EB    FCB   $7B,$83,$FC,$B0,$10 ; -0.0161117018   1/19
83F0  7C 0C 1F 67 CA    L83F0    FCB   $7C,$0C,$1F,$67,$CA ; +0.0342096381   1/17
83F5  7C DE 53 CB C1    L83F5    FCB   $7C,$DE,$53,$CB,$C1 ; -0.0542791328   1/15
83FA  7D 14 64 70 4C    L83FA    FCB   $7D,$14,$64,$70,$4C ; +0.0724571965   1/13
83FF  7D B7 EA 51 7A    L83FF    FCB   $7D,$B7,$EA,$51,$7A ; -0.0898023954   1/11
8404  7D 63 30 88 7E    L8404    FCB   $7D,$63,$30,$88,$7E ; +0.110932413    1/9
8409  7E 92 44 99 3A    L8409    FCB   $7E,$92,$44,$99,$3A ; -0.142839808    1/7
840E  7E 4C CC 91 C7    L840E    FCB   $7E,$4C,$CC,$91,$C7 ; +0.199999121    1/5
8413  7F AA AA AA 13    L8413    FCB   $7F,$AA,$AA,$AA,$13 ; -0.333333316    1/3
8418  81 00 00 00 00    L8418    FCB   $81,$00,$00,$00,$00 ; +1.000000000    1/1
*
*** TCHEBYSHEV MODIFIED TAYLOR SERIES COEFFICIENTS FOR LN(X)
*
841D  03                L841D    FCB   $03                 ; FOUR COEFFICIENTS
841E  7F 5E 56 CB 79    L841E    FCB   $7F,$5E,$56,$CB,$79 ; 0.434255942  (2/7)*(1/LN(2))
8423  80 13 9B 0B 64    L8423    FCB   $80,$13,$9B,$0B,$64 ; 0.576584541  (2/5)*(1/LN(2))
8428  80 76 38 93 16    L8428    FCB   $80,$76,$38,$93,$16 ; 0.961800759  (2/3)*(1/LN(2))
842D  82 38 AA 3B 20    L842D    FCB   $82,$38,$AA,$3B,$20 ; 2.88539007   (2/1)*(1/LN(2))

8432  80 35 04 F3 34    L8432    FCB   $80,$35,$04,$F3,$34 ; 1/SQR(2)

8437  81 35 04 F3 34    L8437    FCB   $81,$35,$04,$F3,$34 ; SQR(2)

843C  80 80 00 00 00    L843C    FCB   $80,$80,$00,$00,$00 ; -.5

8441  80 31 72 17 F8    L8441    FCB   $80,$31,$72,$17,$F8 ; LN(2)
*
* LOG - NATURAL LOGARITHM (LN)

* THE NATURAL OR NAPERIAN LOGARITHM IS CALCULATED USING
* MATHEMATICAL IDENTITIES. FPA0 IS OF THE FORM FPA0=A*(2**B) (SCIENTIFIC
* NOTATION). THEREFORE, THE LOG ROUTINE DETERMINES THE VALUE OF
* LN(A*(2**B)). A SERIES OF MATHEMATICAL IDENTITIES WILL EXPAND THIS
* TERM: LN(A*(2**B))=(-1/2+(1/LN(2))*(LN(A*SQR(2)))+B)*LN(2). ALL OF
* THE TERMS OF THE LATTER EXPRESSION ARE CONSTANTS EXCEPT FOR THE
* LN(A*SQR(2)) TERM WHICH IS EVALUATED USING THE TAYLOR SERIES EXPANSION
8446  BD BC 6D          LOG      JSR   LBC6D               ; CHECK STATUS OF FPA0
8449  10 2F 2F FD                LBLE  LB44A               ; 'FC' ERROR IF NEGATIVE OR ZERO
844D  8E 84 32                   LDX   #L8432              ; POINT (X) TO FP NUMBER (1/SQR(2))
8450  96 4F                      LDA   FP0EXP              ; *GET EXPONENT OF ARGUMENT
8452  80 80                      SUBA  #$80                ; *SUBTRACT OFF THE BIAS AND
8454  34 02                      PSHS  A                   ; *SAVE IT ON THE STACK
8456  86 80                      LDA   #$80                ; =FORCE EXPONENT OF FPA0
8458  97 4F                      STA   FP0EXP              ; =TO BE ZERO
845A  BD B9 C2                   JSR   LB9C2               ; ADD FPA0 TO (X)
845D  8E 84 37                   LDX   #L8437              ; POINT X TO SQR(2)
8460  BD BB 8F                   JSR   LBB8F               ; DIVIDE SQR(2) BY FPA0
8463  8E BA C5                   LDX   #LBAC5              ; POINT X TO FP VALUE OF 1.00
8466  BD B9 B9                   JSR   LB9B9               ; SUBTRACT FPA0 FROM (X)
* NOW FPA0 = (1-SQR(2)*X)/(1+SQR(2)*X) WHERE X IS ARGUMENT
8469  8E 84 1D                   LDX   #L841D              ; POINT X TO TABLE OF COEFFICIENTS
846C  BD BE F0                   JSR   LBEF0               ; EXPAND POLYNOMIAL
846F  8E 84 3C                   LDX   #L843C              ; POINT X TO FP VALUE OF (-.5)
8472  BD B9 C2                   JSR   LB9C2               ; ADD FPA0 TO X
8475  35 04                      PULS  B                   ; GET EXPONENT OF ARGUMENT BACK (WITHOUT BIAS)
8477  BD BD 99                   JSR   LBD99               ; ADD ACCB TO FPA0
847A  8E 84 41                   LDX   #L8441              ; POINT X TO LN(2)
847D  7E BA CA                   JMP   LBACA               ; MULTIPLY FPA0 * LN(2)
