; Extended Color BASIC 1.1 -- $9A22-$9BAB
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: PLAY=$9A22

* PLAY
9A22  9E 8A             PLAY     LDX   ZERO                ; *DEFAULT VALUES FOR LENGTH OF 'PLAY' COMMAND AND ADDRESS
9A24  C6 01                      LDB   #$01                ; *OF START OF 'PLAY' STRING IF USED FOR PLAY" (NULL STRING)
9A26  34 14                      PSHS  X,B                 ; SAVE DEFAULT VALUES
9A28  BD B1 56                   JSR   LB156               ; EVALUATE EXPRESSION
9A2B  5F                         CLRB                      ; *
9A2C  BD A9 A2                   JSR   LA9A2               ; * SET UP DA TO PASS THROUGH ANA MUX
9A2F  BD A9 76                   JSR   LA976               ; ENABLE ANA MUX
9A32  BD B6 54          L9A32    JSR   LB654               ; *POINT X TO START OF 'PLAY' STRING AND PUT LENGTH
* *OF STRING INTO ACCB
9A35  20 02                      BRA   L9A39               ; INEFFICIENT - SHOULD BE FCB SKP2
9A37  35 14             L9A37    PULS  B,X                 ; GET PLAY STRING START AND LENGTH
9A39  D7 D8             L9A39    STB   VD8                 ; LENGTH OF 'PLAY' COMMAND
9A3B  27 FA                      BEQ   L9A37               ; GET NEW STRING DATA IF LENGTH = 0
9A3D  9F D9                      STX   VD9                 ; START OF 'PLAY' STRING
9A3F  10 27 0F 31                LBEQ  LA974               ; DISABLE ANA MUX AND RETURN IF X = 0
9A43  0D D8             L9A43    TST   VD8                 ; SEE IF LENGTH OF STRING = 0
9A45  27 F0                      BEQ   L9A37               ; GET NEW DATA IF SO
9A47  BD 9B 98                   JSR   L9B98               ; GET A COMMAND CHARACTER IF NOT
9A4A  81 3B                      CMPA  #';'                ; SUB COMMAND TERMINATED
9A4C  27 F5                      BEQ   L9A43               ; IGNORE SEMICOLONS
9A4E  81 27                      CMPA  #'''                ; CHECK FOR APOSTROPHE
9A50  27 F1                      BEQ   L9A43               ; IGNORE THEM TOO
9A52  81 58                      CMPA  #'X'                ; CHECK FOR AN EXECUTABLE SUBSTRING
9A54  10 27 01 B2                LBEQ  L9C0A               ; GO PROCESS SUB COMMAND
9A58  8D 02                      BSR   L9A5C               ; CHECK FOR OTHER COMMANDS
9A5A  20 E7                      BRA   L9A43               ; KEEP GOING THROUGH INTERPRETATION LOOP
* OCTAVE
9A5C  81 4F             L9A5C    CMPA  #'O'                ; ADJUST OCTAVE?
9A5E  26 0D                      BNE   L9A6D               ; NO
9A60  D6 DE                      LDB   OCTAVE              ; GET CURRENT OCTAVE
9A62  5C                         INCB                      ; LEGAL VALUES ARE 1-5 BUT INTERNALLY THE COMPUTER USES 0-4
9A63  8D 5B                      BSR   L9AC0               ; MODIFIER CHECK
9A65  5A                         DECB                      ; COMPENSATE FOR INCB ABOVE
9A66  C1 04                      CMPB  #$04                ; MAXIMUM VALUE OF 4
9A68  22 63                      BHI   L9ACD               ; 'FC' ERROR
9A6A  D7 DE                      STB   OCTAVE              ; SAVE NEW VALUE OF OCTAVE
9A6C  39                         RTS
* VOLUME
9A6D  81 56             L9A6D    CMPA  #'V'                ; ADJUST VOLUME?
9A6F  26 1A                      BNE   L9A8B               ; NO
9A71  D6 DF                      LDB   VOLHI               ; GET CURRENT HIGH VOLUME LIMIT
9A73  54                         LSRB                      ; *SHIFT 2 BITS TO RIGHT; DA IS ONLY 6 BITS (BIT 2 - BIT 7) -
9A74  54                         LSRB                      ; *TO MANIPULATE THE DATA IT MUST BE IN BITS 0-5
9A75  C0 1F                      SUBB  #31                 ; SUBTRACT OUT MID VALUE OFFSET
9A77  8D 47                      BSR   L9AC0               ; MODIFIER CHECK
9A79  C1 1F                      CMPB  #31                 ; MAXIMUM ALLOWED RANGE IS 31
9A7B  22 50                      BHI   L9ACD               ; 'FC' ERROR
9A7D  58                         ASLB                      ; *
9A7E  58                         ASLB                      ; *MOVE NEW VALUE BACK TO BITS 2-7
9A7F  34 04                      PSHS  B                   ; SAVE NEW VOLUME ON THE STACK
9A81  CC 7E 7E                   LDD   #$7E7E              ; PUT MID VALUE IN HIGH AND LOW LIMIT
9A84  AB E4                      ADDA  ,S                  ; ADD NEW VOLUME TO HIGH LIMIT
9A86  E0 E0                      SUBB  ,S+                 ; SUBTR NEW VOLUME FROM LOW LIMIT
9A88  DD DF                      STD   VOLHI               ; SAVE NEW VOLUME LIMITS
9A8A  39                         RTS
* NOTE LENGTH
9A8B  81 4C             L9A8B    CMPA  #'L'                ; SET NOTE LENGTH?
9A8D  26 23                      BNE   L9AB2               ; NO
9A8F  D6 E1                      LDB   NOTELN              ; GET CURRENT LENGTH
9A91  8D 2D                      BSR   L9AC0               ; MODIFIER CHECK
9A93  5D                         TSTB                      ; *
9A94  27 37                      BEQ   L9ACD               ; * 'FC' ERROR IF LENGTH = 0
9A96  D7 E1                      STB   NOTELN              ; SAVE NEW NOTE LENGTH
9A98  0F E5                      CLR   DOTVAL              ; RESET NOTE TIMER SCALE FACTOR
9A9A  8D 03             L9A9A    BSR   L9A9F               ; CHECK FOR A DOTTED NOTE
9A9C  24 FC                      BCC   L9A9A               ; BRANCH IF DOTTED NOTE
9A9E  39                         RTS
* SCALE FACTOR - 'DOTTED NOTE'
9A9F  0D D8             L9A9F    TST   VD8                 ; CHECK COMMAND LENGTH
9AA1  27 0A                      BEQ   L9AAD               ; IT'S EMPTY
9AA3  BD 9B 98                   JSR   L9B98               ; GET COMMAND CHARACTER
9AA6  81 2E                      CMPA  #'.'                ; CHECK FOR DOTTED NOTE
9AA8  27 05                      BEQ   L9AAF               ; BRANCH ON DOTTED NOTE AND CLEAR CARRY FLAG
9AAA  BD 9B E2                   JSR   L9BE2               ; *MOVE COMMAND STRING POINTER BACK ONE AND ADD ONE TO
; *COMMAND LENGTH
9AAD  43                L9AAD    COMA                      ; SET CARRY FLAG
9AAE  39                         RTS
9AAF  0C E5             L9AAF    INC   DOTVAL              ; ADD ONE TO NOTE TIMER SCALE FACTOR
9AB1  39                         RTS
* TEMPO
9AB2  81 54             L9AB2    CMPA  #'T'                ; MODIFY TEMPO?
9AB4  26 0D                      BNE   L9AC3               ; NO
9AB6  D6 E2                      LDB   TEMPO               ; GET CURRENT TEMPO
9AB8  8D 06                      BSR   L9AC0               ; EVALUATE MODIFIER
9ABA  5D                         TSTB                      ; SET FLAGS
9ABB  27 10                      BEQ   L9ACD               ; 'FC' ERROR IF IT'S 0
9ABD  D7 E2                      STB   TEMPO               ; SAVE NEW TEMPO
9ABF  39                         RTS
9AC0  7E 9B AC          L9AC0    JMP   L9BAC               ; EVALUATE THE >,<,+,-,= OPERATORS
* PAUSE
9AC3  81 50             L9AC3    CMPA  #'P'                ; PAUSE COMMAND?
9AC5  26 24                      BNE   L9AEB               ; NO
9AC7  BD 9C CB                   JSR   L9CCB               ; EVALUATE A DECIMAL COMMAND STRING VALUE
9ACA  5D                         TSTB                      ; * CHECK FOR LEGAL EXPRESSION AND
9ACB  26 03                      BNE   L9AD0               ; * BRANCH IF PAUSE VALUE <> 0
9ACD  7E B4 4A          L9ACD    JMP   LB44A               ; 'FC' ERROR IF PAUSE <> 0
9AD0  96 E5             L9AD0    LDA   DOTVAL              ; *SAVE CURRENT VALUE OF VOLUME AND NOTE
9AD2  9E DF                      LDX   VOLHI               ; *TIMER SCALE
9AD4  34 12                      PSHS  X,A                 ; *
9AD6  86 7E                      LDA   #$7E                ; MID VALUE OF DA CONVERTER
9AD8  97 DF                      STA   VOLHI               ; *SET VOLUME = 0
9ADA  97 E0                      STA   VOLLOW              ; *
9ADC  0F E5                      CLR   DOTVAL              ; RESET NOTE TIMER SCALE FACTOR
9ADE  8D 07                      BSR   L9AE7               ; GO 'PLAY' A NOTE OF 0 VOLUME
9AE0  35 12                      PULS  A,X                 ; *
9AE2  97 E5                      STA   DOTVAL              ; *RESTORE VALUE OF VOLUME
9AE4  9F DF                      STX   VOLHI               ; *AND NOTE TIMER SCALE
9AE6  39                         RTS
9AE7  6F E2             L9AE7    CLR   ,-S                 ; PUSH NOTE NUMBER 0 ONTO STACK
9AE9  20 40                      BRA   L9B2B               ; GO PLAY IT
* NOTE
9AEB  81 4E             L9AEB    CMPA  #'N'                ; LETTER N BEFORE THE NUMBER OF A NOTE?
9AED  26 03                      BNE   L9AF2               ; NO - IT'S OPTIONAL
9AEF  BD 9B 98                   JSR   L9B98               ; GET NEXT COMMAND CHARACTER
9AF2  81 41             L9AF2    CMPA  #'A'                ; CHECK FOR NOTE A
9AF4  25 04                      BLO   L9AFA               ; BELOW
9AF6  81 47                      CMPA  #'G'                ; CHECK FOR NOTE B
9AF8  23 05                      BLS   L9AFF               ; FOUND NOTE A-G
9AFA  BD 9B BE          L9AFA    JSR   L9BBE               ; EVALUATE DECIMAL NUMERIC EXPRESSION IN COMMAND STRING
9AFD  20 23                      BRA   L9B22               ; PROCESS NOTE VALUE
* PROCESS A NOTE HERE
9AFF  80 41             L9AFF    SUBA  #'A'                ; MASK OFF ASCII
9B01  8E 9C 5B                   LDX   #L9C5B              ; LOAD X WITH NOTE JUMP TABLE
9B04  E6 86                      LDB   A,X                 ; GET NOTE
9B06  0D D8                      TST   VD8                 ; ANY COMMAND CHARACTERS LEFT?
9B08  27 18                      BEQ   L9B22               ; NO
9B0A  BD 9B 98                   JSR   L9B98               ; GET COMMAND CHARACTER
9B0D  81 23                      CMPA  #'#'                ; 'SHARP' NOTE?
9B0F  27 04                      BEQ   L9B15               ; YES
9B11  81 2B                      CMPA  #'+'                ; 'SHARP' NOTE?
9B13  26 03                      BNE   L9B18               ; NO
9B15  5C                L9B15    INCB                      ; ADD 1 TO NOTE NUMBER (SHARP)
9B16  20 0A                      BRA   L9B22               ; PROCESS NOTE
9B18  81 2D             L9B18    CMPA  #'-'                ; 'FLAT' NOTE?
9B1A  26 03                      BNE   L9B1F               ; NO
9B1C  5A                         DECB                      ; SUBTR 1 FROM NOTE NUMBER (FLAT)
9B1D  20 03                      BRA   L9B22               ; PROCESS NOTE
9B1F  BD 9B E2          L9B1F    JSR   L9BE2               ; *MOVE COMMAND STRING PTR BACK ONE AND ADD ONE
* *TO COMMAND LENGTH CTR
9B22  5A                L9B22    DECB                      ; =ADJUST NOTE NUMBER, BASIC USES NOTE NUMBERS 1-12, INTERNALLY
* =COMPUTER USES 0-11
9B23  C1 0B                      CMPB  #12-1               ; MAXIMUM NOTE VALUE
9B25  22 A6                      BHI   L9ACD               ; 'FC' ERROR IF > 11
9B27  34 04                      PSHS  B                   ; SAVE NOTE VALUE
9B29  D6 E1                      LDB   NOTELN              ; GET NOTE LENGTH
9B2B  96 E2             L9B2B    LDA   TEMPO               ; GET TEMPO
9B2D  3D                         MUL                       ; CALCULATE NOTE DURATION
9B2E  DD D5                      STD   VD5                 ; SAVE NOTE DURATION
* THE IRQ INTERRUPT IS USED TO PROVIDE A MASTER TIMING REFERENCE FOR
* THE 'PLAY' COMMAND.  WHEN A NOTE IS DONE, THE IRQ SERVICING
* ROUTINE WILL RETURN CONTROL TO THE MAIN 'PLAY' COMMAND INTERPRETATION LOOP
9B30  33 61                      LEAU  $01,S               ; *LOAD U W/CURRENT VALUE OF (STACK POINTER+1) SO THAT THE STACK
* *POINTER WILL BE PROPERLY RESET WHEN IRQ VECTORS
* *YOU OUT OF THE 'PLAY' TIMING ROUTINES BELOW
9B32  96 DE                      LDA   OCTAVE              ; GET CURRENT OCTAVE
9B34  81 01                      CMPA  #$01                ; *
9B36  22 2C                      BHI   L9B64               ; * BRANCH IF OCTAVE > 1
* OCTAVES 1 AND 2 USE A TWO BYTE DELAY TO SET THE PROPER FREQUENCY
9B38  8E 9C 62                   LDX   #L9C62              ; POINT TO DELAY TABLE
9B3B  C6 18                      LDB   #2*12               ; 24 BYTES DATA/OCTAVE
9B3D  3D                         MUL                       ; CALC OCTAVE TABLE OFFSET
9B3E  3A                         ABX                       ; POINT TO CORRECT OCTAVE TABLE
9B3F  35 04                      PULS  B                   ; GET NOTE VALUE BACK
9B41  58                         ASLB                      ; X 2 - 2 BYTES/NOTE
9B42  3A                         ABX                       ; POINT TO CORRECT NOTE
9B43  31 84                      LEAY  ,X                  ; GET POINTER TO Y REG (TFR X,Y)
9B45  8D 45                      BSR   L9B8C               ; CALCULATE NOTE TIMER VALUE
9B47  DD E3                      STD   PLYTMR              ; SAVE IT
* MAIN SOUND GENERATION LOOP - ONLY THE IRQ SERVICE WILL GET YOU OUT
* OF THIS LOOP (OCTAVES 1 AND 2)
9B49  8D 0C             L9B49    BSR   L9B57               ; MID VALUE TO DA AND WAIT
9B4B  96 DF                      LDA   VOLHI               ; GET HIGH VALUE
9B4D  8D 0B                      BSR   L9B5A               ; STORE TO DA AND WAIT
9B4F  8D 06                      BSR   L9B57               ; MID VALUE TO DA AND WAIT
9B51  96 E0                      LDA   VOLLOW              ; GET LOW VALUE
9B53  8D 05                      BSR   L9B5A               ; STORE
9B55  20 F2                      BRA   L9B49               ; KEEP LOOPING
9B57  86 7E             L9B57    LDA   #$7E                ; DA MID VALUE AND RS 232 MARKING
9B59  12                         NOP                       ; DELAY SOME - FINE TUNE PLAY FREQUENCY
9B5A  B7 FF 20          L9B5A    STA   PIA1                ; STORE TO DA CONVERTER
9B5D  AE A4                      LDX   ,Y                  ; GET DELAY FROM OCTAVE TABLE
9B5F  30 1F             L9B5F    LEAX  $-01,X              ; *
9B61  26 FC                      BNE   L9B5F               ; *COUNT X TO ZERO - PROGRAMMABLE DELAY
9B63  39                         RTS
* OCTAVES 3,4 AND 5 USE A ONE BYTE DELAY TO SET THE PROPER FREQUENCY
9B64  8E 9C 7A          L9B64    LDX   #L9C92-2*12         ; POINT TO DELAY TABLE
9B67  C6 0C                      LDB   #12                 ; 12 BYTES DATA PER OCTAVE
9B69  3D                         MUL                       ; CAIC OCTAVE TABLE OFFSET
9B6A  3A                         ABX                       ; POINT TO CORRECT OCTAVE TABLE
9B6B  35 04                      PULS  B                   ; GET NOTE VALUE BACK
9B6D  3A                         ABX                       ; POINT TO CORRECT NOTE
9B6E  8D 1C                      BSR   L9B8C               ; CALCULATE NOTE TIMER VALUE
9B70  DD E3                      STD   PLYTMR              ; SAVE IT
9B72  8D 0C             L9B72    BSR   L9B80               ; MID VALUE TO DA AND WAIT
9B74  96 DF                      LDA   VOLHI               ; GET HIGH VALUE
9B76  8D 0B                      BSR   L9B83               ; STORE TO DA AND WAIT
9B78  8D 06                      BSR   L9B80               ; MID VALUE TO DA AND WAIT
9B7A  96 E0                      LDA   VOLLOW              ; GET LOW VALUE
9B7C  8D 05                      BSR   L9B83               ; STORE TO DA AND WAIT
9B7E  20 F2                      BRA   L9B72               ; KEEP GOING
* PUT MID VALUE TO DA CONVERTER AND WAIT A WHILE
9B80  86 7E             L9B80    LDA   #$7E                ; DA CONVERTER MID VALUE AND KEEP RS 232 OUTPUT MARKING
9B82  12                         NOP                       ; DELAY SOME - FINE TUNE PLAY FREQUENCY
9B83  B7 FF 20          L9B83    STA   PIA1                ; STORE IN DA CONVERTER
9B86  A6 84                      LDA   ,X                  ; GET DELAY VALUE FROM OCTAVE TABLE
9B88  4A                L9B88    DECA                      ; COUNT ACCA TO ZERO - TIME DELAY
9B89  26 FD                      BNE   L9B88               ; COUNT ACCA TO ZERO - TIME DELAY
9B8B  39                         RTS
* CALCULATE NOTE TIMER VALUE - RETURN WITH VALUE IN ACCD -
* THE LARGER ACCD IS, THE LONGER THE NOTE WILL PLAY
9B8C  C6 FF             L9B8C    LDB   #$FF                ; NOTE TIMER BASE VALUE
9B8E  96 E5                      LDA   DOTVAL              ; GET NOTE TIMER SCALE FACTOR
9B90  27 05                      BEQ   L9B97               ; USE DEFAULT VALUE IF 0
9B92  8B 02                      ADDA  #$02                ; ADD IN CONSTANT TIMER SCALE FACTOR
9B94  3D                         MUL                       ; MULTIPLY SCALE FACTOR BY BASE VALUE
9B95  44                         LSRA                      ; *DIVIDE ACCD BY TWO - EACH INCREMENT OF DOTVAL
9B96  56                         RORB                      ; *WILL INCREASE NOTE TIMER BY 128
9B97  39                L9B97    RTS

* GET NEXT COMMAND - RETURN VALUE IN ACCA
9B98  34 10             L9B98    PSHS  X                   ; SAVE X REGISTER
9B9A  0D D8             L9B9A    TST   VD8                 ; CHECK COMMAND COUNTER
9B9C  27 4D                      BEQ   L9BEB               ; 'FC' ERROR IF NO COMMAND DATA LEFT
9B9E  9E D9                      LDX   VD9                 ; GET COMMAND ADDR
9BA0  A6 80                      LDA   ,X+                 ; GET COMMAND
9BA2  9F D9                      STX   VD9                 ; SAVE NEW ADDRESS
9BA4  0A D8                      DEC   VD8                 ; DECREMENT COMMAND CTR
9BA6  81 20                      CMPA  #SPACE              ; CHECK FOR BLANK
9BA8  27 F0                      BEQ   L9B9A               ; IGNORE BLANKS
9BAA  35 90                      PULS  X,PC                ; RESTORE X RESISTER AND RETURN
