; Disk Extended Color BASIC 1.0 -- $C426-$C58E
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: DVEC0=$C426

* * BUFFER ADDRESS OFF STACK AND RETURN

* OPEN RAM HOOK
C426  32 62             DVEC0    LEAS  $02,S               ; PULL RETURN ADDRESS OFF OF THE STACK
C428  BD B1 56                   JSR   LB156               ; EVALUATE AN EXPRESSION
C42B  BD B6 A4                   JSR   LB6A4               ; *GET MODE(I,O,R) - FIRST BYTE OF STRING EXPRESSION
C42E  34 04                      PSHS  B                   ; *AND SAVE IT ON STACK
C430  BD A5 A2                   JSR   LA5A2               ; GET DEVICE NUMBER
C433  5D                         TSTB                      ; SET FLAGS
C434  10 2F E1 CB                LBLE  LA603               ; BRANCH IF NOT A DISK FILE
C438  35 02                      PULS  A                   ; GET MODE
C43A  34 06                      PSHS  B,A                 ; SAVE MODE AND DEVICE NUMBER (FILE NUMBER)
C43C  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
C43E  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
C441  8E C2 94                   LDX   #DATEXT             ; POINT TO 'DAT' FOR EXTENSION
C444  BD C8 8A                   JSR   LC88A               ; GET FILENAME FROM BASIC
C447  CC 01 FF                   LDD   #$01FF              ; DEFAULT DISK FILE TYPE AND ASCII FLAG
C44A  FD 09 57                   STD   DFLTYP              ; SAVE DEFAULT VALUES: DATA, ASCII
C44D  8E 01 00                   LDX   #SECLEN             ; DEFAULT RECORD LENGTH - 1 PAGE
C450  9D A5                      JSR   GETCCH              ; GET CHAR FROM BASIC
C452  27 08                      BEQ   LC45C               ; BRANCH IF END OF LINE
C454  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
C457  BD B3 E6                   JSR   LB3E6               ; EVALUATE EXPRESSION
C45A  9E 52                      LDX   FPA0+2              ; GET EVALUATED EXPRESSION
C45C  BF 09 7C          LC45C    STX   DFFLEN              ; RECORD LENGTH
C45F  10 27 EF E7                LBEQ  LB44A               ; IF = 0, THEN 'ILLEGAL FUNCTION CALL'
C463  BD A5 C7                   JSR   LA5C7               ; ERROR IF ANY FURTHER CHARACTERS ON LINE
C466  35 06                      PULS  A,B                 ; GET MODE AND FILE NUMBER

* OPEN DISK FILE FOR READ OR WRITE
C468  34 02             LC468    PSHS  A                   ; SAVE MODE ON STACK
C46A  BD C7 19                   JSR   LC719               ; POINT X TO FCB FOR THIS FILE
C46D  10 26 E1 AB                LBNE  LA61C               ; 'FILE ALREADY OPEN' ERROR IF FILE OPEN
C471  9F F1                      STX   FCBTMP              ; SAVE FILE BUFFER POINTER
C473  BD C7 6D                   JSR   LC76D               ; MAKE SURE FILE ALLOC TABLE IS VALID
C476  BD C6 5F                   JSR   LC65F               ; SCAN DIRECTORY FOR 'FILENAME.EXT'
C479  35 04                      PULS  B                   ; GET MODE
C47B  86 10                      LDA   #INPFIL             ; INPUT TYPE FILE
C47D  34 02                      PSHS  A                   ; SAVE FILE TYPE ON STACK
C47F  C1 49                      CMPB  #'I'                ; INPUT MODE?
C481  26 1F                      BNE   LC4A2               ; BRANCH IF NOT

* OPEN A SEQUENTIAL FILE FOR INPUT
C483  BD C6 B8                   JSR   LC6B8               ; CHECK TO SEE IF DIRECTORY MATCH IS FOUND
C486  BD C7 D7                   JSR   LC7D7               ; CHECK TO SEE IF FILE ALREADY OPEN
C489  BE 09 74                   LDX   V974                ; GET RAM DIRECTORY BUFFER
C48C  EC 0B                      LDD   DIRTYP,X            ; GET FILE TYPE AND ASCII FLAG
C48E  FD 09 57                   STD   DFLTYP              ; SAVE IN RAM IMAGE
C491  8D 6D                      BSR   LC500               ; INITIALIZE FILE BUFFER CONTROL BLOCK
C493  BD C5 FA                   JSR   LC5FA               ; GO FILL DATA BUFFER
C496  BD C7 25          LC496    JSR   LC725               ; POINT X TO PROPER FILE ALLOCATION TABLE
C499  6C 00                      INC   FAT0,X              ; ADD ONE TO FAT ACTIVE FILE COUNTER
C49B  9E F1                      LDX   FCBTMP              ; GET FILE BUFFER POINTER
C49D  35 02                      PULS  A                   ; GET FILE TYPE
C49F  A7 00                      STA   FCBTYP,X            ; SAVE IT IN FCB
C4A1  39                         RTS
C4A2  68 E4             LC4A2    ASL   ,S                  ; SET FILE TYPE TO OUTPUT
C4A4  C1 4F                      CMPB  #'O'                ; FILE MODE = OUTPUT?
C4A6  26 1A                      BNE   LC4C2               ; BRANCH IF NOT

* OPEN A SEQUENTIAL FILE FOR OUTPUT
C4A8  7D 09 73                   TST   V973                ; DOES FILE EXIST ON DIRECTORY?
C4AB  27 0F                      BEQ   LC4BC               ; BRANCH IF NOT
C4AD  BD C6 CF                   JSR   LC6CF               ; KILL THE OLD FILE
C4B0  B6 09 73                   LDA   V973                ; * GET DIRECTORY SECTOR NUMBER OF OLD FILE AND
C4B3  B7 09 77                   STA   V977                ; * SAVE IT AS FIRST FREE DIRECTORY ENTRY
C4B6  BE 09 74                   LDX   V974                ; =GET RAM DIRECTORY IMAGE OF OLD FILE AND
C4B9  BF 09 78                   STX   V978                ; =SAVE IT AS FIRST FREE DIRECTORY ENTRY

C4BC  8D 7C             LC4BC    BSR   LC53A               ; SET UP NEW DIRECTORY ENTRY ON DISK
C4BE  8D 4B                      BSR   LC50B               ; INITIALIZE FILE BUFFER
C4C0  20 D4                      BRA   LC496               ; FLAG AND MAP FCB AS BEING USED
C4C2  C1 52             LC4C2    CMPB  #'R'                ; FILE MODE = R (RANDOM)?
C4C4  27 06                      BEQ   LC4CC               ; BRANCH IF SO
C4C6  C1 44                      CMPB  #'D'                ; FILE MODE = D (DIRECT)?
C4C8  10 26 E1 4A                LBNE  LA616               ; 'BAD FILE MODE' ERROR IF NOT

* OPEN A RANDOM/DIRECT FILE
C4CC  68 E4             LC4CC    ASL   ,S                  ; SET FILE TYPE TO DIRECT
C4CE  FC 09 48                   LDD   RNBFAD              ; * GET ADDRESS OF RANDOM FILE BUFFER AREA
C4D1  34 06                      PSHS  B,A                 ; * AND SAVE IT ON THE STACK
C4D3  F3 09 7C                   ADDD  DFFLEN              ; ADD THE RECORD LENGTH
C4D6  25 06                      BLO   LC4DE               ; 'OB' ERROR IF SUM > $FFFF
C4D8  10 B3 09 4A                CMPD  FCBADR              ; IS IT > THAN FCB DATA AREA?
C4DC  23 05                      BLS   LC4E3               ; BRANCH IF NOT
C4DE  C6 3A             LC4DE    LDB   #2*29               ; 'OUT OF BUFFER SPACE' ERROR
C4E0  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER
C4E3  34 06             LC4E3    PSHS  B,A                 ; SAVE END OF RANDOM BUFFER ON STACK
C4E5  7D 09 73                   TST   V973                ; DID THIS FILE EXIST
C4E8  26 02                      BNE   LC4EC               ; BRANCH IF SO
C4EA  8D 4E                      BSR   LC53A               ; SET UP NEW FILE IN DIRECTORY
C4EC  8D 12             LC4EC    BSR   LC500               ; INITIALIZE FILE BUFFER
C4EE  63 0D                      COM   FCBSOF,X            ; * SET FCBSOF,X TO $FF (ILLEGAL SECTOR OFFSET) WHICH WILL
* * FORCE NEW SECTOR DATA TO BE READ IN DURING GET/PUT
C4F0  6C 08                      INC   FCBREC+1,X          ; INITIALIZE RECORD NUMBER = 1
C4F2  35 46                      PULS  A,B,U               ; U = START OF RANDOM FILE BUFFER AREA, ACCD = END
C4F4  FD 09 48                   STD   RNBFAD              ; SAVE NEW START OF RANDOM FILE BUFFER AREA
C4F7  EF 0B                      STU   FCBBUF,X            ; SAVE BUFFER START IN FCB
C4F9  FE 09 7C                   LDU   DFFLEN              ; * GET RANDOM FILE RECORD LENGTH
C4FC  EF 09                      STU   FCBRLN,X            ; * AND SAVE IT IN FCB
C4FE  20 96                      BRA   LC496               ; SET FAT FLAG, SAVE FILE TYPE IN FCB

* INITIALIZE FCB DATA FOR INPUT
C500  8D 09             LC500    BSR   LC50B               ; INITIALIZE FCB
C502  FE 09 74                   LDU   V974                ; GET RAM DIRECTORY IMAGE
C505  EE 4E                      LDU   DIRLST,U            ; *GET NUMBER OF BYTES IN LAST SECTOR OF FILE
C507  EF 88 13                   STU   FCBLST,X            ; *SAVE IT IN FCB
C50A  39                         RTS
* INITIALIZE FILE CONTROL BLOCK
C50B  9E F1             LC50B    LDX   FCBTMP              ; GET CURRENT FILE BUFFER
C50D  C6 19                      LDB   #FCBCON             ; CLEAR FCB CONTROL BYTES
C50F  6F 80             LC50F    CLR   ,X+                 ; CLEAR A BYTE
C511  5A                         DECB                      ; DECREMENT COUNTER
C512  26 FB                      BNE   LC50F               ; BRANCH IF NOT DONE
C514  9E F1                      LDX   FCBTMP              ; GET CURRENT FILE BUFFER ADDRESS BACK
C516  96 EB                      LDA   DCDRV               ; *GET CURRENT DRIVE NUMBER AND
C518  A7 01                      STA   FCBDRV,X            ; *SAVE IT IN FCB
C51A  B6 09 76                   LDA   V976                ; =GET FIRST GRANULE -
C51D  A7 02                      STA   FCBFGR,X            ; =SAVE IT AS THE STARTING GRANULE NUMBER AND
C51F  A7 03                      STA   FCBCGR,X            ; =SAVE IT AS CURRENT GRANULE NUMBER
C521  F6 09 73                   LDB   V973                ; GET DIRECTORY SECTOR NUMBER
C524  C0 03                      SUBB  #$03                ; SUBTRACT 3 - DIRECTORY SECTORS START AT 3
C526  58                         ASLB                      ; * MULTIPLY SECTORS
C527  58                         ASLB                      ; * BY 8 (8 DIRECTORY
C528  58                         ASLB                      ; * ENTRIES PER SECTOR)
C529  34 04                      PSHS  B                   ; SAVE SECTOR OFFSET
C52B  FC 09 74                   LDD   V974                ; GET RAM DIRECTORY IMAGE
C52E  83 06 00                   SUBD  #DBUF0              ; SUBTRACT RAM OFFSET
C531  86 08                      LDA   #$08                ; 8 DIRECTORY ENTRIES/SECTOR
C533  3D                         MUL                       ; NOW ACCA CONTAINS 0-7
C534  AB E0                      ADDA  ,S+                 ; ACCA CONTAINS DIRECTORY ENTRY (0-71)
C536  A7 88 12                   STA   FCBDIR,X            ; SAVE DIRECTORY ENTRY NUMBER
C539  39                         RTS

* SET UP DIRECTORY AND UPDATE FILE ALLOCATION TABLE ENTRY IN FIRST UNUSED SECTOR
C53A  C6 38                      LDB   #28*2               ; 'DISK FULL' ERROR
C53C  B6 09 77                   LDA   V977                ; GET SECTOR NUMBER OF FIRST EMPTY DIRECTORY ENTRY
C53F  10 27 E7 03                LBEQ  LAC46               ; 'DISK FULL' ERROR IF NO EMPTY DIRECTORY ENTRIES
C543  B7 09 73                   STA   V973                ; SAVE SECTOR NUMBER OF FIRST EMPTY DIRECTORY ENTRY
C546  97 ED                      STA   DSEC                ; SAVE SECTOR NUMBER IN DSKCON REGISTER
C548  C6 02                      LDB   #$02                ; READ OP CODE
C54A  D7 EA                      STB   DCOPC               ; SAVE IN DSKCON REGISTER
C54C  BD D5 FF                   JSR   LD5FF               ; READ SECTOR
C54F  BE 09 78                   LDX   V978                ; * GET ADDRESS OF RAM IMAGE OF UNUSED DIRECTORY
C552  BF 09 74                   STX   V974                ; * ENTRY AND SAVE AS CURRENT USED RAM IMAGE
C555  33 84                      LEAU  ,X                  ; (TFR X,U) POINT U TO DIRECTORY RAM IMAGE
C557  C6 20                      LDB   #DIRLEN             ; SET COUNTER TO CLEAR 32 BYTES (DIRECTORY ENTRY)
C559  6F 80             LC559    CLR   ,X+                 ; CLEAR BYTE
C55B  5A                         DECB                      ; DECREMENT COUNTER
C55C  26 FB                      BNE   LC559               ; CONTINUE IF NOT DONE
C55E  8E 09 4C                   LDX   #DNAMBF             ; POINT TO FILENAME AND EXTENSION RAM IMAGE
C561  C6 0B                      LDB   #11                 ; 11 BYTES IN FILENAME AND EXTENSION
C563  BD A5 9A                   JSR   LA59A               ; MOVE B BYTES FROM X TO U
C566  FC 09 57                   LDD   DFLTYP              ; GET FILE TYPE AND ASCII FLAG
C569  ED 40                      STD   ,U                  ; SAVE IN RAM IMAGE
C56B  C6 21                      LDB   #33                 ; FIRST GRANULE TO CHECK
C56D  BD C7 8F                   JSR   LC78F               ; FIND THE FIRST FREE GRANULE
C570  B7 09 76                   STA   V976                ; SAVE IN RAM
C573  A7 42                      STA   $02,U               ; SAVE IN RAM IMAGE OF DIRECTORY TRACK
C575  C6 03                      LDB   #$03                ; * GET WRITE OPERATION CODE AND SAVE
C577  D7 EA                      STB   DCOPC               ; * IT IN DSKCON REGISTER
C579  BD D5 FF                   JSR   LD5FF               ; GO WRITE A SECTOR IN DIRECTORY
C57C  34 56             LC57C    PSHS  U,X,B,A             ; SAVE REGISTERS
C57E  BD C7 25                   JSR   LC725               ; POINT X TO FILE ALLOCATION TABLE
C581  6C 01                      INC   FAT1,X              ; INDICATE NEW DATA IN FILE ALLOC TABLE
C583  A6 01                      LDA   FAT1,X              ; GET NEW DATA FLAG
C585  B1 09 7A                   CMPA  WFATVL              ; * HAVE ENOUGH GRANULES BEEN REMOVED FROM THE FAT TO
* * CAUSE THE FAT TO BE WRITTEN TO THE DISK
C588  25 03                      BLO   LC58D               ; RETURN IF NO NEED TO WRITE OUT ALLOCATION TABLE
C58A  BD C6 F1                   JSR   LC6F1               ; WRITE FILE ALLOCATION SECTOR TO DISK
C58D  35 D6             LC58D    PULS  A,B,X,U,PC          ; RESTORE REGISTERS
