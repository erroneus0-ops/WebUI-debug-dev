; Extended Color BASIC 1.1 -- $9023-$91D7
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: (none -- local labels only)

9023  96 4F             L9023    LDA   FP0EXP              ; = GET EXPONENT OF FPA0
9025  97 47                      STA   V47                 ; = AND SAVE IT IN V47
9027  27 03                      BEQ   L902C               ; BRANCH IF FPA0 = 0
9029  BD 91 CD                   JSR   L91CD               ; CONVERT FPA0 TO NUMBER WITH 9 SIGNIFICANT
* PLACES TO LEFT OF DECIMAL POINT
902C  96 47             L902C    LDA   V47                 ; GET BASE 10 EXPONENT OFFSET
902E  10 2B 00 81                LBMI  L90B3               ; BRANCH IF FPA0 < 100,000,000
9032  40                         NEGA                      ; * CALCULATE THE NUMBER OF LEADING ZEROES TO INSERT -
9033  9B D9                      ADDA  VD9                 ; * SUBTRACT BASE 10 EXPONENT OFFSET AND 9 (FPA0 HAS
9035  80 09                      SUBA  #$09                ; * 9 PLACES TO LEFT OF EXPONENT) FROM LEFT DIGIT COUNTER
9037  BD 90 EA                   JSR   L90EA               ; PUT ACCA ZEROES IN STRING BUFFER
903A  BD 92 63                   JSR   L9263               ; INITIALIZE DECIMAL POINT AND COMMA COUNTERS
903D  BD 92 02                   JSR   L9202               ; CONVERT FPA0 TO DECIMAL ASCII IN THE STRING BUFFER
9040  96 47                      LDA   V47                 ; * GET BASE 10 EXPONENT AND PUT THAT MANY
9042  BD 92 81                   JSR   L9281               ; * ZEROES IN STRING BUFFER - STOP AT DECIMAL POINT
9045  96 47                      LDA   V47                 ; WASTED INSTRUCTION - SERVES NO PURPOSE
9047  BD 92 49                   JSR   L9249               ; CHECK FOR DECIMAL POINT
904A  96 D8                      LDA   VD8                 ; GET THE RIGHT DIGIT COUNTER
904C  26 02                      BNE   L9050               ; BRANCH IF RIGHT DIGlT COUNTER <> 0
904E  33 5F                      LEAU  $-01,U              ; * MOVE BUFFER POINTER BACK ONE - DELETE
* * DECIMAL POINT IF NO RIGHT DIGITS SPECiFIED
9050  4A                L9050    DECA                      ; SUBTRACT ONE (DECIMAL POINT)
9051  BD 90 EA                   JSR   L90EA               ; PUT ACCA ZEROES INTO BUFFER (TRAILING ZEROES)
9054  BD 91 85          L9054    JSR   L9185               ; INSERT ASTERISK PADDING, FLOATING $, AND POST-SIGN
9057  4D                         TSTA                      ; WAS THERE A POST-SIGN?
9058  27 06                      BEQ   L9060               ; NO
905A  C1 2A                      CMPB  #'*'                ; IS THE FIRST CHARACTER AN $?
905C  27 02                      BEQ   L9060               ; YES
905E  E7 C0                      STB   ,U+                 ; STORE THE POST-SIGN
9060  6F C4             L9060    CLR   ,U                  ; CLEAR THE LAST CHARACTER IN THE BUFFER
*
* REMOVE ANY EXTRA BLANKS OR ASTERISKS FROM THE
* STRING BUFFER TO THE LEFT OF THE DECIMAL POINT
9062  8E 03 DA                   LDX   #STRBUF+3           ; POINT X TO THE START OF THE BUFFER
9065  30 01             L9065    LEAX  $01,X               ; MOVE BUFFER POINTER UP ONE
9067  9F 0F                      STX   TEMPTR              ; SAVE BUFFER POINTER IN TEMPTR
9069  96 3A                      LDA   VARPTR+1            ; * GET ADDRESS OF DECIMAL POINT IN BUFFER, SUBTRACT
906B  90 10                      SUBA  TEMPTR+1            ; * CURRENT POSITION AND SUBTRACT LEFT DIGIT COUNTER -
906D  90 D9                      SUBA  VD9                 ; * THE RESULT WILL BE ZERO WHEN TEMPTR+1 IS POINTING
; * TO THE FIRST DIGIT OF THE FORMAT STRING
906F  27 38                      BEQ   L90A9               ; RETURN IF NO DIGITS TO LEFT OF THE DECiMAL POINT
9071  A6 84                      LDA   ,X                  ; GET THE CURRENT BUFFER CHARACTER
9073  81 20                      CMPA  #SPACE              ; SPACE?
9075  27 EE                      BEQ   L9065               ; YES - ADVANCE POINTER
9077  81 2A                      CMPA  #'*'                ; ASTERISK?
9079  27 EA                      BEQ   L9065               ; YES - ADVANCE POINTER
907B  4F                         CLRA                      ; A ZERO ON THE STACK IS END OF DATA POINTER
907C  34 02             L907C    PSHS  A                   ; PUSH A CHARACTER ONTO THE STACK
907E  A6 80                      LDA   ,X+                 ; GET NEXT CHARACTER FROM BUFFER
9080  81 2D                      CMPA  #'-'                ; MINUS SIGN?
9082  27 F8                      BEQ   L907C               ; YES
9084  81 2B                      CMPA  #'+'                ; PLUS SIGN?
9086  27 F4                      BEQ   L907C               ; YES
9088  81 24                      CMPA  $'$'                ; DOLLAR SIGN?
908A  27 F0                      BEQ   L907C               ; YES
908C  81 30                      CMPA  #'0'                ; ZERO?
908E  26 0E                      BNE   L909E               ; NO - ERROR
9090  A6 01                      LDA   $01,X               ; GET CHARACTER FOLLOWING ZERO
9092  8D 16                      BSR   L90AA               ; CLEAR CARRY IF NUMERIC
9094  25 08                      BLO   L909E               ; BRANCH IF NOT A NUMERIC CHARACTER - ERROR
9096  35 02             L9096    PULS  A                   ; * PULL A CHARACTER OFF OF THE STACK
9098  A7 82                      STA   ,-X                 ; * AND PUT IT BACK IN THE STRING BUFFER
909A  26 FA                      BNE   L9096               ; * KEEP GOING UNTIL ZERO FLAG
909C  20 C7                      BRA   L9065               ; KEEP CLEANING UP THE INPUT BUFFER
909E  35 02             L909E    PULS  A                   ; = REMOVE THE CHARACTERS ON
90A0  4D                         TSTA                      ; = THE STACK AND EXIT WHEN
90A1  26 FB                      BNE   L909E               ; = ZERO FLAG FOUND
90A3  9E 0F                      LDX   TEMPTR              ; GET THE STRING BUFFER START POINTER
90A5  86 25                      LDA   #'%'                ; * PUT A % SIGN BEFORE THE ERROR POSITION TO
90A7  A7 82                      STA   ,-X                 ; * INDICATE AN ERROR
90A9  39                L90A9    RTS
*
* CLEAR CARRY IF NUMERIC
90AA  81 30             L90AA    CMPA  #'0'                ; ASCII ZERO
90AC  25 04                      BLO   L90B2               ; RETURN IF ACCA < ASCII 0
90AE  80 3A                      SUBA  #'9'+1              ; *
90B0  80 C6                      SUBA  #-('9'+1)           ; *CARRY CLEAR IF NUMERIC
90B2  39                L90B2    RTS
*
* PROCESS AN ITEM-LIST WHICH IS < 100,000,000
90B3  96 D8             L90B3    LDA   VD8                 ; GET RIGHT DIGIT COUNTER
90B5  27 01                      BEQ   L90B8               ; BRANCH IF NO FORMATTED DIGITS TO THE RIGHT OF DECIMAL PT
90B7  4A                         DECA                      ; SUBTRACT ONE FOR DECIMAL POINT
90B8  9B 47             L90B8    ADDA  V47                 ; *ADD THE BASE 10 EXPONENT OFFSET - ACCA CONTAINS THE
* *NUMBER OF SHIFTS REQUIRED TO ADJUST FPA0 TO THE SPECIFIED
* *NUMBER OF DlGITS TO THE RIGHT OF THE DECIMAL POINT
90BA  2B 01                      BMI   L90BD               ; IF ACCA >= 0 THEN NO SHIFTS ARE REQUIRED
90BC  4F                         CLRA                      ; FORCE SHIFT COUNTER = 0
90BD  34 02             L90BD    PSHS  A                   ; SAVE INITIAL SHIFT COUNTER ON THE STACK
90BF  2A 0A             L90BF    BPL   L90CB               ; EXIT ROUTINE IF POSITIVE
90C1  34 02                      PSHS  A                   ; SAVE SHIFT COUNTER ON STACK
90C3  BD BB 82                   JSR   LBB82               ; DIVIDE FPA0 BY 10 - SHIFT ONE DIGIT TO RIGHT
90C6  35 02                      PULS  A                   ; GET SHIFT COUNTER FROM THE STACK
90C8  4C                         INCA                      ; BUMP SHIFT COUNTER UP BY ONE
90C9  20 F4                      BRA   L90BF               ; CHECK FOR FURTHER DIVISION
90CB  96 47             L90CB    LDA   V47                 ; * GET BASE 10 EXPONENT OFFSET, ADD INITIAL SHIFT COUNTER
90CD  A0 E0                      SUBA  ,S+                 ; * AND SAVE NEW BASE 10 EXPONENT OFFSET - BECAUSE
90CF  97 47                      STA   V47                 ; * FPA0 WAS SHIFTED ABOVE
90D1  8B 09                      ADDA  #$09                ; =ADD NINE (SIGNIFICANT PLACES) AND BRANCH IF THERE ARE NO
90D3  2B 19                      BMI   L90EE               ; =ZEROES TO THE LEFT OF THE DECIMAL POINT IN THIS PRINT ITEM
90D5  96 D9                      LDA   VD9                 ; *DETERMINE HOW MANY FILLER ZEROES TO THE LEFT OF THE DECIMAL
90D7  80 09                      SUBA  #$09                ; *POINT. GET THE NUMBER OF FORMAT PLACES TO LEFT OF DECIMAL
90D9  90 47                      SUBA  V47                 ; *POINT, SUBTRACT THE BASE 10 EXPONENT OFFSET AND THE CONSTANT 9
90DB  8D 0D                      BSR   L90EA               ; *(UNNORMALIZATION)-THEN OUTPUT THAT MANY ZEROES TO THE BUFFER
90DD  BD 92 63                   JSR   L9263               ; INITIALIZE DECIMAL POINT AND COMMA COUNTERS
90E0  20 1D                      BRA   L90FF               ; PROCESS THE REMAINDER OF THE PRINT ITEM
*
* PUT (ACCA+1) ASCII ZEROES IN BUFFER
90E2  34 02             L90E2    PSHS  A                   ; SAVE ZERO COUNTER
90E4  86 30                      LDA   #'0'                ; * INSERT A ZERO INTO
90E6  A7 C0                      STA   ,U+                 ; * THE BUFFER
90E8  35 02                      PULS  A                   ; RESTORE ZERO COUNTER

* PUT ACCA ASCII ZEROES INTO THE BUFFER
90EA  4A                L90EA    DECA                      ; DECREMENT ZERO COUNTER
90EB  2A F5                      BPL   L90E2               ; BRANCH IF NOT DONE
90ED  39                         RTS

90EE  96 D9             L90EE    LDA   VD9                 ; * GET THE LEFT DIGIT COUNTER AND PUT
90F0  8D F8                      BSR   L90EA               ; * THAT MANY ZEROES IN THE STRiNG BUFFER
90F2  BD 92 4D                   JSR   L924D               ; PUT THE DECIMAL POINT IN THE STRING BUFFER
90F5  86 F7                      LDA   #-9                 ; *DETERMINE HOW MANY FILLER ZEROES BETWEEN THE DECIMAL POINT
90F7  90 47                      SUBA  V47                 ; *AND SIGNIFICANT DATA. SUBTRACT BASE 10 EXPONENT FROM -9
90F9  8D EF                      BSR   L90EA               ; *(UNNORMALIZATION) AND OUTPUT THAT MANY ZEROES TO BUFFER
90FB  0F 45                      CLR   V45                 ; CLEAR THE DECIMAL POINT COUNTER - SUPPRESS THE DECIMAL POINT
90FD  0F D7                      CLR   VD7                 ; CLEAR THE COMMA COUNTER - SUPPRESS COMMAS
90FF  BD 92 02          L90FF    JSR   L9202               ; DECODE FPA0 INTO A DECIMAL ASCII STRING
9102  96 D8                      LDA   VD8                 ; GET THE RIGHT DIGIT COUNTER
9104  26 02                      BNE   L9108               ; BRANCH IF RIGHT DIGIT COUNTER <> 0
9106  DE 39                      LDU   VARPTR              ; RESET BUFFER PTR TO THE DECIMAL POINT IF NO DIGITS TO RIGHT
9108  9B 47             L9108    ADDA  V47                 ; *ADD BASE 10 EXPONENT - A POSITIVE ACCA WILL CAUSE THAT MANY
* *FILLER ZEROES TO BE OUTPUT TO THE RIGHT OF LAST SIGNIFICANT DATA
* *SIGNIFICANT DATA
910A  16 FF 43                   LBRA  L9050               ; INSERT LEADING ASTERISKS, FLOATING DOLLAR SIGN, ETC
*
* FORCE THE NUMERIC OUTPUT FORMAT TO BE EXPONENTIAL FORMAT
910D  96 4F             L910D    LDA   FP0EXP              ; * GET EXPONENT OF FPA0 AND
910F  34 02                      PSHS  A                   ; * SAVE IT ON THE STACK
9111  27 03                      BEQ   L9116               ; BRANCH IF FPA0 = 0
9113  BD 91 CD                   JSR   L91CD               ; *CONVERT FPA0 INTO A NUMBER WITH 9 SIGNIFICANT
* *DIGITS TO THE LEFT OF THE DECIMAL POINT
9116  96 D8             L9116    LDA   VD8                 ; GET THE RIGHT DIGIT COUNTER
9118  27 01                      BEQ   L911B               ; BRANCH IF NO FORMATTED DIGITS TO THE RIGHT
911A  4A                         DECA                      ; SUBTRACT ONE FOR THE DECIMAL POINT
911B  9B D9             L911B    ADDA  VD9                 ; ADD TO THE LEFT DIGIT COUNTER
911D  7F 03 DA                   CLR   STRBUF+3            ; CLEAR BUFFER BYTE AS TEMPORARY STORAGE LOCATION
9120  D6 DA                      LDB   VDA                 ; * GET THE STATUS BYTE FOR A
9122  C4 04                      ANDB  #$04                ; * POST-BYTE FORCE; BRANCH IF
9124  26 03                      BNE   L9129               ; * A POST-BYTE FORCE
9126  73 03 DA                   COM   STRBUF+3            ; TOGGLE BUFFER BYTE TO -1 IF NO POST-BYTE FORCE
9129  BB 03 DA          L9129    ADDA  STRBUF+3            ; SUBTRACT 1 IF NO POST BYTE FORCE
912C  80 09                      SUBA  #$09                ; *SUBTRACT 9 (DUE TO THE CONVERSION TO 9
* *SIGNIFICANT DIGITS TO LEFT OF DECIMAL POINT)
912E  34 02                      PSHS  A                   ; =SAVE SHIFT COUNTER ON THE STACK - ACCA CONTAINS THE NUMBER
* =OF SHIFTS REQUIRED TO ADJUST FPA0 FOR THE NUMBER OF
* =FORMATTED PLACES TO THE RIGHT OF THE DECIMAL POINT.
9130  2A 0A             L9130    BPL   L913C               ; NO MORE SHIFTS WHEN ACCA >= 0
9132  34 02                      PSHS  A                   ; SAVE SHIFT COUNTER
9134  BD BB 82                   JSR   LBB82               ; DIVIDE FPA0 BY 10 - SHIFT TO RIGHT ONE
9137  35 02                      PULS  A                   ; RESTORE THE SHIFT COUNTER
9139  4C                         INCA                      ; ADD 1 TO SHIFT COUNTER
913A  20 F4                      BRA   L9130               ; CHECK FOR FURTHER SHIFTING (DIVISION)
913C  A6 E4             L913C    LDA   ,S                  ; *GET THE INITIAL VALUE OF THE SHIFT COUNTER
913E  2B 01                      BMI   L9141               ; *AND BRANCH IF SHIFTING HAS TAKEN PLACE
9140  4F                         CLRA                      ; RESET ACCA IF NO SHIFTING HAS TAKEN PLACE
9141  40                L9141    NEGA                      ; *CALCULATE THE POSITION OF THE DECIMAL POINT BY
9142  9B D9                      ADDA  VD9                 ; *NEGATING SHIFT COUNTER, ADDING THE LEFT DIGIT COUNTER
9144  4C                         INCA                      ; *PLUS ONE AND THE POST-BYTE POSlTION, IF USED
9145  BB 03 DA                   ADDA  STRBUF+3            ; *
9148  97 45                      STA   V45                 ; SAVE DECIMAL POINT COUNTER
914A  0F D7                      CLR   VD7                 ; CLEAR COMMA COUNTER - NO COMMAS INSERTED
914C  BD 92 02                   JSR   L9202               ; CONVERT FPA0 INTO ASCII DECIMAL STRING
914F  35 02                      PULS  A                   ; =GET THE INITIAL VALUE OF SHIFT COUNTER AND
9151  BD 92 81                   JSR   L9281               ; =INSERT THAT MANY ZEROES INTO THE BUFFER
9154  96 D8                      LDA   VD8                 ; *GET THE RIGHT DIGIT COUNTER AND BRANCH
9156  26 02                      BNE   L915A               ; *IF NOT ZERO
9158  33 5F                      LEAU  $-01,U              ; MOVE BUFFER POINTER BACK ONE

* CALCULATE VALUE OF EXPONENT AND PUT IN STRING BUFFER
915A  E6 E0             L915A    LDB   ,S+                 ; GET ORIGINAL EXPONENT OF FPA0
915C  27 09                      BEQ   L9167               ; BRANCH IF EXPONENT = 0
915E  D6 47                      LDB   V47                 ; GET BASE 10 EXPONENT
9160  CB 09                      ADDB  #$09                ; ADD 9 FOR 9 SIGNIFICANT DIGIT CONVERSION
9162  D0 D9                      SUBB  VD9                 ; SUBTRACT LEFT DIGIT COUNTER
9164  F0 03 DA                   SUBB  STRBUF+3            ; ADD ONE TO EXPONENT IF POST-SIGN FORCE
9167  86 2B             L9167    LDA   #'+'                ; PLUS SIGN
9169  5D                         TSTB                      ; TEST EXPONENT
916A  2A 03                      BPL   L916F               ; BRANCH IF POSITIVE EXPONENT
916C  86 2D                      LDA   #'-'                ; MINUS SIGN
916E  50                         NEGB                      ; CONVERT EXPONENT TO POSITIVE NUMBER
916F  A7 41             L916F    STA   $01,U               ; PUT SIGN OF EXPONENT IN STRING BUFFER
9171  86 45                      LDA   #'E'                ; * PUT AN 'E' (EXPONENTIATION FLAG) IN
9173  A7 C1                      STA   ,U++                ; * BUFFER AND SKIP OVER THE SIGN
9175  86 2F                      LDA   #'0'-1              ; INITIALIZE TENS DIGIT TO ASCII ZERO MINUS ONE
*CONVERT BINARY EXPONENT IN ACCB TO ASCII VALUE IN ACCA
9177  4C                L9177    INCA                      ; ADD ONE TO TENS DIGIT COUNTER
9178  C0 0A                      SUBB  #10                 ; *SUBTRACT 10 FROM EXPONENT AND ADD ONE TO TENS
917A  24 FB                      BCC   L9177               ; * DIGIT IF NO CARRY. TENS DIGIT DONE IF THERE IS A CARRY
917C  CB 3A                      ADDB  #'9'+1              ; ADD ASCII BIAS TO UNITS DIGIT
917E  ED C1                      STD   ,U++                ; SAVE EXPONENT IN BUFFER
9180  6F C4                      CLR   ,U                  ; CLEAR FINAL BYTE IN BUFFER - PRINT TERMINATOR
9182  7E 90 54                   JMP   L9054               ; INSERT ASTERISK PADDING, FLOATING DOLLAR SIGN, ETC.

* INSERT ASTERISK PADDING, FLOATING $ AND PRE-SIGN
9185  8E 03 DB          L9185    LDX   #STRBUF+4           ; POINT X TO START OF PRINT ITEM BUFFER
9188  E6 84                      LDB   ,X                  ; * GET SIGN BYTE OF ITEM-LIST BUFFER
918A  34 04                      PSHS  B                   ; * AND SAVE IT ON THE STACK
918C  86 20                      LDA   #SPACE              ; DEFAULT PAD WITH BLANKS
918E  D6 DA                      LDB   VDA                 ; * GET STATUS BYTE AND CHECK FOR
9190  C5 20                      BITB  #$20                ; * ASTERISK LEFT PADDING
9192  35 04                      PULS  B                   ; GET SIGN BYTE AGAIN
9194  27 08                      BEQ   L919E               ; BRANCH IF NO PADDING
9196  86 2A                      LDA   #'*'                ; PAD WITH ASTERISK
9198  C1 20                      CMPB  #SPACE              ; WAS THE FIRST BYTE A BLANK (POSITIVE)?
919A  26 02                      BNE   L919E               ; NO
919C  1F 89                      TFR   A,B                 ; TRANSFER PAD CHARACTER TO ACCB
919E  34 04             L919E    PSHS  B                   ; SAVE FIRST CHARACTER ON STACK
91A0  A7 80             L91A0    STA   ,X+                 ; STORE PAD CHARACTER IN BUFFER
91A2  E6 84                      LDB   ,X                  ; GET NEXT CHARACTER IN BUFFER
91A4  27 10                      BEQ   L91B6               ; INSERT A ZERO IF END OF BUFFER
91A6  C1 45                      CMPB  #'E'                ; * CHECK FOR AN 'E' AND
91A8  27 0C                      BEQ   L91B6               ; * PUT A ZERO BEFORE IT
91AA  C1 30                      CMPB  #'0'                ; = REPLACE LEADING ZEROES WITH
91AC  27 F2                      BEQ   L91A0               ; = PAD CHARACTERS
91AE  C1 2C                      CMPB  #','                ; * REPLACE LEADING COMMAS
91B0  27 EE                      BEQ   L91A0               ; * WITH PAD CHARACTERS
91B2  C1 2E                      CMPB  #'.'                ; = CHECK FOR DECIMAL POINT
91B4  26 04                      BNE   L91BA               ; = AND DON'T PUT A ZERO BEFORE IT
91B6  86 30             L91B6    LDA   #'0'                ; * REPLACE PREVIOUS CHARACTER
91B8  A7 82                      STA   ,-X                 ; * WITH A ZERO
91BA  96 DA             L91BA    LDA   VDA                 ; = GET STATUS BYTE, CHECK
91BC  85 10                      BITA  #$10                ; = FOR FLOATING $
91BE  27 04                      BEQ   L91C4               ; = BRANCH IF NO FLOATING $
91C0  C6 24                      LDB   #'$'                ; * STORE A $ IN
91C2  E7 82                      STB   ,-X                 ; * BUFFER
91C4  84 04             L91C4    ANDA  #$04                ; CHECK PRE-SIGN FLAG
91C6  35 04                      PULS  B                   ; GET SIGN CHARACTER
91C8  26 02                      BNE   L91CC               ; RETURN IF POST-SIGN REQUIRED
91CA  E7 82                      STB   ,-X                 ; STORE FIRST CHARACTER
91CC  39                L91CC    RTS
*
* CONVERT FPA0 INTO A NUMBER OF THE FORM - NNN,NNN,NNN X 10**M.
* THE EXPONENT M WILL BE RETURNED IN V47 (BASE 10 EXPONENT).
91CD  34 40             L91CD    PSHS  U                   ; SAVE BUFFER POINTER
91CF  4F                         CLRA                      ; INITIAL EXPONENT OFFSET = 0
91D0  97 47             L91D0    STA   V47                 ; SAVE EXPONENT OFFSET
91D2  D6 4F                      LDB   FP0EXP              ; GET EXPONENT OF FPA0
91D4  C1 80                      CMPB  #$80                ; * COMPARE TO EXPONENT OF .5
91D6  22 11                      BHI   L91E9               ; * AND BRANCH IF FPA0 > = 1.0
