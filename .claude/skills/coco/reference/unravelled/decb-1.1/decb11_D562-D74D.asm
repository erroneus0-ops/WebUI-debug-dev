; Disk Extended Color BASIC 1.1 -- $D562-$D74D
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: DSKO=$D562, DSKINI=$D599, DOS=$D6EC

* DSKO$ COMMAND
D562  8D C3             DSKO     BSR   LD527               ; GET THE DRIVE, TRACK AND SECTOR NUMBERS
D564  8D E7                      BSR   LD54D               ; GET THE DESCRIPTOR OF STRING 1
D566  8D BC                      BSR   LD524               ; 'TM' ERROR IF NUMERIC EXPRESSION
D568  9E 52                      LDX   FPA0+2              ; * GET STRING 1 DESCRIPTOR ADDRESS
D56A  34 10                      PSHS  X                   ; * AND SAVE IT ON THE STACK
D56C  8D DF                      BSR   LD54D               ; GET THE DESCRIPTOR OF STRING 2
D56E  BD B6 54                   JSR   LB654               ; *GET LENGTH AND ADDRESS OF STRING 2 AND
D571  34 14                      PSHS  X,B                 ; *SAVE THEM ON THE STACK
D573  5F                         CLRB                      ; SET CLEAR COUNTER TO 256 (FULL SECTOR BUFFER)
D574  8E 06 00                   LDX   #DBUF0              ; USE DBUF0 AS THE DSKO$ I/O BUFFER
D577  6F 80             LD577    CLR   ,X+                 ; CLEAR A BYTE IN I/O BUFFER
D579  5A                         DECB                      ; DECREMENT CLEAR COUNTER
D57A  26 FB                      BNE   LD577               ; BRANCH IF ALL 256 BYTES NOT CLEARED
D57C  35 14                      PULS  B,X                 ; GET THE LENGTH AND ADDRESS OF STRING 2
D57E  CE 06 80                   LDU   #DBUF0+128          ; POINT X TO STRING 2 DESTINATION
D581  8D 96                      BSR   LD519               ; MOVE STRING 2 DATA INTO DBUF0
D583  35 10                      PULS  X                   ; POINT X TO STRING 1 DESCRIPTOR
D585  BD B6 59                   JSR   LB659               ; GET THE LENGTH AND ADDRESS OF STRING 1
D588  CE 06 00                   LDU   #DBUF0              ; POINT U TO STRING 1 DESTINATION
D58B  8D 8C                      BSR   LD519               ; MOVE STRING 1 DATA INTO DBUF0
D58D  C6 03                      LDB   #$03                ; DSKCON WRITE OP CODE
D58F  8E 06 00                   LDX   #DBUF0              ; POINT X TO I/O BUFFER (DBUF0)
D592  9F EE                      STX   DCBPT               ; *
D594  D7 EA                      STB   DCOPC               ; * SAVE NEW DSKCON BUFFER POINTER AND OP CODE VARIABLES
D596  7E D6 F2                   JMP   LD6F2               ; GO WRITE OUT A SECTOR

* DSKINI COMMAND
D599  10 27 D0 82       DSKINI   LBEQ  LA61F               ; BRANCH TO 'DN' ERROR IF NO DRIVE NUMBER SPECIFIED
D59D  BD D2 56                   JSR   LD256               ; CALCULATE DRIVE NUMBER
D5A0  C6 04                      LDB   #$04                ; SKIP FACTOR DEFAULT VALUE
D5A2  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHAR FROM BASiC
D5A4  27 0C                      BEQ   LD5B2               ; BRANCH IF END OF LINE
D5A6  BD B7 38                   JSR   LB738               ; SYNTAX CHECK FOR COMMA AND EVALUATE EXPRESSION
D5A9  C1 11                      CMPB  #17                 ; MAX VALUE OF SKIP FACTOR = 16
D5AB  10 24 DE 9B                LBHS  LB44A               ; 'ILLEGAL FUNCTION CALL' IF BAD SKIP FACTOR
D5AF  BD A5 C7                   JSR   LA5C7               ; SYNTAX ERROR IF MORE CHARACTERS ON THE LINE
D5B2  34 04             LD5B2    PSHS  B                   ; SAVE SKIP FACTOR ON THE STACK
D5B4  8E 07 12                   LDX   #DBUF1+SECMAX       ; POINT TO END OF LOGICAL SECTOR NUMBER STORAGE AREA
D5B7  C6 12                      LDB   #SECMAX             ; 18 SECTORS PER TRACK
D5B9  6F 82             LD5B9    CLR   ,-X                 ; CLEAR A BYTE IN THE BUFFER
D5BB  5A                         DECB                      ; CLEARED ALL 18?
D5BC  26 FB                      BNE   LD5B9               ; KEEP GOING IF NOT
D5BE  4F                         CLRA                      ; RESET PHYSICAL SECTOR COUNTER
D5BF  20 0D                      BRA   LD5CE               ; START WITH FIRST PHYSICAL SECTOR = 1

* CALCULATE LOGICAL SECTOR NUMBERS
D5C1  EB E4             LD5C1    ADDB  ,S                  ; ADD SKIP FACTOR TO LOGICAL SECTOR COUNTER
D5C3  5C                LD5C3    INCB                      ; ADD ONE TO LOGICAL SECTOR COUNTER
D5C4  C0 12             LD5C4    SUBB  #SECMAX             ; SUBTRACT MAX NUMBER OF SECTORS
D5C6  24 FC                      BHS   LD5C4               ; BRANCH UNTIL 0 > ACCB >= -18
D5C8  CB 12                      ADDB  #SECMAX             ; ADD 18, NOW ACCB IS 0-17
D5CA  6D 85                      TST   B,X                 ; IS ANYTHING STORED HERE ALREADY?
D5CC  26 F5                      BNE   LD5C3               ; YES - GET ANOTHER SECTOR
D5CE  4C                LD5CE    INCA                      ; * INCREMENT PHYSICAL SECTOR NUMBER AND
D5CF  A7 85                      STA   B,X                 ; * SAVE IT IN THE RAM BUFFER
D5D1  81 12                      CMPA  #SECMAX             ; FINISHED WITH ALL SECTORS?
D5D3  25 EC                      BLO   LD5C1               ; NO - KEEP GOING
D5D5  32 61                      LEAS  $01,S               ; REMOVE SKIP FACTOR FROM STACK
D5D7  8E 22 0F                   LDX   #DFLBUF+$1888-2     ; GET TOP OF RAM USED BY DSKINI
D5DA  9C 27                      CMPX  MEMSIZ              ; IS IT > CLEARED AREA?
D5DC  10 22 D6 64                LBHI  LAC44               ; 'OUT OF MEMORY' ERROR IF > CLEARED AREA
D5E0  BD CA E9                   JSR   DVEC7               ; CLOSE ALL FILES
D5E3  73 09 5C                   COM   DRESFL              ; SET RESET FLAG TO $FF - THIS WILL CAUSE A DOS RESET
D5E6  10 CE 08 00                LDS   #DBUF1+SECLEN       ; SET STACK TO TOP OF DBUF1
D5EA  BD 95 AC                   JSR   L95AC               ; RESET SAM TO DISPLAY PAGE ZERO AND ALPHA GRAPHICS
D5ED  86 00                      LDA   #$00                ; YOU COULD DELETE THIS INSTRUCTION AND CHANGE FOLLOWING STA TO CLR
D5EF  97 EA                      STA   DCOPC               ; RESTORE HEAD TO TRACK ZERO DSKCON OP CODE
D5F1  0F EC                      CLR   DCTRK               ; SET DSKCON TRACK VARIABLE TO TRACK ZERO
D5F3  BD D6 F2                   JSR   LD6F2               ; RESTORE HEAD TO TRACK ZERO
D5F6  7F 09 85                   CLR   RDYTMR              ; RESET THE READY TIMER
D5F9  86 C0                      LDA   #$C0                ; * FOC READ ADDRESS CODE
D5FB  B7 FF 48                   STA   FDCREG              ; *
D5FE  BD D7 D1                   JSR   LD7D1               ; CHECK DRIVE READY - WAIT UNTIL READY
D601  27 1D                      BEQ   LD620               ; BRANCH IF DRIVES READY
D603  7E D6 88                   JMP   LD688               ; ERROR IF DRIVES NOT READY
D606  81 16             LD606    CMPA  #22                 ; = CHECK FOR TRACK 22 (PRECOMPENSATION)
D608  25 08                      BLO   LD612               ; = AND BRANCH IF < TRACK 22 - NO PRECOMP
D60A  B6 09 86                   LDA   DRGRAM              ; * GET THE RAM IMAGE OF DSKREG, 'OR'
D60D  8A 10                      ORA   #$10                ; * IN THE PRECOMPENSATION FLAG AND
D60F  B7 FF 40                   STA   DSKREG              ; * SEND IT TO DSKREG
D612  86 53             LD612    LDA   #$53                ; = GET STEP IN COMMAND
D614  B7 FF 48                   STA   FDCREG              ; = AND SEND IT TO THE 1793
D617  1E 88                      EXG   A,A                 ; * DELAY AFTER ISSUING COMMAND TO 1793
D619  1E 88                      EXG   A,A                 ; *
D61B  BD D7 D1                   JSR   LD7D1               ; CHECK DRIVE READY
D61E  26 68                      BNE   LD688               ; BRANCH IF NOT READY - ISSUE AN ERROR
D620  BD D7 F0          LD620    JSR   LD7F0               ; WAIT A WHILE
D623  8D 6C                      BSR   LD691               ; BUILD A FORMATTED TRACK IN RAM
D625  10 8E FF 4B                LDY   #FDCREG+3           ; Y POINTS TO 1793 DATA REGISTER
D629  1A 50                      ORCC  #$50                ; DISABLE INTERRUPTS
D62B  8E D6 4F                   LDX   #LD64F              ; * GET RETURN ADDRESS AND STORE
D62E  BF 09 83                   STX   DNMIVC              ; * IT IN THE NON MASKABLE INTERRUPT VECTOR
D631  8E 09 89                   LDX   #DFLBUF             ; POINT X TO THE FORMATTED TRACK RAM IMAGE
D634  B6 FF 48                   LDA   FDCREG              ; RESET STATUS OF THE 1793
D637  86 FF                      LDA   #$FF                ; * ENABLE THE NMI FLAG TO VECTOR
D639  B7 09 82                   STA   NMIFLG              ; * OUT OF AN I/O LOOP UPON AN NMI INTERRUPT
D63C  C6 F4                      LDB   #$F4                ; = GET WRITE TRACK COMMAND AND
D63E  F7 FF 48                   STB   FDCREG              ; = SEND TO 1793
D641  B6 09 86                   LDA   DRGRAM              ; * GET THE DSKREG RAM IMAGE AND 'OR' IN THE
D644  8A 80                      ORA   #$80                ; * FLAG WHICH WILL ENABLE THE 1793 TO HALT
D646  B7 FF 40                   STA   DSKREG              ; * THE 6809. SEND RESULT TO DSKREG
D649  E6 80             LD649    LDB   ,X+                 ; = GET A BYTE FROM THE FORMATTED TRACK
D64B  E7 A4                      STB   ,Y                  ; = RAM IMAGE, SEND IT TO THE 1793 AND
D64D  20 FA                      BRA   LD649               ; = LOOP BACK TO GET ANOTHER BYTE

D64F  B6 FF 48          LD64F    LDA   FDCREG              ; GET STATUS
D652  1C AF                      ANDCC #$AF                ; ENABLE INTERRUPTS
D654  84 44                      ANDA  #$44                ; * KEEP ONLY WRITE PROTECT & LOST DATA
D656  97 F0                      STA   DCSTA               ; * AND SAVE IT IN THE DSKCON STATUS BYTE
D658  26 2E                      BNE   LD688               ; BRANCH IF ERROR
D65A  0C EC                      INC   DCTRK               ; SKIP TO THE NEXT TRACK
D65C  96 EC                      LDA   DCTRK               ; GET THE TRACK NUMBER
D65E  81 23                      CMPA  #TRKMAX             ; WAS IT THE LAST TRACK
D660  26 A4                      BNE   LD606               ; NO - KEEP GOING

* VERIFY THAT ALL SECTORS ARE READABLE
D662  86 02                      LDA   #$02                ; = GET THE DSKCON READ OP CODE
D664  97 EA                      STA   DCOPC               ; = AND SAVE IT IN THE DSKCON VARIABLE
D666  8E 06 00                   LDX   #DBUF0              ; * POINT THE DSKCON BUFFER POINTER
D669  9F EE                      STX   DCBPT               ; * TO DBUF0
D66B  CE 07 00                   LDU   #DBUF1              ; POINT U TO THE LOGICAL SECTOR NUMBERS
D66E  4F                         CLRA                      ; RESET THE TRACK COUNTER TO ZERO
D66F  97 EC             LD66F    STA   DCTRK               ; SET THE DSKCON TRACK VARIABLE
D671  5F                         CLRB                      ; RESET THE SECTOR COUNTER
D672  A6 C5             LD672    LDA   B,U                 ; GET THE PHYSICAL SECTOR NUMBER
D674  97 ED                      STA   DSEC                ; SAVE DSKCON SECTOR VARIABLE
D676  BD D6 F2                   JSR   LD6F2               ; READ A SECTOR
D679  5C                         INCB                      ; * INCREMENT THE SECTOR COUNTER
D67A  C1 12                      CMPB  #SECMAX             ; * AND COMPARE IT TO MAXIMUM SECTOR NUMBER
D67C  25 F4                      BLO   LD672               ; * AND KEEP LOOPING IF MORE SECTORS LEFT
D67E  96 EC                      LDA   DCTRK               ; = GET THE CURRENT TRACK NUMBER
D680  4C                         INCA                      ; = ADD ONE TO IT, COMPARE TO THE MAXIMUM TRACK
D681  81 23                      CMPA  #TRKMAX             ; = NUMBER AND KEEP LOOPING IF
D683  25 EA                      BLO   LD66F               ; = THERE ARE STILL TRACKS TO DO
D685  7E D2 CD                   JMP   LD2CD               ; GO CHECK FOR A DOS RESET
D688  7F 09 86          LD688    CLR   DRGRAM              ; CLEAR RAM IMAGE OF DSKREG
D68B  7F FF 40                   CLR   DSKREG              ; CLEAR DSKREG - TURN DISK MOTORS OFF
D68E  7E D7 01                   JMP   >LD701              ; PROCESS DRIVES NOT READY ERROR

* BUILD A FORMATTED TRACK OF DATA IN RAM STARTING AT DFLBUF.

D691  8E 09 89          LD691    LDX   #DFLBUF             ; START TRACK BUFFER AT DFLBUF
D694  CC 20 4E                   LDD   #$204E              ; GET SET TO WRITE 32 BYTES OF $4E
D697  8D 29                      BSR   LD6C2               ; GO WRITE GAP IV
D699  5F                         CLRB                      ; RESET SECTOR COUNTER
D69A  34 04             LD69A    PSHS  B                   ; SAVE SECTOR COUNTER
D69C  CE 07 00                   LDU   #DBUF1              ; POINT U TO THE TABLE OF LOGICAL SECTORS
D69F  E6 C5                      LDB   B,U                 ; * GET LOGICAL SECTOR NUMBER FROM TABLE AND
D6A1  D7 ED                      STB   DSEC                ; * SAVE IT IN THE DSKCON VARIABLE
D6A3  CE D6 D4                   LDU   #LD6D4              ; POINT U TO TABLE OF SECTOR FORMATTING DATA
D6A6  C6 03                      LDB   #$03                ; * GET FIRST 3 DATA BLOCKS AND
D6A8  8D 1E                      BSR   LD6C8               ; * WRITE THEM TO BUFFER
D6AA  96 EC                      LDA   DCTRK               ; = GET TRACK NUMBER AND STORE lT
D6AC  A7 80                      STA   ,X+                 ; = IN THE RAM BUFFER
D6AE  6F 80                      CLR   ,X+                 ; CLEAR A BYTE (SIDE NUMBER) IN BUFFER
D6B0  96 ED                      LDA   DSEC                ; * GET SECTOR NUMBER AND
D6B2  A7 80                      STA   ,X+                 ; * STORE IT IN THE BUFFER
D6B4  C6 09                      LDB   #$09                ; = GET THE LAST NINE DATA BLOCKS AND
D6B6  8D 10                      BSR   LD6C8               ; = WRITE THEM TO THE BUFFER
D6B8  35 04                      PULS  B                   ; GET SECTOR COUNTER
D6BA  5C                         INCB                      ; NEXT SECTOR
D6BB  C1 12                      CMPB  #SECMAX             ; 18 SECTORS PER TRACK
D6BD  25 DB                      BLO   LD69A               ; BRANCH IF ALL SECTORS NOT DONE
D6BF  CC C8 4E                   LDD   #$C84E              ; WRITE 200 BYTES OF $4E AT END OF TRACK

* WRITE ACCA BYTES OF ACCB INTO BUFFER
D6C2  E7 80             LD6C2    STB   ,X+                 ; STORE A BYTE IN THE BUFFER
D6C4  4A                         DECA                      ; DECREMENT COUNTER
D6C5  26 FB                      BNE   LD6C2               ; BRANCH IF ALL BYTES NOT MOVED
D6C7  39                         RTS
D6C8  34 04             LD6C8    PSHS  B                   ; SAVE THE COUNTER ON THE STACK
D6CA  EC C1                      LDD   ,U++                ; GET TWO BYTES OF DATA FROM THE TABLE
D6CC  8D F4                      BSR   LD6C2               ; WRITE ACCA BYTES OF ACCB INTO THE BUFFER
D6CE  35 04                      PULS  B                   ; * GET THE COUNTER BACK, DECREMENT
D6D0  5A                         DECB                      ; * IT AND BRANCH IF ALL DATA BLOCKS
D6D1  26 F5                      BNE   LD6C8               ; * NOT DONE
D6D3  39                         RTS

* DATA USED TO FORMAT A SECTOR ON THE DISK

* THESE DATA ARE CLOSE TO THE IBM SYSTEM 34 FORMAT FOR 256 BYTE SECTORS.
* DOUBLE DENSITY. THE FORMAT GENERALLY CONFORMS TO THAT SPECIFIED ON THE
* 1793 DATA SHEET. THE GAP SIZES HAVE BEEN REDUCED TO THE MINIMUM
* ALLOWABLE. THE IBM FORMAT USES $40 AS THE FILL CHARACTER FOR THE DATA
* BLOCKS WHILE COLOR DOS USES AN $FF AS THE FILL CHARACTER.
D6D4  08 00             LD6D4    FCB   8,0                 ; SYNC FIELD
D6D6  03 F5                      FCB   3,$F5
D6D8  01 FE                      FCB   1,$FE               ; ID ADDRESS MARK (AM1)
* TRACK, SIDE, AND SECTOR NUMBERS ARE INSERTED HERE
D6DA  01 01                      FCB   1,1                 ; SECTOR SIZE (256 BYTE SECTORS)
D6DC  01 F7                      FCB   1,$F7               ; CRC REQUEST
D6DE  16 4E                      FCB   22,$4E              ; GAP II (POST-ID GAP)
D6E0  0C 00                      FCB   12,0                ; SYNC FIELD
D6E2  03 F5                      FCB   3,$F5
D6E4  01 FB                      FCB   1,$FB               ; DATA ADDRESS MARK (AM2)
D6E6  00 FF                      FCB   0,$FF               ; DATA FIELD (256 BYTES)
D6E8  01 F7                      FCB   1,$F7               ; CRC REQUEST
D6EA  18 4E                      FCB   24,$4E              ; GAP III (POST DATA GAP)


* DOS COMMAND
D6EC  26 54             DOS      BNE   LD742               ; RETURN IF ARGUMENT GIVEN
D6EE  6E 9F C0 0A                JMP   [DOSVEC]            ; JUMP TO THE DOS COMMAND

D6F2  34 04             LD6F2    PSHS  B                   ; SAVE ACCB
D6F4  C6 05                      LDB   #$05                ; 5 RETRIES
D6F6  F7 09 88                   STB   ATTCTR              ; SAVE RETRY COUNT
D6F9  35 04                      PULS  B                   ; RESTORE ACCB
D6FB  8D 62             LD6FB    BSR   DSKCON              ; GO EXECUTE COMMAND
D6FD  0D F0                      TST   DCSTA               ; CHECK STATUS
D6FF  27 0D                      BEQ   LD70E               ; BRANCH IF NO ERRORS
D701  96 F0             LD701    LDA   DCSTA               ; GET DSKCON ERROR STATUS
D703  C6 3C                      LDB   #2*30               ; 'WRITE PROTECTED' ERROR
D705  85 40                      BITA  #$40                ; CHECK BIT 6 OF STATUS
D707  26 02                      BNE   LD70B               ; BRANCH IF WRITE PROTECT ERROR
D709  C6 28             LD709    LDB   #2*20               ; 'I/O ERROR'
D70B  7E AC 46          LD70B    JMP   LAC46               ; JUMP TO ERROR DRIVER
D70E  34 02             LD70E    PSHS  A                   ; SAVE ACCA
D710  96 EA                      LDA   DCOPC               ; GET OPERATION CODE
D712  81 03                      CMPA  #$03                ; CHECK FOR WRITE SECTOR COMMAND
D714  35 02                      PULS  A                   ; RESTORE ACCA
D716  26 2A                      BNE   LD742               ; RETURN IF NOT WRITE SECTOR
D718  7D 09 87                   TST   DVERFL              ; CHECK VERIFY FLAG
D71B  27 25                      BEQ   LD742               ; RETURN IF NO VERIFY
D71D  34 56                      PSHS  U,X,B,A             ; SAVE REGISTERS
D71F  86 02                      LDA   #$02                ; READ OPERATION CODE
D721  97 EA                      STA   DCOPC               ; STORE TO DSKCON PARAMETER
D723  DE EE                      LDU   DCBPT               ; POINT U TO WRITE BUFFER ADDRESS
D725  8E 07 00                   LDX   #DBUF1              ; * ADDRESS OF VERIFY BUFFER
D728  9F EE                      STX   DCBPT               ; * TO DSKCON VARIABLE
D72A  8D 33                      BSR   DSKCON              ; GO READ SECTOR
D72C  DF EE                      STU   DCBPT               ; RESTORE WRITE BUFFER
D72E  86 03                      LDA   #$03                ; WRITE OP CODE
D730  97 EA                      STA   DCOPC               ; SAVE IN DSKCON VARIABLE
D732  96 F0                      LDA   DCSTA               ; CHECK STATUS FOR THE READ OPERATION
D734  26 0D                      BNE   LD743               ; BRANCH IF ERROR
D736  5F                         CLRB                      ; CHECK 256 BYTES
D737  A6 80             LD737    LDA   ,X+                 ; GET BYTE FROM WRITE BUFFER
D739  A1 C0                      CMPA  ,U+                 ; COMPARE TO READ BUFFER
D73B  26 06                      BNE   LD743               ; BRANCH IF NOT EQUAL
D73D  5A                         DECB                      ; * DECREMENT BYTE COUNTER AND
D73E  26 F7                      BNE   LD737               ; * BRANCH IF NOT DONE
D740  35 56                      PULS  A,B,X,U             ; RESTORE REGISTERS
D742  39                LD742    RTS
D743  35 56             LD743    PULS  A,B,X,U             ; RESTORE REGISTERS
D745  7A 09 88                   DEC   ATTCTR              ; DECREMENT THE VERIFY COUNTER
D748  26 B1                      BNE   LD6FB               ; BRANCH IF MORE TRIES LEFT
D74A  C6 48                      LDB   #2*36               ; 'VERIFY ERROR'
D74C  20 BD                      BRA   LD70B               ; JUMP TO ERROR HANDLER
