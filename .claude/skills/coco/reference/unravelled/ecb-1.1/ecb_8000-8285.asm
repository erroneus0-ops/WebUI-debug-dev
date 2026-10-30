; Extended Color BASIC 1.1 -- $8000-$8285
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: EXBAS=$8000, XBWMST=$80C0, XVEC3=$8273

8000                             ORG   $8000
8000  45 58             EXBAS    FCC   'EX'
*
* MOVE EXTENDED BASIC'S COMMAND INTERPRETATION TABLE FROM ROM TO RAM
8002  8E 80 DE          L8002    LDX   #L80DE              ; ROM ADDRESS
8005  CE 01 2A                   LDU   #COMVEC+10          ; RAM ADDRESS
8008  C6 0A                      LDB   #10                 ; 10 BYTES TO MOVE
800A  BD A5 9A                   JSR   LA59A               ; MOVE B BYTES FROM (X) TO (U)
800D  8E B2 77                   LDX   #LB277              ; ADDRESS OF SYNTAX ERROR
8010  AF 43                      STX   $03,U               ; PUT SYNTAX ERROR IN ADDRESS OF DISK
8012  AF 48                      STX   $08,U               ; BASIC'S COMMAND INTERPRETATION LOOPS
8014  8E 89 4C                   LDX   #XIRQSV             ; *PUT EXBASIC'S IRQ SERVICING ROUTINE
8017  BF 01 0D                   STX   IRQVEC+1            ; *ADDRESS IN THE IRQ VECTOR
801A  9E 8A                      LDX   ZERO                ; GET X=0
801C  BF 01 12                   STX   TIMVAL              ; INITIALIZE TIMER = 0
801F  BD 82 9C                   JSR   XVEC18              ; INITIALIZE A BUNCH OF VARIABLES
8022  CC 2C 05                   LDD   #$2C05              ; *INITIALIZE DLOAD TO 1200 BAUD AND
8025  DD E6                      STD   DLBAUD              ; *TIMEOUT CONSTANT TO 5
8027  8E 01 3E                   LDX   #USR0               ; =INITIALIZE ADDRESS OF START OF
802A  9F B0                      STX   USRADR              ; =USR JUMP TABLE
* INITIALIZE THE USR CALLS TO 'FC ERROR'
802C  CE B4 4A                   LDU   #LB44A              ; ADDRESS OF 'FC ERROR' ROUTINE
802F  C6 0A                      LDB   #10                 ; 10 USR CALLS IN EX BASIC
8031  EF 81             L8031    STU   ,X++                ; STORE 'FC' ERROR AT USR ADDRESSES
8033  5A                         DECB                      ; FINISHED ALL 10?
8034  26 FB                      BNE   L8031               ; NO

* MODIFY THE RAM HOOKS FOR THE NEW ROUTINES CONTAINED IN EXT BASIC
8036  86 7E                      LDA   #$7E                ; OP CODE OF 'JMP'
8038  B7 01 9A                   STA   RVEC20              ; =
803B  8E 82 B9                   LDX   #XVEC20             ; =
803E  BF 01 9B                   STX   RVEC20+1            ; = COMMAND INTERPRETATION LOOP
8041  B7 01 8B                   STA   RVEC15              ; *
8044  8E 88 46                   LDX   #XVEC15             ; *
8047  BF 01 8C                   STX   RVEC15+1            ; * EXPRESSION EVALUATION
804A  B7 01 97                   STA   RVEC19              ; =
804D  8E 87 E5                   LDX   #XVEC19             ; =
8050  BF 01 98                   STX   RVEC19+1            ; = ASCII TO FLOATING POINT CONVERSION
8053  B7 01 79                   STA   RVEC9               ; *
8056  8E 8E 90                   LDX   #XVEC9              ; *
8059  BF 01 7A                   STX   RVEC9+1             ; * PRINT
805C  B7 01 91                   STA   RVEC17              ; =
805F  8E 88 F0                   LDX   #XVEC17             ; =
8062  BF 01 92                   STX   RVEC17+1            ; = ERROR DRIVER
8065  B7 01 6A                   STA   RVEC4               ; *
8068  8E 8C F1                   LDX   #XVEC4              ; *
806B  BF 01 6B                   STX   RVEC4+1             ; * CONSOLE IN
806E  B7 01 67                   STA   RVEC3               ; =
8071  8E 82 73                   LDX   #XVEC3              ; =
8074  BF 01 68                   STX   RVEC3+1             ; = CONSOLE OUT
8077  B7 01 76                   STA   RVEC8               ; *
807A  8E 82 86                   LDX   #XVEC8              ; *
807D  BF 01 77                   STX   RVEC8+1             ; * CLOSE A FILE
8080  B7 01 A3                   STA   RVEC23              ; =
8083  8E 83 04                   LDX   #XVEC23             ; =
8086  BF 01 A4                   STX   RVEC23+1            ; = CRUNCH A BASIC LINE
8089  B7 01 94                   STA   RVEC18              ; *
808C  8E 82 9C                   LDX   #XVEC18             ; *
808F  BF 01 95                   STX   RVEC18+1            ; * RUN
8092  B7 01 1D                   STA   EXPJMP              ; STORE OP CODE OF JMP
8095  8E 84 89                   LDX   #L8489              ; GET EXPONENTIATION ADDRESS
8098  BF 01 1E                   STX   EXPJMP+1            ; SAVE IT
809B  BD 96 E6                   JSR   L96E6               ; GO INITIALIZE EXBAS GRAPHICS VARIABLES
809E  B6 FF 03                   LDA   PIA0+3              ; * ENABLE PIA0 TO
80A1  8A 01                      ORA   #$01                ; * PASS 60HZ
80A3  B7 FF 03                   STA   PIA0+3              ; * INTERRUPT TO MPU
80A6  8E 44 4B                   LDX   #'DK'               ; FIRST TWO BYTES OF DISK ROM
80A9  BC C0 00                   CMPX  DOSBAS              ; COMPARE TO DISK ROM ADDRESS
80AC  10 27 3F 52                LBEQ  DOSBAS+2            ; BRANCH IF DISK BASIC EXISTS
80B0  1C AF                      ANDCC #$AF                ; ENABLE INTERRUPTS
80B2  8E 80 E7                   LDX   #L80E6+1            ; POINT TO SIGN ON MESSAGE
80B5  BD B9 9C                   JSR   STRINOUT            ; DISPLAY IT
80B8  8E 80 C0                   LDX   #XBWMST             ; GET EXBAS WARM START (RESET) VECTOR
80BB  9F 72                      STX   RSTVEC              ; SAVE IT
80BD  7E A0 E2                   JMP   LA0E2               ; SET WARM START FLAG, ENTER BASIC
* EXBAS WARM START ENTRY POINT
80C0  12                XBWMST   NOP                       ; WARM START ENABLE
80C1  0F E3                      CLR   PLYTMR              ; =
80C3  0F E4                      CLR   PLYTMR+1            ; = CLEAR PLAY TIMER
80C5  B6 FF 03                   LDA   PIA0+3              ; * ENABLE PIA0 TO
80C8  8A 01                      ORA   #$01                ; * PASS 60HZ
80CA  B7 FF 03                   STA   PIA0+3              ; * INTERRUPT TO MPU
80CD  7E A0 E8                   JMP   BAWMST              ; JUMP TO BASIC'S WARM START
*
* THIS CODE IS A PATCH TO FIX THE PCLEAR BUG
80D0  96 68             L80D0    LDA   CURLIN              ; GET THE CURRENT LINE NUMBER
80D2  4C                         INCA                      ; TEST FOR DIRECT MODE
80D3  27 08                      BEQ   L80DD               ; RETURN IF DIRECT MODE
80D5  1F 20                      TFR   Y,D                 ; SAVE OFFSET IN ACCD
80D7  93 19                      SUBD  TXTTAB              ; SUBTRACT OUT START OF BASIC
80D9  D3 A6                      ADDD  CHARAD              ; ADD THE CURRENT BASIC INPUT POINTER
80DB  DD A6                      STD   CHARAD              ; SAVE NEW BASIC INPUT POINTER
80DD  39                L80DD    RTS

80DE  19                L80DE    FCB   25                  ; 25 EXBAS COMMANDS
80DF  81 83             L80DF    FDB   L8183               ; EXBAS RESERVED WORD DICTIONARY TABLE
80E1  81 3C             L80E1    FDB   L813C               ; EXBAS RESERVED WORD HANDLER
80E3  0E                L80E3    FCB   14                  ; 14 EXBAS SECONDARY COMMANDS
80E4  82 1E             L80E4    FDB   L821E               ; EXBAS SECONDARY RESERVED WORD TABLE
80E6  81 68             L80E6    FDB   L8168               ; EXBAS SECONDARY RESERVED WORD HANDLER

80E8  45 58 54 45 4E 44 L80E8    FCC   'EXTENDED COLOR BASIC 1.1'
80EE  45 44 20 43 4F 4C
80F4  4F 52 20 42 41 53
80FA  49 43 20 31 2E 31
8100  0D                L8100    FCB   CR
8101  43 4F 50 59 52 49 L8101    FCC   'COPYRIGHT (C) 1982'
8107  47 48 54 20 28 43
810D  29 20 31 39 38 32
8113  20 42 59 20 54 41                ' BY TANDY'
8119  4E 44 59
811C  0D                L811C    FCB   CR
811D  55 4E 44 45 52 20 L811D    FCC   'UNDER LICENSE FROM MICROSOFT'
8123  4C 49 43 45 4E 53
8129  45 20 46 52 4F 4D
812F  20 4D 49 43 52 4F
8135  53 4F 46 54
8139  0D 0D 00          L8139    FCB   CR,CR,0

* EXBAS COMMAND INTERPRETATION LOOP
813C  81 CB             L813C    CMPA  #$CB                ; $CB IS LARGEST EX BASIC COMMAND TOKEN
813E  22 08                      BHI   L8148               ; BRANCH IF > LARGEST TOKEN
8140  8E 81 F0                   LDX   #L81F0              ; POINT X TO EXBAS DISPATCH TABLE FOR COMMANDS
8143  80 B5                      SUBA  #$B5                ; $B5 IS SMALLEST EXBAS TOKEN
8145  7E AD D4                   JMP   LADD4               ; INTERPRET BASIC TOKEN HANDLER
8148  81 FF             L8148    CMPA  #$FF                ; CHECK FOR SECONDARY TOKEN
814A  27 08                      BEQ   L8154               ; BRANCH IF IT IS SECONDARY
814C  81 CD                      CMPA  #$CD                ; LARGEST EXBAS TOKEN
814E  23 15                      BLS   L8165               ; 'SYNTAX' ERROR FOR USING & FN
8150  6E 9F 01 37                JMP   [COMVEC+23]         ; GO TO DISK BASIC RESERVED WORD HANDLER
8154  9D 9F             L8154    JSR   GETNCH              ; GET AN INPUT CHARACTER FROM BASIC
8156  81 90                      CMPA  #$90                ; TOKEN FOR MID$
8158  10 27 05 7A                LBEQ  L86D6               ; BRANCH IF MID$
815C  81 9F                      CMPA  #$9F                ; TOKEN FOR TIMER
815E  10 27 07 FE                LBEQ  L8960               ; BRANCH IF TIMER
8162  BD 01 A0                   JSR   RVEC22              ; HOOK INTO RAM
8165  7E B2 77          L8165    JMP   LB277               ; 'SYNTAX' ERROR

* EXBAS SECONDARY COMMAND HANDLER
8168  C1 42             L8168    CMPB  #2*33               ; *80+33 IS LARGEST EXBAS SECONDARY COMMAND
816A  23 04                      BLS   L8170               ; BRANCH IF LEGITIMATE EXBAS SECONDARY TOKEN
816C  6E 9F 01 3C                JMP   [COMVEC+28]         ; GO TO DISK BASIC SECONDARY COMMAND HANDLER
8170  C0 28             L8170    SUBB  #2*20               ; SUBTRACT OUT 20 BASIC SECONDARY COMMANDS
8172  C1 10                      CMPB  #2*8                ; HEX$ TOKEN
8174  22 07                      BHI   L817D               ; BRANCH IF > HEX$
8176  34 04                      PSHS  B                   ; SAVE TOKEN OFFSET
8178  BD B2 62                   JSR   LB262               ; EVALUATE EXPRESSION IN PARENTHESES
817B  35 04                      PULS  B                   ; GET TOKEN OFFSET BACK
817D  8E 82 57          L817D    LDX   #L8257              ; EXBAS SECONDARY COMMAND JUMP TABLE
8180  7E B2 CE                   JMP   LB2CE               ; JUMP TO SECONDARY FUNCT1ON HANDLER

* RESERVED WORD TABLE FOR EXTENDED BASIC
* TOKEN #
8183  44 45 CC          L8183    FCC   'DE',$80+'L'        ; B5
8186  45 44 49 D4       L8186    FCC   'EDI',$80+'T'       ; B6
818A  54 52 4F CE       L818A    FCC   'TRO',$80+'N'       ; B7
818E  54 52 4F 46 C6    L818E    FCC   'TROF',$80+'F'      ; B8
8193  44 45 C6          L8193    FCC   'DE',$80+'F'        ; B9
8196  4C 45 D4          L8196    FCC   'LE',$80+'T'        ; BA
8199  4C 49 4E C5       L8199    FCC   'LIN',$80+'E'       ; BB
819D  50 43 4C D3       L819D    FCC   'PCL',$80+'S'       ; BC
81A1  50 53 45 D4       L81A1    FCC   'PSE',$80+'T'       ; BD
81A5  50 52 45 53 45 D4 L81A5    FCC   'PRESE',$80+'T'     ; BE
81AB  53 43 52 45 45 CE L81AB    FCC   'SCREE',$80+'N'     ; BF
81B1  50 43 4C 45 41 D2 L81B1    FCC   'PCLEA',$80+'R'     ; C0
81B7  43 4F 4C 4F D2    L81B7    FCC   'COLO',$80+'R'      ; C1
81BC  43 49 52 43 4C C5 L81BC    FCC   'CIRCL',$80+'E'     ; C2
81C2  50 41 49 4E D4    L81C2    FCC   'PAIN',$80+'T'      ; C3
81C7  47 45 D4          L81C7    FCC   'GE',$80+'T'        ; C4
81CA  50 55 D4          L81CA    FCC   'PU',$80+'T'        ; C5
81CD  44 52 41 D7       L81CD    FCC   'DRA',$80+'W'       ; C6
81D1  50 43 4F 50 D9    L81D1    FCC   'PCOP',$80+'Y'      ; C7
81D6  50 4D 4F 44 C5    L81D6    FCC   'PMOD',$80+'E'      ; C8
81DB  50 4C 41 D9       L81DB    FCC   'PLA',$80+'Y'       ; C9
81DF  44 4C 4F 41 C4    L81DF    FCC   'DLOA',$80+'D'      ; CA
81E4  52 45 4E 55 CD    L81E4    FCC   'RENU',$80+'M'      ; CB
81E9  46 CE             L81E9    FCC   'F',$80+'N'         ; CC
81EB  55 53 49 4E C7    L81EB    FCC   'USIN',$80+'G'      ; CD

* DISPATCH TABLE FOR EXTENDED BASIC COMMANDS
*       TOKEN #
81F0  89 70             L81F0    FDB   DEL                 ; DEL     B5
81F2  85 33             L81F2    FDB   EDIT                ; EDIT    B6
81F4  86 A7             L81F4    FDB   TRON                ; TRON    B7
81F6  86 A8             L81F6    FDB   TROFF               ; TROFF   B8
81F8  88 71             L81F8    FDB   DEF                 ; DEF     B9
81FA  AF 89             L81FA    FDB   LET                 ; LET     BA
81FC  93 BB             L81FC    FDB   LINE                ; LINE    BB
81FE  95 32             L81FE    FDB   PCLS                ; PCLS    BC
8200  93 61             L8200    FDB   PSET                ; PSET    BD
8202  93 65             L8202    FDB   PRESET              ; PRESET  BE
8204  96 70             L8204    FDB   SCREEN              ; SCREEN  BF
8206  96 8B             L8206    FDB   PCLEAR              ; PCLEAR  C0
8208  95 46             L8208    FDB   COLOR               ; COLOR   C1
820A  9E 9D             L820A    FDB   CIRCLE              ; CIRCLE  C2
820C  98 EC             L820C    FDB   PAINT               ; PAINT   C3
820E  97 55             L820E    FDB   GET                 ; GET     C4
8210  97 58             L8210    FDB   PUT                 ; PUT     C5
8212  9C B6             L8212    FDB   DRAW                ; DRAW    C6
8214  97 23             L8214    FDB   PCOPY               ; PCOPY   C7
8216  96 21             L8216    FDB   PMOD                ; PMODE   C7
8218  9A 22             L8218    FDB   PLAY                ; PLAY    C9
821A  8C 18             L821A    FDB   DLOAD               ; DLOAD   CA
821C  8A 09             L821C    FDB   RENUM               ; RENUM   CB

* SECONDARY FUNCTION FOR EXTENDED BASIC
* TOKENS ARE PRECEEDED WITH AN $FF BYTE
* TOKEN #
821E  41 54 CE          L821E    FCC   'AT',$80+'N'        ; 94
8221  43 4F D3          L8221    FCC   'CO',$80+'S'        ; 95
8224  54 41 CE          L8224    FCC   'TA',$80+'N'        ; 96
8227  45 58 D0          L8227    FCC   'EX',$80+'P'        ; 97
822A  46 49 D8          L822A    FCC   'FI',$80+'X'        ; 98
822D  4C 4F C7          L822D    FCC   'LO',$80+'G'        ; 99
8230  50 4F D3          L8230    FCC   'PO',$80+'S'        ; 9A
8233  53 51 D2          L8233    FCC   'SQ',$80+'R'        ; 9B
8236  48 45 58 A4       L8236    FCC   'HEX',$80+'$'       ; 9C
823A  56 41 52 50 54 D2 L823A    FCC   'VARPT',$80+'R'     ; 9D
8240  49 4E 53 54 D2    L8240    FCC   'INST',$80+'R'      ; 9E
8245  54 49 4D 45 D2    L8245    FCC   'TIME',$80+'R'      ; 9F
824A  50 50 4F 49 4E D4 L824A    FCC   'PPOIN',$80+'T'     ; A0
8250  53 54 52 49 4E 47 L8250    FCC   'STRING',$80+'$'    ; A1
8256  A4
* JUMP TABLE FOR EXTENDED BASIC SECONDARY FUNCTIONS
*       TOKEN #
8257  83 B0             L8257    FDB   ATN                 ; ATN     94
8259  83 78             L8259    FDB   COS                 ; COS     95
825B  83 81             L825B    FDB   TAN                 ; TAN     96
825D  84 F2             L825D    FDB   EXP                 ; EXP     97
825F  85 24             L825F    FDB   FIX                 ; FIX     98
8261  84 46             L8261    FDB   LOG                 ; LOG     99
8263  86 AC             L8263    FDB   POS                 ; POS     9A
8265  84 80             L8265    FDB   SQR                 ; SQR     9B
8267  8B DD             L8267    FDB   HEXDOL              ; HEXDOL  9C
8269  86 BE             L8269    FDB   VARPTR              ; VARPT   9D
826B  87 7E             L826B    FDB   INSTR               ; INSTR   9E
826D  89 68             L826D    FDB   TIMER               ; TIMER   9F
826F  93 39             L826F    FDB   PPOINT              ; PPOINT  A0
8271  87 4E             L8271    FDB   STRING              ; STRING  A1

* CONSOLE OUT RAM HOOK
8273  0D 6F             XVEC3    TST   DEVNUM              ; CHECK DEVICE NUMBER
8275  10 27 13 33                LBEQ  L95AC               ; BRANCH IF SCREEN
8279  34 04                      PSHS  B                   ; SAVE CHARACTER
827B  D6 6F                      LDB   DEVNUM              ; *GET DEVICE NUMBER AND
827D  C1 FD                      CMPB  #-3                 ; *CHECK FOR DLOAD
827F  35 04                      PULS  B                   ; GET CHARACTER BACK
8281  26 02                      BNE   L8285               ; RETURN IF NOT DLOAD
8283  32 62                      LEAS  $02,S               ; *TAKE RETURN OFF STACK & GO BACK TO ROUTINE
* *THAT CALLED CONSOLE OUT
8285  39                L8285    RTS
