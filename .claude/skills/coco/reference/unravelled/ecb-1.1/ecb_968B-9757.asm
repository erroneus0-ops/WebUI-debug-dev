; Extended Color BASIC 1.1 -- $968B-$9757
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: PCLEAR=$968B, PCOPY=$9723, GET=$9755

* PCLEAR
968B  BD B7 0B          PCLEAR   JSR   EVALEXPB            ; EVALUATE EXPRESSION, RETURN VALUE IN ACCB
968E  5D                         TSTB                      ; SET FLAGS
968F  27 DC                      BEQ   L966D               ; BRANCH IF PCLEAR0 - 'FC' ERROR
9691  C1 09                      CMPB  #$09                ; TRYING TO CLEAR MORE THAN 8 PAGES?
9693  24 D8                      BCC   L966D               ; YES 'ILLEGAL FUNCTION CALL'
9695  86 06                      LDA   #$06                ; 6 X 256 (1.5K) PER GRAPHIC PAGE
9697  3D                         MUL                       ; MULT BY NUMBER OF PAGES
9698  DB BC                      ADDB  GRPRAM              ; ADD IN START OF GRAPHIC RAM
969A  1F 98                      TFR   B,A                 ; MOVE B TO MSB OF REG ACCD
969C  C6 01                      LDB   #$01                ; REG D NOW CONTAINS TOP OF PCLEARED SPACE +1
969E  1F 02                      TFR   D,Y                 ; SAVE IN Y
96A0  10 93 B7                   CMPD  ENDGRP              ; COMPARE TOP OF PCLEARED SPACE TO END OF CURRENT GRAPHIC PAGE
* THIS CODE REFLECTS THE INFAMOUS PCLEAR BUG
96A3  25 C8                      BLO   L966D               ; 'FC' ERROR IF TRYING TO CLEAR < END OF GRAPHIC RAM
96A5  93 19                      SUBD  TXTTAB              ; SUBTRACT START OF BASIC PROGRAM
96A7  D3 1B                      ADDD  VARTAB              ; ADD END OF BASIC PROGRAM
96A9  1F 01                      TFR   D,X                 ; X=TOP OF PCLEARED SPACE + LENGTH OF BASIC PROGRAM
96AB  4C                         INCA                      ; ADD 256 - LEAVE SOME ROOM FOR THE STACK
96AC  93 21                      SUBD  FRETOP              ; SUBTRACT OUT TOP OF CLEARED SPACE
96AE  24 BD                      BCC   L966D               ; 'FC' ERROR - NO ROOM LEFT
96B0  BD 80 D0                   JSR   L80D0               ; ADJUST BASIC'S INPUT POINTER
96B3  12                         NOP                       ; SPACE FILLER FOR EXBAS 1.1
96B4  DE 1B                      LDU   VARTAB              ; GET END OF BASIC PROGRAM
96B6  9F 1B                      STX   VARTAB              ; STORE NEW END OF BASIC PROGRAM
96B8  11 93 1B                   CMPU  VARTAB              ; COMPARE OLD END TO NEW END
96BB  24 17                      BCC   L96D4               ; BRANCH IF OLD END > NEW END
96BD  A6 C2             L96BD    LDA   ,-U                 ; GET BYTE FROM OLD PROGRAM
96BF  A7 82                      STA   ,-X                 ; MOVE TO NEW PROGRAM LOCATION
96C1  11 93 19                   CMPU  TXTTAB              ; AT THE BEGINNING OF OLD PROGRAM?
96C4  26 F7                      BNE   L96BD               ; NO
96C6  10 9F 19                   STY   TXTTAB              ; SAVE NEW STARTING ADDRESS
96C9  6F 3F                      CLR   $-01,Y              ; CLEAR BYTE JUST BEFORE PROGRAM
96CB  BD AC EF          L96CB    JSR   LACEF               ; PUT CORRECT ADDRESSES IN FIRST 2 BYTES OF EACH LINE
96CE  BD AD 26                   JSR   LAD26               ; DO PART OF A NEW
96D1  7E AD 9E                   JMP   LAD9E               ; GO BACK TO BASIC'S MAIN LOOP
96D4  DE 19             L96D4    LDU   TXTTAB              ; GET START OF BASIC PROGRAM
96D6  10 9F 19                   STY   TXTTAB              ; STORE NEW STARTING ADDR
96D9  6F 3F                      CLR   $-01,Y              ; CLEAR THE BYTE JUST BEFORE PROGRAM
96DB  A6 C0             L96DB    LDA   ,U+                 ; GET BYTE FROM OLD PROGRAM
96DD  A7 A0                      STA   ,Y+                 ; MOVE TO NEW PROG LOCATION
96DF  10 9C 1B                   CMPY  VARTAB              ; AT END OF OLD PROGRAM?
96E2  26 F7                      BNE   L96DB               ; NO
96E4  20 E5                      BRA   L96CB               ; GO RESET SOME POINTERS

* INITIALIZATION ROUTINE FOR EXBAS GRAPHICS VARIABLES
96E6  C6 1E             L96E6    LDB   #$1E                ; *
96E8  D7 19                      STB   TXTTAB              ; * SET START OF BASIC PROG TO 1E00
96EA  86 06                      LDA   #$06                ; =
96EC  97 BC             L96EC    STA   GRPRAM              ; =CONSTANT OFFSET OF $600
96EE  97 BA                      STA   BEGGRP              ; START OF GRAPHICS PAGE TO $600
96F0  4F                         CLRA                      ; PMODE = 0
96F1  97 B6                      STA   PMODE               ; SET PMODE TO 0
96F3  86 10                      LDA   #$10                ; 16 BYTES/HOR GRAPHIC ROW
96F5  97 B9                      STA   HORBYT              ; SAVE IT
96F7  86 03                      LDA   #$03                ; SET FOREGROUND COLOR TO 3
96F9  97 B2                      STA   FORCOL              ; SET FOREGROUND COLOR TO 3
96FB  86 0C                      LDA   #$0C                ; *
96FD  97 B7                      STA   ENDGRP              ; * SET END OF GRAPHICS PAGE TO $C00
96FF  9E 19                      LDX   TXTTAB              ; GET START OF PROGRAM
9701  6F 1F                      CLR   $-01,X              ; CLEAR ONE BYTE JUST BEFORE PROGRAM
9703  7E AD 19                   JMP   LAD19               ; GO DO A 'NEW'

* TABLE OF HOW MANY BYTES/GRAPHIC ROW AND HOW MUCH RAM
* FOR ONE HI RES SCREEN FOR THE PMODES. ROWS FIRST,
* BYTES (IN 256 BYTE BLOCKS) SECOND.
9706  10 06             L9706    FCB   $10,$06             ; PMODE 0
9708  20 0C             L9708    FCB   $20,$0C             ; PMODE 1
970A  10 0C             L970A    FCB   $10,$0C             ; PMODE 2
970C  20 18             L970C    FCB   $20,$18             ; PMODE 3
970E  20 18             L970E    FCB   $20,$18             ; PMODE 4

* CALC ABS(VEREND - VERBEG)
9710  DC C5             L9710    LDD   VEREND              ; GET VERTICAL ENDING ADDRESS
9712  93 BF                      SUBD  VERBEG              ; SUBTRACT OUT VERTICAL BEGINNING ADDRESS
9714  24 3B             L9714    BCC   L9751               ; RETURN IF END >= START
9716  34 01                      PSHS  CC                  ; SAVE STATUS (WHICH COORDINATE IS GREATER)
9718  BD 9D C3                   JSR   L9DC3               ; NEGATE ACCD IF START COORD > END COORD
971B  35 81                      PULS  CC,PC               ; RESTORE STATUS AND RETURN
* CALC ABS(HOREND - HORBEG)
971D  DC C3             L971D    LDD   HOREND              ; GET HORIZONTAL END COORD
971F  93 BD                      SUBD  HORBEG              ; SUB OUT HORIZONTAL START COORD
9721  20 F1                      BRA   L9714               ; GET ABSOLUTE VALUE

* PCOPY
9723  8D 1A             PCOPY    BSR   L973F               ; *EVALUATE SOURCE PAGE NUMBER AND RETURN MSB OF
* *ADDRESS OF START OF PAGE IN ACCD
9725  34 06                      PSHS  B,A                 ; SAVE PAGE 1 OFFSET
9727  C6 A5                      LDB   #$A5                ; TOKEN FOR 'TO'
9729  BD B2 6F                   JSR   LB26F               ; SYNTAX CHECK FOR 'TO'
972C  8D 11                      BSR   L973F               ; EVALUATE PAGE NUMBER
972E  35 10                      PULS  X                   ; SET ADDRESS OF SOURCE PAGE TO X
9730  1F 03                      TFR   D,U                 ; ADDRESS OF DESTINATION PAGE TO U
9732  10 8E 03 00                LDY   #$300               ; MOVE $300 PAIRS OF BYTES (ONE GRAPHIC PAGE)
9736  EC 81             L9736    LDD   ,X++                ; GET TWO BYTES FROM SOURCE
9738  ED C1                      STD   ,U++                ; PUT INTO DESTINATION PAGE
973A  31 3F                      LEAY  $-01,Y              ; DECREMENT COUNTER
973C  26 F8                      BNE   L9736               ; NOT DONE YET
973E  39                         RTS

973F  BD B7 0B          L973F    JSR   EVALEXPB            ; EVALUATE EXPRESSION
9742  5D                         TSTB                      ; PAGE ZERO?
9743  27 0D                      BEQ   L9752               ; YES - 'ILLEGAL FUNCTION CALL'

* THIS IS A FLAKEY ERROR CHECK - IT WILL LET YOU PCOPY OVER
* THE TOP OF THE BASIC PROGRAM IN SOME INSTANCES.
9745  D1 19                      CMPB  TXTTAB              ; IS PAGE NUMBER > MSB OF START ADDR OF BASIC PROG?
9747  22 09                      BHI   L9752               ;  'FC' ERROR IF SO - BAD ERROR CHECK
9749  5A                         DECB                      ; *BUMP PAGE NUMBER DOWN 1, BASIC STARTS AT 1, THIS
* *ROUTINE STARTS AT ZERO
974A  86 06                      LDA   #$06                ; 6*256 (1.5K) PER GRAPHIC PAGE
974C  3D                         MUL                       ; GET OFFSET OF THIS PAGE NUMBER
974D  DB BC                      ADDB  GRPRAM              ; *GET START OF GRAPHIC RAM- ACCB NOW CONTAINS
* *MSB OF ADDRESS OF THIS PAGE
974F  1E 89                      EXG   A,B                 ; NON ACCD HAS ADDRESS OF PAGE START
9751  39                L9751    RTS
9752  7E B4 4A          L9752    JMP   LB44A               ; 'ILLEGAL FUNCTION CALL'

* GET
9755  5F                GET      CLRB                      ; 'GET' FLAG
9756  20 02                      BRA   L975A               ; THIS SHOULD BE FCB SKP2 - IT WOULD SAVE A BYTE
