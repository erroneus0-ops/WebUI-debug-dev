; Disk Extended Color BASIC 1.1 -- $C6EF-$C892
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: KILL=$C6EF, DVEC5=$C848, DVEC6=$C84B, DVEC1=$C888

* KILL COMMAND
C6EF  BD C9 35          KILL     JSR   LC935               ; GET FILENAME.EXT FROM BASIC
C6F2  BD A5 C7                   JSR   LA5C7               ; 'SYNTAX' ERROR IF MORE CHARACTERS ON LINE
C6F5  BD C7 9D                   JSR   LC79D               ; GET VALID FAT DATA
C6F8  8D 92                      BSR   LC68C               ; TEST FOR FILE NAME MATCH IN DIRECTORY
C6FA  8D E9                      BSR   LC6E5               ; MAKE SURE THE FILE EXISTED
C6FC  86 FF             LC6FC    LDA   #$FF                ; * MATCH FILE TYPE = $FF; THIS WILL CAUSE AN 'AO'
* * ERROR TO BE GENERATED IF ANY FILE TYPE IS OPEN
C6FE  BD C8 07                   JSR   LC807               ; CHECK TO MAKE SURE FILE IS NOT OPEN
C701  BE 09 74                   LDX   V974                ; *GET RAM IMAGE OF DIRECTORY
C704  6F 84                      CLR   DIRNAM,X            ; *AND ZERO FIRST BYTE - KILL FILE
C706  C6 03                      LDB   #$03                ; =WRITE OPERATION CODE - SAVE
C708  D7 EA                      STB   DCOPC               ; =IT IN DSKCON VARIABLE
C70A  BD D6 F2                   JSR   LD6F2               ; WRITE A SECTOR
C70D  E6 0D                      LDB   DIRGRN,X            ; GET NUMBER OF FIRST GRANULE IN FILE
C70F  8D 44             LC70F    BSR   LC755               ; POINT X TO PROPER FILE ALLOCATION TABLE
C711  30 06                      LEAX  FATCON,X            ; SKIP 6 CONTROL BYTES
C713  3A                         ABX                       ; POINT TO CORRECT ENTRY
C714  E6 84                      LDB   ,X                  ; GET NEXT GRANULE
C716  86 FF                      LDA   #$FF                ; *GET FREE GRANULE FLAG AND
C718  A7 84                      STA   ,X                  ; *MARK GRANULE AS FREE
C71A  C1 C0                      CMPB  #$C0                ; WAS THIS THE LAST GRANULE?
C71C  25 F1                      BLO   LC70F               ; * KEEP FREEING GRANULES IF NOT LAST ONE
* * WRITE FILE ALLOCATION SECTOR TO DIRECTORY - DO NOT WRITE
* * THE SIX CONTROL BYTES AT THE START OF THE FAT TO THE DISK
C71E  CE 06 00          LC71E    LDU   #DBUF0              ; =POINT U TO DISK BUFFER 0 AND
C721  DF EE                      STU   DCBPT               ; =SAVE IT AS DSKCON VARIABLE
C723  CC 11 03                   LDD   #$1103              ; * WRITE DIRECTORY TRACK - SAVE
C726  97 EC                      STA   DCTRK               ; * TRACK AND WRITE OPERATION CODE IN
C728  D7 EA                      STB   DCOPC               ; * DSKCON VARIABLES
C72A  C6 02                      LDB   #$02                ; = GET FILE ALLOCATION SECTOR AND
C72C  D7 ED                      STB   DSEC                ; = SAVE IN DSKCON VARIABLE
C72E  8D 25                      BSR   LC755               ; POINT X TO PROPER FILE ALLOCATION TABLE
C730  6F 01                      CLR   FAT1,X              ; RESET FLAG INDICATING VALID FAT DATA HAS BEEN STORED ON DISK
C732  30 06                      LEAX  FATCON,X            ; MOVE (X) TO START OF GRANULE DATA
C734  C6 44                      LDB   #GRANMX             ; 68 BYTES IN FAT
C736  BD A5 9A                   JSR   LA59A               ; MOVE ACCB BYTES FROM FAT RAM IMAGE TO DBUF0

* ZERO OUT ALL OF THE BYTES IN THE FAT SECTOR WHICH DO NOT CONTAIN THE GRANULE DATA
C739  6F C0             LC739    CLR   ,U+                 ; CLEAR A BYTE
C73B  11 83 07 00                CMPU  #DBUF0+SECLEN       ; FINISHED THE WHOLE SECTOR?
C73F  26 F8                      BNE   LC739               ; NO
C741  7E D6 F2                   JMP   LD6F2               ; WRITE A SECTOR

* ENTER WITH ACCB CONTAINING FILE NUMBER (1-15); EXIT WITH X POINTING
* TO CORRECT FILE BUFFER; FLAGS SET ACCORDING TO FILE TYPE.

C744  34 04             LC744    PSHS  B                   ; SAVE FILE NUMBER ON STACK
C746  D6 6F                      LDB   DEVNUM              ; GET DEVICE NUMBER (FILE NUMBER)
C748  8C                         CMPX  #$3404              ; SKIP TWO BYTES
C749  34 04             LC719    PSHS  B                   ; SAVE FILE NUMBER ON STACK
C74B  58                         ASLB                      ; X2: 2 BYTES PER POINTER
C74C  8E 09 26                   LDX   #FCBV1-2            ; POINT X TO START OF FCB POINTERS
C74F  AE 85                      LDX   B,X                 ; POINT X TO PROPER FCB
C751  E6 00                      LDB   FCBTYP,X            ; SET FLAGS ACCORDING TO FILE TYPE
C753  35 84                      PULS  B,PC                ; RESTORE FILE NUMBER

* POINT X TO DRIVE ALLOCATION TABLE

C755  34 06             LC755    PSHS  B,A                 ; SAVE ACCD ON STACK
C757  96 EB                      LDA   DCDRV               ; GET DRIVE NUMBER
C759  C6 4A                      LDB   #FATLEN             ; GET LENGTH OF FILE ALLOCATION TABLE
C75B  3D                         MUL                       ; MULTIPLY BY DRIVE NUMBER TO GET OFFSET
C75C  8E 08 00                   LDX   #FATBL0             ; START OF FILE ALLOCATION TABLE
C75F  30 8B                      LEAX  D,X                 ; POINT TO RIGHT TABLE
C761  35 86                      PULS  A,B,PC              ; RESTORE ACCD

* CONVERT GRANULE NUMBER TO TRACK & SECTOR NUMBER - X MUST BE POINTING TO CORRECT
* FCB; THE TRACK AND SECTOR NUMBER WILL BE STORED IN DSKCON REGISTERS
C763  E6 03             LC763    LDB   FCBCGR,X            ; GET GRANULE NUMBER
C765  54                         LSRB                      ; DIVIDE BY 2 - 2 GRANULES / TRACK
C766  D7 EC                      STB   DCTRK               ; TRACK NUMBER
C768  C1 11                      CMPB  #17                 ; TRACK 17 = DIRECTORY TRACK
C76A  25 02                      BLO   LC76E               ; BRANCH IF < DIRECTORY TRACK
C76C  0C EC                      INC   DCTRK               ; INCR TRACK NUMBER IF > DIRECTORY TRACK
C76E  58                LC76E    ASLB                      ; MULTIPLY TRACK NUMBER BY 2
C76F  50                         NEGB                      ; NEGATE GRANULE NUMBER
C770  EB 03                      ADDB  FCBCGR,X            ; B=0 IF EVEN GRANULE; 1 IF ODD
C772  8D 05                      BSR   LC779               ; RETURN B=0 FOR EVEN GRANULE NUMBER, B=9 FOR ODD GRANULE NUMBER
C774  EB 04                      ADDB  FCBSEC,X            ; ADD SECTOR NUMBER
C776  D7 ED                      STB   DSEC                ; SAVE SECTOR NUMBER
C778  39                         RTS
* MULTIPLY ACCD BY 9
C779  34 06             LC778    PSHS  B,A                 ; TEMP STORE ACCD ON STACK
C77B  58                         ASLB                      ; *
C77C  49                         ROLA                      ; * MULTIPLY BY 2
C77D  58                         ASLB                      ; =
C77E  49                         ROLA                      ; = MULTIPLY BY FOUR
C77F  58                         ASLB                      ; *
C780  49                         ROLA                      ; * MULTIPLY BY EIGHT
C781  E3 E1                      ADDD  ,S++                ; ADD ONE = MULTIPLY BY NINE
C783  39                         RTS

* CONVERT ACCD INTO A GRANULE NUMBER - RETURN RESULT IN ACCB;
* ENTER WITH ACCD CONTAINING A NUMBER OF SECTORS. RETURN IN ACCB
* THE NUMBER (0-67) CORRESPONDING TO THE NUMBER OF COMPLETE
* GRANULES CONTAINED IN THAT MANY SECTORS.
* DIVIDE BY 90, MULTIPLY BY 10 IS FASTER THAN DIVIDE BY 9
C784  6F E2             LC784    CLR   ,-S                 ; CLEAR A TEMPORARY SLOT ON THE STACK
C786  6C E4             LC756    INC   ,S                  ; * DIVIDE ACCD BY 90 - SAVE THE
C788  83 00 5A                   SUBD  #9*10               ; * QUOTIENT+1 ON THE STACK - REMAINDER
C78B  2A F9                      BPL   LC786               ; * IN ACCB
C78D  A6 E4                      LDA   ,S                  ; = PUT THE QUOTIENT+1 IN ACCA AND
C78F  E7 E4                      STB   ,S                  ; = SAVE REMAINDER ON STACK
C791  C6 0A                      LDB   #10                 ; * MULTIPLY (QUOTIENT+1)
C793  3D                         MUL                       ; * BY 10
C794  35 02                      PULS  A                   ; PUT THE REMAINDER IN ACCA
C796  5A                LC796    DECB                      ; * DECREMENT THE GRANULE COUNT BY ONE FOR
C797  8B 09                      ADDA  #$09                ; * EVERY NINE SECTORS (1 GRANULE) IN THE
C799  2B FB                      BMI   LC796               ; * REMAINDER - COMPENSATE FOR THE + 1 IN QUOTIENT+1
C79B  4F                         CLRA                      ; CLEAR MS BYTE OF ACCD
C79C  39                LC79C    RTS

* MAKE SURE RAM FILE ALLOCATION TABLE DATA IS VALID
C79D  8D B6             LC79D    BSR   LC755               ; POINT X TO FAT FOR THE CORRECT DRIVE NUMBER
C79F  6D 00                      TST   FAT0,X              ; CHECK TO SEE IF ANY FILES ARE ACTIVE
C7A1  26 F9                      BNE   LC79C               ; RETURN IF ANY FILES ACTIVE IN THIS FAT
C7A3  6F 01                      CLR   FAT1,X              ; RESET FAT DATA VALID FLAG
C7A5  33 06                      LEAU  FATCON,X            ; LOAD U WITH START OF GRANULE DATA BUFFER
C7A7  8E 06 00                   LDX   #DBUF0              ; BUFFER FOR DISK TRANSFER
C7AA  9F EE                      STX   DCBPT               ; PUT IN DSKCON PARAMETER
C7AC  CC 11 02                   LDD   #$1102              ; DIRECTORY TRACK, READ SECTOR
C7AF  97 EC                      STA   DCTRK               ; STORE IN DSKCON TRACK NUMBER
C7B1  D7 EA                      STB   DCOPC               ; STORE IN DSKCON OP CODE
C7B3  C6 02                      LDB   #$02                ; GET SECTOR NUMBER 2 (FILE ALLOCATION TABLE)
C7B5  D7 ED                      STB   DSEC                ; STORE IN DSKCON PARAMETER
C7B7  BD D6 F2                   JSR   LD6F2               ; GO READ SECTOR
C7BA  C6 44                      LDB   #GRANMX             ; TRANSFER FILE ALLOCATION TABLE TO FILE ALLOC TABLE BUFFER
C7BC  7E A5 9A                   JMP   LA59A               ; MOVE B BYTES FROM (X) TO (U)

* FIND FIRST FREE GRANULE - ENTER WITH ACCB CONTAINING
* GRANULE FROM WHICH TO START SEARCHING. THE FOUND GRANULE
* IS MARKED BY STORING A $C0 IN THE GRANULE'S DATA BYTE
* TO INDICATE THAT IT IS THE LAST GRANULE IN THE FILE.
* RETURN WITH FIRST FREE GRANULE FOUND IN ACCA
C7BF  8D 94             LC7BF    BSR   LC755               ; POINT X TO FILE ALLOC TABLE
C7C1  30 06                      LEAX  FATCON,X            ; SKIP CONTROL BYTES
C7C3  4F                         CLRA                      ; USE ACCA AS GRANULE COUNTER
C7C4  C4 FE                      ANDB  #$FE                ; MASK OFF BIT ZERO OF SEARCH GRANULE
C7C6  6F E2                      CLR   ,-S                 ; INITIALIZE AND SAVE A BYTE ON STACK (DIRECTION FLAG)
C7C8  63 85             LC7C8    COM   B,X                 ; IS THIS GRANULE FREE? ($FF=FREE)
C7CA  27 31                      BEQ   LC7FD               ; BRANCH IF IT IS
C7CC  63 85                      COM   B,X                 ; RESTORE GRANULE DATA
C7CE  4C                         INCA                      ; ADD ONE TO GRANULE COUNTER
C7CF  81 44                      CMPA  #GRANMX             ; GRANMX GEANULES PER DISK
C7D1  24 25                      BHS   LC7F8               ; BRANCH IF ALL GRANULES CHECKED (DISK FULL)
C7D3  5C                         INCB                      ; INCR TO NEXT GRANULE
C7D4  C5 01                      BITB  #$01                ; IS BIT 0 SET?
C7D6  26 F0                      BNE   LC7C8               ; BRANCH IF ODD GRANULE NUMBER (SAME TRACK)
C7D8  34 06                      PSHS  B,A                 ; SAVE GRANULE COUNTER AND CURRENT GRANULE NUMBER
C7DA  C0 02                      SUBB  #$02                ; SUBTRACT ONE TRACK (2 GRANULES)
C7DC  63 62                      COM   $02,S               ; COMPLEMENT DIRECTION FLAG
C7DE  26 0C                      BNE   LC7EC               ; BRANCH EVERY OTHER TIME
C7E0  E0 E0                      SUBB  ,S+                 ; SUBTRACT THE GRANULE COUNTER FROM THE CURRENT GRANULE NUMBER
C7E2  2A 04                      BPL   LC7E8               ; BRANCH IF LOWER BOUND NOT EXCEEDED
C7E4  E6 E4                      LDB   ,S                  ; RESTORE CURRENT GRANULE NUMBER IF LOWER BOUND EXCEEDED
C7E6  63 61             LC7E6    COM   $01,S               ; * COMPLEMENT FLAG - IF GRANULE NUMBER HAS EXCEEDED
* * BOUNDS ON EITHER THE HI OR LO SIDE, FORCE IT TO GO IN
* * THE DIRECTION OPPOSITE THE EXCEEDED BOUND
C7E8  32 61             LC7E8    LEAS  $01,S               ; CLEAN UP STACK
C7EA  20 DC                      BRA   LC7C8               ; CHECK FOR ANOTHER FREE GRANULE

C7EC  EB E0             LC7EC    ADDB  ,S+                 ; ADD THE GRANULE COUNTER TO THE CURRENT GRANULE NUMBER
C7EE  C1 44                      CMPB  #GRANMX             ; GRANMX GRANULES PER DISK
C7F0  25 F6                      BLO   LC7E8               ; BRANCH IF UPPER BOUND NOT EXCEEDED
C7F2  E6 E4                      LDB   ,S                  ; * RESTORE CURRENT GRANULE COUNT AND GO TWICE
C7F4  C0 04                      SUBB  #$04                ; * AS FAR AS USUAL IN OPPOSITE DIRECTION IF UPPER BOUND EXCEEDED
C7F6  20 EE                      BRA   LC7E6               ; KEEP SEARCHING
C7F8  C6 38             LC7F8    LDB   #2*28               ; 'DISK FULL' ERROR
C7FA  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER

* POINT X TO FIRST FREE GRANULE POSITION IN THE FILE ALLOCATION
* TABLE AND MARK THE POSITION WITH A LAST GRANULE IN FILE MARKER
C7FD  32 61             LC7FD    LEAS  $01,S               ; CLEAR UP STACK - REMOVE DIRECTION FLAG
C7FF  1F 98                      TFR   B,A                 ; GRANULE NUMBER TO ACCA
C801  3A                         ABX                       ; POINT X TO FIRST FOUND GRANULE
C802  C6 C0                      LDB   #$C0                ; LAST GRANULE FLAG
C804  E7 84                      STB   ,X                  ; MARK THE FIRST FOUND GRANULE AS THE LAST GRANULE
C806  39                LC806    RTS

* CHECK ALL ACTIVE FILES TO MAKE SURE A FILE IS NOT ALREADY OPEN - TO BE OPEN
* A FILE BUFFER MUST MATCH THE DRIVE NUMBER AND FIRST GRANULE NUMBER
* IN RAM DIRECTORY ENTRY AND THE FCB TYPE MUST NOT MATCH THE FILE TYPE IN ACCA
* AN 'AO' ERROR WILL NOT BE GENERATED IF A FILE IS BEING OPENED FOR
* THE SAME MODE THAT IT HAS ALREADY BEEN OPENED UNDER.

C807  34 02             LC807    PSHS  A                   ; SAVE FILE TYPE ON STACK
C809  F6 09 5B                   LDB   FCBACT              ; NUMBER OF CURRENTLY OPEN FILES
C80C  5C                         INCB                      ; ADD ONE MORE TO FILE COUNTER
C80D  BD C7 49          LC80D    JSR   LC749               ; POINT X TO FCB OF THIS FILE
C810  27 17                      BEQ   LC829               ; BRANCH IF BUFFER NOT BEING USED
C812  96 EB                      LDA   DCDRV               ; * GET DRIVE NUMBER AND CHECK TO SEE IF IT
C814  A1 01                      CMPA  FCBDRV,X            ; * MATCHES THE DRIVE NUMBER FOR THIS BUFFER
C816  26 11                      BNE   LC829               ; FILE EXISTS ON ANOTHER DRIVE
C818  FE 09 74                   LDU   V974                ; GET RAM DIRECTORY AREA
C81B  A6 4D                      LDA   DIRGRAN,U           ; GET FIRST GRANULE IN FILE
C81D  A1 02                      CMPA  FCBFGR,X            ; DOES IT MATCH THIS FILE BUFFER?
C81F  26 08                      BNE   LC829               ; NO
C821  A6 00                      LDA   FCBTYP,X            ; GET FILE TYPE OF THIS BUFFER
C823  A1 E4                      CMPA  ,S                  ; DOES IT MATCH THE ONE WE ARE LOOKING FOR?
C825  10 26 DD F3                LBNE  LA61C               ; 'FILE ALREADY OPEN' ERROR IF NOT
C829  5A                LC829    DECB                      ; DECR FILE COUNTER
C82A  26 E1                      BNE   LC80D               ; BRANCH IF HAVEN'T CHECKED ALL ACTIVE FILES
C82C  35 82                      PULS  A,PC                ; RESTORE FILE TYPE AND RETURN

C82E  BD A5 A5          LC82E    JSR   LA5A5               ; EVALUATE AN EXPRESSION (DEVICE NUMBER)
C831  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
C833  5D                         TSTB                      ; TEST NEW DEVICE NUMBER
C834  10 2F EC 12                LBLE  LB44A               ; 'FC' ERROR IF DEVICE NUMBER NOT A DISK FILE
C838  BD C7 49                   JSR   LC749               ; POINT X TO FCB
C83B  A6 00                      LDA   FCBTYP,X            ; TEST IF BUFFER IS IN USE
C83D  10 27 DB BA                LBEQ  LA3FB               ; 'FILE NOT OPEN' ERROR
C841  81 40                      CMPA  #RANFIL             ; DIRECT/RANDOM FILE?
C843  27 C1                      BEQ   LC806               ; RETURN IF RANDOM
C845  7E A6 16          LC856    JMP   LA616               ; BAD FILE MODE ERROR IF NOT RANDOM

* INPUT DEVICE NUMBER CHECK RAM HOOK
C848  86 10             DVEC5    LDA   #INPFIL             ; INPUT FILE TYPE
C84A  8C                LC84A    CMPX  #8620               ; SKIP TWO BYTES

* PRINT DEVICE NUMBER CHECK RAM HOOK
C84B  86 20             DVEC6    LDA   #OUTFIL             ; OUTPUT FILE TYPE
C84D  0D 6F                      TST   DEVNUM              ; * CHECK DEVICE NUMBER AND RETURN IF
C84F  2F B5                      BLE   LC806               ; * NOT A DISK FILE
C851  AF E4                      STX   ,S                  ; = REPLACE SUBROUTINE RETURN ADDRESS WITH X REGISTER -
* = THIS IS THE SAME AS LEAS 2,S AND PSHS X
C853  BD C7 44                   JSR   LC744               ; POINT X TO FCB
C856  34 06                      PSHS  B,A                 ; SAVE ACCB AND FILE TYPE ON STACK
C858  A6 00                      LDA   FCBTYP,X            ; GET FILE TYPE
C85A  10 27 DB 9D                LBEQ  LA3FB               ; 'FILE NOT OPEN' ERROR
C85E  81 40                      CMPA  #RANFIL             ; RANDOM FILE?
C860  27 06                      BEQ   LC868               ; BRANCH IF RANDOM FILE
C862  A1 E4                      CMPA  ,S                  ; IS THIS FCB OF THE PROPER TYPE?
C864  26 DF                      BNE   LC845               ; 'FILE MODE' ERROR IF NOT
C866  35 96             LC866    PULS  A,B,X,PC            ; RESTORE ACCB,X,ACCA (FILE TYPE) AND RETURN

C868  AE 64             LC868    LDX   $04,S               ; * GET CALLING ADDRESS FROM THE STACK AND
C86A  8C B0 0C                   CMPX  #LB00C              ; * RETURN UNLESS COMING FROM
C86D  26 F7                      BNE   LC866               ; * BASIC'S 'INPUT' STATEMENT
C86F  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR A COMMA
C872  81 22                      CMPA  #'"'                ; CHECK FOR A DOUBLE QUOTE
C874  26 0B                      BNE   LC881               ; RETURN TO BASIC'S 'INPUT' COMMAND
C876  BD B2 44                   JSR   LB244               ; STRIP PROMPT STRING FROM BASIC AND PUT IT ON THE STRING STACK
C879  BD B6 57                   JSR   LB657               ; PURGE THE STRING PUT ON THE STRING STACK
C87C  C6 3B                      LDB   #';'                ; SEMICOLON
C87E  BD B2 6F                   JSR   LB26F               ; DO A SYNTAX CHECK FOR SEMICOLON
C881  8E B0 1E          LC881    LDX   #LB01E              ; GET MODIFIED REENTRY POINT INTO BASIC
C884  AF 64                      STX   $04,S               ; AND PUT IT INTO THE RETURN ADDRESS ON THE STACK
C886  35 96                      PULS  A,B,X,PC            ; RETURN TO BASIC

* DEVICE NUMBER VALIDITY CHECK RAM HOOK
C888  2F 25             DVEC1    BLE   LC8AF               ; RETURN IF NOT A DISK FILE
C88A  F1 09 5B                   CMPB  FCBACT              ; COMPARE DEVICE NUMBER TO HIGHEST POSSIBLE
C88D  10 22 DD 8E                LBHI  LA61F               ; 'DEVICE NUMBER' ERROR IF TOO BIG
C891  35 90                      PULS  X,PC                ; RETURN
