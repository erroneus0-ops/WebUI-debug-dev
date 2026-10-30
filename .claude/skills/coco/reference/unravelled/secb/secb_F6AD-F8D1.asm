; Super Extended Color BASIC 2.0 (CoCo 3) -- $F6AD-$F8D1
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: ALINK23=$F6AD, MICROMS=$F702, AUTHORMS=$F71B, ALINK27=$F757, ALINK24=$F77E, ALINK22=$F7AE, DO A BACKSPACE HERE=$, DO A HI-RES BACKSPACE HERE=$, ALINK26=$F8A3, ALINK25=$F8C3

* CLS PATCH ENTERED FROM $8C4C
F6AD  35 01             ALINK23  PULS  CC                  ; RESTORE THE ZERO FLAG
F6AF  10 21 09 4D                LBRN  RAMLINK             ; RAM HOOK
F6B3  27 2B                      BEQ   LF6E0               ; CLEAR THE SCREEN CURSOR ATTRIBUTES IF NO ARGUMENT
F6B5  BD B7 0B                   JSR   EVALEXPB            ; EVALUATE EXPRESSION, RETURN VALUE IN ACCB
F6B8  5D                         TSTB                      ; TEST ARGUMENT
F6B9  27 25                      BEQ   LF6E0               ; BRANCH IF CLS 0
F6BB  C1 08                      CMPB  #$08                ; CHECK FOR CLS 8
F6BD  22 28                      BHI   LF6E7               ; BRANCH IF > CLS 8
F6BF  5A                         DECB                      ; CHANGE 1-8 TO 0-7
F6C0  31 8D EF B4                LEAY  IM.PALET,PC         ; POINT TO THE PALETTE REGISTER IMAGES
F6C4  A6 A5                      LDA   B,Y                 ; GET THE COLOR IN THE PALETTE REGISTER
F6C6  B7 FF 9A                   STA   V.BORDER            ; AND SAVE IT AS THE NEW BORDER COLOR
F6C9  17 00 9A                   LBSR  LF766               ; SET THE BORDER COLOR IN THE 40 & 80 COLUMN VIDEO MODE IMAGES
F6CC  F7 FE 08                   STB   H.CRSATT            ; SAVE THE ADJUSTED CLS ARGUMENT AS THE NEW ATTRIBUTE BYTE
F6CF  86 20                      LDA   #SPACE
F6D1  17 00 9E                   LBSR  LF772               ; PUT THE HI-RES TEXT SCREEN INTO LOGICAL BLOCK 1
F6D4  8E 20 00                   LDX   #HRESSCRN           ; POINT X TO THE TOP OF THE HI-RES TEXT SCREEN
F6D7  BF FE 00                   STX   H.CRSLOC            ; PUT THE CURSOR AT THE TOP OF THE SCREEN
F6DA  8D BF                      BSR   LF69B               ; CLEAR THE SCREEN
F6DC  17 00 99          LF6DC    LBSR  LF778               ; REMOVE THE HI-RES TEXT SCREEN FROM THE LOGICAL ADDRESS SPACE
F6DF  39                         RTS
F6E0  17 00 8F          LF6E0    LBSR  LF772               ; PUT THE HI-RES TEXT SCREEN INTO LOGICAL BLOCK 1
F6E3  8D A7                      BSR   LF68C               ; CLEAR THE HI-RES TEXT SCREEN
F6E5  20 F5                      BRA   LF6DC               ; PUT BLOCK 7.1 BACK INTO LOGICAL BLOCK 1
F6E7  7F FE 08          LF6E7    CLR   H.CRSATT            ; RESET THE ATTRIBUTE BYTE TO ZERO
F6EA  B6 E6 78                   LDA   IM.PALET            ; GET THE COLOR IN PALETTE REGISTER 0
F6ED  B7 FF 9A                   STA   V.BORDER            ; AND SAVE IT AS THE NEW BORDER COLOR
F6F0  8D 74                      BSR   LF766               ; ALSO SAVE IT IN THE 40 AND 80 COLUMN VIDEO REGISTER IMAGES
F6F2  C1 64                      CMPB  #100                ; CHECK FOR CLS 100
F6F4  27 3A                      BEQ   LF730               ; IF CLS 100, THEN PRINT THE AUTHORS' NAMES - THIS WILL ONLY BE
; DONE THE FIRST TIME CLS 100 IS EXECUTED, THIS CODE WILL BE
; OVERWRITTEN BY NOPs WHEN THE AUTHORS' NAMES ARE DISPLAYED.
F6F6  8D 7A                      BSR   LF772               ; PUT THE HI-RES TEXT SCREEN INTO LOGICAL BLOCK 1
F6F8  8D 92                      BSR   LF68C               ; CLEAR THE HI-RES TEXT SCREEN
F6FA  8D 7C                      BSR   LF778               ; PUT BLOCK 7.1 BACK INTO LOGICAL BLOCK 1
F6FC  8E F7 01                   LDX   #MICROMS-1          ; POINT TO MICROWARE'S COMMERCIAL MESSAGE
F6FF  7E B9 9C                   JMP   STRINOUT            ; COPY A STRING TO CONSOLE OUT ($B99C)

* MICROWARE COMMERCIAL
F702  4D 69 63 72 6F 77 MICROMS  FCC   'T.Harris & T.Earles'
F708  61 72 65 20 53 79
F70E  73 74 65 6D 73 20
F714  43 6F 72 70 2E
F719  0D 00             LF719    FCB   $0D,$00

* NAMES OF THE AUTHORS
* THE INITIALIZATION CODE WILL COPY THE AUTHOR'S NAMES INTO THIS SPOT
F71B  00 00 00 00 00 00 AUTHORMS FCB   $00,$00,$00,$00,$00,$00
F721  00 00 00 00 00 00          FCB   $00,$00,$00,$00,$00,$00
F727  00 00 00 00 00 00          FCB   $00,$00,$00,$00,$00,$00
F72D  00 00 00                   FCB   $00,$00,$00

F730  8D 40             LF730    BSR   LF772               ; PUT THE HI-RES TEXT SCREEN INTO LOGICAL BLOCK 1
F732  17 FF 57                   LBSR  LF68C               ; CLEAR THE HI-RES TEXT SCREEN
F735  8D 41                      BSR   LF778               ; PUT BLOCK 7.1 BACK INTO LOGICAL BLOCK 1
F737  8E F7 1A                   LDX   #AUTHORMS-1         ; POINT TO THE AUTHOR MESSAGE
F73A  BD B9 9C                   JSR   STRINOUT            ; COPY A STRING TO CONSOLE OUT
F73D  34 10                      PSHS  X
F73F  30 8D FF B1                LEAX  LF6F4,PC            ; POINT TO THE INSTRUCTION WHICH BRANCHES TO THIS ROUTINE
F743  86 12                      LDA   #$12                ; OP CODE OF A NOP
F745  A7 80                      STA   ,X+                 ; REPLACE THE BRANCH TO THIS ROUTINE WITH 2 NOPs MAKING IT SO
F747  A7 84                      STA   ,X                  ; THAT THIS ROUTINE MAY ONLY BE ENTERED ONE TIME
F749  30 8D FF CE                LEAX  AUTHORMS,PC         ; POINT TO THE AUTHORS CODED NAMES
* REPLACE THE AUTHORS' NAMES AND THE CODE THAT DISPLAYS THEM WITH NOPs
F74D  A7 80             LF74D    STA   ,X+                 ; SAVE A NOP
F74F  8C F7 4D                   CMPX  #LF74D              ; CHECK FOR END OF THE DISPLAY NAME ROUTINE
F752  25 F9                      BCS   LF74D               ; LOOP UNTIL DONE
F754  35 10                      PULS  X                   ; RESTORE X; THIS AND THE RTS FOLLOWING SHOULD BE PULS X,PC
F756  39                         RTS

* GET AN INPUT LINE FOR BASIC PATCH ENTERED FROM $A38D
F757  0D E7             ALINK27  TST   HRWIDTH             ; CHECK FOR HI-RES TEXT MODE
F759  26 06                      BNE   LF761               ; BRANCH IF IN A HI-RES TEXT MODE
F75B  BD A9 28                   JSR   LA928               ; CLEAR THE 32 COLUMN SCREEN
F75E  7E A3 90          LF75E    JMP   LA390               ; RE-ENTER THE MAIN STREAM OF CODE ($A390)
F761  17 FF 7C          LF761    LBSR  LF6E0               ; RESET THE HI-RES TEXT SCREEN
F764  20 F8                      BRA   LF75E

* SAVE THE VALUE IN ACCA AS THE BORDER COLOR IN THE 40 AND 80 COLUMN VIDEO MODE IMAGES
F766  34 20             LF766    PSHS  Y
F768  31 8D E8 CF                LEAY  LE8CF,PC            ; POINT TO THE 40 COLUMN MODE REGISTER IMAGE
F76C  A7 23                      STA   $03,Y               ; SAVE THE BORDER COLOR IN THE 40 COLUMN VIDEO MODE REGISTER IMAGE
F76E  A7 2C                      STA   $0C,Y               ; SAVE THE BORDER COLOR IN THE 80 COLUMN VIDEO MODE REGISTER IMAGE
F770  35 A0                      PULS  Y,PC

F772  1A 50             LF772    ORCC  #$50                ; DISABLE THE INTERRUPTS
F774  17 E9 3E                   LBSR  SELTEXT             ; PUT BLOCK 6.6 INTO LOGICAL BLOCK 1
F777  39                         RTS
F778  17 E9 1C          LF778    LBSR  SETMMU              ; COPY THE MMU IMAGES INTO THE MMU REGISTERS
F77B  1C AF                      ANDCC #$AF                ; ENABLE IRQ, FIRQ
F77D  39                         RTS
* PATCH 24 - BLINK THE CURSOR PATCH ENTERED FROM $A0D4
F77E  8D 07             ALINK24  BSR   LF787               ; BLINK THE CURSOR
F780  BD A1 CB                   JSR   KEYIN               ; GET A KEY
F783  27 F9                      BEQ   ALINK24             ; LOOP UNTIL A KEY IS PRESSED
F785  35 94                      PULS  B,X,PC
F787  0A 94             LF787    DEC   BLKCNT              ; DECREMENT THE CURSOR BLINK DELAY
F789  26 1D                      BNE   LF7A8               ; IT'S NOT TIME TO BLINK THE CURSOR
F78B  C6 0B                      LDB   #11                 ; CURSOR BLINK DELAY CONSTANT
F78D  D7 94                      STB   BLKCNT              ; RESET THE CURSOR BLINK DELAY COUNTER
F78F  8D E1                      BSR   LF772               ; PUT THE HI-RES TEXT SCREEN INTO THE LOGICAL ADDRESS SPACE
F791  BE FE 00                   LDX   H.CRSLOC            ; POINT TO THE CURSOR CHARACTER
F794  A6 01                      LDA   $01,X               ; GET THE CURSOR CHARACTER'S ATTRIBUTES
F796  85 40                      BITA  #$40                ; IS THE UNDERLINE MODE ACTIVE?
F798  27 05                      BEQ   LF79F               ; BRANCH IF NOT ACTIVE UNDERLINE
F79A  B6 FE 08                   LDA   H.CRSATT            ; GET THE CURSOR ATTRIBUTES RAM IMAGE
F79D  20 05                      BRA   LF7A4               ; PUT IT ON THE SCREEN
F79F  B6 FE 08          LF79F    LDA   H.CRSATT            ; GET THE CURSOR ATTRIBUTES RAM IMAGE
F7A2  8A 40                      ORA   #$40                ; FORCE THE UNDERLINE ATTRIBUTE
F7A4  A7 01             LF7A4    STA   $01,X               ; SAVE THE NEW CURSOR ATTRIBUTES IN THE HI-RES TEXT SCREEN
F7A6  8D D0                      BSR   LF778               ; RESTORE THE NORMAL BASIC PROGRAM BLOCK TO LOGICAL BLOCK 1
F7A8  8E 04 5E          LF7A8    LDX   #DEBDEL             ; GET THE KEYBOARD DEBOUNCE DELAY
F7AB  7E A7 D3                   JMP   LA7D3               ; GO WAIT A WHILE ($A7D3)

* PATCH 22 - PUT A CHARACTER ON THE SCREEN PATCH ENTERED FROM $BC3D
F7AE  8D C2             ALINK22  BSR   LF772               ; PUT THE HI-RES TEXT SCREEN INTO THE LOGICAL ADDRESS SPACE
F7B0  10 21 08 4C                LBRN  RAMLINK             ; RAM HOOK
F7B4  BE FE 00                   LDX   H.CRSLOC            ; POINT TO THE CURSOR CHARACTER
F7B7  81 08                      CMPA  #BS                 ; BACKSPACE CHARACTER?
F7B9  26 09                      BNE   LF7C4               ; NO

                        DO A BACKSPACE HERE
F7BB  8C 20 00                   CMPX  #HRESSCRN           ; ARE WE AT THE UPPER LEFT-HAND CORNER OF THE SCREEN?
F7BE  27 1E                      BEQ   LF7DE               ; YES, DO NOT ALLOW A BACKSPACE
F7C0  8D 20                      BSR   LF7E2               ; DO A BACKSPACE ON THE HI-RES SCREEN
F7C2  20 1A                      BRA   LF7DE
F7C4  81 0D             LF7C4    CMPA  #CR                 ; ENTER KEY?
F7C6  26 04                      BNE   LF7CC               ; NO
F7C8  8D 5D                      BSR   LF827               ; DO A CARRIAGE RETURN ON THE HI-RES SCREEN
F7CA  20 0B                      BRA   LF7D7               ; CHECK TO SEE IF THE SCREEN SHOULD BE SCROLLED
F7CC  81 20             LF7CC    CMPA  #$20                ; CHECK FOR A CONTROL CHARACTER
F7CE  25 0E                      BCS   LF7DE               ; DO NOTHING IF A CONTROL CHARACTER
F7D0  F6 FE 08                   LDB   H.CRSATT            ; GET THE CURSOR ATTRIBUTES RAM IMAGE
F7D3  ED 84                      STD   ,X                  ; PUT THE NEW CHARACTER AND ATTRIBUTES INTO THE HI-RES TEXT SCREEN
F7D5  8D 30                      BSR   LF807               ; MOVE THE CURSOR FORWARD ONE CHARACTER
F7D7  BC FE 06          LF7D7    CMPX  H.DISPEN            ; CHECK FOR THE END OF THE HI-RES TEXT SCREEN
F7DA  25 02                      BCS   LF7DE               ; BRANCH IF NOT AT THE END
F7DC  8D 76                      BSR   LF854               ; SCROLL THE SCREEN UP ONE ROW
F7DE  8D 98             LF7DE    BSR   LF778               ; RESTORE THE NORMAL BASIC PROGRAM BLOCK TO LOGICAL BLOCK 1
F7E0  35 96                      PULS  A,B,X,PC

                        DO A HI-RES BACKSPACE HERE
F7E2  34 06             LF7E2    PSHS  B,A
F7E4  86 20                      LDA   #SPACE              ; SPACE CHARACTER
F7E6  F6 FE 08                   LDB   H.CRSATT            ; GET THE ATTRIBUTES RAM IMAGE
F7E9  ED 84                      STD   ,X                  ; SAVE A SPACE ON THE SCREEN AT THE OLD CURSOR POSITION
F7EB  CA 40                      ORB   #$40                ; FORCE THE UNDERLINE ATTRIBUTE
F7ED  ED 1E                      STD   $-02,X              ; SAVE AN UNDERLINED SPACE AS THE NEW CURSOR CHARACTER
F7EF  30 1E                      LEAX  $-02,X              ; MOVE THE CURSOR POINTER BACK TWO
F7F1  BF FE 00                   STX   H.CRSLOC            ; AND SAVE IT IN RAM
F7F4  FC FE 02                   LDD   H.CURSX             ; GET THE COLUMN AND ROW POSITION OF THE OLD CURSOR
F7F7  4A                         DECA                      ; BUMP THE COLUMN NUMBER DOWN ONE
F7F8  2A 08                      BPL   LF802               ; BRANCH IF NO WRAP-AROUND
F7FA  5A                         DECB                      ; BUMP THE ROW COUNTER DOWN ONE
F7FB  F7 FE 03                   STB   H.CURSY             ; SAVE THE NEW CURSOR ROW NUMBER
F7FE  B6 FE 04                   LDA   H.COLUMN            ; GET THE NUMBER OF CHARACTERS PER ROW
F801  4A                         DECA                      ; MAKE THE HIGHEST ALLOWABLE COLUMN NUMBER (ZERO IS FIRST)
F802  B7 FE 02          LF802    STA   H.CURSX             ; SAVE THE NEW CURSOR COLUMN NUMBER
F805  35 86                      PULS  A,B,PC
F807  34 06             LF807    PSHS  B,A
F809  86 20                      LDA   #$20                ; GET THE CURSOR CHARACTER
F80B  F6 FE 08                   LDB   H.CRSATT            ; GET THE CURSOR ATTRIBUTES RAM IMAGE
F80E  CA 40                      ORB   #$40                ; FORCE THE UNDERLINE ATTRIBUTE
F810  30 02                      LEAX  $02,X               ; MOVE THE POINTER UP ONE CHARACTER POSITION
F812  ED 84                      STD   ,X                  ; SAVE THE NEW CHARACTER ATTRIBUTES IN THE HI-RES TEXT SCREEN
F814  BF FE 00                   STX   H.CRSLOC            ; SAVE THE NEW CURSOR POSITION
F817  FC FE 02                   LDD   H.CURSX             ; GET THE OLD CURSOR ROW AND COLUMN NUMBERS
F81A  4C                         INCA                      ; BUMP THE COLUMN NUMBER UP ONE
F81B  B1 FE 04                   CMPA  H.COLUMN            ; CHECK FOR WRAP-AROUND TO NEXT ROW
F81E  25 E2                      BCS   LF802               ; BRANCH IF NO WRAP-AROUND
F820  5C                         INCB                      ; BUMP THE ROW NUMBER UP ONE
F821  F7 FE 03                   STB   H.CURSY             ; SAVE THE NEW ROW NUMBER
F824  4F                         CLRA                      ; SET THE COLUMN NUMBER TO ZERO
F825  20 DB                      BRA   LF802
* DO A HI-RES CARRIAGE RETURN
F827  34 06             LF827    PSHS  B,A
F829  86 20                      LDA   #SPACE              ; SPACE CHARACTER
F82B  F6 FE 08                   LDB   H.CRSATT            ; GET THE CURSOR ATTRIBUTES RAM IMAGE
F82E  ED 81             LF82E    STD   ,X++                ; SAVE A SPACE CHARACTER AND ADVANCE THE CURSOR POINTER ONE CHARACTER
F830  34 02                      PSHS  A
F832  B6 FE 02                   LDA   H.CURSX             ; GET THE CURSOR'S COLUMN NUMBER
F835  4C                         INCA                      ; BUMP IT UP ONE
F836  B7 FE 02                   STA   H.CURSX             ; SAVE THE NEW COLUMN NUMBER
F839  B1 FE 04                   CMPA  H.COLUMN            ; HAS IT WRAPPED AROUND?
F83C  35 02                      PULS  A
F83E  25 EE                      BCS   LF82E               ; BRANCH IF NO WRAP-AROUND
F840  BF FE 00                   STX   H.CRSLOC            ; SAVE THE NEW CURSOR POINTER
F843  7F FE 02                   CLR   H.CURSX             ; SET THE CURSOR COLUMN NUMBER TO ZERO
F846  7C FE 03                   INC   H.CURSY             ; BUMP THE ROW NUMBER UP ONE
F849  86 20                      LDA   #$20                ; GET THE CURSOR CHARACTER
F84B  F6 FE 08                   LDB   H.CRSATT            ; ACCB ALREADY CONTAINS THIS VALUE
F84E  CA 40                      ORB   #$40                ; FORCE THE UNDERLINE ATTRIBUTE
F850  ED 84                      STD   ,X                  ; SAVE AN UNDERLINED CHARACTER AS THE NEW CURSOR CHARACTER
F852  35 86                      PULS  A,B,PC

* SCROLL THE SCREEN
F854  34 06             LF854    PSHS  B,A
F856  8E 20 00                   LDX   #HRESSCRN           ; POINT TO THE START OF THE HI-RES TEXT SCREEN
F859  B6 FE 04                   LDA   H.COLUMN            ; GET THE NUMBER OF CHARACTERS PER ROW
F85C  81 28                      CMPA  #40                 ; 40 CHARACTERS PER ROW?
F85E  26 0E                      BNE   LF86E               ; BRANCH IF 80 CHARACTERS PER ROW

* SCROLL A 40 CHARACTER ROW
F860  EC 88 50          LF860    LDD   2*40,X              ; GET A CHARACTER AND ATTRIBUTE FROM ONE ROW DOWN
F863  ED 81                      STD   ,X++                ; AND MOVE THEM UP TO THE PRESENT ROW
F865  8C 27 30                   CMPX  #HRESSCRN+(ROWMAX-1)*40*2 ; PAST THE END OF THE HI-RES TEXT SCREEN?
F868  25 F6                      BCS   LF860               ; NO, KEEP MOVING CHARACTERS AND ATTRIBUTES
F86A  8D 0F             LF86A    BSR   LF87B               ; FILL THE LAST ROW WITH SPACES
F86C  35 86                      PULS  A,B,PC

* SCROLL AN 80 CHARACTER SCREEN
F86E  EC 89 00 A0       LF86E    LDD   80*2,X              ; GET A CHARACTER AND ATTRIBUTES FROM ONE ROW DOWN
F872  ED 81                      STD   ,X++                ; AND MOVE THEM UP TO THE PRESENT ROW
F874  8C 2E 60                   CMPX  #HRESSCRN+(ROWMAX-1)*80*2 ; PAST THE END OF THE HI-RES TEXT SCREEN?
F877  25 F5                      BCS   LF86E               ; NO, KEEP MOVING CHARACTERS AND ATTRIBUTES
F879  20 EF                      BRA   LF86A

* FILL THE LAST ROW WITH SPACES
F87B  7F FE 02          LF87B    CLR   H.CURSX             ; RESET THE COLUMN NUMBER TO ZERO
F87E  86 17                      LDA   #ROWMAX-1           ; GET THE HIGHEST ROW NUMBER (ZERO IS LOWEST)
F880  B7 FE 03                   STA   H.CURSY             ; AND SAVE IT AS THE CURRENT ROW NUMBER
F883  86 20                      LDA   #SPACE              ; SPACE CHARACTER
F885  F6 FE 08                   LDB   H.CRSATT            ; GET THE ATTRIBUTES RAM IMAGE
F888  34 10                      PSHS  X                   ; SAVE THE CURRENT CHARACTER POINTER
F88A  ED 81             LF88A    STD   ,X++                ; SAVE A CHARACTER AND ATTRIBUTES TO THE HI-RES TEXT SCREEN
F88C  BC FE 06                   CMPX  H.DISPEN            ; CHECK FOR THE END OF THE HI-RES TEXT SCREEN
F88F  26 F9                      BNE   LF88A               ; BRANCH IF NOT AT THE END OF THE HI-RES TEXT SCREEN
F891  7F FE 02                   CLR   H.CURSX             ; RESET THE COLUMN NUMBER TO ZERO
F894  35 10                      PULS  X                   ; RESTORE THE CHARACTER POINTER
F896  86 20                      LDA   #$20                ; GET THE CURSOR CHARACTER
F898  F6 FE 08                   LDB   H.CRSATT            ; GET THE CURSOR ATTRIBUTES RAM IMAGE
F89B  CA 40                      ORB   #$40                ; FORCE THE UNDERLINE ATTRIBUTE
F89D  ED 84                      STD   ,X                  ; SAVE THE NEW CURSOR CHARACTER
F89F  BF FE 00                   STX   H.CRSLOC            ; SAVE THE NEW CURSOR POINTER
F8A2  39                         RTS

* PRINT @ PATCH ENTERED FROM $B902
F8A3  0D 6F             ALINK26  TST   DEVNUM              ; CHECK THE DEVICE NUMBER
F8A5  26 04                      BNE   LF8AB               ; BRANCH IF NOT THE SCREEN
F8A7  0D E7                      TST   HRWIDTH             ; CHECK THE HI-RES TEXT MODE
F8A9  26 06                      BNE   LF8B1               ; BRANCH IF A HI-RES TEXT MODE IS SET
F8AB  BD A3 5F          LF8AB    JSR   LA35F               ; SET UP THE PRINT PARAMETERS
F8AE  7E B9 5F                   JMP   LB95F               ; RE-ENTER THE MAIN STREAM OF CODE ($B95F)
F8B1  17 FE BE          LF8B1    LBSR  LF772               ; PUT THE HI-RES TEXT SCREEN INTO THE LOGICAL ADDRESS SPACE
F8B4  7D FE 02                   TST   H.CURSX             ; CHECK THE CURSOR'S X COORDINATE
F8B7  34 01                      PSHS  CC                  ; SAVE THE ZERO FLAG
F8B9  17 FE BC                   LBSR  LF778               ; RESTORE THE NORMAL BASIC PROGRAM BLOCK TO LOGICAL BLOCK 1
F8BC  35 01                      PULS  CC                  ; RESTORE THE ZERO FLAG
F8BE  10 26 C0 96                LBNE  LB958               ; BRANCH IF THE CURSOR IS NOT AT THE START OF THE LINE ($B958)
F8C2  39                         RTS

* PRINT @ PATCH ENTERED FROM $B902
F8C3  0D E7             ALINK25  TST   HRWIDTH             ; CHECK THE HI-RES TEXT MODE
F8C5  26 06                      BNE   LF8CD               ; 'HP' ERROR IF THE HI-RES TEXT MODE IS NOT SET
F8C7  BD A5 54                   JSR   LA554               ; MOVE THE CURSOR TO THE PROPER PRINT POSITION
F8CA  7E B9 05                   JMP   LB905               ; RE-ENTER THE MAIN STREAM OF CODE ($B905)
F8CD  C6 4E             LF8CD    LDB   #39*2               ; 'HP' ERROR
F8CF  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER ($AC46)
