; Color BASIC 1.2 -- $A282-$A44B
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: PUTCHR=$A282, CLOSE=$A416

* CONSOLE OUT
A282  BD 01 67          PUTCHR   JSR   RVEC3               ; HOOK INTO RAM
A285  34 04                      PSHS  B                   ; SAVE ACCB
A287  D6 6F                      LDB   DEVNUM              ; GET DEVICE NUMBER
A289  5C                         INCB                      ; SET FLAGS
A28A  35 04                      PULS  B                   ; RESTORE ACCB
A28C  2B 31                      BMI   LA2BF               ; SEND TO LINE PRINTER
A28E  26 7A                      BNE   LA30A               ; SEND TO SCREEN
* SEND TO CASSETTE
A290  34 16                      PSHS  X,B,A               ; RESTORE REGISTERS
A292  D6 78                      LDB   FILSTA              ; GET FILE STATUS
A294  5A                         DECB                      ; INPUT FILE?
A295  27 0F                      BEQ   LA2A6               ; YES
A297  D6 79                      LDB   CINCTR              ; TEMP CHAR CTR
A299  5C                         INCB                      ; IS THE BUFFER FULL
A29A  26 02                      BNE   LA29E               ; NO
A29C  8D 0A                      BSR   LA2A8               ; YES, WRITE DATA BLOCK TO TAPE
A29E  9E 7A             LA29E    LDX   CINPTR              ; GET BUFFER POINTER
A2A0  A7 80                      STA   ,X+                 ; PUT CHAR IN CASSETTE BUFFER
A2A2  9F 7A                      STX   CINPTR              ; STORE NEW BUFFER POINTER
A2A4  0C 79                      INC   CINCTR              ; INCR BYTE COUNT
A2A6  35 96             LA2A6    PULS  A,B,X,PC

* WRITE A BLOCK OF DATA TO TAPE
A2A8  C6 01             LA2A8    LDB   #1                  ; DATA BLOCK TYPE - NOT A HEADER BLOCK
A2AA  D7 7C             LA2AA    STB   BLKTYP              ; BLOCK NUMBER
A2AC  8E 01 DA                   LDX   #CASBUF             ; CASSETTE BUFFER
A2AF  9F 7E                      STX   CBUFAD              ; STARTING ADDRESS
A2B1  D6 79                      LDB   CINCTR              ; GET NUMBER OF BYTES
A2B3  D7 7D                      STB   BLKLEN              ; BYTE COUNT
A2B5  34 62                      PSHS  U,Y,A               ; SAVE REGISTERS
A2B7  BD A7 E5                   JSR   LA7E5               ; WRITE A BLOCK ON TAPE
A2BA  35 62                      PULS  A,Y,U               ; RESTORE REGISTERS
A2BC  7E A6 50                   JMP   LA650               ; RESET BUFFER POINTERS

* SOFTWARE UART TO L1NE PRINTER
A2BF  34 17             LA2BF    PSHS  X,B,A,CC            ; SAVE REGISTERS AND INTERRUPT STATUS
A2C1  1A 50                      ORCC  #$50                ; DISABLE IRQ,FIRQ
A2C3  F6 FF 22          LA2C3    LDB   PIA1+2              ; GET RS 232 STATUS
A2C6  54                         LSRB                      ; SHIFT RS 232 STATUS BIT INTO CARRY
A2C7  25 FA                      BCS   LA2C3               ; LOOP UNTIL READY
A2C9  8D 30                      BSR   LA2FB               ; SET OUTPUT TO MARKING
A2CB  5F                         CLRB                      ; *
A2CC  8D 2F                      BSR   LA2FD               ; * TRANSMIT ONE START BIT
A2CE  C6 08                      LDB   #8                  ; SEND 8 BITS
A2D0  34 04             LA2D0    PSHS  B                   ; SAVE BIT COUNTER
A2D2  5F                         CLRB                      ; CLEAR DA IMAGE I ZEROES TO DA WHEN SENDING RS 232 DATA
A2D3  44                         LSRA                      ; ROTATE NEXT BIT OF OUTPUT CHARACTER TO CARRY FLAG
A2D4  59                         ROLB                      ; * ROTATE CARRY FLAG INTO BIT ONE
A2D5  58                         ASLB                      ; * AND ALL OTHER BITS SET TO ZERO
A2D6  8D 25                      BSR   LA2FD               ; TRANSMIT DATA BYTE
A2D8  35 04                      PULS  B                   ; GET BIT COUNTER
A2DA  5A                         DECB                      ; SENT ALL 8 BITS?
A2DB  26 F3                      BNE   LA2D0               ; NO
A2DD  8D 1C                      BSR   LA2FB               ; SEND STOP BIT (ACCB:0)
A2DF  35 03                      PULS  CC,A                ; RESTORE OUTPUT CHARACTER & INTERRUPT STATUS
A2E1  81 0D                      CMPA  #CR                 ; IS IT CARRIAGE RETURN?
A2E3  27 08                      BEQ   LA2ED               ; YES
A2E5  0C 9C                      INC   LPTPOS              ; INCREMENT CHARACTER COUNTER
A2E7  D6 9C                      LDB   LPTPOS              ; CHECK FOR END OF LINE PRINTER LINE
A2E9  D1 9B                      CMPB  LPTWID              ; AT END OF LINE PRINTER LINE?
A2EB  25 06                      BLO   LA2F3               ; NO
A2ED  0F 9C             LA2ED    CLR   LPTPOS              ; RESET CHARACTER COUNTER
A2EF  8D 14                      BSR   LA305               ; *
A2F1  8D 12                      BSR   LA305               ; * DELAY FOR CARRIAGE RETURN
A2F3  F6 FF 22          LA2F3    LDB   PIA1+2              ; WAIT FOR HANDSHAKE
A2F6  54                         LSRB                      ; CHECK FOR R5232 STATUS?
A2F7  25 FA                      BCS   LA2F3               ; NOT YET READY
A2F9  35 94                      PULS  B,X,PC              ; RESTORE REGISTERS
A2FB  C6 02             LA2FB    LDB   #2                  ; SET RS232 OUTPUT HIGH (MARKING)
A2FD  F7 FF 20          LA2FD    STB   DA                  ; STORE TO THE D/A CONVERTER REGISTER
A300  8D 00                      BSR   LA302               ; GO WAIT A WHILE
A302  9E 95             LA302    LDX   LPTBTD              ; GET BAUD RATE
A304  8C 9E 97                   FCB   SKP2                ; SKIP NEXT TWO BYTES
A305  9E 97             LA305    LDX   LPTLND              ; PRINTER CARRIAGE RETURN DELAY
A307  7E A7 D3                   JMP   LA7D3               ; DELAY ON DECREMENTING X

* PUT A CHARACTER ON THE SCREEN
A30A  34 16             LA30A    PSHS  X,B,A               ; SAVE REGISTERS
A30C  9E 88                      LDX   CURPOS              ; POINT X TO CURRENT CHARACTER POSITION
A30E  81 08                      CMPA  #BS                 ; IS IT BACKSPACE?
A310  26 0B                      BNE   LA31D               ; NO
A312  8C 04 00                   CMPX  #VIDRAM             ; AT TOP OF SCREEN?
A315  27 46                      BEQ   LA35D               ; YES - DO NOT ALLOW BACKSPACE
A317  86 60                      LDA   #$60                ; BLANK
A319  A7 82                      STA   ,-X                 ; PUT IN PREVIOUS POSITION
A31B  20 27                      BRA   LA344               ; SAVE NEW CURPOS
A31D  81 0D             LA31D    CMPA  #CR                 ; ENTER KEY?
A31F  26 0E                      BNE   LA32F               ; BRANCH IF NOT
A321  9E 88                      LDX   CURPOS              ; GET CURRENT CHAR POSITION
A323  86 60             LA323    LDA   #$60                ; BLANK
A325  A7 80                      STA   ,X+                 ; PUT IT ON SCREEN
A327  1F 10                      TFR   X,D                 ; *
A329  C5 1F                      BITB  #$1F                ; * TEST FOR BEGINNING OF NEW LINE
A32B  26 F6                      BNE   LA323               ; PUT OUT BLANKS TILL NEW LINE
A32D  20 15                      BRA   LA344               ; CHECK FOR SCROLLING
A32F  81 20             LA32F    CMPA  #SPACE              ; *
A331  25 2A                      BCS   LA35D               ; * BRANCH IF CONTROL CHARACTER
A333  4D                         TSTA                      ; SET FLAGS
A334  2B 0C                      BMI   LA342               ; IT IS GRAPHIC CHARACTER
A336  81 40                      CMPA  #$40                ; *
A338  25 06                      BCS   LA340               ; * BRANCH IF NUMBER OR SPECIAL CHARACTER
A33A  81 60                      CMPA  #$60                ; UPPER/LOWER CASE?
A33C  25 04                      BCS   LA342               ; BRANCH IF UPPER CASE ALPHA
A33E  84 DF                      ANDA  #$DF                ; CLEAR BIT 5, FORCE ASCII LOWER CASE TO BE UPPER CASE
A340  88 40             LA340    EORA  #$40                ; INVERT BIT 6, CHANGE UPPER CASE TO LOWER & VICE VERSA
A342  A7 80             LA342    STA   ,X+                 ; STORE CHARACTER TO SCREEN
A344  9F 88             LA344    STX   CURPOS              ; SAVE CURRENT CHAR POSITION
A346  8C 05 FF                   CMPX  #VIDRAM+511         ; END OF SCREEN BUFFER?
A349  23 12                      BLS   LA35D               ; RETURN IF NO NEED TO SCROLL
A34B  8E 04 00                   LDX   #VIDRAM             ; TOP OF SCREEN

* SCROLL THE SCREEN
A34E  EC 88 20          LA34E    LDD   32,X                ; GET TWO BYTES
A351  ED 81                      STD   ,X++                ; MOVE THEM UP ONE ROW
A353  8C 05 E0                   CMPX  #VIDRAM+$1E0        ; AT THE LAST LINE?
A356  25 F6                      BCS   LA34E               ; NO
A358  C6 60                      LDB   #$60                ; BLANK
A35A  BD A9 2D                   JSR   LA92D               ; BLANK LAST LINE
A35D  35 96             LA35D    PULS  A,B,X,PC            ; RESTORE REGISTERS

* SET UP TAB FIELD WIDTH, TAB ZONE, CURRENT POSITION
* AND LINE WIDTH ACCORDING TO THE DEVICE SELECTED
A35F  BD 01 64          LA35F    JSR   RVEC2               ; HOOK INTO RAM
A362  34 16                      PSHS  X,B,A               ; SAVE REGISTERS
A364  0F 6E                      CLR   PRTDEV              ; RESET PRINT DEVICE NUMBER
A366  96 6F                      LDA   DEVNUM              ; GET DEVICE NUMBER
A368  27 09                      BEQ   LA373               ; BRANCH IF SCREEN
A36A  4C                         INCA                      ; CHECK FOR CASSETTE
A36B  27 17                      BEQ   LA384               ; BRANCH IF CASSETTE
* END UP HERE IF PRINTER
A36D  9E 99                      LDX   LPTCFW              ; TAB FIELD WIDTH AND TAB ZONE
A36F  DC 9B                      LDD   LPTWID              ; PRINTER WIDTH AND POSITION
A371  20 09                      BRA   LA37C               ; SET PRINT PARAMETERS
* SCREEN DISPLAY VALUES
A373  D6 89             LA373    LDB   CURPOS+1            ; GET CURSOR LOC LS BYTE
A375  C4 1F                      ANDB  #$1F                ; KEEP ONLY COLUMN POSITION
A377  8E 10 10                   LDX   #$1010              ; TAB FIELD WIDTH AND LAST TAB ZONE
A37A  86 20                      LDA   #32                 ; DISPLAY SCREEN LINE WIDTH
A37C  9F 6A             LA37C    STX   DEVCFW              ; SAVE TAB FIELD WIDTH AND ZONE
A37E  D7 6C                      STB   DEVPOS              ; SAVE PRINT POSITION
A380  97 6D                      STA   DEVWID              ; SAVE PRINT WIDTH
A382  35 96                      PULS  A,B,X,PC            ; RESTORE REGISTERS
A384  03 6E             LA384    COM   PRTDEV              ; SET TO $FF FOR CASSETTE
A386  8E 01 00                   LDX   #$0100              ; * TAB FIELD WIDTH = 1; ALL OTHER
A389  4F                         CLRA                      ; * PARAMETERS = 0
A38A  5F                         CLRB                      ; *
A38B  20 EF                      BRA   LA37C               ; SET PRINT PARAMETERS

* THIS IS THE ROUTINE THAT GETS AN INPUT LINE FOR BASIC
* EXIT WITH BREAK KEY: CARRY = 1
* EXIT WITH ENTER KEY: CARRY = 0
A38D  BD A9 28          LA38D    JSR   LA928               ; CLEAR SCREEN
A390  BD 01 82          LA390    JSR   RVEC12              ; HOOK INTO RAM
A393  0F 87                      CLR   IKEYIM              ; RESET BREAK CHECK KEY TEMP KEY STORAGE
A395  8E 02 DD                   LDX   #LINBUF+1           ; INPUT LINE BUFFER
A398  C6 01                      LDB   #1                  ; ACCB CHAR COUNTER: SET TO 1 TO ALLOW A
* BACKSPACE AS FIRST CHARACTER
A39A  BD A1 71          LA39A    JSR   LA171               ; GO GET A CHARACTER FROM CONSOLE IN
A39D  0D 70                      TST   CINBFL              ; GET CONSOLE IN BUFFER FLAG
A39F  26 2B                      BNE   LA3CC               ; BRANCH IF NO MORE CHARACTERS IN INPUT FILE
A3A1  0D 6F                      TST   DEVNUM              ; CHECK DEVICE NUMBER
A3A3  26 23                      BNE   LA3C8               ; BRANCH IF NOT SCREEN
A3A5  81 0C                      CMPA  #FORMF              ; FORM FEED
A3A7  27 E4                      BEQ   LA38D               ; YES - CLEAR SCREEN
A3A9  81 08                      CMPA  #BS                 ; BACKSPACE
A3AB  26 07                      BNE   LA3B4               ; NO
A3AD  5A                         DECB                      ; YES - DECREMENT CHAR COUNTER
A3AE  27 E0                      BEQ   LA390               ; BRANCH IF BACK AT START OF LINE AGAIN
A3B0  30 1F                      LEAX  -1,X                ; DECREMENT BUFFER POINTER
A3B2  20 34                      BRA   LA3E8               ; ECHO CHAR TO SCREEN
A3B4  81 15             LA3B4    CMPA  #$15                ; SHIFT RIGHT ARROW?
A3B6  26 0A                      BNE   LA3C2               ; NO
* YES, RESET BUFFER TO BEGINNING AND ERASE CURRENT LINE
A3B8  5A                LA3B8    DECB                      ; DEC CHAR CTR
A3B9  27 D5                      BEQ   LA390               ; GO BACK TO START IF CHAR CTR = 0
A3BB  86 08                      LDA   #BS                 ; BACKSPACE?
A3BD  BD A2 82                   JSR   PUTCHR              ; SEND TO CONSOLE OUT (SCREEN)
A3C0  20 F6                      BRA   LA3B8               ; KEEP GOING
A3C2  81 03             LA3C2    CMPA  #3                  ; BREAK KEY?
A3C4  1A 01                      ORCC  #1                  ; SET CARRY FLAG
A3C6  27 05                      BEQ   LA3CD               ; BRANCH IF BREAK KEY DOWN
A3C8  81 0D             LA3C8    CMPA  #CR                 ; ENTER KEY?
A3CA  26 0D                      BNE   LA3D9               ; NO
A3CC  4F                LA3CC    CLRA                      ; CLEAR CARRY FLAG IF ENTER KEY - END LINE ENTRY
A3CD  34 01             LA3CD    PSHS  CC                  ; SAVE CARRY FLAG
A3CF  BD B9 58                   JSR   LB958               ; SEND CR TO SCREEN
A3D2  6F 84                      CLR   ,X                  ; MAKE LAST BYTE IN INPUT BUFFER = 0
A3D4  8E 02 DC                   LDX   #LINBUF             ; RESET INPUT BUFFER POINTER
A3D7  35 81                      PULS  CC,PC               ; RESTORE CARRY FLAG

* INSERT A CHARACTER INTO THE BASIC LINE INPUT BUFFER
A3D9  81 20             LA3D9    CMPA  #$20                ; IS IT CONTROL CHAR?
A3DB  25 BD                      BLO   LA39A               ; BRANCH IF CONTROL CHARACTER
A3DD  81 7B                      CMPA  #'z-1               ; *
A3DF  24 B9                      BCC   LA39A               ; * IGNORE IF > LOWER CASE Z
A3E1  C1 FA                      CMPB  #LBUFMX             ; HAVE 250 OR MORE CHARACTERS BEEN ENTERED?
A3E3  24 B5                      BCC   LA39A               ; YES, IGNORE ANY MORE
A3E5  A7 80                      STA   ,X+                 ; PUT IT IN INPUT BUFFER
A3E7  5C                         INCB                      ; INCREMENT CHARACTER COUNTER
A3E8  BD A2 82          LA3E8    JSR   PUTCHR              ; ECHO IT TO SCREEN
A3EB  20 AD                      BRA   LA39A               ; GO SET SOME MORE

* INPUT DEVICE NUMBER CHECK
A3ED  BD 01 6D          LA3ED    JSR   RVEC5               ; HOOK INTO RAM
A3F0  96 6F                      LDA   DEVNUM              ; DEVICE NUMBER
A3F2  27 21                      BEQ   LA415               ; RETURN IF SCREEN
A3F4  4C                         INCA                      ; *
A3F5  26 0C                      BNE   LA403               ; * BRANCH IF NOT CASSETTE (BAD FILE MODE)
A3F7  96 78                      LDA   FILSTA              ; GET FILE STATUS
A3F9  26 05                      BNE   LA400               ; FILE IS OPEN
A3FB  C6 2C             LA3FB    LDB   #22*2               ; 'FILE NOT OPEN' ERROR
A3FD  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR SERVICING ROUTINE
A400  4A                LA400    DECA                      ; *
A401  27 12                      BEQ   LA415               ; * FILE IS IN INPUT MODE, RETURN
A403  7E A6 16          LA403    JMP   LA616               ; 'BAD FILE MODE' ERROR

* PRINT DEVICE NUMBER CHECK
A406  BD 01 70          LA406    JSR   RVEC6               ; HOOK INTO RAM
A409  96 6F                      LDA   DEVNUM              ; GET DEVICE NUMBER
A40B  4C                         INCA                      ; *
A40C  26 07                      BNE   LA415               ; * RETURN IF NOT TAPE
A40E  96 78                      LDA   FILSTA              ; GET FILE STATUS
A410  27 E9                      BEQ   LA3FB               ; 'FILE NOT OPEN' ERROR
A412  4A                         DECA                      ; *
A413  27 EE                      BEQ   LA403               ; * 'BAD FILE MODE' - FILE IN INPUT MODE
A415  39                LA415    RTS

* CLOSE
A416  27 0E             CLOSE    BEQ   LA426               ; BRANCH IF NO NAME SPECIFIED
A418  BD A5 A5                   JSR   LA5A5               ; CHECK DEVICE NUMBER
A41B  8D 10             LA41B    BSR   LA42D               ; GO CLOSE A FILE
A41D  9D A5                      JSR   GETCCH              ; GET CURRENT BASIC CHARACTER
A41F  27 2A                      BEQ   LA44B               ; RETURN IF NO MORE FILES
A421  BD A5 A2                   JSR   LA5A2               ; CHECK SYNTAX AND DEVICE NUMBER
A424  20 F5                      BRA   LA41B               ; KEEP CLOSING FILES

* CLOSE ALL FILES HANDLER
A426  BD 01 73          LA426    JSR   RVEC7               ; HOOK INTO RAM
A429  86 FF                      LDA   #-1                 ; CASSETTE DEVICE NUMBER
A42B  97 6F                      STA   DEVNUM              ; SET DEVICE NUMBER
* CLOSE FILE HANDLER
A42D  BD 01 76          LA42D    JSR   RVEC8               ; HOOK INTO RAM
A430  96 6F                      LDA   DEVNUM              ; GET DEVICE NUMBER
A432  0F 6F                      CLR   DEVNUM              ; SET TO SCREEN
A434  4C                         INCA                      ; *
A435  26 14                      BNE   LA44B               ; * BRANCH IF WAS NOT CASSETTE
A437  96 78                      LDA   FILSTA              ; GET FILE STATUS
A439  81 02                      CMPA  #2                  ; IS IT OUTPUT MODE
A43B  26 0C                      BNE   LA449               ; NO
A43D  96 79                      LDA   CINCTR              ; GET CHARACTER BUFFER CTR
A43F  27 03                      BEQ   LA444               ; WRITE END OF PROG BLOCK IF BUFFER EMPTY
A441  BD A2 A8                   JSR   LA2A8               ; WRITE A BLOCK TO TAPE
A444  C6 FF             LA444    LDB   #$FF                ; END OF FILE TYPE BLOCK NUMBER
A446  BD A2 AA                   JSR   LA2AA               ; WRITE END OF FILE TYPE BLOCK
A449  0F 78             LA449    CLR   FILSTA              ; CASSETTE FILE STATUS CLOSED
A44B  39                LA44B    RTS
