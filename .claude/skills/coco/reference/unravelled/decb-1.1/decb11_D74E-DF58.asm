; Disk Extended Color BASIC 1.1 -- $D74E-$DF58
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: VERIFY=$D74E, DSKCON=$D75F, DNMISV=$D8A1, DIRQSV=$D8AF, DOSCOM=$DF00, DOSINI=$DF4C, END=$DF58

* VERIFY COMMAND
D74E  5F                VERIFY   CLRB                      ; OFF FLAG = 0
D74F  81 AA                      CMPA  #$AA                ; OFF TOKEN ?
D751  27 07                      BEQ   LD75A               ; YES
D753  53                         COMB                      ; ON FLAG = $FF
D754  81 88                      CMPA  #$88                ; ON TOKEN
D756  10 26 DB 1D                LBNE  LB277               ; BRANCH TO 'SYNTAX ERROR' IF NOT ON OR OFF
D75A  F7 09 87          LD75A    STB   DVERFL              ; SET VERIFY FLAG
D75D  0E 9F                      JMP   GETNCH              ; GET NEXT CHARACTER FROM BASIC

* DSKCON ROUTINE
D75F  34 76             DSKCON   PSHS  U,Y,X,B,A           ; SAVE REGISTERS
D761  86 05                      LDA   #$05                ; * GET RETRY COUNT AND
D763  34 02                      PSHS  A                   ; * SAVE IT ON THE STACK
D765  7F 09 85          LD765    CLR   RDYTMR              ; RESET DRIVE NOT READY TIMER
D768  D6 EB                      LDB   DCDRV               ; GET DRIVE NUMBER
D76A  8E D8 9D                   LDX   #LD89D              ; POINT X TO DRIVE ENABLE MASKS
D76D  B6 09 86                   LDA   DRGRAM              ; GET DSKREG IMAGE
D770  84 A8                      ANDA  #$A8                ; KEEP MOTOR STATUS, DOUBLE DENSITY. HALT ENABLE
D772  AA 85                      ORA   B,X                 ; 'OR' IN DRIVE SELECT DATA
D774  8A 20                      ORA   #$20                ; 'OR' IN DOUBLE DENSITY
D776  D6 EC                      LDB   DCTRK               ; GET TRACK NUMBER
D778  C1 16                      CMPB  #22                 ; PRECOMPENSATION STARTS AT TRACK 22
D77A  25 02                      BLO   LD77E               ; BRANCH IF LESS THAN 22
D77C  8A 10                      ORA   #$10                ; TURN ON WRITE PRECOMPENSATION IF >= 22
D77E  1F 89             LD77E    TFR   A,B                 ; SAVE PARTIAL IMAGE IN ACCB
D780  8A 08                      ORA   #$08                ; 'OR' IN MOTOR ON CONTROL BIT
D782  B7 09 86                   STA   DRGRAM              ; SAVE IMAGE IN RAM
D785  B7 FF 40                   STA   DSKREG              ; PROGRAM THE 1793 CONTROL REGISTER
D788  C5 08                      BITB  #$08                ; = WERE MOTORS ALREADY ON?
D78A  26 06                      BNE   LD792               ; = DON'T WAIT FOR IT TO COME UP TO SPEED IF ALREADY ON
D78C  BD A7 D1                   JSR   LA7D1               ; * WAIT A WHILE
D78F  BD A7 D1                   JSR   LA7D1               ; * WAIT SOME MORE FOR MOTOR TO COME UP TO SPEED
D792  8D 3D             LD792    BSR   LD7D1               ; WAIT UNTIL NOT BUSY OR TIME OUT
D794  26 0A                      BNE   LD7A0               ; BRANCH IF TIMED OUT (DOOR OPEN. NO DISK, NO POWER. ETC.)
D796  0F F0                      CLR   DCSTA               ; CLEAR STATUS REGISTER
D798  8E D8 95                   LDX   #LD895              ; POINT TO COMMAND JUMP VECTORS
D79B  D6 EA                      LDB   DCOPC               ; GET COMMAND
D79D  58                         ASLB                      ; 2 BYTES PER COMMAND JUMP ADDRESS
D79E  AD 95                      JSR   [B,X]               ; GO DO IT
D7A0  35 02             LD7A0    PULS  A                   ; GET RETRY COUNT
D7A2  D6 F0                      LDB   DCSTA               ; GET STATUS
D7A4  27 0B                      BEQ   LD7B1               ; BRANCH IF NO ERRORS
D7A6  4A                         DECA                      ; DECREMENT RETRIES COUNTER
D7A7  27 08                      BEQ   LD7B1               ; BRANCH IF NO RETRIES LEFT
D7A9  34 02                      PSHS  A                   ; SAVE RETRY COUNT ON STACK
D7AB  8D 0B                      BSR   LD7B8               ; RESTORE HEAD TO TRACK 0
D7AD  26 F1                      BNE   LD7A0               ; BRANCH IF SEEK ERROR
D7AF  20 B4                      BRA   LD765               ; GO TRY COMMAND AGAIN IF NO ERROR
D7B1  86 78             LD7B1    LDA   #120                ; 120*1/60 = 2 SECONDS (1/60 SECOND FOR EACH IRQ INTERRUPT)
D7B3  B7 09 85                   STA   RDYTMR              ; WAIT 2 SECONDS BEFORE TURNING OFF MOTOR
D7B6  35 F6                      PULS  A,B,X,Y,U,PC        ; RESTORE REGISTERS - EXIT DSKCON
* RESTORE HEAD TO TRACK 0
D7B8  8E 09 7E          LD7B8    LDX   #DR0TRK             ; POINT TO TRACK TABLE
D7BB  D6 EB                      LDB   DCDRV               ; GET DRIVE NUMBER
D7BD  6F 85                      CLR   B,X                 ; ZERO TRACK NUMBER
D7BF  86 03                      LDA   #$03                ; * RESTORE HEAD TO TRACK 0, UNLOAD THE HEAD
D7C1  B7 FF 48                   STA   FDCREG              ; * AT START, 30 MS STEPPING RATE
D7C4  1E 88                      EXG   A,A                 ; =
D7C6  1E 88                      EXG   A,A                 ; = WAIT FOR 1793 TO RESPOND TO COMMAND
D7C8  8D 07                      BSR   LD7D1               ; WAIT TILL DRIVE NOT BUSY
D7CA  8D 24                      BSR   LD7F0               ; WAIT SOME MORE
D7CC  84 10                      ANDA  #$10                ; 1793 STATUS : KEEP ONLY SEEK ERROR
D7CE  97 F0                      STA   DCSTA               ; SAVE IN DSKCON STATUS
D7D0  39                LD7D0    RTS
* WAIT FOR THE 1793 TO BECOME UNBUSY. IF IT DOES NOT BECOME UNBUSY,
* FORCE AN INTERRUPT AND ISSUE A 'DRIVE NOT READY' 1793 ERROR.
D7D1  9E 8A             LD7D1    LDX   ZERO                ; GET ZERO TO X REGISTER - LONG WAIT
D7D3  30 1F             LD7D3    LEAX  -1,X                ; DECREMENT LONG WAIT COUNTER
D7D5  27 08                      BEQ   LD7DF               ; lF NOT READY BY NOW, FORCE INTERRUPT
D7D7  B6 FF 48                   LDA   FDCREG              ; * GET 1793 STATUS AND TEST
D7DA  85 01                      BITA  #$01                ; * BUSY STATUS BIT
D7DC  26 F5                      BNE   LD7D3               ; BRANCH IF BUSY
D7DE  39                         RTS
D7DF  86 D0             LD7DF    LDA   #$D0                ; * FORCE INTERRUPT COMMAND - TERMINATE ANY COMMAND
D7E1  B7 FF 48                   STA   FDCREG              ; * IN PROCESS. DO NOT GENERATE A 1793 INTERRUPT REQUEST
D7E4  1E 88                      EXG   A,A                 ; * WAIT BEFORE READING 1793
D7E6  1E 88                      EXG   A,A                 ; *
D7E8  B6 FF 48                   LDA   FDCREG              ; RESET INTRQ (FDC INTERRUPT REQUEST)
D7EB  86 80                      LDA   #$80                ; RETURN DRIVE NOT READY STATUS IF THE DRIVE DID NOT BECOME UNBUSY
D7ED  97 F0                      STA   DCSTA               ; SAVE DSKCON STATUS BYTE
D7EF  39                         RTS
* MEDIUM DELAY
D7F0  8E 22 2E          LD7F0    LDX   #8750               ; DELAY FOR A WHILE
D7F3  30 1F             LD7F3    LEAX  -1,X                ; * DECREMENT DELAY COUNTER AND
D7F5  26 FC                      BNE   LD7F3               ; * BRANCH IF NOT DONE
D7F7  39                         RTS
* READ ONE SECTOR
D7F8  86 80             LD7F8    LDA   #$80                ; $80 IS READ FLAG (1793 READ SECTOR)
D7FA  8C                LD7FA    CMPX  #$86A0              ; SKIP TWO BYTES
* WRITE ONE SECTOR
D7FB  86 A0             LD7FB    LDA   #$A0                ; $A0 IS WRITE FLAG (1793 WRITE SECTOR)
D7FD  34 02                      PSHS  A                   ; SAVE READ/WRITE FLAG ON STACK
D7FF  8E 09 7E                   LDX   #DR0TRK             ; POINT X TO TRACK NUMBER TABLE IN RAM
D802  D6 EB                      LDB   DCDRV               ; GET DRIVE NUMBER
D804  3A                         ABX                       ; POINT X TO CORRECT DRIVE'S TRACK BYTE
D805  E6 84                      LDB   ,X                  ; GET TRACK NUMBER OF CURRENT HEAD POSITION
D807  F7 FF 49                   STB   FDCREG+1            ; SEND TO 1793 TRACK REGISTER
D80A  D1 EC                      CMPB  DCTRK               ; COMPARE TO DESIRED TRACK
D80C  27 1E                      BEQ   LD82C               ; BRANCH IF ON CORRECT TRACK
D80E  96 EC                      LDA   DCTRK               ; GET TRACK DESIRED
D810  B7 FF 4B                   STA   FDCREG+3            ; SEND TO 1793 DATA REGiSTER
D813  A7 84                      STA   ,X                  ; SAVE IN RAM TRACK IMAGE
D815  86 17                      LDA   #$17                ; * SEEK COMMAND FOR 1793: DO NOT LOAD THE
D817  B7 FF 48                   STA   FDCREG              ; * HEAD AT START, VERIFY DESTINATION TRACK,
D81A  1E 88                      EXG   A,A                 ; * 30 MS STEPPING RATE - WAIT FOR
D81C  1E 88                      EXG   A,A                 ; * VALID STATUS FROM 1793
D81E  8D B1                      BSR   LD7D1               ; WAIT TILL NOT BUSY
D820  26 08                      BNE   LD82A               ; RETURN IF TIMED OUT
D822  8D CC                      BSR   LD7F0               ; WAIT SOME MORE
D824  84 18                      ANDA  #$18                ; KEEP ONLY SEEK ERROR OR CRC ERROR IN ID FIELD
D826  27 04                      BEQ   LD82C               ; BRANCH IF NO ERRORS - HEAD ON CORRECT TRACK
D828  97 F0                      STA   DCSTA               ; SAVE IN DSKCON STATUS
D82A  35 82             LD82A    PULS  A,PC
* HEAD POSITIONED ON CORRECT TRACK
D82C  96 ED             LD82C    LDA   DSEC                ; GET SECTOR NUMBER DESIRED
D82E  B7 FF 4A                   STA   FDCREG+2            ; SEND TO 1793 SECTOR REGISTER
D831  8E D8 8B                   LDX   #LD88B              ; * POINT X TO ROUTINE TO BE VECTORED
D834  BF 09 83                   STX   DNMIVC              ; * TO BY NMI UPON COMPLETION OF DISK I/O AND SAVE VECTOR
D837  9E EE                      LDX   DCBPT               ; POINT X TO I/O BUFFER
D839  B6 FF 48                   LDA   FDCREG              ; RESET INTRQ (FDC INTERRUPT REQUEST)
D83C  B6 09 86                   LDA   DRGRAM              ; GET DSKREG IMAGE
D83F  8A 80                      ORA   #$80                ; SET FLAG TO ENABLE 1793 TO HALT 6809
D841  35 04                      PULS  B                   ; GET READ/WRITE COMMAND FROM STACK
D843  10 9E 8A                   LDY   ZERO                ; ZERO OUT Y - TIMEOUT INITIAL VALUE
D846  CE FF 48                   LDU   #FDCREG             ; U POINTS TO 1793 INTERFACE REGISTERS
D849  73 09 82                   COM   NMIFLG              ; NMI FLAG = $FF: ENABLE NMI VECTOR
D84C  1A 50                      ORCC  #$50                ; DISABLE FIRQ,IRQ
D84E  F7 FF 48                   STB   FDCREG              ; * SEND READ/WRITE COMMAND TO 1793: SINGLE RECORD, COMPARE
D851  1E 88                      EXG   A,A                 ; * FOR SIDE 0, NO 15 MS DELAY, DISABLE SIDE SELECT
D853  1E 88                      EXG   A,A                 ; * COMPARE, WRITE DATA ADDRESS MARK (FB) - WAIT FOR STATUS
D855  C1 80                      CMPB  #$80                ; WAS THIS A READ?
D857  27 1C                      BEQ   LD875               ; IF SO, GO LOOK FOR DATA
* WAIT FOR THE 1793 TO ACKNOWLEDGE READY TO WRITE DATA
D859  C6 02                      LDB   #$02                ; DRQ MASK BIT
D85B  E5 C4             LD85B    BITB  ,U                  ; IS 1793 READY FOR A BYTE? (DRQ SET IN STATUS BYTE)
D85D  26 0C                      BNE   LD86B               ; BRANCH IF SO
D85F  31 3F                      LEAY  -1,Y                ; DECREMENT WAIT TIMER
D861  26 F8                      BNE   LD85B               ; KEEP WAITING FOR THE 1793 DRQ
D863  7F 09 82          LD863    CLR   NMIFLG              ; RESET NMI FLAG
D866  1C AF                      ANDCC #$AF                ; ENABLE FIRQ,IRQ
D868  7E D7 DF                   JMP   LD7DF               ; FORCE INTERRUPT, SET DRIVE NOT READY ERROR

* WRITE A SECTOR
D86B  E6 80             LD86B    LDB   ,X+                 ; GET A BYTE FROM RAM
D86D  F7 FF 4B                   STB   FDCREG+3            ; SEND IT TO 1793 DATA REGISTER
D870  B7 FF 40                   STA   DSKREG              ; REPROGRAM FDC CONTROL REGISTER
D873  20 F6                      BRA   LD86B               ; SEND MORE DATA
* WAIT FOR THE 17933 TO ACKNOWLEDGE READY TO READ DATA
D875  C6 02             LD875    LDB   #$02                ; DRQ MASK BIT
D877  E5 C4             LD877    BITB  ,U                  ; DOES THE 1793 HAVE A BYTE? (DRQ SET IN STATUS BYTE)
D879  26 06                      BNE   LD881               ; YES, GO READ A SECTOR
D87B  31 3F                      LEAY  -1,Y                ; DECREMENT WAIT TIMER
D87D  26 F8                      BNE   LD877               ; KEEP WAITING FOR 1793 DRQ
D87F  20 E2                      BRA   LD863               ; GENERATE DRIVE NOT READY ERROR

* READ A SECTOR
D881  F6 FF 4B          LD881    LDB   FDCREG+3            ; GET DATA BYTE FROM 1793 DATA REGISTER
D884  E7 80                      STB   ,X+                 ; PUT IT IN RAM
D886  B7 FF 40                   STA   DSKREG              ; REPROGRAM FDC CONTROL REGISTER
D889  20 F6                      BRA   LD881               ; KEEP GETTING DATA
* BRANCH HERE ON COMPLETION OF SECTOR READ/WRITE
D88B  1C AF             LD88B    ANDCC #$AF                ; ENABLE IRQ, FIRO
D88D  B6 FF 48                   LDA   FDCREG              ; * GET STATUS & KEEP WRITE PROTECT, RECORD TYPE/WRITE
D890  84 7C                      ANDA  #$7C                ; * FAULT, RECORD NOT FOUND, CRC ERROR OR LOST DATA
D892  97 F0                      STA   DCSTA               ; SAVE IN DSKCON STATUS
D894  39                         RTS

* DSKCON OPERATION CODE JUMP VECTORS
D895  D7 B8             LD895    FDB   LD7B8               ; RESTORE HEAD TO TRACK ZERO
D897  D7 D0                      FDB   LD7D0               ; NO OP - RETURN
D899  D7 F8                      FDB   LD7F8               ; READ SECTOR
D89B  D7 FB                      FDB   LD7FB               ; WRITE SECTOR

* DSKREG MASKS FOR DISK DRIVE SELECT
D89D  01                LD89D    FCB   1                   ; DRIVE SEL 0
D89E  02                         FCB   2                   ; DRIVE SEL 1
D89F  04                         FCB   4                   ; DRIVE SEL 2
D8A0  40                         FCB   $40                 ; DRIVE SEL 3

* NMI SERVICE
D8A1  B6 09 82          DNMISV   LDA   NMIFLG              ; GET NMI FLAG
D8A4  27 08                      BEQ   LD8AE               ; RETURN IF NOT ACTIVE
D8A6  BE 09 83                   LDX   DNMIVC              ; GET NEW RETURN VECTOR
D8A9  AF 6A                      STX   10,S                ; STORE AT STACKED PC SLOT ON STACK
D8AB  7F 09 82                   CLR   NMIFLG              ; RESET NMI FLAG
D8AE  3B                         RTI

* IRQ SERVICE
D8AF  B6 FF 03          DIRQSV   LDA   PIA0+3              ; 63.5 MICRO SECOND OR 60 HZ INTERRUPT?
D8B2  2A FA                      BPL   LD8AE               ; RETURN IF 63.5 MICROSECOND
D8B4  B6 FF 02                   LDA   PIA0+2              ; RESET 60 HZ PIA INTERRUPT FLAG
D8B7  B6 09 85                   LDA   RDYTMR              ; GET TIMER
D8BA  27 11                      BEQ   LD8CD               ; BRANCH IF NOT ACTIVE
D8BC  4A                         DECA                      ; DECREMENT THE TIMER
D8BD  B7 09 85                   STA   RDYTMR              ; SAVE IT
D8C0  26 0B                      BNE   LD8CD               ; BRANCH IF NOT TIME TO TURN OFF DISK MOTORS
D8C2  B6 09 86                   LDA   DRGRAM              ; = GET DSKREG IMAGE
D8C5  84 B0                      ANDA  #$B0                ; = TURN ALL MOTORS AND DRIVE SELECTS OFF
D8C7  B7 09 86                   STA   DRGRAM              ; = PUT IT BACK IN RAM IMAGE
D8CA  B7 FF 40                   STA   DSKREG              ; SEND TO CONTROL REGISTER (MOTORS OFF)
D8CD  7E 89 55          LD8CD    JMP   L8955               ; JUMP TO EXTENDED BASIC'S IRQ HANDLER

* THIS IS THE END OF DISK BASIC (EXCEPT FOR THE DOS COMMAND AT $DF00).
* THE CODE FROM THIS POINT TO $DF00 IS GARBAGE.
* DOSBAS 1.1 = 1686 WASTED BYTES

** THIS IS THE CODE FOR THE DOS COMMAND

                                 ORG   DOSBAS+$1F00
DF00  11 3F             DOSCOM   SWI3                      ; DO A SOFTWARE INTERRUPT (#3)
DF02  0F 03                      CLR   TMPLOC              ; RESET SECTOR COUNTER
DF04  CC 26 00                   LDD   #DOSBUF             ; RAM LOAD ADDRESS FOR SECTOR DATA
DF07  34 06                      PSHS  B,A                 ; SAVE RAM LOAD ADDRESS
DF09  BE C0 06          LDF09    LDX   DSKVAR              ; POINT X TO DSKCON VARIABLES
DF0C  0C 03                      INC   TMPLOC              ; INCREMENT SECTOR COUNTER
DF0E  96 03                      LDA   TMPLOC              ; GET THE SECTOR COUNTER
DF10  81 12                      CMPA  #SECMAX             ; LOADED IN 18 SECTORS? (ONE TRACK)
DF12  22 22                      BHI   LDF36               ; YES - EXIT
DF14  A7 03                      STA   $03,X               ; NO - SAVE SECTOR NUMBER IN DSEC
DF16  CC 02 00                   LDD   #$0200              ; GET FDC OP CODE (READ) AND DRIVE NUMBER (0)
DF19  A7 84                      STA   ,X                  ; SAVE THEM IN DSKCON VARIABLES (BUG - SHOULD BE STD ,X)
DF1B  86 22                      LDA   #34                 ; GET TRACK NUMBER (34)
DF1D  A7 02                      STA   $02,X               ; SAVE IT IN DSKCON VARIABLES TOO
DF1F  35 06                      PULS  A,B                 ; GET RAM LOAD ADDRESS
DF21  ED 04                      STD   $04,X               ; AND SAVE IT IN THE DSKCON VARIABLES
DF23  8B 01                      ADDA  #$01                ; ADD 256 (ONE SECTOR) TO RAM LOAD ADDRESS (SHOULD BE INCA)
DF25  34 06                      PSHS  B,A                 ; SAVE NEW RAM LOAD ADDRESS
DF27  AD 9F C0 04                JSR   [DCNVEC]            ; GO READ A SECTOR
DF2B  6D 06                      TST   $06,X               ; CHECK FOR ERRORS
DF2D  27 DA                      BEQ   LDF09               ; KEEP READING IF NONE
DF2F  35 06                      PULS  A,B                 ; PULL LOAD ADDRESS OFF OF THE STACK
DF31  C6 28                      LDB   #2*20               ; 'IO' ERROR
DF33  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR SERVICING ROUTINE
DF36  35 06             LDF36    PULS  A,B                 ; PULL RAM LOAD ADDRESS OFF OF THE STACK [label LDF36 moved here from $DF2F: the ROM bytes of the code that references it point here]
DF38  FC 26 00                   LDD   DOSBUF              ; GET FIRST TWO BYTES OF RAM DATA
DF3B  10 83 4F 53                CMPD  #'OS'               ; LOOK FOR 'OS' (OS9) AT START OF BUFFER
DF3F  10 27 46 BF                LBEQ  DOSBUF+2            ; IF 'OS' THEN BRANCH TO DATA LOADED IN RAM
DF43  7F 26 00                   CLR   DOSBUF              ; * OTHERWISE CLEAR THE FIRST TWO

DF46  7F 26 01                   CLR   DOSBUF+1            ; * BYTES OF RAM DATA
DF49  7E A0 E8                   JMP   BAWMST              ; JUMP TO BASIC'S WARM START

DF4C  CC 3B 3B          DOSINI   LDD   #$3B3B              ; TWO RTI INSTRUCTIONS [label DOSINI moved here from $DF46: the ROM bytes of the code that references it point here]
DF4F  FD 01 00                   STD   SW3VEC              ; *
DF52  FD 01 02                   STD   SW3VEC+2            ; * LOAD THE SWI2 AND SWI3 JUMP
DF55  FD 01 04                   STD   SW2VEC+1            ; * VECTORS WITH RTIS
DF58  39                END      RTS

* END OF THE DOS AND DOSINI COMMANDS - THE REST OF THE CODE
* TO THE END OF THE DISK ROM ($DFFF) IS GARBAGE.
* DOSBAS 1.1 = 167 WASTED BYTES
