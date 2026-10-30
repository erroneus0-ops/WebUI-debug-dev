; Color BASIC memory map: constants (EQU) and RAM variables (RMB), incl. direct page.
; Source: Unravelled II.xls tab "Memory Map CB". First column = RAM address (RMB/code) or the constant VALUE (EQU).
; 6809 is big-endian:
; a 2-byte variable at $nn holds its high byte at $nn and low byte at $nn+1.

8000                    EXBAS    EQU   $8000
A000                    BASIC    EQU   $A000
C000                    ROMPAK   EQU   $C000

0008                    BS       EQU   8                   ; BACKSPACE
000D                    CR       EQU   $D                  ; ENTER KEY
001B                    ESC      EQU   $1B                 ; ESCAPE CODE
000A                    LF       EQU   $A                  ; LINE FEED
000C                    FORMF    EQU   $C                  ; FORM FEED
0020                    SPACE    EQU   $20                 ; SPACE (BLANK)

003A                    STKBUF   EQU   58                  ; STACK BUFFER ROOM
045E                    DEBDEL   EQU   $45E                ; DEBOUNCE DELAY
00FA                    LBUFMX   EQU   250                 ; MAX NUMBER OF CHARS IN A BASIC LINE
00FA                    MAXLIN   EQU   $FA                 ; MAXIMUM MS BYTE OF LINE NUMBER

2600                    DOSBUF   EQU   $2600               ; RAM LOAD LOCATION FOR THE DOS COMMAND
0020                    DIRLEN   EQU   32                  ; NUMBER OF BYTES IN DIRECTORY ENTRY
0100                    SECLEN   EQU   256                 ; LENGTH OF SECTOR IN BYTES
0012                    SECMAX   EQU   18                  ; MAXIMUM NUMBER OF SECTORS PER TRACK
1200                    TRKLEN   EQU   SECMAX*SECLEN       ; LENGTH OF TRACK IN BYTES
0023                    TRKMAX   EQU   35                  ; MAX NUMBER OF TRACKS
004A                    FATLEN   EQU   6+(TRKMAX-1)*2      ; FILE ALLOCATION TABLE LENGTH
0044                    GRANMX   EQU   (TRKMAX-1)*2        ; MAXIMUM NUMBER OF GRANULES
0119                    FCBLEN   EQU   SECLEN+25           ; FILE CONTROL BLOCK LENGTH
0010                    INPFIL   EQU   $10                 ; INPUT FILE TYPE
0020                    OUTFIL   EQU   $20                 ; OUTPUT FILE TYPE
0040                    RANFIL   EQU   $40                 ; RANDOM/DIRECT FILE TYPE

* PSEUDO PSEUDO OPS
0021                    SKP1     EQU   $21                 ; OP CODE OF BRN — SKIP ONE BYTE
008C                    SKP2     EQU   $8C                 ; OP CODE OF CMPX # - SKIP TWO BYTES
0086                    SKP1LD   EQU   $86                 ; OP CODE OF LDA # - SKIP THE NEXT BYTE
* AND LOAD THE VALUE OF THAT BYTE INTO ACCA — THIS
* IS USUALLY USED TO LOAD ACCA WITH A NON ZERO VALUE

* REGISTER ADDRESSES
FF00                    PIA0     EQU   $FF00               ; PERIPHERAL INPUT ADAPTER #0
FF20                    PIA1     EQU   $FF20               ; PERIPHERAL INPUT ADAPTER #1
FF20                    DA       EQU   PIA1+0              ; DIGITAL/ANALOG CONVERTER
FF40                    DSKREG   EQU   $FF40               ; DISK CONTROL REGISTER
FF48                    FDCREG   EQU   $FF48               ; 1793 CONTROL REGISTER
FFC0                    SAMREG   EQU   $FFC0               ; SAM CONTROL REGISTER

0000                             ORG   0
      0000                       SETDP 0

0000                    ENDFLG   RMB   1                   ; STOP/END FLAG: POSITIVE=STOP, NEG=END
0001                    CHARAC   RMB   1                   ; TERMINATOR FLAG 1
0002                    ENDCUR   RMB   1                   ; TERMINATOR FLAG 2
0003                    TMPLOC   RMB   1                   ; SCRATCH VARIABLE
0004                    IFCTR    RMB   1                   ; IF COUNTER - HOW MANY IF STATEMENTS IN A LINE
0005                    DIMFLG   RMB   1                   ; *DV* ARRAY FLAG 0=EVALUATE, 1=DIMENSIONING
0006                    VALTYP   RMB   1                   ; *DV* *PV TYPE FLAG: 0=NUMERIC, $FF=STRING
0007                    GARBFL   RMB   1                   ; *TV STRING SPACE HOUSEKEEPING FLAG
0008                    ARYDIS   RMB   1                   ; DISABLE ARRAY SEARCH: 00=ALLOW SEARCH
0009                    INPFLG   RMB   1                   ; *TV INPUT FLAG: READ=0, INPUT<>0
000A                    RELFLG   RMB   1                   ; *TV RELATIONAL OPERATOR FLAG
000B                    TEMPPT   RMB   2                   ; *PV TEMPORARY STRING STACK POINTER
000D                    LASTPT   RMB   2                   ; *PV ADDR OF LAST USED STRING STACK ADDRESS
000F                    TEMPTR   RMB   2                   ; TEMPORARY POINTER
0011                    TMPTR1   RMB   2                   ; TEMPORARY DESCRIPTOR STORAGE (STACK SEARCH)
** FLOATING POINT ACCUMULATOR #2 (MANTISSA ONLY)
0013                    FPA2     RMB   4                   ; FLOATING POINT ACCUMULATOR #2 MANTISSA
0017                    BOTSTK   RMB   2                   ; BOTTOM OF STACK AT LAST CHECK
0019                    TXTTAB   RMB   2                   ; *PV BEGINNING OF BASIC PROGRAM
001B                    VARTAB   RMB   2                   ; *PV START OF VARIABLES
001D                    ARYTAB   RMB   2                   ; *PV START OF ARRAYS
001F                    ARYEND   RMB   2                   ; *PV END OF ARRAYS (+1)
0021                    FRETOP   RMB   2                   ; *PV START OF STRING STORAGE (TOP OF FREE RAM)
0023                    STRTAB   RMB   2                   ; *PV START OF STRING VARIABLES
0025                    FRESPC   RMB   2                   ; UTILITY STRING POINTER
0027                    MEMSIZ   RMB   2                   ; *PV TOP OF STRING SPACE
0029                    OLDTXT   RMB   2                   ; SAVED LINE NUMBER DURING A "STOP"
002B                    BINVAL   RMB   2                   ; BINARY VALUE OF A CONVERTED LINE NUMBER
002D                    OLDPTR   RMB   2                   ; SAVED INPUT PTR DURING A "STOP"
002F                    TINPTR   RMB   2                   ; TEMPORARY INPUT POINTER STORAGE
0031                    DATTXT   RMB   2                   ; *PV 'DATA' STATEMENT LINE NUMBER POINTER
0033                    DATPTR   RMB   2                   ; *PV 'DATA' STATEMENT ADDRESS POINTER
0035                    DATTMP   RMB   2                   ; DATA POINTER FOR 'INPUT' & 'READ'
0037                    VARNAM   RMB   2                   ; *TV TEMP STORAGE FOR A VARIABLE NAME
0039                    VARPTR   RMB   2                   ; *TV POINTER TO A VARIABLE DESCRIPTOR
003B                    VARDES   RMB   2                   ; TEMP POINTER TO A VARIABLE DESCRIPTOR
003D                    RELPTR   RMB   2                   ; POINTER TO RELATIONAL OPERATOR PROCESSING ROUTINE
003F                    TRELFL   RMB   1                   ; TEMPORARY RELATIONAL OPERATOR FLAG BYTE

* FLOATING POINT ACCUMULATORS #3,4 & 5 ARE MOSTLY
* USED AS SCRATCH PAD VARIABLES.
** FLOATING POINT ACCUMULATOR #3 :PACKED: ($40-$44)
0040                    V40      RMB   1
0041                    V41      RMB   1
0042                    V42      RMB   1
0043                    V43      RMB   1
0044                    V44      RMB   1
** FLOATING POINT ACCUMULATOR #4 :PACKED: ($45-$49)
0045                    V45      RMB   1
0046                    V46      RMB   1
0047                    V47      RMB   1
0048                    V48      RMB   2
** FLOATING POINT ACCUMULATOR #5 :PACKED: ($4A—$4E)
004A                    V4A      RMB   1
004B                    V4B      RMB   2
004D                    V4D      RMB   2
** FLOATING POINT ACCUMULATOR #0
004F                    FP0EXP   RMB   1                   ; *PV FLOATING POINT ACCUMULATOR #0 EXPONENT
0050                    FPA0     RMB   4                   ; *PV FLOATING POINT ACCUMULATOR #0 MANTISSA
0054                    FP0SGN   RMB   1                   ; *PV FLOATING POINT ACCUMULATOR #0 SIGN
0055                    COEFCT   RMB   1                   ; POLYNOMIAL COEFFICIENT COUNTER
0056                    STRDES   RMB   5                   ; TEMPORARY STRING DESCRIPTOR
005B                    FPCARY   RMB   1                   ; FLOATING POINT CARRY BYTE
** FLOATING POINT ACCUMULATOR #1
005C                    FP1EXP   RMB   1                   ; *PV FLOATING POINT ACCUMULATOR #1 EXPONENT
005D                    FPA1     RMB   4                   ; *PV FLOATING POINT ACCUMULATOR #1 MANTISSA
0061                    FP1SGN   RMB   1                   ; *PV FLOATING POINT ACCUMULATOR #1 SIGN

0062                    RESSGN   RMB   1                   ; SIGN OF RESULT OF FLOATING POINT OPERATION
0063                    FPSBYT   RMB   1                   ; FLOATING POINT SUB BYTE (FIFTH BYTE)
0064                    COEFPT   RMB   2                   ; POLYNOMIAL COEFFICIENT POINTER
0066                    LSTTXT   RMB   2                   ; CURRENT LINE POINTER DURING LIST
0068                    CURLIN   RMB   2                   ; *PV CURRENT LINE # OF BASIC PROGRAM, $FFFF = DIRECT
006A                    DEVCFW   RMB   1                   ; *TV TAB FIELD WIDTH
006B                    DEVLCF   RMB   1                   ; *TV TAB ZONE
006C                    DEVPOS   RMB   1                   ; *TV PRINT POSITION
006D                    DEVWID   RMB   1                   ; *TV PRINT WIDTH
006E                    PRTDEV   RMB   1                   ; *TV PRINT DEVICE: 0=NOT CASSETTE, -1=CASSETTE
006F                    DEVNUM   RMB   1                   ; *PV DEVICE NUMBER: -3=DLOAD, -2=PRINTER,
*                    -1=CASSETTE, 0=SCREEN, 1-15=DISK
0070                    CINBFL   RMB   1                   ; *PV CONSOLE IN BUFFER FLAG: 00=NOT EMPTY, $FF=EMPTY
0071                    RSTFLG   RMB   1                   ; *PV WARM START FLAG: $55=WARM, OTHER=COLD
0072                    RSTVEC   RMB   2                   ; *PV WARM START VECTOR - JUMP ADDRESS FOR WARM START
0074                    TOPRAM   RMB   2                   ; *PV TOP OF RAM
0076                             RMB   2                   ; SPARE: UNUSED VARIABLES
0078                    FILSTA   RMB   1                   ; *PV FILE STATUS FLAG: 0=CLOSED, 1=INPUT, 2=OUTPUT
0079                    CINCTR   RMB   1                   ; *PV CONSOLE IN BUFFER CHAR COUNTER
007A                    CINPTR   RMB   2                   ; *PV CONSOLE IN BUFFER POINTER
007C                    BLKTYP   RMB   1                   ; *TV CASS BLOCK TYPE: 0=HEADER, 1=DATA, $FF=EOF
007D                    BLKLEN   RMB   1                   ; *TV CASSETTE BYTE COUNT
007E                    CBUFAD   RMB   2                   ; *TV CASSETTE LOAD BUFFER POINTER
0080                    CCKSUM   RMB   1                   ; *TV CASSETTE CHECKSUM BYTE
0081                    CSRERR   RMB   1                   ; *TV ERROR FLAG/CHARACTER COUNT
0082                    CPULWD   RMB   1                   ; *TV PULSE WIDTH COUNT
0083                    CPERTM   RMB   1                   ; *TV BIT COUNTER
0084                    CBTPHA   RMB   1                   ; *TV BIT PHASE FLAG
0085                    CLSTSN   RMB   1                   ; *TV LAST SINE TABLE ENTRY
0086                    GRBLOK   RMB   1                   ; *TV GRAPHIC BLOCK VALUE FOR SET, RESET AND POINT
0087                    IKEYIM   RMB   1                   ; *TV INKEY$ RAM IMAGE
0088                    CURPOS   RMB   2                   ; *PV CURSOR LOCATION
008A                    ZERO     RMB   2                   ; *PV DUMMY - THESE TWO BYTES ARE ALWAYS ZERO
008C                    SNDTON   RMB   1                   ; *TV TONE VALUE FOR SOUND COMMAND
008D                    SNDDUR   RMB   2                   ; *TV DURATION VALUE FOR SOUND COMMAND

** THESE BYTES ARE MOVED DOWN FROM ROM
*** INIT DESCRIPTION
* VALUE
008F                    CMPMID   RMB   1                   ; 18 *PV 1200/2400 HERTZ PARTITION
0090                    CMP0     RMB   1                   ; 24 *PV UPPER LIMIT OF 1200 HERTZ PERIOD
0091                    CMP1     RMB   1                   ; 10 *PV UPPER LIMIT OF 2400 HERTZ PERIOD
0092                    SYNCLN   RMB   2                   ; 128 *PV NUMBER OF $55'S TO CASSETTE LEADER
0094                    BLKCNT   RMB   1                   ; 11 *PV CURSOR BLINK DELAY
0095                    LPTBTD   RMB   2                   ; 88 *PV BAUD RATE CONSTANT (600)
0097                    LPTLND   RMB   2                   ; 1 *PV PRINTER CARRIAGE RETURN DELAY
0099                    LPTCFW   RMB   1                   ; 16 *PV TAB FIELD WIDTH
009A                    LPTLCF   RMB   1                   ; 112 *PV LAST TAB ZONE
009B                    LPTWID   RMB   1                   ; 132 *PV PRINTER WIDTH
009C                    LPTPOS   RMB   1                   ; 0 *PV LINE PRINTER POSITION
009D                    EXECJP   RMB   2                   ; LB4AA *PV JUMP ADDRESS FOR EXEC COMMAND

** THIS ROUTINE PICKS UP THE NEXT INPUT CHARACTER FROM
** BASIC. THE ADDRESS OF THE NEXT BASIC BYTE TO BE
** INTERPRETED IS STORED AT CHARAD.

009F  0C A7             GETNCH   INC   <CHARAD+1           ; *PV INCREMENT LS BYTE OF INPUT POINTER
00A1  26 02                      BNE   GETCCH              ; *PV BRANCH IF NOT ZERO (NO CARRY)
00A3  0C A6                      INC   <CHARAD             ; *PV INCREMENT MS BYTE OF INPUT POINTER
00A5  B6                GETCCH   FCB   $B6                 ; *PV OP CODE OF LDA EXTENDED
00A6                    CHARAD         2                   ; *PV THESE 2 BYTES CONTAIN ADDRESS OF THE CURRENT
*     CHARACTER WHICH THE BASIC INTERPRETER IS
*     PROCESSING
00A8  7E AA 1A                   JMP   BROMHK              ; JUMP BACK INTO THE BASIC RUM

00AB                    VAB      RMB   1                   ; = LOW ORDER FOUR BYTES OF THE PRODUCT
00AC                    VAC      RMB   1                   ; = OF A FLOATING POINT MULTIPLICATION
00AD                    VAD      RMB   1                   ; = THESE BYTES ARE USE AS RANDOM DATA
00AE                    VAE      RMB   1                   ; = BY THE RND STATEMENT

* EXTENDED BASIC VARIABLES
00AF                    TRCFLG   RMB   1                   ; *PV TRACE FLAG 0=OFF ELSE=ON
00B0                    USRADR   RMB   2                   ; *PV ADDRESS OF THE START OF USR VECTORS
00B2                    FORCOL   RMB   1                   ; *PV FOREGROUND COLOR
00B3                    BAKCOL   RMB   1                   ; *PV BACKGROUND COLOR
00B4                    WCOLOR   RMB   1                   ; *TV WORKING COLOR BEING USED BY EX BASIC
00B5                    ALLCOL   RMB   1                   ; *TV ALL PIXELS IN THIS BYTE SET TO COLOR OF VB3
00B6                    PMODE    RMB   1                   ; *PV PMODE'S MODE ARGUMENT
00B7                    ENDGRP   RMB   2                   ; *PV END OF CURRENT GRAPHIC PAGE
00B9                    HORBYT   RMB   1                   ; *PV NUMBER OF BYTES/HORIZONTAL GRAPHIC LINE
00BA                    BEGGRP   RMB   2                   ; *PV START OF CURRENT GRAPHIC PAGE
00BC                    GRPRAM   RMB   1                   ; *PV START OF GRAPHIC RAM (MS BYTE)
00BD                    HORBEG   RMB   2                   ; *DV* *PV HORIZ COORD - START POINT
00BF                    VERBEG   RMB   2                   ; *DV* *PV VERT COORD - START POINT
00C1                    CSSYAL   RMB   1                   ; *PV SCREEN'S COLOR SET ARGUMENT
00C2                    SETFLG   RMB   1                   ; *PV PRESET/PSET FLAG: 0=PRESET, 1=PSET
00C3                    HOREND   RMB   2                   ; *DV* *PV HORIZ COORD - ENDING POINT
00C5                    VEREND   RMB   2                   ; *DV* *PV VERT COORD - ENDING POINT
00C7                    HORDEF   RMB   2                   ; *PV HORIZ COORD - DEFAULT COORD
00C9                    VERDEF   RMB   2                   ; *PV VERT COORD - DEFAULT COORD

* EXTENDED BASIC SCRATCH PAD VARIABLES
00CB                    VCB      RMB   2
00CD                    VCD      RMB   2
00CF                    VCF      RMB   2
00D1                    VD1      RMB   2
00D3                    VD3      RMB   1
00D4                    VD4      RMB   1
00D5                    VD5      RMB   1
00D6                    VD6      RMB   1
00D7                    VD7      RMB   1
00D8                    VD8      RMB   1
00D9                    VD9      RMB   1
00DA                    VDA      RMB   1

00DB                    CHGFLG   RMB   1                   ; *TV FLAG TO INDICATE IF GRAPHIC DATA HAS BEEN CHANGED
00DC                    TMPSTK   RMB   2                   ; *TV STACK POINTER STORAGE DURING PAINT
00DE                    OCTAVE   RMB   1                   ; *PV OCTAVE VALUE (PLAY)
00DF                    VOLHI    RMB   1                   ; *DV* *PV VOLUME HIGH VALUE (PLAY)
00E0                    VOLLOW   RMB   1                   ; *DV* *PV VOLUME LOW VALUE (PLAY)
00E1                    NOTELN   RMB   1                   ; *PV NOTE LENGTH (PLAY)
00E2                    TEMPO    RMB   1                   ; *PV TEMPO VALUE (PLAY)
00E3                    PLYTMR   RMB   2                   ; *TV TIMER FOR THE PLAY COMMAND
00E5                    DOTYAL   RMB   1                   ; *TV DOTTED NOTE TIMER SCALE FACTOR
00E6                    DLBAUD   RMB   1                   ; *DV* *PV DLOAD BAUD RATE CONSTANT $B0=300, $2C=1200
00E7                    TIMOUT   RMB   1                   ; *DV* *PV DLOAD TIMEOUT CONSTANT
00E8                    ANGLE    RMB   1                   ; *DV* *PV ANGLE VALUE (DRAW)
00E9                    SCALE    RMB   1                   ; *DV* *PV SCALE VALUE (DRAW)

* DSKCON VARIABLES
00EA                    DCOPC    RMB   1                   ; *PV DSKCON OPERATION CODE 0-3
00EB                    DCDRV    RMB   1                   ; *PV DSKCON DRIVE NUMBER 0—3
00EC                    DCTRK    RMB   1                   ; *PV DSKCON TRACK NUMBER 0—34
00ED                    DSEC     RMB   1                   ; *PV DSKCON SECTOR NUMBER 1-18
00EE                    DCBPT    RMB   2                   ; *PV DSKCON DATA POINTER
00F0                    DCSTA    RMB   1                   ; *PV DSKCON STATUS BYTE

00F1                    FCBTMP   RMB   2                   ; TEMPORARY FCB POINTER

00F3                             RMB   13                  ; SPARE: UNUSED VARIABLES


* BASIC EXBASIC DOSBASIC

0100                    SW3VEC   RMB   3                   ; $XXXX $XXXX $3B3B SWI3 VECTOR
0103                    SW2VEC   RMB   3                   ; $XXXX $XXXX $3B3B SWI2 VECTOR
0106                    SWIVEC   RMB   3                   ; $XXXX $XXXX $XXXX SWI VECTOR
0109                    NMIVEC   RMB   3                   ; $XXXX $XXXX $D7AE NMI VECTOR
010C                    IRQVEC   RMB   3                   ; $A9B3 $894C $D7BC IRQ VECTOR
010F                    FRQVEC   RMB   3                   ; $A0F6 $A0F6 $A0F6 FIRQ VECTOR

0112                    TIMVAL
0112                    USRJMP   RMB   3                   ; JUMP ADDRESS FOR BASIC'S USR FUNCTION
                        *        RMB   2                   ; TIMER VALUE FOR EXBAS
                        *        RMB   1                   ; UNUSED BY EXBAS OR DISK BASIC
0115                    RVSEED   RMB   1                   ; * FLOATING POINT RANDOM NUMBER SEED EXPONENT
0116                             RMB   4                   ; * MANTISSA: INITIALLY SET TO $804FC75259
011A                    CASFLG   RMB   1                   ; UPPER CASE/LOWER CASE FLAG: $FF=UPPER, 0=LOWER
011B                    DEBVAL   RMB   2                   ; KEYBOARD DEBOUNCE DELAY (SET TO $45E)
011D                    EXPJMP   RMB   3                   ; JUMP ADDRESS FOR EXPONENTIATION
** INITIALLY SET TO ERROR FOR BASIC, $8489 FOR EX BASIC

                        ***      COMMAND INTERPRETATION VECTOR TABLE

** FOUR SETS OF 10 BYTE TABLES:


** THE LAST USED TABLE MUST BE FOLLOWED BY A ZERO BYTE
* THE JUMP TABLE VECTORS (3,4 AND 8,9) POINT TO THE JUMP TABLE FOR
* THE FIRST TABLE. FOR ALL OTHER TABLES, THESE VECTORS POINT TO A
* ROUTINE WHICH WILL VECTOR YOU TO THE CORRECT JUMP TABLE.
* SUPER ENHANCED BASIC HAS MODIFIED THIS SCHEME SO THAT THE USER
* TABLE MAY NOT BE ACCESSED.  ANY ADDITIONAL TABLES WILL HAVE TO BE
* ACCESSED FROM A NEW COMMAND HANDLER.

                        *        BYTE  DESCRIPTION
                        *        0     NUMBER OF RESERVED WORDS
                        *        1,2   LOOKUP TABLE OF RESERVED WORDS
                        *        3,4   JUMP TABLE FOR COMMANDS (FIRST TABLE)
*
                        *        5     NUMBER OF SECONDARY FUNCTIONS
                        *        6,7   LOOKUP TABLE OF SECONDARY FUNCTIONS (FIRST TABLE)
*
*
                        *        8,9   JUMP TABLE FOR SECONDARY FUNCTIONS
                        *        10    0 BYTE - END OF TABLE FLAG (LAST TABLE ONLY)

0120                    COMVEC   RMB   10                  ; BASIC'S TABLE
012A                             RMB   10                  ; EX BASIC'S TABLE
0134                             RMB   10                  ; DISC BASIC'S TABLE (UNUSED BY EX BASIC)

**** USR FUNCTION VECTOR ADDRESSES (EX BASIC ONLY)
013E                             RMB   2                   ; USR 0 VECTOR
0140                             RMB   2                   ; USR 1
0142                             RMB   2                   ; USR 2
0144                             RMB   2                   ; USR 3
0146                             RMB   2                   ; USR 4
0148                             RMB   2                   ; USR 5
014A                             RMB   2                   ; USR 6
014C                             RMB   2                   ; USR 7
014E                             RMB   2                   ; USR 8
0150                             RMB   2                   ; USR 9

*** THE ABOVE 20 BYTE USR ADDR VECTOR TABLE IS MOVED TO
*** $95F-$972 BY DISC BASIC. THE 20 BYTES FROM $13E-$151
*** ARE REDEFINED AS FOLLOWS:

                        *        RMB   10                  ; USER (SPARE) COMMAND INTERPRETATION TABLE SPACE
                        *        FCB   0                   ; END OF COMM INTERP TABLE FLAG
                        *        RMB   9                   ; UNUSED BY DISK BASIC

                        *        COMMAND INTERPRETATION TABLE VALUES
* BASIC EX BASIC DISK BASIC
                        *                                          BASIC TABLE 0 ; 53 BASIC TABLE
* $AA66
* $AB67
* 20
* $AB1A
* $AA29

* 25 EX BASIC TABLE
* $8183
* $813C $CE2E ($CF0A 2.1)
* 14
* $821E
* $8168 $CE56 ($CF32 2.1)

* 19 (20 2.1) DISK BASIC TABLE
* $C17F
* $C2C0
* 6
* $C201
* $C236


0152                    KEYBUF   RMB   8                   ; KEYBOARD MEMORY BUFFER
015A                    POTVAL   RMB   1                   ; LEFT VERTICAL JOYSTICK DATA
015B                             RMB   1                   ; LEFT HORIZONTAL JOYSTICK DATA
015C                             RMB   1                   ; RIGHT VERTICAL JOYSTICK DATA
015D                             RMB   1                   ; RIGHT HORIZONTAL JOYSTICK DATA

* BASIC'S RAM VECTORS - INITIALIZED TO RTS BY COLOR BASIC
* 25 SETS OF 3 BYTE INSTRUCTIONS WHICH ARE CALLED BY COLOR BASIC
* EXTENDED AND DISK BASIC. THEIR PURPOSE IS TO ALLOW ENHANCEMENTS (SUCH
* AS EX BASIC AND DOS BASIC) AS MORE ROMS ARE ADDED TO THE
* SYSTEM BY EFFECTIVELY ALLOWING MORE CODE TO BE ADDED TO THE
* ROUTINES IN EARLIER ROMS. THIS NEW CODE IS LOCATED IN THE NEW ROMS
* AND THE ADDRESS TO GET TO THE NEW CODE IS IN BYTES 1 & 2 OF THE
* RAM VECTOR. BYTE 0 WILL CONTAIN A $7E WHICH IS THE FIRST BYTE OF
* THE JMP INSTRUCTION.
* THE FIRST ADDRESS IN THIS TABLE IS THE ADDRESS IN BASIC WHICH
* CALLS THE RAM VECTOR, THE SECOND ADDRESS IS THE VALUE WHICH
* EX BASIC PUTS IN THE RAM VECTOR (IF ANY) AND THE THIRD ADDRESS
* IS THE VALUE WHICH DISK BASIC PUTS THERE (IF ANY)


* 2.0 2.1 1.0 1.1
015E                    RVEC0    RMB   3                   ; $A5F6 $C426 $C44B OPEN COMMAND
0161                    RVEC1    RMB   3                   ; $A5B9 $C838 $C888 DEVICE NUMBER VALIDITY CHECK
0164                    RVEC2    RMB   3                   ; $A35F $C843 $C893 SET PRINT PARAMETERS
0167                    RVEC3    RMB   3                   ; $A282 $8273 $CB4A $CC1C CONSOLE OUT
016A                    RVEC4    RMB   3                   ; $A176 $8CF1 $C58F $C5BC CONSOLE IN
016D                    RVEC5    RMB   3                   ; $A3ED $C818 $C848 INPUT DEVICE NUMBER CHECK
0170                    RVEC6    RMB   3                   ; $A406 $C81B $C84B PRINT DEVICE NUMBER CHECK
0173                    RVEC7    RMB   3                   ; $A426 $CA3B $CAE9 CLOSE ALL FILES
0176                    RVEC8    RMB   3                   ; $A42D $8286 $CA4B $CAF9 CLOSE ONE FILE
0179                    RVEC9    RMB   3                   ; $B918 $8E90 $8E90 $8E90 PRINT
017C                    RVEC10   RMB   3                   ; $B061 $CC5B $CD35 INPUT
017F                    RVEC11   RMB   3                   ; $A549 $C859 $C8A9 BREAK CHECK
0182                    RVEC12   RMB   3                   ; $A390 $C6B7 $C6E4 INPUTTING A BASIC LINE
0185                    RVEC13   RMB   3                   ; $A4BF $CA36 $CAE4 TERMINATING BASIC LINE INPUT
0188                    RVEC14   RMB   3                   ; $A5CE $CA60 $C90C EOF COMMAND
018B                    RVEC15   RMB   3                   ; $B223 $8846 $CDF6 $CED2 EVALUATE AN EXPRESSION
018E                    RVEC16   RMB   3                   ; $AC46 $C6B7 $C6E4 RESERVED FOR ON ERROR GOTO CMD
0191                    RVEC17   RMB   3                   ; $AC49 $88F0 $C24D $C265 ERROR DRIVER
0194                    RVEC18   RMB   3                   ; $AE75 $829C $C990 $CA3E RUN
0197                    RVEC19   RMB   3                   ; $BD22 $87EF ASCII TO FLOATING POINT CONV.
019A                    RVEC20   RMB   3                   ; $AD9E $82B9 $C8B0 BASIC'S COMMAND INTERP. LOOP
019D                    RVEC21   RMB   3                   ; $A8C4 RESET/SET/POINT COMMANDS
01A0                    RVEC22   RMB   3                   ; $A910 CLS
* $8162 EXBAS' SECONDARY TOKEN HANDLER
* $8AFA EXBAS' RENUM TOKEN CHECK
* $975C $C29A $C2B2 EXBAS' GET/PUT
01A3                    RVEC23   RMB   3                   ; $B821 $8304 CRUNCH BASIC LINE
01A6                    RVEC24   RMB   3                   ; $B7C2 UNCRUNCH BASIC LINE

01A9                    STRSTK   RMB   8*5                 ; STRING DESCRIPTOR STACK
01D1                    CFNBUF   RMB   9                   ; CASSETTE FILE NAME BUFFER
01DA                    CASBUF   RMB   256                 ; CASSETTE FILE DATA BUFFER
02DA                    LINHDR   RMB   2                   ; LINE INPUT BUFFER HEADER
02DC                    LINBUF   RMB   LBUFMX+1            ; BASIC LINE INPUT BUFFER
03D7                    STRBUF   RMB   41                  ; STRING BUFFER

0400                    VIDRAM   RMB   200                 ; VIDEO DISPLAY AREA

*START OF ADDITIONAL RAM VARIABLE STORAGE (DISK BASIC ONLY)
0600                    DBUF0    RMB   SECLEN              ; I/O BUFFER #0
0700                    DBUF1    RMB   SECLEN              ; I/O BUFFER #1
0800                    FATBL0   RMB   FATLEN              ; FILE ALLOCATION TABLE - DRIVE 0
084A                    FATBL1   RMB   FATLEN              ; FILE ALLOCATION TABLE - DRIVE 1
0894                    FATBL2   RMB   FATLEN              ; FILE ALLOCATION TABLE - DRIVE 2
08DE                    FATBL3   RMB   FATLEN              ; FILE ALLOCATION TABLE - DRIVE 3
0928                    FCBV1    RMB   16*2                ; FILE BUFFER VECTORS (15 USER, 1 SYSTEM)
0948                    RNBFAD   RMB   2                   ; START OF FREE RANDOM FILE BUFFER AREA
094A                    FCBADR   RMB   2                   ; START OF FILE CONTROL BLOCKS
094C                    DNAMBF   RMB   8                   ; DISK FILE NAME BUFFER
0954                    DEXTBF   RMB   3                   ; DISK FILE EXTENSION NAME BUFFER
0957                    DFLTYP   RMB   1                   ; *DV* DISK FILE TYPE: 0=BASIC, 1=DATA, 2=MACHINE
*      LANGUAGE, 3=TEXT EDITOR SOURCE FILE
0958                    DASCFL   RMB   1                   ; *DV* ASCII FLAG: 0=CRUNCHED OR BINARY, $FF=ASCII
0959                    DRUNFL   RMB   1                   ; RUN FLAG: (IF BIT 1=1 THEN RUN, IF BIT 0=1, THEN CLOSE
* ALL FILES BEFORE RUNNING)
095A                    DEFDRV   RMB   1                   ; DEFAULT DRIVE NUMBER
095B                    FCBACT   RMB   1                   ; NUMBER OF FCBS ACTIVE
095C                    DRESFL   RMB   1                   ; RESET FLAG: <>0 WILL CAUSE A 'NEW' & SHUT DOWN ALL FCBS
095D                    DLOADFL  RMB   1                   ; LOAD FLAG: CAUSE A 'NEW' FOLLOWING A LOAD ERROR
095E                    DMRGFL   RMB   1                   ; MERGE FLAG: 0=N0 MERGE, $FF=MERGE
095F                    DUSRVC   RMB   20                  ; DISK BASIC USR COMMAND VECTORS
*** DISK FILE WORK AREA FOR DIRECTORY SEARCH
*   EXISTING FILE
0973                    V973     RMB   1                   ; SECTOR NUMBER
0974                    V974     RMB   2                   ; RAM DIRECTORY IMAGE ADDRESS
0976                    V976     RMB   1                   ; FIRST GRANULE NUMBER
*   UNUSED FILE
0977                    V977     RMB   1                   ; SECTOR NUMBER
0978                    V978     RMB   2                   ; RAM DIRECTORY IMAGE ADDRESS

097A                    WFATVL   RMB   2                   ; WRITE FAT VALUE: NUM OF FREE GRANS WHICH MUST BE TAKEN
; FROM THE FAT TO TRIGGER A WRITE FAT TO DISK SEQUENCE
097C                    DFFLEN   RMB   2                   ; DIRECT ACCESS FILE RECORD LENGTH
097E                    DR0TRK   RMB   4                   ; CURRENT TRACK NUMBER, DRIVES 0,1,2,3
0982                    NMIFLG   RMB   1                   ; NMI FLAG: 0=DON'T VECTOR <>0=YECTOR OUT
0983                    DNMIVC   RMB   2                   ; NMI VECTOR: WHERE TO JUMP FOLLOWING AN NMI
* INTERRUPT IF THE NMI FLAG IS SET
0985                    RDYTMR   RMB   1                   ; MOTOR TURN OFF TIMER
0986                    DRGRAM   RMB   1                   ; RAM IMAGE OF DSKREG ($FF40)
0987                    DVERFL   RMB   1                   ; VERIFY FLAG: 0=OFF, $FF=ON
0988                    ATTCTR   RMB   1                   ; READ/WRITE ATTEMPT COUNTER: NUMBER OF TIMES THE
* DISK WILL ATTEMPT TO RETRIEVE OR WRITE DATA
* BEFORE IT GIVES UP AND ISSUES AN ERROR.

0989                    DFLBUF   RMB   SECLEN              ; INITIALIZED TO SECLEN BY DISKBAS

*RANDOM FILE RESERVED AREA

*FILE CONTROL BLOCKS AND BUFFERS

*GRAPHIC PAGE RESERVED AREA

*BASIC PROGRAM

*VARIABLE STORAGE AREA

*ARRAY STORAGE AREA


* FREE MEMORY


*STACK

*STRING SPACE

*USER PROGRAM RESERVED AREA

*END OF RAM

8000                    ORG      $8000

8000                             RMB   $2000               ; EXTENDED BASIC ROM
A000                             RMB   $2000               ; COLOR BASIC ROM
                        ROMPAK   EQU   *
C000                    DOSBAS   RMB   $2000               ; DISK BASIC ROM/ENHANCED BASIC INIT CODE
E000                             RMB   $1F00               ; ENHANCED BASIC


* I/O AREA

                        PIA0     EQU   *                   ; PERIPHERAL INTERFACE ADAPTER ONE

FF00                    BIT0     KEYBOARD ROW 1 AND RIGHT JOYSTICK SWITCH 1
                        BIT1     KEYBOARD ROW 2 AND LEFT JOYSTICK SWITCH 1
                        BIT2     KEYBOARD ROW 3 AND RIGHT JOYSTICK SWITCH 2
                        BIT3     KEYBOARD ROW 4 AND LEFT JOYSTICK SWITCH 2
                        BIT4     KEYBOARD ROW 5
                        BIT5     KEYBOARD ROW 6
                        BIT6     KEYBOARD ROW 7
                        BIT7     JOTSTICK COMPARISON IINPUT

FF01                    BIT0     CONTROL OF HSYNC (63.5ps)  ; 0 = IRQ* TO CPU DISABLED
                                 INTERRUPT                 ; 1 = IRQ* TO CPU ENABLED
                        BIT1     CONTROL OF INTERRUPT      ; 0 = FLAG SET ON FALLING EDGE OF HS
                                 POLARITY                  ; 1 = FLAG SET ON RISING EDGE OF HS
                        BIT2     NORMALLY 1                ; 0 = CHANGES FF00 TO DATA DIRECTION
                        BIT3     SEL 1                     ; LSB OF TWO ANALOG MUX SELECT LINES
                        BIT4     ALWAYS 1
                        BIT5     ALWAYS 1
                        BIT6     NOT USED
                        BIT7     HORIZONTAL SYNC INTERRUPT FLAG

FF02                    BIT0     KEYBOARD COLUMN 1
                        BIT1     KEYBOARD COLUMN 2
                        BIT2     KEYBOARD COLUMN 3
                        BIT3     KEYBOARD COLUMN 4
                        BIT4     KEYBOARD COLUMN 5
                        BIT5     KEYBOARD COLUMN 6
                        BIT6     KEYBOARD COLUMN 7 / RAM SIZE OUTPUT
                        BIT7     KEYBOARD COLUMN 8

FF03                    BIT0     CONTROL OF VSYNC (16.667ms)  ; 0 = IRQ* TO CPU DISABLED
                                 INTERRUPT                 ; 1 = IRQ* TO CPU ENABLED
                        BIT1     CONTROL OF INTERRUPT      ; 0 = FLAG SET ON FALLING EDGE OF FS
                                 POLARITY                  ; 1 = FLAG SET ON RISING EDGE OF FS
                        BIT2     NORMALLY 1                ; 0 = CHANGES FF02 TO DATA DIRECTION
                        BIT3     SEL 2                     ; MSB OF TWO ANALOG MUX SELECT LINES
                        BIT4     ALWAYS 1
                        BIT5     ALWAYS 1
                        BIT6     NOT USED
                        BIT7     FIELD SYNC INTERRUPT FLAG

FF04                             RMB   28                  ; PIA0 IMAGES
FF20                    DA
                        PIA1     EQU   *                   ; PERIPHERAL INTERFACE ADAPTER TWO

FF20                    BIT0     CASSETTE DATA INPUT
                        BIT1     RS-232C DATA OUTPUT
                        BIT2     6 BIT D/A LSB
                        BIT3     6 BIT D/A
                        BIT4     6 BIT D/A
                        BIT5     6 BIT D/A
                        BIT6     6 BIT D/A
                        BIT7     6 BIT D/A MSB

FF21                    BIT0     CONTROL OF CD             ; 0 = FIRQ* TO CPU DISABLED
                                 (RS-232C STATUS)          ; 1 = FIRQ* TO CPU ENABLED
                        BIT1     CONTROL OF INTERRUPT      ; 0 = FLAG SET ON FALLING EDGE OF CD
                                 POLARITY                  ; 1 = FLAG SET ON RISING EDGE OF CD
                        BIT2     NORMALLY 1                ; 0 = CHANGES FF20 TO DATA DIRECTION
                        BIT3     CASSETTE MOTOR CONTROL    ; 0 = OFF 1 = ON
                        BIT4     ALWAYS 1
                        BIT5     ALWAYS 1
                        BIT6     NOT USED
                        BIT7     CD INTERRUPT FLAG

FF22                    BIT0     RS-232C DATA INPUT
                        BIT1     SINGLE BIT SOUND OUTPUT
                        BIT2     RAM SIZE INPUT
                        BIT3     RGB MONITOR SENSING INPUT  ; CSS
                        BIT4     VDG CONTROL OUTPUT        ; GM0 & UPPER/LOWER CASE*
                        BIT5     VDG CONTROL OUTPUT        ; GM1 & INVERT
                        BIT6     VDG CONTROL OUTPUT        ; GM2
                        BIT7     VDG CONTROL OUTPUT        ; A*/G

FF23                    BIT0     CONTROL OF CARTRIDGE      ; 0 = FIRQ* TO CPU DISABLED
                                 INTERRUPT                 ; 1 = FIRQ* TO CPU ENABLED
                        BIT1     CONTROL OF INTERRUPT      ; 0 = FLAG SET ON FALLING EDGE OF CART*
                                 POLARITY                  ; 1 = FLAG SET ON RISING EDGE OF CART*
                        BIT2     NORMALLY 1                ; 0 = CHANGES FF22 TO DATA DIRECTION
                        BIT3     SOUND ENABLE
                        BIT4     ALWAYS 1
                        BIT5     ALWAYS 1
                        BIT6     NOT USED
                        BIT7     CARTRIDGE INTERRUPT FLAG

FF24                             RMB   28                  ; PIA1 IMAGES
FF40                    PIA2
FF40                    DSKREG   RMB   1                   ; DISK CONTROL REGISTER

FF40                    BIT0     DRIVE SELECT 0
                        BIT1     DRIVE SELECT 1
                        BIT2     DRIVE SELECT 2
                        BIT3     DRIVE MOTOR ENABLE        ; 0 = MOTORS OFF 1 = MOTORS ON
                        BIT4     WRITE PRECOMPENSATION     ; 0 = NO PRECOMP 1 = PRECOMP
                        BIT5     DENSITY FLAG              ; 0 = SINGLE 1 = DOUBLE
                        BIT6     DRIVE SELECT 3
                        BIT7     HALT FLAG                 ; 0 = DISABLED 1 = ENABLED

FF41                             RMB   7                   ; DSKREG IMAGES

* FLOPPY DISK CONTROLLER INTERNAL REGISTERS
FF48                    FDCREG   RMB   1                   ; STATUS/COMMAND REGISTER

                        COMMANDS TYPE  COMMAND             ; CODE
                                 I     RESTORE             ; $03
                                 I     SEEK                ; $17
                                 I     STEP                ; $23
                                 I     STEP IN             ; $43
                                 I     STEP OUT            ; $53
                                 II    READ SECTOR         ; $80
                                 II    WRITE SECTOR        ; $A0
                                 III   READ ADDRESS        ; $C0
                                 III   READ TRACK          ; $E4
                                 III   WRITE TRACK         ; $F4
                                 IV    FORCE INTERRUPT     ; $D0

                        STATUS   BIT   TYPE I              ; READ ADDRESS/SECTOR/TRACK WRITE SECTOR/TRACK
                                 S0    BUSY                ; BUSY BUSY
                                 S1    INDEX               ; DRQ DRQ
                                 S2    TRACK 0             ; LOST DATA LOST DATA
                                 S3    CRC ERROR           ; CRC ERROR (EXCEPT TRACK) CRC ERROR (EXCEPT TRACK)
                                 S4    SEEK ERROR          ; RNF (EXCEPT TRACK) RNF (EXCEPT TRACK)
                                 S5    HEAD LOADED         ; RECORD TYPE (SECTOR ONLY) WRITE FAULT
                                 S6    WRITE PROTECT       ; WRITE PROTECT
                                 S7    NOT READY           ; NOT READY NOT READY

FF49                             RMB   1                   ; TRACK REGISTER
FF4A                             RMB   1                   ; SECTOR REGISTER
FF4B                             RMB   1                   ; DATA REGISTER
FF4C                             RMB   4                   ; FDCREG IMAGES

FF50                             RMB   16                  ; UNUSED SPACE
FF60                             RMB   1                   ; X COORDINATE FOR X-PAD
FF61                             RMB   1                   ; Y COORDINATE FOR X-PAD
FF62                             RMB   1                   ; STATUS REGISTER FOR X-PAD
FF63                             RMB   5                   ; UNUSED
* RS-232 PROGRAM PAK
FF68                             RMB   1                   ; READ/WRITE DATA REGISTER
FF69                             RMB   1                   ; STATUS REGISTER
FF6A                             RMB   1                   ; COMMAND REGISTER
FF6B                             RMB   1                   ; CONTROL REGISTER
FF6C                             RMB   4
FF70                             RMB   13
FF7D                             RMB   1                   ; SOUND/SPEECH CARTRIDGE RESET
FF7E                             RMB   1                   ; SOUND/SPEECH CARTRIDGE READ/WRITE
FF7F                             RMB   1                   ; MULTI-PAK PROGRAMMING REGISTER

FF80                             RMB   64                  ; RESERVED FOR FUTURE EXPANSION


                        SAMREG   EQU   *                   ; SAM CONTROL REGISTERS

FFC0                    V0CLR    RMB   1                   ; CLEAR COCO GRAPHICS MODE V0
FFC1                    V0SET    RMB   1                   ; SET COCO GRAPHICS MODE V0
FFC2                    V1CLR    RMB   1                   ; CLEAR COCO GRAPHICS MODE V1
FFC3                    V1SET    RMB   1                   ; SET COCO GRAPHICS MODE V1
FFC4                    V2CLR    RMB   1                   ; CLEAR COCO GRAPHICS MODE V2
FFC5                    V2SET    RMB   1                   ; SET COCO GRAPHICS MODE V2
FFC6                    F0CLR    RMB   1                   ; CLEAR COCO GRAPHICS OFFSET F0
FFC7                    F0SET    RMB   1                   ; SET COCO GRAPHICS OFFSET F0
FFC8                    F1CLR    RMB   1                   ; CLEAR COCO GRAPHICS OFFSET F1
FFC9                    F1SET    RMB   1                   ; SET COCO GRAPHICS OFFSET F1
FFCA                    F2CLR    RMB   1                   ; CLEAR COCO GRAPHICS OFFSET F2
FFCB                    F2SET    RMB   1                   ; SET COCO GRAPHICS OFFSET F2
FFCC                    F3CLR    RMB   1                   ; CLEAR COCO GRAPHICS OFFSET F3
FFCD                    F3SET    RMB   1                   ; SET COCO GRAPHICS OFFSET F3
FFCE                    F4CLR    RMB   1                   ; CLEAR COCO GRAPHICS OFFSET F4
FFCF                    F4SET    RMB   1                   ; SET COCO GRAPHICS OFFSET F4
FFD0                    F5CLR    RMB   1                   ; CLEAR COCO GRAPHICS OFFSET F5
FFD1                    F5SET    RMB   1                   ; SET COCO GRAPHICS OFFSET F5
FFD2                    F6CLR    RMB   1                   ; CLEAR COCO GRAPHICS OFFSET F6
FFD3                    F6SET    RMB   1                   ; SET COCO GRAPHICS OFFSET F6
FFD4                             RMB   4                   ; RESERVED
FFD8                    R1CLR    RMB   1                   ; CLEAR CPU RATE, (0.89 MHz)
FFD9                    R1SET    RMB   1                   ; SET CPU RATE, (1.78 MHz)
FFDA                             RMB   4                   ; RESERVED
FFDE                    ROMCLR   RMB   1                   ; ROM DISABLED
FFDF                    ROMSET   RMB   1                   ; ROM ENABLED

FFE0                             RMB   18                  ; RESERVED FOR FUTURE MPU ENHANCEMENTS
                        *        INTERRUPT VECTORS
FFF2                    SWI3     RMB   2
FFF4                    SWI2     RMB   2
FFF6                    FIRQ     RMB   2
FFF8                    IRQ      RMB   2
FFFA                    SWI      RMB   2
FFFC                    NMI      RMB   2
FFFE                    RESETV   RMB   2
