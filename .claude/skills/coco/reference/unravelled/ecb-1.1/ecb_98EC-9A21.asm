; Extended Color BASIC 1.1 -- $98EC-$9A21
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: PAINT=$98EC

* PAINT
98EC  81 40             PAINT    CMPA  #'@'                ; CHECK FOR @ SIGN
98EE  26 02                      BNE   L98F2               ; SKIP IF NOT
98F0  9D 9F                      JSR   GETNCH              ; READ A CHARACTER FROM BASIC INPUT LINE
98F2  BD 93 B2          L98F2    JSR   L93B2               ; *SYNTAX CHECK FOR '(', TWO EXPRESSION, AND ')'.
* *SAVE HOR COORD IN HORSES, VER COORD IN VERSES
98F5  BD 93 1D                   JSR   L931D               ; NORMALIZE THE HOR, VER COORDINATES
98F8  86 01                      LDA   #$01                ; PSET VALUE
98FA  97 C2                      STA   SETFLG              ; SET PSET/PRESET FLAG TO PSET
98FC  BD 95 81                   JSR   L9581               ; GET PAINT COLOR CODE & SET THE ACTIVE COLOR AND ALL PIXEL BYTES
98FF  DC B4                      LDD   WCOLOR              ; GET THEM
9901  34 06                      PSHS  B,A                 ; SAVE THEM ON STACK
9903  9D A5                      JSR   GETCCH              ; GET CURRENT CHARACTER FROM INPUT LINE
9905  27 03                      BEQ   L990A               ; BRANCH IF NONE LEFT - DEFAULT BORDER COLOR TO FOREGROUND,
; PAINT COLOR TO BACKGROUND
9907  BD 95 81                   JSR   L9581               ; EVALUATE THE BORDER COLOR
990A  96 B5             L990A    LDA   ALLCOL              ; GET BORDER COLOR ALL PIXEL BYTE
990C  97 D8                      STA   VD8                 ; TEMP SAVE IT
990E  35 06                      PULS  A,B                 ; GET PAINT ACTIVE COLORS BACK
9910  DD B4                      STD   WCOLOR              ; RESAVE IT
9912  4F                         CLRA                      ; * STORE A BLOCK OF 'PAINT' DATA ON THE STACK WHICH
9913  34 56                      PSHS  U,X,B,A             ; * WILL ACT AS AN END OF 'PAINT' DATA FLAG.
* *THE CLRA WILL CAUSE THE UP/DN FLAG TO BE ZERO WHICH IS
* *USED AS A FLAG TO EXIT THE 'PAINT' ROUTINE
9915  BD 95 22                   JSR   L9522               ; GET NORMALIZED MAX HOR/VER VALUES - RETURN RESULT IN VD3, VD5
9918  BD 92 8F                   JSR   L928F               ; POINT U TO THE ROUTINE WHICH WILL SELECT A PIXEL
*
* 'PAINT' THE FIRST HORIZONTAL LINE FROM THE START COORDINATES
991B  DF D9                      STU   VD9                 ; SAVE IT
991D  BD 99 DF                   JSR   L99DF               ; 'PAINT' FROM CURRENT HOR COORD TO ZERO
9920  27 0F                      BEQ   L9931               ; BRANCH IF NO PAINTING DONE - HIT BORDER INSTANTLY
9922  BD 99 CB                   JSR   L99CB               ; 'PAINT' TOWARD MAX HOR COORD
9925  86 01                      LDA   #$01                ; *
9927  97 D7                      STA   VD7                 ; * UP/DN FLAG UP=1; DOWN=$FF
9929  BD 99 BA                   JSR   L99BA               ; SAVE POSITIVE GOING LINE INFO ON STACK
992C  00 D7                      NEG   VD7                 ; SET UP/ON FLAG = FF
992E  BD 99 BA                   JSR   L99BA               ; SAVE NEGATIVE GOING LINE INFO ON STACK
9931  10 DF DC          L9931    STS   TMPSTK              ; TEMP STORE STACK POINTER
9934  0D DB             L9934    TST   CHGFLG              ; SEE IF 'PAINTED' COLOR IS DIFFERENT THAN ORIGINAL COLOR
9936  26 03                      BNE   L993B               ; BRANCH IF DATA HAS BEEN MODIFIED
9938  10 DE DC                   LDS   TMPSTK              ; GET STACK POINTER BACK
993B  35 56             L993B    PULS  A,B,X,U             ; GET DATA FOR THE NEXT LINE SEGMENT TO CHECK FROM THE STACK
993D  0F DB                      CLR   CHGFLG              ; CLEAR CHANGE FLAG
993F  10 DF DC                   STS   TMPSTK              ; TEMP SAVE STACK
9942  30 01                      LEAX  $01,X               ; ADD ONE TO 'START HOR COORD - 1'
9944  9F BD                      STX   HORBEG              ; PUT IT AT 'CURRENT HOR COORD ADDR'
9946  DF D1                      STU   VD1                 ; 'LENGTH OF PARENT LINE'
9948  97 D7                      STA   VD7                 ; SAVE 'UP/DN FLAG'
994A  27 9F                      BEQ   L98EB               ; EXIT ROUTINE IF UP/DN FLAG = 0
994C  2B 06                      BMI   L9954               ; BRANCH IF UP/DN FLAG = DOWN
* CHECK LINE BELOW CURRENT DATA
994E  5C                         INCB                      ; INCREMENT VER COORD
994F  D1 D6                      CMPB  VD6                 ; COMPARE TO MAXIMUM VER COORD
9951  23 05                      BLS   L9958               ; BRANCH IF NOT GREATER - PROCESS LINE
9953  5F                         CLRB                      ; SET VER COORD TO ZERO TO FORCE WRAP AROUND
9954  5D                L9954    TSTB                      ; TEST VER COORD
9955  27 DD                      BEQ   L9934               ; *PROCESS ANOTHER BLOCK OF 'PAINT' DATA IF
* *WRAP AROUND - DISCARD ANY LINE BELOW
* *VER COORD = 0 OR ABOVE MAX VERTICAL COORD
9957  5A                         DECB                      ; DEC VER COORD - WE ARE TESTING UP/DN FLAG = UP IF THERE
* PROCESS A HOR LINE THAT WAS STORED ON STACK - LIMIT CHECKS HAVE BEEN DONE
9958  D7 C0             L9958    STB   VERBEG+1            ; SAVE CURRENT VER COORD
995A  BD 99 DF                   JSR   L99DF               ; PAINT FROM HOR COORD TO ZERO OR BORDER
995D  27 0F                      BEQ   L996E               ; IF NUMBER OF PAINTED PIXELS = 0, COMPLEMENT LENGTH
995F  10 83 00 03                CMPD  #3                  ; *SEE IF < 3 PIXELS WERE PAINTED - IF FEWER THAN
* *THREE PIXELS WERE PAINTED THEN THERE IS NO NEED TO
* *CHECK FOR MORE DATA TO 'PAINT' ON THE LINE TO THE
* *LEFT OF THE CURRENT POSITION IN THE OPPOSITE
* *DIRECTION THAT THE UP/DN FLAG IS CURRENTLY SET TO
9963  25 04                      BLO   L9969               ; BRANCH IF NO NEED TO CHECK FOR 'PAINTABLE' DATA
9965  30 1E                      LEAX  $-02,X              ; MOVE THE HORIZONTAL COORDINATE TWO PIXELS TO THE LEFT
9967  8D 38                      BSR   L99A1               ; *SAVE A BLOCK OF 'PAINT' DATA IN THE DIRECTION
* *OPPOSITE TO THE 'UP/DN' FLAG
9969  BD 99 CB          L9969    JSR   >L99CB              ; CONTINUE PAINTING LINE TO THE RIGHT
996C  8D 4C             L996C    BSR   L99BA               ; *SAVE A BLOCK OF PAINT DATA IN THE SAME
* *DIRECTION AS THE 'UP/DN' FLAG
*
* THIS CODE WILL INSURE THAT THE CURRENT LINE IS
* EXAMINED TO THE RIGHT FOR 'PAINTABLE' PIXELS FOR
* A LENGTH EQUAL TO THE LENGTH OF THE 'PARENT' LINE
996E  43                L996E    COMA                      ; *
996F  53                         COMB                      ; * COMPLEMENT LENGTH OF LINE JUST PAINTED
9970  D3 D1             L9970    ADDD  VD1                 ; ADD TO LENGTH OF 'PARENT LINE'
9972  DD D1                      STD   VD1                 ; SAVE DIFFERENCE OF LINE JUST PAINTED AND PARENT LINE
9974  2F 16                      BLE   L998C               ; BRANCH IF PARENT LINE IS SHORTER
9976  BD 95 06                   JSR   L9506               ; GO INC HOR COORD
9979  BD 9A 12                   JSR   L9A12               ; CHECK FOR BORDER COLOR
997C  26 05                      BNE   L9983               ; NOT BORDER COLOR -
997E  CC FF FF                   LDD   #-1                 ; * GO DECREMENT ONE FROM LENGTH OF DIFFERENCE
9981  20 ED                      BRA   L9970               ; * LINE AND KEEP LOOKING FOR NON BORDER COLOR
9983  BD 95 14          L9983    JSR   L9514               ; GO DEC HOR COORD
9986  8D 3E                      BSR   L99C6               ; GET AND SAVE HOR COORD
9988  8D 5E                      BSR   L99E8               ; PAINT FORWARD TO MAX HOR COORD OR BORDER
998A  20 E0                      BRA   L996C               ; SAVE A BLOCK OF 'PAINT' DATA AND KEEP CHECKING
*
* CHECK TO SEE IF THE CURRENT LINE EXTENDS FURTHER TO
* THE RIGHT THAN THE PARENT LINE AND PUT A BLOCK OF
* PAINT DATA ON THE STACK IF IT IS MORE THAN 2 PIXELS
* PAST THE END OF THE PARENT LINE
998C  BD 95 06          L998C    JSR   L9506               ; INC CURRENT HOR COORD
998F  30 8B                      LEAX  D,X                 ; * POINT X TO THE RIGHT END OF THE 'PARENT' LINE
9991  9F BD                      STX   HORBEG              ; * AND SAVE IT AS THE CURRENT HORIZ COORDINATE
9993  43                         COMA                      ; = ACCD CONTAINS A NEGATIVE NUMBER CORRESPONDING TO
9994  53                         COMB                      ; = THE NUMBER OF PIXELS THE CURRENT LINE EXTENDS
9995  83 00 01                   SUBD  #1                  ; = PAST THE RIGHT END OF THE 'PARENT' LINE. CONVERT
9998  2F 04                      BLE   L999E               ; = TO A POSITIVE NUMBER AND BRANCH IF THE LINE DOESN'T EXTEND
999A  1F 01                      TFR   D,X                 ; *SAVE THE PORTION OF THE LINE TO THE RIGHT OF THE PARENT LINE
* *AS THE LENGTH
999C  8D 03                      BSR   L99A1               ; =SAVE A BLOCK OF 'PAINT' DATA IN THE DIRECTION OPPOSITE THE
* =CURRENT UP/DN FLAG
999E  7E 99 34          L999E    JMP   >L9934              ; PROCESS MORE 'PAINT' DATA BLOCKS
*
* BLOCKS OF PAINT DATA ARE STORED ON THE STACK SO THAT PAINT
* CAN 'REMEMBER' WHERE IT SHOULD GO BACK TO PAINT UP OR DOWN
* FROM THE CURRENT LINE IT IS PAINTING. THESE BLOCKS OF DATA
* REPRESENT HORIZONTAL LINES ABOVE OR BELOW THE CURRENT LINE
* BEING PAINTED AND REQUIRE SIX BYTES OF STORAGE ON THE STACK.
* THE DATA ARE STORED AS FOLLOWS: ,S=UP/DOWN FLAG; 1,S=VER COORD
* OF LINE; 2 3,S=LEFTMOST HOR COORD OF LINE; 4 5,S=LENGTH OF LINE

* SAVE A BLOCK OF 'PAINT' DATA FOR A LINE IN THE
* OPPOSITE DIRECTION OF THE CURRENT UP/DN FLAG
99A1  DD CB             L99A1    STD   VCB                 ; SAVE NUMBER PIXELS PAINTED
99A3  35 20                      PULS  Y                   ; PUT RETURN ADDR IN Y
99A5  DC BD                      LDD   HORBEG              ; GET HORIZONTAL START COORDINATE
99A7  34 16                      PSHS  X,B,A               ; PUT ON STACK
99A9  96 D7                      LDA   VD7                 ; GET U/D FLAG
99AB  40                         NEGA                      ; REVERSE THE UP/DN FLAG
99AC  D6 C0             L99AC    LDB   VERBEG+1            ; GET VERTICAL START COORDINATE
99AE  34 06                      PSHS  B,A                 ; SAVE VERTICAL START COORDINATE AND U/D FLAG
99B0  34 20                      PSHS  Y                   ; PUT RETURN ADDR BACK ON STACK

* CODE BELOW CHECKS FOR ABILITY TO STORE FOUR BYTES IN
* FREE RAM, HOWEVER THE PAINT ROUTINE WILL STORE SIX
* BYTES IN FREE RAM - FIRST INSTRUCTION SHOULD BE LDB #3
99B2  C6 02                      LDB   #$02                ; * CHECK TO SEE IF THERE'S ENOUGH FREE
99B4  BD AC 33                   JSR   LAC33               ; * RAM FOR 4 BYTES TEMP STORAGE
99B7  DC CB                      LDD   VCB                 ; GET LENGTH OF RIGHT PAINTED LINE
99B9  39                         RTS
*
* SAVE A BLOCK OF 'PAINT' DATA FOR A LINE IN
* THE SAME DIRECTION AS THE CURRENT UP/DN FLAG
99BA  DD CB             L99BA    STD   VCB                 ; SAVE LENGTH OF RIGHT HOR PAINTED LINE
99BC  35 20                      PULS  Y                   ; SAVE RETURN ADDRESS IN Y
99BE  DC C3                      LDD   HOREND              ; HORIZONTAL START COORDINATE
99C0  34 16                      PSHS  X,B,A               ; SAVE HORIZONTAL START COORDINATE AND LENGTH
99C2  96 D7                      LDA   VD7                 ; GET UP/DOWN FLAG (1 OR -1)
99C4  20 E6                      BRA   L99AC               ; SAVE THE 'PAINT' DATA ON THE STACK
99C6  9E BD             L99C6    LDX   HORBEG              ; GET CURRENT HOR COORD
99C8  9F C3                      STX   HOREND              ; SAVE IT
99CA  39                         RTS
* GO HERE TO FINISH PAINTING TO RIGHT AFTER YOU HAVE PAINTED TO THE LEFT
99CB  DD CD             L99CB    STD   VCD                 ; SAVE COUNT OF THE NUMBER OF PIXELS 'PAINTED'
99CD  10 9E C3                   LDY   HOREND              ; GET LAST HOR START COORD
99D0  8D F4                      BSR   L99C6               ; *SAVE CURRENT HOR COORD - NOW HOREND CONTAINS COORDINATE
* *THE LEFT BORDER OF THIS HORIZONTAL LINE
99D2  10 9F BD                   STY   HORBEG              ; START PAINTING TO RIGHT FROM THE LEFT PAINT START COORD
99D5  8D 11                      BSR   L99E8               ; PAINT TOWARDS THE RIGHT
99D7  9E CD                      LDX   VCD                 ; GET THE NUMBER OF PIXELS PAINTED WHEN GOING TOWARDS LEFT PIXELS
99D9  30 8B                      LEAX  D,X                 ; ADD TO NUMBER PAINTED GOING TOWARD RIGHT
99DB  C3 00 01                   ADDD  #1                  ; ADD 1 TO PAINT COUNT TOWARD RIGHT - ACCD = LENGTH OF PAINTED LINE
*
99DE  39                         RTS
* PAINT FROM HOR COORD TO ZERO OR HIT BORDER
* RETURN WITH Z = 1 IF NO PAINTING DONE
99DF  BD 99 C6          L99DF    JSR   >L99C6              ; PUT STARTING HOR COORD IN HOREND
99E2  10 8E 95 14                LDY   #L9514              ; (DECR HOR COORD ADDRESS) TO Y
99E6  20 06                      BRA   L99EE               ; GO PAINT THE LINE
* PAINT FROM HOR COORD TO MAX HOR COORD OR HIT
* BORDER-RETURN Z=1 IF NO PAINTING DONE
99E8  10 8E 95 06       L99E8    LDY   #L9506              ; PUT INCR HOR COORD ADDR IN Y
99EC  AD A4                      JSR   ,Y                  ; INCR HOR COORD - THE LEFT PAINT ROUTINE PAINTED THE FIRST COORD
99EE  DE 8A             L99EE    LDU   ZERO                ; ZERO U REG - INITIAL PIXEL PAINT COUNTER
99F0  9E BD                      LDX   HORBEG              ; GET HOR COORD
99F2  2B 17             L99F2    BMI   L9A0B               ; BRANCH IF HORIZONTAL COORDINATE IS > $7F OR < 0
99F4  9C D3                      CMPX  VD3                 ; COMPARE CURRENT HOR COORD TO MAX VALUE
99F6  22 13                      BHI   L9A0B               ; BRANCH IF > MAX
99F8  34 60                      PSHS  U,Y                 ; SAVE PAINT COUNTER, INC/DEC POINTER
99FA  8D 16                      BSR   L9A12               ; CHECK FOR BORDER PIXEL
99FC  27 0B                      BEQ   L9A09               ; HIT BOROER
99FE  BD 93 77                   JSR   L9377               ; SET PIXEL TO 'PAINT' COLOR - PAINTING IS DONE HERE
9A01  35 60                      PULS  Y,U                 ; RESTORE PAINT COUNTER AND INC/DEC POINTER
9A03  33 41                      LEAU  $01,U               ; ADD ONE TO PAINT COUNTER
9A05  AD A4                      JSR   ,Y                  ; INCR OR DECR HOR COORD DEPENDING ON CONTENTS OF Y
9A07  20 E9                      BRA   L99F2               ; KEEP PAINTING THE LINE
9A09  35 60             L9A09    PULS  Y,U                 ; RESTORE PAINT COUNTER AND INC/DEC POINTER
9A0B  1F 30             L9A0B    TFR   U,D                 ; SAVE PAINT COUNTER IN ACCD
9A0D  1F 01                      TFR   D,X                 ; SAVE PAINT COUNTER IN X
9A0F  93 8A                      SUBD  ZERO                ; SET FLAGS ACCDRDING TO CONDITION OF PAINT COUNTER
9A11  39                         RTS
* CHECK FOR BORDER COLOR - ENTER W/VD9 CONTAINING
* ADDRESS OF ROUTINE TO GET ABS SCREEN ADDRESS
* AND PIXEL MASK - EXIT WITH Z = 1 IF HIT BORDER COLOR PIXEL
9A12  AD 9F 00 D9       L9A12    JSR   [VD9]               ; GET THE ADDR AND PIXEL MASK
9A16  1F 89                      TFR   A,B                 ; COPY PIXEL MASK TO ACCB
9A18  D4 D8                      ANDB  VD8                 ; AND PIXEL MASK W/BORDER COLOR; ACCB = ONE PIXEL OF BORDER COLOR
9A1A  34 06                      PSHS  B,A                 ; PUSH MASK AND BORDER PIXEL
9A1C  A4 84                      ANDA  ,X                  ; * PUT CURRENT PIXEL DATA INTO ACCB AND
9A1E  A1 61                      CMPA  $01,S               ; * COMPARE IT TO BORDER COLOR; Z FLAG = 1 IF MATCH
9A20  35 86                      PULS  A,B,PC              ; RESTORE MASK AND BORDER PIXEL - THEN RETURN
