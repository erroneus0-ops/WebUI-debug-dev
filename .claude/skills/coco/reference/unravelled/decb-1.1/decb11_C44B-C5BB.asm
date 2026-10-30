; Disk Extended Color BASIC 1.1 -- $C44B-$C5BB
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: DVEC0=$C44B

* * BUFFER ADDRESS OFF STACK AND RETURN

* OPEN RAM HOOK
C44B  32 62             DVEC0    LEAS  $02,S               ; PULL RETURN ADDRESS OFF OF THE STACK
C44D  BD B1 56                   JSR   LB156               ; EVALUATE AN EXPRESSION
C450  BD B6 A4                   JSR   LB6A4               ; *GET MODE(I,O,R) - FIRST BYTE OF STRING EXPRESSION
C453  34 04                      PSHS  B                   ; *AND SAVE IT ON STACK
C455  BD A5 A2                   JSR   LA5A2               ; GET DEVICE NUMBER
C458  5D                         TSTB                      ; SET FLAGS
C459  10 2F E1 A6                LBLE  LA603               ; BRANCH IF NOT A DISK FILE
C45D  35 02                      PULS  A                   ; GET MODE
C45F  34 06                      PSHS  B,A                 ; SAVE MODE AND DEVICE NUMBER (FILE NUMBER)
C461  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
C463  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
C466  8E C2 AC                   LDX   #DATEXT             ; POINT TO 'DAT' FOR EXTENSION
C469  BD C9 38                   JSR   LC938               ; GET FILENAME FROM BASIC
C46C  CC 01 FF                   LDD   #$01FF              ; DEFAULT DISK FILE TYPE AND ASCII FLAG
C46F  FD 09 57                   STD   DFLTYP              ; SAVE DEFAULT VALUES: DATA, ASCII
C472  8E 01 00                   LDX   #SECLEN             ; DEFAULT RECORD LENGTH - 1 PAGE
C475  9D A5                      JSR   GETCCH              ; GET CHAR FROM BASIC
C477  27 08                      BEQ   LC481               ; BRANCH IF END OF LINE
C479  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
C47C  BD B3 E6                   JSR   LB3E6               ; EVALUATE EXPRESSION
C47F  9E 52                      LDX   FPA0+2              ; GET EVALUATED EXPRESSION
C481  BF 09 7C          LC481    STX   DFFLEN              ; RECORD LENGTH
C484  10 27 EF C2                LBEQ  LB44A               ; IF = 0, THEN 'ILLEGAL FUNCTION CALL'
C488  BD A5 C7                   JSR   LA5C7               ; ERROR IF ANY FURTHER CHARACTERS ON LINE
C48B  35 06                      PULS  A,B                 ; GET MODE AND FILE NUMBER

* OPEN DISK FILE FOR READ OR WRITE
C48D  34 02             LC48D    PSHS  A                   ; SAVE MODE ON STACK
C48F  BD C7 49                   JSR   LC749               ; POINT X TO FCB FOR THIS FILE
C492  10 26 E1 86                LBNE  LA61C               ; 'FILE ALREADY OPEN' ERROR IF FILE OPEN
C496  9F F1                      STX   FCBTMP              ; SAVE FILE BUFFER POINTER
C498  BD C7 9D                   JSR   LC79D               ; MAKE SURE FILE ALLOC TABLE IS VALID
C49B  BD C6 8C                   JSR   LC68C               ; SCAN DIRECTORY FOR 'FILENAME.EXT'
C49E  35 04                      PULS  B                   ; GET MODE
C4A0  86 10                      LDA   #INPFIL             ; INPUT TYPE FILE
C4A2  34 02                      PSHS  A                   ; SAVE FILE TYPE ON STACK
C4A4  C1 49                      CMPB  #'I'                ; INPUT MODE?
C4A6  26 1F                      BNE   LC4C7               ; BRANCH IF NOT

* OPEN A SEQUENTIAL FILE FOR INPUT
C4A8  BD C6 E5                   JSR   LC6E5               ; CHECK TO SEE IF DIRECTORY MATCH IS FOUND
C4AB  BD C8 07                   JSR   LC807               ; CHECK TO SEE IF FILE ALREADY OPEN
C4AE  BE 09 74                   LDX   V974                ; GET RAM DIRECTORY BUFFER
C4B1  EC 0B                      LDD   DIRTYP,X            ; GET FILE TYPE AND ASCII FLAG
C4B3  FD 09 57                   STD   DFLTYP              ; SAVE IN RAM IMAGE
C4B6  8D 75                      BSR   LC52D               ; INITIALIZE FILE BUFFER CONTROL BLOCK
C4B8  BD C6 27                   JSR   LC627               ; GO FILL DATA BUFFER
C4BB  BD C7 55          LC4BB    JSR   LC755               ; POINT X TO PROPER FILE ALLOCATION TABLE
C4BE  6C 00                      INC   FAT0,X              ; ADD ONE TO FAT ACTIVE FILE COUNTER
C4C0  9E F1                      LDX   FCBTMP              ; GET FILE BUFFER POINTER
C4C2  35 02                      PULS  A                   ; GET FILE TYPE
C4C4  A7 00                      STA   FCBTYP,X            ; SAVE IT IN FCB
C4C6  39                         RTS
C4C7  68 E4             LC4C7    ASL   ,S                  ; SET FILE TYPE TO OUTPUT
C4C9  C1 4F                      CMPB  #'O'                ; FILE MODE = OUTPUT?
C4CB  26 1B                      BNE   LC4E8               ; BRANCH IF NOT

* OPEN A SEQUENTIAL FILE FOR OUTPUT
C4CD  7D 09 73                   TST   V973                ; DOES FILE EXIST ON DIRECTORY?
C4D0  27 0F                      BEQ   LC4E1               ; BRANCH IF NOT
C4D2  BD C6 FC                   JSR   LC6CF               ; KILL THE OLD FILE
C4D5  B6 09 73                   LDA   V973                ; * GET DIRECTORY SECTOR NUMBER OF OLD FILE AND
C4D8  B7 09 77                   STA   V977                ; * SAVE IT AS FIRST FREE DIRECTORY ENTRY
C4DB  BE 09 74                   LDX   V974                ; =GET RAM DIRECTORY IMAGE OF OLD FILE AND
C4DE  BF 09 78                   STX   V978                ; =SAVE IT AS FIRST FREE DIRECTORY ENTRY

C4E1  BD C5 67          LC4E1    JSR   LC567               ; SET UP NEW DIRECTORY ENTRY ON DISK
C4E4  8D 52                      BSR   LC538               ; INITIALIZE FILE BUFFER
C4E6  20 D3                      BRA   LC4BB               ; FLAG AND MAP FCB AS BEING USED
C4E8  C1 52             LC4E8    CMPB  #'R'                ; FILE MODE = R (RANDOM)?
C4EA  27 06                      BEQ   LC4F2               ; BRANCH IF SO
C4EC  C1 44                      CMPB  #'D'                ; FILE MODE = D (DIRECT)?
C4EE  10 26 E1 24                LBNE  LA616               ; 'BAD FILE MODE' ERROR IF NOT

* OPEN A RANDOM/DIRECT FILE
C4F2  68 E4             LC4F2    ASL   ,S                  ; SET FILE TYPE TO DIRECT
C4F4  FC 09 48                   LDD   RNBFAD              ; * GET ADDRESS OF RANDOM FILE BUFFER AREA
C4F7  34 06                      PSHS  B,A                 ; * AND SAVE IT ON THE STACK
C4F9  F3 09 7C                   ADDD  DFFLEN              ; ADD THE RECORD LENGTH
C4FC  25 06                      BLO   LC504               ; 'OB' ERROR IF SUM > $FFFF
C4FE  10 B3 09 4A                CMPD  FCBADR              ; IS IT > THAN FCB DATA AREA?
C502  23 05                      BLS   LC509               ; BRANCH IF NOT
C504  C6 3A             LC504    LDB   #2*29               ; 'OUT OF BUFFER SPACE' ERROR
C506  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER
C509  34 06             LC509    PSHS  B,A                 ; SAVE END OF RANDOM BUFFER ON STACK
C50B  7D 09 73                   TST   V973                ; DID THIS FILE EXIST
C50E  26 04                      BNE   LC514               ; BRANCH IF SO
C510  8D 55                      BSR   LC567               ; SET UP NEW FILE IN DIRECTORY
C512  20 05                      BRA   LC519               ; INITIALIZE FCB
C514  86 FF             LC514    LDA   #$FF                ; * SET FILE TYPE MATCH = $FF (ILLEGAL VALUE) -
C516  BD C8 07                   JSR   LC807               ; * THIS WILL FORCE ANY OPEN MATCHED FILE TO CAUSE
* * A 'FILE ALREADY OPEN' ERROR
C519  8D 12             LC519    BSR   LC52D               ; INITIALIZE FCB
C51B  63 0D                      COM   FCBSOF,X            ; * SET FCBSOF,X TO $FF (ILLEGAL SECTOR OFFSET) WHICH WILL
* * FORCE NEW SECTOR DATA TO BE READ IN DURING GET/PUT
C51D  6C 08                      INC   FCBREC+1,X          ; INITIALIZE RECORD NUMBER = 1
C51F  35 46                      PULS  A,B,U               ; U = START OF RANDOM FILE BUFFER AREA, ACCD = END
C521  FD 09 48                   STD   RNBFAD              ; SAVE NEW START OF RANDOM FILE BUFFER AREA
C524  EF 0B                      STU   FCBBUF,X            ; SAVE BUFFER START IN FCB
C526  FE 09 7C                   LDU   DFFLEN              ; * GET RANDOM FILE RECORD LENGTH
C529  EF 09                      STU   FCBRLN,X            ; * AND SAVE IT IN FCB
C52B  20 8E                      BRA   LC4BB               ; SET FAT FLAG, SAVE FILE TYPE IN FCB

* INITIALIZE FCB DATA FOR INPUT
C52D  8D 09             LC52D    BSR   LC538               ; INITIALIZE FCB
C52F  FE 09 74                   LDU   V974                ; GET RAM DIRECTORY IMAGE
C532  EE 4E                      LDU   DIRLIST,U           ; *GET NUMBER OF BYTES IN LAST SECTOR OF FILE
C534  EF 88 13                   STU   FCBLST,X            ; *SAVE IT IN FCB
C537  39                         RTS
* INITIALIZE FILE CONTROL BLOCK
C538  9E F1             LC538    LDX   FCBTMP              ; GET CURRENT FILE BUFFER
C53A  C6 19                      LDB   #FCBCON             ; CLEAR FCB CONTROL BYTES
C53C  6F 80             LC53C    CLR   ,X+                 ; CLEAR A BYTE
C53E  5A                         DECB                      ; DECREMENT COUNTER
C53F  26 FB                      BNE   LC53C               ; BRANCH IF NOT DONE
C541  9E F1                      LDX   FCBTMP              ; GET CURRENT FILE BUFFER ADDRESS BACK
C543  96 EB                      LDA   DCDRV               ; *GET CURRENT DRIVE NUMBER AND
C545  A7 01                      STA   FCBDRV,X            ; *SAVE IT IN FCB
C547  B6 09 76                   LDA   V976                ; =GET FIRST GRANULE -
C54A  A7 02                      STA   FCBFGR,X            ; =SAVE IT AS THE STARTING GRANULE NUMBER AND
C54C  A7 03                      STA   FCBCGR,X            ; =SAVE IT AS CURRENT GRANULE NUMBER
C54E  F6 09 73                   LDB   V973                ; GET DIRECTORY SECTOR NUMBER
C551  C0 03                      SUBB  #$03                ; SUBTRACT 3 - DIRECTORY SECTORS START AT 3
C553  58                         ASLB                      ; * MULTIPLY SECTORS
C554  58                         ASLB                      ; * BY 8 (8 DIRECTORY
C555  58                         ASLB                      ; * ENTRIES PER SECTOR)
C556  34 04                      PSHS  B                   ; SAVE SECTOR OFFSET
C558  FC 09 74                   LDD   V974                ; GET RAM DIRECTORY IMAGE
C55B  83 06 00                   SUBD  #DBUF0              ; SUBTRACT RAM OFFSET
C55E  86 08                      LDA   #$08                ; 8 DIRECTORY ENTRIES/SECTOR
C560  3D                         MUL                       ; NOW ACCA CONTAINS 0-7
C561  AB E0                      ADDA  ,S+                 ; ACCA CONTAINS DIRECTORY ENTRY (0-71)
C563  A7 88 12                   STA   FCBDIR,X            ; SAVE DIRECTORY ENTRY NUMBER
C566  39                         RTS

* SET UP DIRECTORY AND UPDATE FILE ALLOCATION TABLE ENTRY IN FIRST UNUSED SECTOR
C567  C6 38             LC567    LDB   #28*2               ; 'DISK FULL' ERROR
C569  B6 09 77                   LDA   V977                ; GET SECTOR NUMBER OF FIRST EMPTY DIRECTORY ENTRY
C56C  10 27 E6 D6                LBEQ  LAC46               ; 'DISK FULL' ERROR IF NO EMPTY DIRECTORY ENTRIES
C570  B7 09 73                   STA   V973                ; SAVE SECTOR NUMBER OF FIRST EMPTY DIRECTORY ENTRY
C573  97 ED                      STA   DSEC                ; SAVE SECTOR NUMBER IN DSKCON REGISTER
C575  C6 02                      LDB   #$02                ; READ OP CODE
C577  D7 EA                      STB   DCOPC               ; SAVE IN DSKCON REGISTER
C579  BD D6 F2                   JSR   LD6F2               ; READ SECTOR
C57C  BE 09 78                   LDX   V978                ; * GET ADDRESS OF RAM IMAGE OF UNUSED DIRECTORY
C57F  BF 09 74                   STX   V974                ; * ENTRY AND SAVE AS CURRENT USED RAM IMAGE
C582  33 84                      LEAU  ,X                  ; (TFR X,U) POINT U TO DIRECTORY RAM IMAGE
C584  C6 20                      LDB   #DIRLEN             ; SET COUNTER TO CLEAR 32 BYTES (DIRECTORY ENTRY)
C586  6F 80             LC586    CLR   ,X+                 ; CLEAR BYTE
C588  5A                         DECB                      ; DECREMENT COUNTER
C589  26 FB                      BNE   LC586               ; CONTINUE IF NOT DONE
C58B  8E 09 4C                   LDX   #DNAMBF             ; POINT TO FILENAME AND EXTENSION RAM IMAGE
C58E  C6 0B                      LDB   #11                 ; 11 BYTES IN FILENAME AND EXTENSION
C590  BD A5 9A                   JSR   LA59A               ; MOVE B BYTES FROM X TO U
C593  FC 09 57                   LDD   DFLTYP              ; GET FILE TYPE AND ASCII FLAG
C596  ED 40                      STD   $00,U               ; SAVE IN RAM IMAGE
C598  C6 21                      LDB   #33                 ; FIRST GRANULE TO CHECK
C59A  BD C7 BF                   JSR   LC7BF               ; FIND THE FIRST FREE GRANULE
C59D  B7 09 76                   STA   V976                ; SAVE IN RAM
C5A0  A7 42                      STA   $02,U               ; SAVE IN RAM IMAGE OF DIRECTORY TRACK
C5A2  C6 03                      LDB   #$03                ; * GET WRITE OPERATION CODE AND SAVE
C5A4  D7 EA                      STB   DCOPC               ; * IT IN DSKCON REGISTER
C5A6  BD D6 F2                   JSR   LD6F2               ; GO WRITE A SECTOR IN DIRECTORY
C5A9  34 56             LC5A9    PSHS  U,X,B,A             ; SAVE REGISTERS
C5AB  BD C7 55                   JSR   LC755               ; POINT X TO FILE ALLOCATION TABLE
C5AE  6C 01                      INC   FAT1,X              ; INDICATE NEW DATA IN FILE ALLOC TABLE
C5B0  A6 01                      LDA   FAT1,X              ; GET NEW DATA FLAG
C5B2  B1 09 7A                   CMPA  WFATVL              ; * HAVE ENOUGH GRANULES BEEN REMOVED FROM THE FAT TO
* * CAUSE THE FAT TO BE WRITTEN TO THE DISK
C5B5  25 03                      BLO   LC5BA               ; RETURN IF NO NEED TO WRITE OUT ALLOCATION TABLE
C5B7  BD C7 1E                   JSR   LC71E               ; WRITE FILE ALLOCATION SECTOR TO DISK
C5BA  35 D6             LC5BA    PULS  A,B,X,U,PC          ; RESTORE REGISTERS
