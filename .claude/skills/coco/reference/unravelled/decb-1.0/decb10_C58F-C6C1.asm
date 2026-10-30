; Disk Extended Color BASIC 1.0 -- $C58F-$C6C1
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: DVEC4=$C58F, DVEC12=$C6B7

* CONSOLE IN RAM VECTOR
C58F  96 6F             DVEC4    LDA   DEVNUM              ; GET DEVICE NUMBER
C591  10 2F C7 5C                LBLE  XVEC4               ; BRANCH IF NOT DISK FILE
C595  32 62                      LEAS  $02,S               ; GET RID OF RETURN ADDRESS
C597  34 14             LC597    PSHS  X,B                 ; SAVE REGISTERS
C599  0F 70                      CLR   CINBFL              ; CLEAR BUFFER NOT EMPTY FLAG
C59B  8E 09 26                   LDX   #FCBV1-2            ; POINT TO FILE BUFFER VECTOR TABLE
C59E  D6 6F                      LDB   DEVNUM              ; GET ACTIVE DISK FILE NUMBER
C5A0  58                         ASLB                      ; TIMES 2 - TWO BYTES PER FCB ADDRESS
C5A1  AE 85                      LDX   B,X                 ; NOW X POINTS TO FILE BUFFER
C5A3  E6 84                      LDB   FCBTYP,X            ; GET FILE TYPE
C5A5  C1 40                      CMPB  #RANFIL             ; IS THIS A RANDOM (DIRECT) FILE?
C5A7  26 16                      BNE   LC5BF               ; BRANCH IF NOT

* GET A BYTE FROM A RANDOM FILE - RETURN CHAR IN ACCA
C5A9  EC 88 15                   LDD   FCBGET,X            ; GET THE RECORD COUNTER
C5AC  10 A3 09                   CMPD  FCBRLN,X            ; *COMPARE TO RECORD LENGTH AND
C5AF  24 20                      BHS   LC5D1               ; *BRANCH TO BUFFER EMPTY IF >= RECORD LENGTH
C5B1  C3 00 01                   ADDD  #$0001              ; = ADD ONE TO RECORD POINTER AND
C5B4  ED 88 15                   STD   FCBGET,X            ; = SAVE IT IN FCB
C5B7  AE 0B                      LDX   FCBBUF,X            ; * POINT X TO START OF RANDOM FILE BUFFER AND
C5B9  30 8B                      LEAX  D,X                 ; * ADD THE RECORD COUNTER TO IT
C5BB  A6 1F                      LDA   -1,X                ; GET A CHARACTER FROM THE BUFFER
C5BD  35 94                      PULS  B,X,PC              ; RESTORE REGISTERS AND RETURN
* GET A BYTE FROM A SEQUENTIAL FILE
C5BF  E6 88 10          LC5BF    LDB   FCBCFL,X            ; * TEST THE CACHE FLAG AND BRANCH IF AN
C5C2  27 08                      BEQ   LC5CC               ; * EXTRA CHARACTER HAS NOT BEEN READ FROM FILE
C5C4  A6 88 11                   LDA   FCBCDT,X            ; GET THE CACHE CHARACTER
C5C7  6F 88 10                   CLR   FCBCFL,X            ; CLEAR THE CACHE FLAG
C5CA  35 94                      PULS  B,X,PC              ; RESTORE REGISTERS AND RETURN

C5CC  E6 88 17          LC5CC    LDB   FCBDFL,X            ; IS ANY DATA LEFT?
C5CF  27 04                      BEQ   LC5D5               ; BRANCH IF SO
C5D1  03 70             LC5D1    COM   CINBFL              ; SET FLAG TO BUFFER EMPTY
C5D3  35 94                      PULS  B,X,PC

C5D5  E6 05             LC5D5    LDB   FCBCPT,X            ; GET CHARACTER POINTER
C5D7  6C 05                      INC   FCBCPT,X            ; ADD ONE TO CHARACTER POINTER
C5D9  6A 88 18                   DEC   FCBLFT,X            ; DECREMENT NUMBER OF CHARACTERS LEFT IN FILE BUFFER
C5DC  27 06                      BEQ   LC5E4               ; IF LAST CHARACTER, GO GET SOME MORE
C5DE  3A                         ABX                       ; ADD CHARACTER COUNTER TO X
C5DF  A6 88 19                   LDA   FCBCON,X            ; GET DATA CHARACTER (SKIP PAST 25 FCB CONTROL BYTES
C5E2  35 94                      PULS  B,X,PC
* GET A CHARACTER FROM FCB DATA BUFFER - RETURN CHAR IN ACCA
C5E4  34 60             LC5E4    PSHS  U,Y                 ; SAVE REGISTERS
C5E6  4F                         CLRA                      ; *
C5E7  33 8B                      LEAU  D,X                 ; * POINT U TO CORRECT CHARACTER
C5E9  A6 C8 19                   LDA   FCBCON,U            ; =GET DATA CHAR (SKIP PAST 25 CONTROL BYTES)
C5EC  34 02                      PSHS  A                   ; =AND SAVE DATA CHARACTER ON STACK
C5EE  6F 05                      CLR   FCBCPT,X            ; RESET CHAR POINTER TO START OF BUFFER
C5F0  A6 01                      LDA   FCBDRV,X            ; GET DRIVE NUMBER AND SAVE IT IN
C5F2  97 EB                      STA   DCDRV               ; DSKCON VARIABLE
C5F4  8D 04                      BSR   LC5FA               ; GO READ A SECTOR - FILL THE BUFFER
C5F6  35 62                      PULS  A,Y,U               ; RESTORE REGISTERS AND DATA CHARACTER
C5F8  35 94                      PULS  B,X,PC              ; RESTORE REGISTERS AND RETURN
* REFILL THE FCB INPUT DATA BUFFER FOR SEQUENTIAL FILES
C5FA  A6 04             LC5FA    LDA   FCBSEC,X            ; GET CURRENT SECTOR NUMBER
C5FC  4C                LC5FC    INCA                      ; ADD ONE
C5FD  34 02                      PSHS  A                   ; SAVE NEW SECTOR NUMBER ON THE STACK
C5FF  81 09                      CMPA  #$09                ; NINE SECTORS PER GRANULE
C601  23 01                      BLS   LC604               ; BRANCH IF <= 9
C603  4F                         CLRA                      ; SET TO SECTOR ZERO
C604  A7 04             LC604    STA   FCBSEC,X            ; SAVE SECTOR NUMBER
C606  E6 03                      LDB   FCBCGR,X            ; GET GRANULE NUMBET TO FAT POINTER
C608  33 84                      LEAU  ,X                  ; POINT U TO FCB (TFR X,U)
C60A  BD C7 25                   JSR   LC725               ; POINT X TO PROPER FILE ALLOCATION TABLE
C60D  3A                         ABX                       ; ADD OLD GRANULE NUMBER TO FAT POINTER
C60E  E6 06                      LDB   FATCON,X            ; GET GRANULE NUMBER (6 CONTROL BYTES AT FRONT OF FAT)
C610  30 C4                      LEAX  ,U                  ; POINT X TO FCB
C612  C1 C0                      CMPB  #$C0                ; IS CURRENT GRANULE LAST ONE IN FILE?
C614  24 0A                      BHS   LC620               ; YES
C616  35 02                      PULS  A                   ; GET SECTOR NUMBER
C618  80 0A                      SUBA  #10                 ; WAS IT 10? - OVERFLOW TO NEXT GRANULE IF SO
C61A  26 15                      BNE   LC631               ; BRANCH IF NOT
C61C  E7 03                      STB   FCBCGR,X            ; SAVE NEW GRANULE NUMBER
C61E  20 DC                      BRA   LC5FC               ; SET VARIABLES FOR NEW GRANULE
C620  C4 3F             LC620    ANDB  #$3F                ; GET NUMBER OF SECTORS USED IN THIS GRANULE
C622  C1 09                      CMPB  #$09                ; 9 SECTORS / GRANULE
C624  23 05                      BLS   LC62B               ; BRANCH IF OK
C626  C6 40             LC626    LDB   #2*32               ; 'BAD FILE STRUCTURE' ERROR
C628  7E AC 46                   JMP   LAC46               ; ERROR DRIVER
C62B  E0 E0             LC62B    SUBB  ,S+                 ; SUBTRACT CURRENT SECTOR NUMBER AND PULS A
C62D  25 21                      BLO   LC650               ; BRANCH IF PAST LAST SECTOR
C62F  1F 98                      TFR   B,A                 ; SECTOR NUMBER TO ACCA
C631  34 02             LC631    PSHS  A                   ; SAVE SECTOR NUMBER DIFFERENCE
C633  8D 23                      BSR   LC658               ; INCREMENT RECORD NUMBER
C635  86 02                      LDA   #$02                ; *GET READ OPERATION CODE
C637  97 EA                      STA   DCOPC               ; *AND SAVE IT IN DSKCON VARIABLE
C639  BD C7 33                   JSR   LC733               ; GET PROPER TRACK AND SECTOR TO DSKCON VARIABLES
C63C  33 88 19                   LEAU  FCBCON,X            ; * POINT U TO START OF FCB DATA BUFFER
C63F  DF EE                      STU   DCBPT               ; * AND SAVE IT IN DSKCON VARIABLE
C641  BD D5 FF                   JSR   LD5FF               ; GO READ A SECTOR INTO FCB BUFFER
C644  6F 88 18                   CLR   FCBLFT,X            ; NUMBER OF CHARS LEFT IN BUFFER = 256
C647  E6 E0                      LDB   ,S+                 ; GET SECTOR NUMBER OFF STACK
C649  26 0C                      BNE   LC657               ; RETURN IF DATA LEFT; FALL THRU IF LAST SECTOR
C64B  EC 88 13                   LDD   FCBLST,X            ; GET NUMBER OF BYTES IN THE LAST SECTOR
C64E  26 04                      BNE   LC654               ; BRANCH IF SOME BYTES IN LAST SECTOR
C650  5F                LC650    CLRB                      ; SET NUMBER OF REMAINING BYTES = 256
C651  63 88 17                   COM   FCBDFL,X            ; SET DATA LEFT FLAG TO $FF
C654  E7 88 18          LC654    STB   FCBLFT,X            ; SAVE THE NUMBER OF CHARS LEFT IN BUFFER
C657  39                LC657    RTS

C658  EE 07             LC658    LDU   FCBREC,X            ; GET CURRENT RECORD NUMBER
C65A  33 41                      LEAU  $01,U               ; BUMP IT
C65C  EF 07                      STU   FCBREC,X            ; PUT IT BACK
C65E  39                         RTS

* SCAN DIRECTORY FOR FILENAME.EXT FOUND IN DNAMBF. IF FILENAME FOUND,
* RETURN WITH SECTOR NUMBER IN V973, GRANULE IN V976 AND RAM BUFFER
* CONTAINING DIRECTORY DATA IN V974. IF DISK IS FULL THEN V973,
* V977 = 0. THE FIRST UNUSED SECTOR RETURNED IN V977, RAM IMAGE IN V978
C65F  7F 09 73          LC65F    CLR   V973                ; CLEAR SECTOR NUMBER
C662  7F 09 77                   CLR   V977                ; CLEAR TEMP SECTOR COUNTER
C665  CC 11 02                   LDD   #$1102              ; TRACK 17 (DIRECTORY), READ OPERATION CODE
C668  97 EC                      STA   DCTRK               ; SAVE TRACK NUMBER
C66A  D7 EA                      STB   DCOPC               ; SAVE OPERATION CODE (READ)
C66C  C6 03                      LDB   #$03                ; READ SECTOR 3 (FIRST DIRECTORY SECTOR)
C66E  D7 ED             LC66E    STB   DSEC                ; SAVE SECTOR NUMBER IN DSKCON VARIABLE
C670  CE 06 00                   LDU   #DBUF0              ; *BUFFER AREA NUMBER 0 AS DATA BUFFER - SAVE
C673  DF EE                      STU   DCBPT               ; *IN DSKCON VARIABLE
C675  BD D5 FF                   JSR   LD5FF               ; GO READ A SECTOR
C678  FF 09 74          LC678    STU   V974                ; SAVE RAM DIRECTORY BUFFER ADDRESS
C67B  31 C4                      LEAY  ,U                  ; POINT Y TO DIRECTORY BUFFER
C67D  A6 C4                      LDA   ,U                  ; GET A BYTE FROM BUFFER
C67F  26 28                      BNE   LC6A9               ; BRANCH IF NOT ZERO - FILE IS ACTIVE
C681  8D 29                      BSR   LC6AC               ; SET UNUSED FILE POINTERS IF ENTRY HAS BEEN KILLED
C683  8E 09 4C          LC683    LDX   #DNAMBF             ; POINT TO DISK FILE NAME BUFFER
C686  A6 80             LC686    LDA   ,X+                 ; *COMPARE THE FILENAME AND EXTENSION
C688  A1 C0                      CMPA  ,U+                 ; *STORED IN RAM AT DNAMBF TO THE DIRECTORY
C68A  26 0E                      BNE   LC69A               ; *ENTRY STORED AT ,U (BRANCH IF MISMATCH)
C68C  8C 09 57                   CMPX  #DNAMBF+11          ; AT END OF FILE NAME BUFFER?
C68F  26 F5                      BNE   LC686               ; BRANCH IF NOT DONE CHECKING FILENAME
C691  F7 09 73                   STB   V973                ; SAVE SECTOR NUMBER IN DSKCON VARIABLE
C694  A6 42                      LDA   FCBFGR,U            ; *GET NUMBER OF FIRST GRANULE IN FILE
C696  B7 09 76                   STA   V976                ; *AND SAVE IT IN V976
C699  39                         RTS

C69A  33 A8 20          LC69A    LEAU  DIRLEN,Y            ; GET NEXT DIRECTORY ENTRY (DIRLEN BYTES PER ENTRY)
C69D  11 83 07 00                CMPU  #DBUF0+SECLEN       ; AT END OF BUFFER?
C6A1  26 D5                      BNE   LC678               ; CHECK NEXT ENTRY IF NOT AT END
C6A3  5C                         INCB                      ; NEXT SECTOR
C6A4  C1 0B                      CMPB  #11                 ; 11 SECTORS MAX IN DIRECTORY
C6A6  23 C6                      BLS   LC66E               ; BRANCH IF MORE SECTORS
C6A8  39                         RTS

C6A9  43                LC6A9    COMA                      ; COMPLEMENT FIRST BYTE IN DIRECTORY EMTRY
C6AA  26 D7                      BNE   LC683               ; BRANCH IF FILE IS ACTIVE - FALL THRU IF NOT USED

* SET POINTERS FOR FIRST UNUSED DIRECTORY ENTRY
C6AC  B6 09 77          LC6AC    LDA   V977                ; UNUSED ENTRY ALREADY FOUND?
C6AF  26 06                      BNE   DVEC12              ; RETURN IF UNUSED ENTRY ALREADY FOUND
C6B1  F7 09 77                   STB   V977                ; SECTOR CONTAINING THIS DIRECTORY ENTRY
C6B4  FF 09 78                   STU   V978                ; POINTS TO RAM AREA WHERE DIRECTORY DATA IS STORED
C6B7  39                DVEC12   RTS

C6B8  C6 34             LC6B8    LDB   #2*26               ; 'NE' ERROR
C6BA  7D 09 73                   TST   V973                ; WAS A DIRECTORY MATCH FOUND?
C6BD  26 F8                      BNE   DVEC12              ; RETURN IF FOUND
C6BF  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER IF NOT FOUND
