; Color BASIC 1.2 -- $B764-$B8F6
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: LIST=$B764

* LIST
B764  34 01             LIST     PSHS  CC                  ; SAVE ZERO FLAG ON STACK
B766  BD AF 67                   JSR   LAF67               ; CONVERT DECIMAL LINE NUMBER TO BINARY
B769  BD AD 01                   JSR   LAD01               ; * FIND RAM ADDRESS OF THAT LINE NUMBER AND
B76C  9F 66                      STX   LSTTXT              ; * SAVE IT IN LSTTXT
B76E  35 01                      PULS  CC                  ; GET ZERO FLAG FROM STACK
B770  27 12                      BEQ   LB784               ; BRANCH IF END OF LINE
B772  9D A5                      JSR   GETCCH              ; GET CURRENT CHARACTER FROM BASIC
B774  27 13                      BEQ   LB789               ; BRANCH IF END OF LINE
B776  81 AC                      CMPA  #$AC                ; MINUS TOKEN (IS IT A RANGE OF LINE NUMBERS?)
B778  26 09                      BNE   LB783               ; NO - RETURN
B77A  9D 9F                      JSR   GETNCH              ; GET NEXT CHARACTER FROM BASIC
B77C  27 06                      BEQ   LB784               ; BRANCH IF END OF LINE
B77E  BD AF 67                   JSR   LAF67               ; GET ENDING LINE NUMBER
B781  27 06                      BEQ   LB789               ; BRANCH IF LEGAL LINE NUMBER
B783  39                LB783    RTS
* LIST THE ENTIRE PROGRAM
B784  CE FF FF          LB784    LDU   #$FFFF              ; * SET THE DEFAULT ENDING LINE NUMBER
B787  DF 2B                      STU   BINVAL              ; * TO $FFFF
B789  32 62             LB789    LEAS  2,S                 ; PURGE RETURN ADDRESS FROM THE STACK
B78B  9E 66                      LDX   LSTTXT              ; POINT X TO STARTING LINE ADDRESS
B78D  BD B9 5C          LB78D    JSR   LB95C               ; MOVE CURSOR TO START OF A NEW LINE
B790  BD A5 49                   JSR   LA549               ; CHECK FOR A BREAK OR PAUSE
B793  EC 84                      LDD   ,X                  ; GET ADDRESS OF NEXT BASIC LINE
B795  26 08                      BNE   LB79F               ; BRANCH IF NOT END OF PROGRAM
B797  BD A4 2D          LB797    JSR   LA42D               ; CHECK CLOSE FILE HANDLER
B79A  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
B79C  7E AC 73                   JMP   LAC73               ; RETURN TO BASIC'S MAIN INPUT LOOP
B79F  9F 66             LB79F    STX   LSTTXT              ; SAVE NEW STARTING LINE ADDRESS
B7A1  EC 02                      LDD   2,X                 ; * GET THE LINE NUMBER OF THIS LINE AND
B7A3  10 93 2B                   CMPD  BINVAL              ; * COMPARE IT TO ENDING LINE NUMBER
B7A6  22 EF                      BHI   LB797               ; EXIT IF LINE NUMBER > ENDING LINE NUMBER
B7A8  BD BD CC                   JSR   LBDCC               ; PRINT THE NUMBER IN ACCD ON SCREEN IN DECIMAL
B7AB  BD B9 AC                   JSR   LB9AC               ; SEND A SPACE TO CONSOLE OUT
B7AE  9E 66                      LDX   LSTTXT              ; GET RAM ADDRESS OF THIS LINE
B7B0  8D 10                      BSR   LB7C2               ; UNCRUNCH A LINE
B7B2  AE 9F 00 66                LDX   [LSTTXT]            ; POINT X TO START OF NEXT LINE
B7B6  CE 02 DD                   LDU   #LINBUF+1           ; POINT U TO BUFFER FULL OF UNCRUNCHED LINE
B7B9  A6 C0             LB7B9    LDA   ,U+                 ; GET A BYTE FROM THE BUFFER
B7BB  27 D0                      BEQ   LB78D               ; BRANCH IF END OF BUFFER
B7BD  BD B9 B1                   JSR   LB9B1               ; SEND CHARACTER TO CONSOLE OUT
B7C0  20 F7                      BRA   LB7B9               ; GET ANOTHER CHARACTER

* UNCRUNCH A LINE INTO BASIC'S LINE INPUT BUFFER
B7C2  BD 01 A6          LB7C2    JSR   RVEC24              ; HOOK INTO RAM
B7C5  30 04                      LEAX  4,X                 ; MOVE POINTER PAST ADDRESS OF NEXT LINE AND LINE NUMBER
B7C7  10 8E 02 DD                LDY   #LINBUF+1           ; UNCRUNCH LINE INTO LINE INPUT BUFFER
B7CB  A6 80             LB7CB    LDA   ,X+                 ; GET A CHARACTER
B7CD  27 51                      BEQ   LB820               ; BRANCH IF END OF LINE
B7CF  2B 15                      BMI   LB7E6               ; BRANCH IF IT'S A TOKEN
B7D1  81 3A                      CMPA  #':                 ; CHECK FOR END OF SUB LINE
B7D3  26 0D                      BNE   LB7E2               ; BRNCH IF NOT END OF SUB LINE
B7D5  E6 84                      LDB   ,X                  ; GET CHARACTER FOLLOWING COLON
B7D7  C1 84                      CMPB  #$84                ; TOKEN FOR ELSE?
B7D9  27 F0                      BEQ   LB7CB               ; YES - DON'T PUT IT IN BUFFER
B7DB  C1 83                      CMPB  #$83                ; TOKEN FOR REMARK?
B7DD  27 EC                      BEQ   LB7CB               ; YES - DON'T PUT IT IN BUFFER
B7DF  8C                         FCB   SKP2                ; SKIP TWO BYTES
B7E0  86 21             LB7E0    LDA   #'!                 ; EXCLAMATION POINT
B7E2  8D 30             LB7E2    BSR   LB814               ; PUT CHARACTER IN BUFFER
B7E4  20 E5                      BRA   LB7CB               ; GET ANOTHER CHARACTER
* UNCRUNCH A TOKEN
B7E6  CE 01 16          LB7E6    LDU   #COMVEC-10          ; FIRST DO COMMANDS
B7E9  81 FF                      CMPA  #$FF                ; CHECK FOR SECONDARY TOKEN
B7EB  26 04                      BNE   LB7F1               ; BRANCH IF NON SECONDARY TOKEN
B7ED  A6 80                      LDA   ,X+                 ; GET SECONDARY TOKEN
B7EF  33 45                      LEAU  5,U                 ; BUMP IT UP TO SECONDARY FUNCTIONS
B7F1  84 7F             LB7F1    ANDA  #$7F                ; MASK OFF BIT 7 OF TOKEN
B7F3  33 4A             LB7F3    LEAU  10,U                ; MOVE TO NEXT COMMAND TABLE
B7F5  6D C4                      TST   ,U                  ; IS THIS TABLE ENABLED?
B7F7  27 E7                      BEQ   LB7E0               ; NO - ILLEGAL TOKEN
B7F9  A0 C4                      SUBA  ,U                  ; SUBTRACT THE NUMBER OF TOKENS FROM THE CURRENT TOKEN NUMBER
B7FB  2A F6                      BPL   LB7F3               ; BRANCH IF TOKEN NOT IN THIS TABLE
B7FD  AB C4                      ADDA  ,U                  ; RESTORE TOKEN NUMBER RELATIVE TO THIS TABLE
B7FF  EE 41                      LDU   1,U                 ; POINT U TO COMMAND DICTIONARY TABLE
B801  4A                LB801    DECA                      ; DECREMENT TOKEN NUMBER
B802  2B 06                      BMI   LB80A               ; BRANCH IF THIS IS THE CORRECT TOKEN
* SKIP THROUGH DICTIONARY TABLE TO START OF NEXT TOKEN
B804  6D C0             LB804    TST   ,U+                 ; GRAB A BYTE
B806  2A FC                      BPL   LB804               ; BRANCH IF BIT 7 NOT SET
B808  20 F7                      BRA   LB801               ; GO SEE IF THIS IS THE CORRECT TOKEN
B80A  A6 C4             LB80A    LDA   ,U                  ; GET A CHARACTER FROM DICTIONARY TABLE
B80C  8D 06                      BSR   LB814               ; PUT CHARACTER IN BUFFER
B80E  6D C0                      TST   ,U+                 ; CHECK FOR START OF NEXT TOKEN
B810  2A F8                      BPL   LB80A               ; BRANCH IF NOT DONE WITH THIS TOKEN
B812  20 B7                      BRA   LB7CB               ; GO GET ANOTHER CHARACTER
B814  10 8C 03 D6       LB814    CMPY  #LINBUF+LBUFMX      ; TEST FOR END OF LINE INPUT BUFFER
B818  24 06                      BCC   LB820               ; BRANCH IF AT END OF BUFFER
B81A  84 7F                      ANDA  #$7F                ; MASK OFF BIT 7
B81C  A7 A0                      STA   ,Y+                 ; * SAVE CHARACTER IN BUFFER AND
B81E  6F A4                      CLR   ,Y                  ; * CLEAR NEXT CHARACTER SLOT IN BUFFER
B820  39                LB820    RTS
*
* CRUNCH THE LINE THAT THE INPUT POINTER IS
* POINTING TO INTO THE LINE INPUT BUFFER
* RETURN LENGTH OF CRUNCHED LINE IN ACCD
*
B821  BD 01 A3          LB821    JSR   RVEC23              ; HOOK INTO RAM
B824  9E A6                      LDX   CHARAD              ; GET BASIC'S INPUT POINTER ADDRESS
B826  CE 02 DC                   LDU   #LINBUF             ; POINT X TO LINE INPUT BUFFER
B829  0F 43             LB829    CLR   V43                 ; CLEAR ILLEGAL TOKEN FLAG
B82B  0F 44                      CLR   V44                 ; CLEAR DATA FLAG
B82D  A6 80             LB82D    LDA   ,X+                 ; GET INPUT CHAR
B82F  27 21                      BEQ   LB852               ; BRANCH IF END OF LINE
B831  0D 43                      TST   V43                 ; * CHECK ILLEGAL TOKEN FLAG & BRANCH IF NOT
B833  27 0F                      BEQ   LB844               ; * PROCESSING AN ILLEGAL TOKEN
B835  BD B3 A2                   JSR   LB3A2               ; SET CARRY IF NOT UPPER CASE ALPHA
B838  24 18                      BCC   LB852               ; BRANCH IF UPPER CASE ALPHA
B83A  81 30                      CMPA  #'0                 ; * DON'T CRUNCH ASCII NUMERIC CHARACTERS
B83C  25 04                      BLO   LB842               ; * BRANCH IF NOT NUMERIC
B83E  81 39                      CMPA  #'9                 ; *
B840  23 10                      BLS   LB852               ; * BRANCH IF NUMERIC
* END UP HERE IF NOT UPPER CASE ALPHA OR NUMERIC
B842  0F 43             LB842    CLR   V43                 ; CLEAR ILLEGAL TOKEN FLAG
B844  81 20             LB844    CMPA  #SPACE              ; SPACE?
B846  27 0A                      BEQ   LB852               ; DO NOT REMOVE SPACES
B848  97 42                      STA   V42                 ; SAVE INPUT CHARACTER AS SCAN DELIMITER
B84A  81 22                      CMPA  #'"                 ; CHECK FOR STRING DELIMITER
B84C  27 38                      BEQ   LB886               ; BRANCH IF STRING
B84E  0D 44                      TST   V44                 ; * CHECK DATA FLAG AND BRANCH IF CLEAR
B850  27 19                      BEQ   LB86B               ; * DO NOT CRUNCH DATA
B852  A7 C0             LB852    STA   ,U+                 ; SAVE CHARACTER IN BUFFER
B854  27 06                      BEQ   LB85C               ; BRANCH IF END OF LINE
B856  81 3A                      CMPA  #':                 ; * CHECK FOR END OF SUBLINE
B858  27 CF                      BEQ   LB829               ; * AND RESET FLAGS IF END OF SUBLINE
B85A  20 D1             LB85A    BRA   LB82D               ; GO GET ANOTHER CHARACTER
B85C  6F C0             LB85C    CLR   ,U+                 ; * DOUBLE ZERO AT END OF LINE
B85E  6F C0                      CLR   ,U+                 ; *
B860  1F 30                      TFR   U,D                 ; SAVE ADDRESS OF END OF LINE IN ACCD
B862  83 02 DA                   SUBD  #LINHDR             ; LENGTH OF LINE IN ACCD
B865  8E 02 DB                   LDX   #LINBUF-1           ; * SET THE INPUT POINTER TO ONE BEFORE
B868  9F A6                      STX   CHARAD              ; * THE START OF THE CRUNCHED LINE
B86A  39                         RTS                       ; EXIT 'CRUNCH'
B86B  81 3F             LB86B    CMPA  #'?                 ; CHECK FOR "?" - PRINT ABBREVIATION
B86D  26 04                      BNE   LB873               ; BRANCH IF NOT PRINT ABBREVIATION
B86F  86 87                      LDA   #$87                ; * GET THE PRINT TOKEN AND SAVE IT
B871  20 DF                      BRA   LB852               ; * IN BUFFER
B873  81 27             LB873    CMPA  #''                 ; APOSTROPHE IS SAME AS REM
B875  26 13                      BNE   LB88A               ; BRANCH IF NOT REMARK
B877  CC 3A 83                   LDD   #$3A83              ; COLON, REM TOKEN
B87A  ED C1                      STD   ,U++                ; SAVE IN BUFFER
B87C  0F 42             LB87C    CLR   V42                 ; SET DELIMITER = 0 (END OF LINE)
B87E  A6 80             LB87E    LDA   ,X+                 ; SCAN TILL WE MATCH [V42]
B880  27 D0                      BEQ   LB852               ; BRANCH IF END OF LINE
B882  91 42                      CMPA  V42                 ; DELIMITER?
B884  27 CC                      BEQ   LB852               ; BRANCH OUT IF SO
B886  A7 C0             LB886    STA   ,U+                 ; DON'T CRUNCH REMARKS OR STRINGS
B888  20 F4                      BRA   LB87E               ; GO GET MORE STRING OR REMARK
B88A  81 30             LB88A    CMPA  #'0                 ; * LESS THAN ASCII ZERO?
B88C  25 04                      BCS   LB892               ; * BRANCH IF SO
B88E  81 3C                      CMPA  #';+1               ; = CHECK FOR NUMERIC VALUE, COLON OR SEMICOLON
B890  25 C0                      BCS   LB852               ; = AND INSERT IN BUFFER IF SO
B892  30 1F             LB892    LEAX  -1,X                ; MOVE INPUT POINTER BACK ONE
B894  34 50                      PSHS  U,X                 ; SAVE POINTERS TO INPUT STRING, OUTPUT STRING
B896  0F 41                      CLR   V41                 ; TOKEN FLAG 0 = COMMAND, FF = SECONDARY
B898  CE 01 16                   LDU   #COMVEC-10          ; POINT U TO COMMAND INTERPRETATION
* TABLE FOR BASIC - 10
B89B  0F 42             LB89B    CLR   V42                 ; INITIALIZE V42 AS TOKEN COUNTER
B89D  33 4A             LB89D    LEAU  10,U                ; MOVE TO NEXT COMMAND INTERPRETATION TABLE
B89F  A6 C4                      LDA   ,U                  ; GET NUMBER OF COMMANDS
B8A1  27 31                      BEQ   LB8D4               ; GO DO SECONDARY FUNCTIONS IF NO COMMAND TABLE
B8A3  10 AE 41                   LDY   1,U                 ; POINT Y TO COMMAND DICTIONARY TABLE
B8A6  AE E4             LB8A6    LDX   ,S                  ; GET POINTER TO INPUT STRING
B8A8  E6 A0             LB8A8    LDB   ,Y+                 ; GET A BYTE FROM DICTIONARY TABLE
B8AA  E0 80                      SUBB  ,X+                 ; SUBTRACT INPUT CHARACTER
B8AC  27 FA                      BEQ   LB8A8               ; LOOP IF SAME
B8AE  C1 80                      CMPB  #$80                ; LAST CHAR IN RESERVED WORD TABLE HAD
* BIT 7 SET, SO IF WE HAVE $80 HERE
* THEN IT IS A GOOD COMPARE
B8B0  26 38                      BNE   LB8EA               ; BRANCH IF NO MATCH - CHECK ANOTHER COMMAND
B8B2  32 62                      LEAS  2,S                 ; DELETE OLD INPUT POINTER FROM STACK
B8B4  35 40                      PULS  U                   ; GET POINTER TO OUTPUT STRING
B8B6  DA 42                      ORB   V42                 ; OR IN THE TABLE POSITION TO MAKE THE TOKEN
* - NOTE THAT B ALREADY HAD $80 IN IT -
B8B8  96 41                      LDA   V41                 ; * CHECK TOKEN FLAG AND BRANCH
B8BA  26 06                      BNE   LB8C2               ; * IF SECONDARY
B8BC  C1 84                      CMPB  #$84                ; IS IT ELSE TOKEN?
B8BE  26 06                      BNE   LB8C6               ; NO
B8C0  86 3A                      LDA   #':                 ; PUT A COLON (SUBLINE) BEFORE ELSE TOKEN
B8C2  ED C1             LB8C2    STD   ,U++                ; SECONDARY TOKENS PRECEEDED BY $FF
B8C4  20 94                      BRA   LB85A               ; GO PROCESS MORE INPUT CHARACTERS
B8C6  E7 C0             LB8C6    STB   ,U+                 ; SAVE THIS TOKEN
B8C8  C1 86                      CMPB  #$86                ; DATA TOKEN?
B8CA  26 02                      BNE   LB8CE               ; NO
B8CC  0C 44                      INC   V44                 ; SET DATA FLAG
B8CE  C1 82             LB8CE    CMPB  #$82                ; REM TOKEN?
B8D0  27 AA                      BEQ   LB87C               ; YES
B8D2  20 86             LB8D2    BRA   LB85A               ; GO PROCESS MORE INPUT CHARACTERS
* CHECK FOR A SECONDARY TOKEN
B8D4  CE 01 1B          LB8D4    LDU   #COMVEC-5           ; NOW DO SECONDARY FUNCTIONS
B8D7  03 41                      COM   V41                 ; TOGGLE THE TOKEN FLAG
B8D9  26 C0                      BNE   LB89B               ; BRANCH IF NOW CHECKING SECONDARY COMMANDS

* THIS CODE WILL PROCESS INPUT DATA WHICH CANNOT BE CRUNCHED AND SO
* IS ASSUMED TO BE ILLEGAL DATA OR AN ILLEGAL TOKEN
B8DB  35 50                      PULS  X,U                 ; RESTORE INPUT AND OUTPUT POINTERS
B8DD  A6 80                      LDA   ,X+                 ; * MOVE THE FIRST CHARACTER OF AN
B8DF  A7 C0                      STA   ,U+                 ; * ILLEGAL TOKEN
B8E1  BD B3 A2                   JSR   LB3A2               ; SET CARRY IF NOT ALPHA
B8E4  25 EC                      BCS   LB8D2               ; BRANCH IF NOT ALPHA
B8E6  03 43                      COM   V43                 ; SET ILLEGAL TOKEN FLAG IF UPPER CASE ALPHA
B8E8  20 E8                      BRA   LB8D2               ; PROCESS MORE INPUT CHARACTERS
B8EA  0C 42             LB8EA    INC   V42                 ; INCREMENT TOKEN COUNTER
B8EC  4A                         DECA                      ; DECR COMMAND COUNTER
B8ED  27 AE                      BEQ   LB89D               ; GET ANOTHER COMMAND TABLE IF DONE W/THIS ONE
B8EF  31 3F                      LEAY  -1,Y                ; MOVE POINTER BACK ONE
B8F1  E6 A0             LB8F1    LDB   ,Y+                 ; * GET TO NEXT
B8F3  2A FC                      BPL   LB8F1               ; * RESERVED WORD
B8F5  20 AF                      BRA   LB8A6               ; GO SEE IF THIS WORD IS A MATCH
