; Color BASIC 1.2 -- $B6A0-$B763
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: ASC=$B6A0, LEFT=$B6AB, RIGHT=$B6C8, MID=$B6CF, VAL=$B716, PEEK=$B750, POKE=$B757, LLIST=$B75E

* ASC$
B6A0  8D 02             ASC      BSR   LB6A4               ; PUT 1ST CHARACTER OF STRING INTO ACCB
B6A2  20 DF                      BRA   LB683               ; CONVERT ACCB INTO FP NUMBER IN FPA0
B6A4  8D E0             LB6A4    BSR   LB686               ; POINT X TO STRING DESCRIPTOR
B6A6  27 5E                      BEQ   LB706               ; 'FC' ERROR IF NULL STRING
B6A8  E6 84                      LDB   ,X                  ; GET FIRST BYTE OF STRING
B6AA  39                         RTS

* LEFT$
B6AB  8D 48             LEFT     BSR   LB6F5               ; GET ARGUMENTS FROM STACK
B6AD  4F                         CLRA                      ; CLEAR STRING POINTER OFFSET - OFFSET = 0 FOR LEFT$
B6AE  E1 84             LB6AE    CMPB  ,X                  ; * COMPARE LENGTH PARAMETER TO LENGTH OF
B6B0  23 03                      BLS   LB6B5               ; * STRING AND BRANCH IF LENGTH OF STRING
* >= LENGTH PARAMETER
B6B2  E6 84                      LDB   ,X                  ; USE LENGTH OF STRING OTHERWISE
B6B4  4F                         CLRA                      ; CLEAR STRING POINTER OFFSET (0 FOR LEFT$)
B6B5  34 06             LB6B5    PSHS  B,A                 ; PUSH PARAMETERS ONTO STACK
B6B7  BD B5 0F                   JSR   LB50F               ; RESERVE ACCB BYTES IN THE STRING SPACE
B6BA  9E 4D                      LDX   V4D                 ; POINT X TO STRING DESCRIPTOR
B6BC  8D 9B                      BSR   LB659               ; GET ADDRESS OF OLD STRING (X=ADDRESS)
B6BE  35 04                      PULS  B                   ; * PULL STRING POINTER OFFSET OFF OF THE STACK
B6C0  3A                         ABX                       ; * AND ADD IT TO STRING ADDRESS
B6C1  35 04                      PULS  B                   ; PULL LENGTH PARAMETER OFF OF THE STACK
B6C3  BD B6 45                   JSR   LB645               ; MOVE ACCB BYTES FROM (X) TO [FRESPC]
B6C6  20 D5                      BRA   LB69D               ; PUT TEMP STRING DESCRIPTOR ONTO THE STRING STACK

* RIGHT$
B6C8  8D 2B             RIGHT    BSR   LB6F5               ; GET ARGUMENTS FROM STACK
B6CA  A0 84                      SUBA  ,X                  ; ACCA=LENGTH PARAMETER - LENGTH OF OLD STRING
B6CC  40                         NEGA                      ; NOW ACCA = LENGTH OF OLD STRING
B6CD  20 DF                      BRA   LB6AE               ; PUT NEW STRING IN THE STRING SPACE

* MID$
B6CF  C6 FF             MID      LDB   #$FF                ; * GET DEFAULT VALUE OF LENGTH AND
B6D1  D7 53                      STB   FPA0+3              ; * SAVE IT IN FPA0
B6D3  9D A5                      JSR   GETCCH              ; GET CURRENT CHARACTER FROM BASIC
B6D5  81 29                      CMPA  #')                 ; ARGUMENT DELIMITER?
B6D7  27 05                      BEQ   LB6DE               ; YES - NO LENGTH PARAMETER GIVEN
B6D9  BD B2 6D                   JSR   LB26D               ; SYNTAX CHECK FOR COMMA
B6DC  8D 2D                      BSR   LB70B               ; EVALUATE NUMERIC EXPRESSION (LENGTH)
B6DE  8D 15             LB6DE    BSR   LB6F5               ; GET ARGUMENTS FROM STACK
B6E0  27 24                      BEQ   LB706               ; 'FC' ERROR IF NULL STRING
B6E2  5F                         CLRB                      ; CLEAR LENGTH COUNTER (DEFAULT VALUE)
B6E3  4A                         DECA                      ; *SUOTRACT ONE FROM POSITION PARAMETER (THESE
B6E4  A1 84                      CMPA  ,X                  ; *ROUTINES EXPECT 1ST POSITION TO BE ZERO, NOT ONE)
* *AND COMPARE IT TO LENGTH OF OLD STRING
B6E6  24 CD                      BCC   LB6B5               ; IF POSITION > LENGTH OF OLD STRING, THEN NEW
* STRING WILL BE A NULL STRING
B6E8  1F 89                      TFR   A,B                 ; SAVE ABSOLUTE POSITION PARAMETER IN ACCB
B6EA  E0 84                      SUBB  ,X                  ; ACCB=POSITION-LENGTH OF OLD STRING
B6EC  50                         NEGB                      ; NOW ACCB=LENGTH OF OLDSTRING-POSITION
B6ED  D1 53                      CMPB  FPA0+3              ; *IF THE AMOUNT OF OLD STRING TO THE RIGHT OF
B6EF  23 C4                      BLS   LB6B5               ; *POSITION IS <= THE LENGTH PARAMETER, BRANCH AND
*USE ALL OF THE STRING TO THE RIGHT OF THE POSITION
*INSTEAD OF THE LENGTH PARAMETER
B6F1  D6 53                      LDB   FPA0+3              ; GET LENGTH OF NEW STRING
B6F3  20 C0                      BRA   LB6B5               ; PUT NEW STRING IN STRING SPACE
* DO A SYNTAX CHECK FOR ")", THEN PULL THE PREVIOUSLY CALCULATED NUMERIC
* ARGUMENT (ACCD) AND STRING ARGUMENT DESCRIPTOR ADDR OFF OF THE STACK
B6F5  BD B2 67          LB6F5    JSR   LB267               ; SYNTAX CHECK FOR A ")"
B6F8  EE E4                      LDU   ,S                  ; LOAD THE RETURN ADDRESS INTO U REGISTER
B6FA  AE 65                      LDX   5,S                 ; * GET ADDRESS OF STRING AND
B6FC  9F 4D                      STX   V4D                 ; * SAVE IT IN V4D
B6FE  A6 64                      LDA   4,S                 ; = PUT LENGTH OF STRING IN
B700  E6 64                      LDB   4,S                 ; = BOTH ACCA AND ACCB
B702  32 67                      LEAS  7,S                 ; REMOVE DESCRIPTOR AND RETURN ADDRESS FROM STACK
B704  1F 35                      TFR   U,PC                ; JUMP TO ADDRESS IN U REGISTER
B706  7E B4 4A          LB706    JMP   LB44A               ; 'ILLEGAL FUNCTION CALL'
* EVALUATE AN EXPRESSION - RETURN AN INTEGER IN
* ACCB - 'FC' ERROR IF EXPRESSION > 255
B709  9D 9F             LB709    JSR   GETNCH              ; GET NEXT BASIC INPUT CHARACTER
B70B  BD B1 41          LB70B    JSR   LB141               ; EVALUATE A NUMERIC EXPRESSION
B70E  BD B3 E9          LB70E    JSR   LB3E9               ; CONVERT FPA0 TO INTEGER IN ACCD
B711  4D                         TSTA                      ; TEST MS BYTE OF INTEGER
B712  26 F2                      BNE   LB706               ; 'FC' ERROR IF EXPRESSION > 255
B714  0E A5                      JMP   GETCCH              ; GET CURRENT INPUT CHARACTER FROM BASIC

* VAL
B716  BD B6 86          VAL      JSR   LB686               ; POINT X TO STRING ADDRESS
B719  10 27 03 1C                LBEQ  LBA39               ; IF NULL STRING SET FPA0
B71D  DE A6                      LDU   CHARAD              ; SAVE INPUT POINTER IN REGISTER U
B71F  9F A6                      STX   CHARAD              ; POINT INPUT POINTER TO ADDRESS OF STRING
B721  3A                         ABX                       ; MOVE POINTER TO END OF STRING TERMINATOR
B722  A6 84                      LDA   ,X                  ; GET LAST BYTE OF STRING
B724  34 52                      PSHS  U,X,A               ; SAVE INPUT POINTER, STRING TERMINATOR
* ADDRESS AND CHARACTER
B726  6F 84                      CLR   ,X                  ; CLEAR STRING TERMINATOR : FOR ASCII - FP CONVERSION
B728  9D A5                      JSR   GETCCH              ; GET CURRENT CHARACTER FROM BASIC
B72A  BD BD 12                   JSR   LBD12               ; CONVERT AN ASCII STRING TO FLOATING POINT
B72D  35 52                      PULS  A,X,U               ; RESTORE CHARACTERS AND POINTERS
B72F  A7 84                      STA   ,X                  ; REPLACE STRING TERMINATOR
B731  DF A6                      STU   CHARAD              ; RESTORE INPUT CHARACTER
B733  39                         RTS

B734  8D 07             LB734    BSR   LB73D               ; * EVALUATE AN EXPRESSION, RETURN
B736  9F 2B                      STX   BINVAL              ; * THE VALUE IN X; STORE IT IN BINVAL
B738  BD B2 6D          LB738    JSR   LB26D               ; SYNTAX CHECK FOR A COMMA
B73B  20 CE                      BRA   LB70B               ; EVALUATE EXPRESSION IN RANGE 0 <= X < 256
* EVALUATE EXPRESSION : RETURN INTEGER PORTION IN X - 'FC' ERROR IF
* EXPRESSION IS NEGATIVE OR > 32767, I.E. NOT A LEGAL POSITIVE INTEGER.
B73D  BD B1 41          LB73D    JSR   LB141               ; EVALUATE NUMERIC EXPRESSION
B740  96 54             LB740    LDA   FP0SGN              ; GET SIGN OF FPA0 MANTISSA
B742  2B C2                      BMI   LB706               ; 'ILLEGAL FUNCTION CALL' IF NEGATIVE
B744  96 4F                      LDA   FP0EXP              ; GET EXPONENT OF FPA0
B746  81 90                      CMPA  #$90                ; COMPARE TO LARGEST POSITIVE INTEGER
B748  22 BC                      BHI   LB706               ; 'ILLEGAL FUNCTION CALL' IF TOO LARGE
B74A  BD BC C8                   JSR   LBCC8               ; SHIFT BINARY POINT TO EXTREME RIGHT OF FPA0
B74D  9E 52                      LDX   FPA0+2              ; LOAD X WITH LOWER TWO BYTES OF FPA0
B74F  39                         RTS

* PEEK
B750  8D EE             PEEK     BSR   LB740               ; CONVERT FPA0 TO INTEGER IN REGISTER X
B752  E6 84                      LDB   ,X                  ; GET THE VALUE BEING 'PEEK'ED
B754  7E B4 F3                   JMP   LB4F3               ; CONVERT ACCB INTO A FP NUMBER

* POKE
B757  8D DB             POKE     BSR   LB734               ; EVALUATE 2 EXPRESSIONS
B759  9E 2B                      LDX   BINVAL              ; GET THE ADDRESS TO BE 'POKE'ED
B75B  E7 84                      STB   ,X                  ; STORE THE DATA IN THAT ADDRESS
B75D  39                         RTS

* LLIST
B75E  C6 FE             LLIST    LDB   #-2                 ; * SET DEVICE NUMBER TO
B760  D7 6F                      STB   DEVNUM              ; * PRINTER
B762  9D A5                      JSR   GETCCH              ; GET CURRENT CHARACTER FROM BASIC
