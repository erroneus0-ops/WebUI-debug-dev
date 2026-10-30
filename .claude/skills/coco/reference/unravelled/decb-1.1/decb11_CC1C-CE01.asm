; Disk Extended Color BASIC 1.1 -- $CC1C-$CE01
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: DVEC3=$CC1C, DIR=$CCA9, DVEC10=$CD35, CVN=$CDF4

* CONSOLE OUT RAM HOOK
CC1C  0D 6F             DVEC3    TST   DEVNUM              ; CHECK DEVICE NUMBER
CC1E  10 2F B6 51                LBLE  XVEC3               ; BRANCH TO EX BASIC IF NOT A DISK FILE
CC22  32 62                      LEAS  $02,S               ; POP RETURN OFF STACK
* SEND A CHARACTER IN ACCA TO A DISK FILE. A CARRIAGE RETURN WILL RESET THE
* PRINT POSITION AND CONTROL CODES WILL NOT INCREMENT THE PRINT POSITION.
CC24  34 16             LCC24    PSHS  X,B,A               ; SAVE REGISTERS
CC26  8E 09 26                   LDX   #FCBV1-2            ; POINT X TO TABLE OF FILE NUMBER VECTORS
CC29  D6 6F                      LDB   DEVNUM              ; GET CURRENT FILE NUMBER
CC2B  58                         ASLB                      ; 2 BYTES PER FCB ADDRESS
CC2C  AE 85                      LDX   B,X                 ; POINT X TO PROPER FCB
CC2E  E6 84                      LDB   FCBTYP,X            ; GET FILE TYPE
CC30  C1 10                      CMPB  #INPFIL             ; IS IT AN INPUT FILE?
CC32  27 36                      BEQ   LCC6A               ; RETURN IF SO
CC34  81 0D                      CMPA  #CR                 ; CARRIAGE RETURN (ENTER)
CC36  26 02                      BNE   LCC3A               ; NO
CC38  6F 06                      CLR   FCBPOS,X            ; CLEAR PRINT POSITION IF CARRIAGE RETURN
CC3A  81 20             LCC3A    CMPA  #SPACE              ; *
CC3C  25 02                      BLO   LCC40               ; *BRANCH IF CONTROL CHAR
CC3E  6C 06                      INC   FCBPOS,X            ; INCREMENT PRINT POSITION
CC40  C1 40             LCC40    CMPB  #RANFIL             ; IS IT RANDOM FILE?
CC42  26 1A                      BNE   LCC5E               ; BRANCH IF NOT RANDOM
* PUT A BYTE INTO A RANDOM FILE
CC44  EC 88 17                   LDD   FCBPUT,X            ; GET 'PUT' BYTE COUNTER
CC47  C3 00 01                   ADDD  #$0001              ; ADD ONE
CC4A  10 A3 09                   CMPD  FCBRLN,X            ; COMPARE TO RECORD LENGTH
CC4D  10 22 01 7A                LBHI  LCDCB               ; 'FR' ERROR IF 'PUT' BYTE COUNTER > RECORD LENGTH
CC51  ED 88 17                   STD   FCBPUT,X            ; SAVE NEW 'PUT' BYTE COUNTER
CC54  AE 0B                      LDX   FCBBUF,X            ; POINT TO RANDOM FILE BUFFER POINTER
CC56  30 8B                      LEAX  D,X                 ; POINT TO ONE PAST END OF CURRENT RECORD DATA
CC58  35 02                      PULS  A                   ; PULL DATA FROM STACK
CC5A  A7 1F                      STA   -1,X                ; STORE IN DATA BUFFER
CC5C  35 94                      PULS  B,X,PC              ; RESTORE REGISTERS AND RETURN

* WRITE A BYTE TO SEQUENTIAL OUTPUT FILE
CC5E  6C 88 18          LCC5E    INC   FCBLFT,X            ; INCREMENT CHARACTER COUNT
CC61  E6 88 18                   LDB   FCBLFT,X            ; * GET CHARACTER COUNT AND BRANCH
CC64  27 06                      BEQ   LCC6C               ; * IF THE BUFFER IS FULL
CC66  3A                         ABX                       ; ADD CHARACTER COUNT TO FCB ADDRESS
CC67  A7 88 18                   STA   FCBCON-1,X          ; STORE NEW CHARACTER (SKIP PAST 25 CONTROL BYTES AT FCB START)
CC6A  35 96             LCC6A    PULS  A,B,X,PC

* WRITE OUT A FULL BUFFER AND RESET BUFFER
CC6C  34 60             LCC6C    PSHS  U,Y                 ; SAVE REGISTERS
CC6E  A7 89 01 18                STA   SECLEN+FCBCON-1,X   ; STORE LAST CHARACTER IN BUFFER
CC72  E6 01                      LDB   FCBDRV,X            ; * GET DRIVE NUMBER AND SAVE
CC74  D7 EB                      STB   DCDRV               ; * IT IN DSKCON CONTROL TABLE
CC76  6C 04                      INC   FCBSEC,X            ; INCREMENT SECTOR NUMBER
CC78  BD CB DF                   JSR   LCBDF               ; WRITE THE FILE BUFFER TO DISK
CC7B  31 84                      LEAY  ,X                  ; SAVE FCB POINTER IN Y
CC7D  E6 03                      LDB   FCBCGR,X            ; GET GRANULE NUMBER
CC7F  BD C7 55                   JSR   LC755               ; POINT X TO PROPER ALLOCATION TABLE
CC82  3A                         ABX                       ; ADD THE GRANULE NUMBER TO FAT POINTER
CC83  33 06                      LEAU  FATCON,X            ; POINT U TO THE CORRECT GRANULE IN FAT - SKIP PAST
; THE SIX FAT CONTROL BYTES
CC85  A6 24                      LDA   FCBSEC,Y            ; GET CURRENT SECTOR FOR THIS GRANULE
CC87  81 09                      CMPA  #$09                ; MAX SECTOR NUMBER (9 SECTORS/GRANULE)
CC89  25 0E                      BLO   LCC99               ; BRANCH IF NOT AT END OF GRANULE
CC8B  6A 24                      DEC   FCBSEC,Y            ; *DECREMENT SECTOR NUMBER AND INCREMENT ERROR FLAG IN
CC8D  6C 25                      INC   FCBCPT,Y            ; *CASE ERROR FOUND WHILE LOOKING FOR NEXT GRANULE —
* THE ERROR FLAG IS USED TO INDICATE THAT ANOTHER SECTOR
* MUST BE ADDED TO THE LENGTH OF FILE FOLLOWING ERROR PROCESSING.
CC8F  BD C7 BF                   JSR   LC7BF               ; GET NEXT FREE GRANULE
CC92  6F 24                      CLR   FCBSEC,Y            ; *CLEAR SECTOR NUMBER AND
CC94  6F 25                      CLR   FCBCPT,Y            ; *ERROR FLAG - DISK WAS NOT FULL
CC96  A7 23                      STA   FCBCGR,Y            ; SAVE NEW GRANULE IN FCB
CC98  8C 8A C0                   CMPX  #$8AC0              ; SKIP TWO BYTES — NO DATA STORED IN NEW SECTOR YET
CC99  8A C0             LCC99    ORA   #$C0                ; FORCE GRANULE NUMBER TO BE FINAL GRANULE IN FILE
CC9B  A7 C4                      STA   ,U                  ; STORE IN MAP
CC9D  30 A4                      LEAX  ,Y                  ; POINT X TO FCB
CC9F  BD C6 85                   JSR   LC685               ; INCREMENT RECORD NUMBER
CCA2  BD C5 A9                   JSR   LC5A9               ; UPDATE FILE ALLOCATION TABLE
CCA5  35 60                      PULS  Y,U                 ; RESTORE REGISTERS
CCA7  35 96                      PULS  A,B,X,PC            ; RESTORE REGISTERS AND RETURN

* DIR COMMAND
CCA9  BD D2 4F          DIR      JSR   LD24F               ; SCAN DRIVE NUMBER FROM INPUT LINE
CCAC  BD C7 9D                   JSR   LC79D               ; GET FAT FOR THIS DRIVE
CCAF  BD B9 58                   JSR   LB958               ; PRINT CARRIAGE RETURN TO CONSOLE OUT
CCB2  CC 11 02                   LDD   #$1102              ; * GET TRACK 17 AND
CCB5  97 EC                      STA   DCTRK               ; * READ OP CODE AND
CCB7  D7 EA                      STB   DCOPC               ; * SAVE IN DSKCON VARIABLES
CCB9  C6 03                      LDB   #$03                ; START WITH SECTOR 3 (FIRST DIRECTORY SECTOR)

* READ A DIRECTORY SECTOR INTO THE I/O BUFFER
CCBB  D7 ED             LCCBB    STB   DSEC                ; SAVE SECTOR NUMBER IN DSKCON VARIABLE
CCBD  8E 06 00                   LDX   #DBUF0              ; * USE I/O BUFFER 0 FOR DATA TRANSFER
CCC0  9F EE                      STX   DCBPT               ; * SAVE IN DSKCON VARIABLE
CCC2  BD D6 F2                   JSR   LD6F2               ; READ A SECTOR

* SEND DIRECTORY INFORMATION TO CONSOLE OUT
CCC5  35 40             LCCC5    PULS  U                   ; SAVE TOP OF STACK
CCC7  BD A5 49                   JSR   LA549               ; GO DO A BREAK CHECK
CCCA  34 40                      PSHS  U                   ; RESTORE STACK
CCCC  A6 84                      LDA   DIRNAM,X            ; TEST FILE NAME FIRST BYTE
CCCE  27 38                      BEQ   LCD08               ; BRANCH IF KILLED
CCD0  43                         COMA                      ; FF = END OF DIRECTORY
CCD1  27 44                      BEQ   LCD17               ; RETURN IF END OF DIRECTORY
CCD3  34 10                      PSHS  X                   ; SAVE DIRECTORY POINTER ON STACK
CCD5  C6 08                      LDB   #$08                ; NUMBER CHARACTERS TO PRINT
CCD7  BD B9 A2                   JSR   LB9A2               ; SEND FILENAME TO CONSOLE OUT
CCDA  8D 3F                      BSR   LCD1B               ; SEND BLANK TO CONSOLE OUT
CCDC  C6 03                      LDB   #$03                ; NUMBER CHARACTERS TO PRINT
CCDE  BD B9 A2                   JSR   LB9A2               ; SEND EXTENSION TO CONSOLE OUT
CCE1  8D 38                      BSR   LCD1B               ; SEND BLANK TO CONSOLE OUT
CCE3  E6 00                      LDB   FCBTYP,X            ; GET FILE TYPE
CCE5  C1 0A                      CMPB  #10                 ; * CHECK THE NUMBER OF DECIMAL DIGITS IN
CCE7  24 02                      BHS   LCCEB               ; * ACCB: IF THERE IS ONLY ONE DIGIT,
CCE9  8D 30                      BSR   LCD1B               ; * SEND BLANK TO CONSOLE OUT
CCEB  4F                LCCEB    CLRA                      ; CLEAR MS BYTE OF ACCO
CCEC  BD BD CC                   JSR   LBDCC               ; PRINT ACCD IN DECIMAL TO CONSOLE OUT
CCEF  8D 2A                      BSR   LCD1B               ; SEND BLANK TO CONSOLE OUT
CCF1  AE E4                      LDX   ,S                  ; X NOW POINTS TO DIRECTORY ENTRY
CCF3  86 42                      LDA   #'A'+1              ; ASCII BIAS
CCF5  AB 0C                      ADDA  DIRASC,X            ; ADD TO ASCII FLAG
CCF7  8D 1F                      BSR   LCD18               ; PRINT CHARACTER AND BLANK TO CONSOLE OUT
CCF9  E6 0D                      LDB   DIRGRN,X            ; GET FIRST GRANULE IN FILE
CCFB  8D 21                      BSR   LCD1E               ; COUNT GRANULES
CCFD  1F 89                      TFR   A,B                 ; SAVE COUNT IN ACCB
CCFF  4F                         CLRA                      ; CLEAR MS BYTE OF ACCD
CD00  BD BD CC                   JSR   LBDCC               ; PRINT ACCO IN DECIMAL TO CONSOLE OUT
CD03  BD B9 58                   JSR   LB958               ; SEND CARRIAGE RETURN TO CONSOLE OUT
CD06  35 10                      PULS  X                   ; PULL DIRECTORY POINTER OFF OF THE STACK
CD08  30 88 20          LCD08    LEAX  DIRLEN,X            ; MOVE X TO NEXT DIRECTORY ENTRY
CD0B  8C 07 00                   CMPX  #DBUF0+SECLEN       ; END OF I/O BUFFER?
CD0E  25 B5                      BLO   LCCC5               ; BRANCH IF MORE DIRECTORY ENTRIES IN BUFFER
CD10  D6 ED                      LDB   DSEC                ; GET CURRENT SECTOR
CD12  5C                         INCB                      ; BUMP COUNT
CD13  C1 12                      CMPB  #SECMAX             ; SECMAX SECTORS IN DIRECTORY TRACK
CD15  23 A4                      BLS   LCCBB               ; GET NEXT SECTOR
CD17  39                LCD17    RTS                       ; FINISHED
CD18  BD A2 82          LCD18    JSR   LA282               ; SEND CHARACTER TO CONSOLE OUT
CD1B  7E B9 AC          LCD1B    JMP   LB9AC               ; SEND BLANK TO CONSOLE OUT

* ENTER WITH ACCB POINTING TO FIRST GRANULE IN A FILE; RETURN THE NUMBER OF
* GRANULES IN THE FILE IN ACCA, THE GRANULE DATA FOR THE LAST SECTOR IN ACCB
CD1E  BD C7 55          LCD1E    JSR   LC755               ; POINT X TO FILE ALLOCATION BUFFER
CD21  33 06                      LEAU  FATCON,X            ; POINT U TO START OF GRANULE DATA
CD23  4F                         CLRA                      ; RESET GRANULE COUNTER
CD24  4C                LCD24    INCA                      ; INCREMENT GRANULE COUNTER
CD25  81 44                      CMPA  #GRANMX             ; CHECKED ALL 68 GRANULES?
CD27  10 22 F9 28                LBHI  LC653               ; YES - 'BAD FILE STRUCTURE' ERROR
CD2B  30 C4                      LEAX  ,U                  ; POINT U TO START OF GRANULE DATA
CD2D  3A                         ABX                       ; ADD POINTER TO FIRST GRANULE
CD2E  E6 84                      LDB   ,X                  ; GET THIS GRANULE'S CONTROL BYTE
CD30  C1 C0                      CMPB  #$C0                ; IS THIS THE LAST GRANULE IN FILE?
CD32  25 F0                      BLO   LCD24               ; NO - KEEP GOING
CD34  39                         RTS

* INPUT RAM HOOK
CD35  0D 6F             DVEC10   TST   DEVNUM              ; * CHECK DEVICE NUMBER AND RETURN
CD37  2F 5E                      BLE   LCD97               ; * IF NOT A DISK FILE
CD39  8E B0 69                   LDX   #LB069              ; = CHANGE THE RETURN ADDRESS ON THE STACK TO RE-ENTER BASIC'S INPUT
CD3C  AF E4                      STX   ,S                  ; = ROUTINE AT A DIFFERENT PLACE THAN THE CALLING ROUTINE
CD3E  8E 02 DD                   LDX   #LINBUF+1           ; POINT X TO THE LINE INPUT BUFFER
CD41  C6 2C                      LDB   #','                ; =
CD43  D7 01                      STB   CHARAC              ; =COMMA IS READ ITEM SEPARATOR (TEMPORARY STRING SEARCH FLAG)
CD45  96 06                      LDA   VALTYP              ; * GET VARIABLE TYPE AND BRANCH IF
CD47  26 02                      BNE   LCD4B               ; * IT IS A STRING
CD49  C6 20                      LDB   #SPACE              ; SPACE = NUMERIC SEARCH DELIMITER
CD4B  8D 6F             LCD4B    BSR   LCDBC               ; GET AN INPUT CHARACTER
CD4D  81 20                      CMPA  #SPACE              ; SPACE?
CD4F  27 FA                      BEQ   LCD4B               ; YES - GET ANOTHER CHARACTER
CD51  81 22                      CMPA  #'"'                ; QUOTE?
CD53  26 0A                      BNE   LCD5F               ; NO
CD55  C1 2C                      CMPB  #','                ; SEARCH CHARACTER = COMMA?
CD57  26 06                      BNE   LCD5F               ; NO - NUMERIC SEARCH
CD59  1F 89                      TFR   A,B                 ; * SAVE DOUBLE QUOTE AS
CD5B  D7 01                      STB   CHARAC              ; * THE SEARCH FLAG
CD5D  20 22                      BRA   LCD81               ; SAVE DOUBLE QUOTES AS FIRST ITEM IN BUFFER

CD5F  C1 22             LCD5F    CMPB  #'"'                ; *
CD61  27 11                      BEQ   LCD74               ; *BRANCH IF INPUTTING A STRING VARIABLE
CD63  81 0D                      CMPA  #CR                 ; IS THE INPUT CHARACTER A CARRIAGE RETURN
CD65  26 0D                      BNE   LCD74               ; NO
CD67  8C 02 DD                   CMPX  #LINBUF+1           ; *IF AT THE START OF INPUTBUFFER, CHECK FOR A
CD6A  27 44                      BEQ   LCDB0               ; *FOLLOWING LINE FEED AND EXIT ROUTINE
CD6C  A6 1F                      LDA   -1,X                ; =IF THE INPUT CHARACTER PRECEEDING THE CR WAS A LINE FEED,
CD6E  81 0A                      CMPA  #LF                 ; =THEN INSERT THE CR IN THE INPUT STRING, OTHERWISE
CD70  26 3E                      BNE   LCDB0               ; =CHECK FOR A FOLLOWING LINE FEED AND EXIT THE ROUTINE
CD72  86 0D                      LDA   #CR                 ; RESTORE CARRIAGE RETURN AS THE INPUT CHARACTER
CD74  4D                LCD74    TSTA                      ; *CHECK FOR A NULL (ZERO) INPUT CHARACTER AND
CD75  27 17                      BEQ   LCD8E               ; *IGNORE IT IF lT IS A NULL
CD77  91 01                      CMPA  CHARAC              ; =
CD79  27 1D                      BEQ   LCD98               ; =CHECK TO SEE IF THE INPUT CHARACTER MATCHES
CD7B  34 04                      PSHS  B                   ; =EITHER ACCB OR CHARAC AND IF IT DOES, THEN
CD7D  A1 E0                      CMPA  ,S+                 ; =BRANCH TO CHECK FOR ITEM SEPARATOR OR
CD7F  27 17                      BEQ   LCD98               ; =TERMINATOR SEQUENCE AND EXIT ROUTINE
CD81  A7 80             LCD81    STA   ,X+                 ; STORE NEW CHARACTER IN BUFFER
CD83  8C 03 D6                   CMPX  #LINBUF+LBUFMX      ; END OF INPUT BUFFER
CD86  26 06                      BNE   LCD8E               ; NO
CD88  8D 46                      BSR   LCDD0               ; GET A CHARACTER FROM CONSOLE IN
CD8A  26 06                      BNE   LCD92               ; EXIT ROUTINE IF BUFFER EMPTY
CD8C  20 1E                      BRA   LCDAC               ; CHECK FOR CR OR CR/LF AND EXIT ROUTINE

CD8E  8D 40             LCD8E    BSR   LCDD0               ; GET A CHARACTER FROM CONSOLE IN
CD90  27 CD                      BEQ   LCD5F               ; BRANCH IF BUFFER NOT EMPTY
CD92  6F 84             LCD92    CLR   ,X                  ; PUT A ZERO AT END OF BUFFER WHEN DONE
CD94  8E 02 DC                   LDX   #LINBUF             ; POINT (X) TO LINBUF - RESET POINTER
CD97  39                LCD97    RTS

* CHECK FOR ITEM SEPARATOR OR TERMINATOR AND EXIT THE INPUT ROUTINE
CD98  81 22             LCD98    CMPA  #'"'                ; QUOTE?
CD9A  27 04                      BEQ   LCDA0               ; YES
CD9C  81 20                      CMPA  #SPACE              ; SPACE?
CD9E  26 F2                      BNE   LCD92               ; NO - EXIT ROUTINE
CDA0  8D 2E                      BSR   LCDD0               ; GET A CHARACTER FROM CONSOLE IN
CDA2  26 EE                      BNE   LCD92               ; EXIT ROUTINE IF BUFFER EMPTY
CDA4  81 20                      CMPA  #SPACE              ; SPACE?
CDA6  27 F8                      BEQ   LCDA0               ; YES - GET ANOTHER CHARACTER
CDA8  81 2C                      CMPA  #','                ; COMMA (ITEM SEPARATOR)?
CDAA  27 E6                      BEQ   LCD92               ; YES - EXIT ROUTINE
CDAC  81 0D             LCDAC    CMPA  #CR                 ; CARRIAGE RETURN?
CDAE  26 08                      BNE   LCDB8               ; NO
CDB0  8D 1E                      BSR   LCDD0               ; GET A CHARACTER FROM CONSOLE IN
CDB2  26 DE                      BNE   LCD92               ; EXIT ROUTINE IF BUFFER EMPTY
CDB4  81 0A                      CMPA  #LF                 ; LINE FEED? TREAT CR,LF AS A CR
CDB6  27 DA                      BEQ   LCD92               ; YES - EXIT ROUTINE
CDB8  8D 1C             LCDB8    BSR   LCDD6               ; BACK UP PTR INPUT POINTER ONE
CDBA  20 D6                      BRA   LCD92               ; EXIT ROUTINE

CDBC  8D 12             LCDBC    BSR   LCDD0               ; GET A CHAR FROM INPUT BUFFER - RETURN IN ACCA
CDBE  27 15                      BEQ   LCDD5               ; RETURN IF BUFFER NOT EMPTY
CDC0  BD C7 44                   JSR   LC744               ; POINT X TO START OF FILE BUFFER
CDC3  E6 00                      LDB   FCBTYP,X            ; GET FILE TYPE
CDC5  C1 40                      CMPB  #RANFIL             ; IS IT RANDOM FILE TYPE?
CDC7  10 26 F5 87                LBNE  LC352               ; 'INPUT PAST END OF FILE' ERROR IF NOT RANDOM
CDCB  C6 4A             LCDCB    LDB   #2*37               ; 'WRITE/INPUT PAST END OF RECORD' ERROR IF RANDOM
CDCD  7E AC 46                   JMP   LAC46               ; JUMP TO THE ERROR HANDLER

CDD0  BD A1 76          LCDD0    JSR   LA176               ; GET A CHAR FROM INPUT BUFFER
CDD3  0D 70                      TST   CINBFL              ; SET FLAGS ACCORDING TO CONSOLE INPUT FLAG
CDD5  39                LCDD5    RTS

* MOVE THE INPUT POINTER BACK ONE (DISK FILE)
CDD6  34 14             LCDD6    PSHS  X,B                 ; SAVE REGISTERS ON STACK
CDD8  BD C7 44                   JSR   LC744               ; POINT X TO PROPER FCB
CDDB  E6 00                      LDB   FCBTYP,X            ; GET FILE TYPE OF THIS FCB
CDDD  C1 40                      CMPB  #RANFIL             ; IS IT A RANDOM FILE?
CDDF  26 0B                      BNE   LCDEC               ; BRANCH IF NOT A RANDOM FILE
CDE1  EC 88 15                   LDD   FCBGET,X            ; *GRAB THE RANDOM FILE 'GET' POINTER,
CDE4  83 00 01                   SUBD  #$0001              ; *MOVE IT BACK ONE AND RESTORE IT
CDE7  ED 88 15                   STD   FCBGET,X            ; *
CDEA  35 94                      PULS  B,X,PC              ; RESTORE REGISTERS AND RETURN
CDEC  A7 88 11          LCDEC    STA   FCBCDT,X            ; SAVE THE CHARACTER IN THE CACHE
CDEF  63 88 10                   COM   FCBCFL,X            ; SET THE CACHE FLAG TO $FF - DATA IN CACHE
CDF2  35 94                      PULS  B,X,PC              ; RESTORE REGISTERS AND RETURN

* CVN COMMAND
CDF4  BD B6 54          CVN      JSR   LB654               ; GET LENGTH AND ADDRESS OF STRING
CDF7  C1 05                      CMPB  #$05                ; FIVE BYTES IN A FLOATING POINT NUMBER
CDF9  10 25 E6 4D                LBCS  LB44A               ; 'FC' ERROR IF <> 5 BYTES
CDFD  0F 06                      CLR   VALTYP              ; SET VARIABLE TYPE TO NUMERIC
CDFF  7E BC 14                   JMP   LBC14               ; COPY A PACKED FP NUMBER FROM (X) TO FPA0
