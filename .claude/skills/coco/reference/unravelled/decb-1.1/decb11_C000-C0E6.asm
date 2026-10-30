; Disk Extended Color BASIC 1.1 -- $C000-$C0E6
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: DOSBAS=$C000, DCNVEC=$C004, DSKVAR=$C006, DSINIT=$C008, DOSVEC=$C00A

      00 E0             DHITOK   EQU   $E1                 ; HIGHEST 1.1 DISK TOKEN
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
C002  20 08             LC002    BRA   LC00C

C004  D7 5F             DCNVEC   FDB   DSKCON              ; DSKCON POINTER
C006  00 EA             DSKVAR   FDB   DCOPC               ; ADDRESS OF DSKCON VARIABLES
C008  DF 4C             DSINIT   FDB   DOSINI              ; DISK INITIALIZATION VECTOR
C00A  DF 00             DOSVEC   FDB   DOSCOM              ; DOS COMMAND VECTOR

**** ZERO OUT THE RAM USED BY DISK BASIC
C00C  8E 06 00          LC00C    LDX   #DBUF0              ; POINT X TO START OF DISK RAM
C00F  6F 80             LC00F    CLR   ,X+                 ; CLEAR A BYTE
C011  8C 09 89                   CMPX  #DFLBUF             ; END OF DISK'S RAM?
C014  26 F9                      BNE   LC00F               ; NO - KEEP CLEARING
C016  8E C1 09                   LDX   #LC109              ; POINT X TO ROM IMAGE OF COMMAND INTERPRETATION TABLE
C019  CE 01 34                   LDU   #COMVEC+20          ; POINT U TO RAM ADDRESS OF SAME
C01C  C6 0A                      LDB   #10                 ; 10 BYTES PER TABLE
C01E  BD A5 9A                   JSR   LA59A               ; MOVE (B) BYTES FROM (X) TO (U)
C021  CC B2 77                   LDD   #LB277              ; SYNTAX ERROR ADDRESS
C024  ED 43                      STD   $03,U               ; * SET JUMP TABLE ADDRESSES OF THE USER COMMAND
C026  ED 48                      STD   $08,U               ; * INTERPRETATION TABLE TO POINT TO SYNTAX ERROR
C028  6F C4                      CLR   ,U                  ; CLEAR BYTE 0 OF USER TABLE (DOESN'T EXIST FLAG)
C02A  6F 45                      CLR   $05,U               ; SET NUMBER OF SECONDARY USER TOKENS TO ZERO
C02C  CC CF 0A                   LDD   #DXCVEC             ; * SAVE NEW
C02F  FD 01 2D                   STD   COMVEC+13           ; * POINTERS TO EXBAS
C032  CC CF 32                   LDD   #DXIVEC             ; * COMMAND AND SECONDARY
C035  FD 01 32                   STD   COMVEC+18           ; * COMMAND INTERPRETATION ROUTINES
**** MOVE THE NEW RAM VECTORS FROM ROM TO RAM
C038  CE 01 5E                   LDU   #RVEC0              ; POINT U TO 1ST RAM VECTOR
C03B  86 7E             LC03B    LDA   #$7E                ; OP CODE OF JMP INSTRUCTION
C03D  B7 01 A0                   STA   RVEC22              ; SET 1ST BYTE OF 'GET'/'PUT' RAM VECTOR TO 'JMP'
C040  A7 C0                      STA   ,U+                 ; SET 1ST BYTE OF RAM VECTOR TO 'JMP'
C042  EC 81                      LDD   ,X++                ; GET RAM VECTOR FROM ROM
C044  ED C1                      STD   ,U++                ; STORE IT IN RAM
C046  8C C1 39                   CMPX  #LC139              ; COMPARE TO END OF ROM VALUES
C049  26 F0                      BNE   LC03B               ; BRANCH IF NOT ALL VECTORS MOVED
C04B  8E C2 B2                   LDX   #DVEC22             ; GET ROM VALUE OF 'GET'/'PUT' RAM VECTOR
C04E  BF 01 A1                   STX   RVEC22+1            ; SAVE IT IN RAM
C051  8E C8 B0                   LDX   #DVEC20             ; GET DISK COMMAND INTERPRETATION LOOP RAM VECTOR
C054  BF 01 9B                   STX   RVEC20+1            ; SAVE IN RAM VECTOR TABLE
**** INITIALIZE DISK BASIC'S USR VECTORS
C057  8E 09 5F                   LDX   #DUSRVC             ; POINT X TO START OF DISK BASIC USR VECTORS
C05A  9F B0                      STX   USRADR              ; SAVE START ADDRESS IN USRADR
C05C  CE B4 4A                   LDU   #LB44A              ; POINT U TO ADDRESS OF 'FUNCTION CALL' ERROR
C05F  C6 0A                      LDB   #$0A                ; 10 USER VECTORS TO INITIALIZE
C061  EF 81             LC061    STU   ,X++                ; SET USR VECTOR TO 'FC' ERROR
C063  5A                         DECB                      ; DECREMENT USR VECTOR COUNTER
C064  26 FB                      BNE   LC061               ; BRANCH IN NOT DONE WITH ALL 10 VECTORS
C066  8E D8 A1                   LDX   #DNMISV             ; GET ADDRESS OF NMI SERVICING ROUTINE
C069  BF 01 0A                   STX   NMIVEC+1            ; SAVE IT IN NMI VECTOR
C06C  86 7E                      LDA   #$7E                ; OP CODE OF JMP
C06E  B7 01 09                   STA   NMIVEC              ; MAKE THE NMI VECTOR A JMP
C071  8E D8 AF                   LDX   #DIRQSV             ; GET ADDRESS OF DISK BASIC IRQ SERVICING ROUTINE
C074  BF 01 0D                   STX   IRQVEC+1            ; SAVE IT IN IRQVEC
C077  86 13                      LDA   #$13                ; = INITIALIZE WRITE FAT
C079  B7 09 7A                   STA   WFATVL              ; = TO DISK TRIGGER VALUE
C07C  7F 08 00                   CLR   FATBL0              ; *
C07F  7F 08 4A                   CLR   FATBL1              ; * INITIALIZE THE ACTIVE FILE COUNTER OF
C082  7F 08 94                   CLR   FATBL2              ; * EACH FAT TO ZERO. THIS WILL CAUSE THE FATS
C085  7F 08 DE                   CLR   FATBL3              ; * TO THINK THERE ARE NO ACTIVE FILES
C088  8E 09 89                   LDX   #DFLBUF             ; = GET THE STARTING ADDRESS OF THE
C08B  BF 09 48                   STX   RNBFAD              ; = RANDOM FILE BUFFER FREE AREA AND DAVE IT AS THE
* = START ADDRESS OF FREE RAM FOR RANDOM FILE BUFFERS
C08E  30 89 01 00                LEAX  $0100,X             ; SAVE 256 BYTES FOR RANDOM FILE BUFFERS INITIALLY
C092  BF 09 4A                   STX   FCBADR              ; SAVE START ADDRESS OF FCBS
C095  30 01                      LEAX  $01,X               ; * ADD ONE AND SAVE THE STARTING
C097  BF 09 28                   STX   FCBV1               ; * ADDRESS OF FCB1
C09A  6F 00                      CLR   FCBTYP,X            ; CLEAR THE FIRST BYTE OF FCB 1 (CLOSE FCB)
C09C  30 89 01 19                LEAX  FCBLEN,X            ; POINT X TO FCB 2
C0A0  BF 09 2A                   STX   FCBV1+2             ; SAVE ITS STARTING ADDRESS IN FCB VECTOR TABLE
C0A3  6F 00                      CLR   FCBTYP,X            ; CLEAR THE FIRST BYTE OF FCB 2 (CLOSE FCB)
C0A5  30 89 01 19                LEAX  FCBLEN,X            ; * POINT X TO SYSTEM FCB - THIS FCB WILL ONLY
* * BE USED TO COPY, LOAD, SAVE, MERGE, ETC
C0A9  BF 09 2C                   STX   FCBV1+4             ; SAVE ITS ADDRESS IN THE FCB VECTOR TABLE
C0AC  6F 00                      CLR   FCBTYP,X            ; CLEAR THE FIRST BYTE OF SYSTEM FCB (CLOSE FCB)
C0AE  86 02                      LDA   #$02                ; * SET THE NUMBER OF ACTIVE RESERVED
C0B0  B7 09 5B                   STA   FCBACT              ; * FILE BUFFERS TO 2 (1,2)
C0B3  30 89 01 19                LEAX  FCBLEN,X            ; POINT X TO ONE PAST THE END OF SYSTEM FCB
C0B7  1F 10                      TFR   X,D                 ; SAVE THE ADDRESS IN ACCD
C0B9  5D                         TSTB                      ; ON AN EVEN 256 BYTE BOUNDARY?
C0BA  27 01                      BEQ   LC0BD               ; YES
C0BC  4C                         INCA                      ; NO - ADD 256 TO ADDRESS
C0BD  85 01             LC0BD    BITA  #$01                ; * CHECK TO SEE IF ACCD IS ON AN EVEN
C0BF  27 01                      BEQ   LC0C2               ; * 512 BYTE (ONE GRAPHIC PAGE) BOUNDARY - ADD
C0C1  4C                         INCA                      ; * 256 (INCA) TO IT IF NOT
C0C2  1F 89             LC0C2    TFR   A,B                 ; COPY ACCA TO ACCB
C0C4  CB 18                      ADDB  #$18                ; SAVE ENOUGH ROOM FOR 4 GRAPHICS PAGES (PCLEAR 4)
C0C6  D7 19                      STB   TXTTAB              ; SAVE NEW START OF BASIC ADDRESS
C0C8  BD 96 EC                   JSR   L96EC               ; INITIALIZE EXBAS VARIABLES & DO A NEW
C0CB  96 BA                      LDA   BEGGRP              ; GET THE START OF CURRENT GRAPHICS PAGE
C0CD  8B 06                      ADDA  #$06                ; ADD 1.5K (6 X 256 = ONE GRAPHICS PAGE)
C0CF  97 B7                      STA   ENDGRP              ; SAVE NEW END OF GRAPHICS PAGE
C0D1  AD 9F C0 08                JSR   [DSINIT]            ; INITIALIZE SWI2,3 JUMP ADDRESSES
C0D5  8D 19                      BSR   LC0F0               ; GO INITIALIZE THE FLOPPY DISK CONTROLLER
C0D7  1C AF                      ANDCC #$AF                ; TURN ON IRQ AND FIRQ
C0D9  8E C1 38                   LDX   #LC139-1            ; POINT X TO DISK BASIC COPYRIGHT MESSAGE
C0DC  BD B9 9C                   JSR   STRINOUT            ; PRINT COPYRIGHT MESSAGE TO SCREEN
C0DF  8E C0 E7                   LDX   #DKWMST             ; GET DISK BASIC WARM START ADDRESS
C0E2  9F 72                      STX   RSTVEC              ; SAVE IT IN RESET VECTOR
C0E4  7E A0 E2                   JMP   LA0E2               ; JUMP BACK TO BASIC
