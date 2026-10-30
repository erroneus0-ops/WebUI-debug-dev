; Disk Extended Color BASIC 1.0 -- $CA4B-$CBCE
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: DVEC8=$CA4B, DVEC3=$CB4A

* CLOSE FILE RAM HOOK
CA4B  0D 6F             DVEC8    TST   DEVNUM              ; * CHECK DEVICE NUMBER AND RETURN
CA4D  10 2F B8 35                LBLE  XVEC8               ; * IF NOT A DISK FILE
CA51  32 62                      LEAS  $02,S               ; PURGE RETURN ADDRESS OFF OF THE STACK
CA53  BD C7 14          LCA53    JSR   LC714               ; POINT X TO CORRECT FCB
CA56  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
CA58  9F F1             LCA58    STX   FCBTMP              ; SAVE FILE BUFFER POINTER
CA5A  A6 00                      LDA   FCBTYP,X            ; GET THE TYPE OF THIS FILE
CA5C  27 EC                      BEQ   LCA4A               ; RETURN IF FILE NOT OPEN
CA5E  34 02                      PSHS  A                   ; SAVE FILE TYPE
CA60  6F 00                      CLR   FCBTYP,X            ; CLOSE THE FILE - ZERO OUT THE FILE TYPE
CA62  E6 01                      LDB   FCBDRV,X            ; * GET DRIVE NUMBER AND
CA64  D7 EB                      STB   DCDRV               ; * SAVE IT IN DSKCON VARIABLE
CA66  81 20                      CMPA  #OUTFIL             ; = CHECK FOR OUTPUT TYPE AND
CA68  26 16                      BNE   LCA80               ; = BRANCH IF NOT OUTPUT TYPE FILE

* CLOSE A SEQUENTIAL OUTPUT FILE
CA6A  E6 88 18                   LDB   FCBLFT,X            ; GET THE NUMBER OF CHARACTERS IN BUFFER
CA6D  86 80                      LDA   #$80                ; * SET THE PRE-SAVED BIT TO INDICATE THAT THE DATA
* * HAS ALREADY BEEN SAVED ON DISK
CA6F  ED 88 13                   STD   FCBLST,X            ; SAVE THE NUMBER OF BYTES USED IN THE LAST SECTOR
CA72  6C 04                      INC   FCBSEC,X            ; INCREMENT THE SECTOR NUMBER
CA74  E6 03                      LDB   FCBCGR,X            ; GET THE CURRENT GRANULE NUMBER
CA76  BD C7 25                   JSR   LC725               ; POINT X TO FILE ALLOCATION TABLE
CA79  A7 01                      STA   FAT1,X              ; SET FAT DATA NOT VALID FLAG (ACCA <> 0)
CA7B  3A                         ABX                       ; ADD GRANULE OFFSET TO FAT POINTER
CA7C  6C 06                      INC   FATCON,X            ; * INCREMENT GRANULE DATA (ADD ONE SECTOR TO LAST
* * GRANULE) SKIP PAST THE SIX FAT CONTROL BYTES
CA7E  20 71                      BRA   LCAF1               ; UPDATE FAT AND DIRECTORY
CA80  81 40             LCA80    CMPA  #RANFIL             ; RANDOM FILE?
CA82  26 6D                      BNE   LCAF1               ; NO - UPDATE FAT AND DIRECTORY

* CLOSE A RANDOM FILE
CA84  EC 09                      LDD   FCBRLN,X            ; GET RECORD LENGTH
CA86  AE 0B                      LDX   FCBBUF,X            ; POINT X TO RANDOM FILE BUFFER
CA88  31 8B                      LEAY  D,X                 ; POINT Y TO END OF RANDOM FILE BUFFER
CA8A  34 36                      PSHS  Y,X,B,A             ; SAVE POINTERS ON STACK
CA8C  DE 1B                      LDU   VARTAB              ; GET START OF VARIABLES
CA8E  11 93 1D          LCA8E    CMPU  ARYTAB              ; COMPARE TO START OF ARRAYS
CA91  27 0E                      BEQ   LCAA1               ; BRANCH IF ALL VARIABLES CHECKED
CA93  A6 41                      LDA   $01,U               ; GET 2ND BYTE OF VARIABLE NAME
CA95  33 42                      LEAU  $02,U               ; MOVE POINTER TO START OF DESCRIPTOR
CA97  2A 02                      BPL   LCA9B               ; BRANCH IF VARIABLE - NUMERIC
CA99  8D 28                      BSR   LCAC3               ; ADJUST STRING VARIABLE IF IN RANDOM FILE BUFFER
CA9B  33 45             LCA9B    LEAU  $05,U               ; MOVE POINTER TO NEXT VARIABLE
CA9D  20 EF                      BRA   LCA8E               ; PROCESS ANOTHER VARIABLE
CA9F  35 40             LCA9F    PULS  U                   ; GET ADDRESS OF NEXT ARRAY TO U
CAA1  11 93 1F          LCAA1    CMPU  ARYEND              ; COMPARE TO END OF ARRAYS
CAA4  27 3A                      BEQ   LCAE0               ; BRANCH IF END OF ARRAYS
CAA6  1F 30                      TFR   U,D                 ; * SAVE ARRAY START IN ACCD, ADD OFFSET
CAA8  E3 42                      ADDD  $02,U               ; * TO NEXT ARRAY AND SAVE ADDRESS OF
CAAA  34 06                      PSHS  B,A                 ; * NEXT ARRAY ON THE STACK
CAAC  A6 41                      LDA   $01,U               ; GET 2ND LETTER OF VARIABLE NAME
CAAE  2A EF                      BPL   LCA9F               ; BRANCH IF NUMERIC
CAB0  E6 44                      LDB   $04,U               ; GET THE NUMBER OF DIMENSIONS
CAB2  58                         ASLB                      ; X2:2 BYTES PER DIMENSION
CAB3  CB 05                      ADDB  #$05                ; 5 BYTES CONSTANT PER ARRAY DESCRIPTOR
CAB5  4F                         CLRA                      ; CLEAR MSB OF OFFSET - (ONLY 125 DIMENSIONS ALLOWED)
CAB6  33 CB                      LEAU  D,U                 ; POINT U TO START OF THIS ARRAY'S VARIABLES
CAB8  11 A3 E4          LCAB8    CMPU  ,S                  ; AT END OF THIS ARRAY?
CABB  27 E2                      BEQ   LCA9F               ; YES
CABD  8D 04                      BSR   LCAC3               ; ADJUST STRING VARIABLE IF IN RANDOM FILE BUFFER
CABF  33 45                      LEAU  $05,U               ; MOVE POINTER TO NEXT DESCRIPTOR
CAC1  20 F5                      BRA   LCAB8               ; CHECK NEXT VARIABLE
*
* CHECK TO SEE IF A STRING IS LOCATED IN THE RANDOM FILE BUFFER AREA. IF IT IS
* THE RANDOM FILE BUFFER IN QUESTION, IT WILL BE DELETED. IF IT IS HIGHER IN THE RANDOM
* FILE BUFFER SPACE THAN THE BUFFER IN QUESTION, THE LENGTH OF THE CURRENT
* BUFFER WILL BE SUBTRACTED FROM THE ADDRESS OF THE STRING BECAUSE THE CURRENT
* BUFFER IS BEING DELETED (CLOSED).
CAC3  AE 42             LCAC3    LDX   $02,U               ; POINT X TO START OF STRING
CAC5  BC 09 48                   CMPX  RNBFAD              ; COMPARE TO START OF FREE RANDOM FILE BUFFER AREA
CAC8  24 0E                      BHS   LCAD8               ; RETURN IF > START OF FREE RANDOM FILE BUFFER AREA
CACA  AC 64                      CMPX  $04,S               ; COMPARE TO START OF THIS FILE'S RANDOM BUFFER
CACC  25 0B                      BLO   LCAD9               ; BRANCH IF < START OF THIS FILE'S RANDOM BUFFER
* ** BUG ** THIS SHOULD BE A BRANCH TO A RETURN
CACE  AC 66                      CMPX  $06,S               ; COMPARE TO END OF THIS FILE'S RANDOM BUFFER
CAD0  25 07                      BLO   LCAD9               ; BRANCH IF < END OF THIS FILE'S RANDOM BUFFER
CAD2  1F 10                      TFR   X,D                 ; SAVE POINTER IN ACCD
CAD4  A3 62                      SUBD  $02,S               ; SUBTRACT RECORD LENGTH FROM START OF STRING ADDRESS
CAD6  ED 42                      STD   $02,U               ; SAVE NEW START OF STRING ADDRESS
CAD8  39                LCAD8    RTS
CAD9  6F C4             LCAD9    CLR   ,U                  ; CLEAR THE LENGTH OF THE STRING
CADB  6F 42                      CLR   $02,U               ; * CLEAR THE ADDRESS
CADD  6F 43                      CLR   $03,U               ; * OF THE STRING
CADF  39                         RTS
*REMOVE RESERVED SPACE IN RANDOM FILE BUFFER FOR A 'CLOSED' RANDOM FILE
CAE0  35 56             LCAE0    PULS  A,B,X,U             ; *U = END OF RANDOM FILE BUFFER, X = START OF RANDOM
* *FILE BUFFER, ACCD = RECORD LENGTH

** THIS WOULD PROBABLY BE THE MOST CONVENIENT PLACE TO FIX THE BUG WHICH
** CAUSES THE SYSTEM TO HANG IF AN ERROR IS ENCOUNTERED DURING 'COPY'

                        *        CMPU  FCBADR              ; * IS THE END OF THIS FCB'S BUFFER ABOVE THE END
* * OF THE START OF THE FCB AREA
                        *        BLO   LCAE2               ; NO - FREE UP THE SPACE USED BY THIS FILE IN RANDOM BUFFER
                        *        LDX   #DFLBUF             ; YES - DOING A 'COPY'; RESET START OF RANDOM BUFFER
                        *        BRA   LCAEE
* RANDOM FILE BUFFER AREA

* REMOVE RESERVED SPACE FOR CLOSED FILE FROM RANDOM FILE BUFFER SPACE
CAE2  11 B3 09 48       LCAE2    CMPU  RNBFAD              ; AT THE BOTTOM OF FREE RANDOM BUFFER AREA?
CAE6  27 06                      BEQ   LCAEE               ; BRANCH IF THERE
CAE8  A6 C0                      LDA   ,U+                 ; = GRAB A SOURCE BYTE AND
CAEA  A7 80                      STA   ,X+                 ; = MOVE IT TO DESTINATION
CAEC  20 F4                      BRA   LCAE2               ; KEEP MOVING BYTES
CAEE  BF 09 48          LCAEE    STX   RNBFAD              ; SAVE NEW START OF FREE RANDOM BUFFER AREA
CAF1  BD C7 25          LCAF1    JSR   LC725               ; POINT X TO PROPER FILE ALLOCATION TABLE
CAF4  6A 00                      DEC   FAT0,X              ; REMOVE ONE ACTIVE FILE
CAF6  6D 01                      TST   FAT1,X              ; NEW DATA IN FAT RAM IMAGE?
CAF8  27 03                      BEQ   LCAFD               ; NO
CAFA  BD C6 F1                   JSR   LC6F1               ; WRITE OUT FILE ALLOCATION TABLE TO DISK
CAFD  9E F1             LCAFD    LDX   FCBTMP              ; GET FILE BUFFER POINTER
CAFF  35 02                      PULS  A                   ; GET FILE TYPE
CB01  81 20                      CMPA  #OUTFIL             ; IS IT A SEQUENTIAL OUTPUT FILE?
CB03  27 08                      BEQ   LCB0D               ; YES
CB05  81 40                      CMPA  #RANFIL             ; IS IT A RANDOM FILE?
CB07  26 CF                      BNE   LCAD8               ; RETURN IF NOT A RANDOM FILE (SEQUENTIAL INPUT)
CB09  A6 0F                      LDA   FCBFLG,X            ; * TEST THE GET/PUT FLAG AND
CB0B  27 0A                      BEQ   LCB17               ; * BRANCH IF 'GET'

* WRITE CONTENTS OF FILE BUFFER TO DISK
CB0D  BD C7 33          LCB0D    JSR   LC733               ; GET PROPER TRACK & SECTOR NUMBERS
CB10  33 88 19                   LEAU  FCBCON,X            ; POINT U TO START OF FCB DATA
CB13  DF EE                      STU   DCBPT               ; SET UP FILE BUFFER POINTER FOR DSKCON
CB15  8D 2C                      BSR   LCB43               ; GO WRITE A SECTOR
CB17  A6 88 13          LCB17    LDA   FCBLST,X            ; CHECK THE PRE-SAVED FLAG
CB1A  2A BC                      BPL   LCAD8               ; RETURN IF RECORD HAS ALREADY BEEN SAVED ON DISK
CB1C  E6 88 12                   LDB   FCBDIR,X            ; GET DIRECTORY NUMBER OF THIS FILE
CB1F  C4 07                      ANDB  #$07                ; 8 ENTRIES PER SECTOR
CB21  86 20                      LDA   #DIRLEN             ; DIRLEN BYTES PER DIRECTORY ENTRY
CB23  3D                         MUL                       ; GET SECTOR OFFSET FOR THIS ENTRY
CB24  CE 06 00                   LDU   #DBUF0              ; * GET READ/WRITE BUFFER 0 AND
CB27  DF EE                      STU   DCBPT               ; * SAVE IT IN DSKCON REGISTER
CB29  31 CB                      LEAY  D,U                 ; Y POINTS TO CORRECT DIRECTORY ENTRY
CB2B  E6 88 12                   LDB   FCBDIR,X            ; GET DIRECTORY ENTRY NUMBER
CB2E  54                         LSRB                      ; *
CB2F  54                         LSRB                      ; *
CB30  54                         LSRB                      ; * DIVIDE BY 8; EIGHT DIRECTORY ENTRIES PER SECTOR
CB31  CB 03                      ADDB  #$03                ; ADD BIAS; FIRST 3 SECTORS NOT DIRECTORY
CB33  D7 ED                      STB   DSEC                ; STORE SECTOR NUMBER
CB35  CC 11 02                   LDD   #$1102              ; DIRECTORY TRACK - READ OP CODE
CB38  97 EC                      STA   DCTRK               ; STORE TRACK NUMBER
CB3A  8D 09                      BSR   LCB45               ; GO READ DIRECTORY
CB3C  EC 88 13                   LDD   FCBLST,X            ; GET NUMBER OF BYTES IN THE LAST SECTOR
CB3F  84 7F                      ANDA  #$7F                ; MASK OFF THE PRE-SAVED FLAG
CB41  ED 2E                      STD   DIRLST,Y            ; SAVE NUMBER OF BYTES IN LAST SECTOR OF FILE IN DIRECTORY
CB43  C6 03             LCB43    LDB   #$03                ; WRITE OP CODE
CB45  D7 EA             LCB45    STB   DCOPC               ; SAVE DSKCON OP CODE VARIABLE
CB47  7E D5 FF                   JMP   LD5FF               ; GO READ/WRITE SECTOR

* CONSOLE OUT RAM HOOK
CB4A  0D 6F             DVEC3    TST   DEVNUM              ; CHECK DEVICE NUMBER
CB4C  10 2F B7 23                LBLE  XVEC3               ; BRANCH TO EX BASIC IF NOT A DISK FILE
CB50  32 62                      LEAS  $02,S               ; POP RETURN OFF STACK
* SEND A CHARACTER IN ACCA TO A DISK FILE. A CARRIAGE RETURN WILL RESET THE
* PRINT POSITION AND CONTROL CODES WILL NOT INCREMENT THE PRINT POSITION.
CB52  34 16             LCB52    PSHS  X,B,A               ; SAVE REGISTERS
CB54  8E 09 26                   LDX   #FCBV1-2            ; POINT X TO TABLE OF FILE NUMBER VECTORS
CB57  D6 6F                      LDB   DEVNUM              ; GET CURRENT FILE NUMBER
CB59  58                         ASLB                      ; 2 BYTES PER FCB ADDRESS
CB5A  AE 85                      LDX   B,X                 ; POINT X TO PROPER FCB
CB5C  E6 84                      LDB   FCBTYP,X            ; GET FILE TYPE
CB5E  C1 10                      CMPB  #INPFIL             ; IS IT AN INPUT FILE?
CB60  27 36                      BEQ   LCB98               ; RETURN IF SO
CB62  81 0D                      CMPA  #CR                 ; CARRIAGE RETURN (ENTER)
CB64  26 02                      BNE   LCB68               ; NO
CB66  6F 06                      CLR   FCBPOS,X            ; CLEAR PRINT POSITION IF CARRIAGE RETURN
CB68  81 20             LCB68    CMPA  #SPACE              ; *
CB6A  25 02                      BLO   LCB6E               ; *BRANCH IF CONTROL CHAR
CB6C  6C 06                      INC   FCBPOS,X            ; INCREMENT PRINT POSITION
CB6E  C1 40             LCB6E    CMPB  #RANFIL             ; IS IT RANDOM FILE?
CB70  26 1A                      BNE   LCB8C               ; BRANCH IF NOT RANDOM
* PUT A BYTE INTO A RANDOM FILE
CB72  EC 88 17                   LDD   FCBPUT,X            ; GET 'PUT' BYTE COUNTER
CB75  C3 00 01                   ADDD  #$0001              ; ADD ONE
CB78  10 A3 09                   CMPD  FCBRLN,X            ; COMPARE TO RECORD LENGTH
CB7B  10 22 01 72                LBHI  LCCF1               ; 'FR' ERROR IF 'PUT' BYTE COUNTER > RECORD LENGTH
CB7F  ED 88 17                   STD   FCBPUT,X            ; SAVE NEW 'PUT' BYTE COUNTER
CB82  AE 0B                      LDX   FCBBUF,X            ; POINT TO RANDOM FILE BUFFER POINTER
CB84  30 8B                      LEAX  D,X                 ; POINT TO ONE PAST END OF CURRENT RECORD DATA
CB86  35 02                      PULS  A                   ; PULL DATA FROM STACK
CB88  A7 1F                      STA   -1,X                ; STORE IN DATA BUFFER
CB8A  35 94                      PULS  B,X,PC              ; RESTORE REGISTERS AND RETURN

* WRITE A BYTE TO SEQUENTIAL OUTPUT FILE
CB8C  6C 88 18          LCB8C    INC   FCBLFT,X            ; INCREMENT CHARACTER COUNT
CB8F  E6 88 18                   LDB   FCBLFT,X            ; * GET CHARACTER COUNT AND BRANCH
CB92  27 06                      BEQ   LCB9A               ; * IF THE BUFFER IS FULL
CB94  3A                         ABX                       ; ADD CHARACTER COUNT TO FCB ADDRESS
CB95  A7 88 18                   STA   FCBCON-1,X          ; STORE NEW CHARACTER (SKIP PAST 25 CONTROL BYTES AT FCB START)
CB98  35 96             LCB98    PULS  A,B,X,PC

* WRITE OUT A FULL BUFFER AND RESET BUFFER
CB9A  34 60             LCB9A    PSHS  U,Y                 ; SAVE REGISTERS
CB9C  A7 89 01 18                STA   SECLEN+FCBCON-1,X   ; STORE LAST CHARACTER IN BUFFER
CBA0  BD C6 58                   JSR   LC658               ; INCREMENT RECORD NUMBER
CBA3  E6 01                      LDB   FCBDRV,X            ; * GET DRIVE NUMBER AND SAVE
CBA5  D7 EB                      STB   DCDRV               ; * IT IN DSKCON CONTROL TABLE
CBA7  6C 04                      INC   FCBSEC,X            ; INCREMENT SECTOR NUMBER
CBA9  BD CB 0D                   JSR   LCB0D               ; WRITE THE FILE BUFFER TO DISK
CBAC  31 84                      LEAY  ,X                  ; SAVE FCB POINTER IN Y
CBAE  E6 03                      LDB   FCBCGR,X            ; GET GRANULE NUMBER
CBB0  BD C7 25                   JSR   LC725               ; POINT X TO PROPER ALLOCATION TABLE
CBB3  3A                         ABX                       ; ADD THE GRANULE NUMBER TO FAT POINTER
CBB4  33 06                      LEAU  FATCON,X            ; *POINT U TO THE CORRECT GRANULE IN FAT - SKIP PAST
* *THE SIX FAT CONTROL BYTES
CBB6  A6 24                      LDA   FCBSEC,Y            ; GET CURRENT SECTOR FOR THIS GRANULE
CBB8  81 09                      CMPA  #$09                ; MAX SECTOR NUMBER (9 SECTORS/GRANULE)
CBBA  25 08                      BLO   LCBC4               ; BRANCH IF NOT AT END OF GRANULE
CBBC  6F 24                      CLR   FCBSEC,Y            ; CLEAR SECTOR NUMBER
CBBE  BD C7 8F                   JSR   LC78F               ; GET NEXT FREE GRANULE
CBC1  A7 23                      STA   FCBCGR,Y            ; SAVE NEW GRANULE IN FCB
CBC3  8C 8A C0          LCBC3    CMPX  #$8AC0              ; SKIP TWO BYTES — NO DATA STORED IN NEW SECTOR YET
CBC4  8A C0             LCBC4    ORA   #$C0                ; FORCE GRANULE NUMBER TO BE FINAL GRANULE IN FILE
CBC6  A7 C4                      STA   ,U                  ; STORE IN MAP
CBC8  BD C5 7C                   JSR   LC57C               ; UPDATE FILE ALLOCATION TABLE
CBCB  35 60                      PULS  Y,U                 ; RESTORE REGISTERS
CBCD  35 96                      PULS  A,B,X,PC            ; RESTORE REGISTERS AND RETURN
