; Disk Extended Color BASIC 1.1 -- $D3B9-$D561
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: COPY=$D3B9, DSKI=$D4ED

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
D3B9  BD C9 35          COPY     JSR   LC935               ; * GET SOURCE FILENAME.EXT & DRIVE NUMBER FROM BASIC
D3BC  8D DB                      BSR   LD399               ; * AND SAVE THEM ON THE STACK
D3BE  6F E2                      CLR   ,-S                 ; CLEAR A BYTE ON STACK - SINGLE DISK COPY (SDC) FLAG
D3C0  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
D3C2  27 0A                      BEQ   LD3CE               ; BRANCH IF END OF LINE - SINGLE DISK COPY
D3C4  63 E4                      COM   ,S                  ; SET SOC FLAG TO $FF (NO SINGLE DISK COPY)
D3C6  C6 A5                      LDB   #$A5                ; TOKEN FOR 'TO'
D3C8  BD B2 6F                   JSR   LB26F               ; SYNTAX CHECK FOR 'TO'
D3CB  BD C9 35                   JSR   LC935               ; GET DESTINATION FILENAME.EXT AND DRIVE NUMBER
D3CE  8D C9             LD3CE    BSR   LD399               ; SAVE DESTINATION FILENAME.EXT & DRIVE NUMBER ON STACK
D3D0  BD A5 C7                   JSR   LA5C7               ; SYNTAX ERROR IF MORE CHARACTERS ON LINE
D3D3  BD CA E9                   JSR   DVEC7               ; CLOSE ALL FILES

* COUNT THE NUMBER OF SECTORS WORTH OF FREE RAM AVAILABLE
D3D6  6F E2                      CLR   ,-S                 ; CLEAR A SECTOR COUNTER ON THE STACK
D3D8  30 E9 FF 00                LEAX  -SECLEN,S           ; POINT X ONE SECTOR LENGTH DOWN FROM THE TOP OF STACK
D3DC  6C E4             LD3DC    INC   ,S                  ; INCREMENT SECTOR COUNTER
D3DE  30 89 FF 00                LEAX  -SECLEN,X           ; DECREMENT X BY ONE SECTOR
D3E2  9C 1F                      CMPX  ARYEND              ; COMPARE TO TOP OF ARRAYS
D3E4  24 F6                      BHS   LD3DC               ; BRANCH IF NOT AT BOTTOM OF FREE RAM
D3E6  6A E4                      DEC   ,S                  ; DECREMENT SECTOR COUNTER
D3E8  10 27 D8 58                LBEQ  LAC44               ; 'OM' ERROR IF NOT AT LEAST ONE FULL SECTOR OF FREE RAM
D3EC  30 6E                      LEAX  14,S                ; POINT X TO START OF SOURCE DATA
D3EE  8D BD                      BSR   LD3AD               ; PUT SOURCE DATA INTO DNAMBF AND DSKCON
D3F0  BD C6 8C                   JSR   LC68C               ; SCAN DIRECTORY FOR A MATCH
D3F3  BD C6 E5                   JSR   LC6E5               ; 'NE' ERROR IF MATCH NOT FOUND
D3F6  BE 09 74                   LDX   V974                ; POINT X TO DIRECTORY RAM IMAGE OF FOUND FILE
D3F9  EE 0E                      LDU   DIRLST,X            ; * GET NUMBER OF BYTES IN LAST SECTOR AND
D3FB  AE 0B                      LDX   DIRTYP,X            ; * SOURCE FILE TYPE AND ASCII FLAG
D3FD  34 50                      PSHS  U,X                 ; * AND SAVE THEM ON THE STACK
D3FF  BD C7 9D                   JSR   LC79D               ; GET VALID FAT DATA
D402  F6 09 76                   LDB   V976                ; GET NUMBER OF FIRST GRANULE IN FILE
D405  BD CD 1E                   JSR   LCD1E               ; * GET THE NUMBER OF GRANULES IN FILE
D408  34 02                      PSHS  A                   ; * AND SAVE IT ON THE STACK
D40A  4A                         DECA                      ; SUBTRACT OFF THE LAST GRANULE
D40B  C4 3F                      ANDB  #$3F                ; * MASK OFF LAST GRANULE FLAG BITS AND SAVE THE
D40D  34 04                      PSHS  B                   ; * NUMBER OF SECTORS IN LAST GRANULE ON STACK
D40F  1F 89                      TFR   A,B                 ; SAVE THE NUMBER OF GRANULES IN ACCB
D411  4F                         CLRA                      ; CLEAR THE MS BYTE OF ACCD
D412  BD C7 79                   JSR   LC779               ; MULTIPLY ACCD BY NINE
D415  EB E4                      ADDB  ,S                  ; * ADD THE NUMBER OF SECTORS IN THE LAST
D417  89 00                      ADCA  #$00                ; * GRANULE TO ACCD
D419  8E 00 01                   LDX   #$0001              ; INITIALIZE RECORD COUNTER TO ONE
D41C  34 16                      PSHS  X,B,A               ; INITIALIZE SECTOR AND RECORD COUNTERS ON THE STACK

* AT THIS POINT THE CONTROL VARIABLES FOR COPY ARE STORED ON THE STACK.
*   0 1,S = REMAINING SECTORS COUNTER; 2 3,S = RECORD COUNTER
*     4,S = NUMBER OF SECTORS TO BE COPIED. INITIALLY SET TO NUMBER OF
*           SECTORS IN THE LAST GRANULE.
*     5,S = GRAN TEST FLAG. INITIALLY SET TO NUMBER OF GRANS IN FILE
*     6,S = FILE TYPE; 7,S = ASCII FLAG; 8 9,S = NUMBER OF BYTES IN LAST SECTOR
*    10,S = NUMBER OF SECTORS WHICH WILL FIT IN THE CURRENTLY AVAILABLE FREE RAM
* 11-22,S = DESTINATION FILENAME.EXT AND DRIVE NUMBER
*    23,S = SINGLE DISK COPY FLAG; 24-35,S = SOURCE FILENAME.EXT AND DRIVE NUMBER
D41E  5F                LD41E    CLRB                      ; SET SECTOR COUNTER TO ZERO
D41F  AE E4                      LDX   ,S                  ; GET THE NUMBER OF SECTORS REMAINING IN THE FILE
D421  27 09                      BEQ   LD42C               ; BRANCH IF NO SECTORS LEFT
D423  5C                LD423    INCB                      ; ADD A SECTOR TO TEMPORARY SECTOR COUNTER
D424  30 1F                      LEAX  -1,X                ; DECREMENT REMAINING SECTORS COUNTER
D426  27 04                      BEQ   LD42C               ; BRANCH IF NO SECTORS LEFT
D428  E1 6A                      CMPB  10,S                ; *COMPARE TEMPORARY COUNTER TO NUMBER OF SECTORS WHICH MAY
* *BE STORED IN FREE RAM
D42A  26 F7                      BNE   LD423               ; BRANCH IF STILL ROOM FOR MORE SECTORS
D42C  AF E4             LD42C    STX   ,S                  ; SAVE THE NUMBER OF UNCOPIED SECTORS REMAINING IN THE FILE
D42E  E7 64                      STB   $04,S               ; SAVE THE NUMBER OF SECTORS TO BE COPIED THIS TIME THROUGH LOOP
D430  8D 50                      BSR   LD482               ; 'GET' ACCB SECTORS TO RAM BUFFER
D432  86 FF                      LDA   #$FF                ; SET SOURCE/DESTINATION FLAG TO DESTINATION
D434  8D 40                      BSR   LD476               ; PRINT PROMPT MESSAGE IF REQUIRED
D436  6D 65                      TST   $05,S               ; * CHECK THE GRAN TEST FLAG. IF <> 0, IT CONTAINS THE
D438  27 25                      BEQ   LD45F               ; * NUMBER OF GRANS IN THE FILE AND THE DESTINATION DISK
* * MUST BE CHECKED FOR ENOUGH ROOM. IF IT IS =0
* * THEN THE CHECK HAS ALREADY BEEN DONE
D43A  30 6B                      LEAX  11,S                ; POINT TO DESTINATION FILE PARAMETERS
D43C  BD D3 AD                   JSR   LD3AD               ; GET DESTINATION FILE PARAMETERS FROM STACK
D43F  BD D0 59                   JSR   LD059               ; SCAN DIRECTORY FOR FILE - 'AE' ERROR IF IT EXISTS
D442  BD C7 9D                   JSR   LC79D               ; GET VALID FAT DATA

* MAKE SURE THERE ARE ENOUGH FREE GRANULES ON THE DESTINATION DISK
D445  BD C7 55                   JSR   LC755               ; POINT X TO FAT
D448  30 06                      LEAX  FATCON,X            ; SKIP PAST THE FAT CONTROL BYTES
D44A  A6 65                      LDA   $05,S               ; GET THE NUMBER OF GRANS IN THE FILE
D44C  C6 44                      LDB   #GRANMX             ; SET GRAN COUNTER TO MAXIMUM
D44E  63 84             LD44E    COM   ,X                  ; * CHECK TO SEE IF A BRAN IS FREE
D450  26 03                      BNE   LD455               ; * AND BRANCH IF IT IS NOT FREE
D452  4A                         DECA                      ; = DECREMENT COUNTER AND BRANCH IF
D453  27 08                      BEQ   LD45D               ; = THERE ARE ENOUGH FREE GRANULES
D455  63 80             LD455    COM   ,X+                 ; RESTORE FAT BYTE AND INCREMENT POINTER
D457  5A                         DECB                      ; DECREMENT GRAN COUNTER
D458  26 F4                      BNE   LD44E               ; BRANCH IF ALL GRANS NOT CHECKED
D45A  7E C7 F8                   JMP   LC7F8               ; 'DISK FULL' ERROR
D45D  63 84             LD45D    COM   ,X                  ; RESTORE FAT BYTE
D45F  8D 1B             LD45F    BSR   LD47C               ; 'PUT' DATA FROM RAM BUFFER TO DESTINATION FILE
D461  AE E4                      LDX   ,S                  ; GET THE NUMBER OF REMAINING SECTORS
D463  27 0D                      BEQ   LD472               ; EXIT ROUTINE IF NO SECTORS LEFT
D465  EC 62                      LDD   $02,S               ; *
D467  EB 64                      ADDB  $04,S               ; * GET THE CURRENT RECORD COUNTER, ADD
D469  89 00                      ADCA  #$00                ; * THE NUMBER OF SECTORS (RECORDS) MOVED
D46B  ED 62                      STD   $02,S               ; * AND SAVE THE NEW RECORD COUNTER
D46D  4F                         CLRA                      ; SET SOURCE/DESTINATION FLAG TO SOURCE
D46E  8D 06                      BSR   LD476               ; PRINT PROMPT MESSAGE IF REQUIRED
D470  20 AC                      BRA   LD41E               ; KEEP COPYING SECTORS

D472  32 E8 24          LD472    LEAS  36,S                ; REMOVE TEMPORARY STORAGE VARIABLES FROM STACK
D475  39                         RTS                       ; **** COPY DONE ****

D476  6D E8 19          LD476    TST   25,S                ; *CHECK SINGLE DISK COPY FLAG - IF <> ZERO, THEN DON'T
* *PRINT THE PROMPT MESSAGE
D479  7E D3 26                   JMP   LD326               ; PRINT THE PROMPT MESSAGE IF REQUIRED

* 'PUT'.'GET' DATA FROM THE DESTINATION/SOURCE FILES
D47C  86 FF             LD47C    LDA   #$FF                ; 'PUT' FLAG
D47E  30 6D                      LEAX  13,S                ; POINT X TO DESTINATION FILENAME DATA
D480  20 04                      BRA   LD486               ; GO 'PUT' SOME DATA
D482  4F                LD482    CLRA                      ; ZERO IS THE 'GET' FLAG
D483  30 E8 1A                   LEAX  26,S                ; POINT X TO THE SOURCE FILENAME DATA
D486  97 D8             LD486    STA   VD8                 ; SAVE THE 'GET'/'PUT' FLAG
D488  BD D3 AD                   JSR   LD3AD               ; GET FILENAME AND DRIVE DATA FROM THE STACK
D48B  AE 68                      LDX   $08,S               ; * GET ASCII FLAG AND FILE TYPE AND SAVE
D48D  BF 09 57                   STX   DFLTYP              ; * THEM IN THE DISK RAM VARIABLES
D490  8E 01 00                   LDX   #SECLEN             ; = SAVE ONE SECTOR LENGTH IN
D493  BF 09 7C                   STX   DFFLEN              ; = RAM RECORD LENGTH VARIABLE
D496  86 52                      LDA   #'R'                ; RANDOM FILE TYPE FLAG
D498  F6 09 5B                   LDB   FCBACT              ; * GET THE HIGHEST RESERVED FCB NUMBER, ADD ONE
D49B  5C                         INCB                      ; * AND OPEN A RANDOM FILE WHOSE FCB WILL BE ONE ABOVE
D49C  BD C4 8D                   JSR   LC48D               ; * THE HIGHEST RESERVED FCB (THE SYSTEM FCB)
D49F  9E F1                      LDX   FCBTMP              ; POINT X TO THE 'SYSTEM' FCB
D4A1  CC 01 00                   LDD   #SECLEN             ; * SET THE NUMBER OF BYTES IN THE LAST SECTOR
D4A4  ED 88 13                   STD   FCBLST,X            ; * OF THE FILE EQUAL TO ONE SECTOR LENGTH
D4A7  E6 66                      LDB   $06,S               ; =GET THE NUMBER OF SECTORS TO MOVE AND
D4A9  27 29                      BEQ   LD4D4               ; =BRANCH IF NONE LEFT
D4AB  D6 D8                      LDB   VD8                 ; *GRAB THE 'GET'/'PUT' FLAG, 'AND' IT WITH THE
D4AD  E4 67                      ANDB  $07,S               ; *GRAN TEST FLAG - BRANCH IF 'GET'ING DATA OR THIS IS
D4AF  27 09                      BEQ   LD4BA               ; *NOT THE FIRST TIME THROUGH THE LOOP
D4B1  EC 62                      LDD   $02,S               ; =GET THE NUMBER OF SECTORS REMAINING TO BE COPIED AND
D4B3  EB 66                      ADDB  $06,S               ; =ADD THE NUMBER TO BE COPIED THIS TIME THROUGH LOOP
D4B5  89 00                      ADCA  #$00                ; =
D4B7  BD C2 E6                   JSR   LC2E6               ; *'PUT' THE LAST RECORD IN THE FILE TO THE SYSTEM FCB.
* *THE RECORD NUMBER IS IN ACCD.
D4BA  9E F1             LD4BA    LDX   FCBTMP              ; POINT X TO THE SYSTEM FCB
D4BC  EE 64                      LDU   $04,S               ; * GET THE CURRENT RECORD NUMBER
D4BE  EF 07                      STU   FCBREC,X            ; * AND SAVE IT IN THE FCB
D4C0  E6 66                      LDB   $06,S               ; GET THE NUMBER OF THE RECORD (SECTOR) TO MOVE
D4C2  DE 1F                      LDU   ARYEND              ; END OF ARRAYS IS THE START OF THE COPY FREE RAM BUFFER
D4C4  34 44             LD4C4    PSHS  U,B                 ; SAVE SECTOR COUNTER AND BUFFER POINTER ON THE STACK
D4C6  9E F1                      LDX   FCBTMP              ; POINT X TO SYSTEM FCB
D4C8  EF 0B                      STU   FCBBUF,X            ; *SET THE RANDOM FILE BUFFER POINTER TO THE 'COPY' RAM BUFFER
* *THIS WILL CAUSE THE SYSTEM TO 'HANG' IF AN ERROR OCCURS DURING COPY.
D4CA  BD C2 EA                   JSR   LC2EA               ; GO 'GET' OR 'PUT' DATA TO THE SYSTEM FCB
D4CD  6C 61                      INC   $01,S               ; ADD 256 (ONE SECTOR) TO THE BUFFER POINTER
D4CF  35 44                      PULS  B,U                 ; GET THE SECTOR COUNTER AND BUFFER POINER
D4D1  5A                         DECB                      ; DECREMENT SECTOR COUNTER
D4D2  26 F0                      BNE   LD4C4               ; BRANCH IF ALL SECTORS NOT DONE
D4D4  9E F1             LD4D4    LDX   FCBTMP              ; POINT X TO SYSTEM FCB
D4D6  CE 09 89                   LDU   #DFLBUF             ; * RESET THE RANDOM FILE BUFFER POINTER FOR THE SYSTEM
D4D9  EF 0B                      STU   FCBBUF,X            ; * FCB TO THE BOTTOM OF RANDOM FILE BUFFER AREA
D4DB  D6 D8                      LDB   VD8                 ; =GRAB THE 'GET'/'PUT' FLAG, 'AND' IT WITH THE GRAN
D4DD  E4 67                      ANDB  $07,S               ; =TEST FLAG - CLOSE THE FILE IF 'GET'ING DATA AND
D4DF  27 09                      BEQ   LD4EA               ; =THIS IS NOT THE FIRST TIME THROUGH THE LOOP
D4E1  6F 67                      CLR   $07,S               ; RESET THE GRAN TEST FLAG IF FIRST TIME THROUGH LOOP
D4E3  EC 6A                      LDD   10,S                ; *GET THE NUMBER OF BYTES IN THE LAST SECTOR,
D4E5  8A 80                      ORA   #$80                ; *'OR' IN THE PRE-SAVED FLAG AND
D4E7  ED 88 13                   STD   FCBLST,X            ; *SAVE THE NUMBER OF BYTES IN THE LAST SECTOR IN THE FCB
D4EA  7E CB 06          LD4EA    JMP   LCB06               ; CLOSE THE FILE

* DSKI$ COMMAND
D4ED  8D 38             DSKI     BSR   LD527               ; GET THE DRIVE, TRACK AND SECTOR NUMBERS
D4EF  8D 2B                      BSR   LD51C               ; * EVALUATE STRING VARIABLE 1 AND SAVE
D4F1  34 10                      PSHS  X                   ; * THE DESCRIPTOR ADDRESS ON THE STACK
D4F3  8D 27                      BSR   LD51C               ; = EVALUATE STRING VARIABLE 2 AND SAVE
D4F5  34 10                      PSHS  X                   ; = THE DESCRiPTOR ADDRESS ON THE STACK
D4F7  C6 02                      LDB   #$02                ; DSKCON READ OP CODE
D4F9  BD D5 8F                   JSR   LD58F               ; REAO A SECTOR INTO DBUF0
D4FC  CE 06 80                   LDU   #DBUF0+128          ; POINT U TO TOP HALF OF DBUF0
D4FF  35 10                      PULS  X                   ; GET STRING 2 DESCRIPTOR ADDRESS
D501  8D 05                      BSR   LD508               ; PUT STRING 2 INTO STRING SPACE
D503  CE 06 00                   LDU   #DBUF0              ; POINT U TO BOTTOM HALF OF DBUF0
D506  35 10                      PULS  X                   ; GET STRING 1 DESCRIPTOR ADDRESS
D508  34 50             LD508    PSHS  U,X                 ; PUT STRING DESCRIPTOR & SOURCE POINTER ON THE STACK
D50A  C6 80                      LDB   #128                ; *
D50C  BD B5 0F                   JSR   LB50F               ; * RESERVE 128 BYTES IN STRING SPACE
D50F  33 84                      LEAU  ,X                  ; POINT U TO RESERVED STRING SPACE
D511  35 10                      PULS  X                   ; GET STRING DESCRIPTOR ADDRESS
D513  E7 84                      STB   ,X                  ; * SAVE DESCRIPTOR DATA (LENGTH AND ADDRESS)
D515  EF 02                      STU   $02,X               ; * OF THE NEW STRING
D517  35 10                      PULS  X                   ; GET THE SOURCE (DBUF0) POINTER
D519  7E A5 9A          LD519    JMP   LA59A               ; MOVE SECTOR DATA FROM DBUF0 TO STRING SPACE

D51C  BD B2 6D          LD51C    JSR   SYNCOMMA            ; SYNTAX CHECK FOR A COMMA
D51F  8E B3 57                   LDX   #LB357              ; POINT X TO EVALUATE VARIABLE ROUTINE
D522  8D 2F                      BSR   LD553               ; EVALUATE A VARIABLE
D524  7E B1 46          LD524    JMP   LB146               ; 'TM' ERROR IF NUMERIC VARIABLE

* EVALUATE DRIVE, TRACK AND SECTOR NUMBERS
D527  BD B7 0B          LD527    JSR   EVALEXPB            ; EVALUATE EXPRESSION, RETURN VALUE IN ACCB
D52A  C1 03                      CMPB  #$03                ; * COMPARE TO 3 (HIGHEST DRIVE NUMBER) -
D52C  22 1C                      BHI   LD54A               ; * 'FC' ERROR IF IT'S > 3
D52E  34 04                      PSHS  B                   ; SAVE DRIVE NUMBER ON THE STACK
D530  BD B7 38                   JSR   LB738               ; SYNTAX CHECK FOR COMMA. EVALUATE EXPRESSION (TRACK NUMBER)
D533  C1 22                      CMPB  #TRKMAX-1           ; * CHECK FOR MAXIMUM TRACK NUMBER
D535  22 13                      BHI   LD54A               ; * 'FC' ERROR IF TRACK NUMBER > 34
D537  34 04                      PSHS  B                   ; SAVE TRACK NUMBER ON THE STACK
D539  BD B7 38                   JSR   LB738               ; SYNTAX CHECK FOR COMMA, EVALUATE EXPRESSION (SECTOR NUMBER)
D53C  D7 ED                      STB   DSEC                ; SAVE SECTOR NUMBER IN DSKCON VARIABLE
D53E  5A                         DECB                      ; *USELESS INSTRUCTION. NEXT INSTRUCTION SHOULD JUST
D53F  C1 11                      CMPB  #SECMAX-1           ; *CHECK FOR MAXIMUM SECTOR NUMBER (SECMAX)
D541  22 07                      BHI   LD54A               ; 'FC' ERROR IF SECTOR NUMBER TOO BIG
D543  35 06                      PULS  A,B                 ; * GET TRACK AND DRIVE NUMBER OFF OF
D545  97 EC                      STA   DCTRK               ; * THE STACK AND SAVE IN DSKCON
D547  D7 EB                      STB   DCDRV               ; * VARIABLES
D549  39                         RTS
D54A  7E B4 4A          LD54A    JMP   LB44A               ; JUMP TO 'FC' ERROR

D54D  BD B2 6D          LD54D    JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
D550  8E B1 56                   LDX   #LB156              ; POINT X TO 'EVALUATE EXPRESSION' ROUTINE ADDRESS
D553  D6 EB             LD553    LDB   DCDRV               ; * GET THE DSKCON DRIVE, TRACK AND
D555  DE EC                      LDU   DCTRK               ; * SECTOR VALUES AND SAVE THEM ON THE STACK
D557  34 44                      PSHS  S,B                 ; *
D559  AD 84                      JSR   ,X                  ; GO EVALUATE AN EXPRESSION OR A VARIABLE
D55B  35 44                      PULS  B,S                 ; * GET THE DRIVE, TRACK AND SECTOR
D55D  D7 EB                      STB   DCDRV               ; * NUMBERS OFF OF THE STACK AND PUT
D55F  DF EC                      STU   DCTRK               ; * THEM BACK INTO THE DSKCON VARIABLES
D561  39                         RTS
