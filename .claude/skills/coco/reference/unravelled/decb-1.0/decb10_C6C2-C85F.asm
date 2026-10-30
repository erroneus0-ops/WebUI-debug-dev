; Disk Extended Color BASIC 1.0 -- $C6C2-$C85F
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: KILL=$C6C2, DVEC5=$C818, DVEC6=$C81B, DVEC1=$C838, DVEC2=$C843, DVEC11=$C859

* KILL COMMAND
C6C2  BD C8 87          KILL     JSR   LC887               ; GET FILENAME.EXT FROM BASIC
C6C5  BD A5 C7                   JSR   LA5C7               ; 'SYNTAX' ERROR IF MORE CHARACTERS ON LINE
C6C8  BD C7 6D                   JSR   LC76D               ; GET VALID FAT DATA
C6CB  8D 92                      BSR   LC65F               ; TEST FOR FILE NAME MATCH IN DIRECTORY
C6CD  8D E9                      BSR   LC6B8               ; MAKE SURE THE FILE EXISTED
C6CF  86 FF             LC6CF    LDA   #$FF                ; * MATCH FILE TYPE = $FF; THIS WILL CAUSE AN 'AO'
* * ERROR TO BE GENERATED IF ANY FILE TYPE IS OPEN
C6D1  BD C7 D7                   JSR   LC7D7               ; CHECK TO MAKE SURE FILE IS NOT OPEN
C6D4  BE 09 74                   LDX   V974                ; *GET RAM IMAGE OF DIRECTORY
C6D7  6F 84                      CLR   DIRNAM,X            ; *AND ZERO FIRST BYTE - KILL FILE
C6D9  C6 03                      LDB   #$03                ; =WRITE OPERATION CODE - SAVE
C6DB  D7 EA                      STB   DCOPC               ; =IT IN DSKCON VARIABLE
C6DD  BD D5 FF                   JSR   LD5FF               ; WRITE A SECTOR
C6E0  E6 0D                      LDB   DIRGRN,X            ; GET NUMBER OF FIRST GRANULE IN FILE
C6E2  8D 41             LC6E2    BSR   LC725               ; POINT X TO PROPER FILE ALLOCATION TABLE
C6E4  30 06                      LEAX  FATCON,X            ; SKIP 6 CONTROL BYTES
C6E6  3A                         ABX                       ; POINT TO CORRECT ENTRY
C6E7  E6 84                      LDB   ,X                  ; GET NEXT GRANULE
C6E9  86 FF                      LDA   #$FF                ; *GET FREE GRANULE FLAG AND
C6EB  A7 84                      STA   ,X                  ; *MARK GRANULE AS FREE
C6ED  C1 C0                      CMPB  #$C0                ; WAS THIS THE LAST GRANULE?
C6EF  25 F1                      BLO   LC6E2               ; * KEEP FREEING GRANULES IF NOT LAST ONE
* * WRITE FILE ALLOCATION SECTOR TO DIRECTORY - DO NOT WRITE
* * THE SIX CONTROL BYTES AT THE START OF THE FAT TO THE DISK
C6F1  CE 06 00          LC6F1    LDU   #DBUF0              ; =POINT U TO DISK BUFFER 0 AND
C6F4  DF EE                      STU   DCBPT               ; =SAVE IT AS DSKCON VARIABLE
C6F6  CC 11 03                   LDD   #$1103              ; * WRITE DIRECTORY TRACK - SAVE
C6F9  97 EC                      STA   DCTRK               ; * TRACK AND WRITE OPERATION CODE IN
C6FB  D7 EA                      STB   DCOPC               ; * DSKCON VARIABLES
C6FD  C6 02                      LDB   #$02                ; = GET FILE ALLOCATION SECTOR AND
C6FF  D7 ED                      STB   DSEC                ; = SAVE IN DSKCON VARIABLE
C701  8D 22                      BSR   LC725               ; POINT X TO PROPER FILE ALLOCATION TABLE
C703  6F 01                      CLR   FAT1,X              ; RESET FLAG INDICATING VALID FAT DATA HAS BEEN STORED ON DISK
C705  30 06                      LEAX  FATCON,X            ; MOVE (X) TO START OF GRANULE DATA
C707  C6 44                      LDB   #GRANMX             ; 68 BYTES IN FAT
C709  BD A5 9A                   JSR   LA59A               ; MOVE ACCB BYTES FROM FAT RAM IMAGE TO DBUF0

* ZERO OUT ALL OF THE BYTES IN THE FAT SECTOR WHICH DO NOT CONTAIN THE GRANULE DATA
* ZERO OUT THE REMAINDER OF THE SECTOR BUFFER
C70C  6F 80             LC70C    CLR   ,X+                 ; THIS IS A BUG; SHOULD BE CLR ,U+
C70E  8C 07 00                   CMPX  #DBUF0+SECLEN       ; MORE OF THE SAME BUG; SHOULD BE CMPU
* BNE LC70C  THIS INSTRUCTION HAS BEEN LEFT OUT
C711  7E D5 FF                   JMP   LD5FF               ; WRITE A SECTOR

* ENTER WITH ACCB CONTAINING FILE NUMBER (1-15); EXIT WITH X POINTING
* TO CORRECT FILE BUFFER; FLAGS SET ACCORDING TO FILE TYPE.

C714  34 04             LC714    PSHS  B                   ; SAVE FILE NUMBER ON STACK
C716  D6 6F                      LDB   DEVNUM              ; GET DEVICE NUMBER (FILE NUMBER)
C718  8C 34 04          LC718    CMPX  #$3404              ; SKIP TWO BYTES
C719  34 04             LC719    PSHS  B                   ; SAVE FILE NUMBER ON STACK
C71B  58                         ASLB                      ; X2: 2 BYTES PER POINTER
C71C  8E 09 26                   LDX   #FCBV1-2            ; POINT X TO START OF FCB POINTERS
C71F  AE 85                      LDX   B,X                 ; POINT X TO PROPER FCB
C721  E6 00                      LDB   FCBTYP,X            ; SET FLAGS ACCORDING TO FILE TYPE
C723  35 84                      PULS  B,PC                ; RESTORE FILE NUMBER

* POINT X TO DRIVE ALLOCATION TABLE

C725  34 06             LC725    PSHS  B,A                 ; SAVE ACCD ON STACK
C727  96 EB                      LDA   DCDRV               ; GET DRIVE NUMBER
C729  C6 4A                      LDB   #FATLEN             ; GET LENGTH OF FILE ALLOCATION TABLE
C72B  3D                         MUL                       ; MULTIPLY BY DRIVE NUMBER TO GET OFFSET
C72C  8E 08 00                   LDX   #FATBL0             ; START OF FILE ALLOCATION TABLE
C72F  30 8B                      LEAX  D,X                 ; POINT TO RIGHT TABLE
C731  35 86                      PULS  A,B,PC              ; RESTORE ACCD

* CONVERT GRANULE NUMBER TO TRACK & SECTOR NUMBER - X MUST BE POINTING TO CORRECT
* FCB; THE TRACK AND SECTOR NUMBER WILL BE STORED IN DSKCON REGISTERS
C733  E6 03             LC733    LDB   FCBCGR,X            ; GET GRANULE NUMBER
C735  54                         LSRB                      ; DIVIDE BY 2 - 2 GRANULES / TRACK
C736  D7 EC                      STB   DCTRK               ; TRACK NUMBER
C738  C1 11                      CMPB  #17                 ; TRACK 17 = DIRECTORY TRACK
C73A  25 02                      BLO   LC73E               ; BRANCH IF < DIRECTORY TRACK
C73C  0C EC                      INC   DCTRK               ; INCR TRACK NUMBER IF > DIRECTORY TRACK
C73E  58                LC73E    ASLB                      ; MULTIPLY TRACK NUMBER BY 2
C73F  50                         NEGB                      ; NEGATE GRANULE NUMBER
C740  EB 03                      ADDB  FCBCGR,X            ; B=0 IF EVEN GRANULE; 1 IF ODD
C742  8D 05                      BSR   LC749               ; RETURN B=0 FOR EVEN GRANULE NUMBER, B=9 FOR ODD GRANULE NUMBER
C744  EB 04                      ADDB  FCBSEC,X            ; ADD SECTOR NUMBER
C746  D7 ED                      STB   DSEC                ; SAVE SECTOR NUMBER
C748  39                         RTS
* MULTIPLY ACCD BY 9
C749  34 06             LC749    PSHS  B,A                 ; TEMP STORE ACCD ON STACK
C74B  58                         ASLB                      ; *
C74C  49                         ROLA                      ; * MULTIPLY BY 2
C74D  58                         ASLB                      ; =
C74E  49                         ROLA                      ; = MULTIPLY BY FOUR
C74F  58                         ASLB                      ; *
C750  49                         ROLA                      ; * MULTIPLY BY EIGHT
C751  E3 E1                      ADDD  ,S++                ; ADD ONE = MULTIPLY BY NINE
C753  39                         RTS

* CONVERT ACCD INTO A GRANULE NUMBER - RETURN RESULT IN ACCB;
* ENTER WITH ACCD CONTAINING A NUMBER OF SECTORS. RETURN IN ACCB
* THE NUMBER (0-67) CORRESPONDING TO THE NUMBER OF COMPLETE
* GRANULES CONTAINED IN THAT MANY SECTORS.
* DIVIDE BY 90, MULTIPLY BY 10 IS FASTER THAN DIVIDE BY 9
C754  6F E2             LC754    CLR   ,-S                 ; CLEAR A TEMPORARY SLOT ON THE STACK
C756  6C E4             LC756    INC   ,S                  ; * DIVIDE ACCD BY 90 - SAVE THE
C758  83 00 5A                   SUBD  #9*10               ; * QUOTIENT+1 ON THE STACK - REMAINDER
C75B  2A F9                      BPL   LC756               ; * IN ACCB
C75D  A6 E4                      LDA   ,S                  ; = PUT THE QUOTIENT+1 IN ACCA AND
C75F  E7 E4                      STB   ,S                  ; = SAVE REMAINDER ON STACK
C761  C6 0A                      LDB   #10                 ; * MULTIPLY (QUOTIENT+1)
C763  3D                         MUL                       ; * BY 10
C764  35 02                      PULS  A                   ; PUT THE REMAINDER IN ACCA
C766  5A                LC766    DECB                      ; * DECREMENT THE GRANULE COUNT BY ONE FOR
C767  8B 09                      ADDA  #$09                ; * EVERY NINE SECTORS (1 GRANULE) IN THE
C769  2B FB                      BMI   LC766               ; * REMAINDER - COMPENSATE FOR THE + 1 IN QUOTIENT+1
C76B  4F                         CLRA                      ; CLEAR MS BYTE OF ACCD
C76C  39                LC76C    RTS

* MAKE SURE RAM FILE ALLOCATION TABLE DATA IS VALID
C76D  8D B6             LC76D    BSR   LC725               ; POINT X TO FAT FOR THE CORRECT DRIVE NUMBER
C76F  6D 00                      TST   FAT0,X              ; CHECK TO SEE IF ANY FILES ARE ACTIVE
C771  26 F9                      BNE   LC76C               ; RETURN IF ANY FILES ACTIVE IN THIS FAT
C773  6F 01                      CLR   FAT1,X              ; RESET FAT DATA VALID FLAG
C775  33 06                      LEAU  FATCON,X            ; LOAD U WITH START OF GRANULE DATA BUFFER
C777  8E 06 00                   LDX   #DBUF0              ; BUFFER FOR DISK TRANSFER
C77A  9F EE                      STX   DCBPT               ; PUT IN DSKCON PARAMETER
C77C  CC 11 02                   LDD   #$1102              ; DIRECTORY TRACK, READ SECTOR
C77F  97 EC                      STA   DCTRK               ; STORE IN DSKCON TRACK NUMBER
C781  D7 EA                      STB   DCOPC               ; STORE IN DSKCON OP CODE
C783  C6 02                      LDB   #$02                ; GET SECTOR NUMBER 2 (FILE ALLOCATION TABLE)
C785  D7 ED                      STB   DSEC                ; STORE IN DSKCON PARAMETER
C787  BD D5 FF                   JSR   LD5FF               ; GO READ SECTOR
C78A  C6 44                      LDB   #GRANMX             ; TRANSFER FILE ALLOCATION TABLE TO FILE ALLOC TABLE BUFFER
C78C  7E A5 9A                   JMP   LA59A               ; MOVE B BYTES FROM (X) TO (U)

* FIND FIRST FREE GRANULE - ENTER WITH ACCB CONTAINING
* GRANULE FROM WHICH TO START SEARCHING. THE FOUND GRANULE
* IS MARKED BY STORING A $C0 IN THE GRANULE'S DATA BYTE
* TO INDICATE THAT IT IS THE LAST GRANULE IN THE FILE.
* RETURN WITH FIRST FREE GRANULE FOUND IN ACCA
C78F  8D 94             LC78F    BSR   LC725               ; POINT X TO FILE ALLOC TABLE
C791  30 06                      LEAX  FATCON,X            ; SKIP CONTROL BYTES
C793  4F                         CLRA                      ; USE ACCA AS GRANULE COUNTER
C794  C4 FE                      ANDB  #$FE                ; MASK OFF BIT ZERO OF SEARCH GRANULE
C796  6F E2                      CLR   ,-S                 ; INITIALIZE AND SAVE A BYTE ON STACK (DIRECTION FLAG)
C798  63 85             LC798    COM   B,X                 ; IS THIS GRANULE FREE? ($FF=FREE)
C79A  27 31                      BEQ   LC7CD               ; BRANCH IF IT IS
C79C  63 85                      COM   B,X                 ; RESTORE GRANULE DATA
C79E  4C                         INCA                      ; ADD ONE TO GRANULE COUNTER
C79F  81 44                      CMPA  #GRANMX             ; GRANMX GEANULES PER DISK
C7A1  24 25                      BHS   LC7C8               ; BRANCH IF ALL GRANULES CHECKED (DISK FULL)
C7A3  5C                         INCB                      ; INCR TO NEXT GRANULE
C7A4  C5 01                      BITB  #$01                ; IS BIT 0 SET?
C7A6  26 F0                      BNE   LC798               ; BRANCH IF ODD GRANULE NUMBER (SAME TRACK)
C7A8  34 06                      PSHS  B,A                 ; SAVE GRANULE COUNTER AND CURRENT GRANULE NUMBER
C7AA  C0 02                      SUBB  #$02                ; SUBTRACT ONE TRACK (2 GRANULES)
C7AC  63 62                      COM   $02,S               ; COMPLEMENT DIRECTION FLAG
C7AE  26 0C                      BNE   LC7BC               ; BRANCH EVERY OTHER TIME
C7B0  E0 E0                      SUBB  ,S+                 ; SUBTRACT THE GRANULE COUNTER FROM THE CURRENT GRANULE NUMBER
C7B2  2A 04                      BPL   LC7B8               ; BRANCH IF LOWER BOUND NOT EXCEEDED
C7B4  E6 E4                      LDB   ,S                  ; RESTORE CURRENT GRANULE NUMBER IF LOWER BOUND EXCEEDED
C7B6  63 61             LC7B6    COM   $01,S               ; * COMPLEMENT FLAG - IF GRANULE NUMBER HAS EXCEEDED
* * BOUNDS ON EITHER THE HI OR LO SIDE, FORCE IT TO GO IN
* * THE DIRECTION OPPOSITE THE EXCEEDED BOUND
C7B8  32 61             LC7B8    LEAS  $01,S               ; CLEAN UP STACK
C7BA  20 DC                      BRA   LC798               ; CHECK FOR ANOTHER FREE GRANULE

C7BC  EB E0             LC7BC    ADDB  ,S+                 ; ADD THE GRANULE COUNTER TO THE CURRENT GRANULE NUMBER
C7BE  C1 44                      CMPB  #GRANMX             ; GRANMX GRANULES PER DISK
C7C0  25 F6                      BLO   LC7B8               ; BRANCH IF UPPER BOUND NOT EXCEEDED
C7C2  E6 E4                      LDB   ,S                  ; * RESTORE CURRENT GRANULE COUNT AND GO TWICE
C7C4  C0 04                      SUBB  #$04                ; * AS FAR AS USUAL IN OPPOSITE DIRECTION IF UPPER BOUND EXCEEDED
C7C6  20 EE                      BRA   LC7B6               ; KEEP SEARCHING
C7C8  C6 38             LC7C8    LDB   #2*28               ; 'DISK FULL' ERROR
C7CA  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER

* POINT X TO FIRST FREE GRANULE POSITION IN THE FILE ALLOCATION
* TABLE AND MARK THE POSITION WITH A LAST GRANULE IN FILE MARKER
C7CD  32 61             LC7CD    LEAS  $01,S               ; CLEAR UP STACK - REMOVE DIRECTION FLAG
C7CF  1F 98                      TFR   B,A                 ; GRANULE NUMBER TO ACCA
C7D1  3A                         ABX                       ; POINT X TO FIRST FOUND GRANULE
C7D2  C6 C0                      LDB   #$C0                ; LAST GRANULE FLAG
C7D4  E7 84                      STB   ,X                  ; MARK THE FIRST FOUND GRANULE AS THE LAST GRANULE
C7D6  39                LC7D6    RTS

* CHECK ALL ACTIVE FILES TO MAKE SURE A FILE IS NOT ALREADY OPEN - TO BE OPEN
* A FILE BUFFER MUST MATCH THE DRIVE NUMBER AND FIRST GRANULE NUMBER
* IN RAM DIRECTORY ENTRY AND THE FCB TYPE MUST NOT MATCH THE FILE TYPE IN ACCA
* AN 'AO' ERROR WILL NOT BE GENERATED IF A FILE IS BEING OPENED FOR
* THE SAME MODE THAT IT HAS ALREADY BEEN OPENED UNDER.

C7D7  34 02             LC7D7    PSHS  A                   ; SAVE FILE TYPE ON STACK
C7D9  F6 09 5B                   LDB   FCBACT              ; NUMBER OF CURRENTLY OPEN FILES
C7DC  5C                         INCB                      ; ADD ONE MORE TO FILE COUNTER
C7DD  BD C7 19          LC7DD    JSR   LC719               ; POINT X TO FCB OF THIS FILE
C7E0  27 17                      BEQ   LC7F9               ; BRANCH IF BUFFER NOT BEING USED
C7E2  96 EB                      LDA   DCDRV               ; * GET DRIVE NUMBER AND CHECK TO SEE IF IT
C7E4  A1 01                      CMPA  FCBDRV,X            ; * MATCHES THE DRIVE NUMBER FOR THIS BUFFER
C7E6  26 11                      BNE   LC7F9               ; FILE EXISTS ON ANOTHER DRIVE
C7E8  FE 09 74                   LDU   V974                ; GET RAM DIRECTORY AREA
C7EB  A6 4D                      LDA   DIRGRN,U            ; GET FIRST GRANULE IN FILE
C7ED  A1 02                      CMPA  FCBFGR,X            ; DOES IT MATCH THIS FILE BUFFER?
C7EF  26 08                      BNE   LC7F9               ; NO
C7F1  A6 00                      LDA   FCBTYP,X            ; GET FILE TYPE OF THIS BUFFER
C7F3  A1 E4                      CMPA  ,S                  ; DOES IT MATCH THE ONE WE ARE LOOKING FOR?
C7F5  10 26 DE 23                LBNE  LA61C               ; 'FILE ALREADY OPEN' ERROR IF NOT
C7F9  5A                LC7F9    DECB                      ; DECR FILE COUNTER
C7FA  26 E1                      BNE   LC7DD               ; BRANCH IF HAVEN'T CHECKED ALL ACTIVE FILES
C7FC  35 82                      PULS  A,PC                ; RESTORE FILE TYPE AND RETURN

C7FE  BD A5 A5          LC7FE    JSR   LA5A5               ; EVALUATE AN EXPRESSION (DEVICE NUMBER)
C801  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
C803  5D                         TSTB                      ; TEST NEW DEVICE NUMBER
C804  10 2F EC 42                LBLE  LB44A               ; 'FC' ERROR IF DEVICE NUMBER NOT A DISK FILE
C808  BD C7 19                   JSR   LC719               ; POINT X TO FCB
C80B  A6 00                      LDA   FCBTYP,X            ; TEST IF BUFFER IS IN USE
C80D  10 27 DB EA                LBEQ  LA3FB               ; 'FILE NOT OPEN' ERROR
C811  81 40                      CMPA  #RANFIL             ; DIRECT/RANDOM FILE?
C813  27 C1                      BEQ   LC7D6               ; RETURN IF RANDOM
C815  7E A6 16          LC815    JMP   LA616               ; BAD FILE MODE ERROR IF NOT RANDOM

* INPUT DEVICE NUMBER CHECK RAM HOOK
C818  86 10             DVEC5    LDA   #INPFIL             ; INPUT FILE TYPE
C81A  8C 86 20          LC81A    CMPX  #$8620              ; SKIP TWO BYTES

* PRINT DEVICE NUMBER CHECK RAM HOOK
C81B  86 20             DVEC6    LDA   #OUTFIL             ; OUTPUT FILE TYPE
C81D  0D 6F                      TST   DEVNUM              ; * CHECK DEVICE NUMBER AND RETURN IF
C81F  2F B5                      BLE   LC7D6               ; * NOT A DISK FILE
C821  AF E4                      STX   ,S                  ; = REPLACE SUBROUTINE RETURN ADDRESS WITH X REGISTER -
* = THIS IS THE SAME AS LEAS 2,S AND PSHS X
C823  BD C7 14                   JSR   LC714               ; POINT X TO FCB
C826  34 02                      PSHS  A                   ; SAVE FILE TYPE ON STACK
C828  A6 00                      LDA   FCBTYP,X            ; GET FILE TYPE
C82A  10 27 DB CD                LBEQ  LA3FB               ; 'FILE NOT OPEN' ERROR
C82E  81 40                      CMPA  #RANFIL             ; RANDOM FILE?
C830  27 04                      BEQ   LC836               ; BRANCH IF RANDOM FILE
C832  A1 E4                      CMPA  ,S                  ; IS THIS FCB OF THE PROPER TYPE?
C834  26 DF                      BNE   LC815               ; 'FILE MODE' ERROR IF NOT
C836  35 92             LC836    PULS  A,X,PC              ; RETURN
* DEVICE NUMBER VALIDITY CHECK RAM HOOK
C838  2F 9C             DVEC1    BLE   LC7D6               ; RETURN IF NOT A DISK FILE
C83A  F1 09 5B                   CMPB  FCBACT              ; COMPARE DEVICE NUMBER TO HIGHEST POSSIBLE
C83D  10 22 DD DE                LBHI  LA61F               ; 'DEVICE NUMBER' ERROR IF TOO BIG
C841  35 90                      PULS  X,PC                ; RETURN

* SET PRINT PARAMETERS RAM HOOK
C843  0D 6F             DVEC2    TST   DEVNUM              ; *CHECK DEVICE NUMBER AND
C845  2F 8F                      BLE   LC7D6               ; *RETURN IF NOT DISK FILE
C847  32 62                      LEAS  $02,S               ; PURGE RETURN ADDRESS OFF OF THE STACK
C849  34 16                      PSHS  X,B,A               ; SAVE REGISTERS
C84B  0F 6E                      CLR   PRTDEV              ; SET PRINT DEVICE NUMBER TO NON-CASSETTE
C84D  BD C7 14                   JSR   LC714               ; POINT X TO FCB
C850  E6 06                      LDB   FCBPOS,X            ; GET PRINT POSITION
C852  4F                         CLRA                      ; PRINT WIDTH (256)
C853  8E 10 00                   LDX   #$1000              ; TAB FIELD WIDTH AND TAB ZONE
C856  7E A3 7C                   JMP   LA37C               ; SAVE THE PRINT PARAMETERS

* BREAK CHECK RAM HOOK
C859  0D 6F             DVEC11   TST   DEVNUM              ; * CHECK DEVICE NUMBER AND RETURN
C85B  2F 02                      BLE   LC85F               ; * IF NOT A DISK FILE
C85D  32 62                      LEAS  $02,S               ; = PURGE RETURN ADDRESS OFF OF THE STACK - DON'T
C85F  39                LC85F    RTS                       ; = DO A BREAK CHECK IF DISK FILE
