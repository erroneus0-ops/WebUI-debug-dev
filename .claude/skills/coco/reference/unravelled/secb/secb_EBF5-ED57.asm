; Super Extended Color BASIC 2.0 (CoCo 3) -- $EBF5-$ED57
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: HPAINT=$EBF5

* HPAINT
EBF5  0D E6             HPAINT   TST   HRMODE              ; CHECK HI-RES GRAPHICS MODE
EBF7  10 27 FA F4                LBEQ  LE6EF               ; 'HR' ERROR IF HI-RES GRAPHICS MODE NOT SET UP
EBFB  10 21 14 01                LBRN  RAMLINK             ; RAM HOOK
EBFF  81 40                      CMPA  #'@'                ; CHECK FOR @ SIGN
EC01  26 02                      BNE   LEC05               ; BRANCH IF NOT
EC03  9D 9F                      JSR   GETNCH              ; GET THE NEXT CHARACTER FROM BASIC'S INPUT LINE
EC05  BD EA 04          LEC05    JSR   LEA04               ; SYNTAX CHECK FOR '(', TWO EXPRESSIONS, AND ')'
EC08  BD E7 AD                   JSR   LE7AD               ; NORMALIZE THE HORIZONTAL AND VERTICAL COORDS
EC0B  86 01                      LDA   #$01                ; CODE FOR PSET
EC0D  97 C2                      STA   SETFLG              ; SET PSET/PRESET FLAG TO PSET
EC0F  BD E7 18                   JSR   LE718               ; GET PAINT COLOR CODE & SET ACTIVE COLOR AND ALL PIXEL BYTES
EC12  DC B4                      LDD   WCOLOR              ; GET THEM
EC14  34 06                      PSHS  B,A                 ; SAVE THEM ON THE STACK
EC16  9D A5                      JSR   GETCCH              ; GET BASIC'S CURRENT INPUT CHARACTER
EC18  27 03                      BEQ   LEC1D               ; BRANCH IF NONE LEFT - DEFAULT BORDER COLOR TO FOREGROUND,
; PAINT COLOR TO BACKGROUND
EC1A  BD E7 18                   JSR   LE718               ; EVALUATE THE BORDER COLOR
EC1D  96 B5             LEC1D    LDA   ALLCOL              ; GET BORDER COLOR ALL PIXEL BYTE
EC1F  97 D8                      STA   VD8                 ; TEMP SAVE IT
EC21  35 06                      PULS  A,B                 ; GET PAINT ACTIVE COLORS BACK
EC23  DD B4                      STD   WCOLOR              ; RESAVE THEM
EC25  BD E1 19                   JSR   SELTASK1
EC28  4F                         CLRA                      ; * STORE A BLOCK OF 'PAINT' DATA ON THE STACK WHICH
EC29  34 56                      PSHS  U,X,B,A             ; * WILL ACT AS AN END OF 'PAINT' DATA FLAG.
* THE CLRA WILL CAUSE THE UP/DN FLAG TO BE ZERO WHICH IS USED TO EXIT THE HPAINT ROUTINE
EC2B  BD EB 60                   JSR   LEB60               ; GET NORMALIZED MAX HOR/VERTICAL VALUES - RETURN RESULT IN VD3,VD5
EC2E  BD E7 E6                   JSR   LE7E6               ; POINT U TO THE ROUTINE WHICH WILL SELECT A PIXEL
*
* 'PAINT' THE FIRST HORIZONTAL LINE FROM THE START COORDINATES
EC31  DF D9                      STU   VD9                 ; SAVE ADDRESS
EC33  BD EC BE                   JSR   LECBE               ; 'PAINT' FROM THE CURRENT HORIZONTAL COORD TO ZERO
EC36  27 0F                      BEQ   LEC47               ; BRANCH IF NO PAINTING DONE - HIT BORDER INSTANTLY
EC38  BD ED 01                   JSR   LED01               ; PAINT TOWARD MAX HORIZONTAL COORD
EC3B  86 01                      LDA   #$01                ; SET UP/DN FLAG TO UP (1=UP, $FF=DOWN)
EC3D  97 D7                      STA   VD7                 ; SAVE IT
EC3F  BD ED 2E                   JSR   LED2E               ; SAVE POSITIVE GOING LINE INFO ON STACK
EC42  00 D7                      NEG   VD7                 ; SET UP/DN FLAG TO $FF (DOWN)
EC44  BD ED 2E                   JSR   LED2E               ; SAVE NEGATIVE GOING LINE INFO ON STACK
EC47  10 DF DC          LEC47    STS   TMPSTK              ; TEMP STORE STACK POINTER
EC4A  0D DB             LEC4A    TST   CHGFLG              ; SEE IF PAINTED COLOR IS DIFFERENT THAN THE ORIGINAL COLOR
EC4C  26 03                      BNE   LEC51               ; BRANCH IF DATA HAS BEEN MODIFIED
EC4E  10 DE DC                   LDS   TMPSTK              ; GET STACK POINTER BACK
EC51  35 56             LEC51    PULS  A,B,X,U             ; GET DATA FOR NEXT LINE SEGMENT TO CHECK FROM THE STACK
EC53  0F DB                      CLR   CHGFLG              ; CLEAR THE CHANGE FLAG
EC55  10 DF DC                   STS   TMPSTK              ; TEMP SAVE THE STACK ADDRESS
EC58  30 01                      LEAX  $01,X               ; ADD ONE TO 'START HORIZONTAL COORD -1'
EC5A  9F BD                      STX   HORBEG              ; PIT IT AT 'CURRENT HORIZONTAL COORD ADDRESS'
EC5C  DF D1                      STU   VD1                 ; SAVE LENGTH OF PARENT LINE
EC5E  97 D7                      STA   VD7                 ; SAVE UP/DN FLAG
EC60  27 58                      BEQ   LECBA               ; EXIT ROUTINE IF UP/DN FLAG = 0
EC62  2B 06                      BMI   LEC6A               ; BRANCH IF UP/DN FLAG = DOWN
* CHECK ONE LINE BELOW CURRENT DATA
EC64  5C                         INCB                      ; INCREMENT VERTICAL COORD
EC65  D1 D6                      CMPB  VD6                 ; COMPARE TO MAXIMUM VERTICAL COORD
EC67  23 05                      BLS   LEC6E               ; BRANCH IF NOT GREATER - PROCESS LINE
EC69  5F                         CLRB                      ; SET VERTICAL COORD TO ZERO TO FORCE WRAP AROUND
EC6A  5D                LEC6A    TSTB                      ; CHECK VERTICAL COORD
EC6B  27 DD                      BEQ   LEC4A               ; PROCESS ANOTHER BLOCK OF PAINT DATA IF WRAP AROUND -
; DISCARD ANY LINE BELOW VERTICAL COORD = 0 OR ABOVE MAX VER COORD
EC6D  5A                         DECB                      ; DEC VERTICAL COORD
* PROCESS A HORIZONTAL LINE THAT WAS STORED ON STACK - LIMIT CHECK HAVE BEEN DONE
EC6E  D7 C0             LEC6E    STB   VERBEG+1            ; SAVE CURRENT VERTICAL COORD
EC70  BD EC BE                   JSR   LECBE               ; PAINT FROM HORIZONTAL COORD TO ZERO OR BORDER
EC73  27 11                      BEQ   LEC86               ; BRANCH IF NO PIXELS WERE PAINTED
EC75  10 83 00 03                CMPD  #3                  ; SEE IF FEWER THAN 3 PIXELS WERE PAINTED
EC79  25 05                      BCS   LEC80               ; BRANCH IF NO NEED TO CHECK FOR PAINTABLE DATA
EC7B  30 1E                      LEAX  $-02,X              ; MOVE HORIZONTAL COORD TWO PIXELS TO THE LEFT
EC7D  BD ED 15                   JSR   LED15               ; SAVE A BLOCK OF PAINT DATA IN THE DIRECTION OPPOSITE TO UP/DN FLAG
EC80  BD ED 01          LEC80    JSR   LED01               ; CONTINUE PAINTING LINE TO THE RIGHT
EC83  BD ED 2E          LEC83    JSR   LED2E               ; SAVE A BLOCK OF PAINT DATA IN THE SAME DIRECTION AS UP/DN FLAG
* THIS CODE WILL INSURE THAT THE CURRENT LINE IS
* EXAMINED TO THE RIGHT FOR PAINTABLE PIXELS FOR A
* LINE EQUAL TO THE LENGTH OF THE PARENT LINE
EC86  43                LEC86    COMA                      ; *
EC87  53                         COMB                      ; * COMPLEMENT LENGTH OF LINE JUST PAINTED
EC88  D3 D1             LEC88    ADDD  VD1                 ; ADD TO LENGTH OF PARENT LINE
EC8A  DD D1                      STD   VD1                 ; SAVE DIFFERENCE OF LINE JUST PAINTED AND PARENT LINE
EC8C  2F 17                      BLE   LECA5               ; BRANCH IF PARENT LINE IS SHORTER
EC8E  BD E9 B1                   JSR   LE9B1               ; GO INCR HORIZONTAL COORD
EC91  BD EC F1                   JSR   LECF1               ; CHECK FOR BORDER COLOR
EC94  26 05                      BNE   LEC9B               ; BRANCH IF NOT BORDER COLOR
EC96  CC FF FF                   LDD   #-1                 ; * GO DECREMENT ONE FROM LENGTH OF DIFFERENCE
EC99  20 ED                      BRA   LEC88               ; * LINE AND KEEP LOOKING FOR NON BORDER COLOR
EC9B  BD E9 BF          LEC9B    JSR   LE9BF               ; GET DECR HORIZONTAL COORD
EC9E  BD ED 3A                   JSR   LED3A               ; GET AND SAVE HORIZONTAL COORD
ECA1  8D 24                      BSR   LECC7               ; PAINT FORWARD TO MAX HORIZONTAL COORD OR BORDER
ECA3  20 DE                      BRA   LEC83               ; SAVE BLOCK OF PAINT DATA AND KEEP CHECKING
*
* CHECK TO SEE IF THE CURRENT LINE EXTENDS FURTHER TO
* THE RIGHT THAN THE PARENT LINE AND PUT A BLOCK OF
* PAINT DATA ON THE STACK IF IT IS MORE THAN 2 PIXELS
* PAST THE END OF THE PARENT LINE
ECA5  BD E9 B1          LECA5    JSR   LE9B1               ; INC CURRENT HORIZONTAL COORD
ECA8  30 8B                      LEAX  D,X                 ; POINT X TO THE RIGHT END OF THE PARENT LINE
ECAA  9F BD                      STX   HORBEG              ; SAVE AS THE CURRENT HORIZONTAL COORDINATE
ECAC  43                         COMA                      ; = ACCA CONTAINS A NEGATIVE NUMBER CORRESPONDING TO THE NUMBER
ECAD  53                         COMB                      ; = OF PIXELS THE CURRENT LINE EXTENDS PAST THE RIGHT END
ECAE  83 00 01                   SUBD  #1                  ; = OF THE PARENT LINE. CONVERT TO POSITIVE NUMBER AND BRANCH
ECB1  2F 04                      BLE   LECB7               ; = IF THE LINE DOESN'T EXTEND PAST THE END OF THE PARENT.
ECB3  1F 01                      TFR   D,X                 ; SAVE PORTION OF THE LINE TO THE RIGHT OF THE PARENT LINE
; AS THE LENGTH
ECB5  8D 5E                      BSR   LED15               ; SAVE BLOCK OF PAINT DATA IN THE DIRECTION OPPOSITE THE
; CURRENT UP/DN FLAG
ECB7  7E EC 4A          LECB7    JMP   LEC4A               ; PROCESS MORE PAINT DATA BLOCKS
ECBA  BD E0 FF          LECBA    JSR   SELTASK0            ; ENABLE TASK REGISTER 0
ECBD  39                         RTS

* PAINT FROM HORIZONTAL COORD TO ZERO OR HIT BORDER; RETURN WITH Z=1 IF NO PAINTING DONE
ECBE  BD ED 3A          LECBE    JSR   LED3A               ; PUT STARTING COORD IN HOREND
ECC1  10 8E E9 BF                LDY   #LE9BF              ; ROUTINE TO DEC HORIZONTAL ADDRESS
ECC5  20 06                      BRA   LECCD               ; GO PAINT THE LINE
* PAINT FROM HORIZONTAL COORD TO MAX HORIZONTAL COORD OR HIT BORDER; RETURN Z=1 IF NO PAINTING DONE
ECC7  10 8E E9 B1       LECC7    LDY   #LE9B1              ; ROUTINE TO INCR HORIZONTAL COORD
ECCB  AD A4                      JSR   ,Y                  ; INCR HORIZONTAL COORD - LEFT PAINT ROUTINE PAINTED FIRST COORD
ECCD  DE 8A             LECCD    LDU   ZERO                ; ZERO INITIAL PIXEL PAINT COUNTER
ECCF  9E BD                      LDX   HORBEG              ; GET HORIZONTAL COORD
ECD1  2B 17             LECD1    BMI   LECEA               ; BRANCH IF HORIZONTAL COORD IS > $7F OR < 0
ECD3  9C D3                      CMPX  VD3                 ; COMPARE CURRENT COORD TO MAX VALUE
ECD5  22 13                      BHI   LECEA               ; BRANCH IF > MAX
ECD7  34 60                      PSHS  U,Y                 ; SAVE PAINT COUNTER AND INC/DEC POINTER
ECD9  8D 16                      BSR   LECF1               ; CHECK FOR BORDER PIXEL
ECDB  27 0B                      BEQ   LECE8               ; BRANCH IF HIT BORDER
ECDD  BD E7 92                   JSR   LE792               ; SET PIXEL TO PAINT COLOR - PAINTING IS DONE HERE
ECE0  35 60                      PULS  Y,U                 ; RESTORE PAINT COUNTER AND INC/DEC POINTER
ECE2  33 41                      LEAU  $01,U               ; ADD ONE TO PAINT COUNTER
ECE4  AD A4                      JSR   ,Y                  ; INCR OR DECR HORIZONTAL COORD DEPENDING ON CONTENTS OF Y
ECE6  20 E9                      BRA   LECD1               ; KEEP PAINTING LINE
ECE8  35 60             LECE8    PULS  Y,U                 ; RESTORE PAINT COUNTER AND INC/DEC POINTER
ECEA  1F 30             LECEA    TFR   U,D                 ; SAVE PAINT COUNTER IN ACCD
ECEC  1F 01                      TFR   D,X                 ; ALSO SAVE IT IN X
ECEE  93 8A                      SUBD  ZERO                ; SET COUNTERS ACCORDING TO CONDITION OF PAINT COUNTER
ECF0  39                         RTS
* CHECK FOR BORDER COLOR - ENTER WITH VD9 CONTAINING
* ADDRESS OF ROUTINE TO GET ABSOLUTE SCREEN ADDRESS
* AND PIXEL MASK - EXIT WITH Z=1 IF HIT BORDER COLOR PIXEL
ECF1  AD 9F 00 D9       LECF1    JSR   [VD9]               ; GET SCREEN ADDRESS AND PIXEL MASK
ECF5  1F 89                      TFR   A,B                 ; COPY PIXEL MASK IN ACCB
ECF7  D4 D8                      ANDB  VD8                 ; AND PIXEL MASK WITH BORDER COLOR
ECF9  34 06                      PSHS  B,A                 ; SAVE MASK AND BORDER PIXEL
ECFB  A4 84                      ANDA  ,X                  ; TEST THE PIXEL ON THE SCREEN
ECFD  A1 61                      CMPA  $01,S               ; COMPARE WITH ACCB ON THE STACK
ECFF  35 86                      PULS  A,B,PC              ; EXIT WITH Z FLAG=1 IF MATCH
* GO HERE TO FINISH PAINTING TO RIGHT AFTER YOU HAVE PAINTED LEFT
ED01  DD CD             LED01    STD   VCD                 ; SAVE NUMBER OF PIXELS PAINTED
ED03  10 9E C3                   LDY   HOREND              ; GET LAST HORIZONTAL START COORD
ED06  8D 32                      BSR   LED3A               ; SAVE CURRENT HORIZONTAL COORD - HOREND NOW CONTAINS COORDINATE
; OF THE LEFT BORDER OF THIS HORIZONTAL LINE
ED08  10 9F BD                   STY   HORBEG              ; START PAINTING TO RIGHT FROM THE LEFT PAINT START COORD
ED0B  8D BA                      BSR   LECC7               ; PAINT TOWARDS THE RIGHT
ED0D  9E CD                      LDX   VCD                 ; GET THE NUMBER OF PIXELS PAINTED WHEN GOING TOWARDS LEFT PIXELS
ED0F  30 8B                      LEAX  D,X                 ; ADD NUMBER OF PAINTED GOING TOWARD THE RIGHT
ED11  C3 00 01                   ADDD  #1                  ; ADD 1 TO PAINT COUNT TOWARD RIGHT - ACCD=LENGTH OF PAINTED LINE
ED14  39                         RTS
* BLOCKS OF DATA ARE STORED ON THE STACK SO THAT HPAINT
* CAN REMEMBER WHERE IT SHOULD GO BACK AND PAINT UP OR DOWN
* FROM THE CURRENT LINE IT IS PAINTING. THESE BLOCKS OF DATA
* REPRESENT HORIZONTAL LINES ABOVE OR BELOW THE CURRENT LINE
* BEING PAINTED AND REQUIRE SIX BYTES OF STORAGE ON THE STACK.
* THE DATA ARE AS FOLLOWS: ,S=UP/DN FLAG; 1,S=VERTICAL COORD
* OF LINE; 2 3,S=LEFT MOST HORIZONTAL COORD OF LINE; 4 5,S=LENGTH OF LINE

* SAVE A BLOCK OF PAINT DATA FOR A LINE IN THE OPPOSITE DIRECTION OF THE CURREN UP/DN FLAG
ED15  DD CB             LED15    STD   VCB                 ; SAVE NUMBER OF PIXELS PAINTED
ED17  35 20                      PULS  Y                   ; GET RETURN ADDRESS IN Y
ED19  DC BD                      LDD   HORBEG              ; GET HORIZONTAL START COORD
ED1B  34 16                      PSHS  X,B,A               ; PUT ON STACK
ED1D  96 D7                      LDA   VD7                 ; GET UP/DN FLAG
ED1F  40                         NEGA                      ; REVERSE IT
ED20  D6 C0             LED20    LDB   VERBEG+1            ; GET VERTICAL START COORDINATE
ED22  34 06                      PSHS  B,A                 ; SAVE VERTICAL START COORD AND UP/DN FLAG
ED24  34 20                      PSHS  Y                   ; PUT BACK RETURN ADDRESS
ED26  C6 06                      LDB   #$06                ; GET NUMBER OF FREE BYTES TO CHECK FOR
ED28  BD ED 3F                   JSR   LED3F               ; GO SEE IF THERE IS ENOUGH RAM
ED2B  DC CB                      LDD   VCB                 ; GET LENGTH OF RIGHT PAINTED LINE
ED2D  39                         RTS

* SAVE A BLOCK OF PAINT DATA FOR A LINE IN THE SAME DIRECTION AS THE CURRENT UP/DN FLAG
ED2E  DD CB             LED2E    STD   VCB                 ; SAVE THE LENGTH OF RIGHT HORIZONTAL PAINTED LINE
ED30  35 20                      PULS  Y                   ; SAVE RETURN ADDRESS IN Y
ED32  DC C3                      LDD   HOREND              ; GET HORIZONTAL START COORD
ED34  34 16                      PSHS  X,B,A               ; SAVE START COORD AND LENGTH
ED36  96 D7                      LDA   VD7                 ; GET UP/DN FLAG (1 OR -1)
ED38  20 E6                      BRA   LED20               ; SAVE THE PAINT DATA ON THE STACK
ED3A  9E BD             LED3A    LDX   HORBEG              ; GET CURRENT HORIZONTAL COORD
ED3C  9F C3                      STX   HOREND              ; SAVE IT
ED3E  39                         RTS

* CHECK ACCB (ONLY 0-127) BYTES OF FREE RAM ON THE STACK
ED3F  50                LED3F    NEGB
ED40  32 E5                      LEAS  B,S                 ; MOVE THE STACK POINTER DOWN ACCB BYTES
ED42  11 8C BF F1                CMPS  #TMPSTACK-($2000+14) ; COMPARE TO THE BOTTOM OF THE STACK AREA - THE 14 EXTRA BYTES ARE
; GENERATED BY THE FACT THAT THE SEVEN INTERRUPT VECTORS ARE GOTTEN FROM
; THE ROM BY THE GIME CHIP.  THE 14 BYTES IN RAM ARE UNUSED BY BASIC.
ED46  10 25 00 04                LBCS  LED4E               ; 'OM' ERROR IF PAST THE BOTTOM
ED4A  50                         NEGB                      ; MAKE ACCB POSITIVE AGAIN
ED4B  32 E5                      LEAS  B,S                 ; PUT THE STACK POINTER BACK WHERE IT BELONGS
ED4D  39                         RTS
ED4E  10 CE DF FD       LED4E    LDS   #TMPSTACK-2         ; PUT THE STACK POINTER AT THE TOP OF THE TEMPORARY STACK BUFFER
ED52  BD E0 FF                   JSR   SELTASK0            ; ENABLE TASK REGISTER 0
ED55  7E AC 44                   JMP   LAC44               ; GO DO AN 'OM' ERROR
