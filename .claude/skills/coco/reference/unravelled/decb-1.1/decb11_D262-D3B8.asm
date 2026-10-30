; Disk Extended Color BASIC 1.1 -- $D262-$D3B8
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: BACKUP=$D262

* BACKUP COMMAND
D262  10 27 D3 B9       BACKUP   LBEQ  LA61F               ; DEVICE NUMBER ERROR IF NO DRIVE NUMBERS GIVEN
D266  BD 95 AC                   JSR   L95AC               ; RESET SAM DISPLAY PAGE AND VOG MODE
D269  BD D2 56                   JSR   >LD256              ; * GET SOURCE DRIVE NUMBER AND SAVE
D26C  F7 06 FF                   STB   DBUF0+255           ; * IT AT TOP OF DBUF0 (TOP OF NEW STACK)
D26F  9D A5                      JSR   GETCCH              ; GET A CHARACTER FROM BASIC
D271  27 08                      BEQ   LD27B               ; BRANCH IF END OF LINE
D273  C6 A5                      LDB   #$A5                ; TOKEN FOR 'TO'
D275  BD B2 6F                   JSR   LB26F               ; SYNTAX CHECK FOR 'TO'
D278  BD D2 56                   JSR   >LD256              ; GET DESTINATION DRIVE NUMBER
D27B  10 CE 06 FF       LD27B    LDS   #DBUF0+255          ; PUT STACK AT TOP OF DBUF0
D27F  34 04                      PSHS  B                   ; SAVE DESTINATION DRIVE NUMBER ON STACK
D281  BD A5 C7                   JSR   LA5C7               ; SYNTAX ERROR IF NOT END OF LINE
D284  BD CA E9                   JSR   DVEC7               ; CLOSE ALL FILES
D287  6F E2                      CLR   ,-S                 ; CLEAR A TRACK COUNTER ON STACK
D289  8E 09 88                   LDX   #DFLBUF-1           ; POINT X TO TOP OF DISK RAM VARIABLES
D28C  6C E4             LD28C    INC   ,S                  ; INCREMENT TRACK COUNTER
D28E  30 89 12 00                LEAX  SECMAX*SECLEN,X     ; INCREMENT X BY ONE TRACK
D292  9C 27                      CMPX  MEMSIZ              ; COMPARE TO TOP OF NON RESERVED RAN
D294  23 F6                      BLS   LD28C               ; KEEP GOING IF MORE FREE RAM LEFT
D296  6A E4                      DEC   ,S                  ; DECREMENT TRACK COUNTER
D298  10 27 D9 A8                LBEQ  LAC44               ; 'OM' ERROR IF < 1 TRACK OF FREE RAM
D29C  86 23                      LDA   #TRKMAX             ; GET MAXIMUM NUMBER OF TRACKS — INITIALIZE REMAINING TRACKS CTR
D29E  5F                         CLRB                      ; INITIALIZE TRACKS WRITTEN COUNTER TO ZERO
D29F  34 06                      PSHS  B,A                 ; SAVE TRACKS WRITTEN AND REMAINING COUNTERS ON STACK

* AT THIS POINT THE STACK HAS THE FOLLOWING DATA ON IT:
* ,S = TRACKS REMAINING COUNTER; 1,S = TRACKS WRITTEN COUNTER
* 2,S = NUMBER OF TRACKS WHICH FIT IN RAM; 3,S = DESTINATION DRIVE NUMBER
* 4,S = SOURCE DRIVE NUMBER
D2A1  73 09 5C                   COM   DRESFL              ; SET THE DISK RESET FLAG TO CAUSE A RESET
D2A4  5F                LD2A4    CLRB                      ; INITIALIZE WRITE TRACK COUNTER TO ZERO
D2A5  5C                LD2A5    INCB                      ; ADD ONE TO WRITE TRACK COUNTER
D2A6  6A E4                      DEC   ,S                  ; * DECREMENT REMAINING TRACKS COUNTER
D2A8  27 04                      BEQ   LD2AE               ; * AND BRANCH IF NO TRACKS LEFT
D2AA  E1 62                      CMPB  $02,S               ; = COMPARE WRITE TRACK COUNTER TO NUMBER OF TRACKS THAT
D2AC  26 F7                      BNE   LD2A5               ; = WILL FIT IN RAM AND BRANCH IF ROOM FOR MORE TRACKS IN RAM
D2AE  D7 03             LD2AE    STB   TMPLOC              ; SAVE THE NUMBER OF TRACKS TO BE TRANSFERRED
D2B0  E6 64                      LDB   $04,S               ; GET SOURCE DRIVE NUMBER
D2B2  8D 48                      BSR   LD2FC               ; FILL RAM BUFFER WITH TMPLOC TRACKS OF DATA
D2B4  86 FF                      LDA   #$FF                ; SET SOURCE/DESTINATION FLAG TO DESTINATION
D2B6  BD D3 22                   JSR   >LD322              ; PRINT PROMPT MESSAGE IF NEEDED
D2B9  E6 63                      LDB   $03,S               ; GET DESTINATION DRIVE NUMBER
D2BB  8D 42                      BSR   LD2FF               ; WRITE TMPLOC TRACKS FROM BUFFER
D2BD  6D E4                      TST   ,S                  ; TEST TRACKS REMAINING FLAG
D2BF  27 0C                      BEQ   LD2CD               ; BRANCH IF BACKUP DONE
D2C1  4F                         CLRA                      ; SET SOURCE/DESTINATION FLAG TO SOURCE
D2C2  BD D3 22                   JSR   >LD322              ; PRINT PROMPT MESSAGE IF NEEDED
D2C5  E6 61                      LDB   $01,S               ; * GET THE TRACKS WRITTEN COUNTER, ADD THE NUMBER OF
D2C7  DB 03                      ADDB  TMPLOC              ; * TRACKS MOVED THIS TIME THROUGH LOOP AND
D2C9  E7 61                      STB   $01,S               ; * SAVE THE NEW TRACKS WRITTEN COUNTER
D2CB  20 D7                      BRA   LD2A4               ; COPY SOME MORE TRACKS

D2CD  8D 03             LD2CD    BSR   LD2D2               ; CHECK FOR DOS INITIALIZATION
D2CF  7E AC 73                   JMP   LAC73               ; JUMP BACK TO BASIC'S MAIN LOOP

D2D2  35 40             LD2D2    PULS  U                   ; PUT THE RETURN ADDRESS IN U
D2D4  B6 09 5C                   LDA   DRESFL              ; TEST DISK RESET FLAG
D2D7  27 16                      BEQ   LD2EF               ; DON'T RESET THE DOS IF FLAG NOT SET
D2D9  8E 09 28                   LDX   #FCBV1              ; POINT X TO TABLE OF FCB ADDRESSES
D2DC  4F                         CLRA                      ; SET FILE COUNTER TO ZERO
D2DD  6F 91             LD2DD    CLR   [,X++]              ; MARK FCB AS CLOSED
D2DF  4C                         INCA                      ; ADD ONE TO FILE COUNTER
D2E0  B1 09 5B                   CMPA  FCBACT              ; COMPARE TO NUMBER OF RESERVED FILES
D2E3  23 F8                      BLS   LD2DD               ; BRANCH IF ANY FILES NOT SHUT DOWN
D2E5  9E 19                      LDX   TXTTAB              ; LOAD X WITH THE START OF BASIC
D2E7  6F 1F                      CLR   -1,X                ; SET FIRST BYTE OF BASIC PROGRAM TO ZERO
D2E9  BD AD 19                   JSR   LAD19               ; GO DO A 'NEW'
D2EC  7F 09 5C                   CLR   DRESFL              ; RESET THE DOS RESET FLAG
D2EF  B6 09 5D          LD2EF    LDA   DLODFL              ; * CHECK THE LOAD RESET FLAG AND
D2F2  27 06                      BEQ   LD2FA               ; * BRANCH IF NOT SET
D2F4  7F 09 5D                   CLR   DLODFL              ; CLEAR THE LOAD RESET FLAG
D2F7  BD AD 19                   JSR   LAD19               ; GO DO A 'NEW'
D2FA  6E C4             LD2FA    JMP   ,U                  ; JUMP BACK TO RETURN ADDRESS SAVED IN U ABOVE

D2FC  86 02             LD2FC    LDA   #$02                ; READ OP CODE
D2FE  8C                         CMPX  #$8603              ; SKIP TWO BYTES
D2FF  86 03             LD2FF    LDA   #$03                ; WRITE OP CODE
D301  DD EA                      STD   DCOPC               ; SAVE IN DSKCON VARIABLE
D303  A6 63                      LDA   $03,S               ; * GET THE NUMBER OF THE TRACK BEING CURRENTLY
D305  97 EC                      STA   DCTRK               ; * WRITTEN AND SAVE IT IN DSKCON VARIABLE
D307  8E 09 89                   LDX   #DFLBUF             ; = TRACK BUFFER STARTS AT DFLBUF
D30A  9F EE                      STX   DCBPT               ; = SAVE IT IN DSKCON VARIABLE
D30C  96 03                      LDA   TMPLOC              ; GET NUMBER OF TRACKS TO MOVE
D30E  C6 01             LD30E    LDB   #$01                ; INITIALIZE SECTOR COUNTER TO ONE
D310  D7 ED             LD310    STB   DSEC                ; SAVE DSKCON SECTOR VARIABLE
D312  BD D6 F2                   JSR   LD6F2               ; READ/WRITE A SECTOR
D315  0C EE                      INC   DCBPT               ; MOVE BUFFER POINTER UP ONE SECTOR (256 BYTES)
D317  5C                         INCB                      ; INCREMENT SECTOR COUNTER
D318  C1 12                      CMPB  #SECMAX             ; COMPARE TO MAXIMUM NUMBER OF SECTORS PER TRACK
D31A  23 F4                      BLS   LD310               ; BRANCH IF ANY SECTORS LEFT
D31C  0C EC                      INC   DCTRK               ; INCREMENT TRACK COUNTER VARIABLE TO NEXT TRACK
D31E  4A                         DECA                      ; DECREMENT TRACKS TO MOVE COUNTER
D31F  26 ED                      BNE   LD30E               ; READ MORE TRACKS IF ANY LEFT
D321  39                         RTS

D322  E6 65             LD322    LDB   $05,S               ; * GET THE DESTINATlON DRIVE NUMBER AND
D324  E1 66                      CMPB  $06,S               ; * COMPARE IT TO THE SOURCE DRIVE NUMBER

* PRINT SOURCE/DESTINATION DISK SWITCH PROMPT MESSAGE
D326  26 36             LD326    BNE   LD35E               ; RETURN IF DRIVE NUMBERS NOT EQUAL
D328  7F 09 85                   CLR   RDYTMR              ; RESET THE READY TIMER
D32B  7F FF 40                   CLR   DSKREG              ; CLEAR DSKREG - TURN OFF ALL DISK MOTORS
D32E  7F 09 86                   CLR   DRGRAM              ; CLEAR DSKREG RAM IMAGE
D331  34 02                      PSHS  A                   ; SAVE SOURCE/DESTINATION FLAG ON STACK
D333  BD A9 28                   JSR   LA928               ; CLEAR SCREEN
D336  8E D3 5F                   LDX   #LD35F              ; POINT X TO 'INSERT SOURCE' MESSAGE
D339  C6 0D                      LDB   #13                 ; 13 BYTES IN MESSAGE
D33B  A6 E0                      LDA   ,S+                 ; GET SOURCE/DESTINATION FLAG FROM THE STACK
D33D  27 05                      BEQ   LD344               ; BRANCH IF SOURCE
D33F  8E D3 6C                   LDX   #LD36C              ; POINT X TO 'INSERT DESTINATION' MESSAGE
D342  C6 12                      LDB   #18                 ; 18 BYTES IN MESSAGE
D344  BD B9 A2          LD344    JSR   LB9A2               ; SEND MESSAGE TO CONSOLE OUT
D347  8E D3 7E                   LDX   #LD37E              ; POINT X TO 'DISKETTE AND' MESSAGE
D34A  C6 1B                      LDB   #27                 ; 27 BYTES IN MESSAGE
D34C  BD B9 A2                   JSR   LB9A2               ; SEND MESSAGE TO CONSOLE OUT
D34F  CC 64 05                   LDD   #$6405              ; * SET UP 'SOUND' PARAMETERS
D352  97 8C                      STA   SNDTON              ; * FOR A BEEP
D354  BD A9 51                   JSR   LA951               ; JUMP TO 'SOUND' - DO A BEEP
D357  BD A1 71          LD357    JSR   LA171               ; GET A CHARACTER FROM CONSOLE IN
D35A  81 0D                      CMPA  #CR                 ; * KEEP LOOKING AT CONSOLE IN UNTIL
D35C  26 F9                      BNE   LD357               ; * YOU GET A CARRIAGE RETURN
D35E  39                LD45E    RTS

D35F  49 4E 53 45 52 54 LD35F    FCC   'INSERT SOURCE'
D365  20 53 4F 55 52 43
D36B  45
D36C  49 4E 53 45 52 54 LD36C    FCC   'INSERT DESTINATION'
D372  20 44 45 53 54 49
D378  4E 41 54 49 4F 4E
D37E  20 44 49 53 4B 45 LD37E    FCC   ' DISKETTE AND'
D384  54 54 45 20 41 4E
D38A  44
D38B  0D                         FCB   CR
D38C  50 52 45 53 53 20          FCC   'PRESS 'ENTER''
D392  27 45 4E 54 45 52
D398  27

* PUSH FILENAME.EXT AND DRIVE NUMBER ONTO THE STACK
D399  35 20             LD399    PULS  Y                   ; SAVE RETURN ADDRESS IN Y
D39B  C6 0B                      LDB   #11                 ; 11 CHARACTERS IN FILENAME AND EXTENSION
D39D  8E 09 57                   LDX   #DNAMBF+11          ; POINT X TO TOP OF DISK NAME/EXT BUFFER
D3A0  A6 82             LD3A0    LDA   ,-X                 ; * GET A CHARACTER FROM FILENAME.
D3A2  34 02                      PSHS  A                   ; * EXT BUFFER AND PUSH IT ONTO THE
D3A4  5A                         DECB                      ; * STACK - DECREMENT COUNTER AND
D3A5  26 F9                      BNE   LD3A0               ; * KEEP LOOPING UNTIL DONE
D3A7  96 EB                      LDA   DCDRV               ; = GET DRIVE NUMBER AND PUSH
D3A9  34 02                      PSHS  A                   ; = IT ONTO THE STACK
D3AB  6E A4                      JMP   ,Y                  ; PSEUDO - RETURN TO CALLING ROUTINE

* PULL FILENAME.EXT AND DRIVE NUMBER FROM (X) TO RAM
D3AD  A6 80             LD3AD    LDA   ,X+                 ; * GET DRIVE NUMBER AND SAVE
D3AF  97 EB                      STA   DCDRV               ; * IT IN DSKCON VARIABLE
D3B1  C6 0B                      LDB   #11                 ; 11 BYTES IN FILENAME AND EXTENSION
D3B3  CE 09 4C                   LDU   #DNAMBF             ; POINT U TO DISK NAME BUFFER
D3B6  7E A5 9A                   JMP   LA59A               ; MOVE FILENANE.EXT FROM (X) TO DNAMBF
