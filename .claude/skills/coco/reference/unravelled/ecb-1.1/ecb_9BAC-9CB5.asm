; Extended Color BASIC 1.1 -- $9BAC-$9CB5
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: (none -- local labels only)

* EVALUATE THE >,<,+,-,= OPERATORS - ENTER WITH THE VALUE TO
* BE OPERATED ON IN ACCB, RETURN NEW VALUE IN SAME
9BAC  8D EA             L9BAC    BSR   L9B98               ; GET A COMMAND CHARACTER
9BAE  81 2B                      CMPA  #'+'                ; ADD ONE?
9BB0  27 3C                      BEQ   L9BEE               ; YES
9BB2  81 2D                      CMPA  #'-'                ; SUBTRACT ONE?
9BB4  27 3C                      BEQ   L9BF2               ; YES
9BB6  81 3E                      CMPA  #'>'                ; MULTIPLY BY TWO?
9BB8  27 42                      BEQ   L9BFC               ; YES
9BBA  81 3C                      CMPA  #'<'                ; DIVIDE BY TWO?
9BBC  27 39                      BEQ   L9BF7               ; YES
9BBE  81 3D             L9BBE    CMPA  #'='                ; *CHECK FOR VARIABLE EQUATE - BRANCH IF SO; ACCB WILL BE
9BC0  27 3F                      BEQ   L9C01               ; *SET TO THE VALUE OF THE BASIC VARIABLE IN THE COMMAND
* *STRING WHICH MUST BE NUMERIC, LESS THAN 256
* *AND THE VARIABLE MUST BE FOLLOWED BY A SEMICOLON.
9BC2  BD 90 AA                   JSR   L90AA               ; CLEAR CARRY IF NUMERIC
9BC5  25 24                      BLO   L9BEB               ; 'FC' ERROR IF NON NUMERIC
9BC7  5F                         CLRB                      ; UNITS DIGIT = 0
* STRIP A DECIMAL ASCII VALUE OFF OF THE COMMAND STRING
* AND RETURN BINARY VALUE IN ACCB
9BC8  80 30             L9BC8    SUBA  #'0'                ; MASK OFF ASCII
9BCA  97 D7                      STA   VD7                 ; SAVE VALUE TEMPORARILY
9BCC  86 0A                      LDA   #10                 ; BASE 10
9BCE  3D                         MUL                       ; MULT BY DIGIT
9BCF  4D                         TSTA                      ; *
9BD0  26 19                      BNE   L9BEB               ; *'FC' ERROR IF RESULT > 255
9BD2  DB D7                      ADDB  VD7                 ; GET TEMPORARY VALUE
9BD4  25 15                      BLO   L9BEB               ; 'FC' ERROR IF RESULT > 255
9BD6  0D D8                      TST   VD8                 ; *
9BD8  27 17                      BEQ   L9BF1               ; * RETURN IF NO COMMANDS LEFT
9BDA  BD 9B 98                   JSR   >L9B98              ; GET ANOTHER COMMAND
9BDD  BD 90 AA                   JSR   L90AA               ; CLEAR CARRY IF NUMERIC
9BE0  24 E6                      BCC   L9BC8               ; BRANCH IF MORE NUMERIC DATA
9BE2  0C D8             L9BE2    INC   VD8                 ; *ADD ONE TO COMMAND COUNTER AND
9BE4  9E D9                      LDX   VD9                 ; *MOVE COMMAND STRING BACK ONE
9BE6  30 1F                      LEAX  $-01,X              ; *
9BE8  9F D9                      STX   VD9                 ; *
9BEA  39                         RTS
9BEB  7E B4 4A          L9BEB    JMP   LB44A               ; 'FC' ERROR
9BEE  5C                L9BEE    INCB                      ; ADD ONE TO PARAMETER
9BEF  27 FA                      BEQ   L9BEB               ; 'FC' ERROR IF ADDING 1 TO 255
9BF1  39                L9BF1    RTS
9BF2  5D                L9BF2    TSTB                      ; *
9BF3  27 F6                      BEQ   L9BEB               ; *'FC' ERROR IF TRYING TO DECREMENT 0
9BF5  5A                         DECB                      ; SUBTRACT ONE FROM PARAMETER
9BF6  39                         RTS
9BF7  5D                L9BF7    TSTB                      ; *
9BF8  27 F1                      BEQ   L9BEB               ; *'FC' ERROR IF DIVIDING BY ZERO
9BFA  54                         LSRB                      ; DIVIDE BY TWO
9BFB  39                         RTS
9BFC  5D                L9BFC    TSTB                      ; *
9BFD  2B EC                      BMI   L9BEB               ; *'FC' ERROR IF RESULT WOULD BE > 255
9BFF  58                         ASLB                      ; MULTIPLY BY TWO
9C00  39                         RTS
9C01  34 60             L9C01    PSHS  U,Y                 ; SAVE U,Y REGISTERS
9C03  8D 16                      BSR   L9C1B               ; INTERPRET COMMAND STRING AS IF IT WERE A BASIC VARIABLE
9C05  BD B7 0E                   JSR   LB70E               ; CONVERT FPA0 TO AN INTEGER VALUE IN ACCB
9C08  35 E0                      PULS  Y,U,PC              ; RESTORE U,Y REGISTERS AND RETURN
9C0A  BD 9C 1B          L9C0A    JSR   >L9C1B              ; EVALUATE AN EXPRESSION IN THE COMMAND STRING
9C0D  C6 02                      LDB   #2                  ; =
9C0F  BD AC 33                   JSR   LAC33               ; =ROOM FOR 4 BYTES ON STACK?
9C12  D6 D8                      LDB   VD8                 ; * GET THE CURRENT COMMAND LENGTH AND POINTER AND
9C14  9E D9                      LDX   VD9                 ; * SAVE THEM ON THE STACK
9C16  34 14                      PSHS  X,B                 ; *
9C18  7E 9A 32                   JMP   L9A32               ; GO INTERPRET AND PROCESS THE NEW 'PLAY' SUB COMMAND

* INTERPRET THE PRESENT COMMAND STRING AS IF IT WERE A BASIC VARIABLE
9C1B  9E D9             L9C1B    LDX   VD9                 ; GET COMMAND POINTER
9C1D  34 10                      PSHS  X                   ; SAVE IT
9C1F  BD 9B 98                   JSR   L9B98               ; GET A COMMAND CHARACTER
9C22  BD B3 A2                   JSR   LB3A2               ; SET CARRY IF NOT ALPHA
9C25  25 C4                      BLO   L9BEB               ; 'FC' ERROR IF NOT ALPHA - ILLEGAL VARIABLE NAME
9C27  BD 9B 98          L9C27    JSR   L9B98               ; GET A COMMAND CHARACTER
9C2A  81 3B                      CMPA  #';'                ; CHECK FOR SEMICOLON - COMMAND SEPARATOR
9C2C  26 F9                      BNE   L9C27               ; BRANCH UNTIL FOUND
9C2E  35 10                      PULS  X                   ; GET SAVED COMMAND POINTER
9C30  DE A6                      LDU   CHARAD              ; GET BASIC'S INPUT POINTER
9C32  34 40                      PSHS  U                   ; SAVE IT
9C34  9F A6                      STX   CHARAD              ; PUT PLAY COMMAND POINTER IN PLACE OF BASIC'S INPUT POINTER
9C36  BD B2 84                   JSR   LB284               ; EVALUATE AN ALPHA EXPRESSION P GET NEW STRING DESCRIPTOR
9C39  35 10                      PULS  X                   ; * RESTORE BASIC'S INPUT POINTER
9C3B  9F A6                      STX   CHARAD              ; *
9C3D  39                         RTS

* MORE OF EXTENDED BASIC'S IRQ ROUTINE

9C3E  4F                L9C3E    CLRA                      ; CLEAR ACCA
9C3F  1F 8B                      TFR   A,DP                ; SET THE DIRECT PAGE TO ZERO
9C41  DC E3                      LDD   PLYTMR              ; GET THE 'PLAY' TIMER
9C43  10 27 0D 74                LBEQ  LA9BB               ; BRANCH TO COLOR BASIC'S IRQ ROUTINE IF ZERO
9C47  93 D5                      SUBD  VD5                 ; SUBTRACT OUT 'PLAY' INTERVAL
9C49  DD E3                      STD   PLYTMR              ; SAVE THE NEW TIMER VALUE
9C4B  22 0D                      BHI   L9C5A               ; BRANCH IF 'PLAY' COMMAND NOT DONE
9C4D  0F E3                      CLR   PLYTMR              ; RESET MSB OF 'PLAY' TIMER IF DONE
9C4F  0F E4                      CLR   PLYTMR+1            ; RESET LSB OF 'PLAY' TIMER
9C51  35 02                      PULS  A                   ; GET THE CONDITION CODE REG
9C53  10 EE 67                   LDS   $07,S               ; *LOAD THE STACK POINTER WITH THE CONTENTS OF THE U REGISTER
* *WHICH WAS STACKED WHEN THE INTERRUPT WAS HONORED.
9C56  84 7F                      ANDA  #$7F                ; CLEAR E FLAG - MAKE COMPUTER THINK THIS WAS AN FIRQ
9C58  34 02                      PSHS  A                   ; SAVE CONDITION CODE

* THE RTI WILL NOW NOT RETURN TO WHERE IT WAS
* INTERRUPTED FROM - IT WILL RETURN TO THE MAIN 'PLAY'
* COMMAND INTERPRETATION LOOP.

9C5A  3B                L9C5A    RTI                       ; RETURN

* TABLE OF NUMERICAL NOTE VALUES FOR LETTER NOTES
9C5B  0A 0C 01 03 05 06 L9C5B    FCB   10,12,1,3,5,6,8     ; NOTES A,B,C,D,E,F,G
9C61  08

* TABLE OF DELAYS FOR OCTAVE 1
9C62  01 A8 01 90 01 7A L9C62    FDB   $01A8,$0190,$017A   ; DELAYS FOR OCTAVE 1
9C68  01 64 01 50 01 3D          FDB   $0164,$0150,$013D
9C6E  01 2B 01 1A 01 0A          FDB   $012B,$011A,$010A
9C74  00 FB 00 ED 00 DF          FDB   $00FB,$00ED,$00DF

* TABLE OF DELAYS FOR OCTAVE 2
9C7A  00 D3 00 C7 00 BB L9C7A    FDB   $00D3,$00C7,$00BB   ; DELAYS FOR OCTAVE 2
9C80  00 B1 00 A6 00 9D          FDB   $00B1,$00A6,$009D
9C86  00 94 00 8B 00 83          FDB   $0094,$008B,$0083
9C8C  00 7C 00 75 00 6E          FDB   $007C,$0075,$006E

* TABLE OF DELAYS FOR OCTAVES 3,4,5
9C92  A6 9C 93 8B 83 7B L9C92    FCB   $A6,$9C,$93,$8B,$83,$7B ; DELAYS FOR OCTAVES 3,4,5
9C98  74 6D 67 61 5B 56          FCB   $74,$6D,$67,$61,$5B,$56
9C9E  51 4C 47 43 3F 3B          FCB   $51,$4C,$47,$43,$3F,$3B
9CA4  37 34 31 2E 2B 28          FCB   $37,$34,$31,$2E,$2B,$28
9CAA  26 23 21 1F 1D 1B          FCB   $26,$23,$21,$1F,$1D,$1B
9CB0  19 18 16 14 13 12          FCB   $19,$18,$16,$14,$13,$12
