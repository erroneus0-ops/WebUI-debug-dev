; Color BASIC 1.2 -- $A000-$A1CA
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: POLCAT=$A000, CHROUT=$A002, CSRDON=$A004, BLKIN=$A006, BLKOUT=$A008, JOYIN=$A00A, WRTLDR=$A00C, RESVEC=$A027, BACDST=$A074, BAWMST=$A0E8, BFRQSV=$A0F6

A000                             ORG   $A000
A000  A1 CB             POLCAT   FDB   KEYIN               ; GET A KEYSTROKE
A002  A2 82             CHROUT   FDB   PUTCHR              ; OUTPUT A CHARACTER
A004  A7 7C             CSRDON   FDB   CASON               ; TURN ON CASSETTE MOTOR, START READING
A006  A7 0B             BLKIN    FDB   GETBLK              ; READ A BLOCK FROM CASSETTE
A008  A7 F4             BLKOUT   FDB   SNDBLK              ; WRITE A BLOCK TO CASSETTE
A00A  A9 DE             JOYIN    FDB   GETJOY              ; READ JOYSTICKS
A00C  A7 D8             WRTLDR   FDB   WRLDR               ; TURN ON MOTOR AND WRITE $55'S TO CASSETTE
*
A00E  10 CE 03 D7       LA00E    LDS   #LINBUF+LBUFMX+1    ; SET STACK TO TOP OF LINE INPUT BUFFER
A012  86 37                      LDA   #$37                ; *
A014  B7 FF 23                   STA   PIA1+3              ; * ENABLE 63.5 MICROSECOND INTERRUPT
A017  96 71                      LDA   RSTFLG              ; GET WARM START FLAG
A019  81 55                      CMPA  #$55                ; IS IT A WARM START?
A01B  26 57                      BNE   BACDST              ; NO - D0 A COLD START
A01D  9E 72                      LDX   RSTVEC              ; WARM START VECTOR
A01F  A6 84                      LDA   ,X                  ; GET FIRST BYTE OF WARM START ADDR
A021  81 12                      CMPA  #$12                ; IS IT NOP?
A023  26 4F                      BNE   BACDST              ; NO - DO A COLD START
A025  6E 84                      JMP   ,X                  ; YES, G0 THERE

A027  31 8C E4          RESVEC   LEAY  LA00E,PC            ; POINT Y TO WARM START CHECK CODE
A02A  8E FF 20          LA02A    LDX   #PIA1               ; POINT X TO PIA1
A02D  6F 1D                      CLR   -3,X                ; CLEAR PIA0 CONTROL REGISTER A
A02F  6F 1F                      CLR   -1,X                ; CLEAR PIA0 CONTROL REGISTER B
A031  6F 1C                      CLR   -4,X                ; SET PIA0 SIDE A TO INPUT
A033  CC FF 34                   LDD   #$FF34              ; *
A036  A7 1E                      STA   -2,X                ; * SET PIA0 SIDE B TO OUTPUT
A038  E7 1D                      STB   -3,X                ; * ENABLE PIA0 PERIPHERAL REGISTERS, DISABLE PIA0
A03A  E7 1F                      STB   -1,X                ; * MPU INTERRUPTS, SET CA2, CA1 TO OUTPUTS
A03C  6F 01                      CLR   1,X                 ; CLEAR CONTROL REGISTER A ON PIA1
A03E  6F 03                      CLR   3,X                 ; CLEAR CONTROL REGISTER B ON PIA1
A040  4A                         DECA                      ; A REG NOW HAS $FE
A041  A7 84                      STA   ,X                  ; BITS 1-7 ARE OUTPUTS, BIT 0 IS INPUT ON PIA1 SIDE A
A043  86 F8                      LDA   #$F8                ; =
A045  A7 02                      STA   2,X                 ; = BITS 0-2 ARE INPUTS, BITS 3-7 ARE OUTPUTS ON B SIDE
A047  E7 01                      STB   1,X                 ; * ENABLE PERIPHERAL REGISTERS, DISABLE PIA1 MPU
A049  E7 03                      STB   3,X                 ; * INTERRUPTS AND SET CA2, CB2 AS OUTPUTS
A04B  6F 02                      CLR   2,X                 ; SET 6847 MODE TO ALPHA-NUMERIC
A04D  C6 02                      LDB   #$02                ; *
A04F  E7 84                      STB   ,X                  ; * MAKE RS232 OUTPUT MARKING
A051  CE FF C0                   LDU   #SAMREG             ; SAM CONTROL REGISTER ADDR
A054  C6 10                      LDB   #16                 ; 16 SAM CONTROL REGISTER BITS
A056  A7 C1             LA056    STA   ,U++                ; ZERO OUT SAM CONTROL REGISTER BIT
A058  5A                         DECB                      ; * DECREMENT COUNTER AND
A059  26 FB                      BNE   LA056               ; * BRANCH IF NOT DONE
A05B  B7 FF C9                   STA   SAMREG+9            ; SET DISPLAY PAGE AT $400
A05E  1F 9B                      TFR   B,DP                ; SET DIRECT PAGE TO ZERO
A060  C6 04                      LDB   #$04                ; USE AS A MASK TO CHECK RAMSZ INPUT
A062  A7 1E                      STA   -2,X                ; SET RAMSZ STROBE HIGH
A064  E5 02                      BITB  2,X                 ; CHECK RAMSZ INPUT
A066  27 0A                      BEQ   LA072               ; BRANCH IF JUMPER SET FOR 4K RAMS
A068  6F 1E                      CLR   -2,X                ; SET RAMSZ STROBE LOW
A06A  E5 02                      BITB  2,X                 ; CHECK RAMSZ INPUT
A06C  27 02                      BEQ   LA070               ; BRANCH IF JUMPER SET FOR 64K RAMS
A06E  33 5E                      LEAU  -2,U                ; ADJUST POINTER TO SET SAM FOR 16K RAMS
A070  A7 5D             LA070    STA   -3,U                ; PROGRAM SAM FOR 16K OR 64K RAMS
A072  6E A4             LA072    JMP   ,Y                  ; GO DO A WARM OR COLD START
* COLD START ENTRY
A074  8E 04 01          BACDST   LDX   #VIDRAM+1           ; POINT X TO CLEAR 1ST 1K OF RAM
A077  6F 83             LA077    CLR   ,--X                ; MOVE POINTER DOWN TWO-CLEAR BYTE
A079  30 01                      LEAX  1,X                 ; ADVANCE POINTER ONE
A07B  26 FA                      BNE   LA077               ; KEEP GOING IF NOT AT BOTTOM OF PAGE 0
A07D  BD A9 28                   JSR   LA928               ; CLEAR SCREEN
A080  6F 80                      CLR   ,X+                 ; CLEAR 1ST BYTE OF BASIC PROGRAM
A082  9F 19                      STX   TXTTAB              ; BEGINNING OF BASIC PROGRAM
A084  A6 02             LA084    LDA   2,X                 ; LOOK FOR END OF MEMORY
A086  43                         COMA                      ; * COMPLEMENT IT AND PUT IT BACK
A087  A7 02                      STA   2,X                 ; * INTO SYSTEM MEMORY
A089  A1 02                      CMPA  2,X                 ; IS IT RAM?
A08B  26 06                      BNE   LA093               ; BRANCH IF NOT (ROM, BAD RAM OR NO RAM)
A08D  30 01                      LEAX  1,X                 ; MOVE POINTER UP ONE
A08F  63 01                      COM   1,X                 ; RE-COMPLEMENT TO RESTORE BYTE
A091  20 F1                      BRA   LA084               ; KEEP LOOKING FOR END OF RAM
A093  9F 74             LA093    STX   TOPRAM              ; SAVE ABSOLUTE TOP OF RAM
A095  9F 27                      STX   MEMSIZ              ; SAVE TOP OF STRING SPACE
A097  9F 23                      STX   STRTAB              ; SAVE START OF STRING VARIABLES
A099  30 89 FF 38                LEAX  -200,X              ; CLEAR 200 - DEFAULT STRING SPACE TO 200 BYTES
A09D  9F 21                      STX   FRETOP              ; SAVE START OF STRING SPACE
A09F  1F 14                      TFR   X,S                 ; PUT STACK THERE
A0A1  8E A1 0D                   LDX   #LA10D              ; POINT X TO ROM SOURCE DATA
A0A4  CE 00 8F                   LDU   #CMPMID             ; POINT U TO RAM DESTINATION
A0A7  C6 1C                      LDB   #28                 ; MOVE 28 BYTES
A0A9  BD A5 9A                   JSR   LA59A               ; MOVE 28 BYTES FROM ROM TO RAM
A0AC  CE 01 0C                   LDU   #IRQVEC             ; POINT U TO NEXT RAM DESTINATION
A0AF  C6 1E                      LDB   #30                 ; MOVE 30 MORE BYTES
A0B1  BD A5 9A                   JSR   LA59A               ; MOVE 30 BYTES FROM ROM TO RAM
A0B4  AE 14                      LDX   -12,X               ; POINT X TO SYNTAX ERROR ADDRESS
A0B6  AF 43             LA0B6    STX   3,U                 ; * SET EXBAS COMMAND INTERPRETATION
A0B8  AF 48                      STX   8,U                 ; * HANDLERS TO SYNTAX ERROR
A0BA  8E 01 5E                   LDX   #RVEC0              ; POINT X TO START OF RAM VECTORS
A0BD  CC 39 4B                   LDD   #$394B              ; SET UP TO SAVE 75 RTS'
A0C0  A7 80             LA0C0    STA   ,X+                 ; FILL THE RAM VECTORS WITH RTS'
A0C2  5A                         DECB                      ; * DECREMENT COUNTER AND
A0C3  26 FB                      BNE   LA0C0               ; * BRANCH IF NOT DONE
A0C5  B7 02 D9                   STA   LINHDR-1            ; PUT RTS IN LINHDR-1
A0C8  BD AD 19                   JSR   LAD19               ; G0 DO A 'NEW'
A0CB  8E 45 58                   LDX   #$4558              ; ASCII 'EX' (FIRST TWO LETTERS OF 'EXTENDED')
A0CE  BC 80 00                   CMPX  EXBAS               ; SEE IF EXTENDED ROM IS THERE
A0D1  10 27 DF 2D                LBEQ  EXBAS+2             ; IF IT IS, BRANCH TO IT
A0D5  1C AF                      ANDCC #$AF                ; ENABLE IRQ, FIRQ
A0D7  8E A1 46                   LDX   #LA147-1            ; POINT X TO COLOR BASIC COPYRIGHT MESSAGE
A0DA  BD B9 9C                   JSR   LB99C               ; PRINT 'COLOR BASIC'
A0DD  8E A0 E8                   LDX   #BAWMST             ; WARM START ADDRESS
A0E0  9F 72                      STX   RSTVEC              ; SAVE IT
A0E2  86 55                      LDA   #$55                ; WARM START FLAG
A0E4  97 71                      STA   RSTFLG              ; SAVE IT
A0E6  20 0B                      BRA   LA0F3               ; GO TO BASIC'S MAIN LOOP
A0E8  12                BAWMST   NOP                       ; NOP REQ'D FOR WARM START
A0E9  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
A0EB  BD AD 33                   JSR   LAD33               ; DO PART OF A NEW
A0EE  1C AF                      ANDCC #$AF                ; ENABLE IRQ,FIRQ
A0F0  BD A9 28                   JSR   LA928               ; CLEAR SCREEN
A0F3  7E AC 73          LA0F3    JMP   LAC73               ; GO TO MAIN LOOP OF BASIC
*
* FIRQ SERVICE ROUTINE
A0F6  7D FF 23          BFRQSV   TST   PIA1+3              ; CARTRIDGE INTERRUPT?
A0F9  2B 01                      BMI   LA0FC               ; YES
A0FB  3B                         RTI
A0FC  BD A7 D1          LA0FC    JSR   LA7D1               ; DELAY FOR A WHILE
A0FF  BD A7 D1                   JSR   LA7D1               ; KEEP DELAYING
A102  31 8C 03          LA102    LEAY  <LA108,PC           ; Y = ROM-PAK START UP VECTOR
A105  7E A0 2A                   JMP   LA02A               ; GO DO INITIALIZATION
A108  0F 71             LA108    CLR   RSTFLG              ; CLEAR WARM START FLAG
A10A  7E C0 00                   JMP   ROMPAK              ; JUMP TO EXTERNAL ROM PACK
*
* THESE BYTES ARE MOVED TO ADDRESSES $8F - $AA THE DIRECT PAGE
A10D  12                LA10D    FCB   18                  ; MID BAND PARTITION OF 1200/2400 HERTZ PERIOD
A10E  18                         FCB   24                  ; UPPER LIMIT OF 1200 HERTZ PERIOD
A10F  0A                         FCB   10                  ; UPPER LIMIT OF 2400 HERTZ PERIOD
A110  00 80                      FDB   128                 ; NUMBER OF 55'S TO CASSETTE LEADER
A112  0B                         FCB   11                  ; CURSOR BLINK DELAY
A113  00 58                      FDB   88                  ; CONSTANT FOR 600 BAUD VER 1.2 & UP
A115  00 01                      FDB   1                   ; PRINTER CARRIAGE RETURN DELAY
A117  10                         FCB   16                  ; TAB FIELD WIDTH
A118  70                         FCB   112                 ; LAST TAB ZONE
A119  84                         FCB   132                 ; PRINTER WIDTH
A11A  00                         FCB   0                   ; LINE PRINTER POSITION
A11B  B4 4A                      FDB   LB44A               ; ARGUMENT OF EXEC COMMAND - SET TO 'FC' ERROR
* LINE INPUT ROUTINE
A11D  0C A7                      INC   CHARAD+1
A11F  26 02                      BNE   LA123
A121  0C A6                      INC   CHARAD
A123  B6 00 00          LA123    LDA   >0000
A126  7E AA 1A                   JMP   BROMHK
*
* THESE BYTES ARE MOVED TO ADDRESSES $10C-$129
A129  7E A9 B3                   JMP   BIRQSV              ; IRQ SERVICE
A12C  7E A0 F6                   JMP   >BFRQSV             ; FIRQ SERVICE
A12F  7E B4 4A                   JMP   LB44A               ; USR ADDRESS FOR 8K BASIC (INITIALIZED TO 'FC' ERROR)
A132  80 4F                      FCB   $80                 ; *RANDOM SEED
A133  4F C7                      FDB   $4FC7               ; *RANDON SEED OF MANTISSA
A135  52 59                      FCB   $5259               ; *.811635157
A137  FF                         FCB   $FF                 ; UPPER CASE/LOWER CASE FLAG (STARTS SET TO UPPER)
A138  04 5E                      FDB   DEBDEL              ; KEYBOARD DEBOUNCE DELAY
A13A  7E B2 77                   JMP   LB277               ; DISPATCH FOR EXPONENTIATION (INITIALIZED TO SYNTAX ERROR)
* BASIC COMMAND INTERPRETATION TABLE ROM IMAGE
A13D  35                LA13D    FCB   53                  ; 53 BASIC COMMANDS
A13E  AA 66             LA13E    FDB   LAA66               ; POINTS TO RESERVED WORDS
A140  AB 67             LA140    FDB   LAB67               ; POINTS TO JUMP TABLE FOR COMMANDS
A142  14                LA142    FCB   20                  ; 20 BASIC SECONDARY COMMANDS
A143  AB 1A             LA143    FDB   LAB1A               ; POINTS TO SECONDARY FUNCTION RESERVED WORDS
A145  AA 29             LA145    FDB   LAA29               ; POINTS TO SECONDARY FUNCTION JUMP TABLE
* COPYRIGHT MESSAGES
A147  43 4F 4C 4F 52 20 LA147    FCC   'COLOR BASIC 1.2'
A14D  42 41 53 49 43 20
A153  31 2E 32
A156  0D                LA156    FCB   CR
A157  28 43 29 20 31 39 LA157    FCC   '(C) 1982 TANDY'
A15D  38 32 20 54 41 4E
A163  44 59
A165  00                LA165    FCB   $00
A166  4D 49 43 52 4F 53 LA166    FCC   'MICROSOFT'
A16C  4F 46 54
A16F  0D 00             LA16F    FCB   CR,$00

A171  8D 03             LA171    BSR   LA176               ; GET A CHARACTER FROM CONSOLE IN
A173  84 7F                      ANDA  #$7F                ; MASK OFF BIT 7
A175  39                         RTS

* CONSOLE IN
A176  BD 01 6A          LA176    JSR   RVEC4               ; HOOK INTO RAM
A179  0F 70                      CLR   CINBFL              ; RESET CONSOLE IN BUFFER FLAG = FULL
A17B  0D 6F             LA17B    TST   DEVNUM              ; CHECK DEVICE NUMBER
A17D  27 32                      BEQ   LA1B1               ; G0 DO CURSOR AND GET A KEY IF SCREEN MODE
A17F  0D 79                      TST   CINCTR              ; TEST CHARACTER COUNTER
A181  26 03                      BNE   LA186               ; NOT EMPTY - READ IN SOME CASSETTE DATA
A183  03 70                      COM   CINBFL              ; SET TO $FF: CONSOLE IN BUFFER EMPTY
A185  39                LA185    RTS
*
A186  34 74             LA186    PSHS  U,Y,X,B             ; SAVE REGISTERS
A188  9E 7A                      LDX   CINPTR              ; PICK UP BUFFER POINTER
A18A  A6 80                      LDA   ,X+                 ; GET NEXT CHAR
A18C  34 02                      PSHS  A                   ; SAVE CHAR ON STACK
A18E  9F 7A                      STX   CINPTR              ; SAVE NEW BUFFER POINTER
A190  0A 79             LA190    DEC   CINCTR              ; DECR CHAR COUNT
A192  26 03                      BNE   LA197               ; RETURN IF BUFFER NOT EMPTY
A194  BD A6 35                   JSR   LA635               ; GO READ TAPE
A197  35 F6             LA197    PULS  A,B,X,Y,U,PC        ; RESTORE REGISTERS
*
A199  0A 94             LA199    DEC   BLKCNT              ; CURSOR BLINK DELAY
A19B  26 0E                      BNE   LA1AB               ; NOT TIME FOR NEW COLOR
A19D  C6 0B                      LDB   #11                 ; *
A19F  D7 94                      STB   BLKCNT              ; *RESET DELAY COUNTER
A1A1  9E 88                      LDX   CURPOS              ; GET CURSOR POSITION
A1A3  A6 84                      LDA   ,X                  ; GET CURRENT CURSOR CHAR
A1A5  8B 10                      ADDA  #$10                ; BUMP TO NEXT COLOR
A1A7  8A 8F                      ORA   #$8F                ; MAKE SURE IT'S A SOLID GRAPHICS BLOCK
A1A9  A7 84                      STA   ,X                  ; STORE TO SCREEN
A1AB  8E 04 5E          LA1AB    LDX   #DEBDEL             ; CURSOR BLINK DELAY
A1AE  7E A7 D3          LA1AE    JMP   LA7D3               ; DELAY WHILE X DECREMENTS TO ZERO

* BLINK CURSOR WHILE WAITING FOR A KEYSTROKE
A1B1  34 14             LA1B1    PSHS  X,B                 ; SAVE REGISTERS
A1B3  8D E4             LA1B3    BSR   LA199               ; GO DO CURSOR
A1B5  8D 14                      BSR   KEYIN               ; GO CHECK KEYBOARD
A1B7  27 FA                      BEQ   LA1B3               ; LOOP IF NO KEY DOWN
A1B9  C6 60                      LDB   #$60                ; BLANK
A1BB  E7 9F 00 88                STB   [CURPOS]            ; BLANK CURRENT CURSOR CHAR ON SCREEN
A1BF  35 94             LA1BF    PULS  B,X,PC
*
* THIS ROUTINE GETS A KEYSTROKE FROM THE KEYBOARD IF A KEY
* IS DOWN. IT RETURNS ZERO TRUE IF THERE WAS NO KEY DOWN.
*
A1C1  7F FF 02          LA1C1    CLR   PIA0+2              ; CLEAR COLUMN STROBE
A1C4  B6 FF 00                   LDA   PIA0                ; READ KEY ROWS
A1C7  43                         COMA                      ; COMPLEMENT ROW DATA
A1C8  48                         ASLA                      ; SHIFT OFF JOYSTICK DATA
A1C9  27 79                      BEQ   LA244               ; RETURN IF NO KEYS OR FIRE BUTTONS DOWN
