; Disk Extended Color BASIC 1.1 -- $C5BC-$C6EE
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: DVEC4=$C5BC, DVEC12=$C6E4

* CONSOLE IN RAM VECTOR
C5BC  96 6F             DVEC4    LDA   DEVNUM              ; GET DEVICE NUMBER
C5BE  10 2F C7 2F                LBLE  XVEC4               ; BRANCH IF NOT DISK FILE
C5C2  32 62                      LEAS  $02,S               ; GET RID OF RETURN ADDRESS
C5C4  34 14             LC5C4    PSHS  X,B                 ; SAVE REGISTERS
C5C6  0F 70                      CLR   CINBFL              ; CLEAR BUFFER NOT EMPTY FLAG
C5C8  8E 09 26                   LDX   #FCBV1-2            ; POINT TO FILE BUFFER VECTOR TABLE
C5CB  D6 6F                      LDB   DEVNUM              ; GET ACTIVE DISK FILE NUMBER
C5CD  58                         ASLB                      ; TIMES 2 - TWO BYTES PER FCB ADDRESS
C5CE  AE 85                      LDX   B,X                 ; NOW X POINTS TO FILE BUFFER
C5D0  E6 84                      LDB   FCBTYPE,X           ; GET FILE TYPE
C5D2  C1 40                      CMPB  #RANFIL             ; IS THIS A RANDOM (DIRECT) FILE?
C5D4  26 16                      BNE   LC5EC               ; BRANCH IF NOT

* GET A BYTE FROM A RANDOM FILE - RETURN CHAR IN ACCA
C5D6  EC 88 15                   LDD   FCBGET,X            ; GET THE RECORD COUNTER
C5D9  10 A3 09                   CMPD  FCBRLN,X            ; *COMPARE TO RECORD LENGTH AND
C5DC  24 20                      BHS   LC5FE               ; *BRANCH TO BUFFER EMPTY IF >= RECORD LENGTH
C5DE  C3 00 01                   ADDD  #$0001              ; = ADD ONE TO RECORD POINTER AND
C5E1  ED 88 15                   STD   FCBGET,X            ; = SAVE IT IN FCB
C5E4  AE 0B                      LDX   FCBBUF,X            ; * POINT X TO START OF RANDOM FILE BUFFER AND
C5E6  30 8B                      LEAX  D,X                 ; * ADD THE RECORD COUNTER TO IT
C5E8  A6 1F                      LDA   $-1,X               ; GET A CHARACTER FROM THE BUFFER
C5EA  35 94                      PULS  B,X,PC              ; RESTORE REGISTERS AND RETURN
* GET A BYTE FROM A SEQUENTIAL FILE
C5EC  E6 88 10          LC5EC    LDB   FCBCFL,X            ; * TEST THE CACHE FLAG AND BRANCH IF AN
C5EF  27 08                      BEQ   LC5F9               ; * EXTRA CHARACTER HAS NOT BEEN READ FROM FILE
C5F1  A6 88 11                   LDA   FCBCDT,X            ; GET THE CACHE CHARACTER
C5F4  6F 88 10                   CLR   FCBCFL,X            ; CLEAR THE CACHE FLAG
C5F7  35 94                      PULS  B,X,PC              ; RESTORE REGISTERS AND RETURN

C5F9  E6 88 17          LC5F9    LDB   FCBDFL,X            ; IS ANY DATA LEFT?
C5FC  27 04                      BEQ   LC602               ; BRANCH IF SO
C5FE  03 70                      COM   CINBFL              ; SET FLAG TO BUFFER EMPTY
C600  35 94                      PULS  B,X,PC              ; RESTORE REGISTERS AND RETURN

C602  E6 05             LC602    LDB   FCBCPT,X            ; GET CHARACTER POINTER
C604  6C 05                      INC   FCBCPT,X            ; ADD ONE TO CHARACTER POINTER
C606  6A 88 18                   DEC   FCBLFT,X            ; DECREMENT NUMBER OF CHARACTERS LEFT IN FILE BUFFER
C609  27 06                      BEQ   LC611               ; IF LAST CHARACTER, GO GET SOME MORE
C60B  3A                         ABX                       ; ADD CHARACTER COUNTER TO X
C60C  A6 88 19                   LDA   FCBCON,X            ; GET DATA CHARACTER (SKIP PAST 25 FCB CONTROL BYTES
C60F  35 94                      PULS  B,X,PC
* GET A CHARACTER FROM FCB DATA BUFFER - RETURN CHAR IN ACCA
C611  34 60             LC611    PSHS  U,Y                 ; SAVE REGISTERS
C613  4F                         CLRA                      ; *
C614  33 8B                      LEAU  D,X                 ; * POINT U TO CORRECT CHARACTER
C616  A6 C8 19                   LDA   FCBCON,U            ; =GET DATA CHAR (SKIP PAST 25 CONTROL BYTES)
C619  34 02                      PSHS  A                   ; =AND SAVE DATA CHARACTER ON STACK
C61B  6F 05                      CLR   FCBCPT,X            ; RESET CHAR POINTER TO START OF BUFFER
C61D  A6 01                      LDA   FCBDRV,X            ; GET DRIVE NUMBER AND SAVE IT IN
C61F  97 EB                      STA   DCDRV               ; DSKCON VARIABLE
C621  8D 04                      BSR   LC627               ; GO READ A SECTOR - FILL THE BUFFER
C623  35 62                      PULS  A,Y,U               ; RESTORE REGISTERS AND DATA CHARACTER
C625  35 94                      PULS  B,X,PC              ; RESTORE REGISTERS AND RETURN
* REFILL THE FCB INPUT DATA BUFFER FOR SEQUENTIAL FILES
C627  A6 04             LC627    LDA   FCBSEC,X            ; GET CURRENT SECTOR NUMBER
C629  4C                LC629    INCA                      ; ADD ONE
C62A  34 02                      PSHS  A                   ; SAVE NEW SECTOR NUMBER ON THE STACK
C62C  81 09                      CMPA  #$09                ; NINE SECTORS PER GRANULE
C62E  23 01                      BLS   LC631               ; BRANCH IF <= 9
C630  4F                         CLRA                      ; SET TO SECTOR ZERO
C631  A7 04             LC631    STA   FCBSEC,X            ; SAVE SECTOR NUMBER
C633  E6 03                      LDB   FCBCGR,X            ; GET GRANULE NUMBET TO FAT POINTER
C635  33 84                      LEAU  ,X                  ; POINT U TO FCB (TFR X,U)
C637  BD C7 55                   JSR   LC755               ; POINT X TO PROPER FILE ALLOCATION TABLE
C63A  3A                         ABX                       ; ADD OLD GRANULE NUMBER TO FAT POINTER
C63B  E6 06                      LDB   FATCON,X            ; GET GRANULE NUMBER (6 CONTROL BYTES AT FRONT OF FAT)
C63D  30 C4                      LEAX  ,U                  ; POINT X TO FCB
C63F  C1 C0                      CMPB  #$C0                ; IS CURRENT GRANULE LAST ONE IN FILE?
C641  24 0A                      BHS   LC64D               ; YES
C643  35 02                      PULS  A                   ; GET SECTOR NUMBER
C645  80 0A                      SUBA  #10                 ; WAS IT 10? - OVERFLOW TO NEXT GRANULE IF SO
C647  26 15                      BNE   LC65E               ; BRANCH IF NOT
C649  E7 03                      STB   FCBCGR,X            ; SAVE NEW GRANULE NUMBER
C64B  20 DC                      BRA   LC629               ; SET VARIABLES FOR NEW GRANULE
C64D  C4 3F             LC64D    ANDB  #$3F                ; GET NUMBER OF SECTORS USED IN THIS GRANULE
C64F  C1 09                      CMPB  #$09                ; 9 SECTORS / GRANULE
C651  23 05                      BLS   LC658               ; BRANCH IF OK
C653  C6 40             LC653    LDB   #2*32               ; 'BAD FILE STRUCTURE' ERROR
C655  7E AC 46                   JMP   LAC46               ; ERROR DRIVER
C658  E0 E0             LC658    SUBB  ,S+                 ; SUBTRACT CURRENT SECTOR NUMBER AND PULS A
C65A  25 21                      BLO   LC67D               ; BRANCH IF PAST LAST SECTOR
C65C  1F 98                      TFR   B,A                 ; SECTOR NUMBER TO ACCA
C65E  34 02             LC65E    PSHS  A                   ; SAVE SECTOR NUMBER DIFFERENCE
C660  8D 23                      BSR   LC685               ; INCREMENT RECORD NUMBER
C662  86 02                      LDA   #$02                ; *GET READ OPERATION CODE
C664  97 EA                      STA   DCOPC               ; *AND SAVE IT IN DSKCON VARIABLE
C666  BD C7 63                   JSR   LC763               ; GET PROPER TRACK AND SECTOR TO DSKCON VARIABLES
C669  33 88 19                   LEAU  FCBCON,X            ; * POINT U TO START OF FCB DATA BUFFER
C66C  DF EE                      STU   DCBPT               ; * AND SAVE IT IN DSKCON VARIABLE
C66E  BD D6 F2                   JSR   LD6F2               ; GO READ A SECTOR INTO FCB BUFFER
C671  6F 88 18                   CLR   FCBLFT,X            ; NUMBER OF CHARS LEFT IN BUFFER = 256
C674  E6 E0                      LDB   ,S+                 ; GET SECTOR NUMBER OFF STACK
C676  26 0C                      BNE   LC684               ; RETURN IF DATA LEFT; FALL THRU IF LAST SECTOR
C678  EC 88 13                   LDD   FCBLST,X            ; GET NUMBER OF BYTES IN THE LAST SECTOR
C67B  26 04                      BNE   LC681               ; BRANCH IF SOME BYTES IN LAST SECTOR
C67D  5F                LC67D    CLRB                      ; SET NUMBER OF REMAINING BYTES = 256
C67E  63 88 17                   COM   FCBDFL,X            ; SET DATA LEFT FLAG TO $FF
C681  E7 88 18          LC681    STB   FCBLFT,X            ; SAVE THE NUMBER OF CHARS LEFT IN BUFFER
C684  39                LC684    RTS

C685  EE 07             LC685    LDU   FCBREC,X            ; GET CURRENT RECORD NUMBER
C687  33 41                      LEAU  $01,U               ; BUMP IT
C689  EF 07                      STU   FCBREC,X            ; PUT IT BACK
C68B  39                         RTS

* SCAN DIRECTORY FOR FILENAME.EXT FOUND IN DNAMBF. IF FILENAME FOUND,
* RETURN WITH SECTOR NUMBER IN V973, GRANULE IN V976 AND RAM BUFFER
* CONTAINING DIRECTORY DATA IN V974. IF DISK IS FULL THEN V973,
* V977 = 0. THE FIRST UNUSED SECTOR RETURNED IN V977, RAM IMAGE IN V978
C68C  7F 09 73          LC68C    CLR   V973                ; CLEAR SECTOR NUMBER
C68F  7F 09 77                   CLR   V977                ; CLEAR TEMP SECTOR COUNTER
C692  CC 11 02                   LDD   #$1102              ; TRACK 17 (DIRECTORY), READ OPERATION CODE
C695  97 EC                      STA   DCTRK               ; SAVE TRACK NUMBER
C697  D7 EA                      STB   DCOPC               ; SAVE OPERATION CODE (READ)
C699  C6 03                      LDB   #$03                ; READ SECTOR 3 (FIRST DIRECTORY SECTOR)
C69B  D7 ED             LC69B    STB   DSEC                ; SAVE SECTOR NUMBER IN DSKCON VARIABLE
C69D  CE 06 00                   LDU   #DBUF0              ; *BUFFER AREA NUMBER 0 AS DATA BUFFER - SAVE
C6A0  DF EE                      STU   DCBPT               ; *IN DSKCON VARIABLE
C6A2  BD D6 F2                   JSR   LD6F2               ; GO READ A SECTOR
C6A5  FF 09 74          LC6A5    STU   V974                ; SAVE RAM DIRECTORY BUFFER ADDRESS
C6A8  31 C4                      LEAY  ,U                  ; POINT Y TO DIRECTORY BUFFER
C6AA  A6 C4                      LDA   ,U                  ; GET A BYTE FROM BUFFER
C6AC  26 28                      BNE   LC6D6               ; BRANCH IF NOT ZERO - FILE IS ACTIVE
C6AE  8D 29                      BSR   LC6D9               ; SET UNUSED FILE POINTERS IF ENTRY HAS BEEN KILLED
C6B0  8E 09 4C          LC6B0    LDX   #DNAMBF             ; POINT TO DISK FILE NAME BUFFER
C6B3  A6 80             LC6B3    LDA   ,X+                 ; *COMPARE THE FILENAME AND EXTENSION
C6B5  A1 C0                      CMPA  ,U+                 ; *STORED IN RAM AT DNAMBF TO THE DIRECTORY
C6B7  26 0E                      BNE   LC6C7               ; *ENTRY STORED AT ,U (BRANCH IF MISMATCH)
C6B9  8C 09 57                   CMPX  #DNAMBF+11          ; AT END OF FILE NAME BUFFER?
C6BC  26 F5                      BNE   LC6B3               ; BRANCH IF NOT DONE CHECKING FILENAME
C6BE  F7 09 73                   STB   V973                ; SAVE SECTOR NUMBER IN DSKCON VARIABLE
C6C1  A6 42                      LDA   FCBFGR,U            ; *GET NUMBER OF FIRST GRANULE IN FILE
C6C3  B7 09 76                   STA   V976                ; *AND SAVE IT IN V976
C6C6  39                         RTS

C6C7  33 A8 20          LC6C7    LEAU  DIRLEN,Y            ; GET NEXT DIRECTORY ENTRY (DIRLEN BYTES PER ENTRY)
C6CA  11 83 07 00                CMPU  #DBUF0+SECLEN       ; AT END OF BUFFER?
C6CE  26 D5                      BNE   LC6A5               ; CHECK NEXT ENTRY IF NOT AT END
C6D0  5C                         INCB                      ; NEXT SECTOR
C6D1  C1 0B                      CMPB  #11                 ; 11 SECTORS MAX IN DIRECTORY
C6D3  23 C6                      BLS   LC69B               ; BRANCH IF MORE SECTORS
C6D5  39                         RTS

C6D6  43                LC6D6    COMA                      ; COMPLEMENT FIRST BYTE IN DIRECTORY EMTRY
C6D7  26 D7                      BNE   LC6B0               ; BRANCH IF FILE IS ACTIVE - FALL THRU IF NOT USED

* SET POINTERS FOR FIRST UNUSED DIRECTORY ENTRY
C6D9  B6 09 77          LC6D9    LDA   V977                ; UNUSED ENTRY ALREADY FOUND?
C6DC  26 06                      BNE   DVEC12              ; RETURN IF UNUSED ENTRY ALREADY FOUND
C6DE  F7 09 77                   STB   V977                ; SECTOR CONTAINING THIS DIRECTORY ENTRY
C6E1  FF 09 78                   STU   V978                ; POINTS TO RAM AREA WHERE DIRECTORY DATA IS STORED
C6E4  39                DVEC12   RTS

C6E5  C6 34             LC6E4    LDB   #2*26               ; 'NE' ERROR
C6E7  7D 09 73                   TST   V973                ; WAS A DIRECTORY MATCH FOUND?
C6EA  26 F8                      BNE   DVEC12              ; RETURN IF FOUND
C6EC  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER IF NOT FOUND
