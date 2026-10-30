; Disk Extended Color BASIC 1.0 -- $CBCF-$CD5A
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: DIR=$CBCF, DVEC10=$CC5B, CVN=$CD1A, MKN=$CD28, LOC=$CD36

* DIR COMMAND
CBCF  BD D1 62          DIR      JSR   LD162               ; SCAN DRIVE NUMBER FROM INPUT LINE
CBD2  BD C7 6D                   JSR   LC76D               ; GET FAT FOR THIS DRIVE
CBD5  BD B9 58                   JSR   LB958               ; PRINT CARRIAGE RETURN TO CONSOLE OUT
CBD8  CC 11 02                   LDD   #$1102              ; * GET TRACK 17 AND
CBDB  97 EC                      STA   DCTRK               ; * READ OP CODE AND
CBDD  D7 EA                      STB   DCOPC               ; * SAVE IN DSKCON VARIABLES
CBDF  C6 03                      LDB   #$03                ; START WITH SECTOR 3 (FIRST DIRECTORY SECTOR)

* READ A DIRECTORY SECTOR INTO THE I/O BUFFER
CBE1  D7 ED             LCBE1    STB   DSEC                ; SAVE SECTOR NUMBER IN DSKCON VARIABLE
CBE3  8E 06 00                   LDX   #DBUF0              ; * USE I/O BUFFER 0 FOR DATA TRANSFER
CBE6  9F EE                      STX   DCBPT               ; * SAVE IN DSKCON VARIABLE
CBE8  BD D5 FF                   JSR   LD5FF               ; READ A SECTOR

* SEND DIRECTORY INFORMATION TO CONSOLE OUT
CBEB  35 40             LCBEB    PULS  U                   ; SAVE TOP OF STACK
CBED  BD A5 49                   JSR   LA549               ; GO DO A BREAK CHECK
CBF0  34 40                      PSHS  U                   ; RESTORE STACK
CBF2  A6 84                      LDA   DIRNAM,X            ; TEST FILE NAME FIRST BYTE
CBF4  27 38                      BEQ   LCC2E               ; BRANCH IF KILLED
CBF6  43                         COMA                      ; FF = END OF DIRECTORY
CBF7  27 44                      BEQ   LCC3D               ; RETURN IF END OF DIRECTORY
CBF9  34 10                      PSHS  X                   ; SAVE DIRECTORY POINTER ON STACK
CBFB  C6 08                      LDB   #$08                ; NUMBER CHARACTERS TO PRINT
CBFD  BD B9 A2                   JSR   LB9A2               ; SEND FILENAME TO CONSOLE OUT
CC00  8D 3F                      BSR   LCC41               ; SEND BLANK TO CONSOLE OUT
CC02  C6 03                      LDB   #$03                ; NUMBER CHARACTERS TO PRINT
CC04  BD B9 A2                   JSR   LB9A2               ; SEND EXTENSION TO CONSOLE OUT
CC07  8D 38                      BSR   LCC41               ; SEND BLANK TO CONSOLE OUT
CC09  E6 00                      LDB   FCBTYP,X            ; GET FILE TYPE
CC0B  C1 0A                      CMPB  #10                 ; * CHECK THE NUMBER OF DECIMAL DIGITS IN
CC0D  24 02                      BHS   LCC11               ; * ACCB: IF THERE IS ONLY ONE DIGIT,
CC0F  8D 30                      BSR   LCC41               ; * SEND BLANK TO CONSOLE OUT
CC11  4F                LCC11    CLRA                      ; CLEAR MS BYTE OF ACCO
CC12  BD BD CC                   JSR   LBDCC               ; PRINT ACCD IN DECIMAL TO CONSOLE OUT
CC15  8D 2A                      BSR   LCC41               ; SEND BLANK TO CONSOLE OUT
CC17  AE E4                      LDX   ,S                  ; X NOW POINTS TO DIRECTORY ENTRY
CC19  86 42                      LDA   #'A'+1              ; ASCII BIAS
CC1B  AB 0C                      ADDA  DIRASC,X            ; ADD TO ASCII FLAG
CC1D  8D 1F                      BSR   LCC3E               ; PRINT CHARACTER AND BLANK TO CONSOLE OUT
CC1F  E6 0D                      LDB   DIRGRN,X            ; GET FIRST GRANULE IN FILE
CC21  8D 21                      BSR   LCC44               ; COUNT GRANULES
CC23  1F 89                      TFR   A,B                 ; SAVE COUNT IN ACCB
CC25  4F                         CLRA                      ; CLEAR MS BYTE OF ACCD
CC26  BD BD CC                   JSR   LBDCC               ; PRINT ACCD IN DECIMAL TO CONSOLE OUT
CC29  BD B9 58                   JSR   LB958               ; SEND CARRIAGE RETURN TO CONSOLE OUT
CC2C  35 10                      PULS  X                   ; PULL DIRECTORY POINTER OFF OF THE STACK
CC2E  30 88 20          LCC2E    LEAX  DIRLEN,X            ; MOVE X TO NEXT DIRECTORY ENTRY
CC31  8C 07 00                   CMPX  #DBUF0+SECLEN       ; END OF I/O BUFFER?
CC34  25 B5                      BLO   LCBEB               ; BRANCH IF MORE DIRECTORY ENTRIES IN BUFFER
CC36  D6 ED                      LDB   DSEC                ; GET CURRENT SECTOR
CC38  5C                         INCB                      ; BUMP COUNT
CC39  C1 12                      CMPB  #SECMAX             ; SECMAX SECTORS IN DIRECTORY TRACK
CC3B  23 A4                      BLS   LCBE1               ; GET NEXT SECTOR
CC3D  39                LCC3D    RTS                       ; FINISHED
CC3E  BD A2 82                   JSR   LA282               ; SEND CHARACTER TO CONSOLE OUT
CC41  7E B9 AC                   JMP   LB9AC               ; SEND BLANK TO CONSOLE OUT

* ENTER WITH ACCB POINTING TO FIRST GRANULE IN A FILE; RETURN THE NUMBER OF
* GRANULES IN THE FILE IN ACCA, THE GRANULE DATA FOR THE LAST SECTOR IN ACCB
CC44  BD C7 25          LCC44    JSR   LC725               ; POINT X TO FILE ALLOCATION BUFFER
CC47  33 06                      LEAU  FATCON,X            ; POINT U TO START OF GRANULE DATA
CC49  4F                         CLRA                      ; RESET GRANULE COUNTER
CC4A  4C                LCC4A    INCA                      ; INCREMENT GRANULE COUNTER
CC4B  81 44                      CMPA  #GRANMX             ; CHECKED ALL 68 GRANULES?
CC4D  10 22 F9 D5                LBHI  LC626               ; YES - 'BAD FILE STRUCTURE' ERROR
CC51  30 C4                      LEAX  ,U                  ; POINT U TO START OF GRANULE DATA
CC53  3A                         ABX                       ; ADD POINTER TO FIRST GRANULE
CC54  E6 84                      LDB   ,X                  ; GET THIS GRANULE'S CONTROL BYTE
CC56  C1 C0                      CMPB  #$C0                ; IS THIS THE LAST GRANULE IN FILE?
CC58  25 F0                      BLO   LCC4A               ; NO - KEEP GOING
CC5A  39                         RTS

* INPUT RAM HOOK
CC5B  0D 6F             DVEC10   TST   DEVNUM              ; * CHECK DEVICE NUMBER AND RETURN
CC5D  2F 5E                      BLE   LCCBD               ; * IF NOT A DISK FILE
CC5F  8E B0 69                   LDX   #LB069              ; = CHANGE THE RETURN ADDRESS ON THE STACK TO RE-ENTER BASIC'S INPUT
CC62  AF E4                      STX   ,S                  ; = ROUTINE AT A DIFFERENT PLACE THAN THE CALLING ROUTINE
CC64  8E 02 DD                   LDX   #LINBUF+1           ; POINT X TO THE LINE INPUT BUFFER
CC67  C6 2C                      LDB   #','                ; =
CC69  D7 01                      STB   CHARAC              ; =COMMA IS READ ITEM SEPARATOR (TEMPORARY STRING SEARCH FLAG)
CC6B  96 06                      LDA   VALTYP              ; * GET VARIABLE TYPE AND BRANCH IF
CC6D  26 02                      BNE   LCC71               ; * IT IS A STRING
CC6F  C6 20                      LDB   #SPACE              ; SPACE = NUMERIC SEARCH DELIMITER
CC71  8D 6F             LCC71    BSR   LCCE2               ; GET AN INPUT CHARACTER
CC73  81 20                      CMPA  #SPACE              ; SPACE?
CC75  27 FA                      BEQ   LCC71               ; YES - GET ANOTHER CHARACTER
CC77  81 22                      CMPA  #'"'                ; QUOTE?
CC79  26 0A                      BNE   LCC85               ; NO
CC7B  C1 2C                      CMPB  #','                ; SEARCH CHARACTER = COMMA?
CC7D  26 06                      BNE   LCC85               ; NO - NUMERIC SEARCH
CC7F  1F 89                      TFR   A,B                 ; * SAVE DOUBLE QUOTE AS
CC81  D7 01                      STB   CHARAC              ; * THE SEARCH FLAG
CC83  20 22                      BRA   LCCA7               ; SAVE DOUBLE QUOTES AS FIRST ITEM IN BUFFER

CC85  C1 22             LCC85    CMPB  #'"'                ; *
CC87  27 11                      BEQ   LCC9A               ; *BRANCH IF INPUTTING A STRING VARIABLE
CC89  81 0D                      CMPA  #CR                 ; IS THE INPUT CHARACTER A CARRIAGE RETURN
CC8B  26 0D                      BNE   LCC9A               ; NO
CC8D  8C 02 DD                   CMPX  #LINBUF+1           ; *IF AT THE START OF INPUTBUFFER, CHECK FOR A
CC90  27 44                      BEQ   LCCD6               ; *FOLLOWING LINE FEED AND EXIT ROUTINE
CC92  A6 1F                      LDA   -1,X                ; =IF THE INPUT CHARACTER PRECEEDING THE CR WAS A LINE FEED,
CC94  81 0A                      CMPA  #LF                 ; =THEN INSERT THE CR IN THE INPUT STRING, OTHERWISE
CC96  26 3E                      BNE   LCCD6               ; =CHECK FOR A FOLLOWING LINE FEED AND EXIT THE ROUTINE
CC98  86 0D                      LDA   #CR                 ; RESTORE CARRIAGE RETURN AS THE INPUT CHARACTER
CC9A  4D                LCC9A    TSTA                      ; *CHECK FOR A NULL (ZERO) INPUT CHARACTER AND
CC9B  27 17                      BEQ   LCCB4               ; *IGNORE IT IF lT IS A NULL
CC9D  91 01                      CMPA  CHARAC              ; =
CC9F  27 1D                      BEQ   LCCBE               ; =CHECK TO SEE IF THE INPUT CHARACTER MATCHES
CCA1  34 04                      PSHS  B                   ; =EITHER ACCB OR CHARAC AND IF IT DOES, THEN
CCA3  A1 E0                      CMPA  ,S+                 ; =BRANCH TO CHECK FOR ITEM SEPARATOR OR
CCA5  27 17                      BEQ   LCCBE               ; =TERMINATOR SEQUENCE AND EXIT ROUTINE
CCA7  A7 80             LCCA7    STA   ,X+                 ; STORE NEW CHARACTER IN BUFFER
CCA9  8C 03 D6                   CMPX  #LINBUF+LBUFMX      ; END OF INPUT BUFFER
CCAC  26 06                      BNE   LCCB4               ; NO
CCAE  8D 46                      BSR   LCCF6               ; GET A CHARACTER FROM CONSOLE IN
CCB0  26 06                      BNE   LCCB8               ; EXIT ROUTINE IF BUFFER EMPTY
CCB2  20 1E                      BRA   LCCD2               ; CHECK FOR CR OR CR/LF AND EXIT ROUTINE

CCB4  8D 40             LCCB4    BSR   LCCF6               ; GET A CHARACTER FROM CONSOLE IN
CCB6  27 CD                      BEQ   LCC85               ; BRANCH IF BUFFER NOT EMPTY
CCB8  6F 84             LCCB8    CLR   ,X                  ; PUT A ZERO AT END OF BUFFER WHEN DONE
CCBA  8E 02 DC                   LDX   #LINBUF             ; POINT (X) TO LINBUF - RESET POINTER
CCBD  39                LCCBD    RTS

* CHECK FOR ITEM SEPARATOR OR TERMINATOR AND EXIT THE INPUT ROUTINE
CCBE  81 22             LCCBE    CMPA  #'"'                ; QUOTE?
CCC0  27 04                      BEQ   LCCC6               ; YES
CCC2  81 20                      CMPA  #SPACE              ; SPACE?
CCC4  26 F2                      BNE   LCCB8               ; NO - EXIT ROUTINE
CCC6  8D 2E             LCCC6    BSR   LCCF6               ; GET A CHARACTER FROM CONSOLE IN
CCC8  26 EE                      BNE   LCCB8               ; EXIT ROUTINE IF BUFFER EMPTY
CCCA  81 20                      CMPA  #SPACE              ; SPACE?
CCCC  27 F8                      BEQ   LCCC6               ; YES - GET ANOTHER CHARACTER
CCCE  81 2C                      CMPA  #','                ; COMMA (ITEM SEPARATOR)?
CCD0  27 E6                      BEQ   LCCB8               ; YES - EXIT ROUTINE
CCD2  81 0D             LCCD2    CMPA  #CR                 ; CARRIAGE RETURN?
CCD4  26 08                      BNE   LCCDE               ; NO
CCD6  8D 1E             LCCD6    BSR   LCCF6               ; GET A CHARACTER FROM CONSOLE IN
CCD8  26 DE                      BNE   LCCB8               ; EXIT ROUTINE IF BUFFER EMPTY
CCDA  81 0A                      CMPA  #LF                 ; LINE FEED? TREAT CR,LF AS A CR
CCDC  27 DA                      BEQ   LCCB8               ; YES - EXIT ROUTINE
CCDE  8D 1C             LCCDE    BSR   LCCFC               ; BACK UP PTR INPUT POINTER ONE
CCE0  20 D6                      BRA   LCCB8               ; EXIT ROUTINE

CCE2  8D 12             LCCE2    BSR   LCCF6               ; GET A CHAR FROM INPUT BUFFER - RETURN IN ACCA
CCE4  27 15                      BEQ   LCCFB               ; RETURN IF BUFFER NOT EMPTY
CCE6  BD C7 14                   JSR   LC714               ; POINT X TO START OF FILE BUFFER
CCE9  E6 00                      LDB   FCBTYP,X            ; GET FILE TYPE
CCEB  C1 40                      CMPB  #RANFIL             ; IS IT RANDOM FILE TYPE?
CCED  10 26 F6 43                LBNE  LC334               ; 'INPUT PAST END OF FILE' ERROR IF NOT RANDOM
CCF1  C6 4A             LCCF1    LDB   #2*37               ; 'WRITE/INPUT PAST END OF RECORD' ERROR IF RANDOM
CCF3  7E AC 46                   JMP   LAC46               ; JUMP TO THE ERROR HANDLER

CCF6  BD A1 76          LCCF6    JSR   LA176               ; GET A CHAR FROM INPUT BUFFER
CCF9  0D 70                      TST   CINBFL              ; SET FLAGS ACCORDING TO CONSOLE INPUT FLAG
CCFB  39                LCCFB    RTS

* MOVE THE INPUT POINTER BACK ONE (DISK FILE)
CCFC  34 14             LCCFC    PSHS  X,B                 ; SAVE REGISTERS ON STACK
CCFE  BD C7 14                   JSR   LC714               ; POINT X TO PROPER FCB
CD01  E6 00                      LDB   FCBTYP,X            ; GET FILE TYPE OF THIS FCB
CD03  C1 40                      CMPB  #RANFIL             ; IS IT A RANDOM FILE?
CD05  26 0B                      BNE   LCD12               ; BRANCH IF NOT A RANDOM FILE
CD07  EC 88 15                   LDD   FCBGET,X            ; *GRAB THE RANDOM FILE 'GET' POINTER,
CD0A  83 00 01                   SUBD  #$0001              ; *MOVE IT BACK ONE AND RESTORE IT
CD0D  ED 88 15                   STD   FCBGET,X            ; *
CD10  35 94                      PULS  B,X,PC              ; RESTORE REGISTERS AND RETURN
CD12  A7 88 11          LCD12    STA   FCBCDT,X            ; SAVE THE CHARACTER IN THE CACHE
CD15  63 88 10                   COM   FCBCFL,X            ; SET THE CACHE FLAG TO $FF - DATA IN CACHE
CD18  35 94                      PULS  B,X,PC              ; RESTORE REGISTERS AND RETURN

* CVN COMMAND
CD1A  BD B6 54          CVN      JSR   LB654               ; GET LENGTH AND ADDRESS OF STRING
CD1D  C1 05                      CMPB  #$05                ; FIVE BYTES IN A FLOATING POINT NUMBER
CD1F  10 25 E7 27                LBCS  LB44A               ; 'FC' ERROR IF <> 5 BYTES
CD23  0F 06                      CLR   VALTYP              ; SET VARIABLE TYPE TO NUMERIC
CD25  7E BC 14                   JMP   LBC14               ; COPY A PACKED FP NUMBER FROM (X) TO FPA0

* MKN$ COMMAND
CD28  BD B1 43          MKN      JSR   LB143               ; 'TM' ERROR IF VALTYP=STRING
CD2B  C6 05                      LDB   #$05                ; FIVE BYTES IN A FLOATING POINT NUMBER
CD2D  BD B5 0F                   JSR   LB50F               ; RESERVE FIVE BYTES IN STRING SPACE
CD30  BD BC 35                   JSR   LBC35               ; PACK FPA0 AND STORE IT IN STRING SPACE
CD33  7E B6 9B                   JMP   LB69B               ; SAVE STRING DESCRIPTOR ON STRING STACK

* LOC COMMAND
CD36  8D 05             LOC      BSR   LCD3D               ; POINT X TO FILE BUFFER
CD38  EC 07                      LDD   FCBREC,X            ; GET RECORD NUMBER (RANDOM FILE) OR SECTOR CTR (SEQUENTIAL)
CD3A  7E B4 F4          LCD3A    JMP   GIVABF              ; PUT ACCD IN FPA0

* STRIP A DEVICE NUMBER FROM A BASIC STATEMENT, SET PRINT
* PARAMETERS ACCORDING TO IT - ERROR IF FILE NOT
* OPEN. RETURN WITH (X) POINTING TO THAT FILE'S FCB
CD3D  96 6F             LCD3D    LDA   DEVNUM              ; * GET CURRENT DEVICE NUMBER AND
CD3F  34 02                      PSHS  A                   ; * SAVE IT ON THE STACK
CD41  BD B1 43                   JSR   LB143               ; 'TM' ERROR IF VALTYP=STRING
CD44  BD A5 AE                   JSR   LA5AE               ; CHECK FOR VALID DEVICE NUMBER/SET PRINT PARAMETERS
CD47  0D 6F                      TST   DEVNUM              ; * CHECK DEVICE NUMBER
CD49  10 2F E6 FD                LBLE  LB44A               ; * BRANCH IF NOT DISK FILE 'ILLEGAL FUNCTION CALL'
CD4D  BD C7 14                   JSR   LC714               ; POINT (X) TO FILE BUFFER
CD50  35 02                      PULS  A                   ; * GET OLD DEVICE NUMBER OFF OF THE STACK AND
CD52  97 6F                      STA   DEVNUM              ; * SAVE IT AS DEVICE NUMBER
CD54  6D 00                      TST   FCBTYP,X            ; IS FILE OPEN?
CD56  10 27 D6 A1                LBEQ  LA3FB               ; 'FILE NOT OPEN' ERROR IF NOT OPEN
CD5A  39                         RTS
