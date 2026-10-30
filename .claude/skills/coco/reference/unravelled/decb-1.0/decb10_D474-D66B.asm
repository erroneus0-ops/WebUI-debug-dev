; Disk Extended Color BASIC 1.0 -- $D474-$D66B
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: DSKO=$D474, DSKINI=$D4AB, VERIFY=$D65B

* DSKO$ COMMAND
D474  8D C3             DSKO     BSR   LD439               ; GET THE DRIVE, TRACK AND SECTOR NUMBERS
D476  8D E7                      BSR   LD45F               ; GET THE DESCRIPTOR OF STRING 1
D478  8D BC                      BSR   LD436               ; 'TM' ERROR IF NUMERIC EXPRESSION
D47A  9E 52                      LDX   FPA0+2              ; * GET STRING 1 DESCRIPTOR ADDRESS
D47C  34 10                      PSHS  X                   ; * AND SAVE IT ON THE STACK
D47E  8D DF                      BSR   LD45F               ; GET THE DESCRIPTOR OF STRING 2
D480  BD B6 54                   JSR   LB654               ; *GET LENGTH AND ADDRESS OF STRING 2 AND
D483  34 14                      PSHS  X,B                 ; *SAVE THEM ON THE STACK
D485  5F                         CLRB                      ; SET CLEAR COUNTER TO 256 (FULL SECTOR BUFFER)
D486  8E 06 00                   LDX   #DBUF0              ; USE DBUF0 AS THE DSKO$ I/O BUFFER
D489  6F 80             LD489    CLR   ,X+                 ; CLEAR A BYTE IN I/O BUFFER
D48B  5A                         DECB                      ; DECREMENT CLEAR COUNTER
D48C  26 FB                      BNE   LD489               ; BRANCH IF ALL 256 BYTES NOT CLEARED
D48E  35 14                      PULS  B,X                 ; GET THE LENGTH AND ADDRESS OF STRING 2
D490  CE 06 80                   LDU   #DBUF0+128          ; POINT X TO STRING 2 DESTINATION
D493  8D 96                      BSR   LD42B               ; MOVE STRING 2 DATA INTO DBUF0
D495  35 10                      PULS  X                   ; POINT X TO STRING 1 DESCRIPTOR
D497  BD B6 59                   JSR   LB659               ; GET THE LENGTH AND ADDRESS OF STRING 1
D49A  CE 06 00                   LDU   #DBUF0              ; POINT U TO STRING 1 DESTINATION
D49D  8D 8C                      BSR   LD42B               ; MOVE STRING 1 DATA INTO DBUF0
D49F  C6 03                      LDB   #$03                ; DSKCON WRITE OP CODE
D4A1  8E 06 00          LD4A1    LDX   #DBUF0              ; POINT X TO I/O BUFFER (DBUF0)
D4A4  9F EE                      STX   DCBPT               ; *
D4A6  D7 EA                      STB   DCOPC               ; * SAVE NEW DSKCON BUFFER POINTER AND OP CODE VARIABLES
D4A8  7E D5 FF                   JMP   LD5FF               ; GO WRITE OUT A SECTOR

* DSKINI COMMAND
D4AB  10 27 D1 70       DSKINI   LBEQ  LA61F               ; BRANCH TO 'DN' ERROR IF NO DRIVE NUMBER SPECIFIED
D4AF  BD D1 69                   JSR   LD169               ; CALCULATE DRIVE NUMBER
D4B2  C6 04                      LDB   #$04                ; SKIP FACTOR DEFAULT VALUE
D4B4  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHAR FROM BASiC
D4B6  27 0C                      BEQ   LD4C4               ; BRANCH IF END OF LINE
D4B8  BD B7 38                   JSR   LB738               ; SYNTAX CHECK FOR COMMA AND EVALUATE EXPRESSION
D4BB  C1 11                      CMPB  #17                 ; MAX VALUE OF SKIP FACTOR = 16
D4BD  10 24 DF 89                LBHS  LB44A               ; 'ILLEGAL FUNCTION CALL' IF BAD SKIP FACTOR
D4C1  BD A5 C7                   JSR   LA5C7               ; SYNTAX ERROR IF MORE CHARACTERS ON THE LINE
D4C4  34 04             LD4C4    PSHS  B                   ; SAVE SKIP FACTOR ON THE STACK
D4C6  8E 07 12                   LDX   #DBUF1+SECMAX       ; POINT TO END OF LOGICAL SECTOR NUMBER STORAGE AREA
D4C9  C6 12                      LDB   #SECMAX             ; 18 SECTORS PER TRACK
D4CB  6F 82             LD4CB    CLR   ,-X                 ; CLEAR A BYTE IN THE BUFFER
D4CD  5A                         DECB                      ; CLEARED ALL 18?
D4CE  26 FB                      BNE   LD4CB               ; KEEP GOING IF NOT
D4D0  4F                         CLRA                      ; RESET PHYSICAL SECTOR COUNTER
D4D1  20 0D                      BRA   LD4E0               ; START WITH FIRST PHYSICAL SECTOR = 1

* CALCULATE LOGICAL SECTOR NUMBERS
D4D3  EB E4             LD4D3    ADDB  ,S                  ; ADD SKIP FACTOR TO LOGICAL SECTOR COUNTER
D4D5  5C                LD4D5    INCB                      ; ADD ONE TO LOGICAL SECTOR COUNTER
D4D6  C0 12             LD4D6    SUBB  #SECMAX             ; SUBTRACT MAX NUMBER OF SECTORS
D4D8  24 FC                      BHS   LD4D6               ; BRANCH UNTIL 0 > ACCB >= -18
D4DA  CB 12                      ADDB  #SECMAX             ; ADD 18, NOW ACCB IS 0-17
D4DC  6D 85                      TST   B,X                 ; IS ANYTHING STORED HERE ALREADY?
D4DE  26 F5                      BNE   LD4D5               ; YES - GET ANOTHER SECTOR
D4E0  4C                LD4E0    INCA                      ; * INCREMENT PHYSICAL SECTOR NUMBER AND
D4E1  A7 85                      STA   B,X                 ; * SAVE IT IN THE RAM BUFFER
D4E3  81 12                      CMPA  #SECMAX             ; FINISHED WITH ALL SECTORS?
D4E5  25 EC                      BLO   LD4D3               ; NO - KEEP GOING
D4E7  32 61                      LEAS  $01,S               ; REMOVE SKIP FACTOR FROM STACK
D4E9  8E 22 0F                   LDX   #DFLBUF+$1888-2     ; GET TOP OF RAM USED BY DSKINI
D4EC  9C 27                      CMPX  MEMSIZ              ; IS IT > CLEARED AREA?
D4EE  10 22 D7 52                LBHI  LAC44               ; 'OUT OF MEMORY' ERROR IF > CLEARED AREA
D4F2  BD CA 3B                   JSR   DVEC7               ; CLOSE ALL FILES
D4F5  73 09 5C                   COM   DRESFL              ; SET RESET FLAG TO $FF - THIS WILL CAUSE A DOS RESET
D4F8  10 CE 08 00                LDS   #DBUF1+SECLEN       ; SET STACK TO TOP OF DBUF1
D4FC  BD 95 AC                   JSR   L95AC               ; RESET SAM TO DISPLAY PAGE ZERO AND ALPHA GRAPHICS
D4FF  86 00                      LDA   #$00                ; YOU COULD DELETE THIS INSTRUCTION AND CHANGE FOLLOWING STA TO CLR
D501  97 EA                      STA   DCOPC               ; RESTORE HEAD TO TRACK ZERO DSKCON OP CODE
D503  BD D5 FF                   JSR   LD5FF               ; RESTORE HEAD TO TRACK ZERO
D506  7F 09 85                   CLR   RDYTMR              ; RESET THE READY TIMER
D509  86 C0                      LDA   #$C0                ; * FOC READ ADDRESS CODE
D50B  B7 FF 48                   STA   FDCREG              ; *
D50E  BD D6 DE                   JSR   LD6DE               ; CHECK DRIVE READY - WAIT UNTIL READY
D511  10 26 00 86                LBNE  LD59B               ; BRANCH IF NOT READY - ISSUE AN ERROR
D515  0F EC                      CLR   DCTRK               ; RESET TRACK NUMBER
D517  20 1A                      BRA   LD533               ; START THE FORMATTING PROCESS
D519  81 16             LD519    CMPA  #22                 ; = CHECK FOR TRACK 22 (PRECOMPENSATION)
D51B  25 08                      BLO   LD525               ; = AND BRANCH IF < TRACK 22 - NO PRECOMP
D51D  B6 09 86                   LDA   DRGRAM              ; * GET THE RAM IMAGE OF DSKREG, 'OR'
D520  8A 10                      ORA   #$10                ; * IN THE PRECOMPENSATION FLAG AND
D522  B7 FF 40                   STA   DSKREG              ; * SEND IT TO DSKREG
D525  86 53             LD525    LDA   #$53                ; = GET STEP IN COMMAND
D527  B7 FF 48                   STA   FDCREG              ; = AND SEND IT TO THE 1793
D52A  1E 88                      EXG   A,A                 ; * DELAY AFTER ISSUING COMMAND TO 1793
D52C  1E 88                      EXG   A,A                 ; *
D52E  BD D6 DE                   JSR   LD6DE               ; CHECK DRIVE READY
D531  26 68                      BNE   LD59B               ; BRANCH IF NOT READY - ISSUE AN ERROR
D533  BD D6 FD          LD533    JSR   LD6FD               ; WAIT A WHILE
D536  8D 6C                      BSR   $D5A4               ; BUILD A FORMATTED TRACK IN RAM
D538  10 8E FF 4B                LDY   #FDCREG+3           ; Y POINTS TO 1793 DATA REGISTER
D53C  1A 50                      ORCC  #$50                ; DISABLE INTERRUPTS
D53E  8E D5 62                   LDX   #LD562              ; * GET RETURN ADDRESS AND STORE
D541  BF 09 83                   STX   DNMISV              ; * IT IN THE NON MASKABLE INTERRUPT VECTOR
D544  8E 09 89                   LDX   #DFLBUF             ; POINT X TO THE FORMATTED TRACK RAM IMAGE
D547  B6 FF 48                   LDA   FDCREG              ; RESET STATUS OF THE 1793
D54A  86 FF                      LDA   #$FF                ; * ENABLE THE NMI FLAG TO VECTOR
D54C  B7 09 82                   STA   NMIFLG              ; * OUT OF AN I/O LOOP UPON AN NMI INTERRUPT
D54F  C6 F4                      LDB   #$F4                ; = GET WRITE TRACK COMMAND AND
D551  F7 FF 48                   STB   FDCREG              ; = SEND TO 1793
D554  B6 09 86                   LDA   DRGRAM              ; * GET THE DSKREG RAM IMAGE AND 'OR' IN THE
D557  8A 80                      ORA   #$80                ; * FLAG WHICH WILL ENABLE THE 1793 TO HALT
D559  B7 FF 40                   STA   DSKREG              ; * THE 6809. SEND RESULT TO DSKREG
D55C  E6 80             LD55C    LDB   ,X+                 ; = GET A BYTE FROM THE FORMATTED TRACK
D55E  E7 A4                      STB   ,Y                  ; = RAM IMAGE, SEND IT TO THE 1793 AND
D560  20 FA                      BRA   LD55C               ; = LOOP BACK TO GET ANOTHER BYTE

D562  B6 FF 48          LD562    LDA   FDCREG              ; GET STATUS
D565  1C AF                      ANDCC #$AF                ; ENABLE INTERRUPTS
D567  84 44                      ANDA  #$44                ; * KEEP ONLY WRITE PROTECT & LOST DATA
D569  97 F0                      STA   DCSTA               ; * AND SAVE IT IN THE DSKCON STATUS BYTE
D56B  26 2E                      BNE   LD59B               ; BRANCH IF ERROR
D56D  0C EC                      INC   DCTRK               ; SKIP TO THE NEXT TRACK
D56F  96 EC                      LDA   DCTRK               ; GET THE TRACK NUMBER
D571  81 23                      CMPA  #TRKMAX             ; WAS IT THE LAST TRACK
D573  26 A4                      BNE   LD519               ; NO - KEEP GOING

* VERIFY THAT ALL SECTORS ARE READABLE
D575  86 02                      LDA   #$02                ; = GET THE DSKCON READ OP CODE
D577  97 EA                      STA   DCOPC               ; = AND SAVE IT IN THE DSKCON VARIABLE
D579  8E 06 00                   LDX   #DBUF0              ; * POINT THE DSKCON BUFFER POINTER
D57C  9F EE                      STX   DCBPT               ; * TO DBUF0
D57E  CE 07 00                   LDU   #DBUF1              ; POINT U TO THE LOGICAL SECTOR NUMBERS
D581  4F                         CLRA                      ; RESET THE TRACK COUNTER TO ZERO
D582  97 EC             LD582    STA   DCTRK               ; SET THE DSKCON TRACK VARIABLE
D584  5F                         CLRB                      ; RESET THE SECTOR COUNTER
D585  A6 C5             LD585    LDA   B,U                 ; GET THE PHYSICAL SECTOR NUMBER
D587  97 ED                      STA   DSEC                ; SAVE DSKCON SECTOR VARIABLE
D589  BD D5 FF                   JSR   >LD5FF              ; READ A SECTOR
D58C  5C                         INCB                      ; * INCREMENT THE SECTOR COUNTER
D58D  C1 12                      CMPB  #SECMAX             ; * AND COMPARE IT TO MAXIMUM SECTOR NUMBER
D58F  25 F4                      BLO   LD585               ; * AND KEEP LOOPING IF MORE SECTORS LEFT
D591  96 EC                      LDA   DCTRK               ; = GET THE CURRENT TRACK NUMBER
D593  4C                         INCA                      ; = ADD ONE TO IT, COMPARE TO THE MAXIMUM TRACK
D594  81 23                      CMPA  #TRKMAX             ; = NUMBER AND KEEP LOOPING IF
D596  25 EA                      BLO   LD582               ; = THERE ARE STILL TRACKS TO DO
D598  7E D1 E0                   JMP   LD1E0               ; GO CHECK FOR A DOS RESET
D59B  7F 09 86          LD59B    CLR   DRGRAM              ; CLEAR RAM IMAGE OF DSKREG
D59E  7F FF 40                   CLR   DSKREG              ; CLEAR DSKREG - TURN DISK MOTORS OFF
D5A1  7E D6 0E                   JMP   >LD60E              ; PROCESS DRIVES NOT READY ERROR

* BUILD A FORMATTED TRACK OF DATA IN RAM STARTING AT DFLBUF.

D5A4  8E 09 89                   LDX   #DFLBUF             ; START TRACK BUFFER AT DFLBUF
D5A7  CC 20 4E                   LDD   #$204E              ; GET SET TO WRITE 32 BYTES OF $4E
D5AA  8D 29                      BSR   LD5D5               ; GO WRITE GAP IV
D5AC  5F                         CLRB                      ; RESET SECTOR COUNTER
D5AD  34 04             LD5AD    PSHS  B                   ; SAVE SECTOR COUNTER
D5AF  CE 07 00                   LDU   #DBUF1              ; POINT U TO THE TABLE OF LOGICAL SECTORS
D5B2  E6 C5                      LDB   B,U                 ; * GET LOGICAL SECTOR NUMBER FROM TABLE AND
D5B4  D7 ED                      STB   DSEC                ; * SAVE IT IN THE DSKCON VARIABLE
D5B6  CE D5 E7                   LDU   #LD5E7              ; POINT U TO TABLE OF SECTOR FORMATTING DATA
D5B9  C6 03                      LDB   #$03                ; * GET FIRST 3 DATA BLOCKS AND
D5BB  8D 1E                      BSR   LD5DB               ; * WRITE THEM TO BUFFER
D5BD  96 EC                      LDA   DCTRK               ; = GET TRACK NUMBER AND STORE lT
D5BF  A7 80                      STA   ,X+                 ; = IN THE RAM BUFFER
D5C1  6F 80                      CLR   ,X+                 ; CLEAR A BYTE (SIDE NUMBER) IN BUFFER
D5C3  96 ED                      LDA   DSEC                ; * GET SECTOR NUMBER AND
D5C5  A7 80                      STA   ,X+                 ; * STORE IT IN THE BUFFER
D5C7  C6 09                      LDB   #$09                ; = GET THE LAST NINE DATA BLOCKS AND
D5C9  8D 10                      BSR   LD5DB               ; = WRITE THEM TO THE BUFFER
D5CB  35 04                      PULS  B                   ; GET SECTOR COUNTER
D5CD  5C                         INCB                      ; NEXT SECTOR
D5CE  C1 12                      CMPB  #SECMAX             ; 18 SECTORS PER TRACK
D5D0  25 DB                      BLO   LD5AD               ; BRANCH IF ALL SECTORS NOT DONE
D5D2  CC C8 4E                   LDD   #$C84E              ; WRITE 200 BYTES OF $4E AT END OF TRACK

* WRITE ACCA BYTES OF ACCB INTO BUFFER
D5D5  E7 80             LD5D5    STB   ,X+                 ; STORE A BYTE IN THE BUFFER
D5D7  4A                         DECA                      ; DECREMENT COUNTER
D5D8  26 FB                      BNE   LD5D5               ; BRANCH IF ALL BYTES NOT MOVED
D5DA  39                         RTS
D5DB  34 04             LD5DB    PSHS  B                   ; SAVE THE COUNTER ON THE STACK
D5DD  EC C1                      LDD   ,U++                ; GET TWO BYTES OF DATA FROM THE TABLE
D5DF  8D F4                      BSR   LD5D5               ; WRITE ACCA BYTES OF ACCB INTO THE BUFFER
D5E1  35 04                      PULS  B                   ; * GET THE COUNTER BACK, DECREMENT
D5E3  5A                         DECB                      ; * IT AND BRANCH IF ALL DATA BLOCKS
D5E4  26 F5                      BNE   LD5DB               ; * NOT DONE
D5E6  39                         RTS

* DATA USED TO FORMAT A SECTOR ON THE DISK

* THESE DATA ARE CLOSE TO THE IBM SYSTEM 34 FORMAT FOR 256 BYTE SECTORS.
* DOUBLE DENSITY. THE FORMAT GENERALLY CONFORMS TO THAT SPECIFIED ON THE
* 1793 DATA SHEET. THE GAP SIZES HAVE BEEN REDUCED TO THE MINIMUM
* ALLOWABLE. THE IBM FORMAT USES $40 AS THE FILL CHARACTER FOR THE DATA
* BLOCKS WHILE COLOR DOS USES AN $FF AS THE FILL CHARACTER.
D5E7  08 00             LD6D4    FCB   8,0                 ; SYNC FIELD
D5E9  03 F5                      FCB   3,$F5
D5EB  01 FE                      FCB   1,$FE               ; ID ADDRESS MARK (AM1)
* TRACK, SIDE, AND SECTOR NUMBERS ARE INSERTED HERE
D5ED  01 01                      FCB   1,1                 ; SECTOR SIZE (256 BYTE SECTORS)
D5EF  01 F7                      FCB   1,$F7               ; CRC REQUEST
D5F1  16 4E                      FCB   22,$4E              ; GAP II (POST-ID GAP)
D5F3  0C 00                      FCB   12,0                ; SYNC FIELD
D5F5  03 F5                      FCB   3,$F5
D5F7  01 FB                      FCB   1,$FB               ; DATA ADDRESS MARK (AM2)
D5F9  00 FF                      FCB   0,$FF               ; DATA FIELD (256 BYTES)
D5FB  01 F7                      FCB   1,$F7               ; CRC REQUEST
D5FD  18 4E                      FCB   24,$4E              ; GAP III (POST DATA GAP)


D5FF  34 04             LD5FF    PSHS  B                   ; SAVE ACCB
D601  C6 05                      LDB   #$05                ; 5 RETRIES
D603  F7 09 88                   STB   ATTCTR              ; SAVE RETRY COUNT
D606  35 04                      PULS  B                   ; RESTORE ACCB
D608  8D 62             LD608    BSR   DSKCON              ; GO EXECUTE COMMAND
D60A  0D F0                      TST   DCSTA               ; CHECK STATUS
D60C  27 0D                      BEQ   LD61B               ; BRANCH IF NO ERRORS
D60E  96 F0             LD60E    LDA   DCSTA               ; GET DSKCON ERROR STATUS
D610  C6 3C                      LDB   #2*30               ; 'WRITE PROTECTED' ERROR
D612  85 40                      BITA  #$40                ; CHECK BIT 6 OF STATUS
D614  26 02                      BNE   LD618               ; BRANCH IF WRITE PROTECT ERROR
D616  C6 28             LD616    LDB   #2*20               ; 'I/O ERROR'
D618  7E AC 46          LD618    JMP   LAC46               ; JUMP TO ERROR DRIVER
D61B  34 02             LD61B    PSHS  A                   ; SAVE ACCA
D61D  96 EA                      LDA   DCOPC               ; GET OPERATION CODE
D61F  81 03                      CMPA  #$03                ; CHECK FOR WRITE SECTOR COMMAND
D621  35 02                      PULS  A                   ; RESTORE ACCA
D623  26 2A                      BNE   LD64F               ; RETURN IF NOT WRITE SECTOR
D625  7D 09 87                   TST   DVERVL              ; CHECK VERIFY FLAG
D628  27 25                      BEQ   LD64F               ; RETURN IF NO VERIFY
D62A  34 56                      PSHS  U,X,B,A             ; SAVE REGISTERS
D62C  86 02                      LDA   #$02                ; READ OPERATION CODE
D62E  97 EA                      STA   DCOPC               ; STORE TO DSKCON PARAMETER
D630  DE EE                      LDU   DCBPT               ; POINT U TO WRITE BUFFER ADDRESS
D632  8E 07 00                   LDX   #DBUF1              ; * ADDRESS OF VERIFY BUFFER
D635  9F EE                      STX   DCBPT               ; * TO DSKCON VARIABLE
D637  8D 33                      BSR   DSKCON              ; GO READ SECTOR
D639  DF EE                      STU   DCBPT               ; RESTORE WRITE BUFFER
D63B  86 03                      LDA   #$03                ; WRITE OP CODE
D63D  97 EA                      STA   DCOPC               ; SAVE IN DSKCON VARIABLE
D63F  96 F0                      LDA   DCSTA               ; CHECK STATUS FOR THE READ OPERATION
D641  26 0D                      BNE   LD650               ; BRANCH IF ERROR
D643  5F                         CLRB                      ; CHECK 256 BYTES
D644  A6 80             LD644    LDA   ,X+                 ; GET BYTE FROM WRITE BUFFER
D646  A1 C0                      CMPA  ,U+                 ; COMPARE TO READ BUFFER
D648  26 06                      BNE   LD650               ; BRANCH IF NOT EQUAL
D64A  5A                         DECB                      ; * DECREMENT BYTE COUNTER AND
D64B  26 F7                      BNE   LD644               ; * BRANCH IF NOT DONE
D64D  35 56                      PULS  A,B,X,U             ; RESTORE REGISTERS
D64F  39                LD64F    RTS
D650  35 56             LD650    PULS  A,B,X,U             ; RESTORE REGISTERS
D652  7A 09 88                   DEC   ATTCTR              ; DECREMENT THE VERIFY COUNTER
D655  26 B1                      BNE   LD608               ; BRANCH IF MORE TRIES LEFT
D657  C6 48                      LDB   #2*336              ; 'VERIFY ERROR'
D659  20 BD                      BRA   LD618               ; JUMP TO ERROR HANDLER

* VERIFY COMMAND
D65B  5F                VERIFY   CLRB                      ; OFF FLAG = 0
D65C  81 AA                      CMPA  #$AA                ; OFF TOKEN ?
D65E  27 07                      BEQ   LD667               ; YES
D660  53                         COMB                      ; ON FLAG = $FF
D661  81 88                      CMPA  #$88                ; ON TOKEN
D663  10 26 DC 10                LBNE  LB277               ; BRANCH TO 'SYNTAX ERROR' IF NOT ON OR OFF
D667  F7 09 87          LD667    STB   DVERVL              ; SET VERIFY FLAG
D66A  0E 9F                      JMP   GETNCH              ; GET NEXT CHARACTER FROM BASIC
