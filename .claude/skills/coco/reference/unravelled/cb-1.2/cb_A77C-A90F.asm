; Color BASIC 1.2 -- $A77C-$A90F
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: CASON=$A77C, MOTOR=$A7BD, WRLDR=$A7D8, SNDBLK=$A7F4, SET=$A880, RESET=$A8B1, POINT=$A8F5

*** LOOK FOR THE SYNC BYTES - RETURN WITH ACCA = 0 IF SYNC'ED
*** ON HI - LO TRANSITION, ACCA = $A0 IF SYNC'ED ON THE
*** LO - HI TRANSITION OF THE INPUT SIGNAL FROM THE CASSETTE.
A77C  1A 50             CASON    ORCC  #$50                ; DISABLE IRQ,FIRQ
A77E  8D 4A                      BSR   LA7CA               ; TURN ON TAPE DECK MOTOR
A780  0F 82                      CLR   CPULWD              ; RESET UP TO SPEED COUNTER
A782  8D DF             LA782    BSR   LA763               ; WAIT FOR LO-HI TRANSITION
A784  8D 27             LA784    BSR   LA7AD               ; WAIT FOR HI-LO TRANSITION
A786  22 0F                      BHI   LA797               ; CASSETTE SPEED IN RANGE FOR 1200 HZ
A788  8D 1D             LA788    BSR   LA7A7               ; WAIT FOR LO-HI TRANSITION
A78A  25 0F                      BCS   LA79B               ; CASSETTE SPEED IN RANGE FOR 2400 HZ
A78C  0A 82                      DEC   CPULWD              ; DECREMENT UP TO SPEED COUNTER IF SYNC'ED ON LO-HI
A78E  96 82                      LDA   CPULWD              ; GET IT
A790  81 A0                      CMPA  #-96                ; HAVE THERE BEEN 96 CONSECUTIVE 1-0-1-0 PATTERNS
A792  26 EE             LA792    BNE   LA782               ; NO
A794  97 84                      STA   CBTPHA              ; SAVE WHICH TRANSITION (HI-LO OR LO-HI)
A796  39                         RTS
A797  8D 0E             LA797    BSR   LA7A7               ; WAIT FOR LO-HI TRANSITION
A799  22 E9                      BHI   LA784               ; BRANCH IF TWO CONSECUTIVE 1200 HZ PULSES
A79B  8D 10             LA79B    BSR   LA7AD               ; WAIT FOR HI-LO TRANSITION
A79D  25 E9                      BCS   LA788               ; BRANCH IF TWO CONSECUTIVE 2400 HZ PULSES
A79F  0C 82                      INC   CPULWD              ; INCREMENT UP TO SPEED COUNTER IF SYNC'ED ON HI-LO
A7A1  96 82                      LDA   CPULWD              ; GET IT
A7A3  80 60                      SUBA  #96                 ; GOT ENOUGH SYNC PULSES? - ACCA WILL BE ZERO IF
* THERE HAVE BEEN 96 CONSECUTIVE 0-1-0-1 PATTERNS
A7A5  20 EB                      BRA   LA792
A7A7  0F 83             LA7A7    CLR   CPERTM              ; RESET PERIOD TIMER
A7A9  8D BC                      BSR   LA767               ; WAIT UNTIL CASSETTE INPUT GOES HI
A7AB  20 04                      BRA   LA7B1
A7AD  0F 83             LA7AD    CLR   CPERTM              ; RESET PERIOD TIMER
A7AF  8D C6                      BSR   LA777               ; WAIT UNTIL CASSETTE GOES LO
A7B1  D6 83             LA7B1    LDB   CPERTM              ; GET PERIOD TIMER
A7B3  D1 90                      CMPB  CMP0                ; UPPER LIMIT OF 1200 HZ PERIOD
A7B5  22 03                      BHI   LA7BA               ; BRANCH IF CASSETTE SPEED IS TOO SLOW OR DROPOUT
A7B7  D1 91                      CMPB  CMP1                ; UPPER LIMIT OF 2400 HZ PERIOD
A7B9  39                         RTS
A7BA  0F 82             LA7BA    CLR   CPULWD              ; RESET UP TO SPEED COUNTER
A7BC  39                         RTS

* MOTOR
A7BD  1F 89             MOTOR    TFR   A,B                 ; SAVE CURRENT TOKEN IN ACCB
A7BF  9D 9F                      JSR   GETNCH              ; GET NEXT INPUT CHARACTER FROM BASIC
A7C1  C1 AA                      CMPB  #$AA                ; 'OFF' TOKEN
A7C3  27 24                      BEQ   LA7E9               ; YES
A7C5  C1 88                      CMPB  #$88                ; 'ON' TOKEN
A7C7  BD A5 C9                   JSR   LA5C9               ; SYNTAX ERROR IF IT WASN'T 'ON' OR 'OFF'
A7CA  B6 FF 21          LA7CA    LDA   PIA1+1              ; READ CRA OF U4
A7CD  8A 08                      ORA   #$08                ; TURN ON BIT 3 WHICH ENABLES MOTOR DELAY
A7CF  8D 1F                      BSR   LA7F0               ; PUT IT BACK
A7D1  9E 8A             LA7D1    LDX   ZERO                ; GET READY TO WAIT A WHILE

* DELAY WHILE DECREMENTING X TO ZERO
A7D3  30 1F             LA7D3    LEAX  -1,X                ; DECREMENT X
A7D5  26 FC                      BNE   LA7D3               ; BRANCH IF NOT ZERO
A7D7  39                         RTS

* SEND SYNCLN $55'S TO TAPE
A7D8  1A 50             WRLDR    ORCC  #$50                ; DISABLE INTERRUPTS
A7DA  8D EE                      BSR   LA7CA               ; TURN ON TAPE DECK MOTOR
A7DC  9E 92                      LDX   SYNCLN              ; GET COUNT OF $55'S TO SEND
A7DE  8D 48             LA7DE    BSR   LA828               ; SEND $55 TO TAPE
A7E0  30 1F                      LEAX  -1,X                ; ARE ALL $55'S SENT?
A7E2  26 FA                      BNE   LA7DE               ; NO
A7E4  39                         RTS

* WRITE SYNC BYTES AND A BLOCK TO TAPE
A7E5  8D F1             LA7E5    BSR   WRLDR               ; WRITE SYNC BYTES TO TAPE
A7E7  8D 0B             LA7E7    BSR   SNDBLK              ; GO WRITE A BLOCK

* TURN OFF TAPE DECK MOTOR
A7E9  1C AF             LA7E9    ANDCC #$AF                ; ENABLE IRQ,FIRQ
A7EB  B6 FF 21                   LDA   PIA1+1              ; READ CRA OF U4
A7EE  84 F7                      ANDA  #$F7                ; TURN OFF BIT 3
A7F0  B7 FF 21          LA7F0    STA   PIA1+1              ; PUT IT BACK
A7F3  39                         RTS

* WRITE A BLOCK TO CASSETTE
* BUFFER SIZE IN BLKLEN
* STARTING ADDR IN CBUFAD
* BLOCK NUMBER IN BLKTYP
A7F4  1A 50             SNDBLK   ORCC  #$50                ; DISABLE IRQ,FIRQ
A7F6  D6 7D                      LDB   BLKLEN              ; GET CHAR COUNT
A7F8  D7 81                      STB   CSRERR              ; TEMP CHAR COUNT
A7FA  96 7D                      LDA   BLKLEN              ; GET CHAR COUNT (INCLUDED IN CHECKSUM)
A7FC  27 07                      BEQ   LA805               ; BRANCH IF NO CHARACTERS - NULL
A7FE  9E 7E                      LDX   CBUFAD              ; GET STARTING ADDRESS
A800  AB 80             LA800    ADDA  ,X+                 ; CHECKSUM THE BUFFER
A802  5A                         DECB                      ; DONE ALL CHARACTERS?
A803  26 FB                      BNE   LA800               ; NO
A805  9B 7C             LA805    ADDA  BLKTYP              ; ADD IN THE BLOCK NUMBER
A807  97 80                      STA   CCKSUM              ; SAVE THE CHECKSUM
A809  9E 7E                      LDX   CBUFAD              ; GET STARTING ADDRESS
A80B  8D 1B                      BSR   LA828               ; SEND $55 TO TAPE
A80D  86 3C                      LDA   #$3C                ; SYNC CHAR
A80F  8D 19                      BSR   LA82A               ; SEND TO TAPE
A811  96 7C                      LDA   BLKTYP              ; GET BLOCK NUMBER
A813  8D 15                      BSR   LA82A               ; SEND BLOCK NUMBER TO TAPE
A815  96 7D                      LDA   BLKLEN              ; GET CHARACTER COUNT
A817  8D 11                      BSR   LA82A               ; SEND CHAR COUNT TO TAPE
A819  4D                         TSTA                      ; SET FLAGS
A81A  27 08                      BEQ   LA824               ; BRANCH IF CHAR COUNT IS ZERO
A81C  A6 80             LA81C    LDA   ,X+                 ; GET BUFFER CHARACTER
A81E  8D 0A                      BSR   LA82A               ; SEND BUFFER TO TAPE
A820  0A 81                      DEC   CSRERR              ; DECR TEMP CHAR COUNT
A822  26 F8                      BNE   LA81C               ; NOT DONE YET
A824  96 80             LA824    LDA   CCKSUM              ; GET CHECKSUM
A826  8D 02                      BSR   LA82A               ; SEND CHECKSUM TO TAPE
A828  86 55             LA828    LDA   #$55                ; SEND A $55 TO TAPE

* THIS ROUTINE SENDS THE A REG TO TAPE
A82A  34 02             LA82A    PSHS  A                   ; SAVE OUTPUT CHARACTER
A82C  C6 01                      LDB   #1                  ; ACCB CONTAINS A MASK USED TO DETERMINE WHETHER A
* BIT IN THE OUTPUT CHARACTER IS HI OR LO
A82E  96 85             LA82E    LDA   CLSTSN              ; GET THE ENDING VALUE OF THE LAST SINE CYCLE
A830  B7 FF 20                   STA   DA                  ; STORE IN THE D/A CONVERTER
A833  10 8E A8 5C                LDY   #LA85C              ; SINE LOOK-UP TABLE FOR GENERATING FSK
A837  E5 E4                      BITB  ,S                  ; IS THE CURRENT BIT A ONE OR A ZERO ?
A839  26 0D                      BNE   LA848               ; IF A 1, DO HIGH FREQ
* LOW FREQUENCY LOOK UP
A83B  A6 A0             LA83B    LDA   ,Y+                 ; USE EVERY BYTE IN TABLE IF LOW FREQUENCY
A83D  10 8C A8 80                CMPY  #LA85C+36           ; END OF SINE TABLE?
A841  27 12                      BEQ   LA855               ; YES
A843  B7 FF 20                   STA   DA                  ; SEND NEXT VALUE TO D/A CONVERTER
A846  20 F3                      BRA   LA83B               ; GET NEXT VALUE
* HIGH FREQUENCY LOOK UP
A848  A6 A1             LA848    LDA   ,Y++                ; USE EVERY OTHER BYTE IF HIGH FREQUENCY
A84A  10 8C A8 80                CMPY  #LA85C+36           ; END OF SINE TABLE?
A84E  27 05                      BEQ   LA855               ; YES
A850  B7 FF 20                   STA   DA                  ; SEND NEXT VALUE TO D/A CONVERTER
A853  20 F3                      BRA   LA848               ; GET NEXT VALUE
A855  97 85             LA855    STA   CLSTSN              ; SAVE THE LAST VALUE SENT TO THE D/A CONVERTER
A857  58                         ASLB                      ; SHIFT MASK BIT LEFT
A858  24 D4                      BCC   LA82E               ; DONE WHEN MASK BIT IS SHIFTED INTO CARRY FLAG
A85A  35 82                      PULS  A,PC                ; RESTORE OUTPUT CHARACTER AND RETURN

* THIS IS A LOOK-UP TABLE OF SINE VALUES FOR THE TAPE DECK FSK
* (BIT 1 IS USED TO KEEP THE SERIAL OUTPUT MARKING)
A85C  82 92 AA BA CA DA LA85C    FCB   $82,$92,$AA,$BA,$CA,$DA
A862  EA F2 FA FA FA F2          FCB   $EA,$F2,$FA,$FA,$FA,$F2
A868  EA DA CA BA AA 92          FCB   $EA,$DA,$CA,$BA,$AA,$92
A86E  7A 6A 52 42 32 22          FCB   $7A,$6A,$52,$42,$32,$22
A874  12 0A 02 02 02 0A          FCB   $12,$0A,$02,$02,$02,$0A
A87A  12 22 32 42 52 6A          FCB   $12,$22,$32,$42,$52,$6A

* SET
A880  8D 3F             SET      BSR   LA8C1               ; 6ET ABSOLUTE SCREEN POSITION OF GRAPHICS BLOCK
A882  34 10                      PSHS  X                   ; SAVE CHARACTER LOCATION
A884  BD B7 38                   JSR   LB738               ; SYNTAX CHECK FOR COMMA - RETURN EXPR VALUE IN ACCB
A887  35 10                      PULS  X                   ; REGET CHARACTER LOCATION
A889  C1 08                      CMPB  #8                  ; NINE ALLOWABLE COLORS
A88B  22 48                      BHI   LA8D5               ; ILLEGAL COLOR - 'ILLEGAL FUNCTION CALL'
A88D  5A                         DECB                      ; CHANGE COLOR NUMBERS FROM 0-8 TO (-1 TO 7)
A88E  2B 05                      BMI   LA895               ; BRANCH IF SET (X,Y,0)
A890  86 10                      LDA   #$10                ; $10 OFFSET BETWEEN DIFFERENT COLORS
A892  3D                         MUL                       ; MULT BY COLOR FOR TOTAL OFFSET
A893  20 08                      BRA   LA89D               ; GO SAVE THE COLOR
A895  E6 84             LA895    LDB   ,X                  ; GET CURRENT CHAR FROM SCREEN
A897  2A 03                      BPL   LA89C               ; BRANCH IF NOT GRAPHIC
A899  C4 70                      ANDB  #$70                ; SAVE ONLY THE COLOR INFO
A89B  21                         FCB   SKP1                ; SKIP THE NEXT BYTE
A89C  5F                LA89C    CLRB                      ; RESET ASCII BLOCK TO ZERO COLOR
A89D  34 04                      PSHS  B                   ; SAVE COLOR INFO
A89F  8D 6C                      BSR   LA90D               ; SYNTAX CHECK FOR ')'
A8A1  A6 84                      LDA   ,X                  ; GET CURRENT CHARACTER FROM SCREEN
A8A3  2B 01                      BMI   LA8A6               ; BRANCH IF GRAPHIC
A8A5  4F                         CLRA                      ; RESET ASCII CHARACTER TO ALL PIXELS OFF
A8A6  84 0F             LA8A6    ANDA  #$0F                ; SAVE ONLY PIXEL ON/OFF INFO
A8A8  9A 86                      ORA   GRBLOK              ; 'OR' WITH WHICH PIXEL TO TURN ON
A8AA  AA E0                      ORA   ,S+                 ; 'OR' IN THE COLOR
A8AC  8A 80             LA8AC    ORA   #$80                ; FORCE GRAPHIC
A8AE  A7 84                      STA   ,X                  ; DISPLAY IT ON THE SCREEN
A8B0  39                         RTS

* RESET
A8B1  8D 0E             RESET    BSR   LA8C1               ; GET ABSOLUTE SCREEN ADDRESS OF THIS CHARACTER
A8B3  8D 58                      BSR   LA90D               ; SYNTAX CHECK FOR ")"
A8B5  4F                         CLRA                      ; * ACCA=ZERO GRAPHIC BLOCK - FOR USE IN CASE YOU'RE
; * TRYING TO RESET A NON GRAPHIC BLOCK
A8B6  E6 84                      LDB   ,X                  ; GET CURRENT CHAR FROM SCREEN
A8B8  2A F2                      BPL   LA8AC               ; BRANCH IF NON-GRAPHIC
A8BA  03 86                      COM   GRBLOK              ; INVERT PIXEL ON/OFF MASK
A8BC  D4 86                      ANDB  GRBLOK              ; AND IT WITH CURRENT ON/OFF DATA
A8BE  E7 84                      STB   ,X                  ; DISPLAY IT
A8C0  39                         RTS

*** THIS ROUTINE WILL CHECK SYNTAX AND CHECK FOR LEGAL VALUES
*** OF SET,RESET & POINT HORIZONTAL AND VERTICAL PARAMETERS
*** AND RETURN THEIR ABSOLUTE SCREEN ADDRESS IN THE X REGISTER
*** WHICH OF THE FOUR PIXELS OF THE GRAPHIC BLOCK SELECTED
*** IS RETURNED IN GRBLOK.
A8C1  BD B2 6A          LA8C1    JSR   LB26A               ; SYNTAX CHECK FOR "("
A8C4  BD 01 9D          LA8C4    JSR   RVEC21              ; HOOK INTO RAM
A8C7  BD B7 0B                   JSR   LB70B               ; EVALUATE EXPRESSION - RETURN VALUE IN ACCB
A8CA  C1 3F                      CMPB  #63                 ; ONLY 64 HORIZONTAL GRAPHIC BLOCKS
A8CC  22 07                      BHI   LA8D5               ; 'ILLEGAL FUNCTION CALL'
A8CE  34 04                      PSHS  B                   ; SAVE HOR COORD
A8D0  BD B7 38                   JSR   LB738               ; SYNTAX CHECK FOR COMMA AND EVALUATE EXPR
A8D3  C1 1F                      CMPB  #31                 ; ONLY 32 VERTICAL BLOCKS
A8D5  22 71             LA8D5    BHI   LA948               ; 'ILLEGAL FUNCTION CALL'
A8D7  34 04                      PSHS  B                   ; SAVE VERT COORD
A8D9  54                         LSRB                      ; DIVIDE BY TWO BECAUSE THERE ARE 2 GRAPHIC PIXELS/HOR
* CHARACTER POSITION (BYTE)
A8DA  86 20                      LDA   #32                 ; 32 BYTES/ROW
A8DC  3D                         MUL                       ; GET ROW OFFSET OF CHAR POSITION
A8DD  8E 04 00                   LDX   #VIDRAM             ; SCREEN BUFFER ADDRESS
A8E0  30 8B                      LEAX  D,X                 ; ADD ROW OFFSET TO SCREEN BUFFER ADDRESS
A8E2  E6 61                      LDB   1,S                 ; GET HOR COORD
A8E4  54                         LSRB                      ; 2 VERTICAL PIXELS/CHARACTER POSITION
A8E5  3A                         ABX                       ; ADD VERTICAL OFFSET TO CHARACTER ADDRESS
A8E6  35 06                      PULS  A,B                 ; GET VER COORD TO ACCA, HOR COORD TO ACCB
A8E8  84 01                      ANDA  #1                  ; KEEP ONLY LSB OF VER COORD
A8EA  56                         RORB                      ; LSB OF HOR COORD TO CARRY FLAG
A8EB  49                         ROLA                      ; LSB OF HOR TO BIT 0 OF ACCA
A8EC  C6 10                      LDB   #$10                ; MAKE A BIT MASK - TURN ON BIT 4
A8EE  54                LA8EE    LSRB                      ; SHIFT IT RIGHT ONCE
A8EF  4A                         DECA                      ; SHIFTED IT ENOUGH?
A8F0  2A FC                      BPL   LA8EE               ; NO
A8F2  D7 86                      STB   GRBLOK              ; ACCB=8 FOR UPPER LEFT PIXEL, =4 FOR UPPER RIGHT
* PIXEL =2 FOR LOWER LEFT, =1 FOR LOWER RIGHT
A8F4  39                         RTS

* POINT
A8F5  8D CD             POINT    BSR   LA8C4               ; EVALUATE EXPRESSION
A8F7  C6 FF                      LDB   #$FF                ; INITIAL VALUE OF ON/OFF FLAG = OFF (FALSE)
A8F9  A6 84                      LDA   ,X                  ; GET CURRENT GRAPHIC CHARACTER
A8FB  2A 0D                      BPL   LA90A               ; BRANCH IF NON-GRAPHIC (ALWAYS FALSE)
A8FD  94 86                      ANDA  GRBLOK              ; 'AND' CURR CHAR WITH THE PIXEL IN QUESTION
A8FF  27 08                      BEQ   LA909               ; BRANCH IF THE ELEMENT IS OFF
A901  E6 84                      LDB   ,X                  ; GET CURRENT CHARACTER
A903  54                         LSRB                      ; * SHIFT RIGHT
A904  54                         LSRB                      ; * SHIFT RIGHT
A905  54                         LSRB                      ; * SHIFT RIGHT
A906  54                         LSRB                      ; * SHIFT RIGHT - NOW THE HIGH NIBBLE IS IN THE LOW NIBBLE
A907  C4 07                      ANDB  #7                  ; KEEP ONLY THE COLOR INFO
A909  5C                LA909    INCB                      ; ACCB=0 FOR NO COLOR, =1 T0 8 OTHERWISE
A90A  BD A5 E8          LA90A    JSR   LA5E8               ; CONVERT ACCB TO FLOATING POINT
A90D  7E B2 67          LA90D    JMP   LB267               ; SYNTAX CHECK FOR ')'
