; Disk Extended Color BASIC 1.0 -- $C0D4-$C299
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: DKWMST=$C0D4, DVEC17=$C24D, BASEXT=$C28E, DEFEXT=$C291, DATEXT=$C294, BINEXT=$C297

C0D4  12                DKWMST   NOP                       ; WARM START INDICATOR
C0D5  8D 06                      BSR   LC0DD               ; INITIALIZE THE FLOPPY DISK CONTROLLER
C0D7  BD D1 E5                   JSR   LD1E5               ; CLOSE FILES AND DO MORE INITIALIZATION
C0DA  7E 80 C0                   JMP   XBWMST              ; JUMP TO EXBAS' WARM START
C0DD  7F 09 82          LC0DD    CLR   NMIFLG              ; RESET NMI FLAG
C0E0  7F 09 85                   CLR   RDYTMR              ; RESET DRIVE NOT READY TIMER
C0E3  7F 09 86                   CLR   DRGRAM              ; RESET RAM IMAGE OF DSKREG (MOTORS OFF)
C0E6  7F FF 40                   CLR   DSKREG              ; RESET DISK CONTROL REGISTER
C0E9  86 D0                      LDA   #$D0                ; FORCE INTERRUPT COMMAND OF 1793
C0EB  B7 FF 48                   STA   FDCREG              ; SEND IT TO 1793
C0EE  1E 88                      EXG   A,A                 ; * DELAY
C0F0  1E 88                      EXG   A,A                 ; * DELAY SOME MORE
C0F2  B6 FF 48                   LDA   FDCREG              ; GET 1793 STATUS (CLEAR REGISTER)
C0F5  39                         RTS

* DISK BASIC COMMAND INTERP TABLES
C0F6  13                LC0F6    FCB   19                  ; 19 DISK BASIC 1.0 COMMANDS
C0F7  C1 7F                      FDB   LC17F               ; DISK BASIC'S COMMAND DICTIONARY
C0F9  C2 20                      FDB   LC220               ; COMMAND JUMP TABLE
C0FB  06                         FCB   6                   ; 6 DISK BASIC SECONDARY FUNCTIONS
C0FC  C2 01                      FDB   LC201               ; SECONDARY FUNCTION TABLE
C0FE  C2 36                      FDB   LC236               ; SECONDARY FUNCTION JUMP TABLE

* RAM HOOKS FOR DISK BASIC
C100  C4 26 C8 38 C8 43 LC100    FDB   DVEC0,DVEC1,DVEC2
C106  CB 4A C5 8F C8 18          FDB   DVEC3,DVEC4,DVEC5
C10C  C8 1B CA 3B CA 4B          FDB   DVEC6,DVEC7,DVEC8
C112  8E 90 CC 5B C8 59          FDB   XVEC9,DVEC10,DVEC11
C118  C6 B7 CA 36 C8 60          FDB   DVEC12,DVEC13,DVEC14
C11E  CD F6 C6 B7 C2 4D          FDB   DVEC15,DVEC12,DVEC17
C124  C9 90                      FDB   DVEC18

* DISK BASIC COPYRIGHT MESSAGE
C126  44 49 53 4B 20 45 LC126    FCC   'DISK EXTENDED COLOR BASIC 1.0'
C12C  58 54 45 4E 44 45
C132  44 20 43 4F 4C 4F
C138  52 20 42 41 53 49
C13E  43 20 31 2E 30
C143  0D                         FCB   CR
C144  43 4F 50 59 52 49          FDB   'COPYRIGHT (C) 198'
C14A  47 48 54 20 28 43
C150  29 20 31 39 38
C155  31                         FCB   CYEAR               ; [bytes corrected to match genuine ROM; spreadsheet had 32]
C156  20 42 59 20 54 41          FCC   ' BY TANDY'
C15C  4E 44 59
C15F  0D                         FCB   CR
C160  55 4E 44 45 52 20          FCC   'UNDER LICENSE FROM MICROSOFT'
C166  4C 49 43 45 4E 53
C16C  45 20 46 52 4F 4D
C172  20 4D 49 43 52 4F
C178  53 4F 46 54
C17C  0D 0D 00                   FDB   CR,CR,0

* DISK BASIC COMMAND DICTIONARY TABLE
* TOKEN #
C17F  44 49 D2          LC17F    FCC   'DI',$80+'R'        ; CE
C182  44 52 49 56 C5             FCC   'DRIV',$80+'E'      ; CF
C187  46 49 45 4C C4             FCC   'FIEL',$80+'D'      ; D0
C18C  46 49 4C 45 D3             FCC   'FILE',$80+'S'      ; D1
C191  4B 49 4C CC                FCC   'KIL',$80+'L'       ; D2
C195  4C 4F 41 C4                FCC   'LOA',$80+'D'       ; D3
C199  4C 53 45 D4                FCC   'LSE',$80+'T'       ; D4
C19D  4D 45 52 47 C5             FCC   'MERG',$80+'E'      ; D5
C1A2  52 45 4E 41 4D C5          FCC   'RENAM',$80+'E'     ; D6
C1A8  52 53 45 D4                FCC   'RSE',$80+'T'       ; D7
C1AC  53 41 56 C5                FCC   'SAV',$80+'E'       ; D8
C1B0  57 52 49 54 C5             FCC   'WRIT',$80+'E'      ; D9
C1B5  56 45 52 49 46 D9          FCC   'VERIF',$80+'Y'     ; DA
C1BB  55 4E 4C 4F 41 C4          FCC   'UNLOA',$80+'D'     ; DB
C1C1  44 53 4B 49 4E C9          FCC   'DSKIN',$80+'I'     ; DC
C1C7  42 41 43 4B 55 D0          FCC   'BACKU',$80+'P'     ; DD
C1CD  43 4F 50 D9                FCC   'COP',$80+'Y'       ; DE
C1D1  44 53 4B 49 A4             FCC   'DSKI',$80+'$'      ; DF
C1D6  44 53 4B 4F A4             FCC   'DSKO',$80+'$'      ; E0

* DISK BASIC COMMAND JUMP TABLE
* COMMAND / TOKEN #
C1DB  CB CF             LC1DB    FDB   DIR                 ; DIR / CE [bytes corrected to match genuine ROM; spreadsheet had CC A9]
C1DD  CD E9                      FDB   DRIVE               ; DRIVE / CF [bytes corrected to match genuine ROM; spreadsheet had CE C5]
C1DF  CF E0                      FDB   FIELD               ; FIELD / D0 [bytes corrected to match genuine ROM; spreadsheet had D0 BC]
C1E1  D0 80                      FDB   FILES               ; FILES / D1 [bytes corrected to match genuine ROM; spreadsheet had D1 5C]
C1E3  C6 C2                      FDB   KILL                ; KILL / D2 [bytes corrected to match genuine ROM; spreadsheet had C6 EF]
C1E5  C9 9A                      FDB   LOAD                ; LOAD / D3 [bytes corrected to match genuine ROM; spreadsheet had CA 48]
C1E7  D0 26                      FDB   LSET                ; LSET / D4 [bytes corrected to match genuine ROM; spreadsheet had D1 02]
C1E9  C9 8B                      FDB   MERGE               ; MERGE / D5 [bytes corrected to match genuine ROM; spreadsheet had CA 39]
C1EB  CF 3F                      FDB   RENAME              ; RENAME / D6 [bytes corrected to match genuine ROM; spreadsheet had D0 1B]
C1ED  D0 25                      FDB   RSET                ; RSET / D7 [bytes corrected to match genuine ROM; spreadsheet had D1 01]
C1EF  C9 32                      FDB   SAVE                ; SAVE / D8 [bytes corrected to match genuine ROM; spreadsheet had C9 E0]
C1F1  CF 8A                      FDB   WRITE               ; WRITE / D9 [bytes corrected to match genuine ROM; spreadsheet had D0 66]
C1F3  D6 5B                      FDB   VERIFY              ; VERIFY / DA [bytes corrected to match genuine ROM; spreadsheet had D7 4E]
C1F5  D1 46                      FDB   UNLOAD              ; UNLOAD / DB [bytes corrected to match genuine ROM; spreadsheet had D2 33]
C1F7  D4 AB                      FDB   DSKINI              ; DSKINI /DC [bytes corrected to match genuine ROM; spreadsheet had D5 99]
C1F9  D1 75                      FDB   BACKUP              ; BACKUP / DD [bytes corrected to match genuine ROM; spreadsheet had D2 62]
C1FB  D2 CC                      FDB   COPY                ; COPY / DE [bytes corrected to match genuine ROM; spreadsheet had D3 B9]
C1FD  D3 FF                      FDB   DSKI                ; DSKI$ / DF [bytes corrected to match genuine ROM; spreadsheet had D4 ED]
C1FF  D4 74                      FDB   DSKO                ; DSKO$ / E0 [bytes corrected to match genuine ROM; spreadsheet had D5 62]

* SECONDARY FUNCTION DICTIONARY TABLE
* TOKEN #
C201  43 56 CE          LC201    FCC   'CV',$80+'N'        ; A2
C204  46 52 45 C5                FCC   'FRE',$80+'E'       ; A3
C208  4C 4F C3                   FCC   'LO',$80+'C'        ; A4
C20B  4C 4F C6                   FCC   'LO',$80+'F'        ; A5
C20E  4D 4B 4E A4                FCC   'MKN',$80+'$'       ; A6
C212  41 D3                      FCC   'A',$80+'S'         ; A7

* DISK BASIC SECONDARY FUNCTION JUMP TABLE
* FUNCTION / TOKEN #
C214  CD 1A             LC214    FDB   CVN                 ; CVN / A2 [bytes corrected to match genuine ROM; spreadsheet had CD F4]
C216  CD C0                      FDB   FREE                ; FREE / A3 [bytes corrected to match genuine ROM; spreadsheet had CE 9C]
C218  CD 36                      FDB   LOC                 ; LOC / A4 [bytes corrected to match genuine ROM; spreadsheet had CE 10]
C21A  CD 5B                      FDB   LOF                 ; LOF / A5 [bytes corrected to match genuine ROM; spreadsheet had CE 37]
C21C  CD 28                      FDB   MKN$                ; MKN$ / A6 [bytes corrected to match genuine ROM; spreadsheet had CE 02]
C21E  B2 77                      FDB   AS                  ; AS / A7

C220  81 E0             LC220    CMPA  #DHITOK             ; *COMPARE TO HIGHEST DISK BASIC TOKEN
C222  22 08                      BHI   LC22C               ; *AND BRANCH IF HIGHER
C224  8E C1 DB                   LDX   #LC1DB              ; POINT X TO DISK BASIC COMMAND JUMP TABLE
C227  80 CE                      SUBA  #$CE                ; SUBTRACT OUT LOWEST DISK BASIC COMMAND TOKEN
C229  7E AD D4                   JMP   LADD4               ; JUMP TO BASIC'S COMMAND HANDLER
C22C  81 E0             LC22C    CMPA  #DHITOK             ; COMPARE TO HIGHEST DISK BASIC TOKEN
C22E  10 23 F0 45                LBLS  LB277               ; 'SYNTAX' ERROR IF < DISK BASIC COMMAND TOKEN
C232  6E 9F 01 41                JMP   [COMVEC+33]         ; PROCESS A USER COMMAND TOKEN
*DISK BASIC SECONDARY COMMAND INTERPRETATION HANDLER
C236  C1 4E             LC236    CMPB  $($A7-$80)*2        ; *COMPARE MODIFIED SECONDARY TOKEN TO
C238  23 04                      BLS   LC23E               ; *HIGHEST DISK BASIC TOKEN & BRANCH IF HIGHER
C23A  6E 9F 01 46                JMP   [COMVEC+38]         ; JUMP TO USER SECONDARY COMMAND HANDLER
C23E  C0 44             LC23E    SUBB  $($A2-$80)*2        ; *SUBTRACT OUT THE SMALLEST SECONDARY
C240  34 04                      PSHS  B                   ; *DISK TOKEN & SAVE MODIFIED TOKEN ON THE STACK
C242  BD B2 62                   JSR   LB262               ; SYNTAX CHECK FOR '(' AND EVALUATE EXPRESSION
C245  35 04                      PULS  B                   ; RESTORE MODIFIED TOKEN
C247  8E C2 14                   LDX   #LC214              ; POINT X TO SECONDARY COMMAND JUMP TABLE
C24A  7E B2 CE                   JMP   LB2CE               ; JUMP TO BASIC'S SECONDARY COMMAND HANDLER

* ERROR DRIVER RAM VECTOR
C24D  35 20             DVEC17   PULS  Y                   ; PUT THE RETURN ADDRESS INTO Y
C24F  BD AD 33                   JSR   LAD33               ; RESET THE CONT FLAG, ETC
C252  BD D1 E5                   JSR   LD1E5               ; INITIALIZE SOME DISK VARIABLES AND CLOSE FILES
C255  34 24                      PSHS  Y,B                 ; PUT RETURN ADDRESS AND ERROR NUMBER ON THE STACK
C257  BD CA 3B                   JSR   DVEC7               ; CLOSE ALL FILES
C25A  35 04                      PULS  B                   ; GET THE ERROR NUMBER BACK
C25C  C1 36                      CMPB  #2*27               ; COMPARE TO THE LOWEST DISK ERROR NUMBER
C25E  10 25 C6 8E                LBCS  XVEC17              ; BRANCH TO EXBAS ERROR HANDLER IF NOT DISK ERROR NUMBER
C262  32 62                      LEAS  $02,S               ; PURGE RETURN ADDRESS OFF THE STACK
C264  BD A7 E9                   JSR   LA7E9               ; TURN OFF THE CASSETTE MOTOR
C267  BD A9 74                   JSR   LA974               ; DISABLE THE ANALOG MULTIPLEXER
C26A  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO THE SCREEN
C26C  BD B9 5C                   JSR   LB95C               ; SEND A CR TO THE SCREEN
C26F  BD B9 AF                   JSR   LB9AF               ; SEND A '?' TO THE SCREEN
C272  8E C2 42                   LDX   #LC278-2*27         ; POINT X TO DISK BASIC'S ERROR TABLE
C275  7E AC 60                   JMP   LAC60               ; JUMP TO BASIC'S ERROR HANDLER

* DISK BASIC ERROR MESSAGES
C278  42 52             LC290    FCC   'BR'                ; 27 BAD RECORD
C27A  44 46                      FCC   'DF'                ; 28 DISK FULL
C27C  4F 42                      FCC   'OB'                ; 29 OUT OF BUFFER SPACE
C27E  57 50                      FCC   'WP'                ; 30 WRITE PROTECTED
C280  46 4E                      FCC   'FN'                ; 31 BAD FILE NAME
C282  46 53                      FCC   'FS'                ; 32 BAD FILE STRUCTURE
C284  41 45                      FCC   'AE'                ; 33 FILE ALREADY EXISTS
C286  46 4F                      FCC   'FO'                ; 34 FIELD OVERFLOW
C288  53 45                      FCC   'SE'                ; 35 SET TO NON-FIELDED STRING
C28A  56 46                      FCC   'VF'                ; 36 VERIFICATION ERROR
C28C  45 52                      FCC   'ER'                ; 37 WRITE OR INPUT PAST END OF RECORD

* DISK FILE EXTENSIONS
C28E  42 41 53          BASEXT   FCC   'BAS'               ; BASIC FILE EXTENSION
C291  20 20 20          DEFEXT   FCC   '   '               ; BLANK (DEFAULT) FILE EXTENSION
C294  44 41 54          DATEXT   FCC   'DAT'               ; DATA FILE EXTENSION
C297  42 49 4E          BINEXT   FCC   'BIN'               ; BINARY FILE EXTENSION
