; Disk Extended Color BASIC 1.0 -- $D2CC-$D473
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: COPY=$D2CC, DSKI=$D3FF

* COPY
* THE COPY PROCESS IS PERFORMED BY COPYING DATA FROM THE SOURCE FILE
* TO RAM AND THEN COPYING IT TO THE DESTINATION FILE. THE SOURCE AND
* DESTINATION FILES ARE OPENED AS RANDOM FILES AND BOTH USE THE SYSTEM
* FCB ABOVE THE RESERVED FCBS. ALL OF AVAILABLE FREE RAM ABOVE THE
* VARIABLES IS USED AS A COPY BUFFER WHICH SPEEDS UP THE COPYING PROCESS
* BUT UNFORTUNATELY THE METHOD USED WILL ALLOW AN ERROR ENCOUNTERED DURING
* THE COPY PROCESS TO 'HANG' THE SYSTEM. THIS IS CAUSED BY POINTING THE FCB'S
* RANDOM FILE BUFFER POINTER (FCBBUF,X) TO THE FREE RAM BUFFER. AN ERROR
* WILL THEN CAUSE THE OPEN FILE TO BE CLOSED WITH FCBBUF,X POINTING TO AN
* AREA IN RAM WHERE THE RANDOM FILE BUFFER CLOSE ROUTINE (LCAE2) WILL NEVER
* LOOK FOR IT
D2CC  BD C8 87          COPY     JSR   LC887               ; * GET SOURCE FILENAME.EXT & DRIVE NUMBER FROM BASIC
D2CF  8D DB                      BSR   LD2AC               ; * AND SAVE THEM ON THE STACK
D2D1  6F E2                      CLR   ,-S                 ; CLEAR A BYTE ON STACK - SINGLE DISK COPY (SDC) FLAG
D2D3  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
D2D5  27 0A                      BEQ   LD2E1               ; BRANCH IF END OF LINE - SINGLE DISK COPY
D2D7  63 E4                      COM   ,S                  ; SET SOC FLAG TO $FF (NO SINGLE DISK COPY)
D2D9  C6 A5                      LDB   #$A5                ; TOKEN FOR 'TO'
D2DB  BD B2 6F                   JSR   LB26F               ; SYNTAX CHECK FOR 'TO'
D2DE  BD C8 87                   JSR   LC887               ; GET DESTINATION FILENAME.EXT AND DRIVE NUMBER
D2E1  8D C9             LD2E1    BSR   LD2AC               ; SAVE DESTINATION FILENAME.EXT & DRIVE NUMBER ON STACK
D2E3  BD A5 C7                   JSR   LA5C7               ; SYNTAX ERROR IF MORE CHARACTERS ON LINE
D2E6  BD CA 3B                   JSR   DVEC7               ; CLOSE ALL FILES

* COUNT THE NUMBER OF SECTORS WORTH OF FREE RAM AVAILABLE
D2E9  6F E2                      CLR   ,-S                 ; CLEAR A SECTOR COUNTER ON THE STACK
D2EB  30 E8 9C                   LEAX  -100,S              ; ** BUG ** THIS SHOULD BE $100 TO POINT X ONE SECTOR LENGTH BELOW STACK
D2EE  6C E4             LD2EE    INC   ,S                  ; INCREMENT SECTOR COUNTER
D2F0  30 89 FF 00                LEAX  -SECLEN,X           ; DECREMENT X BY ONE SECTOR
D2F4  9C 1F                      CMPX  ARYEND              ; COMPARE TO TOP OF ARRAYS
D2F6  24 F6                      BHS   LD2EE               ; BRANCH IF NOT AT BOTTOM OF FREE RAM
D2F8  6A E4                      DEC   ,S                  ; DECREMENT SECTOR COUNTER
D2FA  10 27 D9 46                LBEQ  LAC44               ; 'OM' ERROR IF NOT AT LEAST ONE FULL SECTOR OF FREE RAM
D2FE  30 6E                      LEAX  14,S                ; POINT X TO START OF SOURCE DATA
D300  8D BE                      BSR   LD2C0               ; PUT SOURCE DATA INTO DNAMBF AND DSKCON
D302  BD C6 5F                   JSR   LC65F               ; SCAN DIRECTORY FOR A MATCH
D305  BD C6 B8                   JSR   LC6B8               ; 'NE' ERROR IF MATCH NOT FOUND
D308  BE 09 74                   LDX   V974                ; POINT X TO DIRECTORY RAM IMAGE OF FOUND FILE
D30B  EE 0E                      LDU   DIRLST,X            ; * GET NUMBER OF BYTES IN LAST SECTOR AND
D30D  AE 0B                      LDX   DIRTYP,X            ; * SOURCE FILE TYPE AND ASCII FLAG
D30F  34 50                      PSHS  U,X                 ; * AND SAVE THEM ON THE STACK
D311  BD C7 6D                   JSR   LC76D               ; GET VALID FAT DATA
D314  F6 09 76                   LDB   V976                ; GET NUMBER OF FIRST GRANULE IN FILE
D317  BD CC 44                   JSR   LCC44               ; * GET THE NUMBER OF GRANULES IN FILE
D31A  34 02                      PSHS  A                   ; * AND SAVE IT ON THE STACK
D31C  4A                         DECA                      ; SUBTRACT OFF THE LAST GRANULE
D31D  C4 3F                      ANDB  #$3F                ; * MASK OFF LAST GRANULE FLAG BITS AND SAVE THE
D31F  34 04                      PSHS  B                   ; * NUMBER OF SECTORS IN LAST GRANULE ON STACK
D321  1F 89                      TFR   A,B                 ; SAVE THE NUMBER OF GRANULES IN ACCB
D323  4F                         CLRA                      ; CLEAR THE MS BYTE OF ACCD
D324  BD C7 49                   JSR   LC749               ; MULTIPLY ACCD BY NINE
D327  EB E4                      ADDB  ,S                  ; * ADD THE NUMBER OF SECTORS IN THE LAST
D329  89 00                      ADCA  #$00                ; * GRANULE TO ACCD
D32B  8E 00 01                   LDX   #$0001              ; INITIALIZE RECORD COUNTER TO ONE
D32E  34 16                      PSHS  X,B,A               ; INITIALIZE SECTOR AND RECORD COUNTERS ON THE STACK

* AT THIS POINT THE CONTROL VARIABLES FOR COPY ARE STORED ON THE STACK.
*   0 1,S = REMAINING SECTORS COUNTER; 2 3,S = RECORD COUNTER
*     4,S = NUMBER OF SECTORS TO BE COPIED. INITIALLY SET TO NUMBER OF
*           SECTORS IN THE LAST GRANULE.
*     5,S = GRAN TEST FLAG. INITIALLY SET TO NUMBER OF GRANS IN FILE
*     6,S = FILE TYPE; 7,S = ASCII FLAG; 8 9,S = NUMBER OF BYTES IN LAST SECTOR
*    10,S = NUMBER OF SECTORS WHICH WILL FIT IN THE CURRENTLY AVAILABLE FREE RAM
* 11-22,S = DESTINATION FILENAME.EXT AND DRIVE NUMBER
*    23,S = SINGLE DISK COPY FLAG; 24-35,S = SOURCE FILENAME.EXT AND DRIVE NUMBER
D330  5F                LD330    CLRB                      ; SET SECTOR COUNTER TO ZERO
D331  AE E4                      LDX   ,S                  ; GET THE NUMBER OF SECTORS REMAINING IN THE FILE
D333  27 09                      BEQ   LD33E               ; BRANCH IF NO SECTORS LEFT
D335  5C                LD335    INCB                      ; ADD A SECTOR TO TEMPORARY SECTOR COUNTER
D336  30 1F                      LEAX  -1,X                ; DECREMENT REMAINING SECTORS COUNTER
D338  27 04                      BEQ   LD33E               ; BRANCH IF NO SECTORS LEFT
D33A  E1 6A                      CMPB  10,S                ; *COMPARE TEMPORARY COUNTER TO NUMBER OF SECTORS WHICH MAY
* *BE STORED IN FREE RAM
D33C  26 F7                      BNE   LD335               ; BRANCH IF STILL ROOM FOR MORE SECTORS
D33E  AF E4             LD33E    STX   ,S                  ; SAVE THE NUMBER OF UNCOPIED SECTORS REMAINING IN THE FILE
D340  E7 64                      STB   $04,S               ; SAVE THE NUMBER OF SECTORS TO BE COPIED THIS TIME THROUGH LOOP
D342  8D 50                      BSR   $D394               ; 'GET' ACCB SECTORS TO RAM BUFFER
D344  86 FF                      LDA   #$FF                ; SET SOURCE/DESTINATION FLAG TO DESTINATION
D346  8D 40                      BSR   LD388               ; PRINT PROMPT MESSAGE IF REQUIRED
D348  6D 65                      TST   $05,S               ; * CHECK THE GRAN TEST FLAG. IF <> 0, IT CONTAINS THE
D34A  27 25                      BEQ   LD371               ; * NUMBER OF GRANS IN THE FILE AND THE DESTINATION DISK
* * MUST BE CHECKED FOR ENOUGH ROOM. IF IT IS = 0
* * THEN THE CHECK HAS ALREADY BEEN DONE
D34C  30 6B                      LEAX  11,S                ; POINT TO DESTINATION FILE PARAMETERS
D34E  BD D2 C0                   JSR   LD2C0               ; GET DESTINATION FILE PARAMETERS FROM STACK
D351  BD CF 7D                   JSR   LCF7D               ; SCAN DIRECTORY FOR FILE - 'AE' ERROR IF IT EXISTS
D354  BD C7 6D                   JSR   LC76D               ; GET VALID FAT DATA

* MAKE SURE THERE ARE ENOUGH FREE GRANULES ON THE DESTINATION DISK
D357  BD C7 25                   JSR   LC725               ; POINT X TO FAT
D35A  30 06                      LEAX  FATCON,X            ; SKIP PAST THE FAT CONTROL BYTES
D35C  A6 65                      LDA   $05,S               ; GET THE NUMBER OF GRANS IN THE FILE
D35E  C6 44                      LDB   #GRANMX             ; SET GRAN COUNTER TO MAXIMUM
D360  63 84             LD360    COM   ,X                  ; * CHECK TO SEE IF A BRAN IS FREE
D362  26 03                      BNE   LD367               ; * AND BRANCH IF IT IS NOT FREE
D364  4A                         DECA                      ; = DECREMENT COUNTER AND BRANCH IF
D365  27 08                      BEQ   LD36F               ; = THERE ARE ENOUGH FREE GRANULES
D367  63 80             LD367    COM   ,X+                 ; RESTORE FAT BYTE AND INCREMENT POINTER
D369  5A                         DECB                      ; DECREMENT GRAN COUNTER
D36A  26 F4                      BNE   LD360               ; BRANCH IF ALL GRANS NOT CHECKED
D36C  7E C7 C8                   JMP   LC7C8               ; 'DISK FULL' ERROR
D36F  63 84             LD36F    COM   ,X                  ; RESTORE FAT BYTE
D371  8D 1B             LD371    BSR   LD38E               ; 'PUT' DATA FROM RAM BUFFER TO DESTINATION FILE
D373  AE E4                      LDX   ,S                  ; GET THE NUMBER OF REMAINING SECTORS
D375  27 0D                      BEQ   LD384               ; EXIT ROUTINE IF NO SECTORS LEFT
D377  EC 62                      LDD   $02,S               ; *
D379  EB 64                      ADDB  $04,S               ; * GET THE CURRENT RECORD COUNTER, ADD
D37B  89 00                      ADCA  #$00                ; * THE NUMBER OF SECTORS (RECORDS) MOVED
D37D  ED 62                      STD   $02,S               ; * AND SAVE THE NEW RECORD COUNTER
D37F  4F                         CLRA                      ; SET SOURCE/DESTINATION FLAG TO SOURCE
D380  8D 06                      BSR   LD388               ; PRINT PROMPT MESSAGE IF REQUIRED
D382  20 AC                      BRA   LD330               ; KEEP COPYING SECTORS

D384  32 E8 24          LD384    LEAS  36,S                ; REMOVE TEMPORARY STORAGE VARIABLES FROM STACK
D387  39                         RTS                       ; **** COPY DONE ****

D388  6D E8 19          LD388    TST   25,S                ; *CHECK SINGLE DISK COPY FLAG - IF <> ZERO, THEN DON'T
* *PRINT THE PROMPT MESSAGE
D38B  7E D2 39                   JMP   LD239               ; PRINT THE PROMPT MESSAGE IF REQUIRED
D38E  86 FF             LD38E    LDA   #$FF

* 'PUT'.'GET' DATA FROM THE DESTINATION/SOURCE FILES 'PUT' FLAG
D390  30 6D                      LEAX  13,S                ; POINT X TO DESTINATION FILENAME DATA
D392  20 04                      BRA   LD398               ; GO 'PUT' SOME DATA
D394  4F                LD394    CLRA                      ; ZERO IS THE 'GET' FLAG
D395  30 E8 1A                   LEAX  26,S                ; POINT X TO THE SOURCE FILENAME DATA
D398  97 D8             LD398    STA   VD8                 ; SAVE THE 'GET'/'PUT' FLAG
D39A  BD D2 C0                   JSR   LD2C0               ; GET FILENAME AND DRIVE DATA FROM THE STACK
D39D  AE 68                      LDX   8,S                 ; * GET ASCII FLAG AND FILE TYPE AND SAVE
D39F  BF 09 57                   STX   DFLTYP              ; * THEM IN THE DISK RAM VARIABLES
D3A2  8E 01 00                   LDX   #SECLEN             ; = SAVE ONE SECTOR LENGTH IN
D3A5  BF 09 7C                   STX   DFFLEN              ; = RAM RECORD LENGTH VARIABLE
D3A8  86 52                      LDA   #'R'                ; RANDOM FILE TYPE FLAG
D3AA  F6 09 5B                   LDB   FCBACT              ; * GET THE HIGHEST RESERVED FCB NUMBER, ADD ONE
D3AD  5C                         INCB                      ; * AND OPEN A RANDOM FILE WHOSE FCB WILL BE ONE ABOVE
D3AE  BD C4 68                   JSR   LC468               ; * THE HIGHEST RESERVED FCB (THE SYSTEM FCB)
D3B1  9E F1                      LDX   FCBTMP              ; POINT X TO THE 'SYSTEM' FCB
D3B3  CC 01 00                   LDD   #SECLEN             ; * SET THE NUMBER OF BYTES IN THE LAST SECTOR
D3B6  ED 88 13                   STD   FCBLST,X            ; * OF THE FILE EQUAL TO ONE SECTOR LENGTH
D3B9  E6 66                      LDB   $06,S               ; =GET THE NUMBER OF SECTORS TO MOVE AND
D3BB  27 29                      BEQ   LD3E6               ; =BRANCH IF NONE LEFT
D3BD  D6 D8                      LDB   VD8                 ; *GRAB THE 'GET'/'PUT' FLAG, 'AND' IT WITH THE
D3BF  E4 67                      ANDB  $07,S               ; *GRAN TEST FLAG - BRANCH IF 'GET'ING DATA OR THIS IS
D3C1  27 09                      BEQ   LD3CC               ; *NOT THE FIRST TIME THROUGH THE LOOP
D3C3  EC 62                      LDD   $02,S               ; =GET THE NUMBER OF SECTORS REMAINING TO BE COPIED AND
D3C5  EB 66                      ADDB  $06,S               ; =ADD THE NUMBER TO BE COPIED THIS TIME THROUGH LOOP
D3C7  89 00                      ADCA  #$00                ; =
D3C9  BD C2 CC                   JSR   LC2CC               ; *'PUT' THE LAST RECORD IN THE FILE TO THE SYSTEM FCB.
D3CC  9E F1             LD3CC    LDX   FCBTMP              ; *THE RECORD NUMBER IS IN ACCD.
* POINT X TO THE SYSTEM FCB
D3CE  EE 64                      LDU   $04,S               ; * GET THE CURRENT RECORD NUMBER
D3D0  EF 07                      STU   FCBREC,X            ; * AND SAVE IT IN THE FCB
D3D2  E6 66                      LDB   $06,S               ; GET THE NUMBER OF THE RECORD (SECTOR) TO MOVE
D3D4  DE 1F                      LDU   ARYEND              ; END OF ARRAYS IS THE START OF THE COPY FREE RAM BUFFER
D3D6  34 44             LD3D6    PSHS  U,B                 ; SAVE SECTOR COUNTER AND BUFFER POINTER ON THE STACK
D3D8  9E F1                      LDX   FCBTMP              ; POINT X TO SYSTEM FCB
D3DA  EF 0B                      STU   FCBBUF,X            ; *SET THE RANDOM FILE BUFFER POINTER TO THE 'COPY' RAM BUFFER
D3DC  BD C2 D0                   JSR   LC2D0               ; *THIS WILL CAUSE THE SYSTEM TO 'HANG' IF AN ERROR OCCURS DURING COPY.
* GO 'GET' OR 'PUT' DATA TO THE SYSTEM FCB
D3DF  6C 61                      INC   $01,S               ; ADD 256 (ONE SECTOR) TO THE BUFFER POINTER
D3E1  35 44                      PULS  B,U                 ; GET THE SECTOR COUNTER AND BUFFER POINER
D3E3  5A                         DECB                      ; DECREMENT SECTOR COUNTER
D3E4  26 F0                      BNE   LD3D6               ; BRANCH IF ALL SECTORS NOT DONE
D3E6  9E F1             LD3E6    LDX   FCBTMP              ; POINT X TO SYSTEM FCB
D3E8  CE 09 89                   LDU   #DFLBUF             ; * RESET THE RANDOM FILE BUFFER POINTER FOR THE SYSTEM
D3EB  EF 0B                      STU   FCBBUF,X            ; * FCB TO THE BOTTOM OF RANDOM FILE BUFFER AREA
D3ED  D6 D8                      LDB   VD8                 ; =GRAB THE 'GET'/'PUT' FLAG, 'AND' IT WITH THE GRAN
D3EF  E4 67                      ANDB  $07,S               ; =TEST FLAG - CLOSE THE FILE IF 'GET'ING DATA AND
D3F1  27 09                      BEQ   LD3FC               ; =THIS IS NOT THE FIRST TIME THROUGH THE LOOP
D3F3  6F 67                      CLR   $07,S               ; RESET THE GRAN TEST FLAG IF FIRST TIME THROUGH LOOP
D3F5  EC 6A                      LDD   10,S                ; *GET THE NUMBER OF BYTES IN THE LAST SECTOR,
D3F7  8A 80                      ORA   #$80                ; *'OR' IN THE PRE-SAVED FLAG AND
D3F9  ED 88 13                   STD   FCBLST,X            ; *SAVE THE NUMBER OF BYTES IN THE LAST SECTOR IN THE FCB
D3FC  7E CA 58          LD3FC    JMP   LCA58               ; CLOSE THE FILE

* DSKI$ COMMAND
D3FF  8D 38             DSKI     BSR   LD439               ; GET THE DRIVE, TRACK AND SECTOR NUMBERS
D401  8D 2B                      BSR   LD42E               ; * EVALUATE STRING VARIABLE 1 AND SAVE
D403  34 10                      PSHS  X                   ; * THE DESCRIPTOR ADDRESS ON THE STACK
D405  8D 27                      BSR   LD42E               ; = EVALUATE STRING VARIABLE 2 AND SAVE
D407  34 10                      PSHS  X                   ; = THE DESCRiPTOR ADDRESS ON THE STACK
D409  C6 02                      LDB   #$02                ; DSKCON READ OP CODE
D40B  BD D4 A1                   JSR   LD4A1               ; REAO A SECTOR INTO DBUF0
D40E  CE 06 80                   LDU   #DBUF0+128          ; POINT U TO TOP HALF OF DBUF0
D411  35 10                      PULS  X                   ; GET STRING 2 DESCRIPTOR ADDRESS
D413  8D 05                      BSR   LD41A               ; PUT STRING 2 INTO STRING SPACE
D415  CE 06 00                   LDU   #DBUF0              ; POINT U TO BOTTOM HALF OF DBUF0
D418  35 10                      PULS  X                   ; GET STRING 1 DESCRIPTOR ADDRESS
D41A  34 50             LD41A    PSHS  U,X                 ; PUT STRING DESCRIPTOR & SOURCE POINTER ON THE STACK
D41C  C6 80                      LDB   #128                ; *
D41E  BD B5 0F                   JSR   LB50F               ; * RESERVE 128 BYTES IN STRING SPACE
D421  33 84                      LEAU  ,X                  ; POINT U TO RESERVED STRING SPACE
D423  35 10                      PULS  X                   ; GET STRING DESCRIPTOR ADDRESS
D425  E7 84                      STB   ,X                  ; * SAVE DESCRIPTOR DATA (LENGTH AND ADDRESS)
D427  EF 02                      STU   $02,X               ; * OF THE NEW STRING
D429  35 10                      PULS  X                   ; GET THE SOURCE (DBUF0) POINTER
D42B  7E A5 9A          LD42B    JMP   LA59A               ; MOVE SECTOR DATA FROM DBUF0 TO STRING SPACE

D42E  BD B2 6D          LD42E    JSR   SYNCOMMA            ; SYNTAX CHECK FOR A COMMA
D431  8E B3 57                   LDX   #LB357              ; POINT X TO EVALUATE VARIABLE ROUTINE
D434  8D 2F                      BSR   LD465               ; EVALUATE A VARIABLE
D436  7E B1 46          LD436    JMP   LB146               ; 'TM' ERROR IF NUMERIC VARIABLE

* EVALUATE DRIVE, TRACK AND SECTOR NUMBERS
D439  BD B7 0B          LD439    JSR   EVALEXPB            ; EVALUATE EXPRESSION, RETURN VALUE IN ACCB
D43C  C1 03                      CMPB  #$03                ; * COMPARE TO 3 (HIGHEST DRIVE NUMBER) -
D43E  22 1C                      BHI   LD45C               ; * 'FC' ERROR IF IT'S > 3
D440  34 04                      PSHS  B                   ; SAVE DRIVE NUMBER ON THE STACK
D442  BD B7 38                   JSR   LB738               ; SYNTAX CHECK FOR COMMA. EVALUATE EXPRESSION (TRACK NUMBER)
D445  C1 22                      CMPB  #TRKMAX-1           ; * CHECK FOR MAXIMUM TRACK NUMBER
D447  22 13                      BHI   LD45C               ; * 'FC' ERROR IF TRACK NUMBER > 34
D449  34 04                      PSHS  B                   ; SAVE TRACK NUMBER ON THE STACK
D44B  BD B7 38                   JSR   LB738               ; SYNTAX CHECK FOR COMMA, EVALUATE EXPRESSION (SECTOR NUMBER)
D44E  D7 ED                      STB   DSEC                ; SAVE SECTOR NUMBER IN DSKCON VARIABLE
D450  5A                         DECB                      ; *USELESS INSTRUCTION. NEXT INSTRUCTION SHOULD JUST
D451  C1 11                      CMPB  #SECMAX-1           ; *CHECK FOR MAXIMUM SECTOR NUMBER (SECMAX)
D453  22 07                      BHI   LD45C               ; 'FC' ERROR IF SECTOR NUMBER TOO BIG
D455  35 06                      PULS  A,B                 ; * GET TRACK AND DRIVE NUMBER OFF OF
D457  97 EC                      STA   DCTRK               ; * THE STACK AND SAVE IN DSKCON
D459  D7 EB                      STB   DCDRV               ; * VARIABLES
D45B  39                         RTS
D45C  7E B4 4A          LD45C    JMP   LB44A               ; JUMP TO 'FC' ERROR

D45F  BD B2 6D          LD45F    JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
D462  8E B1 56                   LDX   #LB156              ; POINT X TO 'EVALUATE EXPRESSION' ROUTINE ADDRESS
D465  D6 EB             LD465    LDB   DCDRV               ; * GET THE DSKCON DRIVE, TRACK AND
D467  DE EC                      LDU   DCTRK               ; * SECTOR VALUES AND SAVE THEM ON THE STACK
D469  34 44                      PSHS  U,B                 ; *
D46B  AD 84                      JSR   ,X                  ; GO EVALUATE AN EXPRESSION OR A VARIABLE
D46D  35 44                      PULS  B,U                 ; * GET THE DRIVE, TRACK AND SECTOR
D46F  D7 EB                      STB   DCDRV               ; * NUMBERS OFF OF THE STACK AND PUT
D471  DF EC                      STU   DCTRK               ; * THEM BACK INTO THE DSKCON VARIABLES
D473  39                         RTS
