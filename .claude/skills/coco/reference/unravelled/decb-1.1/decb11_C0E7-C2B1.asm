; Disk Extended Color BASIC 1.1 -- $C0E7-$C2B1
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: DKWMST=$C0E7, DVEC17=$C265, BASEXT=$C2A6, DEFEXT=$C2A9, DATEXT=$C2AC, BINEXT=$C2AF

C0E7  12                DKWMST   NOP                       ; WARM START INDICATOR
C0E8  8D 06                      BSR   LC0F0               ; INITIALIZE THE FLOPPY DISK CONTROLLER
C0EA  BD D2 D2                   JSR   LD2D2               ; CLOSE FILES AND DO MORE INITIALIZATION
C0ED  7E 80 C0                   JMP   XBWMST              ; JUMP TO EXBAS' WARM START
C0F0  7F 09 82          LC0F0    CLR   NMIFLG              ; RESET NMI FLAG
C0F3  7F 09 85                   CLR   RDYTMR              ; RESET DRIVE NOT READY TIMER
C0F6  7F 09 86                   CLR   DRGRAM              ; RESET RAM IMAGE OF DSKREG (MOTORS OFF)
C0F9  7F FF 40                   CLR   DSKREG              ; RESET DISK CONTROL REGISTER
C0FC  86 D0                      LDA   #$D0                ; FORCE INTERRUPT COMMAND OF 1793
C0FE  B7 FF 48                   STA   FDCREG              ; SEND IT TO 1793
C101  1E 88                      EXG   A,A                 ; * DELAY
C103  1E 88                      EXG   A,A                 ; * DELAY SOME MORE
C105  B6 FF 48                   LDA   FDCREG              ; GET 1793 STATUS (CLEAR REGISTER)
C108  39                         RTS

* DISK BASIC COMMAND INTERP TABLES
C109  14                LC109    FCB   20                  ; 20 DISK BASIC 1.1 COMMANDS
C10A  C1 92                      FDB   LC192               ; DISK BASIC'S COMMAND DICTIONARY
C10C  C2 38                      FDB   LC238               ; COMMAND JUMP TABLE
C10E  06                         FCB   06                  ; 6 DISK BASIC SECONDARY FUNCTIONS
C10F  C2 19                      FDB   LC219               ; SECONDARY FUNCTION TABLE
C111  C2 4E                      FDB   LC24E               ; SECONDARY FUNCTION JUMP TABLE

* RAM HOOKS FOR DISK BASIC
C113  C4 4B C8 88 C8 93 LC113    FDB   DVEC0,DVEC1,DVEC2
C119  CC 1C C5 BC C8 48          FDB   DVEC3,DVEC4,DVEC5
C11F  C8 4B CA E9 CA F9          FDB   DVEC6,DVEC7,DVEC8
C125  8E 90 CD 35 C8 A9          FDB   XVEC9,DVEC10,DVEC11
C12B  C6 E4 CA E4 C9 0C          FDB   DVEC12,DVEC13,DVEC14
C131  CE D2 C6 E4                FDB   DVEC15,DVEC12
C135  C2 65 CA 3E                FDB   DVEC17,DVEC18

* DISK BASIC COPYRIGHT MESSAGE
C139  44 49 53 4B 20 45 LC139    FCC   'DISK EXTENDED COLOR BASIC 1.1'
C13F  58 54 45 4E 44 45
C145  44 20 43 4F 4C 4F
C14B  52 20 42 41 53 49
C151  43 20 31 2E 31
C156  0D                         FCB   CR
C157  43 4F 50 59 52 49          FDB   'COPYRIGHT (C) 198'
C15D  47 48 54 20 28 43
C163  29 20 31 39 38
C168  32                         FCB   CYEAR
C169  20 42 59 20 54 41          FCC   ' BY TANDY'
C16F  4E 44 59
C172  0D                         FCB   CR
C173  55 4E 44 45 52 20          FCC   'UNDER LICENSE FROM MICROSOFT'
C179  4C 49 43 45 4E 53
C17F  45 20 46 52 4F 4D
C185  20 4D 49 43 52 4F
C18B  53 4F 46 54
C18F  0D 0D 00                   FDB   CR,CR,0


* DISK BASIC COMMAND DICTIONARY TABLE
* TOKEN #
C192  44 49 D2          LC192    FCC   'DI',$80+'R'        ; CE
C195  44 52 49 56 C5             FCC   'DRIV',$80+'E'      ; CF
C19A  46 49 45 4C C4             FCC   'FIEL',$80+'D'      ; D0
C19F  46 49 4C 45 D3             FCC   'FILE',$80+'S'      ; D1
C1A4  4B 49 4C CC                FCC   'KIL',$80+'L'       ; D2
C1A8  4C 4F 41 C4                FCC   'LOA',$80+'D'       ; D3
C1AC  4C 53 45 D4                FCC   'LSE',$80+'T'       ; D4
C1B0  4D 45 52 47 C5             FCC   'MERG',$80+'E'      ; D5
C1B5  52 45 4E 41 4D C5          FCC   'RENAM',$80+'E'     ; D6
C1BB  52 53 45 D4                FCC   'RSE',$80+'T'       ; D7
C1BF  53 41 56 C5                FCC   'SAV',$80+'E'       ; D8
C1C3  57 52 49 54 C5             FCC   'WRIT',$80+'E'      ; D9
C1C8  56 45 52 49 46 D9          FCC   'VERIF',$80+'Y'     ; DA
C1CE  55 4E 4C 4F 41 C4          FCC   'UNLOA',$80+'D'     ; DB
C1D4  44 53 4B 49 4E C9          FCC   'DSKIN',$80+'I'     ; DC
C1DA  42 41 43 4B 55 D0          FCC   'BACKU',$80+'P'     ; DD
C1E0  43 4F 50 D9                FCC   'COP',$80+'Y'       ; DE
C1E4  44 53 4B 49 A4             FCC   'DSKI',$80+'$'      ; DF
C1E9  44 53 4B 4F A4             FCC   'DSKO',$80+'$'      ; E0
C1EE  44 4F D3                   FCC   'DO',$80+'S'        ; E1


* DISK BASIC COMMAND JUMP TABLE
* COMMAND / TOKEN #
C1F1  CC A9             LC1F1    FDB   DIR                 ; DIR / CE
C1F3  CE C5                      FDB   DRIVE               ; DRIVE / CF
C1F5  D0 BC                      FDB   FIELD               ; FIELD / D0
C1F7  D1 5C                      FDB   FILES               ; FILES / D1
C1F9  C6 EF                      FDB   KILL                ; KILL / D2
C1FB  CA 48                      FDB   LOAD                ; LOAD / D3
C1FD  D1 02                      FDB   LSET                ; LSET / D4
C1FF  CA 39                      FDB   MERGE               ; MERGE / D5
C201  D0 1B                      FDB   RENAME              ; RENAME / D6
C203  D1 01                      FDB   RSET                ; RSET / D7
C205  C9 E0                      FDB   SAVE                ; SAVE / D8
C207  D0 66                      FDB   WRITE               ; WRITE / D9
C209  D7 4E                      FDB   VERIFY              ; VERIFY / DA
C20B  D2 33                      FDB   UNLOAD              ; UNLOAD / DB
C20D  D5 99                      FDB   DSKINI              ; DSKINI /DC
C20F  D2 62                      FDB   BACKUP              ; BACKUP / DD
C211  D3 B9                      FDB   COPY                ; COPY / DE
C213  D4 ED                      FDB   DSKI                ; DSKI$ / DF
C215  D5 62                      FDB   DSKO                ; DSKO$ / E0
C217  D6 EC                      FDB   DOS                 ; DOS / E1


* SECONDARY FUNCTION DICTIONARY TABLE
* TOKEN #
C219  43 56 CE          LC219    FCC   'CV',$80+'N'        ; A2
C21C  46 52 45 C5                FCC   'FRE',$80+'E'       ; A3
C220  4C 4F C3                   FCC   'LO',$80+'C'        ; A4
C223  4C 4F C6                   FCC   'LO',$80+'F'        ; A5
C226  4D 4B 4E A4                FCC   'MKN',$80+'$'       ; A6
C22A  41 D3                      FCC   'A',$80+'S'         ; A7


* DISK BASIC SECONDARY FUNCTION JUMP TABLE
* FUNCTION / TOKEN #
C22C  CD F4             LC22C    FDB   CVN                 ; CVN / A2
C22E  CE 9C                      FDB   FREE                ; FREE / A3
C230  CE 10                      FDB   LOC                 ; LOC / A4
C232  CE 37                      FDB   LOF                 ; LOF / A5
C234  CE 02                      FDB   MKN$                ; MKN$ / A6
C236  B2 77                      FDB   AS                  ; AS / A7

*DISK BASIC COMMAND INTERPRETATION HANDLER
C238  81 E1             LC238    CMPA  #DHITOK             ; *COMPARE TO HIGHEST DISK BASIC TOKEN
C23A  22 08                      BHI   LC244               ; *AND BRANCH IF HIGHER
C23C  8E C1 F1                   LDX   #LC1F1              ; POINT X TO DISK BASIC COMMAND JUMP TABLE
C23F  80 CE                      SUBA  #$CE                ; SUBTRACT OUT LOWEST DISK BASIC COMMAND TOKEN
C241  7E AD D4                   JMP   LADD4               ; JUMP TO BASIC'S COMMAND HANDLER
C244  81 E1             LC244    CMPA  #DHITOK             ; COMPARE TO HIGHEST DISK BASIC TOKEN
C246  10 23 F0 2D                LBLS  LB277               ; 'SYNTAX' ERROR IF < DISK BASIC COMMAND TOKEN
C24A  6E 9F 01 41                JMP   [COMVEC+33]         ; PROCESS A USER COMMAND TOKEN
*DISK BASIC SECONDARY COMMAND INTERPRETATION HANDLER
C24E  C1 4E             LC24E    CMPB  #($A7-$80)*2        ; *COMPARE MODIFIED SECONDARY TOKEN TO
C250  23 04                      BLS   LC256               ; *HIGHEST DISK BASIC TOKEN & BRANCH IF HIGHER
C252  6E 9F 01 46                JMP   [,COMVEC+38]        ; JUMP TO USER SECONDARY COMMAND HANDLER
C256  C0 44             LC256    SUBB  #($A2-$80)*2        ; *SUBTRACT OUT THE SMALLEST SECONDARY
C258  34 04                      PSHS  B                   ; *DISK TOKEN & SAVE MODIFIED TOKEN ON THE STACK
C25A  BD B2 62                   JSR   LB262               ; SYNTAX CHECK FOR '(' AND EVALUATE EXPRESSION
C25D  35 04                      PULS  B                   ; RESTORE MODIFIED TOKEN
C25F  8E C2 2C                   LDX   #LC22C              ; POINT X TO SECONDARY COMMAND JUMP TABLE
C262  7E B2 CE                   JMP   LB2CE               ; JUMP TO BASIC'S SECONDARY COMMAND HANDLER

* ERROR DRIVER RAM VECTOR
C265  35 20             DVEC17   PULS  Y                   ; PUT THE RETURN ADDRESS INTO Y
C267  BD AD 33                   JSR   LAD33               ; RESET THE CONT FLAG, ETC
C26A  BD D2 D2                   JSR   LD2D2               ; INITIALIZE SOME DISK VARIABLES AND CLOSE FILES
C26D  34 24                      PSHS  Y,B                 ; PUT RETURN ADDRESS AND ERROR NUMBER ON THE STACK
C26F  BD CA E9                   JSR   DVEC7               ; CLOSE ALL FILES
C272  35 04                      PULS  B                   ; GET THE ERROR NUMBER BACK
C274  C1 36                      CMPB  #2*27               ; COMPARE TO THE LOWEST DISK ERROR NUMBER
C276  10 25 C6 76                LBCS  XVEC17              ; BRANCH TO EXBAS ERROR HANDLER IF NOT DISK ERROR NUMBER
C27A  32 62                      LEAS  $02,S               ; PURGE RETURN ADDRESS OFF THE STACK
C27C  BD A7 E9                   JSR   LA7E9               ; TURN OFF THE CASSETTE MOTOR
C27F  BD A9 74                   JSR   LA974               ; DISABLE THE ANALOG MULTIPLEXER
C282  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO THE SCREEN
C284  BD B9 5C                   JSR   LB95C               ; SEND A CR TO THE SCREEN
C287  BD B9 AF                   JSR   LB9AF               ; SEND A '?' TO THE SCREEN
C28A  8E C2 5A                   LDX   #LC290-2*27         ; POINT X TO DISK BASIC'S ERROR TABLE
C28D  7E AC 60                   JMP   LAC60               ; JUMP TO BASIC'S ERROR HANDLER

* DISK BASIC ERROR MESSAGES
C290  42 52             LC290    FCC   'BR'                ; 27 BAD RECORD
C292  44 46                      FCC   'DF'                ; 28 DISK FULL
C294  4F 42                      FCC   'OB'                ; 29 OUT OF BUFFER SPACE
C296  57 50                      FCC   'WP'                ; 30 WRITE PROTECTED
C298  46 4E                      FCC   'FN'                ; 31 BAD FILE NAME
C29A  46 53                      FCC   'FS'                ; 32 BAD FILE STRUCTURE
C29C  41 45                      FCC   'AE'                ; 33 FILE ALREADY EXISTS
C29E  46 4F                      FCC   'FO'                ; 34 FIELD OVERFLOW
C2A0  53 45                      FCC   'SE'                ; 35 SET TO NON-FIELDED STRING
C2A2  56 46                      FCC   'VF'                ; 36 VERIFICATION ERROR
C2A4  45 52                      FCC   'ER'                ; 37 WRITE OR INPUT PAST END OF RECORD

* DISK FILE EXTENSIONS
C2A6  42 41 53          BASEXT   FCC   'BAS'               ; BASIC FILE EXTENSION
C2A9  20 20 20          DEFEXT   FCC   '   '               ; BLANK (DEFAULT) FILE EXTENSION
C2AC  44 41 54          DATEXT   FCC   'DAT'               ; DATA FILE EXTENSION
C2AF  42 49 4E          BINEXT   FCC   'BIN'               ; BINARY FILE EXTENSION
