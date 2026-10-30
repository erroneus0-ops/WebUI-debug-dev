; Color BASIC 1.2 -- $B046-$B0F7
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: READ=$B046

*
* READ
B046  9E 33             READ     LDX   DATPTR              ; GET 'READ' START ADDRESS
B048  86                         FCB   SKP1LD              ; SKIP ONE BYTE - LDA #*$4F
B049  4F                LB049    CLRA                      ; 'INPUT' ENTRY POINT: INPUT FLAG = 0
B04A  97 09                      STA   INPFLG              ; SET INPUT FLAG; 0 = INPUT: <> 0 = READ
B04C  9F 35                      STX   DATTMP              ; SAVE 'READ' START ADDRESS/'INPUT' BUFFER START
B04E  BD B3 57          LB04E    JSR   LB357               ; EVALUATE A VARIABLE
B051  9F 3B                      STX   VARDES              ; SAVE DESCRIPTOR ADDRESS
B053  9E A6                      LDX   CHARAD              ; * GET BASIC'S INPUT POINTER
B055  9F 2B                      STX   BINVAL              ; * AND SAVE IT
B057  9E 35                      LDX   DATTMP              ; GET 'READ' ADDRESS START/'INPUT' BUFFER POINTER
B059  A6 84                      LDA   ,X                  ; GET A CHARACTER FROM THE BASIC PROGRAM
B05B  26 0C                      BNE   LB069               ; BRANCH IF NOT END OF LINE
B05D  96 09                      LDA   INPFLG              ; * CHECK INPUT FLAG AND BRANCH
B05F  26 58                      BNE   LB0B9               ; * IF LOOKING FOR DATA (READ)
* NO DATA IN 'INPUT' LINE BUFFER AND/OR INPUT
* NOT COMING FROM SCREEN
B061  BD 01 7C                   JSR   RVEC10              ; HOOK INTO RAM IF 'INPUT'
B064  BD B9 AF                   JSR   LB9AF               ; SEND A '?' TO CONSOLE OUT
B067  8D C6                      BSR   LB02F               ; FILL INPUT BUFFER FROM CONSOLE IN
B069  9F A6             LB069    STX   CHARAD              ; RESET BASIC'S INPUT POINTER
B06B  9D 9F                      JSR   GETNCH              ; GET A CHARACTER FROM BASIC
B06D  D6 06                      LDB   VALTYP              ; * CHECK VARIABLE TYPE AND
B06F  27 27                      BEQ   LB098               ; * BRANCH IF NUMERIC
* READ/INPUT A STRING VARIABLE
B071  9E A6                      LDX   CHARAD              ; LOAD X WITH CURRENT BASIC INPUT POINTER
B073  97 01                      STA   CHARAC              ; SAVE CURRENT INPUT CHARACTER
B075  81 22                      CMPA  #'"                 ; CHECK FOR STRING DELIMITER
B077  27 12                      BEQ   LB08B               ; BRANCH IF STRING DELIMITER
B079  30 1F                      LEAX  -1,X                ; BACK UP POINTER
B07B  4F                         CLRA                      ; * ZERO = END OF LINE CHARACTER
B07C  97 01                      STA   CHARAC              ; * SAVE AS TERMINATOR
B07E  BD A3 5F                   JSR   LA35F               ; SET UP PRINT PARAMETERS
B081  0D 6E                      TST   PRTDEV              ; CHECK PRINT DEVICE NUMBER
B083  26 06                      BNE   LB08B               ; BRANCH IF CASSETTE - USE TWO ZEROS AS TERMINATOR
* CHARACTERS FOR CASSETTE
B085  86 3A                      LDA   #':                 ; END OF SUBLINE CHARACTER
B087  97 01                      STA   CHARAC              ; SAVE AS TERMINATOR I
B089  86 2C                      LDA   #',                 ; COMMA
B08B  97 02             LB08B    STA   ENDCHR              ; SAVE AS TERMINATOR 2
B08D  BD B5 1E                   JSR   LB51E               ; STRIP A STRING FROM THE INPUT BUFFER
B090  BD B2 49                   JSR   LB249               ; MOVE INPUT POINTER TO END OF STRING
B093  BD AF A4                   JSR   LAFA4               ; PUT A STRING INTO THE STRING SPACE IF NECESSARY
B096  20 06                      BRA   LB09E               ; CHECK FOR ANOTHER DATA ITEM
* SAVE A NUMERIC VALUE IN A READ OR INPUT DATA ITEM
B098  BD BD 12          LB098    JSR   LBD12               ; CONVERT AN ASCII STRING TO FP NUMBER
B09B  BD BC 33                   JSR   LBC33               ; PACK FPA0 AND STORE IT IN ADDRESS IN VARDES -
* INPUT OR READ DATA ITEM
B09E  9D A5             LB09E    JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
B0A0  27 06                      BEQ   LB0A8               ; BRANCH IF END OF LINE
B0A2  81 2C                      CMPA  #',                 ; CHECK FOR A COMMA
B0A4  10 26 FF 2E                LBNE  LAFD6               ; 'BAD FILE DATA' ERROR OR RETRY
B0A8  9E A6             LB0A8    LDX   CHARAD              ; * GET CURRENT INPUT
B0AA  9F 35                      STX   DATTMP              ; * POINTER (USED AS A DATA POINTER) AND SAVE IT
B0AC  9E 2B                      LDX   BINVAL              ; * RESET INPUT POINTER TO INPUT OR
B0AE  9F A6                      STX   CHARAD              ; * READ STATEMENT
B0B0  9D A5                      JSR   GETCCH              ; GET CURRENT CHARACTER FROM BASIC
B0B2  27 21                      BEQ   LB0D5               ; BRANCH IF END OF LINE - EXIT COMMAND
B0B4  BD B2 6D                   JSR   LB26D               ; SYNTAX CHECK FOR COMMA
B0B7  20 95                      BRA   LB04E               ; GET ANOTHER INPUT OR READ ITEM
* SEARCH FROM ADDRESS IN X FOR
* 1ST OCCURENCE OF THE TOKEN FOR DATA
B0B9  9F A6             LB0B9    STX   CHARAD              ; RESET BASIC'S INPUT POINTER
B0BB  BD AE E8                   JSR   LAEE8               ; SEARCH FOR END OF CURRENT LINE OR SUBLINE
B0BE  30 01                      LEAX  1,X                 ; MOVE X ONE PAST END OF LINE
B0C0  4D                         TSTA                      ; CHECK FOR END OF LINE
B0C1  26 0A                      BNE   LB0CD               ; BRANCH IF END OF SUBLINE
B0C3  C6 06                      LDB   #2*3                ; 'OUT OF DATA' ERROR
B0C5  EE 81                      LDU   ,X++                ; GET NEXT 2 CHARACTERS
B0C7  27 41                      BEQ   LB10A               ; 'OD' ERROR IF END OF PROGRAM
B0C9  EC 81                      LDD   ,X++                ; GET BASIC LINE NUMBER AND
B0CB  DD 31                      STD   DATTXT              ; SAVE IT IN DATTXT
B0CD  A6 84             LB0CD    LDA   ,X                  ; GET AN INPUT CHARACTER
B0CF  81 86                      CMPA  #$86                ; DATA TOKEN?
B0D1  26 E6                      BNE   LB0B9               ; NO — KEEP LOOKING
B0D3  20 94                      BRA   LB069               ; YES
* EXIT READ AND INPUT COMMANDS
B0D5  9E 35             LB0D5    LDX   DATTMP              ; GET DATA POINTER
B0D7  D6 09                      LDB   INPFLG              ; * CHECK INPUT FLAG
B0D9  10 26 FD 0B                LBNE  LADE8               ; * SAVE NEW DATA POINTER IF READ
B0DD  A6 84                      LDA   ,X                  ; = CHECK NEXT CHARACTER IN 'INPUT' BUFFER
B0DF  27 06                      BEQ   LB0E7               ; =  RETURN IF NO MORE DATA FOR INPUT
B0E1  8E B0 E7                   LDX   #LB0E8-1            ; POINT X TO '?EXTRA IGNORED'
B0E4  7E B9 9C                   JMP   LB99C               ; PRINT THE MESSAGE
B0E7  39                LB0E7    RTS

B0E8  3F 45 58 54 52 41 LB0E8    FCC   '?EXTRA IGNORED'    ; ?EXTRA IGNORED MESSAGE
B0EE  20 49 47 4E 4F 52
B0F4  45 44
B0F6  0D 00                      FCB   CR,$00
