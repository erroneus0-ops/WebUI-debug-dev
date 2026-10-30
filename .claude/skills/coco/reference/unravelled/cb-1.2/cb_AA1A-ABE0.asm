; Color BASIC 1.2 -- $AA1A-$ABE0
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: BROMHK=$AA1A

*
* SET CARRY IF NUMERIC - RETURN WITH
* ZERO FLAG SET IF ACCA = 0 OR 3A(:) - END
* OF BASIC LINE OR SUB LINE
AA1A  81 3A             BROMHK   CMPA  #'9+1               ; IS THIS CHARACTER >=(ASCII 9)+1?
AA1C  24 0A                      BHS   LAA28               ; BRANCH IF > 9; Z SET IF = COLON
AA1E  81 20                      CMPA  #SPACE              ; SPACE?
AA20  26 02                      BNE   LAA24               ; NO - SET CARRY IF NUMERIC
AA22  0E 9F                      JMP   GETNCH              ; IF SPACE, GET NECT CHAR (IGNORE SPACES)
AA24  80 30             LAA24    SUBA  #'0                 ; * SET CARRY IF
AA26  80 D0                      SUBA  #-'0                ; * CHARACTER > ASCII 0
AA28  39                LAA28    RTS
*
* DISPATCH TABLE FOR SECONDARY FUNCTIONS
* TOKENS ARE PRECEEDED BY $FF       TOKEN #
AA29  BC 7A             LAA29    FDB   SGN                 ; SGN     80
AA2B  BC EE                      FDB   INT                 ; INT     81
AA2D  BC 93                      FDB   ABS                 ; ABS     82
AA2F  01 12                      FDB   $0112               ; USR     83
AA31  BF 1F                      FDB   RND                 ; RND     84
AA33  BF 78                      FDB   SIN                 ; SIN     85
AA35  B7 50                      FDB   PEEK                ; PEEK    86
AA37  B6 81                      FDB   LEN                 ; LEN     87
AA39  B4 FD                      FDB   STR                 ; STR$    88
AA3B  B7 16                      FDB   VAL                 ; VAL     89
AA3D  B6 A0                      FDB   ASC                 ; ASC     8A
AA3F  B6 8C                      FDB   CHR                 ; CHR$    8B
AA41  A5 CE                      FDB   EOF                 ; EOF     8C
AA43  A9 C6                      FDB   JOYSTK              ; JOYSTK  8D
AA45  B6 AB                      FDB   LEFT                ; LEFT$   8E
AA47  B6 C8                      FDB   RIGHT               ; RIGHT$  8F
AA49  B6 CF                      FDB   MID                 ; MID$    90
AA4B  A8 F5                      FDB   POINT               ; POINT   91
AA4D  A5 64                      FDB   INKEY               ; INKEY$  92
AA4F  B4 EE                      FDB   MEM                 ; MEM     93
*
* THIS TABLE CONTAINS PRECEDENCES AND DISPATCH ADDRESSES FOR ARITHMETIC
* AND LOGICAL OPERATORS - THE NEGATION OPERATORS DO NOT ACT ON TWO OPERANDS
* S0 THEY ARE NOT LISTED IN THIS TABLE. THEY ARE TREATED SEPARATELY IN THE
* EXPRESSION EVALUATION ROUTINE. THEY ARE:
* UNARY NEGATION (-), PRECEDENCE &7D AND LOGICAL NEGATION (NOT), PRECEDENCE $5A
* THE RELATIONAL OPERATORS < > = ARE ALSO NOT LISTED, PRECEDENCE $64.
* A PRECEDENCE VALUE OF ZERO INDICATES END OF EXPRESSION OR PARENTHESES
*
AA51  79                LAA51    FCB   $79
AA52  B9 C5                      FDB   LB9C5               ; +
AA54  79                         FCB   $79
AA55  B9 BC                      FDB   LB9BC               ; -
AA57  7B                         FCB   $7B
AA58  BA CC                      FDB   $BACC               ; *
AA5A  7B                         FCB   $7B
AA5B  BB 91                      FDB   $BB91               ; /
AA5D  7F                         FCB   $7F
AA5E  01 1D                      FDB   $011D               ; EXPONENTIATION
AA60  50                         FCB   $50
AA61  B2 D5                      FDB   $B2D5               ; AND
AA63  46                         FCB   $46
AA64  B2 D4                      FDB   LB2D4               ; OR
*
* THIS IS THE RESERVED WORD TABLE
* TOKEN #
AA66  46 4F D2          LAA66    FCC   'FO',$80+'R'        ; 80
AA69  47 CF                      FCC   'G',$80+'O'         ; 81
AA6B  52 45 CD                   FCC   'RE',$80+'M'        ; 82
AA6E  A7                         FCB   '' + $80            ; 83
AA6F  45 4C 53 C5                FCC   'ELS',$80+'E'       ; 84
AA73  49 C6                      FCC   'I',$80+'F'         ; 85
AA75  44 41 54 C1                FCC   'DAT',$80+'A'       ; 86
AA79  50 52 49 4E D4             FCC   'PRIN',$80+'T'      ; 87
AA7E  4F CE                      FCC   'O',$80+'N'         ; 88
AA80  49 4E 50 55 D4             FCC   'INPU',$80+'T'      ; 89
AA85  45 4E C4                   FCC   'EN',$80+'D'        ; 8A
AA88  4E 45 58 D4                FCC   'NEX',$80+'T'       ; 8B
AA8C  44 49 CD                   FCC   'DI',$80+'M'        ; 8C
AA8F  52 45 41 C4                FCC   'REA',$80+'D'       ; 8D
AA93  52 55 CE                   FCC   'RU',$80+'N'        ; 8E
AA96  52 45 53 54 4F 52          FCC   'RESTOR',$80+'E'    ; 8F
AA9C  C5
AA9D  52 45 54 55 52 CE          FCC   'RETUR',$80+'N'     ; 90
AAA3  53 54 4F D0                FCC   'STO',$80+'P'       ; 91
AAA7  50 4F 4B C5                FCC   'POK',$80+'E'       ; 92
AAAB  43 4F 4E D4                FCC   'CON',$80+'T'       ; 93
AAAF  4C 49 53 D4                FCC   'LIS',$80+'T'       ; 94
AAB3  43 4C 45 41 D2             FCC   'CLEA',$80+'R'      ; 95
AAB8  4E 45 D7                   FCC   'NE',$80+'W'        ; 96
AABB  43 4C 4F 41 C4             FCC   'CLOA',$80+'D'      ; 97
AAC0  43 53 41 56 C5             FCC   'CSAV',$80+'E'      ; 98
AAC5  4F 50 45 CE                FCC   'OPE',$80+'N'       ; 99
AAC9  43 4C 4F 53 C5             FCC   'CLOS',$80+'E'      ; 9A
AACE  4C 4C 49 53 D4             FCC   'LLIS',$80+'T'      ; 9B
AAD3  53 45 D4                   FCC   'SE',$80+'T'        ; 9C
AAD6  52 45 53 45 D4             FCC   'RESE',$80+'T'      ; 9D
AADB  43 4C D3                   FCC   'CL',$80+'S'        ; 9E
AADE  4D 4F 54 4F D2             FCC   'MOTO',$80+'R'      ; 9F
AAE3  53 4F 55 4E C4             FCC   'SOUN',$80+'D'      ; A0
AAE8  41 55 44 49 CF             FCC   'AUDI',$80+'O'      ; A1
AAED  45 58 45 C3                FCC   'EXE',$80+'C'       ; A2
AAF1  53 4B 49 50 C6             FCC   'SKIP',$80+'F'      ; A3
AAF6  54 41 42 A8                FCC   'TAB',$80+'('       ; A4
AAFA  54 CF                      FCC   'T',$80+'O'         ; A5
AAFC  53 55 C2                   FCC   'SU',$80+'B'        ; A6
AAFF  54 48 45 CE                FCC   'THE',$80+'N'       ; A7
AB03  4E 4F D4                   FCC   'NO',$80+'T'        ; A8
AB06  53 54 45 D0                FCC   'STE',$80+'P'       ; A9
AB0A  4F 46 C6                   FCC   'OF',$80+'F'        ; AA
AB0D  AB                         FCC   '+' + $80           ; AB
AB0E  AD                         FCB   '-' + $80           ; AC
AB0F  AA                         FCB   '*' + $80           ; AD
AB10  AF                         FCB   '/' + $80           ; AE
AB11  DE                         FCB   '^' + $80           ; AF
AB12  41 4E C4                   FCC   'AN',$80+'D'        ; B0
AB15  4F D2                      FCC   'O',$80+'R'         ; B1
AB17  BE                         FCB   '>' + $80           ; B2
AB18  BD                         FCB   '=' + $80           ; B3
AB19  BC                         FCB   '<' + $80           ; B4
*
* TOKENS FOR THE SECONDARY FUNCTIONS ARE PRECEEDED BY $FF
* TOKEN #
AB1A  53 47 CE          LAB1A    FCC   'SG',$80+'N'        ; 80
AB1D  49 4E D4                   FCC   'IN',$80+'T'        ; 81
AB20  41 42 D3                   FCC   'AB',$80+'S'        ; 82
AB23  55 53 D2                   FCC   'US',$80+'R'        ; 83
AB26  52 4E C4                   FCC   'RN',$80+'D'        ; 84
AB29  53 49 CE                   FCC   'SI',$80+'N'        ; 85
AB2C  50 45 45 CB                FCC   'PEE',$80+'K'       ; 86
AB30  4C 45 CE                   FCC   'LE',$80+'N'        ; 87
AB33  53 54 52 A4                FCC   'STR',$80+'$'       ; 88
AB37  56 41 CC                   FCC   'VA',$80+'L'        ; 89
AB3A  41 53 C3                   FCC   'AS',$80+'C'        ; 8A
AB3D  43 48 52 A4                FCC   'CHR',$80+'$'       ; 8B
AB41  45 4F C6                   FCC   'EO',$80+'F'        ; 8C
AB44  4A 4F 59 53 54 CB          FCC   'JOYST',$80+'K'     ; 8D
AB4A  4C 45 46 54 A4             FCC   'LEFT',$80+'$'      ; 8E
AB4F  52 49 47 48 54 A4          FCC   'RIGHT',$80+'$'     ; 8F
AB55  4D 49 44 A4                FCC   'MID',$80+'$'       ; 90
AB59  50 4F 49 4E D4             FCC   'POIN',$80+'T'      ; 91
AB5E  49 4E 4B 45 59 A4          FCC   'INKEY',$80+'$'     ; 92
AB64  4D 45 CD                   FCC   'ME',$80+'M'        ; 93
*
* DISPATCH TABLE FOR COMMANDS       TOKEN #
AB67  AD 47             LAB67    FDB   FOR                 ; FOR     80
AB69  AE 86                      FDB   GO                  ; GO      81
AB6B  AE E3                      FDB   REM                 ; REM     82
AB6D  AE E3                      FDB   REM                 ; REM     83
AB6F  AE E3                      FDB   REM                 ; ELSE    84
AB71  AF 14                      FDB   IF                  ; IF      85
AB73  AE E0                      FDB   DATA                ; DATA    86
AB75  B8 F7                      FDB   PRINT               ; PRINT   87
AB77  AF 42                      FDB   ON                  ; ON      88
AB79  AF F5                      FDB   INPUT               ; INPUT   89
AB7B  AE 02                      FDB   END                 ; END     8A
AB7D  B0 F8                      FDB   NEXT                ; NEXT    8B
AB7F  B3 4E                      FDB   DIM                 ; DIM     8C
AB81  B0 46                      FDB   READ                ; READ    8D
AB83  AE 75                      FDB   RUN                 ; RUN     8E
AB85  AD E4                      FDB   RESTOR              ; RESTORE 8F
AB87  AE C0                      FDB   RETURN              ; RETURN  90
AB89  AE 09                      FDB   STOP                ; STOP    91
AB8B  B7 57                      FDB   POKE                ; POKE    92
AB8D  AE 30                      FDB   CONT                ; CONTINUE93
AB8F  B7 64                      FDB   LIST                ; LIST    94
AB91  AE 41                      FDB   CLEAR               ; CLEAR   95
AB93  AD 17                      FDB   NEW                 ; NEW     96
AB95  A4 98                      FDB   CLOAD               ; CLOAD   97
AB97  A4 4C                      FDB   CSAVE               ; CSAVE   98
AB99  A5 F6                      FDB   OPEN                ; OPEN    99
AB9B  A4 16                      FDB   CLOSE               ; CLOSE   9A
AB9D  B7 5E                      FDB   LLIST               ; LLIST   9B
AB9F  A8 80                      FDB   SET                 ; SET     9C
ABA1  A8 B1                      FDB   RESET               ; RESET   9D
ABA3  A9 10                      FDB   CLS                 ; CLS     9E
ABA5  A7 BD                      FDB   MOTOR               ; MOTOR   9F
ABA7  A9 4B                      FDB   SOUND               ; SOUND   A0
ABA9  A9 90                      FDB   AUDIO               ; AUDIO   A1
ABAB  A5 3E                      FDB   EXEC                ; EXEC    A2
ABAD  A5 EC                      FDB   SKIPF               ; SKIPF   A3
*
* ERROR MESSAGES AND THEIR NUMBERS AS USED INTERNALLY
ABAF  4E 46             LABAF    FCC   'NF'                ; 0  NEXT WITHOUT FOR
ABB1  53 4E                      FCC   'SN'                ; 1  SYNTAX ERROR
ABB3  52 47                      FCC   'RG'                ; 2  RETURN WITHOUT GOSUB
ABB5  4F 44                      FCC   'OD'                ; 3  OUT OF DATA
ABB7  46 43                      FCC   'FC'                ; 4  ILLEGAL FUNCTION CALL
ABB9  4F 56                      FCC   'OV'                ; 5  OVERFLOW
ABBB  4F 4D                      FCC   'OM'                ; 6  OUT OF MEMORY
ABBD  55 4C                      FCC   'UL'                ; 7  UNDEFINED LINE NUMBER
ABBF  42 53                      FCC   'BS'                ; 8  BAD SUBSCRIPT
ABC1  44 44                      FCC   'DD'                ; 9  REDIMENSIONED ARRAY
ABC3  2F 30                      FCC   '/0'                ; 10 DIVISION BY ZERO
ABC5  49 44                      FCC   'ID'                ; 11 ILLEGAL DIRECT STATEMENT
ABC7  54 4D                      FCC   'TM'                ; 12 TYPE MISMATCH
ABC9  4F 53                      FCC   'OS'                ; 13 OUT OF STRING SPACE
ABCB  4C 53                      FCC   'LS'                ; 14 STRING TOO LONG
ABCD  53 54                      FCC   'ST'                ; 15 STRING FORMULA TOO COMPLEX
ABCF  43 4E                      FCC   'CN'                ; 16 CAN'T CONTINUE
ABD1  46 44                      FCC   'FD'                ; 17 BAD FILE DATA
ABD3  41 4F                      FCC   'AO'                ; 18 FILE ALREADY OPEN
ABD5  44 4E                      FCC   'DN'                ; 19 DEVICE NUMBER ERROR
ABD7  49 4F                      FCC   'IO'                ; 20 I/O ERROR
ABD9  46 4D                      FCC   'FM'                ; 21 BAD FILE MODE
ABDB  4E 4F                      FCC   'NO'                ; 22 FILE NOT OPEN
ABDD  49 45                      FCC   'IE'                ; 23 INPUT PAST END OF FILE
ABDF  44 53                      FCC   'DS'                ; 24 DIRECT STATEMENT IN FILE
