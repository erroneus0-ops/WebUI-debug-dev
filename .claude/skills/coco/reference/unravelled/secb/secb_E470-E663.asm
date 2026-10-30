; Super Extended Color BASIC 2.0 (CoCo 3) -- $E470-$E663
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: ALINK20=$E470, BAS20ERR=$E4CC, ALINK19=$E4D0, ERNO=$E4E9, ERLIN=$E4FD, ALINK21=$E502, ALINK17=$E532, LPOKE=$E545, LPEEK=$E573, BUTTON=$E5B1, PALETTE=$E5F0, IM.CMP=$E654

* ERROR SERVICING ROUTINE PATCH ENTERED FROM $AC46
E470  7F FE 17          ALINK20  CLR   H.ERRBRK            ; SET THE ERROR/BREAK FLAG TO ERROR (0)
E473  96 68                      LDA   CURLIN              ; GET THE CURRENT LINE NUMBER
E475  4C                         INCA                      ; CHECK FOR DIRECT MODE
E476  27 05                      BEQ   LE47D               ; BRANCH IF DIRECT MODE
E478  BE FE 0E                   LDX   H.ONERR             ; HAS AN ON ERROR TRAP BEEN SET UP?
E47B  26 36                      BNE   LE4B3               ; BRANCH IF ONE HAS
E47D  34 02             LE47D    PSHS  A                   ; SAVE ACCA
E47F  96 E6                      LDA   HRMODE              ; TEST THE HI-RES GRAPHICS MODE
E481  35 02                      PULS  A                   ; RESTORE ACCA
E483  27 03                      BEQ   LE488               ; BRANCH IF HI-RES GRAPHICS NOT SET UP
E485  BD E0 19                   JSR   SETTEXT             ; PROGRAM THE VIDEO CONTROL REGISTERS FOR THE CURRENT MODE
E488  C1 4C             LE488    CMPB  #38*2               ; HI-RES GRAPHICS ERROR
E48A  26 13                      BNE   LE49F               ; BRANCH IF NOT
E48C  BD B9 5C                   JSR   LB95C               ; SET UP PRINT PARAMETERS
E48F  BD B9 AF                   JSR   LB9AF               ; SEND A '?' TO CONSOLE OUT
E492  30 8D 00 36                LEAX  BAS20ERR,PC         ; POINT TO ENHANCED BASIC'S ADDITIONAL ERROR CODES
E496  BD AC A0          LE496    JSR   LACA0               ; GET A CHARACTER FROM X AND SEND IT TO CONSOLE OUT
E499  BD AC A0                   JSR   LACA0               ; DO IT AGAIN
E49C  7E AC 65                   JMP   LAC65               ; RE-ENTER THE MAIN STREAM OF CODE ($AC65)
E49F  C1 4E             LE49F    CMPB  #39*2               ; HI-RES TEXT MODE ERROR
E4A1  26 0D                      BNE   LE4B0               ; BRANCH IF NOT
E4A3  BD B9 5C                   JSR   LB95C               ; SET UP THE PRINT PARAMETERS
E4A6  BD B9 AF                   JSR   LB9AF               ; SEND A '?' TO CONSOLE OUT
E4A9  30 8D 00 21                LEAX  LE4CE,PC            ; POINT TO ENHANCED BASIC'S ADDITIONAL ERROR CODES
E4AD  7E E4 96                   JMP   LE496               ; GO PRINT THE ERROR CODE POINTED TO BY X
E4B0  7E AC 49          LE4B0    JMP   LAC49               ; JUMP TO THE ERROR SERVICING ROUTINE ($AC49)
E4B3  F7 FE 10          LE4B3    STB   H.ERROR             ; SAVE THE ERROR NUMBER
E4B6  34 04                      PSHS  B                   ; ALSO PUT IT ON THE STACK TEMPORARILY
E4B8  DC 68                      LDD   CURLIN              ; GET THE CURRENT LINE NUMBER
E4BA  FD FE 13                   STD   H.ERLINE            ; SAVE THE LINE NUMBER WHERE THE ERROR OCCURRED
E4BD  35 04                      PULS  B                   ; GET BACK THE ERROR NUMBER
E4BF  C1 06                      CMPB  #3*2                ; WAS IT AN OUT OF DATA ERROR?
E4C1  26 04                      BNE   LE4C7               ; BRANCH IF NOT
E4C3  DC 2B                      LDD   BINVAL              ; THE INPUT POINTER IS SAVED IN BINVAL BY THE READ COMMAND
E4C5  DD A6                      STD   CHARAD              ; SAVE NEW ADDRESS FOR BASIC'S INPUT POINTER
E4C7  1F 10             LE4C7    TFR   X,D                 ; SAVE THE ON ERROR DESTINATION LINE NUMBER IN ACCD
E4C9  16 FF 7D                   LBRA  LE449               ; GO TRANSFER CONTROL TO THAT LINE NUMBER

* ENHANCED BASIC'S ERROR CODES
E4CC  48 52             BAS20ERR FCC   'HR'                ; 38  HIRES GRAHICS ERROR
E4CE  48 50             LE4CE    FCC   'HP'                ; 39  HIRES TEXT ERROR

* LINE INTO 'NEW' FROM $AD3F
E4D0  34 06             ALINK19  PSHS  B,A                 ; SAVE THE CONTENTS OF ACCD
E4D2  4F                         CLRA
E4D3  5F                         CLRB
E4D4  DD 2D                      STD   OLDPTR              ; RESET 'CONT' ADDRESS SO THAT YOU CAN'T CONTINUE
E4D6  FD FE 0C                   STD   H.ONBRK             ; RESET THE ON BRK ADDRESS TO ZERO: NON-INITIALIZED
E4D9  FD FE 0E                   STD   H.ONERR             ; RESET THE ON ERROR ADDRESS TO ZERO: NON-INITIALIZED
E4DC  FD FE 13                   STD   H.ERLINE            ; RESET THE ERLIN LINE NUMBER TO ZERO: NO ERROR
E4DF  86 FF                      LDA   #$FF                ; INDICATES NO ERROR
E4E1  B7 FE 10                   STA   H.ERROR             ; RESET ERROR NUMBER TO NO ERROR
E4E4  35 06                      PULS  A,B                 ; RESTORE ACCD
E4E6  7E AD 43                   JMP   LAD43               ; JUMP TO THE END OF THE NEW COMMAND ($AD43)

* ERNO
E4E9  4F                ERNO     CLRA                      ; CLEAR THE MS BYTE OF ACCD
E4EA  F6 FE 10                   LDB   H.ERROR             ; GET THE ERROR NUMBER
E4ED  C1 FF                      CMPB  #$FF                ; IS IT A REAL ERROR
E4EF  26 03                      BNE   LE4F4               ; BRANCH IF YES
E4F1  1D                         SEX                       ; NOW ACCD = $FFFF IF NOT A REAL ERROR
E4F2  20 06                      BRA   LE4FA               ; CONVERT ACCD TO FLOATING POINT
E4F4  C1 F1             LE4F4    CMPB  #$F1                ; CHECK FOR ERROR NUMBER $F1
E4F6  26 01                      BNE   LE4F9               ; BRANCH IF NOT ERROR $F1
E4F8  53                         COMB                      ; CONVERT TO 7*2 (UNDEFINED LINE NUMBER)
E4F9  57                LE4F9    ASRB                      ; DIVIDE ERROR NUMBER BY 2
E4FA  7E B4 F4          LE4FA    JMP   GIVABF              ; CONVERT ACCD INTO A FLOATING POINT NUMBER

* ERLIN
E4FD  FC FE 13          ERLIN    LDD   H.ERLINE            ; GET THE LINE NUMBER WHERE THE ERROR OCCURRED
E500  20 F8                      BRA   LE4FA               ; CONVERT IT INTO A FLOATING POINT NUMBER

* BASIC'S MAIN LOOP IN THE DIRECT MODE PATCH ENTERED FROM $AC73
E502  BD E0 19          ALINK21  JSR   SETTEXT             ; SET UP HI-RES TEXT MODE IF ENABLED
E505  BD B9 5C                   JSR   LB95C               ; SET UP VARIOUS PRINT PARAMETERS
E508  1A 50                      ORCC  #$50                ; DISABLE IRQ, FIRQ
E50A  86 34                      LDA   #BLOCK6.4           ; GET/PUT BUFFER BLOCK
E50C  B7 FF A0                   STA   MMUREG              ; PUT IT INTO LOGICAL BLOCK 0
E50F  CC FF FF                   LDD   #$FFFF              ; NO HGET/HPUT BUFFERS USED FLAG
E512  DD 00                      STD   0                   ; SET THE HGET/HPUT BUFFER SPACE TO SHOW NO BUFFERS IN USE
E514  86 38                      LDA   #BLOCK7.4           ; GET NORMAL LOGICAL BLOCK 0
E516  B7 FF A0                   STA   MMUREG              ; PUT BACK INTO THE LOGICAL ADDRESS SPACE
E519  1C AF                      ANDCC #$AF                ; ENABLE IRQ, FIRQ
E51B  7E AC 76                   JMP   LAC76               ; RE-ENTER THE MAIN STREAM CODE ($AC76)

E51E  7D FE 17          LE51E    TST   H.ERRBRK            ; CHECK THE ERROR/BREAK FLAG
E521  27 05                      BEQ   LE528               ; BRANCH IF ERROR BROUGHT US HERE
E523  FC FE 15                   LDD   H.ONBRKS            ; GET THE ON BRK SOURCE LINE NUMBER IF BREAK VECTORED US HERE
E526  20 03                      BRA   LE52B
E528  FC FE 11          LE528    LDD   H.ONERRS            ; GET THE ON ERROR SOURCE LINE NUMBER
E52B  DD 68             LE52B    STD   CURLIN              ; SAVE THE SOURCE LINE NUMBER AS THE CURRENT LINE NUMBER
E52D  C6 0E                      LDB   #7*2                ; UNDEFINED LINE NUMBER ERROR
E52F  7E AC 49                   JMP   LAC49               ; JUMP TO THE ERROR SERVICING ROUTINE ($AC49)

* INPUT PATCH ENTERED FROM $B03D
E532  FC FE 0C          ALINK17  LDD   H.ONBRK             ; GET THE ON BRK SOURCE LINE NUMBER
E535  10 27 C8 D8                LBEQ  LAE11               ; BRANCH IF ON BRK NOT INITIALIZED ($AE11)
E539  34 06                      PSHS  B,A                 ; SAVE THE ON BRK SOURCE ADDRESS
E53B  86 01                      LDA   #$01                ; BREAK FLAG
E53D  B7 FE 17                   STA   H.ERRBRK            ; SET THE ERROR/BREAK FLAG TO BREAK
E540  35 06                      PULS  A,B                 ; RESTORE SOURCE ADDRESS - INEFFICIENT, LDD H.ONBRK IS BETTER
E542  16 FF 04                   LBRA  LE449

* LPOKE
E545  BD B1 41          LPOKE    JSR   LB141               ; EVALUATE A NUMERIC EXPRESSION
E548  10 21 1A B4                LBRN  RAMLINK             ; ROM HOOK
E54C  8D 40                      BSR   LE58E               ; CONVERT FPA0 INTO AN EXTENDED ADDRESS
E54E  C1 3F                      CMPB  #BLOCK7.7           ; HIGHEST POSSIBLE BLOCK NUMBER
E550  10 22 CE F6                LBHI  ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR IF BLOCK NUMBER TOO BIG
E554  34 14                      PSHS  X,B                 ; SAVE REGISTERS
E556  BD B2 6D                   JSR   SYNCOMMA            ; DO A SYNTAX CHECK FOR A COMMA
E559  BD B7 0B                   JSR   EVALEXPB            ; EVALUATE EXPRESSION, RETURN VALUE IN ACCB
E55C  1F 98                      TFR   B,A                 ; SAVE THE BLOCK NUMBER IN ACCA
E55E  35 14                      PULS  B,X                 ; RESTORE REGISTERS
E560  C1 3F                      CMPB  #BLOCK7.7           ; COMPARE TO HIGHEST POSSIBLE BLOCK NUMBER
E562  10 22 CE E4                LBHI  ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR
E566  1A 50                      ORCC  #$50                ; DISABLE INTERRUPTS
E568  17 FB 36                   LBSR  SELBLOK0            ; PUT THE INTERPRETED BLOCK INTO LOGICAL BLOCK 0
E56B  A7 84                      STA   ,X                  ; STORE THE VALUE BEING POKEd
E56D  17 FB 27                   LBSR  SETMMU              ; RESTORE THE MMU REGISTERS TO WHAT BASIC EXPECTS
E570  1C AF                      ANDCC #$AF                ; ENABLE THE IRQ AND FIRQ INTERRUPTS
E572  39                         RTS

* LPEEK
E573  8D 19             LPEEK    BSR   LE58E               ; CONVERT FPA0 INTO AN EXTENDED ADDRESS
E575  10 21 1A 87                LBRN  RAMLINK             ; RAM HOOK
E579  C1 3F                      CMPB  #BLOCK7.7           ; COMPARE TO HIGHEST LEGAL BLOCK NUMBER
E57B  10 22 CE CB                LBHI  ILLFUNC             ; ILLEGAL FUNCTINO CALL ERROR IF BLOCK NUMBER TOO BIG
E57F  1A 50                      ORCC  #$50                ; DISABLE INTERRUPTS
E581  17 FB 1D                   LBSR  SELBLOK0            ; GET THE INTERPRETED BLOCK NUMBER INTO CPU BLOCK 0
E584  E6 84                      LDB   ,X                  ; GET THE VALUE BEING LPEEKed
E586  17 FB 0E                   LBSR  SETMMU              ; RESTORE THE MMU REGISTERS TO WHAT BASIC EXPECTS
E589  1C AF                      ANDCC #$AF                ; ENABLE THE IRQ AND FIRQ INTERRUPTS
E58B  7E B4 F3                   JMP   LB4F3               ; CONVERT THE VALUE IN ACCB INTO A FLOATING POINT NUMBER

* CONVERT FPA0 INTO A 'LONG' ADDRESS
* THE 'LONG' ADDRESS WIL BE RETURNED IN TWO PIECES: THE LOW ORDER 13 BITS
* WILL BE IN THE X REGISTER, AND THE HIGH ORDER 6 BITS, WHICH ARE THE
* BLOCK NUMBER, WILL BE IN ACCB
E58E  34 02             LE58E    PSHS  A
E590  96 4F                      LDA   FP0EXP              ; GET THE EXPONENT OF FPA0
E592  81 93                      CMPA  #$93                ; EXPONENT OF 512K-1
E594  23 04                      BLS   LE59A               ; BRANCH IF <= 512K-1
E596  C6 40                      LDB   #BLOCK7.7+1         ; MAKE IT ONE BLOCK BIGGER THAN THE BIGGEST ALLOWABLE
E598  20 15                      BRA   LE5AF               ; EXIT ROUTINE
E59A  BD BC C8          LE59A    JSR   LBCC8               ; DE-NORMALIZE FPA0
E59D  DC 52                      LDD   FPA0+2              ; GET THE TWO LEAST SIGNIFICANT BITS OF FPA0
E59F  84 1F                      ANDA  #$1F                ; MASK OFF THE 3 HIGH ORDER BITS
E5A1  1F 01                      TFR   D,X                 ; SAVE THE 13 LOW ORDER BITS IN X REGISTER
E5A3  DC 51                      LDD   FPA0+1              ; GET THE SECOND AND THIRD BYTES IF FPA0
E5A5  47                         ASRA
E5A6  56                         RORB
E5A7  47                         ASRA
E5A8  56                         RORB
E5A9  47                         ASRA
E5AA  56                         RORB
E5AB  47                         ASRA                      ; NOT NECESSARY WITH MAXIMUM OF 512K RAM
E5AC  56                         RORB
E5AD  47                         ASRA                      ; NOT NECESSARY WITH MAXIMUM OF 512K RAM
E5AE  56                         RORB                      ; SHIFT ACCD RIGHT 5 TIMES - THE BLOCK NUMBER IS IN ACCB
E5AF  35 82             LE5AF    PULS  A,PC

* BUTTON
E5B1  BD B3 ED          BUTTON   JSR   INTCNV              ; CONVERT FPA0 INTO AN INTEGER IN ACCB
E5B4  10 21 1A 48                LBRN  RAMLINK             ; RAM HOOK
E5B8  C1 03                      CMPB  #$03                ; ONLY BUTTON NUMBERS 0-3 ALLOWD
E5BA  10 22 CE 8C                LBHI  ILLFUNC             ; ILLEGAL FUNCTION ERROR
E5BE  1F 98                      TFR   B,A                 ; SAVE BUTTON NUMBER IN ACCA
E5C0  5F                         CLRB
E5C1  53                         COMB                      ; NOW ACCB = $FF
E5C2  8E FF 00                   LDX   #PIA0               ; POINT TO THE KEYBOARD STROBE PIO
E5C5  E7 02                      STB   $02,X               ; SET THE COLUMN STROBE TO $FF - ALLOW ONLY BUTTONS TO BE CHECKED
E5C7  E6 84                      LDB   ,X                  ; READ THE KEYBOARD ROWS
E5C9  C1 0F                      CMPB  #$0F                ; THE BUTTONS ARE ON THE BOTTOM FOUR ROWS
E5CB  27 1D                      BEQ   LE5EA               ; BRANCH IF NO BUTTONS DOWN
E5CD  30 8D 00 04                LEAX  LE5D5,PC            ; POINT TO THE BUTTON MASKING ROUTINES
E5D1  48                         ALSA
E5D2  48                         ALSA                      ; MULT ACCA BY FOUR - FOUR BYTES/EACH MASKING ROUTINE
E5D3  6E 86                      JMP   A,X                 ; JUMP TO THE APPROPRIATE MASKING ROUTINE

* MASK OFF ALL BUT BUTTON 1, RIGHT JOYSTICK
E5D5  C4 01             LE5D5    ANDB  #$01
E5D7  20 0A                      BRA   LE5E3

* MASK OFF ALL BUT BUTTON 1, LEFT JOYSTICK
E5D9  C4 04             LE5D9    ANDB  #$04
E5DB  20 06                      BRA   LE5E3

* MASK OFF ALL BUT BUTTON 2, RIGHT JOYSTICK
E5DD  C4 02                      ANDB  #$02
E5DF  20 02                      BRA   LE5E3

* MASK OFF ALL BUT BUTTON 2, LEFT JOYSTICK
E5E1  C4 08                      ANDB  #$08
E5E3  26 05             LE5E3    BNE   LE5EA               ; BRANCH IF MASKED BUTTON NOT DOWN
E5E5  CC 00 01                   LDD   #1                  ; IF BUTTON DOWN, RETURN A VALUE OF ONE
E5E8  20 02                      BRA   LE5EC
E5EA  4F                LE5EA    CLRA
E5EB  5F                         CLRB                      ; RETURN A ZERO IF BUTTON IS NOT DOWN
E5EC  BD B4 F4          LE5EC    JSR   GIVABF              ; CONVERT ACCD INTO A FLOATING POINT NUMBER IN FPA0
E5EF  39                         RTS

* PALETTE
E5F0  81 F7             PALETTE  CMPA  #$F7                ; 'RGB' TOKEN?
E5F2  10 21 1A 0A                LBRN  RAMLINK             ; RAM HOOK
E5F6  26 08                      BNE   LE600               ; NOT THE 'RGB' TOKEN, CHECK FOR 'CMP'
E5F8  9D 9F                      JSR   GETNCH              ; GET THE NEXT CHARACTER FROM BASIC'S INPUT LINE
* RGB ENTRY POINT - SET THE PALETTE REGISTERS FOR DEFAULT RGB VALUES
E5FA  30 8D 00 66       LE5FA    LEAX  IM.RGB,PC           ; POINT TO THE DEFAULT RGB PALETTE COLORS
E5FE  20 34                      BRA   LE634               ; PUT THE DATA POINTED TO BY X INTO THE PALETTE REGISTERS
E600  81 F6             LE600    CMPA  #$F6                ; 'CMP' TOKEN?
E602  26 08                      BNE   LE60C               ; NO, GET A REGISTER NUMBER AND COLOR
E604  9D 9F                      JSR   GETNCH              ; GET THE NEXT CHARACTER FROM BASIC'S INPUT LINE
* CMP ENTRY POINT - SET THE PALETTE REGISTERS FOR DEFAULT CMP VALUES
E606  30 8D 00 4A       LE606    LEAX  IM.CMP,PC           ; POINT TO THE DEFAULT CMP PALETTE COLORS
E60A  20 28                      BRA   LE634               ; PUT THE DATA POINTED TO BY X INTO THE PALETTE REGISTERS
E60C  BD E7 B2          LE60C    JSR   LE7B2               ; EVALUATE TWO EXPRESSIONS, NORMALLY A HORIZONTAL & VERTICAL COORDINATE
E60F  8E FF B0                   LDX   #PALETREG           ; POINT TO THE GIME CHIP'S PALETTE REGISTERS
E612  10 8E E6 78                LDY   #IM.PALET           ; POINT TO THE RAM IMAGE OF THE PALETTE REGISTERS
E616  96 2C                      LDA   BINVAL+1            ; GET THE NUMBER OF THE PALETTE REGISTER TO CHANGE
E618  81 10                      CMPA  #16                 ; 16 PALETTE REGISTERS MAXIMUM
E61A  10 24 CE 2C                LBCC  ILLFUNC             ; ILLEGAL FUNCTION CALLERROR IF PALETTE REGISTER > 15
E61E  30 86                      LEAX  A,X                 ; POINT TO THE SELECTED PALETTE REGISTER
E620  31 A6                      LEAY  A,Y                 ; POINT TO THE SELECTED PALETTE REGISTER RAM IMAGE
E622  D6 C0                      LDB   VERBEG+1            ; GET THE NEW COLOR FOR THE PALETTE REGISTER
E624  C1 3F                      CMPB  #63                 ; MAXIMUM OF 64 COLORS (ZERO IS A LEGIT COLOR)
E626  23 02                      BLS   LE62A               ; BRANCH IF LEGITIMATE COLOR SELECTED
E628  C6 3F                      LDB   #63                 ; USE COLOR 63 IF BAD COLOR NUMBER SELECTED
E62A  1A 50             LE62A    ORCC  #$50                ; DISABLE INTERRUPTS
E62C  13                         SYNC                      ; WAIT FOR AN INTERRUPT TO CHANGE PALETTE REGISTERS - THIS WILL
; PREVENT THE SCREEN FROM FLASHING WHEN THE CHANGE IS MADE.
E62D  E7 84                      STB   ,X                  ; SAVE THE NEW COLOR IN THE PALETTE REGISTER
E62F  E7 A4                      STB   ,Y                  ; SAVE THE NEW COLOR IN THE PALETTE REGISTER RAM IMAGE
E631  1C AF                      ANDCC #$AF                ; ENABLE IRQ, FIRQ INTERRUPTS
E633  39                         RTS

E634  34 10             LE634    PSHS  X                   ; SAVE THE SOURCE REGISTER POINTER
E636  10 8E E6 78                LDY   #IM.PALET           ; POINT TO THE PALETTE REGISTER RAM IMAGE
E63A  8D 0C                      BSR   LE648               ; COPY THE SOURCE PALETTE REGISTER TO THE RAM IMAGE
E63C  35 10                      PULS  X                   ; RESTORE THE SOURCE REGISTER POINTER
E63E  10 8E FF B0                LDY   #PALETREG           ; POINT TO THE PALETTE REGISTERS
E642  1A 50                      ORCC  #$50                ; DIABLE INTERRUPTS
E644  13                         SYNC                      ; COPY IMMEDIATELY AFTER AN INTERRUPT TO PREVENT SPARKING
E645  8D 01                      BSR   LE648               ; COPY THE SOURCE REGISTER DATE INTO THE PALETTE REGISTERS
E647  39                         RTS

E648  C6 0F             LE648    LDB   #16-1               ; NUMBER OF BYTES TO COPY - BUG - SHOULD BE 16
E64A  A6 80             LE64A    LDA   ,X+                 ; GET A BYTE
E64C  A7 A0                      STA   ,Y+                 ; MOVE IT
E64E  5A                         DECB                      ; BUMP COUNTER DOWN ONE
E64F  26 F9                      BNE   LE64A               ; LOOP UNTIL DONE
E651  1C AF                      ANDCC #$AF                ; ENABLE IRQ, FIRQ INTERRUPTS
E653  39                         RTS

* PALETTE COLORS FOR A COMPOSITE MONITOR
E654  12 24 0B 07 3F 1F IM.CMP   FCB   18,36,11,7,63,31
E65A  09 26 00 12 00 3F          FCB   9,38,0,18,0,63
E660  00 12 00 26                FCB   0,18,0,38
