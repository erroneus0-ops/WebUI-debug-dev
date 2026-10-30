; Extended Color BASIC 1.1 -- $8480-$8532
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: SQR=$8480, EXP=$84F2, FIX=$8524

* SQR
8480  BD BC 5F          SQR      JSR   LBC5F               ; MOVE FPA0 TO FPA1
8483  8E BE C0                   LDX   #LBEC0              ; POINT (X) TO FP NUMBER (.5)
8486  BD BC 14                   JSR   LBC14               ; COPY A PACKED NUMBER FROM (X) TO FPA0

* ARITHMETIC OPERATOR FOR EXPONENTIATION JUMPS
* HERE. THE FORMULA USED TO EVALUATE EXPONENTIATION
* IS A**X=E**(X LN A) = E**(FPA0*LN(FPA1)), E=2.7182818
8489  27 67             L8489    BEQ   EXP                 ; DO A NATURAL EXPONENTIATION IF EXPONENT = 0
848B  4D                         TSTA                      ; *CHECK VALUE BEING EXPONENTIATED
848C  26 03                      BNE   L8491               ; *AND BRANCH IF IT IS <> 0
848E  7E BA 3A                   JMP   LBA3A               ; FPA0=0 IF RAISING ZERO TO A POWER
8491  8E 00 4A          L8491    LDX   #V4A                ; * PACK FPA0 AND SAVE
8494  BD BC 35                   JSR   LBC35               ; * IT IN FPA5 (ARGUMENT'S EXPONENT)
8497  5F                         CLRB                      ; ACCB=DEFAULT RESULT SIGN FLAG; 0=POSITIVE
8498  96 61                      LDA   FP1SGN              ; *CHECK THE SIGN OF ARGUMENT
849A  2A 10                      BPL   L84AC               ; *BRANCH IF POSITIVE
849C  BD BC EE                   JSR   INT                 ; CONVERT EXPONENT INTO AN INTEGER
849F  8E 00 4A                   LDX   #V4A                ; POINT X TO FPA5 (ORIGINAL EXPONENT)
84A2  96 61                      LDA   FP1SGN              ; GET MANTISSA SIGN OF FPA1 (ARGUMENT)
84A4  BD BC A0                   JSR   LBCA0               ; *COMPARE FPA0 TO (X) AND
84A7  26 03                      BNE   L84AC               ; *BRANCH IF NOT EQUAL
84A9  43                         COMA                      ; TOGGLE FPA1 MANTISSA SIGN - FORCE POSITIVE
84AA  D6 01                      LDB   CHARAC              ; GET LS BYTE OF INTEGER VALUE OF EXPONENT (RESULT SIGN FLAG)
84AC  BD BC 4C          L84AC    JSR   LBC4C               ; COPY FPA1 TO FPA0; ACCA = MANTISSA SIGN
84AF  34 04                      PSHS  B                   ; PUT RESULT SIGN FLAG ON THE STACK
84B1  BD 84 46                   JSR   >LOG                ; GET NATURAL LOGARITHM OF FPA0
84B4  8E 00 4A                   LDX   #V4A                ; POINT (X) TO FPA5
84B7  BD BA CA                   JSR   LBACA               ; MULTIPLY FPA0 BY FPA5
84BA  8D 36                      BSR   EXP                 ; CALCULATE E**(FPA0)
84BC  35 02                      PULS  A                   ; * GET RESULT SIGN FLAG FROM THE STACK
84BE  46                         RORA                      ; * AND BRANCH IF NEGATIVE
84BF  10 25 3A 26                LBCS  LBEE9               ; CHANGE SIGN OF FPA0 MANTISSA
84C3  39                         RTS

* CORRECTION FACTOR FOR EXPONENTIAL FUNCTION
84C4  81 38 AA 3B 29    L84C4    FCB   $81,$38,$AA,$3B,$29 ; 1.44269504 ( CF )
*
* TCHEBYSHEV MODIFIED TAYLOR SERIES COEFFICIENTS FOR E**X
*
84C9  07                L84C9    FCB   $07                 ; EIGHT COEFFICIENTS
84CA  71 34 58 3E 56    L84CA    FCB   $71,$34,$58,$3E,$56 ; 2.14987637E-05: 1/(7!*(CF**7))
84CF  74 16 7E B3 1B    L84CF    FCB   $74,$16,$7E,$B3,$1B ; 1.4352314E-04 : 1/(6!*(CF**6))
84D4  77 2F EE E3 85    L84D4    FCB   $77,$2F,$EE,$E3,$85 ; 1.34226348E-03: 1/(5!*(CF**5))
84D9  7A 1D 84 1C 2A    L84D9    FCB   $7A,$1D,$84,$1C,$2A ; 9.61401701E-03: 1/(4!*(CF**4))
84DE  7C 63 59 58 0A    L84DE    FCB   $7C,$63,$59,$58,$0A ; 0.0555051269  : 1/(3!*(CF**3))
84E3  7E 75 FD E7 C6    L84E3    FCB   $7E,$75,$FD,$E7,$C6 ; 0.240226385   : 1/(2!*(CF**2))
84E8  80 31 72 18 10    L84E8    FCB   $80,$31,$72,$18,$10 ; 0.693147186   : 1/(1!*(CF**1))
84ED  81 00 00 00 00    L84ED    FCB   $81,$00,$00,$00,$00 ; 1.
*
* EXP ( E**X)
* THE EXPONENTIAL FUNCTION IS EVALUATED BY FIRST MULTIPLYING THE
* ARGUMENT BY A CORRECTION FACTOR (CF). AFTER THIS IS DONE, AN
* ARGUMENT >= 127 WILL YIELD A ZERO RESULT (NO UNDERFLOW) FOR A
* NEGATIVE ARGUMENT OR AN 'OV' (OVERFLOW) ERROR FOR A POSITIVE
* ARGUMENT. THE POLYNOMIAL COEFFICIENTS ARE MODIFIED TO REFLECT
* THE CF MULTIPLICATION AT THE START OF THE EVALUATION PROCESS.

84F2  8E 84 C4          EXP      LDX   #L84C4              ; POINT X TO THE CORRECTION FACTOR
84F5  BD BA CA                   JSR   LBACA               ; MULTIPLY FPA0 BY (X)
84F8  BD BC 2F                   JSR   LBC2F               ; PACK FPA0 AND STORE IT IN FPA3
84FB  96 4F                      LDA   FP0EXP              ; *GET EXPONENT OF FPA0 AND
84FD  81 88                      CMPA  #$88                ; *COMPARE TO THE MAXIMUM VALUE
84FF  25 03                      BLO   L8504               ; BRANCH IF FPA0 < 128
8501  7E BB 5C          L8501    JMP   LBB5C               ; SET FPA0 = 0 OR 'OV' ERROR
8504  BD BC EE          L8504    JSR   INT                 ; CONVERT FPA0 TO INTEGER
8507  96 01                      LDA   CHARAC              ; GET LS BYTE OF INTEGER
8509  8B 81                      ADDA  #$81                ; * WAS THE ARGUMENT =127, IF SO
850B  27 F4                      BEQ   L8501               ; * THEN 'OV' ERROR; THIS WILL ALSO ADD THE $80 BIAS
* * REQUIRED WHEN THE NEW EXPONENT IS CALCULATED BELOW
850D  4A                         DECA                      ; DECREMENT ONE FROM THE EXPONENT, BECAUSE $81, NOT $80 WAS USED ABOVE
850E  34 02                      PSHS  A                   ; SAVE EXPONENT OF INTEGER PORTION ON STACK
8510  8E 00 40                   LDX   #V40                ; POINT (X) TO FPA3
8513  BD B9 B9                   JSR   LB9B9               ; SUBTRACT FPA0 FROM (X) - GET FRACTIONAL PART OF ARGUMENT
8516  8E 84 C9                   LDX   #L84C9              ; POINT X TO COEFFICIENTS
8519  BD BE FF                   JSR   LBEFF               ; EVALUATE POLYNOMIAL FOR FRACTIONAL PART
851C  0F 62                      CLR   RESSGN              ; FORCE THE MANTISSA TO BE POSITIVE
851E  35 02                      PULS  A                   ; GET INTEGER EXPONENT FROM STACK
8520  BD BB 48                   JSR   LBB48               ; * CALCULATE EXPONENT OF NEW FPA0 BY ADDING THE EXPONENTS OF THE
* * INTEGER AND FRACTIONAL PARTS
8523  39                         RTS

* FIX
8524  BD BC 6D          FIX      JSR   LBC6D               ; CHECK STATUS OF FPA0
8527  2B 03                      BMI   L852C               ; BRANCH IF FPA0 = NEGATIVE
8529  7E BC EE          L8529    JMP   INT                 ; CONVERT FPA0 TO INTEGER
852C  03 54             L852C    COM   FP0SGN              ; TOGGLE SIGN OF FPA0 MANTISSA
852E  8D F9                      BSR   L8529               ; CONVERT FPA0 TO INTEGER
8530  7E BE E9                   JMP   LBEE9               ; TOGGLE SIGN OF FPA0
