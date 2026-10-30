; Disk Extended Color BASIC 1.0 -- $C000-$C0D3
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: DOSBAS=$C000, DCNVEC=$C004, DSKVAR=$C006

      00 E1             DHITOK   EQU   $E0                 ; HIGHEST 1.0 DISK TOKEN
      00 32             CYEAR    EQU   '2'
*
*
*
**
**** FILE ALLOCATION TABLE FORMAT
**
*
* THE FILE ALLOCATION TABLE (FAT) CONTAINS THE STATUS OF THE GRANULES ON A DISKETTE.
* THE FAT CONTAINS 6 CONTROL BYTES FOLLOWED BY 68 DATA BYTES (ONE PER GRANULE). ONLY THE
* FIRST TWO OF THE SIX CONTROL BYTES ARE USED. A VALUE OF $FF IS SAVED IN UNALLOCATED
* GRANULES. IF BITS 6 & 7 OF THE DATA BYTE ARE SET, THE GRANULE IS THE LAST GRANULE
* IN A FILE AND BITS 0-5 ARE THE NUMBER OF USED SECTORS IN THAT GRANULE. IF BITS 6 & 7
* ARE NOT SET, THE DATA BYTE CONTAINS THE NUMBER OF THE NEXT GRANULE IN THE FILE.

* OFFSETS TO FAT CONTROL BYTES
      00 00             FAT0     EQU   0                   ; ACTIVE FILE COUNTER : DISK TO RAM FAT IMAGE DISABLE
      00 01             FAT1     EQU   1                   ; VALID DATA FLAG: 0=DISK DATA VALID, <> 0 = NEW FAT
* DATA - DISK DATA INVALID
* NOT USED
      00 06             FATCON   EQU   6                   ; OFFSET TO START OF FAT DATA (68 BYTES)
*
**
**** DIRECTORY ENTRY FORMAT
**
*
* THE DIRECTORY IS USED TO KEEP TRACK OF HOW MANY FILES ARE STORED ON A DISKETTE
* AND WHERE THE FILE IS STORED ON THE DISK. THE FIRST GRANULE USED BY THE FILE WILL
* ALLOW THE FAT TO TRACK DOWN ALL OF THE GRANULES USED BY THE FILE. IF THE FIRST
* BYTE OF THE DIRECTORY ENTRY IS ZERO, THE FILE HAS BEEN KILLED;
* IF THE FIRST BYTE IS $FF THEN THE DIRECTORY ENTRY HAS NEVER BEEN USED.
*
* DESCRIPTION

      00 00             DIRNAM   EQU   0                   ; FILE NAME
      00 08             DIREXT   EQU   8                   ; FILE EXTENSION
      00 0B             DIRTYP   EQU   11                  ; FILE TYPE
      00 0C             DIRASC   EQU   12                  ; ASCII FLAG
      00 0D             DIRGRN   EQU   13                  ; FIRST GRANULE IN FILE
      00 0E             DIRLST   EQU   14                  ; NUMBER OF BYTES IN LAST SECTOR
* UNUSED
*
**
**** FILE CONTROL BLOCK FORMAT
**
*
* THE FILE STRUCTURE OF COLOR TRS DOS IS CONTROLLED BY A FILE CONTROL BLOCK (FCB)
* THE FCB CONTAINS 25 CONTROL BYTES AND A SECTOR LONG (256 BYTES) DATA BUFFER.
* THE CONTROL BYTES CONTROL THE ORDERLY FLOW OF DATA FROM THE COMPUTER'S RAM TO
* THE DISKETTE AND VICE VERSA. THE OPEN COMMAND INITIALIZES THE FCB; THE INPUT,
* OUTPUT, WRITE, PRINT, GET AND PUT COMMANDS TRANSFER DATA THROUGH THE FCB AND
* THE CLOSE COMMAND TURNS OFF THE FCB.

* TABLES OF OFFSETS TO FCB CONTROL BYTES

***** RANDOM FILE
* DESCRIPTION
      00 00             FCBTYP   EQU   0                   ; FILE TYPE: $40=RANDOM/DIRECT, 0=CLOSED
      00 01             FCBDRV   EQU   1                   ; DRIVE NUMBER
      00 02             FCBFGR   EQU   2                   ; FIRST GRANULE IN FILE
      00 03             FCBCGR   EQU   3                   ; CURRENT GRANULE BEING USED
      00 04             FCBSEC   EQU   4                   ; CURRENT SECTOR BEING USED (1-9)
* UNUSED
      00 06             FCBPOS   EQU   6                   ; CURRENT PRINT POSITION - ALWAYS ZERO IN RANDOM FILES
      00 07             FCBREC   EQU   7                   ; CURRENT RECORD NUMBER
      00 09             FCBRLN   EQU   9                   ; RANDOM FILE RECORD LENGTH
      00 0B             FCBBUF   EQU   11                  ; POINTER TO START OF THIS FILE'S RANDOM ACCESS BUFFER
      00 0D             FCBSOF   EQU   13                  ; SECTOR OFFSET TO CURRENT POSITION IN RECORD
      00 0F             FCBFLG   EQU   15                  ; GET/PUT FLAG: 0=PUT, 1=PUT
* NOT USED
      00 12             FCBDIR   EQU   18                  ; DIRECTORY ENTRY NUMBER (0-71)
      00 13             FCBLST   EQU   19                  ; NUMBER OF BYTES IN LAST SECTOR OF FILE
      00 15             FCBGET   EQU   21                  ; 'GET' RECORD COUNTER: HOW MANY CHARACTERS HAVE BEEN
* PULLED OUT OF THE CURRENT RECORD
      00 17             FCBPUT   EQU   23                  ; 'PUT' RECORD COUNTER: POINTER TO WHERE IN THE RECORD THE NEXT
* BYTE WILL BE 'PUT'
      00 19             FCBCON   EQU   25                  ; OFFSET TO START OF FCB DATA BUFFER (256 BYTES)

***** SEQUENTIAL FILE
* DESCRIPTION
      00 00             FCBTYP   EQU   0                   ; FILE TYPE: $10=INPUT, $20=OUTPUT, 0=CLOSED
      00 01             FCBDRV   EQU   1                   ; DRIVE NUMBER
      00 02             FCBFGR   EQU   2                   ; FIRST GRANULE IN FILE
      00 03             FCBCGR   EQU   3                   ; CURRENT GRANULE BEING USED
      00 04             FCBSEC   EQU   4                   ; CURRENT SECTOR BEING USED (1-9)
                        FCBCPT   EQU   5                   ; INPUT FILE: CHARACTER POINTER - POINTS TO NEXT CHARACTER IN
* FILE TO BE PROCESSED.
* OUTPUT FILE: FULL SECTOR FLAG - IF IT IS 1 WHEN THE FILE IS
* CLOSED IT MEANS 256 BYTES OF THE LAST SECTOR HAVE BEEN USED.
      00 06             FCBPOS   EQU   6                   ; CURRENT PRINT POSITION
      00 07             FCBREC   EQU   7                   ; CURRENT RECORD NUMBER: HOW MANY WHOLE SECTORS HAVE BEEN
* INPUT OR OUTPUT TO A FILE.
* UNUSED
      00 10             FCBRLN   EQU   16                  ; CACHE FLAG: 00=CACHE EMPTY, $FF=CACHE FULL
      00 11             FCBCDT   EQU   17                  ; CACHE DATA BYTE
      00 12             FCBDIR   EQU   18                  ; DIRECTORY ENTRY NUMBER (0-71)
      00 13             FCBLST   EQU   19                  ; NUMBER OF BYTES IN LAST SECTOR OF FILE
* UNUSED
      00 17             FCBDFL   EQU   23                  ; INPUT FILE ONLY: DATA LEFT FLAG: 0=DATA LEFT, $FF=NO DATA (EMPTY)
      00 18             FCBLFT   EQU   24                  ; NUMBER OF CHARACTERS LEFT IN BUFFER (INPUT FILE)
* NUMBER OF CHARS STORED IN BUFFER (OUTPUT FILE)
      00 19             FCBCON   EQU   25                  ; OFFSET TO FCB DATA BUFFER (256 BYTES)

                                 ORG   $C000

C000  44 4B             DOSBAS   FCC   'DK'
C002  20 04             LC002    BRA   LC008

C004  D6 6C             DCNVEC   FDB   DSKCON              ; DSKCON POINTER
C006  00 EA             DSKVAR   FDB   $00EA               ; ADDRESS OF DSKCON VARIABLES

**** ZERO OUT THE RAM USED BY DISK BASIC
C008  8E 06 00          LC008    LDX   #DBUF0              ; POINT X TO START OF DISK RAM
C00B  6F 80             LC00B    CLR   ,X+                 ; CLEAR A BYTE
C00D  8C 09 89                   CMPX  #DFLBUF             ; END OF DISK'S RAM?
C010  26 F9                      BNE   LC00B               ; NO - KEEP CLEARING
C012  8E C0 F6                   LDX   #LC0F6              ; POINT X TO ROM IMAGE OF COMMAND INTERPRETATION TABLE
C015  CE 01 34                   LDU   #COMVEC+20          ; POINT U TO RAM ADDRESS OF SAME
C018  C6 0A                      LDB   #10                 ; 10 BYTES PER TABLE
C01A  BD A5 9A                   JSR   LA59A               ; MOVE (B) BYTES FROM (X) TO (U)
C01D  CC B2 77                   LDD   #LB277              ; SYNTAX ERROR ADDRESS
C020  ED 43                      STD   $03,U               ; * SET JUMP TABLE ADDRESSES OF THE USER COMMAND
C022  ED 48                      STD   $08,U               ; * INTERPRETATION TABLE TO POINT TO SYNTAX ERROR
C024  6F C4                      CLR   ,U                  ; CLEAR BYTE 0 OF USER TABLE (DOESN'T EXIST FLAG)
C026  6F 45                      CLR   $05,U               ; SET NUMBER OF SECONDARY USER TOKENS TO ZERO
C028  CC CE 2E                   LDD   #DXCVEC             ; * SAVE NEW
C02B  FD 01 2D                   STD   COMVEC+13           ; * POINTERS TO EXBAS
C02E  CC CE 56                   LDD   #DXIVEC             ; * COMMAND AND SECONDARY
C031  FD 01 32                   STD   COMVEC+18           ; * COMMAND INTERPRETATION ROUTINES
**** MOVE THE NEW RAM VECTORS FROM ROM TO RAM
C034  CE 01 5E                   LDU   #RVEC0              ; POINT U TO 1ST RAM VECTOR
C037  86 7E             LC037    LDA   #$7E                ; OP CODE OF JMP INSTRUCTION
C039  B7 01 A0                   STA   RVEC22              ; SET 1ST BYTE OF 'GET'/'PUT' RAM VECTOR TO 'JMP'
C03C  A7 C0                      STA   ,U+                 ; SET 1ST BYTE OF RAM VECTOR TO 'JMP'
C03E  EC 81                      LDD   ,X++                ; GET RAM VECTOR FROM ROM
C040  ED C1                      STD   ,U++                ; STORE IT IN RAM
C042  8C C1 26                   CMPX  #LC126              ; COMPARE TO END OF ROM VALUES
C045  26 F0                      BNE   LC037               ; BRANCH IF NOT ALL VECTORS MOVED
C047  8E C2 9A                   LDX   #DVEC22             ; GET ROM VALUE OF 'GET'/'PUT' RAM VECTOR
C04A  BF 01 A1                   STX   RVEC22+1            ; SAVE IT IN RAM
**** INITIALIZE DISK BASIC'S USR VECTORS
C04D  8E 09 5F                   LDX   #DUSRVC             ; POINT X TO START OF DISK BASIC USR VECTORS
C050  9F B0                      STX   USRADR              ; SAVE START ADDRESS IN USRADR
C052  CE B4 4A                   LDU   #LB44A              ; POINT U TO ADDRESS OF 'FUNCTION CALL' ERROR
C055  C6 0A                      LDB   #10                 ; 10 USER VECTORS TO INITIALIZE
C057  EF 81             LC057    STU   ,X++                ; SET USR VECTOR TO 'FC' ERROR
C059  5A                         DECB                      ; DECREMENT USR VECTOR COUNTER
C05A  26 FB                      BNE   LC057               ; BRANCH IN NOT DONE WITH ALL 10 VECTORS
C05C  8E D7 AE                   LDX   #DNMISV             ; GET ADDRESS OF NMI SERVICING ROUTINE
C05F  BF 01 0A                   STX   NMIVEC+1            ; SAVE IT IN NMI VECTOR
C062  86 7E                      LDA   #$7E                ; OP CODE OF JMP
C064  B7 01 09                   STA   NMIVEC              ; MAKE THE NMI VECTOR A JMP
C067  8E D7 BC                   LDX   #DIRQSV             ; GET ADDRESS OF DISK BASIC IRQ SERVICING ROUTINE
C06A  BF 01 0D                   STX   IRQVEC+1            ; SAVE IT IN IRQVEC
C06D  86 13                      LDA   #19                 ; = INITIALIZE WRITE FAT
C06F  B7 09 7A                   STA   WFATVL              ; = TO DISK TRIGGER VALUE
C072  7F 08 00                   CLR   FATBL0              ; *
C075  7F 08 4A                   CLR   FATBL1              ; * INITIALIZE THE ACTIVE FILE COUNTER OF
C078  7F 08 94                   CLR   FATBL2              ; * EACH FAT TO ZERO. THIS WILL CAUSE THE FATS
C07B  7F 08 DE                   CLR   FATBL3              ; * TO THINK THERE ARE NO ACTIVE FILES
C07E  8E 09 89                   LDX   #DFLBUF             ; = GET THE STARTING ADDRESS OF THE
C081  BF 09 48                   STX   RNBFAD              ; = RANDOM FILE BUFFER FREE AREA AND DAVE IT AS THE
C084  30 89 01 00                LEAX  256,X               ; = START ADDRESS OF FREE RAM FOR RANDOM FILE BUFFERS
C088  BF 09 4A                   STX   FCBADR              ; SAVE 256 BYTES FOR RANDOM FILE BUFFERS INITIALLY
* SAVE START ADDRESS OF FCBS
C08B  30 01                      LEAX  $01,X               ; * ADD ONE AND SAVE THE STARTING
C08D  BF 09 28                   STX   FCBV1               ; * ADDRESS OF FCB1
C090  6F 00                      CLR   FCBTYP,X            ; CLEAR THE FIRST BYTE OF FCB 1 (CLOSE FCB)
C092  30 89 01 19                LEAX  FCBLEN,X            ; POINT X TO FCB 2
C096  BF 09 2A                   STX   FCBV1+2             ; SAVE ITS STARTING ADDRESS IN FCB VECTOR TABLE
C099  6F 00                      CLR   FCBTYP,X            ; CLEAR THE FIRST BYTE OF FCB 2 (CLOSE FCB)
C09B  30 89 01 19                LEAX  FCBLEN,X            ; * POINT X TO SYSTEM FCB - THIS FCB WILL ONLY
* * BE USED TO COPY, LOAD, SAVE, MERGE, ETC
C09F  BF 09 2C                   STX   FCBV1+4             ; SAVE ITS ADDRESS IN THE FCB VECTOR TABLE
C0A2  6F 00                      CLR   FCBTYP,X            ; CLEAR THE FIRST BYTE OF SYSTEM FCB (CLOSE FCB)
C0A4  86 02                      LDA   #$02                ; * SET THE NUMBER OF ACTIVE RESERVED
C0A6  B7 09 5B                   STA   FCBACT              ; * FILE BUFFERS TO 2 (1,2)
C0A9  30 89 01 19                LEAX  FCBLEN,X            ; POINT X TO ONE PAST THE END OF SYSTEM FCB
C0AD  1F 10                      TFR   X,D                 ; SAVE THE ADDRESS IN ACCD
C0AF  5D                         TSTB                      ; ON AN EVEN 256 BYTE BOUNDARY?
C0B0  27 01                      BEQ   LC0B3               ; YES
C0B2  4C                         INCA                      ; NO - ADD 256 TO ADDRESS
C0B3  1F 89             LC0B3    TFR   A,B                 ; COPY ACCA TO ACCB
C0B5  CB 18                      ADDB  #24                 ; SAVE ENOUGH ROOM FOR 4 GRAPHICS PAGES (PCLEAR 4)
C0B7  D7 19                      STB   TXTTAB              ; SAVE NEW START OF BASIC ADDRESS
C0B9  BD 96 EC                   JSR   L96EC               ; INITIALIZE EXBAS VARIABLES & DO A NEW
C0BC  96 BA                      LDA   BEGGRP              ; GET THE START OF CURRENT GRAPHICS PAGE
C0BE  8B 06                      ADDA  #$06                ; ADD 1.5K (6 X 256 = ONE GRAPHICS PAGE)
C0C0  97 B7                      STA   ENDGRP              ; SAVE NEW END OF GRAPHICS PAGE
C0C2  8D 19                      BSR   LC0DD               ; GO INITIALIZE THE FLOPPY DISK CONTROLLER
C0C4  1C AF                      ANDCC #$AF                ; TURN ON IRQ AND FIRQ
C0C6  8E C1 25                   LDX   #LC125              ; POINT X TO DISK BASIC COPYRIGHT MESSAGE
C0C9  BD B9 9C                   JSR   STRINOUT            ; PRINT COPYRIGHT MESSAGE TO SCREEN
C0CC  8E C0 D4                   LDX   #DKWMST             ; GET DISK BASIC WARM START ADDRESS
C0CF  9F 72                      STX   RSTVEC              ; SAVE IT IN RESET VECTOR
C0D1  7E A0 E2                   JMP   LA0E2               ; JUMP BACK TO BASIC
