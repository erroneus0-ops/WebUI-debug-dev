; Extended Color BASIC 1.1 -- $8CF1-$8E8F
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: XVEC4=$8CF1, $ READ A CHARACTER FROM THE RS 232 INPUT PORT.=$

* CONSOLE IN RAM HOOK
8CF1  96 6F             XVEC4    LDA   DEVNUM              ; GET DEVICE NUMBER
8CF3  81 FD                      CMPA  #-3                 ; DLOAD DEVICE NUMBER
8CF5  26 0A                      BNE   L8D01               ; BRANCH IF NOT OLOAD
8CF7  32 62                      LEAS  $02,S               ; PURGE 1ST RETURN ADDR FROM STACK
8CF9  0F 70                      CLR   CINBFL              ; RESET EMPTY/FULL FLAG
8CFB  0D 79                      TST   CINCTR              ; ANY CHARACTERS LEFT IN BUFFER?
8CFD  26 03                      BNE   L8D02               ; YES, GO GET ONE
8CFF  03 70                      COM   CINBFL              ; SET EMPTY/FULL FLAG TO EOF
8D01  39                L8D01    RTS
8D02  34 74             L8D02    PSHS  U,Y,X,B             ; SAVE REGISTERS
8D04  9E 7A                      LDX   CINPTR              ; GET CONSOLE IN CHARACTER BUFFER
8D06  A6 80                      LDA   ,X+                 ; GET A CHARACTER
8D08  34 02                      PSHS  A                   ; SAVE IT ON THE STACK
8D0A  9F 7A                      STX   CINPTR              ; SAVE NEW CHARACTER BUFFER
8D0C  0A 79                      DEC   CINCTR              ; DECREMENT CHARACTER COUNTER
8D0E  26 02                      BNE   L8D12               ; RETURN IF BUFFER NOT EMPTY
8D10  8D D0                      BSR   L8CE2               ; GO REFILL THE CHARACTER BUFFER
8D12  35 F6             L8D12    PULS  A,B,X,Y,U,PC        ; RESTORE REGISTERS AND RETURN
* TRANSMIT FILE NAME - READ FILE STATUS FROM SENDER
8D14  4F                L8D14    CLRA                      ; RESET ATTEMPT COUNTER
8D15  34 16                      PSHS  X,B,A               ; SAVE SPACE ON STACK FOR TEMP VARIABLES
8D17  31 E4                      LEAY  ,S                  ; STACK TO Y (TFR S,Y) - SAVE VARIABLE POINTER
8D19  20 02                      BRA   L8D1D
8D1B  8D 2B             L8D1B    BSR   L8D48               ; INCREMENT ATTEMPT COUNTER
8D1D  86 8A             L8D1D    LDA   #$8A                ; * GET FILE REQUEST CONTROL CODE
8D1F  8D 37                      BSR   L8D58               ; * AND TRANSMIT IT
8D21  26 F8                      BNE   L8D1B               ; BRANCH IF NO ECHO OR ERROR
8D23  8E 01 D2                   LDX   #CFNBUF+1           ; POINT TO CASS FILE NAME BUFFER
8D26  A6 80             L8D26    LDA   ,X+                 ; GET CHARACTER FROM NAME BUFFER
8D28  BD 8E 04                   JSR   L8E04               ; OUTPUT IT TO RS 232 PORT
8D2B  8C 01 DA                   CMPX  #CFNBUF+9           ; COMPARE TO END OF BUFFER
8D2E  26 F6                      BNE   L8D26               ; LOOP UNTIL DONE
8D30  8D 30                      BSR   L8D62               ; OUTPUT CHECK BYTE AND LOOK FOR ACKNOWLEDGE
8D32  26 E7                      BNE   L8D1B               ; TRANSMIT NAME AGAIN IF NO ACKNOWLEDGE
8D34  8D 3C                      BSR   L8D72               ; GET FILE TYPE $FF = NOT FOUND
8D36  26 E3                      BNE   L8D1B               ; BRANCH IF ERROR
8D38  A7 22                      STA   $02,Y               ; SAVE FILE TYPE
8D3A  8D 36                      BSR   L8D72               ; READ ASCII FLAG
8D3C  26 DD                      BNE   L8D1B               ; BRANCH IF ERROR
8D3E  A7 23                      STA   $03,Y               ; SAVE ASCII FLAG
8D40  8D 29                      BSR   L8D6B               ; READ CHECK BYTE FROM SENDER
8D42  26 D7                      BNE   L8D1B               ; BRANCH IF NO CHECKBYTE MATCH
8D44  32 62                      LEAS  $02,S               ; PURGE ATTEMPT COUNTER & CHECK BYTE FROM STACK
8D46  35 86                      PULS  A,B,PC              ; RETURN FILE STATUS IN ACCD
* INCREMENT ATTEMPT COUNTER - AFTER 5 TRIES, GIVE UP (IO ERROR)
8D48  6C A4             L8D48    INC   ,Y                  ; INCREMENT ATTEMPT COUNTER
8D4A  A6 A4                      LDA   ,Y                  ; GET ATTEMPT COUNTER
8D4C  81 05                      CMPA  #$05                ; IS THIS THE FIFTH TRY?
8D4E  25 1A                      BLO   L8D6A               ; NO
8D50  86 BC                      LDA   #$BC                ; YES ; TIME TO QUIT-GET ABORT CODE
8D52  BD 8E 0C                   JSR   L8E0C               ; OUTPUT ABORT CODE OVER THE RS 232 PORT
8D55  7E A6 19                   JMP   LA619               ; 'IO' ERROR
* ECHO CHECK - OUTPUT A CHARACTER, READ A CHARACTER AND
* COMPARE IT TO THE OUTPUT CHARACTER. Z=0 IF NO MATCH OR ERROR
8D58  34 02             L8D58    PSHS  A                   ; SAVE COMPARE CHARACTER ON STACK
8D5A  8D 5C                      BSR   L8DB8               ; SEND A CHARACTER OUT
8D5C  26 02                      BNE   L8D60               ; BRANCH IF READ ERROR
8D5E  A1 E4                      CMPA  ,S                  ; COMPARE RECEIVED CHARACTER TO TRANSMITTED CHARACTER
8D60  35 82             L8D60    PULS  A,PC                ; RESTORE COMPARE CHARACTER AND RETURN
* TRANSMIT XOR CHECKBYTE AND READ ACKNOWLEGE ($C8)
* RETURN ZERO FLAG SET IF NO ERROR AND ACKNOWLEGE
8D62  A6 21             L8D62    LDA   $01,Y               ; GET XOR CHECKBYTE
8D64  8D 52                      BSR   L8DB8               ; OUTPUT XOR CHECKBYTE AND READ ONE BYTE
8D66  26 02                      BNE   L8D6A               ; BRANCH IF READ ERROR
8D68  81 C8                      CMPA  #$C8                ; COMPARE INPUT BYTE TO ACKNOWLEDGE CODE
8D6A  39                L8D6A    RTS
* READ XOR CHECKBYTE THEN LOAD ACCUMULATED XOR CHECKBYTE.
* SET ZERO FLAG IF ACCUMULATED CHECK BYTE = 0
8D6B  8D 05             L8D6B    BSR   L8D72               ; INPUT A CHARACTER FROM RS 232
8D6D  26 FB                      BNE   L8D6A               ; BRANCH IF TIMEOUT
8D6F  A6 21                      LDA   $01,Y               ; GET CHECK BYTE
8D71  39                         RTS
8D72  8D 48             L8D72    BSR   L8DBC               ; INPUT A CHARACTER FROM RS 232
8D74  34 03                      PSHS  A,CC                ; SAVE CHARACTER AND ZERO FLAG ON STACK
8D76  A8 21                      EORA  $01,Y               ; * EXCLUSIVE OR INPUT
8D78  A7 21                      STA   $01,Y               ; * CHARACTER WITH CHECK BYTE
8D7A  35 83                      PULS  CC,A,PC             ; RESTORE CHARACTER AND ZERO FLAG
* REQUEST A BLOCK FROM RS 232 INPUT -
* LOAD THE RECEIVED DATA INTO THE BUFFER POINTED TO BY X
* U REGFISTER CONTAINS THE BLOCK NUMBER; RETURN Z=1 IF NO
* ERRORS, CHARACTER COUNT IN ACCA; ACCA = 0 IF FILE EMPTY
8D7C  4F                L8D7C    CLRA                      ; RESET ATTEMPT COUNTER
8D7D  34 76                      PSHS  U,Y,X,B,A           ; SAVE SPACE FOR STACK BUFFER
8D7F  68 67                      ASL   $07,S               ; * 6,7 S (U REG) CONTAIN THE 14 BIT BLOCK NUMBER -
8D81  69 66                      ROL   $06,S               ; * PUT THE BOTTOM 7 BITS IN 7,S AND THE
8D83  64 67                      LSR   $07,S               ; * TOP SEVEN BITS IN 6,S
8D85  31 E4                      LEAY  ,S                  ; STACK POINTER TO Y (TFR S,Y)
8D87  20 02                      BRA   L8D8B
8D89  8D BD             L8D89    BSR   L8D48               ; INCREMENT ATTEMPT COUNTER
8D8B  86 97             L8D8B    LDA   #$97                ; * TRANSMIT A BLOCK REQUEST CODE, ECHO
8D8D  8D C9                      BSR   L8D58               ; * CHECK AND RESET CHECK BYTE
8D8F  26 F8                      BNE   L8D89               ; BRANCH IF NO MATCH OR ERROR
8D91  A6 26                      LDA   $06,Y               ; * SEND OUT HIGH ORDER SEVEN BITS
8D93  8D 6F                      BSR   L8E04               ; * OF BLOCK NUMBER
8D95  A6 27                      LDA   $07,Y               ; = SEND OUT LOW ORDER SEVEN BITS
8D97  8D 6B                      BSR   L8E04               ; = OF BLOCK NUMBER
8D99  8D C7                      BSR   L8D62               ; TRANSMIT CHECK BYTE AND GET ACKNOWLEDGE
8D9B  26 EC                      BNE   L8D89               ; BRANCH IF ERROR OR NO ACKNOWLEDGE
8D9D  8D D3                      BSR   L8D72               ; READ CHARACTER COUNT
8D9F  26 E8                      BNE   L8D89               ; BRANCH IF READ ERROR
8DA1  A7 24                      STA   $04,Y               ; SAVE CHARACTER COUNT IN STACK VARIABLES
8DA3  AE 22                      LDX   $02,Y               ; GET VARIABLES POINTER FROM STACK BUFFER
* READ IN A BLOCK OF 128 CHARACTERS - THE HOST WILL TRANSMIT 128
* CHARACTERS REGARDLESS OF HOW MANY ARE VALID. OF HOW MANY ARE VALID.
8DA5  C6 80                      LDB   #128                ; 128 CHARACTERS/BUFFER
8DA7  8D C9             L8DA7    BSR   L8D72               ; READ A CHARACTER
8DA9  26 DE                      BNE   L8D89               ; RESTART PROCESS IF READ ERROR
8DAB  A7 80                      STA   ,X+                 ; SAVE THE CHARACTER IN BUFFER
8DAD  5A                         DECB                      ; DECREMENT CHARACTER COUNTER
8DAE  26 F7                      BNE   L8DA7               ; BRANCH IF NOT DONE
8DB0  8D B9                      BSR   L8D6B               ; INPUT XOR CHECKBYTE
8DB2  26 D5                      BNE   L8D89               ; RESTART PROCESS IF READ ERROR OR BAD CHECKBYTE
8DB4  32 64                      LEAS  $04,S               ; PURGE ATTEMPT COUNTER, CHECK BYTE AND LOAD ADDRESS FROM STACK
8DB6  35 96                      PULS  A,B,X,PC            ; RETURN CHARACTER COUNT IN ACCA
8DB8  6F 21             L8DB8    CLR   $01,Y               ; CLEAR CHECK BYTE
8DBA  8D 50                      BSR   L8E0C               ; OUTPUT A CHARACTER OVER RS 232 PORT
                        $ READ A CHARACTER FROM THE RS 232 INPUT PORT.
* RETURN CHARACTER IN ACCA.  EXIT WITH Z=0
* FOR TIMEOUT ERROR, Z = 1 FOR VALID BYTE INPUT.
8DBC  4F                L8DBC    CLRA                      ; CLEAR ATTEMPT COUNTER
8DBD  34 15                      PSHS  X,B,CC              ; SAVE REGISTERS AND INTERRUPT STATUS
8DBF  1A 50                      ORCC  #$50                ; DISABLE INTERRUPTS
8DC1  96 E7                      LDA   TIMOUT              ; GET TIMEOUT VARIABLE DELAY
8DC3  9E 8A                      LDX   ZERO                ; X=0: TIMEOUT CONSTANT DELAY
8DC5  8D 1F             L8DC5    BSR   L8DE6               ; GO GET RS 232 STATUS
8DC7  24 FC                      BCC   L8DC5               ; LOOP IF SPACING
8DC9  8D 1B             L8DC9    BSR   L8DE6               ; GET RS 232 STATUS
8DCB  25 FC                      BLO   L8DC9               ; LOOP IF MARKING
8DCD  8D 2A                      BSR   L8DF9               ; DELAY 1/2 BIT TIME
8DCF  C6 01                      LDB   #$01                ; * GET BIT SHIFT COUNTER AND BIT
8DD1  34 04                      PSHS  B                   ; * MASK AND SAVE IT ON STACK
8DD3  4F                         CLRA                      ; RESET DATA BYTE
8DD4  8D 21             L8DD4    BSR   L8DF7               ; GO DELAY ONE BIT TIME
8DD6  F6 FF 22                   LDB   PIA1+2              ; * RS 232 INPUT TO
8DD9  56                         RORB                      ; * CARRY FLAG
8DDA  24 02                      BCC   L8DDE               ; BRANCH IF RS 232 INPUT = 0 (SPACING)
8DDC  AA E4                      ORA   ,S                  ; IF MARKING, 'OR' A 1 BIT INTO DATA BYTE
8DDE  68 E4             L8DDE    ASL   ,S                  ; SHIFT BIT COUNTER ONE BIT TO LEFT
8DE0  24 F2                      BCC   L8DD4               ; CARRY WILL BE SET AFTER 8 SHIFTS
8DE2  32 61                      LEAS  $01,S               ; PULL BIT COUNTER OFF THE STACK
8DE4  35 95                      PULS  CC,B,X,PC           ; RESTORE INTERRUPT STATUS & RETURN

* PUT RS 232 STATUS INTO THE CARRY FLAG AND CHECK FOR TIMEOUT
8DE6  F6 FF 22          L8DE6    LDB   PIA1+2              ; * RS 232 INPUT TO
8DE9  56                         RORB                      ; * CARRY FLAG
8DEA  30 01                      LEAX  $01,X               ; = INCREMENT CONSTANT TIMEOUT
8DEC  26 08                      BNE   L8DF6               ; = DELAY, RETURN IF <> 0
8DEE  4A                         DECA                      ; * DECREMENT VARIABLE TIMEOUT
8DEF  26 05                      BNE   L8DF6               ; * DELAY: RETURN IF <> 0
* DLOAD HAS TIMED OUT HERE
8DF1  32 62                      LEAS  $02,S               ; PURGE RETURN ADDRESS OFF STACK
8DF3  35 15                      PULS  CC,B,X              ; CLEAN UP STACK/RESTORE INTERRUPTS
8DF5  4C                         INCA                      ; SET ACCA = 1; ZERO FLAG = 0
8DF6  39                L8DF6    RTS
* DELAY LOOP -- COUNT DOWN DLBAUD
8DF7  8D 00             L8DF7    BSR   L8DF9               ; CALL DELAY ROUTINE
8DF9  34 02             L8DF9    PSHS  A                   ; SAVE ACCA
8DFB  96 E6                      LDA   DLBAUD              ; GET DLOAD DELAY - 1/2 BIT TIME DELAY
8DFD  21 FE             L8DFD    BRN   L8DFD               ; DUMMY INST - JUST ADD TO DELAY
8DFF  4A                         DECA                      ; DEC DELAY TIMER
8E00  26 FB                      BNE   L8DFD               ; NOT DONE
8E02  35 82                      PULS  A,PC                ; RESTORE ACCA AND RETURN
*
8E04  34 02             L8E04    PSHS  A                   ; SAVE CHARACTER ON STACK
8E06  A8 21                      EORA  $01,Y               ; * EOR CHARACTER WITH 1,Y AND
8E08  A7 21                      STA   $01,Y               ; * SAVE RESULT IN 1,Y
8E0A  35 02                      PULS  A                   ; GET CHARACTER BACK

* SEND CHAR IN ACCA OUT OVER RS232 OUTPUT
8E0C  34 07             L8E0C    PSHS  B,A,CC              ; SAVE ACCD AND INTERRUPT STATUS
8E0E  1A 50                      ORCC  #$50                ; DISABLE INTERRUPTS
8E10  8D E5                      BSR   L8DF7               ; DELAY AWHILE
8E12  8D E3                      BSR   L8DF7               ; DELAY SOME MORE
8E14  7F FF 20                   CLR   PIA1                ; SET R5232 OUTPUT TO SPACING
8E17  8D DE                      BSR   L8DF7               ; DELAY SOME MORE - START BIT
8E19  C6 01                      LDB   #$01                ; BIT CTR - SEND 8 BITS
8E1B  34 04                      PSHS  B                   ; SAVE BIT CTR ON STACK
8E1D  A6 62             L8E1D    LDA   $02,S               ; GET OUTPUT BYTE
8E1F  A4 E4                      ANDA  ,S                  ; AND IT W/THE BIT CTR
8E21  27 02                      BEQ   L8E25               ; THIS BIT IN OUTPUT BYTE = 0
8E23  86 02                      LDA   #$02                ; OUTPUT BIT = 1; SET R5232 TO MARKING
8E25  B7 FF 20          L8E25    STA   PIA1                ; BET R5232 TO VALUE IN ACCA
8E28  8D CD                      BSR   L8DF7               ; DELAY FOR AWHILE
8E2A  68 E4                      ASL   ,S                  ; SHIFT BIT CTR
8E2C  24 EF                      BCC   L8E1D               ; WHEN CARRY SET, 8 BITS DONE
8E2E  86 02                      LDA   #$02                ; WHEN DONE, SET R5232 TO MARKING
8E30  B7 FF 20                   STA   PIA1                ; SET R5232 OUTPUT
8E33  32 61                      LEAS  $01,S               ; PULL BIT CTR OFF THE STACK
8E35  35 87                      PULS  CC,A,B,PC           ; RESTORE ACCD, INTERRUPTS & RETURN

* PROCESS EXCLAMATION POINT
8E37  86 01             L8E37    LDA   #$01                ; * SET SPACES
8E39  97 D9                      STA   VD9                 ; * COUNTER = 1
* PROCESS STRING ITEM - LIST
8E3B  5A                L8E3B    DECB                      ; DECREMENT FORMAT STRING LENGTH COUNTER
8E3C  BD 8F D8                   JSR   L8FD8               ; SEND A '+' TO CONSOLE OUT IF VDA <>0
8E3F  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
8E41  10 27 00 93                LBEQ  L8ED8               ; EXIT PRINT USING IF END OF LINE
8E45  D7 D3                      STB   VD3                 ; SAVE REMAINDER FORMAT STRING LENGTH
8E47  BD B1 56                   JSR   LB156               ; EVALUATE EXPRESSION
8E4A  BD B1 46                   JSR   LB146               ; 'TM' ERROR IF NUMERIC VARIABLE
8E4D  9E 52                      LDX   FPA0+2              ; * GET ITEM - LIST DESCRIPTOR ADDRESS
8E4F  9F 4D                      STX   V4D                 ; * AND SAVE IT IN V4D
8E51  D6 D9                      LDB   VD9                 ; GET SPACES COUNTER
8E53  BD B6 AD                   JSR   LB6AD               ; PUT ACCB BYTES INTO STRING SPACE & PUT DESCRIPTOR ON STRING STACK
8E56  BD B9 9F                   JSR   LB99F               ; PRINT THE FORMATTED STRING TO CONSOLE OUT
* PAD FORMAT STRING WITH SPACES IF ITEM - LIST STRING < FORMAT STRING LENGTH
8E59  9E 52                      LDX   FPA0+2              ; POINT X TO FORMATTED STRING DESCRIPTOR ADDRESS
8E5B  D6 D9                      LDB   VD9                 ; GET SPACES COUNTER
8E5D  E0 84                      SUBB  ,X                  ; SUBTRACT LENGTH OF FORMATTED STRING
8E5F  5A                L8E5F    DECB                      ; DECREMENT DIFFERENCE
8E60  10 2B 01 4F                LBMI  L8FB3               ; GO INTERPRET ANOTHER ITEM - LIST
8E64  BD B9 AC                   JSR   LB9AC               ; PAD FORMAT STRING WITH A SPACE
8E67  20 F6                      BRA   L8E5F               ; KEEP PADDING
* PERCENT SIGN - PROCESS A %SPACES% COMMAND
8E69  D7 D3             L8E69    STB   VD3                 ; * SAVE THE CURRENT FORMAT STRING
8E6B  9F 0F                      STX   TEMPTR              ; * COUNTER AND POINTER
8E6D  86 02                      LDA   #$02                ; INITIAL SPACES COUNTER = 2
8E6F  97 D9                      STA   VD9                 ; SAVE IN SPACES COUNTER
8E71  A6 84             L8E71    LDA   ,X                  ; GET A CHARACTER FROM FORMAT STRING
8E73  81 25                      CMPA  #'%'                ; COMPARE TO TERMINATOR CHARACTER
8E75  27 C4                      BEQ   L8E3B               ; BRANCH IF END OF SPACES COMMAND
8E77  81 20                      CMPA  #' '                ; BLANK
8E79  26 07                      BNE   L8E82               ; BRANCH IF ILLEGAL CHARACTER
8E7B  0C D9                      INC   VD9                 ; ADD ONE TO SPACES COUNTER
8E7D  30 01                      LEAX  $01,X               ; MOVE FORMAT POINTER UP ONE
8E7F  5A                         DECB                      ; DECREMENT LENGTH COUNTER
8E80  26 EF                      BNE   L8E71               ; BRANCH IF NOT END OF FORMAT STRING
8E82  9E 0F             L8E82    LDX   TEMPTR              ; * RESTORE CURRENT FORMAT STRING COUNTER
8E84  D6 D3                      LDB   VD3                 ; * AND POINTER TO POSITION BEFORE SPACES COMMAND
8E86  86 25                      LDA   #'%'                ; SEND A '%' TO CONSOLE OUT AS A DEBUGGING AID
* ERROR PROCESSOR - ILLEGAL CHARACTER OR BAD SYNTAX IN FORMAT STRING
8E88  BD 8F D8          L8E88    JSR   L8FD8               ; SEND A '+' TO CONSOLE OUT IF VDA <> 0
8E8B  BD A2 82                   JSR   LA282               ; SEND CHARACTER TO CONSOLE OUT
8E8E  20 29                      BRA   L8EB9               ; GET NEXT CHARACTER IN FORMAT STRING
