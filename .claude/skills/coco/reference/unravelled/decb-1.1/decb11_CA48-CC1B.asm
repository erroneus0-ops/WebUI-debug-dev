; Disk Extended Color BASIC 1.1 -- $CA48-$CC1B
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: LOAD=$CA48, DVEC13=$CAE4, DVEC7=$CAE9, DVEC8=$CAF9

* LOAD COMMAND
CA48  81 4D             LOAD     CMPA  #'M'                ; *
CA4A  10 27 05 73                LBEQ  LCFC1               ; *BRANCH IF LOADM
CA4E  4F                         CLRA                      ; RUN FLAG = ZERO (DON'T RUN)
CA4F  5F                LCA4F    CLRB                      ; CLEAR MERGE FLAG
CA50  B7 09 59          LCA50    STA   DRUNFL              ; RUN FLAG (0 = DON'T RUN, 2 = RUN)
CA53  F7 09 5E                   STB   DMRGFL              ; MERGE FLAG (0 = NO MERGE, $FF = MERGE)
CA56  8D DB                      BSR   LCA33               ; GO GET FILENAME, ETC. FROM BASIC
CA58  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHAR
CA5A  27 10                      BEQ   LCA6C               ; BRANCH IF END OF LINE
CA5C  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
CA5F  C6 52                      LDB   #'R'                ; *
CA61  BD B2 6F                   JSR   LB26F               ; *IS NEXT CHAR 'R'? RUN AFTER LOAD
CA64  BD A5 C7                   JSR   LA5C7               ; SYNTAX ERROR IF ANY MORE CHARS ON LINE
CA67  86 03                      LDA   #$03                ; *SET FLAGS TO RUN AND CLOSE ALL FILES
CA69  B7 09 59                   STA   DRUNFL              ; *BEFORE THE FILE IS RUN
CA6C  8D 99             LCA6C    BSR   LCA07               ; GRAB FCB FOR INPUT FILE
CA6E  B6 09 58                   LDA   DASCFL              ; *CHECK ASCII FLAG AND BRANCH
CA71  27 0B                      BEQ   LCA7E               ; *IF CRUNCHED BASIC FILE
CA73  7D 09 5E                   TST   DMRGFL              ; IS THIS A MERGE?
CA76  26 03                      BNE   LCA7B               ; BRANCH IF MERGE
CA78  BD AD 19                   JSR   LAD19               ; DO A 'NEW' - ERASE VARIABLES, RESET VARIABLES
CA7B  7E AC 7C          LCA7B    JMP   LAC7C               ; GO TO BASIC'S MAIN LOOP, IT WILL LOAD PROGRAM

* LOAD IN A CRUNCHED BASIC FILE
CA7E  B6 09 57          LCA7E    LDA   DFLTYP              ; *CHECK FILE TYPE (MUST BE BASIC:0) & CHECK
CA81  BA 09 5E                   ORA   DMRGFL              ; *MERGE FLAG (MUST BE NO MERGE: 0)
CA84  10 26 DB 8E                LBNE  LA616               ; 'BAD FILE MODE' ERROR IF MERGE OR NON-BASIC
CA88  BD AD 19                   JSR   LAD19               ; DO A 'NEW' - RESET POINTERS, ERASE VARIABLES
CA8B  73 09 5D                   COM   DLODFL              ; * SET THE LOAD FLAG TO $FF - THIS WILL CAUSE A NEW TO
* * OCCUR IF AN ERROR OCCURS WHILE THE PROGRAM IS BEING LOADED
CA8E  BD CD BC                   JSR   LCDBC               ; GET CHAR FROM BUFFER - SHOULD BE $FF
CA91  BD CD BC                   JSR   LCDBC               ; GET ANOTHER - MS BYTE OF LENGTH
CA94  34 02                      PSHS  A                   ; SAVE MS BYTE ON STACK
CA96  BD CD BC                   JSR   LCDBC               ; LS BYTE OF LENGTH OF PROGRAM
CA99  1F 89                      TFR   A,B                 ; PUT LS BYTE INTO ACCB
CA9B  35 02                      PULS  A                   ; NOW ACCD CONTAINS LENGTH OF PROGRAM
CA9D  D3 19                      ADDD  TXTTAB              ; ADD BEGINNING OF BASIC
CA9F  BD AC 37                   JSR   LAC37               ; SEE OF ENOUGH ROOM IN RAM FOR THIS FILE
CAA2  9E 19                      LDX   TXTTAB              ; GET START OF BASIC
CAA4  BD C5 C4          LCAA4    JSR   LC5C4               ; READ A CHAR FROM CONSOLE IN
CAA7  D6 70                      LDB   CINBFL              ; BUFFER EMPTY?
CAA9  26 04                      BNE   LCAAF               ; BRANCH IF SO
CAAB  A7 80                      STA   ,X+                 ; STORE CHAR
CAAD  20 F5                      BRA   LCAA4               ; GET ANOTHER CHARACTER

CAAF  7F 09 5D          LCAAF    CLR   DLODFL              ; CLEAR LOAD FLAG - LOAD WAS ERROR FREE
CAB2  9F 1B                      STX   VARTAB              ; SAVE NEW START OF VARIABLES
* MAKE SURE LAST THREE BYTES LOADED WERE ZERO
CAB4  C6 03                      LDB   #$03                ; CHECK THREE BYTES
CAB6  A6 82             LCAB6    LDA   ,-X                 ; CHECK A BYTE
CAB8  26 03                      BNE   LCABD               ; BRANCH IF NON-ZERO
CABA  5A                         DECB                      ; DECREMENT COUNTER
CABB  26 F9                      BNE   LCAB6               ; KEEP CHECKING IF NOT DONE
CABD  9E 1B             LCABD    LDX   VARTAB              ; GET START OF VARIABLES
CABF  9F 1B             LCABF    STX   VARTAB              ; SAVE START OF VARIABLES
CAC1  6F 80                      CLR   ,X+                 ; CLEAR A BYTE
CAC3  5A                         DECB                      ; DECREMRNT COUNTER
CAC4  2A F9                      BPL   LCABF               ; KEEP CLEARING BYTES IF NOT DONE
CAC6  BD A4 2D          LCAC6    JSR   LA42D               ; CLOSE SELECTED FILE
CAC9  BD AD 21                   JSR   LAD21               ; DO PART OF NEW - ERASE VARIABLES, RESET INPUT PTR
CACC  BD 82 9C                   JSR   XVEC18              ; INITIALIZE EXBAS GRAPHICS VARIABLES
CACF  BD AC EF                   JSR   LACEF               ; RELOCATE ALL THE BASIC NEXT LINE POINTERS
CAD2  77 09 59                   ASR   DRUNFL              ; CHECK LSB OF RUN FLAG
CAD5  25 03                      BLO   LCADA               ; BRANCH IF DON'T CLOSE ALL FILES
CAD7  BD A4 26                   JSR   LA426               ; CLOSE ALL FILES
CADA  77 09 59          LCADA    ASR   DRUNFL              ; TEST BIT 1 OF RUN FLAG
CADD  10 25 E2 BD                LBCS  LAD9E               ; BRANCH TO COMM INTERPRETATION LOOP IF BIT 1 SET
CAE1  7E AC 73                   JMP   LAC73               ; RETURN TO DIRECT MODE

CAE4  0D 6F             DVEC13   TST   DEVNUM              ; * CHECK DEVICE NUMBER AND
CAE6  2E DE                      BGT   LCAC6               ; * TRY TO RUN FILE IF IT IS A DISK FILE
CAE8  39                         RTS

* CLOSE ALL FILE BUFFERS RAM VECTOR
CAE9  F6 09 5B          DVEC7    LDB   FCBACT              ; GET THE NUMBER OF RESERVED FILE BUFFERS
CAEC  5C                         INCB                      ; ADD ONE
CAED  34 04             LCAED    PSHS  B                   ; SAVE IT
CAEF  D7 6F                      STB   DEVNUM              ; STORE IT IN DEVICE NUMBER
CAF1  8D 0E                      BSR   LCB01               ; CLOSE FILE
CAF3  35 04                      PULS  B                   ; GET BACK NUMBER OF FILE BUFFERS
CAF5  5A                         DECB                      ; DECREMENT FILE BUFFER COUNTER
CAF6  26 F5                      BNE   LCAED               ; BRANCH IF ALL FILES NOT CLOSED
CAF8  39                LCAF8    RTS

* CLOSE FILE RAM HOOK
CAF9  0D 6F             DVEC8    TST   DEVNUM              ; * CHECK DEVICE NUMBER AND RETURN
CAFB  10 2F B7 87                LBLE  XVEC8               ; * IF NOT A DISK FILE
CAFF  32 62                      LEAS  $02,S               ; PURGE RETURN ADDRESS OFF OF THE STACK
CB01  BD C7 44          LCB01    JSR   LC744               ; POINT X TO CORRECT FCB
CB04  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
CB06  9F F1             LCB06    STX   FCBTMP              ; SAVE FILE BUFFER POINTER
CB08  A6 00                      LDA   FCBTYP,X            ; GET THE TYPE OF THIS FILE
CB0A  27 EC                      BEQ   LCAF8               ; RETURN IF FILE NOT OPEN
CB0C  34 02                      PSHS  A                   ; SAVE FILE TYPE
CB0E  6F 00                      CLR   FCBTYP,X            ; CLOSE THE FILE - ZERO OUT THE FILE TYPE
CB10  E6 01                      LDB   FCBDRV,X            ; * GET DRIVE NUMBER AND
CB12  D7 EB                      STB   DCDRV               ; * SAVE IT IN DSKCON VARIABLE
CB14  81 20                      CMPA  #OUTFIL             ; = CHECK FOR OUTPUT TYPE AND
CB16  26 19                      BNE   LCB31               ; = BRANCH IF NOT OUTPUT TYPE FILE

* CLOSE A SEQUENTIAL OUTPUT FILE
CB18  E6 88 18                   LDB   FCBLFT,X            ; GET THE NUMBER OF CHARACTERS IN BUFFER
CB1B  86 80                      LDA   #$80                ; * SET THE PRE-SAVED BIT TO INDICATE THAT THE DATA
* * HAS ALREADY BEEN SAVED ON DISK
CB1D  AA 05                      ORA   FCBCPT,X            ; 'OR' IN THE FULL SECTOR FLAG
CB1F  ED 88 13                   STD   FCBLST,X            ; SAVE THE NUMBER OF BYTES USED IN THE LAST SECTOR
CB22  6C 04                      INC   FCBSEC,X            ; INCREMENT THE SECTOR NUMBER
CB24  E6 03                      LDB   FCBCGR,X            ; GET THE CURRENT GRANULE NUMBER
CB26  BD C7 55                   JSR   LC755               ; POINT X TO FILE ALLOCATION TABLE
CB29  A7 01                      STA   FAT1,X              ; SET FAT DATA NOT VALID FLAG (ACCA <> 0)
CB2B  3A                         ABX                       ; ADD GRANULE OFFSET TO FAT POINTER
CB2C  6C 06                      INC   FATCON,X            ; * INCREMENT GRANULE DATA (ADD ONE SECTOR TO LAST
* * GRANULE) SKIP PAST THE SIX FAT CONTROL BYTES
CB2E  7E CB C3          LCB2E    JMP   LCBC3               ; UPDATE FAT AND DIRECTORY
CB31  81 40             LCB31    CMPA  #RANFIL             ; RANDOM FILE?
CB33  26 F9                      BNE   LCB2E               ; NO - UPDATE FAT AND DIRECTORY IF SEQUENTIAL INPUT FILE

* CLOSE A RANDOM FILE
CB35  EC 09                      LDD   FCBRLN,X            ; GET RECORD LENGTH
CB37  AE 0B                      LDX   FCBBUF,X            ; POINT X TO RANDOM FILE BUFFER
CB39  31 8B                      LEAY  D,X                 ; POINT Y TO END OF RANDOM FILE BUFFER
CB3B  34 36                      PSHS  Y,X,B,A             ; SAVE POINTERS ON STACK
CB3D  31 E4                      LEAY  ,S                  ; POINT Y CURRENT STACK POINTER
CB3F  DE 1B                      LDU   VARTAB              ; GET START OF VARIABLES
CB41  11 93 1D          LCB41    CMPU  ARYTAB              ; COMPARE TO START OF ARRAYS
CB44  27 0E                      BEQ   LCB54               ; BRANCH IF ALL VARIABLES CHECKED
CB46  A6 41                      LDA   $01,U               ; GET 2ND BYTE OF VARIABLE NAME
CB48  33 42                      LEAU  $02,U               ; MOVE POINTER TO START OF DESCRIPTOR
CB4A  2A 02                      BPL   LCB4E               ; BRANCH IF VARIABLE - NUMERIC
CB4C  8D 28                      BSR   LCB76               ; ADJUST STRING VARIABLE IF IN RANDOM FILE BUFFER
CB4E  33 45             LCB4E    LEAU  $05,U               ; MOVE POINTER TO NEXT VARIABLE
CB50  20 EF                      BRA   LCB41               ; PROCESS ANOTHER VARIABLE
CB52  35 40             LCB52    PULS  U                   ; GET ADDRESS OF NEXT ARRAY TO U
CB54  11 93 1F          LCB54    CMPU  ARYEND              ; COMPARE TO END OF ARRAYS
CB57  27 3A                      BEQ   LCB93               ; BRANCH IF END OF ARRAYS
CB59  1F 30                      TFR   U,D                 ; * SAVE ARRAY START IN ACCD, ADD OFFSET
CB5B  E3 42                      ADDD  $02,U               ; * TO NEXT ARRAY AND SAVE ADDRESS OF
CB5D  34 06                      PSHS  B,A                 ; * NEXT ARRAY ON THE STACK
CB5F  A6 41                      LDA   $01,U               ; GET 2ND LETTER OF VARIABLE NAME
CB61  2A EF                      BPL   LCB52               ; BRANCH IF NUMERIC
CB63  E6 44                      LDB   $04,U               ; GET THE NUMBER OF DIMENSIONS
CB65  58                         ASLB                      ; X2:2 BYTES PER DIMENSION
CB66  CB 05                      ADDB  #$05                ; 5 BYTES CONSTANT PER ARRAY DESCRIPTOR
CB68  4F                         CLRA                      ; CLEAR MSB OF OFFSET - (ONLY 125 DIMENSIONS ALLOWED)
CB69  33 CB                      LEAU  D,U                 ; POINT U TO START OF THIS ARRAY'S VARIABLES
CB6B  11 A3 E4          LCB6B    CMPU  ,S                  ; AT END OF THIS ARRAY?
CB6E  27 E2                      BEQ   LCB52               ; YES
CB70  8D 04                      BSR   LCB76               ; ADJUST STRING VARIABLE IF IN RANDOM FILE BUFFER
CB72  33 45                      LEAU  $05,U               ; MOVE POINTER TO NEXT DESCRIPTOR
CB74  20 F5                      BRA   LCB6B               ; CHECK NEXT VARIABLE
*
* CHECK TO SEE IF A STRING IS LOCATED IN THE RANDOM FILE BUFFER AREA. IF IT IS
* THE RANDOM FILE BUFFER IN QUESTION, IT WILL BE DELETED. IF IT IS HIGHER IN THE RANDOM
* FILE BUFFER SPACE THAN THE BUFFER IN QUESTION, THE LENGTH OF THE CURRENT
* BUFFER WILL BE SUBTRACTED FROM THE ADDRESS OF THE STRING BECAUSE THE CURRENT
* BUFFER IS BEING DELETED (CLOSED).
CB76  AE 42             LCB76    LDX   $02,U               ; POINT X TO START OF STRING
CB78  BC 09 48                   CMPX  RNBFAD              ; COMPARE TO START OF FREE RANDOM FILE BUFFER AREA
CB7B  24 0E                      BHS   LCB8B               ; RETURN IF > START OF FREE RANDOM FILE BUFFER AREA
CB7D  AC 22                      CMPX  $02,Y               ; COMPARE TO START OF THIS FILE'S RANDOM BUFFER
CB7F  25 0A                      BLO   LCB8B               ; RETURN IF < START OF THIS FILE'S RANDOM BUFFER
CB81  AC 24                      CMPX  $04,Y               ; COMPARE TO END OF THIS FILE'S RANDOM BUFFER
CB83  25 07                      BLO   LCB8C               ; RETURN IF < END OF THIS FILE'S RANDOM BUFFER
CB85  1F 10                      TFR   X,D                 ; SAVE POINTER IN ACCD
CB87  A3 A4                      SUBD  ,Y                  ; SUBTRACT RECORD LENGTH FROM START OF STRING ADDRESS
CB89  ED 42                      STD   $02,U               ; SAVE NEW START OF STRING ADDRESS
CB8B  39                LCB8B    RTS
CB8C  6F C4             LCB8C    CLR   ,U                  ; CLEAR THE LENGTH OF THE STRING
CB8E  6F 42                      CLR   $02,U               ; * CLEAR THE ADDRESS
CB90  6F 43                      CLR   $03,U               ; * OF THE STRING
CB92  39                         RTS
* REMOVE RESERVED SPACE IN RANDOM FILE BUFFER FOR A 'CLOSED' RANDOM FILE
* ADJUST THE START OF RANDOM FILE BUFFER POINTER IN ALL RANDOM FCBS
CB93  F6 09 5B          LCB93    LDB   FCBACT              ; GET THE NUMBER OF ACTIVE FILES
CB96  5C                         INCB                      ; ADD ONE
CB97  34 04             LCB97    PSHS  B                   ; SAVE FILES COUNT ON THE STACK
CB99  BD C7 49                   JSR   LC749               ; POINT X TO FCB
CB9C  A6 00                      LDA   FCBTYP,X            ; GET FILE TYPE
CB9E  81 40                      CMPA  #RANFIL             ; IS IT A RANDOM FILE?
CBA0  26 0B                      BNE   LCBAD               ; BRANCH IF NOT
CBA2  EC 0B                      LDD   FCBBUF,X            ; GET START OF THIS FILE'S RANDOM FILE BUFFER
CBA4  10 A3 24                   CMPD  $04,Y               ; * COMPARE TO END OF RANDOM FILE BUFFER AREA AND
CBA7  25 04                      BLO   LCBAD               ; * BRANCH IF < END OF RANDOM FILE BUFFER AREA
CBA9  A3 A4                      SUBD  ,Y                  ; = SUBTRACT RECORD LENGTH OF SELECTED FILE
CBAB  ED 0B                      STD   FCBBUF,X            ; = SAVE NEW START OF RANDOM FILE BUFFER
CBAD  35 04             LCBAD    PULS  B                   ; GET THE FILES COUNTER
CBAF  5A                         DECB                      ; DECREMENT FILES COUNTER
CBB0  26 E5                      BNE   LCB97               ; BRANCH IF ALL FILES NOT DONE
CBB2  35 56                      PULS  A,B,X,U             ; * U = END OF RANDOM FILE BUFFER, X = START OF RANDOM
; * FILE BUFFER, ACCD = RECORD LENGTH

** THIS WOULD PROBABLY BE THE MOST CONVENIENT PLACE TO FIX THE BUG WHICH
** CAUSES THE SYSTEM TO HANG IF AN ERROR IS ENCOUNTERED DURING 'COPY'

                        *        CMPU  FCBADR              ; * IS THE END OF THIS FCB'S BUFFER ABOVE THE END
* * OF THE START OF THE FCB AREA
                        *        BLO   LCBB4               ; NO - FREE UP THE SPACE USED BY THIS FILE IN RANDOM BUFFER
                        *        LDX   #DFLBUF             ; YES - DOING A 'COPY'; RESET START OF RANDOM BUFFER
                        *        BRA   LCBC0
* RANDOM FILE BUFFER AREA
* REMOVE RESERVED SPACE FOR CLOSED FILE FROM RANDOM FILE BUFFER SPACE

CBB4  11 B3 09 48       LCBB4    CMPU  RNBFAD              ; AT THE BOTTOM OF FREE RANDOM BUFFER AREA?
CBB8  27 06                      BEQ   LCBC0               ; BRANCH IF THERE
CBBA  A6 C0                      LDA   ,U+                 ; = GRAB A SOURCE BYTE AND
CBBC  A7 80                      STA   ,X+                 ; = MOVE IT TO DESTINATION
CBBE  20 F4                      BRA   LCBB4               ; KEEP MOVING BYTES
CBC0  BF 09 48          LCBC0    STX   RNBFAD              ; SAVE NEW START OF FREE RANDOM BUFFER AREA
CBC3  BD C7 55          LCBC3    JSR   LC755               ; POINT X TO PROPER FILE ALLOCATION TABLE
CBC6  6A 00                      DEC   FAT0,X              ; REMOVE ONE ACTIVE FILE
CBC8  6D 01                      TST   FAT1,X              ; NEW DATA IN FAT RAM IMAGE?
CBCA  27 03                      BEQ   LCBCF               ; NO
CBCC  BD C7 1E                   JSR   LC71E               ; WRITE OUT FILE ALLOCATION TABLE TO DISK
CBCF  9E F1             LCBCF    LDX   FCBTMP              ; GET FILE BUFFER POINTER
CBD1  35 02                      PULS  A                   ; GET FILE TYPE
CBD3  81 20                      CMPA  #OUTFIL             ; IS IT A SEQUENTIAL OUTPUT FILE?
CBD5  27 08                      BEQ   LCBDF               ; YES
CBD7  81 40                      CMPA  #RANFIL             ; IS IT A RANDOM FILE?
CBD9  26 B0                      BNE   LCB8B               ; RETURN IF NOT A RANDOM FILE (SEQUENTIAL INPUT)
CBDB  A6 0F                      LDA   FCBFLG,X            ; * TEST THE GET/PUT FLAG AND
CBDD  27 0A                      BEQ   LCBE9               ; * BRANCH IF 'GET'

* WRITE CONTENTS OF FILE BUFFER TO DISK
CBDF  BD C7 63          LCBDF    JSR   LC763               ; GET PROPER TRACK & SECTOR NUMBERS
CBE2  33 88 19                   LEAU  FCBCON,X            ; POINT U TO START OF FCB DATA
CBE5  DF EE                      STU   DCBPT               ; SET UP FILE BUFFER POINTER FOR DSKCON
CBE7  8D 2C                      BSR   LCC15               ; GO WRITE A SECTOR
CBE9  A6 88 13          LCBE9    LDA   FCBLST,X            ; CHECK THE PRE-SAVED FLAG
CBEC  2A 9D                      BPL   LCB8B               ; RETURN IF RECORD HAS ALREADY BEEN SAVED ON DISK
CBEE  E6 88 12                   LDB   FCBDIR,X            ; GET DIRECTORY NUMBER OF THIS FILE
CBF1  C4 07                      ANDB  #$07                ; 8 ENTRIES PER SECTOR
CBF3  86 20                      LDA   #DIRLEN             ; DIRLEN BYTES PER DIRECTORY ENTRY
CBF5  3D                         MUL                       ; GET SECTOR OFFSET FOR THIS ENTRY
CBF6  CE 06 00                   LDU   #DBUF0              ; * GET READ/WRITE BUFFER 0 AND
CBF9  DF EE                      STU   DCBPT               ; * SAVE IT IN DSKCON REGISTER
CBFB  31 CB                      LEAY  D,U                 ; Y POINTS TO CORRECT DIRECTORY ENTRY
CBFD  E6 88 12                   LDB   FCBDIR,X            ; GET DIRECTORY ENTRY NUMBER
CC00  54                         LSRB                      ; *
CC01  54                         LSRB                      ; *
CC02  54                         LSRB                      ; * DIVIDE BY 8; EIGHT DIRECTORY ENTRIES PER SECTOR
CC03  CB 03                      ADDB  #$03                ; ADD BIAS; FIRST 3 SECTORS NOT DIRECTORY
CC05  D7 ED                      STB   DSEC                ; STORE SECTOR NUMBER
CC07  CC 11 02                   LDD   #$1102              ; DIRECTORY TRACK - READ OP CODE
CC0A  97 EC                      STA   DCTRK               ; STORE TRACK NUMBER
CC0C  8D 09                      BSR   LCC17               ; GO READ DIRECTORY
CC0E  EC 88 13                   LDD   FCBLST,X            ; GET NUMBER OF BYTES IN THE LAST SECTOR
CC11  84 7F                      ANDA  #$7F                ; MASK OFF THE PRE-SAVED FLAG
CC13  ED 2E                      STD   DIRLIST,Y           ; SAVE NUMBER OF BYTES IN LAST SECTOR OF FILE IN DIRECTORY
CC15  C6 03             LCC15    LDB   #$03                ; WRITE OP CODE
CC17  D7 EA             LCC17    STB   DCOPC               ; SAVE DSKCON OP CODE VARIABLE
CC19  7E D6 F2                   JMP   LD6F2               ; GO READ/WRITE SECTOR
