; Disk Extended Color BASIC 1.0 -- $D175-$D2CB
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: BACKUP=$D175

* BACKUP COMMAND
D175  10 27 D4 A6       BACKUP   LBEQ  LA61F               ; DEVICE NUMBER ERROR IF NO DRIVE NUMBERS GIVEN
D179  BD 95 AC                   JSR   L95AC               ; RESET SAM DISPLAY PAGE AND VOG MODE
D17C  BD D1 69                   JSR   >LD169              ; * GET SOURCE DRIVE NUMBER AND SAVE
D17F  F7 06 FF                   STB   DBUF0+255           ; * IT AT TOP OF DBUF0 (TOP OF NEW STACK)
D182  9D A5                      JSR   GETCCH              ; GET A CHARACTER FROM BASIC
D184  27 08                      BEQ   LD18E               ; BRANCH IF END OF LINE
D186  C6 A5                      LDB   #$A5                ; TOKEN FOR 'TO'
D188  BD B2 6F                   JSR   LB26F               ; SYNTAX CHECK FOR 'TO'
D18B  BD D1 69                   JSR   >LD169              ; GET DESTINATION DRIVE NUMBER
D18E  10 CE 06 FF       LD18E    LDS   #DBUF0+255          ; PUT STACK AT TOP OF DBUF0
D192  34 04                      PSHS  B                   ; SAVE DESTINATION DRIVE NUMBER ON STACK
D194  BD A5 C7                   JSR   LA5C7               ; SYNTAX ERROR IF NOT END OF LINE
D197  BD CA 3B                   JSR   DVEC7               ; CLOSE ALL FILES
D19A  6F E2                      CLR   ,-S                 ; CLEAR A TRACK COUNTER ON STACK
D19C  8E 09 88                   LDX   #DFLBUF-1           ; POINT X TO TOP OF DISK RAM VARIABLES
D19F  6C E4             LD19F    INC   ,S                  ; INCREMENT TRACK COUNTER
D1A1  30 89 12 00                LEAX  SECMAX*SECLEN,X     ; INCREMENT X BY ONE TRACK
D1A5  9C 27                      CMPX  MEMSIZ              ; COMPARE TO TOP OF NON RESERVED RAN
D1A7  23 F6                      BLS   LD19F               ; KEEP GOING IF MORE FREE RAM LEFT
D1A9  6A E4                      DEC   ,S                  ; DECREMENT TRACK COUNTER
D1AB  10 27 DA 95                LBEQ  LAC44               ; 'OM' ERROR IF < 1 TRACK OF FREE RAM
D1AF  86 23                      LDA   #TRKMAX             ; GET MAXIMUM NUMBER OF TRACKS — INITIALIZE REMAINING TRACKS CTR
D1B1  5F                         CLRB                      ; INITIALIZE TRACKS WRITTEN COUNTER TO ZERO
D1B2  34 06                      PSHS  B,A                 ; SAVE TRACKS WRITTEN AND REMAINING COUNTERS ON STACK

* AT THIS POINT THE STACK HAS THE FOLLOWING DATA ON IT:
* ,S = TRACKS REMAINING COUNTER; 1,S = TRACKS WRITTEN COUNTER
* 2,S = NUMBER OF TRACKS WHICH FIT IN RAM; 3,S = DESTINATION DRIVE NUMBER
* 4,S = SOURCE DRIVE NUMBER
D1B4  73 09 5C                   COM   DRESFL              ; SET THE DISK RESET FLAG TO CAUSE A RESET
D1B7  5F                LD1B7    CLRB                      ; INITIALIZE WRITE TRACK COUNTER TO ZERO
D1B8  5C                LD1B8    INCB                      ; ADD ONE TO WRITE TRACK COUNTER
D1B9  6A E4                      DEC   ,S                  ; * DECREMENT REMAINING TRACKS COUNTER
D1BB  27 04                      BEQ   LD1C1               ; * AND BRANCH IF NO TRACKS LEFT
D1BD  E1 62                      CMPB  $02,S               ; = COMPARE WRITE TRACK COUNTER TO NUMBER OF TRACKS THAT
D1BF  26 F7                      BNE   LD1B8               ; = WILL FIT IN RAM AND BRANCH IF ROOM FOR MORE TRACKS IN RAM
D1C1  D7 03             LD1C1    STB   TMPLOC              ; SAVE THE NUMBER OF TRACKS TO BE TRANSFERRED
D1C3  E6 64                      LDB   $04,S               ; GET SOURCE DRIVE NUMBER
D1C5  8D 48                      BSR   LD20F               ; FILL RAM BUFFER WITH TMPLOC TRACKS OF DATA
D1C7  86 FF                      LDA   #$FF                ; SET SOURCE/DESTINATION FLAG TO DESTINATION
D1C9  BD D2 35                   JSR   >LD235              ; PRINT PROMPT MESSAGE IF NEEDED
D1CC  E6 63                      LDB   $03,S               ; GET DESTINATION DRIVE NUMBER
D1CE  8D 42                      BSR   LD212               ; WRITE TMPLOC TRACKS FROM BUFFER
D1D0  6D E4                      TST   ,S                  ; TEST TRACKS REMAINING FLAG
D1D2  27 0C                      BEQ   LD1E0               ; BRANCH IF BACKUP DONE
D1D4  4F                         CLRA                      ; SET SOURCE/DESTINATION FLAG TO SOURCE
D1D5  BD D2 35                   JSR   >LD235              ; PRINT PROMPT MESSAGE IF NEEDED
D1D8  E6 61                      LDB   $01,S               ; * GET THE TRACKS WRITTEN COUNTER, ADD THE NUMBER OF
D1DA  DB 03                      ADDB  TMPLOC              ; * TRACKS MOVED THIS TIME THROUGH LOOP AND
D1DC  E7 61                      STB   $01,S               ; * SAVE THE NEW TRACKS WRITTEN COUNTER
D1DE  20 D7                      BRA   LD1B7               ; COPY SOME MORE TRACKS

D1E0  8D 03             LD1E0    BSR   LD1E5               ; CHECK FOR DOS INITIALIZATION
D1E2  7E AC 73                   JMP   LAC73               ; JUMP BACK TO BASIC'S MAIN LOOP

D1E5  35 40             LD1E5    PULS  U                   ; PUT THE RETURN ADDRESS IN U
D1E7  B6 09 5C                   LDA   DRESFL              ; TEST DISK RESET FLAG
D1EA  27 16                      BEQ   LD202               ; DON'T RESET THE DOS IF FLAG NOT SET
D1EC  8E 09 28                   LDX   #FCBV1              ; POINT X TO TABLE OF FCB ADDRESSES
D1EF  4F                         CLRA                      ; SET FILE COUNTER TO ZERO
D1F0  6F 91             LD1F0    CLR   [,X++]              ; MARK FCB AS CLOSED
D1F2  4C                         INCA                      ; ADD ONE TO FILE COUNTER
D1F3  B1 09 5B                   CMPA  FCBACT              ; COMPARE TO NUMBER OF RESERVED FILES
D1F6  23 F8                      BLS   LD1F0               ; BRANCH IF ANY FILES NOT SHUT DOWN
D1F8  9E 19                      LDX   TXTTAB              ; LOAD X WITH THE START OF BASIC
D1FA  6F 1F                      CLR   -1,X                ; SET FIRST BYTE OF BASIC PROGRAM TO ZERO
D1FC  BD AD 19                   JSR   LAD19               ; GO DO A 'NEW'
D1FF  7F 09 5C                   CLR   DRESFL              ; RESET THE DOS RESET FLAG
D202  B6 09 5D          LD202    LDA   DLODFL              ; * CHECK THE LOAD RESET FLAG AND
D205  27 06                      BEQ   LD20D               ; * BRANCH IF NOT SET
D207  7F 09 5D                   CLR   DLODFL              ; CLEAR THE LOAD RESET FLAG
D20A  BD AD 19                   JSR   LAD19               ; GO DO A 'NEW'
D20D  6E C4             LD20D    JMP   ,U                  ; JUMP BACK TO RETURN ADDRESS SAVED IN U ABOVE

D20F  86 02                      LDA   #$02                ; READ OP CODE
D211  8C 86 03          LD211    CMPX  #$8603              ; SKIP TWO BYTES
D212  86 03             LD212    LDA   #$03                ; WRITE OP CODE [bytes corrected to match genuine ROM; spreadsheet had 86 33]
D214  DD EA                      STD   DCOPC               ; SAVE IN DSKCON VARIABLE
D216  A6 63                      LDA   $03,S               ; * GET THE NUMBER OF THE TRACK BEING CURRENTLY
D218  97 EC                      STA   DCTRK               ; * WRITTEN AND SAVE IT IN DSKCON VARIABLE
D21A  8E 09 89                   LDX   #DFLBUF             ; = TRACK BUFFER STARTS AT DFLBUF
D21D  9F EE                      STX   DCBPT               ; = SAVE IT IN DSKCON VARIABLE
D21F  96 03                      LDA   TMPLOC              ; GET NUMBER OF TRACKS TO MOVE
D221  C6 01             LD221    LDB   #$01                ; INITIALIZE SECTOR COUNTER TO ONE
D223  D7 ED             LD223    STB   DSEC                ; SAVE DSKCON SECTOR VARIABLE
D225  BD D5 FF                   JSR   LD5FF               ; READ/WRITE A SECTOR
D228  0C EE                      INC   DCBPT               ; MOVE BUFFER POINTER UP ONE SECTOR (256 BYTES)
D22A  5C                         INCB                      ; INCREMENT SECTOR COUNTER
D22B  C1 12                      CMPB  #SECMAX             ; COMPARE TO MAXIMUM NUMBER OF SECTORS PER TRACK
D22D  23 F4                      BLS   LD223               ; BRANCH IF ANY SECTORS LEFT
D22F  0C EC                      INC   DCTRK               ; INCREMENT TRACK COUNTER VARIABLE TO NEXT TRACK
D231  4A                         DECA                      ; DECREMENT TRACKS TO MOVE COUNTER
D232  26 ED                      BNE   LD221               ; READ MORE TRACKS IF ANY LEFT
D234  39                         RTS

D235  E6 65             LD235    LDB   $05,S               ; * GET THE DESTINATlON DRIVE NUMBER AND
D237  E1 66                      CMPB  $06,S               ; * COMPARE IT TO THE SOURCE DRIVE NUMBER

* PRINT SOURCE/DESTINATION DISK SWITCH PROMPT MESSAGE
D239  26 36             LD239    BNE   LD271               ; RETURN IF DRIVE NUMBERS NOT EQUAL
D23B  7F 09 85                   CLR   RDYTMR              ; RESET THE READY TIMER
D23E  7F FF 40                   CLR   DSKREG              ; CLEAR DSKREG - TURN OFF ALL DISK MOTORS
D241  7F 09 86                   CLR   DRGRAM              ; CLEAR DSKREG RAM IMAGE
D244  34 02                      PSHS  A                   ; SAVE SOURCE/DESTINATION FLAG ON STACK
D246  BD A9 28                   JSR   LA928               ; CLEAR SCREEN
D249  8E D2 72                   LDX   #LD272              ; POINT X TO 'INSERT SOURCE' MESSAGE
D24C  C6 0D                      LDB   #13                 ; 13 BYTES IN MESSAGE
D24E  A6 E0                      LDA   ,S+                 ; GET SOURCE/DESTINATION FLAG FROM THE STACK
D250  27 05                      BEQ   LD257               ; BRANCH IF SOURCE
D252  8E D2 7F                   LDX   #LD27F              ; POINT X TO 'INSERT DESTINATION' MESSAGE
D255  C6 12                      LDB   #18                 ; 18 BYTES IN MESSAGE
D257  BD B9 A2          LD257    JSR   LB9A2               ; SEND MESSAGE TO CONSOLE OUT
D25A  8E D2 91                   LDX   #LD291              ; POINT X TO 'DISKETTE AND' MESSAGE
D25D  C6 1B                      LDB   #27                 ; 27 BYTES IN MESSAGE
D25F  BD B9 A2                   JSR   LB9A2               ; SEND MESSAGE TO CONSOLE OUT
D262  CC 64 05                   LDD   #$6405              ; * SET UP 'SOUND' PARAMETERS
D265  97 8C                      STA   SNDTON              ; * FOR A BEEP
D267  BD A9 51                   JSR   LA951               ; JUMP TO 'SOUND' - DO A BEEP
D26A  BD A1 71          LD26A    JSR   LA171               ; GET A CHARACTER FROM CONSOLE IN
D26D  81 0D                      CMPA  #CR                 ; * KEEP LOOKING AT CONSOLE IN UNTIL
D26F  26 F9                      BNE   LD26A               ; * YOU GET A CARRIAGE RETURN
D271  39                LD271    RTS

D272  49 4E 53 45 52 54 LD272    FCC   'INSERT SOURCE'
D278  20 53 4F 55 52 43
D27E  45
D27F  49 4E 53 45 52 54 LD27F    FCC   'INSERT DESTINATION'
D285  20 44 45 53 54 49
D28B  4E 41 54 49 4F 4E
D291  20 44 49 53 4B 45 LD291    FCC   ' DISKETTE AND'
D297  54 54 45 20 41 4E
D29D  44
D29E  0D                         FCB   CR
D29F  50 52 45 53 53 20          FCC   'PRESS 'ENTER''
D2A5  27 45 4E 54 45 52
D2AB  27

* PUSH FILENAME.EXT AND DRIVE NUMBER ONTO THE STACK
D2AC  35 20             LD2AC    PULS  Y                   ; SAVE RETURN ADDRESS IN Y
D2AE  C6 0B                      LDB   #11                 ; 11 CHARACTERS IN FILENAME AND EXTENSION
D2B0  8E 09 57                   LDX   #DNAMBF+11          ; POINT X TO TOP OF DISK NAME/EXT BUFFER
D2B3  A6 82             LD2B3    LDA   ,-X                 ; * GET A CHARACTER FROM FILENAME.
D2B5  34 02                      PSHS  A                   ; * EXT BUFFER AND PUSH IT ONTO THE
D2B7  5A                         DECB                      ; * STACK - DECREMENT COUNTER AND
D2B8  26 F9                      BNE   LD2B3               ; * KEEP LOOPING UNTIL DONE
D2BA  96 EB                      LDA   DCDRV               ; = GET DRIVE NUMBER AND PUSH
D2BC  34 02                      PSHS  A                   ; = IT ONTO THE STACK
D2BE  6E A4                      JMP   ,Y                  ; PSEUDO - RETURN TO CALLING ROUTINE

* PULL FILENAME.EXT AND DRIVE NUMBER FROM (X) TO RAM
D2C0  A6 80             LD2C0    LDA   ,X+                 ; * GET DRIVE NUMBER AND SAVE
D2C2  97 EB                      STA   DCDRV               ; * IT IN DSKCON VARIABLE
D2C4  C6 0B                      LDB   #11                 ; 11 BYTES IN FILENAME AND EXTENSION
D2C6  CE 09 4C                   LDU   #DNAMBF             ; POINT U TO DISK NAME BUFFER
D2C9  7E A5 9A                   JMP   LA59A               ; MOVE FILENANE.EXT FROM (X) TO DNAMBF
