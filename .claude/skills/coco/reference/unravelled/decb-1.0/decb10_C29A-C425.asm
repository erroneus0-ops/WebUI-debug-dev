; Disk Extended Color BASIC 1.0 -- $C29A-$C425
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: DVEC22=$C29A

* CLS RAM VECTOR
C29A  34 11             DVEC22   PSHS  X,CC                ; SAVE X REG AND STATUS
C29C  AE 63                      LDX   $03,S               ; LOAD X WITH CALLING ADDRESS
C29E  8C 97 5F                   CMPX  #L975F              ; COMING FROM EXBAS' GET/PUT?
C2A1  26 04                      BNE   LC2A7               ; NO
C2A3  81 23                      CMPA  #'#'                ; NUMBER SIGN (GET#, PUT#)?
C2A5  27 02                      BEQ   LC2A9               ; BRANCH IF GET OR PUT TO RANDOM FILE
C2A7  35 91             LC2A7    PULS  CC,X,PC             ; RESTORE X REG, STATUS AND RETURN

* GET/PUT TO A DIRECT/RANDOM FILE
C2A9  32 65             LC2A9    LEAS  $05,S               ; PURGE RETURN ADDRESS AND REGISTERS OFF OF THE STACK
C2AB  BD C7 FE                   JSR   LC7FE               ; EVALUATE DEVICE NUMBER & SET FCB POINTER
C2AE  9F F1                      STX   FCBTMP              ; SAVE FCB POINTER
C2B0  6F 88 15                   CLR   FCBGET,X            ; * RESET THE GET
C2B3  6F 88 16                   CLR   FCBGET+1,X          ; * DATA POINTER
C2B6  6F 88 17                   CLR   FCBPUT,X            ; = RESET THE PUT
C2B9  6F 88 18                   CLR   FCBPUT+1,X          ; = DATA POINTER
C2BC  6F 06                      CLR   FCBPOS,X            ; RESET PRINT POSITION COUNTER
C2BE  A6 01                      LDA   FCBDRV,X            ; *GET THE FCB DRIVE NUMBER AND
C2C0  97 EB                      STA   DCDRV               ; *SAVE IT IN DSKCON VARIABLE
C2C2  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER FROM BASIC
C2C4  27 0A                      BEQ   LC2D0               ; BRANCH IF END OF LINE
C2C6  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
C2C9  BD B3 E6                   JSR   LB3E6               ; EVALUATE EXPRESSION - RETURN IN ACCD
C2CC  9E F1             LC2CC    LDX   FCBTMP              ; POINT X TO FCB
C2CE  ED 07                      STD   FCBREC,X            ; SAVE RECORD NUMBER IN FCB
C2D0  BD C6 58          LC2D0    JSR   LC658               ; INCREMENT RECORD NUMBER
C2D3  EC 09                      LDD   FCBRLN,X            ; * GET RANDOM FILE RECORD LENGTH AND RANDOM FILE
C2D5  AE 0B                      LDX   FCBBUF,X            ; * BUFFER POINTER AND SAVE THEM ON THE STACK -
C2D7  34 16                      PSHS  X,B,A               ; * THESE ARE THE INITIAL VALUES OF A TEMPORARY
* * RECORD LENGTH COUNTER AND RANDOM BUFFER
* * POINTER WHICH ARE MAINTAINED ON THE STACK
C2D9  30 5E                      LEAX  -2,U                ; POINT X TO (RECORD NUMBER -1)
C2DB  BD 9F B5                   JSR   L9FB5               ; MULT (UNSIGNED) RECORD LENGTH X (RECORD NUMBER -1)
C2DE  34 60                      PSHS  U,Y                 ; SAVE PRODUCT ON THE STACK
C2E0  A6 E0                      LDA   ,S+                 ; CHECK MS BYTE OF PRODUCT
C2E2  26 09                      BNE   LC2ED               ; 'BR' ERROR IF NOT ZERO (RECORD NUMBER TOO BIG)
C2E4  35 10                      PULS  X                   ; * PULL THE BOTTOM 3 PRODUCT BYTES OFF THE STACK;
C2E6  35 04                      PULS  B                   ; * TOP TWO IN X, BOTTOM IN ACCB; ACCB POINTS TO
* * THE FIRST BYTE OF THE SECTOR USED BY THIS RECORD,
* * (X) CONTAINS THE SECTOR OFFSET (IN WHICH SECTOR
* * FROM THE START THE BYTE IS LOCATED)
C2E8  8C 02 64          LC2E8    CMPX  #(TRKMAX-1)         ; 612 SECTORS MAX IN A RANDOM FILE
C2EB  25 05                      BLO   LC2F2               ; BRANCH IF RECORD LENGTH O.K.
C2ED  C6 36             LC2ED    LDB   #2*27               ; 'BAD RECORD' ERROR
C2EF  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER
C2F2  DE F1             LC2F2    LDU   FCBTMP              ; POINT U TO FCB
C2F4  AC 4D                      CMPX  FCBSOF,U            ; * COMPARE SAVED SECTOR OFFSET TO THE CURRENT SECTOR OFFSET
C2F6  10 27 00 B7                LBEQ  LC3B1               ; * BEING PROCESSED - DO NOT PROCESS A NEW SECTOR IF THEY ARE EQUAL
C2FA  34 14                      PSHS  X,B                 ; SAVE BYTE AND SECTOR OFFSET TO RECORD START ON STACK
C2FC  A6 4F                      LDA   FCBFLG,U            ; * CHECK FCB GET/PUT FLAG AND
C2FE  27 06                      BEQ   LC306               ; * BRANCH IF IT WAS A GET
C300  6F 4F                      CLR   FCBFLG,U            ; FORCE GET/PUT TO 'PUT'
C302  C6 03                      LDB   #$03                ; DSKCON WRITE OP CODE
C304  8D 33                      BSR   LC339               ; GO WRITE A SECTOR - SAVE 'PUT' DATA ON DISK
* CONVERT THE SECTOR OFFSET TO A GRANULE AND SECTOR NUMBER
C306  EC 61             LC306    LDD   $01,S               ; * GET THE NUMBER OF SECTORS TO THE START OF
C308  BD C7 54                   JSR   LC754               ; * THIS RECORD NUMBER AND CONVERT THEM TO A GRANULE OFFSET
C30B  34 04                      PSHS  B                   ; SAVE GRANULE OFFSET ON THE STACK
C30D  BD C7 49                   JSR   LC749               ; MULTIPLY GRANULE NUMBER X 9 - CONVERT TO NUMBER OF SECTORS
C310  50                         NEGB                      ; * NEGATE LS BYTE OF GRANULE OFFSET AND ADD THE
C311  EB 63                      ADDB  $03,S               ; * LS BYTE OF SECTOR OFFSET - ACCB = SECTOR
* * NUMBER (0-8) CORRESPONDING TO THE SECTOR NUMBER WITHIN A
* * GRANULE OF THE LAST SECTOR OF THE SECTOR OFFSET
C313  5C                         INCB                      ; = ADD ONE - SECTORS SAVED IN THE FCB; START
C314  E7 44                      STB   FCBSEC,U            ; = AT 1 NOT 0 - SAVE IT IN THE FCB
C316  E6 42                      LDB   FCBFGR,U            ; GET FIRST GRANULE IN FILE
C318  BD C7 25                   JSR   LC725               ; POINT X TO FAT
C31B  33 06                      LEAU  FATCON,X            ; POINT U TO FAT DATA
C31D  A6 E4                      LDA   ,S                  ; GET NUMBER OF GRANULES OFFSET TO RECORD
C31F  4C                         INCA                      ; ADD ONE (COMPENSATE FOR DECA BELOW)
C320  30 C4             LC320    LEAX  ,U                  ; POINT X TO FAT DATA
C322  3A                         ABX                       ; POINT X TO CORRECT GRANULE
C323  4A                         DECA                      ; DECREMENT GRANULE COUNTER
C324  27 37                      BEQ   LC35D               ; BRANCH IF CORRECT GRANULE FOUND
C326  E7 E4                      STB   ,S                  ; SAVE GRANULE ADDRESS ON STACK
C328  E6 84                      LDB   ,X                  ; GET NEXT GRANULE IN FILE
C32A  C1 C0                      CMPB  #$C0                ; LAST GRANULE IN FILE?
C32C  25 F2                      BLO   LC320               ; NO - KEEP LOOKING

* THE GRANULE BEING SEARCHED FOR IS NOT PRESENTLY DEFINED IN THIS RANDOM FILE
C32E  E6 E4                      LDB   ,S                  ; GET OFFSET TO LAST GRANULE
C330  0D D8                      TST   VD8                 ; * CHECK GET/PUT FLAG
C332  26 14                      BNE   LC348               ; * AND BRANCH IF PUT
C334  C6 2E             LC334    LDB   #2*23               ; 'INPUT PAST END OF FILE' ERROR
C336  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER
C339  30 C8 19          LC339    LEAX  FCBCON,U            ; POINT X TO FCB DATA BUFFER

* READ/WRITE A SECTOR. ENTER WITH OP CODE IN ACCB, BUFFER PTR IN X
C33C  D7 EA             LC33C    STB   DCOPC               ; SAVE DSKCON OPERATION CODE VARIABLE
C33E  9F EE                      STX   DCBPT               ; SAVE DSKCON LOAD BUFFER VARIABLE
C340  30 C4                      LEAX  ,U                  ; POINT X TO FCB
C342  BD C7 33                   JSR   LC733               ; CONVERT FCB TRACK AND SECTOR TO DSKCON VARIABLES
C345  7E D5 FF                   JMP   LD5FF               ; READ/WRITE A TRACK OR SECTOR

* 'PUT' DATA INTO A GRANULE NOT PRESENTLY INCLUDED IN THIS FILE
C348  34 12             LC348    PSHS  X,A                 ; SAVE GRANULE COUNTER AND POINTER TO LAST USED GRANULE
C34A  BD C7 8F                   JSR   LC78F               ; FIND FIRST FREE GRANULE IN FAT
C34D  1F 89                      TFR   A,B                 ; SAVE FREE GRANULE NUMBER IN ACCB
C34F  35 42                      PULS  A,U                 ; PULL LAST GRANULE POINTER AND COUNTER OFF OF STACK
C351  E7 C4                      STB   ,U                  ; SAVE NEWLY FOUND GRANULE NUMBER IN ADDRESS OF LAST GRANULE
C353  4A                         DECA                      ; DECREMENT GRANULE COUNTER
C354  26 F2                      BNE   LC348               ; GET ANOTHER GRANULE IF NOT DONE
C356  34 14                      PSHS  X,B                 ; SAVE POINTER TO LAST GRANULE AND OFFSET
C358  BD C6 F1                   JSR   LC6F1               ; WRITE FAT TO DISK
C35B  35 14                      PULS  B,X                 ; RESTORE POINTER AND OFFSET

* WHEN CORRECT GRANULE IS FOUND, FIND THE RIGHT SECTOR
C35D  32 61             LC35D    LEAS  $01,S               ; REMOVE GRAN NUMBER FROM STACK
C35F  DE F1                      LDU   FCBTMP              ; POINT U TO FCB
C361  E7 43                      STB   FCBCGR,U            ; SAVE CURRENT GRANULE IN FCB
C363  86 FF                      LDA   #$FF                ; *SET FCBSOF,U TO ILLEGAL SECTOR OFFSET WHICH WILL
C365  A7 4D                      STA   FCBSOF,U            ; *FORCE NEW SECTOR DATA TO BE READ IN
C367  A6 84                      LDA   ,X                  ; GET CURRENT GRANULE
C369  81 C0                      CMPA  #$C0                ; IS IT THE LAST GRANULE?
C36B  25 27                      BLO   LC394               ; NO
C36D  84 3F                      ANDA  #$3F                ; MASK OFF LAST GRANULE FLAG BITS
C36F  A1 44                      CMPA  FCBSEC,U            ; * COMPARE CALCULATED SECTOR TO CURRENT SECTOR IN FCB
C371  24 21                      BHS   LC394               ; * AND BRANCH IF CALCULATED SECTOR IS > LAST SECTOR IN FILE
C373  96 D8                      LDA   VD8                 ; = CHECK GET/PUT FLAG: IF 'GET' THEN 'INPUT
C375  27 BD                      BEQ   LC334               ; = PAST END OF FILE' ERROR
C377  A6 44                      LDA   FCBSEC,U            ; * GET CURRENT SECTOR NUMBER FROM FCB,
C379  8A C0                      ORA   #$C0                ; * OR IN THE LAST GRANULE FLAG BITS
C37B  A7 84                      STA   ,X                  ; * AND SAVE IN FAT
C37D  BD C5 7C                   JSR   LC57C               ; WRITE FAT TO DISK IF NECESSARY
C380  AE 49                      LDX   FCBRLN,U            ; * GET RECORD LENGTH AND CHECK TO
C382  8C 01 00                   CMPX  #SECLEN             ; * SEE IF IT IS SECLEN (EXACTLY ONE SECTOR)
C385  26 08                      BNE   LC38F               ; BRANCH IF IT IS NOT EXACTLY ONE SECTOR
C387  AC C8 13                   CMPX  FCBLST,U            ; =BRANCH IF THE NUMBER OF BYTES IN THE LAST SECTOR
C38A  27 08                      BEQ   LC394               ; =IS SET TO ONE SECTOR (SECLEN)
C38C  86 81                      LDA   #$81                ; *SET THE PRESAVED FLAG (BIT15) AND FORCE
C38E  21 4F             LC38E    BRN   LC3DF               ; *THE NUMBER OF BYTES IN LAST SECTOR TO 256
C38F  4F                LC38F    CLRA                      ; SET THE NUMBER OF BYTES IN LAST SECTOR TO ZERO
C390  5F                         CLRB                      ; CLEAR LS BYTE OF ACCD
C391  ED C8 13                   STD   FCBLST,U            ; SAVE THE NUMBER OF BYTES IN LAST SECTOR
C394  C6 02             LC394    LDB   #$02                ; DSKCON READ OP CODE
C396  AE 49                      LDX   FCBRLN,U            ; * GET RECORD LENGTH AND COMPARE
C398  8C 01 00                   CMPX  #SECLEN             ; * IT TO SECLEN - EXACTLY ONE SECTOR
C39B  26 0D                      BNE   LC3AA               ; BRANCH IF NOT EXACTLY ONE SECTOR LONG
C39D  32 67                      LEAS  $07,S               ; CLEAN UP STACK
C39F  AE 4B                      LDX   FCBBUF,U            ; POINT X TO START OF RANDOM FILE BUFFER
C3A1  96 D8                      LDA   VD8                 ; * CHECK GET/PUT FLAG AND
C3A3  27 02                      BEQ   LC3A7               ; * BRANCH IF GET
C3A5  C6 03                      LDB   #$03                ; DSKCON WRITE OP CODE
C3A7  7E C3 3C          LC3A7    JMP   >LC33C              ; READ/WRITE A SECTOR
C3AA  BD C3 39          LC3AA    JSR   >LC339              ; READ A SECTOR INTO FCB DATA BUFFER
C3AD  35 14                      PULS  B,X                 ; * GET BACK THE BYTE OFFSET TO RECORD: X = NUMBER OF
* * SECTORS; ACCB = BYTE POINTER IN SECTOR
C3AF  AF 4D                      STX   FCBSOF,U            ; SAVE SECTOR OFFSET IN FCB
C3B1  34 04             LC3B1    PSHS  B                   ; SAVE BYTE OFFSET ON STACK
C3B3  BD C7 25                   JSR   LC725               ; POINT X TO FILE ALLOCATION TABLE
C3B6  30 06                      LEAX  FATCON,X            ; MOVE X TO FAT DATA
C3B8  E6 43                      LDB   FCBCGR,U            ; GET CURRENT GRANULE NUMBER
C3BA  3A                         ABX                       ; POINT X TO PROPER GRANULE IN FAT
C3BB  A6 84                      LDA   ,X                  ; * GET CURRENT GRANULE AND CHECK TO
C3BD  81 C0                      CMPA  #$C0                ; * SEE IF IT IS LAST GRANULE
C3BF  25 24                      BLO   LC3E5               ; BRANCH IF THIS GRANULE IS < LAST GRANULE
C3C1  84 3F                      ANDA  #$3F                ; MASK OFF LAST GRANULE FLAG BITS
C3C3  A1 44                      CMPA  FCBSEC,U            ; * COMPARE LAST SECTOR USED IN GRANULE TO
C3C5  26 1E                      BNE   LC3E5               ; * CALCULATED SECTOR; BRANCH IF NOT EQUAL
C3C7  EC C8 13                   LDD   FCBLST,U            ; GET NUMBER OF BYTES IN LAST SECTOR
C3CA  84 7F                      ANDA  #$7F                ; MASK OFF PRESAVED FLAG (BIT 15)
C3CC  34 06                      PSHS  B,A                 ; SAVE NUMBER OF BYTES IN LAST SECTOR ON STACK
C3CE  4F                         CLRA                      ; * LOAD ACCB WITH THE BYTE OFFSET TO CURRENT
C3CF  E6 62                      LDB   $02,S               ; * RECORD AND ADD THE REMAINING RECORD LENGTH
C3D1  E3 63                      ADDD  $03,S               ; * TO IT - ACCD = END OF RECORD OFFSET
C3D3  10 A3 E1                   CMPD  ,S++                ; =COMPARE THE END OF RECORD OFFSET TO THE NUMBER OF
C3D6  23 0D                      BLS   LC3E5               ; =BYTES USED IN THE LAST SECTOR
C3D8  0D D8                      TST   VD8                 ; * CHECK GET/PUT FLAG AND BRANCH IF 'GET'
C3DA  10 27 FF 56                LBEQ  LC334               ; * TO 'INPUT PAST END OF FILE' ERROR

* IF LAST USED SECTOR, CALCULATE HOW MANY BYTES ARE USED
* IF DATA IS BEING 'PUT' PASTH THE CURRENT END OF FILE
C3DE  84 01                      ANDA  #$01
C3E0  8A 80                      ORA   #$80                ; * SET PRE-SAVED FLAG BIT - ALL PUT RECORDS ARE
* * WRITTEN TO DISK BEFORE LEAVING 'PUT'
C3E2  ED C8 13                   STD   FCBLST,U            ; SAVE NUMBER OF BYTES USED IN LAST SECTOR
C3E5  35 04             LC3E5    PULS  B                   ; PULL BYTE OFFSET OFF OF THE STACK
C3E7  30 C8 19                   LEAX  FCBCON,U            ; POINT X TO FCB DATA BUFFER
C3EA  3A                         ABX                       ; MOVE X TO START OF RECORD
C3EB  EE 62                      LDU   $02,S               ; POINT U TO CURRENT POSITION IN RANDOM FILE BUFFER
C3ED  34 04                      PSHS  B                   ; SAVE BYTE OFFSET ON STACK
C3EF  86 FF                      LDA   #-1                 ; * CONVERT ACCD INTO A NEGATIVE 2 BYTE NUMBER
* * REPRESENTING THE REMAINING UNUSED BYTES IN THE SECTOR
C3F1  E3 61                      ADDD  $01,S               ; * ADD TEMPORARY RECORD LENGTH COUNTER (SUBTRACT
* * REMAINING BYTES FROM TEMPORARY RECORD LENGTH)
C3F3  24 07                      BHS   LC3FC               ; BRANCH IF THERE ARE ENOUGH UNUSED BYTES TO FINISH THE RECORD
C3F5  ED 61                      STD   $01,S               ; SAVE NEW TEMPORARY RECORD LENGTH COUNTER
C3F7  35 04                      PULS  B                   ; RESTORE BYTE COUNTER
C3F9  50                         NEGB                      ; * NEGATE IT - ACCB = THE NUMBER OF BYTES
* * AVAILABLE TO A RECORD IN THIS SECTOR
C3FA  20 08                      BRA   LC404               ; MOVE THE DATA

* BRANCH HERE IF REMAINING RECORD LENGTH WILL FIT IN
* WHAT'S LEFT OF THE CURRENTLY SELECTED SECTOR
C3FC  E6 62             LC3FC    LDB   $02,S               ; GET REMAINING RECORD LENGTH
C3FE  6F 61                      CLR   $01,S               ; * CLEAR THE TEMPORARY RECORD LENGTH
C400  6F 62                      CLR   $02,S               ; * COUNTER ON THE STACK
C402  32 61                      LEAS  $01,S               ; PURGE BYTE OFFSET FROM STACK
C404  96 D8             LC404    LDA   VD8                 ; * CHECK GET/PUT FLAG AND
C406  27 02                      BEQ   LC40A               ; * BRANCH IF GET
C408  1E 13                      EXG   X,U                 ; SWAP SOURCE AND DESTINATION POINTERS
C40A  BD A5 9A          LC40A    JSR   LA59A               ; TRANSFER DATA FROM SOURCE TO DESTINATION BUFFERS
C40D  EF 62                      STU   $02,S               ; SAVE NEW TEMP RECORD POINTER ON THE STACK (GET)

* MOVE DATA FROM FCB DATA BUFFER TO THE RANDOM FILE BUFFER IF 'GET'
* OR FROM RANDOM FILE BUFFER TO FCB DATA BUFFER IF 'PUT'
C40F  DE F1                      LDU   FCBTMP              ; POINT U TO FCB
C411  96 D8                      LDA   VD8                 ; * CHECK GET/PUT FLAG AND
C413  27 04                      BEQ   LC419               ; * BRANCH IF GET
C415  A7 4F                      STA   FCBFLG,U            ; SAVE 'PUT' FLAG IN THE FCB
C417  AF 62                      STX   $02,S               ; SAVE NEW TEMPORARY RECORD POINTER ON STACK (PUT)
C419  AE 4D             LC419    LDX   FCBSOF,U            ; * GET SECTOR OFFSET COUNTER AND
C41B  30 01                      LEAX  $01,X               ; * ADD ONE TO IT
C41D  5F                         CLRB                      ; SET BYTE OFFSET = 0
C41E  EE E4                      LDU   ,S                  ; * CHECK THE LENGTH OF THE TEMPORARY RECORD LENGTH
C420  10 26 FE C4                LBNE  LC2E8               ; * COUNTER AND KEEP MOVING DATA IF <> 0
C424  35 96                      PULS  A,B,X,PC            ; * PULL TEMPORARY RECORD LENGTH AND
