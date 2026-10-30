; Super Extended Color BASIC 2.0 (CoCo 3) -- $E236-$E46F
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: COMDIS20=$E236, FUNDIC20=$E264, FUNDIS20=$E27E, ALINK12=$E288, ALINK28=$E297, ALINK29=$E29D, DISK20MS=$E2A3, MWAREMS=$E2F8, DISK21MS=$E316, ALINK14=$E389, ALINK18=$E3B4, ERR=$E3D4, BRK=$E3E6, ALINK6A=$E3F8, ALINK6B=$E40C, ALINK16=$E413, ALINK15=$E429

*
* BASIC 2.0 COMMAND DISPATCH TABLE
*
*         TOKEN #
E236  F6 36             COMDIS20 FDB   WIDTH               ; WIDTH   E2
E238  E5 F0             LE238    FDB   PALETTE             ; PALETTE E3
E23A  E6 88             LE23A    FDB   HSCREEN             ; HSCREEN E4
E23C  E5 45             LE23C    FDB   LPOKE               ; LPOKE   E5
E23E  E6 CF             LE23E    FDB   HCLS                ; HCLS    E6
E240  E6 F4             LE240    FDB   HCOLOR              ; HCOLOR  E7
E242  EB F5             LE242    FDB   HPAINT              ; HPAINT  E8
E244  EA 49             LE244    FDB   HCIRCLE             ; HCIRCLE E9
E246  E8 82             LE246    FDB   HLINE               ; HLINE   EA
E248  ED E5             LE248    FDB   HGET                ; HGET    EB
E24A  ED ED             LE24A    FDB   HPUT                ; HPUT    EC
E24C  ED 58             LE24C    FDB   HBUFF               ; HBUFF   ED
E24E  EF 3F             LE24E    FDB   HPRINT              ; HPRINT  EE
E250  E3 D4             LE250    FDB   ERR                 ; ERR     EF
E252  E3 E6             LE252    FDB   BRK                 ; BRK     F0
E254  F8 D2             LE254    FDB   LOCATE              ; LOCATE  F1
E256  F9 25             LE256    FDB   HSTAT               ; HSTAT   F2
E258  E7 61             LE258    FDB   HSET                ; HSET    F3
E25A  E7 65             LE25A    FDB   HRESET              ; HRESET  F4
E25C  F3 9D             LE25C    FDB   HDRAW               ; HDRAW   F5
E25E  E6 76             LE25E    FDB   CMP                 ; CMP     F6
E260  E6 74             LE260    FDB   RGB                 ; RGB     F7
E262  F9 B9             LE262    FDB   ATTR                ; ATTR    F8
*
* BASIC 2.0 FUNCTION DICTIONARY TABLE
*
* TOKEN #
E264  4C 50 45 45 CB    FUNDIC20 FCC   'LPEE',$80+'K'      ; A8
E269  42 55 54 54 4F CE LE269    FCC   'BUTTO',$80+'N'     ; A9
E26F  48 50 4F 49 4E D4 LE26F    FCC   'HPOIN',$80+'T'     ; AA
E275  45 52 4E CF       LE275    FCC   'ERN',$80+'O'       ; AB
E279  45 52 4C 49 CE    LE279    FCC   'ERLI',$80+'N'      ; AC
*
* BASIC 2.0 FUNCTION DISPATCH TABLE
*
*         TOKEN #
E27E  E5 73             FUNDIS20 FDB   LPEEK               ; LPEEK   A8
E280  E5 B1             LE280    FDB   BUTTON              ; BUTTON  A9
E282  E8 5C             LE282    FDB   HPOINT              ; HPOINT  AA
E284  E4 E9             LE284    FDB   ERNO                ; ERNO    AB
E286  E4 FD             LE286    FDB   ERLIN               ; ERLIN   AC

* PRINT THE COPYRIGHT MESSAGE PATCH ENTERED FROM $80B2
E288  8E 80 E7          ALINK12  LDX   #L80E7              ; POINT TO EXTENDED BASIC'S COPYRIGHT MESSAGE
E28B  BD B9 9C                   JSR   STRINOUT            ; COPY A STRING FROM (X) TO CONSOLE OUT
E28E  8E E2 F7                   LDX   #MWAREMS-1          ; MICROWARE'S COPYRIGHT MESSAGE
E291  BD B9 9C                   JSR   STRINOUT            ; COPY A STRING FROM (X) TO CONSOLE OUT
E294  7E 80 B8                   JMP   L80B8               ; EXTENDED BASIC'S WARM START REENTRY

* PRINT THE DISK BASIC 2.0 COPYRIGHT MESSAGE PATCH ENTERED FROM $C0C6
E297  8E E2 A2          ALINK28  LDX   #DISK20MS-1         ; POINT TO DISK BASIC 2.0 MESSAGE
E29A  7E C0 C9                   JMP   LC0C9               ; COPY MESSAGE TO SCREEN AND WARM START DISK BASIC 2.0
* PRINT THE DISK BASIC 2.1 COPYRIGHT MESSAGE PATCH ENTERED FROM $C0C6
E29D  8E E3 15          ALINK29  LDX   #LE313+2            ; POINT TO DISK BASIC 2.1 MESSAGE
E2A0  7E C0 DC                   JMP   LC0DC               ; COPY MESSAGE TO SCREEN AND WARM START DISK BASIC 2.1

E2A3  44 49 53 4B 20 45 DISK20MS FCC   'DISK EXTENDED COLOR BASIC 2.0'
E2A9  58 54 45 4E 44 45
E2AF  44 20 43 4F 4C 4F
E2B5  52 20 42 41 53 49
E2BB  43 20 32 2E 30
E2C0  0D                LE2C0    FCB   $0D
E2C1  43 4F 50 52 2E 20 LE2C1    FCC   'COPR. 1981, 1986 BY TANDY'
E2C7  31 39 38 31 2C 20
E2CD  31 39 38 36 20 42
E2D3  59 20 54 41 4E 44
E2D9  59
E2DA  0D                LE2DA    FCB   $0D
E2DB  55 4E 44 45 52 20 LE2DB    FCC   'UNDER LICENSE FROM MICROSOFT'
E2E1  4C 49 43 45 4E 53
E2E7  45 20 46 52 4F 4D
E2ED  20 4D 49 43 52 4F
E2F3  53 4F 46 54
E2F7  0D                LE2F7    FCB   $0D
E2F8  41 4E 44 20 4D 49 MWAREMS  FCC   'AND MICROWARE SYSTEMS CORP.'
E2FE  43 52 4F 57 41 52
E304  45 20 53 59 53 54
E30A  45 4D 53 20 43 4F
E310  52 50 2E
E313  0D 0D 00          LE313    FCB   $0D,$0D,$00
E316  44 49 53 4B 20 45 DISK21MS FCC   'DISK EXTENDED COLOR BASIC 2.1'
E31C  58 54 45 4E 44 45
E322  44 20 43 4F 4C 4F
E328  52 20 42 41 53 49
E32E  43 20 32 2E 31
E333  0D                LE333    FCB   $0D
E334  43 4F 50 52 2E 20 LE334    FCC   'COPR. 1981, 1986 BY TANDY'
E33A  31 39 38 32 2C 20
E340  31 39 38 36 20 42
E346  59 20 54 41 4E 44
E34C  59
E34D  0D                LE33D    FCB   $0D
E34E  55 4E 44 45 52 20 LE33E    FCC   'UNDER LICENSE FROM MICROSOFT'
E354  4C 49 43 45 4E 53
E35A  45 20 46 52 4F 4D
E360  20 4D 49 43 52 4F
E366  53 4F 46 54
E36A  0D                LE36A    FCB   $0D
E36B  41 4E 44 20 4D 49 LE36B    FCC   'AND MICROWARE SYSTEMS CORP.'
E371  43 52 4F 57 41 52
E377  45 20 53 59 53 54
E37D  45 4D 53 20 43 4F
E383  52 50 2E
E386  0D 0D 00          LE386    FCB   $0D,$0D,$00

* GRAPHICS INITIALIZATION PATCH ENTERED FROM $9703
E389  4F                ALINK14  CLRA
E38A  5F                         CLRB
E38B  10 21 1C 71                LBRN  RAMLINK             ; RAM HOOK
E38F  F7 FE 08                   STB   H.CRSATT            ; SET CURSOR ATTRIBUTES TO ZERO
E392  DD E6                      STD   HRMODE              ; SET HI-RES GRAPHICS AND TEXT MODES TO OFF
E394  FD FE 0C                   STD   H.ONBRK             ; RESET THE ON BRK ADDRESS TO ZERO; NON-INITIALIZED
E397  FD FE 0E                   STD   H.ONERR             ; RESET THE ON ERROR ADDRES TO ZERO; NON-INITIALIZED
E39A  B7 FE 0B                   STA   H.BCOLOR            ; PALETTE REGISTER ZERO IS THE DEFAULT BACKGROUND COLOR
E39D  86 01                      LDA   #$01                ; DEFAULT PALETTE REGISTER FOR THE FOREGROUND COLOR
E39F  B7 FE 0A                   STA   H.FCOLOR            ; USE PALETTE REGISTER1 AS THE FOREGROUND COLOR
E3A2  86 34                      LDA   #BLOCK6.4           ; GET THE HPUT/HGET BUFFER BLOCK
E3A4  B7 FF A0                   STA   MMUREG              ; PIT IT INTO LOGICAL BLOCK 0
E3A7  CC FF FF                   LDD   #$FFFF              ; HPUT/HGET BUFFER EMPTY FLAG
E3AA  DD 00                      STD   $0                  ; RESET THE HPUT/HGET BUFFER TO EMPTY
E3AC  86 38                      LDA   #BLOCK7.0
E3AE  B7 FF A0                   STA   MMUREG              ; RESTORE BLOCK 7.0 TO LOGICAL BLOCK 0 OF TASK REGISTER 0
E3B1  7E AD 19                   JMP   LAD19               ; GO DO A COMPLETE 'NEW'

* ON COMMAND (FOR ON ERR AND ON BRK) PATCH ENTERED FROM $AF42
E3B4  81 EF             ALINK18  CMPA  #$EF                ; 'ERR' TOKEN
E3B6  27 1C                      BEQ   ERR
E3B8  81 F0                      CMPA  #$F0                ; 'BRK' TOKEN
E3BA  27 2A                      BEQ   BRK
E3BC  BD B7 0B                   JSR   EVALEXPB            ; EVALUATE EXPRESSION, RETURN VALUE IN ACCB
E3BF  7E AF 45                   JMP   LAF45               ; JUMP TO THE ON COMMAND($AF45)
E3C2  9D 9F             LE3C2    JSR   GETNCH              ; GET THE NEXT CHARACTER FROM BASIC'S INPUT LINE
E3C4  81 81                      CMPA  #$81                ; 'GO' TOKEN
E3C6  26 07                      BNE   LE3CF               ; SYNTAX ERROR IF NOT GO
E3C8  9D 9F                      JSR   GETNCH              ; GET THE NEXT CHARACTER FROM BASIC'S INPUT LINE
E3CA  81 A5                      CMPA  #$A5                ; 'TO' TOKEN
E3CC  26 01                      BNE   LE3CF               ; SYNTAX ERROR IF NOT GOTO
E3CE  39                         RTS
E3CF  32 62             LE3CF    LEAS  $02,S               ; REMOVE ONE RETURN ADDRESS FROM THE STACK
E3D1  7E B2 77                   JMP   LB277               ; 'SYNTAX' ERROR

* ERR
E3D4  8D EC             ERR      BSR   LE3C2               ; CHECK FOR THE 'GO' AND 'TO' TOKENS
E3D6  9D 9F                      JSR   GETNCH              ; GET THE NEXT CHARACTER FROM BASIC'S INPUT LINE
E3D8  BD AF 67                   JSR   LAF67               ; STRIP THE 'GOTO' LINE NUMBER FROM THE BASIC INPUT LINE
E3DB  DC 2B                      LDD   BINVAL              ; GET THE 'GOTO' LINE NUMBER
E3DD  FD FE 0E                   STD   H.ONERR             ; SAVE IT
E3E0  DC 68                      LDD   CURLIN              ; GET THE CURRENT LINE NUMBER
E3E2  FD FE 11                   STD   H.ONERRS            ; AND SAVE IT AS THE SOURCE LINE NUMBER
E3E5  39                         RTS

* BRK
E3E6  8D DA             BRK      BSR   LE3C2               ; CHECK FOR THE 'GO' AND THE 'TO' TOKENS
E3E8  9D 9F                      JSR   GETNCH              ; GET THE NEXT CHARACTER FROM BASIC'S INPUT LINE
E3EA  BD AF 67                   JSR   LAF67               ; STRIP THE 'GOTO' LINE NUMBER FROM THE BASIC INPUT LINE
E3ED  DC 2B                      LDD   BINVAL              ; GET THE 'GOTO' LINE NUMBER
E3EF  FD FE 0C                   STD   H.ONBRK             ; SAVE IT
E3F2  DC 68                      LDD   CURLIN              ; GET THE CURRENT LINE NUMBER
E3F4  FD FE 15                   STD   H.ONBRKS            ; AND SAVE IT AS THE SOURCE LINE NUMBER
E3F7  39                         RTS

* &H TYPE VARIABLE EVALUATION PATCH ENTERED FROM $8834
E3F8  68 02             ALINK6A  LSL   $02,X               ; *
E3FA  69 01                      ROL   $01,X               ; * MULTIPLY THE TEMPORARY
E3FC  69 84                      ROL   ,X                  ; * ACCUMULATOR BY TWO
E3FE  10 25 D6 90                LBCS  LBA92               ; 'OV' OVERFLOW ERROR ($BA92)
E402  5A                         DECB                      ; DECREMENT THE SHIFT COUNTER
E403  26 F3                      BNE   ALINK6A             ; LOOP UNTIL DONE
E405  80 30                      SUBA  #'0'                ; MASK OFF ASCII
E407  AB 02                      ADDA  $02,X               ; * ADD DIGIT TO TEMPORARY
E409  A7 02                      STA   $02,X               ; * ACCUMULATOR AND SAVE IT
E40B  39                         RTS

* &H TYPE VARIABLE EVALUATION PATCH ENTERED FROM $8843
E40C  10 25 A3 F0       ALINK6B  LBCS  L8800               ; ($8800)
E410  7E 88 3F                   JMP   L883F               ; ($883F)

* BASIC'S LINE INPUT PATCH ENTERED FROM $A3C2
E413  81 03             ALINK16  CMPA  #$03                ; BREAK KEY DEPRESSED?
E415  1A 01                      ORCC  #$01                ; SET THE CARRY FLAG
E417  26 0D                      BNE   LE426               ; BRANCH IF NOT THE BREAK KEY
E419  34 03                      PSHS  A,CC                ; SAVE REGISTERS
E41B  96 E6                      LDA   HRMODE              ; CHECK THE HI-RES GRAPHICS MODE
E41D  27 05                      BEQ   LE424               ; BRANCH IF IN COCO COMPATIBLE MODE
E41F  0F E6                      CLR   HRMODE              ; FORCE TO COCO COMPATIBLE MODE
E421  BD E0 19                   JSR   SETTEXT             ; PROGRAM THE VIDEO MODE REGISTERS
E424  35 03             LE424    PULS  CC,A                ; RESTORE REGISTERS
E426  7E A3 C6          LE426    JMP   LA3C6               ; RE-ENTER THE MAIN STREAM OF CODE ($A3C6)

* BREAK CHECK PATCH ENTERED FROM $ADF0
E429  81 03             ALINK15  CMPA  #$03                ; BREAK KEY DEPRESSED?
E42B  27 03                      BEQ   LE430               ; YES
E42D  7E AD F4                   JMP   LADF4               ; RE-ENTER THE MAIN STREAM OF CODE ($ADF4)
E430  86 01             LE430    LDA   #$01                ; 'BREAK' FLAG
E432  B7 FE 17                   STA   H.ERRBRK            ; SAVE IN THE ERROR/BREAK FLAG
E435  96 68                      LDA   CURLIN              ; DIRECT MODE?
E437  4C                         INCA                      ; $FF SIGNIFIES DIRECT MODE
E438  27 05                      BEQ   LE43F               ; BRANCH IF DIRECT MODE
E43A  FC FE 0C                   LDD   H.ONBRK             ; HAS AN ON BRK TRAP BEEN SET UP?
E43D  26 0A                      BNE   LE449               ; YES
E43F  96 E6             LE43F    LDA   HRMODE              ; CHECK THE HI-RES GRAPHICS MODE
E441  27 03                      BEQ   LE446               ; BRANCH IF COCO COMPATIBLE
E443  BD E0 19                   JSR   SETTEXT             ; PROGRAM THE VIDEO DISPLAY REGISTERS
E446  7E AE 09          LE446    JMP   LAE09               ; JUMP TO THE STOP COMMAND ($AE09)
E449  DD 2B             LE449    STD   BINVAL              ; SAVE THE SEARCH LINE NUMBER
E44B  7D FE 17                   TST   H.ERRBRK            ; CHECK THE ERROR/BREAK FLAG
E44E  26 08                      BNE   LE458               ; BRANCH IF BREAK
E450  10 DE 21                   LDS   FRETOP              ; IF ERROR, RESET THE STACK POINTER
E453  CC AD C4                   LDD   #LADC4              ; * GET THE ADDRESS ($ADC4) OF THE MAIN COMMAND INTERPRETATION
E456  34 06                      PSHS  B,A                 ; * LOOP AND SAVE IT AS THE NEW RETURN ADDRESS
E458  BD AE EB          LE458    JSR   LAEEB               ; MOVE THE INPUT POINTER TO THE END OF THE LINE
E45B  30 01                      LEAX  $01,X               ; SKIP TO THE START OF THE NEXT LINE
E45D  DC 2B                      LDD   BINVAL              ; GET THE LINE NUMBER WE'RE LOOKING FOR
E45F  10 93 68                   CMPD  CURLIN              ; COMPARE TO THE CURRENT LINE NUMBER
E462  22 02                      BHI   LE466               ; BRANCH IF SEARCH LINE NUMBER GREATER THAN CURRENT LINE NUMBER
E464  9E 19                      LDX   TXTTAB              ; POINT X TO THE BEGINNING OF THE PROGRAM
E466  BD AD 05          LE466    JSR   LAD05               ; SEARCH FOR THE PROGRAM LINE NUMBER IN ACCD
E469  10 25 00 B1                LBCS  LE51E               ; BRANCH IF LINE NUMBER NOT FOUND
E46D  7E AE BB                   JMP   LAEBB               ; RESET BASIC'S INPUT POINTER AND RETURN ($AEBB)
