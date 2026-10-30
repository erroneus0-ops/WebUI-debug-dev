; Disk Extended Color BASIC 1.0 -- $D66C-$D7DC
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: DSKCON=$D66C, DNMISV=$D7AE, DIRQSV=$D7BC

* DSKCON ROUTINE
D66C  34 76             DSKCON   PSHS  U,Y,X,B,A           ; SAVE REGISTERS
D66E  86 05                      LDA   #$05                ; * GET RETRY COUNT AND
D670  34 02                      PSHS  A                   ; * SAVE IT ON THE STACK
D672  7F 09 85          LD672    CLR   RDYTMR              ; RESET DRIVE NOT READY TIMER
D675  D6 EB                      LDB   DCDRV               ; GET DRIVE NUMBER
D677  8E D7 AA                   LDX   #LD7AA              ; POINT X TO DRIVE ENABLE MASKS
D67A  B6 09 86                   LDA   DRGRAM              ; GET DSKREG IMAGE
D67D  84 A8                      ANDA  #$A8                ; KEEP MOTOR STATUS, DOUBLE DENSITY. HALT ENABLE
D67F  AA 85                      ORA   B,X                 ; 'OR' IN DRIVE SELECT DATA
D681  8A 20                      ORA   #$20                ; 'OR' IN DOUBLE DENSITY
D683  D6 EC                      LDB   DCTRK               ; GET TRACK NUMBER
D685  C1 16                      CMPB  #22                 ; PRECOMPENSATION STARTS AT TRACK 22
D687  25 02                      BLO   LD68B               ; BRANCH IF LESS THAN 22
D689  8A 10                      ORA   #$10                ; TURN ON WRITE PRECOMPENSATION IF >= 22
D68B  1F 89             LD68B    TFR   A,B                 ; SAVE PARTIAL IMAGE IN ACCB
D68D  8A 08                      ORA   #$08                ; 'OR' IN MOTOR ON CONTROL BIT
D68F  B7 09 86                   STA   DRGRAM              ; SAVE IMAGE IN RAM
D692  B7 FF 40                   STA   DSKREG              ; PROGRAM THE 1793 CONTROL REGISTER
D695  C5 08                      BITB  #$08                ; = WERE MOTORS ALREADY ON?
D697  26 06                      BNE   LD69F               ; = DON'T WAIT FOR IT TO COME UP TO SPEED IF ALREADY ON
D699  BD A7 D1                   JSR   LA7D1               ; * WAIT A WHILE
D69C  BD A7 D1                   JSR   LA7D1               ; * WAIT SOME MORE FOR MOTOR TO COME UP TO SPEED
D69F  8D 3D             LD69F    BSR   LD6DE               ; WAIT UNTIL NOT BUSY OR TIME OUT
D6A1  26 0A                      BNE   LD6AD               ; BRANCH IF TIMED OUT (DOOR OPEN. NO DISK, NO POWER. ETC.)
D6A3  0F F0                      CLR   DCSTA               ; CLEAR STATUS REGISTER
D6A5  8E D7 A2                   LDX   #LD7A2              ; POINT TO COMMAND JUMP VECTORS
D6A8  D6 EA                      LDB   DCOPC               ; GET COMMAND
D6AA  58                         ASLB                      ; 2 BYTES PER COMMAND JUMP ADDRESS
D6AB  AD 95                      JSR   [B,X]               ; GO DO IT
D6AD  35 02             LD6AD    PULS  A                   ; GET RETRY COUNT
D6AF  D6 F0                      LDB   DCSTA               ; GET STATUS
D6B1  27 0B                      BEQ   LD6BE               ; BRANCH IF NO ERRORS
D6B3  4A                         DECA                      ; DECREMENT RETRIES COUNTER
D6B4  27 08                      BEQ   LD6BE               ; BRANCH IF NO RETRIES LEFT
D6B6  34 02                      PSHS  A                   ; SAVE RETRY COUNT ON STACK
D6B8  8D 0B                      BSR   LD6C5               ; RESTORE HEAD TO TRACK 0
D6BA  26 F1                      BNE   LD6AD               ; BRANCH IF SEEK ERROR
D6BC  20 B4                      BRA   LD672               ; GO TRY COMMAND AGAIN IF NO ERROR
D6BE  86 78             LD6BE    LDA   #120                ; 120*1/60 = 2 SECONDS (1/60 SECOND FOR EACH IRQ INTERRUPT)
D6C0  B7 09 85                   STA   RDYTMR              ; WAIT 2 SECONDS BEFORE TURNING OFF MOTOR
D6C3  35 F6                      PULS  A,B,X,Y,U,PC        ; RESTORE REGISTERS - EXIT DSKCON
* RESTORE HEAD TO TRACK 0
D6C5  8E 09 7E          LD6C5    LDX   #DR0TRK             ; POINT TO TRACK TABLE
D6C8  D6 EB                      LDB   DCDRV               ; GET DRIVE NUMBER
D6CA  6F 85                      CLR   B,X                 ; ZERO TRACK NUMBER
D6CC  86 03                      LDA   #$03                ; * RESTORE HEAD TO TRACK 0, UNLOAD THE HEAD
D6CE  B7 FF 48                   STA   FDCREG              ; * AT START, 30 MS STEPPING RATE
D6D1  1E 88                      EXG   A,A                 ; =
D6D3  1E 88                      EXG   A,A                 ; = WAIT FOR 1793 TO RESPOND TO COMMAND
D6D5  8D 07                      BSR   LD6DE               ; WAIT TILL DRIVE NOT BUSY
D6D7  8D 24                      BSR   LD6FD               ; WAIT SOME MORE
D6D9  84 10                      ANDA  #$10                ; 1793 STATUS : KEEP ONLY SEEK ERROR
D6DB  97 F0                      STA   DCSTA               ; SAVE IN DSKCON STATUS
D6DD  39                LD6DD    RTS
* WAIT FOR THE 1793 TO BECOME UNBUSY. IF IT DOES NOT BECOME UNBUSY,
* FORCE AN INTERRUPT AND ISSUE A 'DRIVE NOT READY' 1793 ERROR.
D6DE  9E 8A             LD6DE    LDX   ZERO                ; GET ZERO TO X REGISTER - LONG WAIT
D6E0  30 1F             LD6E0    LEAX  -1,X                ; DECREMENT LONG WAIT COUNTER
D6E2  27 08                      BEQ   LD6EC               ; lF NOT READY BY NOW, FORCE INTERRUPT
D6E4  B6 FF 48                   LDA   FDCREG              ; * GET 1793 STATUS AND TEST
D6E7  85 01                      BITA  #$01                ; * BUSY STATUS BIT
D6E9  26 F5                      BNE   LD6E0               ; BRANCH IF BUSY
D6EB  39                         RTS
D6EC  86 D0             LD6EC    LDA   #$D0                ; * FORCE INTERRUPT COMMAND - TERMINATE ANY COMMAND
D6EE  B7 FF 48                   STA   FDCREG              ; * IN PROCESS. DO NOT GENERATE A 1793 INTERRUPT REQUEST
D6F1  1E 88                      EXG   A,A                 ; * WAIT BEFORE READING 1793
D6F3  1E 88                      EXG   A,A                 ; *
D6F5  B6 FF 48                   LDA   FDCREG              ; RESET INTRQ (FDC INTERRUPT REQUEST)
D6F8  86 80                      LDA   #$80                ; RETURN DRIVE NOT READY STATUS IF THE DRIVE DID NOT BECOME UNBUSY
D6FA  97 F0                      STA   DCSTA               ; SAVE DSKCON STATUS BYTE
D6FC  39                         RTS
* MEDIUM DELAY
D6FD  8E 22 2E          LD6FD    LDX   #8750               ; DELAY FOR A WHILE
D700  30 1F             LD700    LEAX  -1,X                ; * DECREMENT DELAY COUNTER AND
D702  26 FC                      BNE   LD700               ; * BRANCH IF NOT DONE
D704  39                         RTS
* READ ONE SECTOR
D705  86 80             LD705    LDA   #$80                ; $80 IS READ FLAG (1793 READ SECTOR)
D707  8C                LD707    CMPX  #$86A0              ; SKIP TWO BYTES
* WRITE ONE SECTOR
D708  86 A0             LD708    LDA   #$A0                ; $A0 IS WRITE FLAG (1793 WRITE SECTOR)
D70A  34 02                      PSHS  A                   ; SAVE READ/WRITE FLAG ON STACK
D70C  8E 09 7E                   LDX   #DR0TRK             ; POINT X TO TRACK NUMBER TABLE IN RAM
D70F  D6 EB                      LDB   DCDRV               ; GET DRIVE NUMBER
D711  3A                         ABX                       ; POINT X TO CORRECT DRIVE'S TRACK BYTE
D712  E6 84                      LDB   ,X                  ; GET TRACK NUMBER OF CURRENT HEAD POSITION
D714  F7 FF 49                   STB   FDCREG+1            ; SEND TO 1793 TRACK REGISTER
D717  D1 EC                      CMPB  DCTRK               ; COMPARE TO DESIRED TRACK
D719  27 1E                      BEQ   LD739               ; BRANCH IF ON CORRECT TRACK
D71B  96 EC                      LDA   DCTRK               ; GET TRACK DESIRED
D71D  B7 FF 4B                   STA   FDCREG+3            ; SEND TO 1793 DATA REGiSTER
D720  A7 84                      STA   ,X                  ; SAVE IN RAM TRACK IMAGE
D722  86 17                      LDA   #$17                ; * SEEK COMMAND FOR 1793: DO NOT LOAD THE
D724  B7 FF 48                   STA   FDCREG              ; * HEAD AT START, VERIFY DESTINATION TRACK,
D727  1E 88                      EXG   A,A                 ; * 30 MS STEPPING RATE - WAIT FOR
D729  1E 88                      EXG   A,A                 ; * VALID STATUS FROM 1793
D72B  8D B1                      BSR   LD6DE               ; WAIT TILL NOT BUSY
D72D  26 08                      BNE   LD737               ; RETURN IF TIMED OUT
D72F  8D CC                      BSR   LD6FD               ; WAIT SOME MORE
D731  84 18                      ANDA  #$18                ; KEEP ONLY SEEK ERROR OR CRC ERROR IN ID FIELD
D733  27 04                      BEQ   LD739               ; BRANCH IF NO ERRORS - HEAD ON CORRECT TRACK
D735  97 F0                      STA   DCSTA               ; SAVE IN DSKCON STATUS
D737  35 82             LD737    PULS  A,PC
* HEAD POSITIONED ON CORRECT TRACK
D739  96 ED             LD739    LDA   DSEC                ; GET SECTOR NUMBER DESIRED
D73B  B7 FF 4A                   STA   FDCREG+2            ; SEND TO 1793 SECTOR REGISTER
D73E  8E D7 98                   LDX   #LD798              ; * POINT X TO ROUTINE TO BE VECTORED
D741  BF 09 83                   STX   DNMISV              ; * TO BY NMI UPON COMPLETION OF DISK I/O AND SAVE VECTOR
D744  9E EE                      LDX   DCBPT               ; POINT X TO I/O BUFFER
D746  B6 FF 48                   LDA   FDCREG              ; RESET INTRQ (FDC INTERRUPT REQUEST)
D749  B6 09 86                   LDA   DRGRAM              ; GET DSKREG IMAGE
D74C  8A 80                      ORA   #$80                ; SET FLAG TO ENABLE 1793 TO HALT 6809
D74E  35 04                      PULS  B                   ; GET READ/WRITE COMMAND FROM STACK
D750  10 9E 8A                   LDY   ZERO                ; ZERO OUT Y - TIMEOUT INITIAL VALUE
D753  CE FF 48                   LDU   #FDCREG             ; U POINTS TO 1793 INTERFACE REGISTERS
D756  73 09 82                   COM   NMIFLG              ; NMI FLAG = $FF: ENABLE NMI VECTOR
D759  1A 50                      ORCC  #$50                ; DISABLE FIRQ,IRQ
D75B  F7 FF 48                   STB   FDCREG              ; * SEND READ/WRITE COMMAND TO 1793: SINGLE RECORD, COMPARE
D75E  1E 88                      EXG   A,A                 ; * FOR SIDE 0, NO 15 MS DELAY, DISABLE SIDE SELECT
D760  1E 88                      EXG   A,A                 ; * COMPARE, WRITE DATA ADDRESS MARK (FB) - WAIT FOR STATUS
D762  C1 80                      CMPB  #$80                ; WAS THIS A READ?
D764  27 1C                      BEQ   LD782               ; IF SO, GO LOOK FOR DATA
* WAIT FOR THE 1793 TO ACKNOWLEDGE READY TO WRITE DATA
D766  C6 02                      LDB   #$02                ; DRQ MASK BIT
D768  E5 C4             LD768    BITB  ,U                  ; IS 1793 READY FOR A BYTE? (DRQ SET IN STATUS BYTE)
D76A  26 0C                      BNE   LD778               ; BRANCH IF SO
D76C  31 3F                      LEAY  -1,Y                ; DECREMENT WAIT TIMER
D76E  26 F8                      BNE   LD768               ; KEEP WAITING FOR THE 1793 DRQ
D770  7F 09 82          LD770    CLR   NMIFLG              ; RESET NMI FLAG
D773  1C AF                      ANDCC #$AF                ; ENABLE FIRQ,IRQ
D775  7E D6 EC                   JMP   LD6EC               ; FORCE INTERRUPT, SET DRIVE NOT READY ERROR

* WRITE A SECTOR
D778  E6 80             LD778    LDB   ,X+                 ; GET A BYTE FROM RAM
D77A  F7 FF 4B                   STB   FDCREG+3            ; SEND IT TO 1793 DATA REGISTER
D77D  B7 FF 40                   STA   DSKREG              ; REPROGRAM FDC CONTROL REGISTER
D780  20 F6                      BRA   LD778               ; SEND MORE DATA
* WAIT FOR THE 17933 TO ACKNOWLEDGE READY TO READ DATA
D782  C6 02             LD782    LDB   #$02                ; DRQ MASK BIT
D784  E5 C4             LD784    BITB  ,U                  ; DOES THE 1793 HAVE A BYTE? (DRQ SET IN STATUS BYTE)
D786  26 06                      BNE   LD78E               ; YES, GO READ A SECTOR
D788  31 3F                      LEAY  -1,Y                ; DECREMENT WAIT TIMER
D78A  26 F8                      BNE   LD784               ; KEEP WAITING FOR 1793 DRQ
D78C  20 E2                      BRA   LD770               ; GENERATE DRIVE NOT READY ERROR

* READ A SECTOR
D78E  F6 FF 4B          LD78E    LDB   FDCREG+3            ; GET DATA BYTE FROM 1793 DATA REGISTER
D791  E7 80                      STB   ,X+                 ; PUT IT IN RAM
D793  B7 FF 40                   STA   DSKREG              ; REPROGRAM FDC CONTROL REGISTER
D796  20 F6                      BRA   LD78E               ; KEEP GETTING DATA
* BRANCH HERE ON COMPLETION OF SECTOR READ/WRITE
D798  1C AF             LD798    ANDCC #$AF                ; ENABLE IRQ, FIRO
D79A  B6 FF 48                   LDA   FDCREG              ; * GET STATUS & KEEP WRITE PROTECT, RECORD TYPE/WRITE
D79D  84 7C                      ANDA  #$7C                ; * FAULT, RECORD NOT FOUND, CRC ERROR OR LOST DATA
D79F  97 F0                      STA   DCSTA               ; SAVE IN DSKCON STATUS
D7A1  39                         RTS

* DSKCON OPERATION CODE JUMP VECTORS
D7A2  D6 C5             LD7A2    FDB   LD6C5               ; RESTORE HEAD TO TRACK ZERO
D7A4  D6 DD                      FDB   LD6DD               ; NO OP - RETURN
D7A6  D7 05                      FDB   LD705               ; READ SECTOR
D7A8  D7 08                      FDB   $D708               ; WRITE SECTOR

* DSKREG MASKS FOR DISK DRIVE SELECT
D7AA  01                LD7AA    FCB   1                   ; DRIVE SEL 0
D7AB  02                         FDB   2                   ; DRIVE SEL 1
D7AC  04                         FDB   4                   ; DRIVE SEL 2
D7AD  40                         FCB   $40                 ; DRIVE SEL 3

* NMI SERVICE
D7AE  B6 09 82          DNMISV   LDA   NMIFLG              ; GET NMI FLAG
D7B1  27 08                      BEQ   LD7BB               ; RETURN IF NOT ACTIVE
D7B3  BE 09 83                   LDX   DNMISV              ; GET NEW RETURN VECTOR
D7B6  AF 6A                      STX   10,S                ; STORE AT STACKED PC SLOT ON STACK
D7B8  7F 09 82                   CLR   NMIFLG              ; RESET NMI FLAG
D7BB  3B                LD7BB    RTI

* IRQ SERVICE
D7BC  B6 FF 03          DIRQSV   LDA   PIA0+3              ; 63.5 MICRO SECOND OR 60 HZ INTERRUPT?
D7BF  2A FA                      BPL   LD7BB               ; RETURN IF 63.5 MICROSECOND
D7C1  B6 FF 02                   LDA   PIA0+2              ; RESET 60 HZ PIA INTERRUPT FLAG
D7C4  B6 09 85                   LDA   RDYTMR              ; GET TIMER
D7C7  27 11                      BEQ   LD7DA               ; BRANCH IF NOT ACTIVE
D7C9  4A                         DECA                      ; DECREMENT THE TIMER
D7CA  B7 09 85                   STA   RDYTMR              ; SAVE IT
D7CD  26 0B                      BNE   LD7DA               ; BRANCH IF NOT TIME TO TURN OFF DISK MOTORS
D7CF  B6 09 86                   LDA   DRGRAM              ; = GET DSKREG IMAGE
D7D2  84 B0                      ANDA  #$B0                ; = TURN ALL MOTORS AND DRIVE SELECTS OFF
D7D4  B7 09 86                   STA   DRGRAM              ; = PUT IT BACK IN RAM IMAGE
D7D7  B7 FF 40                   STA   DSKREG              ; SEND TO CONTROL REGISTER (MOTORS OFF)
D7DA  7E 89 55          LD7DA    JMP   L8955               ; JUMP TO EXTENDED BASIC'S IRQ HANDLER

* THIS IS THE END OF DISK BASIC.
* THE CODE FROM THIS POINT TO $DFFF IS GARBAGE.
* DOSBAS 1.0 = 2083 WASTED BYTES
