; Extended Color BASIC 1.1 -- $9546-$968A
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: COLOR=$9546, PMOD=$9621, SCREEN=$9670

* COLOR
9546  81 2C             COLOR    CMPA  #','                ; *CHECK FOR COMMA AND
9548  27 08                      BEQ   L9552               ; *BRANCH IF FOREGROUND COLOR ARGUMENT MISSING
954A  8D 0E                      BSR   L955A               ; EVALUATE FIRST ARGUMENT
954C  D7 B2                      STB   FORCOL              ; STORE IN FOREGROUND LOCATION
954E  9D A5                      JSR   GETCCH              ; GET NEXT INPUT CHARACTER
9550  27 07                      BEQ   L9559               ; RETURN IF NONE
9552  BD B2 6D          L9552    JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMMA
9555  8D 03                      BSR   L955A               ; EVALUATE LAST ARGUMENT
9557  D7 B3                      STB   BAKCOL              ; STORE IN BACKGROUND COLOR
9559  39                L9559    RTS

* EVALUATE AN EXPRESSION AND CONVERT IT TO A PROPER COLOR CODE
* DEPENDING ON THE PMODE AND CSS; ILLEGAL FUNCTION CALL IF > 8 -
* RETURN COLOR VALUE IN ACCB; CSS VALUE IN ACCA
955A  BD B7 0B          L955A    JSR   EVALEXPB            ; EVALUATE EXPRESSION
955D  C1 09             L955D    CMPB  #$09                ; ONLY ALLOW 0-8
955F  10 24 1E E7                LBCC  LB44A               ; 'ILLEGAL FUNCTION CALL' IF BAD COLOR
9563  4F                         CLRA                      ; VDG CSS VALUE FOR FIRST COLOR SET
9564  C1 05                      CMPB  #$05                ; FIRST OR SECOND COLOR SET?
9566  25 04                      BLO   L956C               ; BRANCH IF FIRST SET
9568  86 08                      LDA   #$08                ; VDG CSS VALUE FOR SECOND COLOR SET
956A  C0 04                      SUBB  #$04                ; MAKE 5-8 BECOME 1-4
956C  34 02             L956C    PSHS  A                   ; SAVE VDG CSS VALUE ON THE STACK
956E  96 B6                      LDA   PMODE               ; GET PMODE
9570  46                         RORA                      ; 4 COLOR OR 2 COLOR
9571  24 08                      BCC   L957B               ; 2 COLOR
9573  5D                         TSTB                      ; WAS COLOR = 0
9574  26 02                      BNE   L9578               ; NO
9576  C6 04             L9576    LDB   #$04                ; IF SO, MAKE IT 4
9578  5A                L9578    DECB                      ; CONVERT 1-4 TO 0-3
9579  35 82             L9579    PULS  A,PC                ; PUT VDG CSS VALUE IN ACCA AND RETURN
957B  56                L957B    RORB                      ; CHECK ONLY THE LSB OF COLOR IF IN 2 COLOR MODE
957C  25 F8                      BLO   L9576               ; BRANCH IF ODD - FORCE ACCB TO 3
957E  5F                         CLRB                      ; FORCE ACCB = 0 IF EVEN
957F  20 F8                      BRA   L9579               ; RETURN

* SET THE CURRENT ACTIVE COLOR AND ALL PIXEL BYTE
* TO FOREGROUND/BACKGROUND COLOR DEPENDING ON
* PSET, PRESET IF NO EXPRESSION , ')' OR
* ','.  OTHERWISE EVALUATE THE EXPRESSION
9581  BD 95 9A          L9581    JSR   >L959A              ; GET THE COLOR OF A BYTE
9584  9D A5                      JSR   GETCCH              ; CHECK CURRENT INPUT CHARACTER
9586  27 10                      BEQ   L9598               ; BRANCH IF NONE
9588  81 29                      CMPA  #')'                ; * CHECK FOR ')' AND BRANCH IF
958A  27 0C                      BEQ   L9598               ; * NO MORE ARGUMENTS
958C  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
958F  81 2C                      CMPA  #','                ; WAS NEXT CHARACTER A COMMA?
9591  27 05                      BEQ   L9598               ; YES
9593  BD 95 5A                   JSR   >L955A              ; EVALUATE EXPRESSION, RETURN COLOR IN ACCB
9596  8D 0A                      BSR   L95A2               ; TEMP STORE COLOR AND ALL PIXEL BYTE
9598  0E A5             L9598    JMP   GETCCH              ; CHECK INPUT CHARACTER AND RETURN

* SET THE ACTIVE COLOR BYTE AND THE ALL ACTIVE COLOR BYTE
959A  D6 B2             L959A    LDB   FORCOL              ; GET FOREGROUND COLOR
959C  0D C2                      TST   SETFLG              ; CHECK PSET/PRESET FLAG
959E  26 02                      BNE   L95A2               ; BRANCH IF PSET
95A0  D6 B3                      LDB   BAKCOL              ; GET BACKGROUND COLOR
95A2  D7 B4             L95A2    STB   WCOLOR              ; TEMP STORE COLOR
95A4  86 55                      LDA   #$55                ; CONSIDER A BYTE AS 4 PIXELS
95A6  3D                         MUL                       ; SET COLOR ON ALL 4 PIXElS
95A7  D7 B5                      STB   ALLCOL              ; SAVE BYTE WITH ALL PIXELS TURNED ON
95A9  39                         RTS
95AA  26 23             L95AA    BNE   L95CF               ; BRANCH IF GRAPHIC MODE, OTHERWISE SET UP ALPHA GRAPHIC MODE

* THIS CODE WILL RESET THE DISPLAY PAGE REGISTER IN THE
* SAM CHIP TO 2 ($400) AND RESET THE SAM'S VDG CONTROL
* REGISTER TO 0 (ALPHA-NUMERICS). IN ADDITION, IT WILL
* RESET THE VDG CONTROL PINS TO ALPHA-GRAPHICS MODE.

* SET UP THE SAM AND VDG TO GRAPHICS MODE
95AC  34 16             L95AC    PSHS  X,B,A               ; SAVE REGISTERS
95AE  8E FF C8                   LDX   #SAM+8              ; POINT X TO THE MIDDLE OF THE SAM CNTL REG
95B1  A7 0A                      STA   10,X                ; **
95B3  A7 08                      STA   $08,X               ; ***
95B5  A7 06                      STA   $06,X               ; ****
95B7  A7 04                      STA   $04,X               ; ***** RESET SAM DISPLAY PAGE TO $400
95B9  A7 02                      STA   $02,X               ; ****
95BB  A7 01                      STA   $01,X               ; ***
95BD  A7 1E                      STA   $-02,X              ; **
95BF  A7 1C                      STA   $-04,X              ; ***
95C1  A7 1A                      STA   $-06,X              ; **** RESET SAM'S VDG TO ALPHA-NUMERIC MODE
95C3  A7 18                      STA   $-08,X              ; ***
95C5  B6 FF 22                   LDA   PIA1+2              ; GET DATA FROM PIA1, PORT B
95C8  84 07                      ANDA  #$07                ; FORCE ALL BITS TO ZERO, KEEP ONLY CSS DATA
95CA  B7 FF 22                   STA   PIA1+2              ; PUT THE VDG INTO ALPHA-GRAPHICS MODE
95CD  35 96                      PULS  A,B,X,PC            ; RETURN

95CF  34 16             L95CF    PSHS  X,B,A
95D1  96 B6                      LDA   PMODE               ; GET CURRENT PMODE VALUE
95D3  8B 03                      ADDA  #$03                ; ADD 3 - NOW 3-7 ONLY 5 OF 8 POSSIBLE MODES USED
95D5  C6 10                      LDB   #$10                ; $10 OFFSET BETWEEN PMODES
95D7  3D                         MUL                       ; GET PMODE VALUES FOR VDG GM0, GM1, GM2
95D8  CA 80                      ORB   #$80                ; FORCE BIT 7 HIGH (VDG A/G CONTROL)
95DA  DA C1                      ORB   CSSVAL              ; 'OR' IN THE VDG CSS DATA
95DC  B6 FF 22                   LDA   PIA1+2              ; GET PIA1, PORT B
95DF  84 07                      ANDA  #$07                ; MASK OFF THE VDG CONTROL DATA
95E1  34 02                      PSHS  A                   ; SAVE IT
95E3  EA E0                      ORB   ,S+                 ; 'OR' IT WITH THE VDG VALUES CALCULATED ABOVE
95E5  F7 FF 22                   STB   PIA1+2              ; STORE IT INTO THE PIA
95E8  96 BA                      LDA   BEGGRP              ; GET MSB OF START OF GRAPHIC PAGE
95EA  44                         LSRA                      ; *DIVIDE BY 2 - ACCA CONTAINS HOW MANY 512 BYTE
* *BLOCKS IN STARTING ADDR
95EB  BD 96 0F                   JSR   >L960F              ; GO SET SAM CONTROL REGISTER
95EE  96 B6                      LDA   PMODE               ; GET PMODE VALUE
95F0  8B 03                      ADDA  #$03                ; ADD IN BIAS TO ADJUST TO PMODE THE SAM REGISTER WANTS
95F2  81 07                      CMPA  #$07                ; WAS PMODE 4?
95F4  26 01                      BNE   L95F7               ; NO
95F6  4A                         DECA                      ; DECREMENT ACCA IF PMODE 4 (SAME VDG AS PMODE3)
95F7  8D 02             L95F7    BSR   L95FB               ; SET THE SAM'S VDG REGISTER
95F9  35 96                      PULS  A,B,X,PC            ; RESTORE REGISTERS AND RETURN

95FB  C6 03             L95FB    LDB   #$03                ; 3 BITS IN SAM VDG CONTROL REGISTER
* ENTER WITH DATA TO GO IN VDG REGISTER IN BOTTOM 3 BITS OF ACCA
95FD  8E FF C0                   LDX   #SAM                ; POINT X TO SAM CONTROL REGISTER
9600  46                L9600    RORA                      ; PUT A BIT INTO CARRY FLAG
9601  24 04                      BCC   L9607               ; BRANCH IF BIT WAS A ZERO
9603  A7 01                      STA   $01,X               ; SET SAM REGISTER BIT
9605  20 02                      BRA   L9609               ; DO NEXT BIT
9607  A7 84             L9607    STA   ,X                  ; CLEAR SAM REGISTER
9609  30 02             L9609    LEAX  $02,X               ; NEXT BIT IN REGISTER
960B  5A                         DECB                      ; DONE ALL BITS?
960C  26 F2                      BNE   L9600               ; NO
960E  39                         RTS
960F  C6 07             L960F    LDB   #$07                ; 7 BITS IN SAM DISPLAY PAGE REGISTER
9611  8E FF C6                   LDX   #SAM+6              ; POINT X TO SAM DISPLAY PAGE REGISTER
9614  20 EA                      BRA   L9600               ; GO SET THE REGISTER
9616  B6 FF 22          L9616    LDA   PIA1+2              ; GET PIA1, PORT B
9619  84 F7                      ANDA  #$F7                ; MASK OFF VDG CSS CONTROL BIT
961B  9A C1                      ORA   CSSVAL              ; OR IN CSS COLOR DATA
961D  B7 FF 22                   STA   PIA1+2              ; RESTORE IT IN PIA1
9620  39                         RTS

* PMODE
9621  81 2C             PMOD     CMPA  #','                ; CHECK FOR COMMA - FIRST ARGUMENT MAY BE MISSING
9623  27 2B                      BEQ   L9650               ; IT IS A COMMA
9625  BD B7 0B                   JSR   EVALEXPB            ; EVALUATE EXPRESSION
9628  C1 05                      CMPB  #$05                ; > 4?
962A  24 41                      BCC   L966D               ; YES, ILLEGAL FUNCTION CALL
962C  96 BC                      LDA   GRPRAM              ; GET THE START OF GRAPHIC RAM
962E  97 BA             L962E    STA   BEGGRP              ; SET START GRAPHIC PAGE
9630  58                         ASLB                      ; MULT MODE BY 2 - TABLE HAS 2 BYTES PER ENTRY
9631  CE 97 07                   LDU   #L9706+1            ; LOOKUP TABLE
9634  AB C5                      ADDA  B,U                 ; ADD THE AMOUNT OF MEMORY REQUIRED FOR ONE GRAPHIC PAGE
9636  91 19                      CMPA  TXTTAB              ; COMPARE TO MSB OF START OF BASIC PROGRAM
9638  22 33                      BHI   L966D               ; 'FC' ERROR IF END OF GRAPHIC PAGE > START OF BASIC PROGRAM
963A  97 B7                      STA   ENDGRP              ; STORE THE END OF GRAPHIC PAGE
963C  33 5F                      LEAU  $-01,U              ; POINT U TO PREVIOUS BYTE IN TABLE
963E  A6 C5                      LDA   B,U                 ; *GET THE NUMBER OF BYTES/HORIZONTAL LINE
9640  97 B9                      STA   HORBYT              ; *AND SAVE IT IN HORBYT
9642  54                         LSRB                      ; RESTORE PMODE VALUE
9643  D7 B6                      STB   PMODE               ; SAVE IT
9645  4F                         CLRA                      ; BACKGROUND COLOR
9646  97 B3                      STA   BAKCOL              ; SET BACKGROUND COLOR TO ZERO
9648  86 03                      LDA   #$03                ; FOREGROUND COLOR
964A  97 B2                      STA   FORCOL              ; SET FOREGROUND COLOR
964C  9D A5                      JSR   GETCCH              ; IS THERE A STARTING PAGE NUMBER?
964E  27 1C                      BEQ   L966C               ; NO
9650  BD B7 38          L9650    JSR   LB738               ; EVALUATE EXPRESSION
9653  5D                         TSTB                      ; SET FLAGS
9654  27 17                      BEQ   L966D               ; 'ILLEGAL FUNCTION CALL' - CAN'T START ON PAGE ZERO
9656  5A                         DECB                      ; BUMP ONE; BASIC STARTS ON PAGE 1, THIS ROUTINE AT 0
9657  86 06                      LDA   #$06                ; EACH GRAPHIC PAGE = 6 X 256 (1.5K)
9659  3D                         MUL                       ; MULT BY PAGE NUMBER
965A  DB BC                      ADDB  GRPRAM              ; ADD IN START OF GRAPHIC RAM
965C  34 04                      PSHS  B                   ; SAVE TEMP START ADDR
965E  DB B7                      ADDB  ENDGRP              ; ADD CURRENT END ADDR
9660  D0 BA                      SUBB  BEGGRP              ; SUB OUT CURRENT START ADDR - (ADDS THE SIZE OF ONE GRAPHIC PAGE)
9662  D1 19                      CMPB  TXTTAB              ; IS IT > CURRENT START OF BASIC PROGRAM
9664  22 07                      BHI   L966D               ; YES! ILLEGAL FUNCTION CALL
9666  D7 B7                      STB   ENDGRP              ; SAVE AS END OF GRAPHIC PAGE
9668  35 04                      PULS  B                   ; GET TEMP START ADOR
966A  D7 BA                      STB   BEGGRP              ; SAVE AS START OF GRAPHIC PAGE
966C  39                L966C    RTS
966D  7E B4 4A          L966D    JMP   LB44A               ; 'ILLEGAL FUNCTION CALL'

* SCREEN
9670  81 2C             SCREEN   CMPA  #','                ; CHECK FOR A COMMA
9672  27 0B                      BEQ   L967F               ; BRANCH IF COMMA - FIRST ARGUMENT MISSING
9674  BD B7 0B                   JSR   EVALEXPB            ; EVALUATE EXPRESSION
9677  5D                         TSTB                      ; ZERO FLAG SET IF ALPHA, NOT SET IF GRAPHIC SCREEN
9678  BD 95 AA                   JSR   L95AA               ; SET UP THE SAM & VDG FOR PROPER GRAPHIC MODE
967B  9D A5                      JSR   GETCCH              ; GET NEXT CHARACTER
967D  27 ED                      BEQ   L966C               ; RETURN IF NOTHING ELSE ON LINE
967F  BD B7 38          L967F    JSR   LB738               ; CHECK FOR COMMA AND EVALUATE EXPRESSION
9682  5D                         TSTB                      ; SET FLAGS
9683  27 02                      BEQ   L9687               ; BRANCH IF COLOR SET ZERO
9685  C6 08                      LDB   #$08                ; VALUE FOR COLOR SET ONE
9687  D7 C1             L9687    STB   CSSVAL              ; SAVE IN VDG CSS RAM IMAGE
9689  20 8B                      BRA   L9616               ; GO SET IT INTO PIA
