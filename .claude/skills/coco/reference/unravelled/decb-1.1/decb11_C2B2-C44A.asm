; Disk Extended Color BASIC 1.1 -- $C2B2-$C44A
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: DVEC22=$C2B2

* CLS RAM VECTOR
C2B2  34 11             DVEC22   PSHS  X,CC                ; SAVE X REG AND STATUS
C2B4  AE 63                      LDX   $03,S               ; LOAD X WITH CALLING ADDRESS
C2B6  8C 97 5F                   CMPX  #L975F              ; COMING FROM EXBAS' GET/PUT?
C2B9  26 04                      BNE   LC2BF               ; NO
C2BB  81 23                      CMPA  #'#'                ; NUMBER SIGN (GET#, PUT#)?
C2BD  27 02                      BEQ   LC2C1               ; BRANCH IF GET OR PUT TO RANDOM FILE
C2BF  35 91             LC2BF    PULS  CC,X,PC             ; RESTORE X REG, STATUS AND RETURN

* GET/PUT TO A DIRECT/RANDOM FILE
C2C1  32 65             LC2C1    LEAS  $05,S               ; PURGE RETURN ADDRESS AND REGISTERS OFF OF THE STACK
C2C3  BD C8 2E                   JSR   LC82E               ; EVALUATE DEVICE NUMBER & SET FCB POINTER
C2C6  9F F1                      STX   FCBTMP              ; SAVE FCB POINTER
C2C8  6F 88 15                   CLR   FCBGET,X            ; * RESET THE GET
C2CB  6F 88 16                   CLR   FCBGET+1,X          ; * DATA POINTER
C2CE  6F 88 17                   CLR   FCBPUT,X            ; = RESET THE PUT
C2D1  6F 88 18                   CLR   FCBPUT+1,X          ; = DATA POINTER
C2D4  6F 06                      CLR   FCBPOS,X            ; RESET PRINT POSITION COUNTER
C2D6  A6 01                      LDA   FCBDRV,X            ; *GET THE FCB DRIVE NUMBER AND
C2D8  97 EB                      STA   DCDRV               ; *SAVE IT IN DSKCON VARIABLE
C2DA  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER FROM BASIC
C2DC  27 0C                      BEQ   LC2EA               ; BRANCH IF END OF LINE
C2DE  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
C2E1  BD B7 3D                   JSR   LB73D               ; EVALUATE EXPRESSION - RETURN IN (X)
C2E4  1F 10                      TFR   X,D                 ; SAVE RECORD NUMBER IN ACCD
C2E6  9E F1             LC2E6    LDX   FCBTMP              ; POINT X TO FCB
C2E8  ED 07                      STD   FCBREC,X            ; SAVE RECORD NUMBER IN FCB
C2EA  EC 07             LC2EA    LDD   FCBREC,X            ; GET RECORD NUMBER
C2EC  27 1D                      BEQ   LC30B               ; 'BAD RECORD' ERROR IF RECORD NUMBER = 0
C2EE  BD C6 85                   JSR   LC685               ; INCREMENT RECORD NUMBER
C2F1  EC 09                      LDD   FCBRLN,X            ; * GET RANDOM FILE RECORD LENGTH AND RANDOM FILE
C2F3  AE 0B                      LDX   FCBBUF,X            ; * BUFFER POINTER AND SAVE THEM ON THE STACK -
C2F5  34 16                      PSHS  X,B,A               ; * THESE ARE THE INITIAL VALUES OF A TEMPORARY
* * RECORD LENGTH COUNTER AND RANDOM BUFFER
* * POINTER WHICH ARE MAINTAINED ON THE STACK
C2F7  30 5E                      LEAX  $-2,U               ; POINT X TO (RECORD NUMBER -1)
C2F9  BD 9F B5                   JSR   L9FB5               ; MULT (UNSIGNED) RECORD LENGTH X (RECORD NUMBER -1)
C2FC  34 60                      PSHS  U,Y                 ; SAVE PRODUCT ON THE STACK
C2FE  A6 E0                      LDA   ,S+                 ; CHECK MS BYTE OF PRODUCT
C300  26 09                      BNE   LC30B               ; 'BR' ERROR IF NOT ZERO (RECORD NUMBER TOO BIG)
C302  35 10                      PULS  X                   ; * PULL THE BOTTOM 3 PRODUCT BYTES OFF THE STACK;
C304  35 04                      PULS  B                   ; * TOP TWO IN X, BOTTOM IN ACCB; ACCB POINTS TO
* * THE FIRST BYTE OF THE SECTOR USED BY THIS RECORD,
* * (X) CONTAINS THE SECTOR OFFSET (IN WHICH SECTOR
* * FROM THE START THE BYTE IS LOCATED)
C306  8C 02 64          LC306    CMPX  #(TRKMAX-1)         ; 612 SECTORS MAX IN A RANDOM FILE
C309  25 05                      BLO   LC310               ; BRANCH IF RECORD LENGTH O.K.
C30B  C6 36             LC30B    LDB   #2*27               ; 'BAD RECORD' ERROR
C30D  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER
C310  DE F1             LC310    LDU   FCBTMP              ; POINT U TO FCB
C312  AC 4D                      CMPX  FCBSOF,U            ; * COMPARE SAVED SECTOR OFFSET TO THE CURRENT SECTOR OFFSET
C314  10 27 00 B7                LBEQ  LC3CF               ; * BEING PROCESSED - DO NOT PROCESS A NEW SECTOR IF THEY ARE EQUAL
C318  34 14                      PSHS  X,B                 ; SAVE BYTE AND SECTOR OFFSET TO RECORD START ON STACK
C31A  A6 4F                      LDA   FCBFLG,U            ; * CHECK FCB GET/PUT FLAG AND
C31C  27 06                      BEQ   LC324               ; * BRANCH IF IT WAS A GET
C31E  6F 4F                      CLR   FCBFLG,U            ; FORCE GET/PUT TO 'PUT'
C320  C6 03                      LDB   #$03                ; DSKCON WRITE OP CODE
C322  8D 33                      BSR   LC357               ; GO WRITE A SECTOR - SAVE 'PUT' DATA ON DISK
* CONVERT THE SECTOR OFFSET TO A GRANULE AND SECTOR NUMBER
C324  EC 61             LC324    LDD   $01,S               ; * GET THE NUMBER OF SECTORS TO THE START OF
C326  BD C7 84                   JSR   LC784               ; * THIS RECORD NUMBER AND CONVERT THEM TO A GRANULE OFFSET
C329  34 04                      PSHS  B                   ; SAVE GRANULE OFFSET ON THE STACK
C32B  BD C7 79                   JSR   LC779               ; MULTIPLY GRANULE NUMBER X 9 - CONVERT TO NUMBER OF SECTORS
C32E  50                         NEGB                      ; * NEGATE LS BYTE OF GRANULE OFFSET AND ADD THE
C32F  EB 63                      ADDB  $03,S               ; * LS BYTE OF SECTOR OFFSET - ACCB = SECTOR
* * NUMBER (0-8) CORRESPONDING TO THE SECTOR NUMBER WITHIN A
* * GRANULE OF THE LAST SECTOR OF THE SECTOR OFFSET
C331  5C                         INCB                      ; = ADD ONE - SECTORS SAVED IN THE FCB; START
C332  E7 44                      STB   FCBSEC,U            ; = AT 1 NOT 0 - SAVE IT IN THE FCB
C334  E6 42                      LDB   FCBFGR,U            ; GET FIRST GRANULE IN FILE
C336  BD C7 55                   JSR   LC755               ; POINT X TO FAT
C339  33 06                      LEAU  FATCON,X            ; POINT U TO FAT DATA
C33B  A6 E4                      LDA   ,S                  ; GET NUMBER OF GRANULES OFFSET TO RECORD
C33D  4C                         INCA                      ; ADD ONE (COMPENSATE FOR DECA BELOW)
C33E  30 C4             LC33E    LEAX  ,U                  ; POINT X TO FAT DATA
C340  3A                         ABX                       ; POINT X TO CORRECT GRANULE
C341  4A                         DECA                      ; DECREMENT GRANULE COUNTER
C342  27 37                      BEQ   LC37B               ; BRANCH IF CORRECT GRANULE FOUND
C344  E7 E4                      STB   ,S                  ; SAVE GRANULE ADDRESS ON STACK
C346  E6 84                      LDB   ,X                  ; GET NEXT GRANULE IN FILE
C348  C1 C0                      CMPB  #$C0                ; LAST GRANULE IN FILE?
C34A  25 F2                      BLO   LC33E               ; NO - KEEP LOOKING

* THE GRANULE BEING SEARCHED FOR IS NOT PRESENTLY DEFINED IN THIS RANDOM FILE
C34C  E6 E4                      LDB   ,S                  ; GET OFFSET TO LAST GRANULE
C34E  0D D8                      TST   VD8                 ; * CHECK GET/PUT FLAG
C350  26 14                      BNE   LC366               ; * AND BRANCH IF PUT
C352  C6 2E             LC352    LDB   #2*23               ; 'INPUT PAST END OF FILE' ERROR
C354  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER
C357  30 C8 19          LC357    LEAX  FCBCON,U            ; POINT X TO FCB DATA BUFFER

* READ/WRITE A SECTOR. ENTER WITH OP CODE IN ACCB, BUFFER PTR IN X
C35A  D7 EA             LC35A    STB   DCOPC               ; SAVE DSKCON OPERATION CODE VARIABLE
C35C  9F EE                      STX   DCBPT               ; SAVE DSKCON LOAD BUFFER VARIABLE
C35E  30 C4                      LEAX  ,U                  ; POINT X TO FCB
C360  BD C7 63                   JSR   LC763               ; CONVERT FCB TRACK AND SECTOR TO DSKCON VARIABLES
C363  7E D6 F2                   JMP   LD6F2               ; READ/WRITE A TRACK OR SECTOR

* 'PUT' DATA INTO A GRANULE NOT PRESENTLY INCLUDED IN THIS FILE
C366  34 12             LC366    PSHS  X,A                 ; SAVE GRANULE COUNTER AND POINTER TO LAST USED GRANULE
C368  BD C7 BF                   JSR   LC7BF               ; FIND FIRST FREE GRANULE IN FAT
C36B  1F 89                      TFR   A,B                 ; SAVE FREE GRANULE NUMBER IN ACCB
C36D  35 42                      PULS  A,U                 ; PULL LAST GRANULE POINTER AND COUNTER OFF OF STACK
C36F  E7 C4                      STB   ,U                  ; SAVE NEWLY FOUND GRANULE NUMBER IN ADDRESS OF LAST GRANULE
C371  4A                         DECA                      ; DECREMENT GRANULE COUNTER
C372  26 F2                      BNE   LC366               ; GET ANOTHER GRANULE IF NOT DONE
C374  34 14                      PSHS  X,B                 ; SAVE POINTER TO LAST GRANULE AND OFFSET
C376  BD C7 1E                   JSR   LC71E               ; WRITE FAT TO DISK
C379  35 14                      PULS  B,X                 ; RESTORE POINTER AND OFFSET

* WHEN CORRECT GRANULE IS FOUND, FIND THE RIGHT SECTOR
C37B  32 61             LC37B    LEAS  $01,S               ; REMOVE GRAN NUMBER FROM STACK
C37D  DE F1                      LDU   FCBTMP              ; POINT U TO FCB
C37F  E7 43                      STB   FCBCGR,U            ; SAVE CURRENT GRANULE IN FCB
C381  86 FF                      LDA   #$FF                ; *SET FCBSOF,U TO ILLEGAL SECTOR OFFSET WHICH WILL
C383  A7 4D                      STA   FCBSOF,U            ; *FORCE NEW SECTOR DATA TO BE READ IN
C385  A6 84                      LDA   ,X                  ; GET CURRENT GRANULE
C387  81 C0                      CMPA  #$C0                ; IS IT THE LAST GRANULE?
C389  25 27                      BLO   LC3B2               ; NO
C38B  84 3F                      ANDA  #$3F                ; MASK OFF LAST GRANULE FLAG BITS
C38D  A1 44                      CMPA  FCBSEC,U            ; * COMPARE CALCULATED SECTOR TO CURRENT SECTOR IN FCB
C38F  24 21                      BHS   LC3B2               ; * AND BRANCH IF CALCULATED SECTOR IS > LAST SECTOR IN FILE
C391  96 D8                      LDA   VD8                 ; = CHECK GET/PUT FLAG: IF 'GET' THEN 'INPUT
C393  27 BD                      BEQ   LC352               ; = PAST END OF FILE' ERROR
C395  A6 44                      LDA   FCBSEC,U            ; * GET CURRENT SECTOR NUMBER FROM FCB,
C397  8A C0                      ORA   #$C0                ; * OR IN THE LAST GRANULE FLAG BITS
C399  A7 84                      STA   ,X                  ; * AND SAVE IN FAT
C39B  BD C5 A9                   JSR   LC5A9               ; WRITE FAT TO DISK IF NECESSARY
C39E  AE 49                      LDX   FCBRLN,U            ; * GET RECORD LENGTH AND CHECK TO
C3A0  8C 01 00                   CMPX  #SECLEN             ; * SEE IF IT IS SECLEN (EXACTLY ONE SECTOR)
C3A3  26 08                      BNE   LC3AD               ; BRANCH IF IT IS NOT EXACTLY ONE SECTOR
C3A5  AC C8 13                   CMPX  FCBLST,U            ; =BRANCH IF THE NUMBER OF BYTES IN THE LAST SECTOR
C3A8  27 08                      BEQ   LC3B2               ; =IS SET TO ONE SECTOR (SECLEN)
C3AA  86 81                      LDA   #$81                ; *SET THE PRESAVED FLAG (BIT15) AND FORCE
C3AC  21 4F             LC3AC    BRN   $C3FD               ; *THE NUMBER OF BYTES IN LAST SECTOR TO 256
C3AD  4F                LC3AD    CLRA                      ; SET THE NUMBER OF BYTES IN LAST SECTOR TO ZERO
C3AE  5F                         CLRB                      ; CLEAR LS BYTE OF ACCD
C3AF  ED C8 13                   STD   FCBLST,U            ; SAVE THE NUMBER OF BYTES IN LAST SECTOR
C3B2  C6 02             LC3B2    LDB   #$02                ; DSKCON READ OP CODE
C3B4  AE 49                      LDX   FCBRLN,U            ; * GET RECORD LENGTH AND COMPARE
C3B6  8C 01 00                   CMPX  #SECLEN             ; * IT TO SECLEN - EXACTLY ONE SECTOR
C3B9  26 0D                      BNE   LC3C8               ; BRANCH IF NOT EXACTLY ONE SECTOR LONG
C3BB  32 67                      LEAS  $07,S               ; CLEAN UP STACK
C3BD  AE 4B                      LDX   FCBBUF,U            ; POINT X TO START OF RANDOM FILE BUFFER
C3BF  96 D8                      LDA   VD8                 ; * CHECK GET/PUT FLAG AND
C3C1  27 02                      BEQ   LC3C5               ; * BRANCH IF GET
C3C3  C6 03                      LDB   #$03                ; DSKCON WRITE OP CODE
C3C5  7E C3 5A          LC3C5    JMP   >LC35A              ; READ/WRITE A SECTOR
C3C8  BD C3 57          LC3C8    JSR   >LC357              ; READ A SECTOR INTO FCB DATA BUFFER
C3CB  35 14                      PULS  B,X                 ; * GET BACK THE BYTE OFFSET TO RECORD: X = NUMBER OF
* * SECTORS; ACCB = BYTE POINTER IN SECTOR
C3CD  AF 4D                      STX   FCBSOF,U            ; SAVE SECTOR OFFSET IN FCB
C3CF  34 04             LC3CF    PSHS  B                   ; SAVE BYTE OFFSET ON STACK
C3D1  BD C7 55                   JSR   LC755               ; POINT X TO FILE ALLOCATION TABLE
C3D4  30 06                      LEAX  FATCON,X            ; MOVE X TO FAT DATA
C3D6  E6 43                      LDB   FCBCGR,U            ; GET CURRENT GRANULE NUMBER
C3D8  3A                         ABX                       ; POINT X TO PROPER GRANULE IN FAT
C3D9  A6 84                      LDA   ,X                  ; * GET CURRENT GRANULE AND CHECK TO
C3DB  81 C0                      CMPA  #$C0                ; * SEE IF IT IS LAST GRANULE
C3DD  25 2B                      BLO   LC40A               ; BRANCH IF THIS GRANULE IS < LAST GRANULE
C3DF  84 3F                      ANDA  #$3F                ; MASK OFF LAST GRANULE FLAG BITS
C3E1  A1 44                      CMPA  FCBSEC,U            ; * COMPARE LAST SECTOR USED IN GRANULE TO
C3E3  26 25                      BNE   LC40A               ; * CALCULATED SECTOR; BRANCH IF NOT EQUAL
C3E5  EC C8 13                   LDD   FCBLST,U            ; GET NUMBER OF BYTES IN LAST SECTOR
C3E8  84 7F                      ANDA  #$7F                ; MASK OFF PRESAVED FLAG (BIT 15)
C3EA  34 06                      PSHS  B,A                 ; SAVE NUMBER OF BYTES IN LAST SECTOR ON STACK
C3EC  4F                         CLRA                      ; * LOAD ACCB WITH THE BYTE OFFSET TO CURRENT
C3ED  E6 62                      LDB   $02,S               ; * RECORD AND ADD THE REMAINING RECORD LENGTH
C3EF  E3 63                      ADDD  $03,S               ; * TO IT - ACCD = END OF RECORD OFFSET
C3F1  10 A3 E1                   CMPD  ,S++                ; =COMPARE THE END OF RECORD OFFSET TO THE NUMBER OF
C3F4  23 14                      BLS   LC40A               ; =BYTES USED IN THE LAST SECTOR
C3F6  0D D8                      TST   VD8                 ; * CHECK GET/PUT FLAG AND BRANCH IF 'GET'
C3F8  10 27 FF 56                LBEQ  LC352               ; * TO 'INPUT PAST END OF FILE' ERROR

* IF LAST USED SECTOR, CALCULATE HOW MANY BYTES ARE USED
* IF DATA IS BEING 'PUT' PASTH THE CURRENT END OF FILE
C3FC  10 83 01 00                CMPD  #SECLEN             ; COMPARE TO ONE SECTOR'S LENGTH
C400  23 03                      BLS   LC405               ; BRANCH IF REMAINDER OF RECORD LENGTH WILL FIT IN THIS SECTOR
C402  CC 01 00                   LDD   #SECLEN             ; FORCE NUMBER OF BYTES = ONE SECTOR LENGTH
C405  8A 80             LC405    ORA   #$80                ; * SET PRE-SAVED FLAG BIT - ALL PUT RECORDS ARE
* * WRITTEN TO DISK BEFORE LEAVING 'PUT'
C407  ED C8 13                   STD   FCBLST,U            ; SAVE NUMBER OF BYTES USED IN LAST SECTOR
C40A  35 04             LC40A    PULS  B                   ; PULL BYTE OFFSET OFF OF THE STACK
C40C  30 C8 19                   LEAX  FCBCON,U            ; POINT X TO FCB DATA BUFFER
C40F  3A                         ABX                       ; MOVE X TO START OF RECORD
C410  EE 62                      LDU   $02,S               ; POINT U TO CURRENT POSITION IN RANDOM FILE BUFFER
C412  34 04                      PSHS  B                   ; SAVE BYTE OFFSET ON STACK
C414  86 FF                      LDA   #-1                 ; * CONVERT ACCD INTO A NEGATIVE 2 BYTE NUMBER
* * REPRESENTING THE REMAINING UNUSED BYTES IN THE SECTOR
C416  E3 61                      ADDD  $01,S               ; * ADD TEMPORARY RECORD LENGTH COUNTER (SUBTRACT
* * REMAINING BYTES FROM TEMPORARY RECORD LENGTH)
C418  24 07                      BHS   LC421               ; BRANCH IF THERE ARE ENOUGH UNUSED BYTES TO FINISH THE RECORD
C41A  ED 61                      STD   $01,S               ; SAVE NEW TEMPORARY RECORD LENGTH COUNTER
C41C  35 04                      PULS  B                   ; RESTORE BYTE COUNTER
C41E  50                         NEGB                      ; * NEGATE IT - ACCB = THE NUMBER OF BYTES
* * AVAILABLE TO A RECORD IN THIS SECTOR
C41F  20 08                      BRA   LC429               ; MOVE THE DATA

* BRANCH HERE IF REMAINING RECORD LENGTH WILL FIT IN
* WHAT'S LEFT OF THE CURRENTLY SELECTED SECTOR
C421  E6 62             LC421    LDB   $02,S               ; GET REMAINING RECORD LENGTH
C423  6F 61                      CLR   $01,S               ; * CLEAR THE TEMPORARY RECORD LENGTH
C425  6F 62                      CLR   $02,S               ; * COUNTER ON THE STACK
C427  32 61                      LEAS  $01,S               ; PURGE BYTE OFFSET FROM STACK
C429  96 D8             LC429    LDA   VD8                 ; * CHECK GET/PUT FLAG AND
C42B  27 02                      BEQ   LC42F               ; * BRANCH IF GET
C42D  1E 13                      EXG   X,U                 ; SWAP SOURCE AND DESTINATION POINTERS
C42F  BD A5 9A          LC42F    JSR   LA59A               ; TRANSFER DATA FROM SOURCE TO DESTINATION BUFFERS
C432  EF 62                      STU   $02,S               ; SAVE NEW TEMP RECORD POINTER ON THE STACK (GET)

* MOVE DATA FROM FCB DATA BUFFER TO THE RANDOM FILE BUFFER IF 'GET'
* OR FROM RANDOM FILE BUFFER TO FCB DATA BUFFER IF 'PUT'
C434  DE F1                      LDU   FCBTMP              ; POINT U TO FCB
C436  96 D8                      LDA   VD8                 ; * CHECK GET/PUT FLAG AND
C438  27 04                      BEQ   LC43E               ; * BRANCH IF GET
C43A  A7 4F                      STA   FCBFLG,U            ; SAVE 'PUT' FLAG IN THE FCB
C43C  AF 62                      STX   $02,S               ; SAVE NEW TEMPORARY RECORD POINTER ON STACK (PUT)
C43E  AE 4D             LC43E    LDX   FCBSOF,U            ; * GET SECTOR OFFSET COUNTER AND
C440  30 01                      LEAX  $01,X               ; * ADD ONE TO IT
C442  5F                         CLRB                      ; SET BYTE OFFSET = 0
C443  EE E4                      LDU   ,S                  ; * CHECK THE LENGTH OF THE TEMPORARY RECORD LENGTH
C445  10 26 FE BD                LBNE  LC306               ; * COUNTER AND KEEP MOVING DATA IF <> 0
C449  35 96                      PULS  A,B,X,PC            ; * PULL TEMPORARY RECORD LENGTH AND
