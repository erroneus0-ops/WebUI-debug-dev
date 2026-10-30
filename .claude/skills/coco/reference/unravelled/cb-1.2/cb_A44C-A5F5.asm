; Color BASIC 1.2 -- $A44C-$A5F5
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: CSAVE=$A44C, CLOAD=$A498, EXEC=$A53E, INKEY=$A564, EOF=$A5CE, SKIPF=$A5EC

* CSAVE
A44C  BD A5 78          CSAVE    JSR   LA578               ; GO SCAN OFF NAME
A44F  9D A5                      JSR   GETCCH              ; GET CURRENT CHARACTER IN THE BASIC LINE
A451  27 16                      BEQ   LA469               ; BRANCH IF NONE
A453  BD B2 6D                   JSR   LB26D               ; SYNTAX ERROR IF NOT COMMA
A456  C6 41                      LDB   #'A                 ; IS THIS AN ASCII SAVE?
A458  BD B2 6F                   JSR   LB26F               ; SYNTAX ERROR IF NOT 'A'
A45B  26 EE                      BNE   LA44B               ; RETURN IF NOT END OF LINE
A45D  4F                         CLRA                      ; FILE TYPE = 0
A45E  BD A6 5C                   JSR   LA65C               ; WRITE OUT HEADER BLOCK
A461  86 FF                      LDA   #-1                 ; CASSETTE CODE
A463  97 6F                      STA   DEVNUM              ; SET DEVICE NUMBER TO CASSETTE
A465  4F                         CLRA                      ; CLEAR CARRY - FORCE LIST TO BEGIN AT PROGRAM START
A466  7E B7 64                   JMP   LIST                ; GO DO A 'LIST' TO CASSETTE

* NON-ASCII CSAVE
A469  4F                LA469    CLRA                      ; FILE TYPE = 0
A46A  9E 8A                      LDX   ZERO                ; ZERO OUT ASCII FLAG AND FILE MODE
A46C  BD A6 5F                   JSR   LA65F               ; WRITE HEADER BLOCK
A46F  0F 78                      CLR   FILSTA              ; CLOSE FILES
A471  0C 7C                      INC   BLKTYP              ; INCREMENT BLOCK NUMBER
A473  BD A7 D8                   JSR   WRLDR               ; WRITE 55'S TO CASSETTE
A476  9E 19                      LDX   TXTTAB              ; ADDRESS OF PROGRAM START
A478  9F 7E             LA478    STX   CBUFAD              ; STORE CURRENT BLOCK START ADDR
A47A  86 FF                      LDA   #255                ; 255 BYTE BLOCKS
A47C  97 7D                      STA   BLKLEN              ; BLOCK SIZE
A47E  DC 1B                      LDD   VARTAB              ; END OF PROGRAM
A480  93 7E                      SUBD  CBUFAD              ; CURRENT BLOCK STARTING ADDR
A482  27 0D                      BEQ   LA491               ; BRANCH IF IT CAME OUT EXACT
A484  10 83 00 FF                CMPD  #255                ; MORE THAN 255 BYTES LEFT?
A488  24 02                      BHS   LA48C               ; YES
A48A  D7 7D                      STB   BLKLEN              ; USE ACTUAL BLOCK SIZE IF LESS THAN 255
A48C  BD A7 F4          LA48C    JSR   SNDBLK              ; WRITE BLOCK TO CASSETTE
A48F  20 E7                      BRA   LA478               ; DO ANOTHER BLOCK
A491  00 7C             LA491    NEG   BLKTYP              ; MAKE BLOCK NUMBER NEGATIVE (EOF BLOCK)
A493  0F 7D                      CLR   BLKLEN              ; ZERO BLOCK SIZE
A495  7E A7 E7                   JMP   LA7E7               ; WRITE A BLOCK, TURN OFF MOTOR

* CLOAD
A498  0F 78             CLOAD    CLR   FILSTA              ; CLOSE FILES
A49A  81 4D                      CMPA  #'M                 ; IS IT CLOADM?
A49C  27 60                      BEQ   LA4FE               ; BRANCH IF SO
A49E  32 62                      LEAS  2,S                 ; GET RID OF THE RETURN
A4A0  BD A5 C5                   JSR   LA5C5               ; GO GET FILE NAME
A4A3  BD A6 48                   JSR   LA648               ; SEARCH FOR FILE
A4A6  7D 01 E4                   TST   CASBUF+10           ; GET FILE MODE (NON-ZERO=DATA OR ASCII)
A4A9  27 1D                      BEQ   LA4C8               ; ZERO = CRUNCHED BASIC OR MACHINE LANG
A4AB  B6 01 E3                   LDA   CASBUF+9            ; GET ASCII FLAG
A4AE  27 1D                      BEQ   LA4CD               ; 'BAD FILE NODE' 0 = CRUNCHED OR MACH LANG
A4B0  BD AD 19                   JSR   LAD19               ; DO A 'NEW'
A4B3  86 FF                      LDA   #-1                 ; TAPE DEVICE NUMBER
A4B5  97 6F                      STA   DEVNUM              ; SET DEVICE NUMBER TO TAPE
A4B7  0C 78                      INC   FILSTA              ; FILE TYPE = INPUT
A4B9  BD A6 35                   JSR   LA635               ; GO LOAD ASCII RECORD
A4BC  7E AC 7C                   JMP   LAC7C               ; GO LOAD AND CRUNCH INPUT

* COME HERE FROM BASIC'S DIRECT LOOP IF CONSOLE
* IN BUFFER EMPTY
A4BF  BD 01 85          LA4BF    JSR   RVEC13              ; HOOK INTO RAM
A4C2  BD A4 2D                   JSR   LA42D               ; CLOSE ACTIVE FILE
A4C5  7E AC 73                   JMP   LAC73               ; GO TO BASIC'S DIRECT LOOP

* CLOAD A CRUNCHED BASIC
A4C8  B6 01 E2          LA4C8    LDA   CASBUF+8            ; FILE TYPE
A4CB  27 03                      BEQ   LA4D0               ; ZERO IS CSAVE TYPE
A4CD  7E A6 16          LA4CD    JMP   LA616               ; 'BAD FILE MODE' IF NOT BASIC FILE
A4D0  BD AD 19          LA4D0    JSR   LAD19               ; DO A 'NEW'
A4D3  BD A7 7C                   JSR   CASON               ; TURN ON TAPE, START READING
A4D6  9E 19                      LDX   TXTTAB              ; GET START OF PROGRAM ADDRESS
A4D8  9F 7E             LA4D8    STX   CBUFAD              ; STORE IT IN LOAD BUFFER
A4DA  DC 7E                      LDD   CBUFAD              ; GET START ADDRESS TO D REG
A4DC  4C                         INCA                      ; ADD 256 TO LOAD ADDRESS
A4DD  BD AC 37                   JSR   LAC37               ; SEE IF ROOM BELOW STACK FOR ONE BLOCK
A4E0  BD A7 0B                   JSR   GETBLK              ; READ A BLOCK
A4E3  26 13                      BNE   LA4F8               ; GOT AN ERROR DURING READ
A4E5  96 7C                      LDA   BLKTYP              ; BLOCK NUMBER
A4E7  27 0F                      BEQ   LA4F8               ; I/O ERROR IF HEADER BLOCK TYPE
A4E9  2A ED                      BPL   LA4D8               ; REAR MORE IF BLOCK NUMBER POSITIVE
A4EB  9F 1B                      STX   VARTAB              ; SET END OF PROGRAM ADDRESS
A4ED  8D 4C                      BSR   LA53B               ; TURN OFF TAPE DECK
A4EF  8E AB EC                   LDX   #LABED-1            ; POINT TO 'OK' MESSAGE
A4F2  BD B9 9C                   JSR   LB99C               ; PRINT 'OK' TO CONSOLE OUT
A4F5  7E AC E9                   JMP   LACE9               ; RESET INPUT POINTER, CLEAR VARIABLES AND
* RETURN TO MAIN LOOP OF BASIC

A4F8  BD AD 19          LA4F8    JSR   LAD19               ; DO A 'NEW'
A4FB  7E A6 19          LA4FB    JMP   LA619               ; 'I/O ERROR'

* CLOADM
A4FE  9D 9F             LA4FE    JSR   GETNCH              ; GET NEXT CHARACTER IN BASIC LINE
A500  8D 76                      BSR   LA578               ; GO SCAN OFF NAME
A502  BD A6 48                   JSR   LA648               ; SEARCH FOR FILE
A505  9E 8A                      LDX   ZERO                ; STORE ZERO TO X REG, DEFAULT OFFSET VALUE
A507  9D A5                      JSR   GETCCH              ; CHECK FOR AN OFFSET
A509  27 06                      BEQ   LA511               ; BRANCH IF NO OFFSET
A50B  BD B2 6D                   JSR   LB26D               ; SYNTAX CHECK FOR COMMA
A50E  BD B7 3D                   JSR   LB73D               ; EVALUATE OFFSET; RETURN VALUE IN X
A511  B6 01 E2          LA511    LDA   CASBUF+8            ; CHECK FILE MODE
A514  81 02                      CMPA  #2                  ; IS IT MACHINE LANGUAGE?
A516  26 B5                      BNE   LA4CD               ; 'BAD FILE MODE' ERROR IF NOT
A518  FC 01 E5                   LDD   CASBUF+11           ; GET TRANSFER ADDR FROM TAPE
A51B  33 8B                      LEAU  D,X                 ; ADD OFFSET
A51D  DF 9D                      STU   EXECJP              ; STORE TRANSFER ADDR IN EXEC ARGUMENT
A51F  7D 01 E4                   TST   CASBUF+10           ; CHECK FILE MODE
A522  26 A9                      BNE   LA4CD               ; 'BAD FILE MODE' ERROR
A524  FC 01 E7                   LDD   CASBUF+13           ; GET LOAD ADDR FROM TAPE
A527  30 8B                      LEAX  D,X                 ; ADD OFFSET
A529  9F 7E                      STX   CBUFAD              ; STORE IN BUFFER START ADDRESS POINTER
A52B  BD A7 7C                   JSR   CASON               ; START UP TAPE
A52E  BD A7 0B          LA52E    JSR   GETBLK              ; READ A BLOCK
A531  26 C8                      BNE   LA4FB               ; BRANCH IF I/O ERROR
A533  9F 7E                      STX   CBUFAD              ; STORE NEW START ADDR (ONE BLOCK HIGHER)
A535  0D 7C                      TST   BLKTYP              ; CHECK BLOCK NUMBER
A537  27 C2                      BEQ   LA4FB               ; BRANCH IF I/O ERROR (HEADER BLOCK)
A539  2A F3                      BPL   LA52E               ; GO READ SOME MORE
A53B  7E A7 E9          LA53B    JMP   LA7E9               ; GO TURN OFF TAPE DECK

* EXEC
A53E  27 05             EXEC     BEQ   LA545               ; BRANCH IF NO ARGUMENT
A540  BD B7 3D                   JSR   LB73D               ; EVALUATE ARGUMENT - ARGUMENT RETURNED IN X
A543  9F 9D                      STX   EXECJP              ; STORE X TO EXEC JUMP ADDRESS
A545  6E 9F 00 9D       LA545    JMP   [EXECJP]            ; GO DO IT

* BREAK CHECK
A549  BD 01 7F          LA549    JSR   RVEC11              ; HOOK INTO RAM
A54C  96 6F                      LDA   DEVNUM              ; GET DEVICE NUMBER
A54E  4C                         INCA                      ; CHECK FOR TAPE
A54F  27 50                      BEQ   LA5A1               ; RETURN IF TAPE
A551  7E AD EB                   JMP   LADEB               ; GO DO BREAK KEY CHECK

* THIS ROUTINE EVALUATES AN ARGUMENT
* AND MAKES SURE IT IS WITHIN LIMITS OF VIDEO DISPLAY RAM
A554  BD B3 E4          LA554    JSR   LB3E4               ; EVALUATE EXPRESSION AND RETURN VALUE IN ACCD
A557  83 01 FF                   SUBD  #511                ; ONLY 512 VIDEO DISPLAY LOCATIONS
A55A  10 22 0E EC                LBHI  LB44A               ; BRANCH IF > 511 TO 'ILLEGAL FUNCTION CALL'
A55E  C3 05 FF                   ADDD  #VIDRAM+511         ; ADD BACK IN OFFSET + START OF VIDEO RAM
A561  DD 88                      STD   CURPOS              ; PUT THE CURSOR THERE
A563  39                         RTS

* INKEY$
A564  96 87             INKEY    LDA   IKEYIM              ; WAS A KEY DOWN IN THE BREAK CHECK?
A566  26 03                      BNE   LA56B               ; YES
A568  BD A1 CB                   JSR   KEYIN               ; GO GET A KEY
A56B  0F 87             LA56B    CLR   IKEYIM              ; CLEAR INKEY RAM IMAGE
A56D  97 53                      STA   FPA0+3              ; STORE THE KEY IN FPA0
A56F  10 26 11 1C                LBNE  LB68F               ; CONVERT FPA0+3 TO A STRING
A573  97 56                      STA   STRDES              ; SET LENGTH OF STRING = 0 IF NO KEY DOWN
A575  7E B6 9B                   JMP   LB69B               ; PUT A NULL STRING ONTO THE STRING STACK

* STRIP A FILENAME OFF OF THE BASIC INPUT LINE
A578  8E 01 D1          LA578    LDX   #CFNBUF             ; POINT TO FILE NAME BUFFER
A57B  6F 80                      CLR   ,X+                 ; CLEAR THE FIRST BYTE - IT WILL CONTAIN THE COUNT
* OF THE NUMBER OF CHARACTERS IN THE NAME
A57D  86 20                      LDA   #SPACE              ; SPACE
A57F  A7 80             LA57F    STA   ,X+                 ; BLANK FILL 8 CHARS
A581  8C 01 DA                   CMPX  #CASBUF             ; DONE?
A584  26 F9                      BNE   LA57F               ; NO
A586  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHAR
A588  27 17                      BEQ   LA5A1               ; RETURN IF NO NAME
A58A  BD B1 56                   JSR   LB156               ; GET THE FILE NAME - EVALUATE EXPRESSION
A58D  BD B6 54                   JSR   LB654               ; POINT X TO START OF NAME (TOP STRING ON STRING STACK)
A590  CE 01 D1                   LDU   #CFNBUF             ; CASSETTE FILE NAME BUFFER
A593  E7 C0                      STB   ,U+                 ; STORE THE NUMBER OF BYTES IN THE NAME
A595  27 0A                      BEQ   LA5A1               ; NULL NAME (BLANK NAME)
A597  8C                         FCB   SKP2                ; SKIP THE NEXT TWO BYTES
A598  C6 08             LA598    LDB   #8                  ; MOVE 8 BYTES

* MOVE ACCB BYTES FROM (X) TO (U)
A59A  A6 80             LA59A    LDA   ,X+                 ; GET BYTE FROM X
A59C  A7 C0                      STA   ,U+                 ; STORE IT AT U
A59E  5A                         DECB                      ; MOVED ALL BYTES?
A59F  26 F9                      BNE   LA59A               ; NO
A5A1  39                LA5A1    RTS

* GET DEVICE NUMBER FROM BASIC LINE - CHECK VALIDITY
A5A2  BD B2 6D          LA5A2    JSR   LB26D               ; CHECK FOR COMMA, SYNTAX ERROR IF NONE
A5A5  81 23             LA5A5    CMPA  #'#                 ; IS NEXT CHARACTER A NUMBER?
A5A7  26 02                      BNE   LA5AB               ; NO
A5A9  9D 9F                      JSR   GETNCH              ; GET NEXT BASIC INPUT CHARACTER
A5AB  BD B1 41          LA5AB    JSR   LB141               ; EVALUATE EXPRESSION
A5AE  BD B3 ED          LA5AE    JSR   INTCNV              ; CONVERT FPA0 TO INTEGER, RETURN VALUE IN ACCD
A5B1  59                         ROLB                      ; MSB OF ACCB TO CARRY
A5B2  89 00                      ADCA  #0                  ; ADD MSB OF ACCB TO ACCA
A5B4  26 69                      BNE   LA61F               ; 'DEVICE # ERROR' IF ACCA<FF80 OR >007F
A5B6  56                         RORB                      ; RESTORE ACCB
A5B7  D7 6F                      STB   DEVNUM              ; STORE B IN DEVICE NUMBER
A5B9  BD 01 61                   JSR   RVEC1               ; HOOK INTO RAM
A5BC  27 06                      BEQ   LA5C4               ; BRANCH IF DEVICE NUMBER SET TO SCREEN
A5BE  2A 5F                      BPL   LA61F               ; 'DEVICE NUMBER' ERROR IF POSITIVE DEVICE NUMBER
A5C0  C1 FE                      CMPB  #-2                 ; LOWEST LEGAL DEVICE NUMBER
A5C2  2D 5B                      BLT   LA61F               ; 'DEVICE NUMBER ERROR'
A5C4  39                LA5C4    RTS

** THIS ROUTINE WILL SCAN OFF THE FILE NAME FROM A BASIC LINE
** AND RETURN A SYNTAX ERROR IF THERE ARE ANY CHARACTERS
** FOLLOWING THE END OF THE NAME
A5C5  8D B1             LA5C5    BSR   LA578               ; SCAN OFF NAME
A5C7  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHAR FROM BASIC LINE
A5C9  27 F9             LA5C9    BEQ   LA5C4               ; RETURN IF END OF LINE
A5CB  7E B2 77                   JMP   LB277               ; SYNTAX ERROR IF ANY MORE CHARACTERS

* EOF
A5CE  BD 01 88          EOF      JSR   RVEC14              ; HOOK INTO RAM
A5D1  96 6F                      LDA   DEVNUM              ; GET DEVICE NUMBER
A5D3  34 02                      PSHS  A                   ; SAVE IT
A5D5  8D D7                      BSR   LA5AE               ; CHECK DEVICE NUMBER
A5D7  BD A3 ED                   JSR   LA3ED               ; CHECK FOR PROPER FILE AND MODE
A5DA  5F                         CLRB                      ; NOT EOF FLAG = 0
A5DB  96 6F                      LDA   DEVNUM              ; TEST DEVICE NUMBER
A5DD  27 05                      BEQ   LA5E4               ; BRANCH IF NOT SET TO DISPLAY
A5DF  0D 79                      TST   CINCTR              ; ANY CHARACTERS LEFT TO SEND?
A5E1  26 01                      BNE   LA5E4               ; YES
A5E3  53                         COMB                      ; NO - EOF: SET FLAG = -1 ($FF)
A5E4  35 02             LA5E4    PULS  A                   ; GET DEVICE NUMBER BACK AGAIN
A5E6  97 6F                      STA   DEVNUM              ; RESTORE IT
A5E8  1D                LA5E8    SEX                       ; CONVERT ACCB TO 2 DIGIT SIGNED INTEGER
A5E9  7E B4 F4                   JMP   GIVABF              ; CONVERT ACCD TO FLOATING POINT

* SKIPF
A5EC  8D D7             SKIPF    BSR   LA5C5               ; SCAN OFF THE BASIC FILE NAME
A5EE  8D 58                      BSR   LA648               ; LOOK FOR THAT FILE ON TAPE
A5F0  BD A6 D1                   JSR   LA6D1               ; READ THE FILE
A5F3  26 24                      BNE   LA619               ; 'I/O ERROR'
A5F5  39                         RTS
