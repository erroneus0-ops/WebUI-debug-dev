; Super Extended Color BASIC 2.0 (CoCo 3) -- $E04D-$E235
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: SETGRAPH=$E04D, RESTABLE=$E06C, IM.GRAPH=$E070, SETVIDEO=$E082, SETMMU=$E097, SELBLOK0=$E0A1, SELTEXT=$E0B5, IM.MMU=$E0E1, SELTASK0=$E0FF, SELTASK1=$E119, ALINK2=$E138, EBCOMTAB=$E162, ALINK3=$E172, ALINK4=$E192, ALINK5=$E1A6, COMDIC20=$E1C5

E04D  34 32             SETGRAPH PSHS  Y,X,A
E04F  10 21 1F AD                LBRN  RAMLINK             ; RAM HOOK
E053  8E E0 70                   LDX   #IM.GRAPH           ; POINT TO THE VIDEO MODE RAM IMAGE FOR HSCREEN MODES 1,2
E056  10 8E E0 6C                LDY   #RESTABLE           ; POINT TO THE VIDEO RESOLUTION TABLE
E05A  96 E6                      LDA   HRMODE              ; GET THE HI-RES GRAPHICS MODE
E05C  81 02                      CMPA  #$02                ; 1 OR 2 ARE 40 COLUMN MODES
E05E  23 03                      BLS   LE063               ; BRANCH IF 40 COLUMN TEXT MODE
E060  8E E0 79                   LDX   #LE079              ; POINT TO THE VIDEO RAM IMAGE FOR 80 COLUMN MODE
E063  80 01             LE063    SUBA  #$01                ; ADJUST MODE NUMBERS TO START AT ZERO
E065  A6 A6                      LDA   A,Y                 ; GRAB THE PROPER VIDEO RESOLUTION MODE
E067  A7 02                      STA   $02,X               ; SAVE IT IN THE PROPER IMAGE
E069  7E E0 82                   JMP   SETVIDEO            ; GO SET UP THE VIDEO REGISTERS

* VIDEO RESOLUTION MODE REGISTER (FF99) DATA FOR HSCREEN MODES
E06C  15                RESTABLE FCB   $15                 ; 320 PIXELS, 4 COLORS
E06D  1E                LE06D    FCB   $1E                 ; 320 PIXELS, 16 COLORS
E06E  14                LE06E    FCB   $14                 ; 640 PIXELS, 2 COLORS
E06F  1D                LE06F    FCB   $1D                 ; 640 PIXELS, 4 COLORS

* VIDEO MODE REGISTER IMAGES FOR THE HI-RES GRAPHICS MODES
* VIDEO MODE REGISTER IMAGE FOR THE 320x192 GRAPHICS MODE
E070  4C                IM.GRAPH FCB   MMUEN+MC3+MC2       ; FF90
E071  80 00 00 00 00 C0 LE071    FCB   $80,$00,$00,$00,$00,$C0 ; FF98
E077  00 00                      FCB   $00,$00
* VIDEO MODE REGISTER IMAGE FOR THE 640x192 GRAPHICS MODE
E079  4C                LE079    FCB   MMUEN+MC3+MC2       ; FF90
E07A  80 00 00 00 00 C0 LE07A    FCB   $80,$00,$00,$00,$00,$C0 ; FF98
E080  00 00                      FCB   $00,$00

* PROGRAM INIT0 AND THE 8 VIDEO MODE REGISTERS
* ENTER WITH X POINTING TO THE DATA TO PUT INTO THE REGISTERS
E082  A6 80             SETVIDEO LDA   ,X+                 ; GET THE FIRST BYTE
E084  B7 FF 90                   STA   INIT0               ; AND PUT IT INTO INIT0
E087  10 8E FF 98                LDY   #VIDEOREG           ; POINT TO THE VIDEO MODE REGISTERS
E08B  A6 80             LE08B    LDA   ,X+                 ; GET A BYTE
E08D  A7 A0                      STA   ,Y+                 ; AND STICK IT INTO THE VIDEO MODE REGISTER
E08F  10 8C FF A0                CMPY  #MMUREG             ; END OF THE VIDEO MODE REGISTERS?
E093  25 F6                      BCS   LE08B               ; NO - KEEP STUFFING REGISTERS
E095  35 B2                      PULS  A,X,Y,PC

* PROGRAM THE MMU REGISTERS; ENTER WITH X POINTING TO THE DATA TO PLACE INTO THE MMU REGISTERS
E097  34 36             SETMMU   PSHS  Y,X,B,A
E099  30 8D 00 44                LEAX  IM.MMU,PC           ; POINT TO THE RAM IMAGE OF THE MMU REGISTERS
E09D  8D 52                      BSR   LE0F1               ; MOVE 16 BYTES INTO THE MMU REGISTERS
E09F  35 B6                      PULS  A,B,X,Y,PC

* PLACE A BLOCK INTO LOGICAL ADDRESS SPACE BLOCK 0.
* ENTER WITH ACCB CONTAINING THE BLOCK NUMBER TO BE PLACED INTO THE LOGICAL ADDRESS SPACE
* EXIT WITH BLOCK 7.0 REPLACED IN BLOCK 0 OF THE LOGICAL ADDRESS SPACE RAM IMAGE
E0A1  34 36             SELBLOK0 PSHS  Y,X,B,A
E0A3  30 8D 00 3A                LEAX  IM.MMU,PC           ; POINT TO THE RAM IMAGE OF THE MMU REGISTERS
E0A7  34 10                      PSHS  X                   ; TEMP SAVE
E0A9  E7 84                      STB   ,X                  ; SAVE THE NEW BLOCK NUMBER IN LOGICAL ADDRESS SPACE BLOCK 0 (TR0)
E0AB  8D 44                      BSR   LE0F1               ; COPY THE RAM IMAGE OF THE MMU REGISTERS INTO THE MMU REGISTERS
E0AD  C6 38                      LDB   #BLOCK7.0           ; GET BLOCK 7.0
E0AF  35 10                      PULS  X                   ; RESTORE THE MMU IMAGE POINTER
E0B1  E7 84                      STB   ,X                  ; RESTORE BLOCK 7.0 TO BLOCK 0 OF MMU RAM IMAGE
E0B3  35 B6                      PULS  A,B,X,Y,PC

* PLACE THE HI-RES TEXT SCREEN INTO LOGICAL ADDRESS SPACE BLOCK 1
* EXIT WITH BLOCK 7.1 REPLACED INTO BLOCK 1 OF THE LOGICAL ADDRESS SPACE RAM IMAGE
E0B5  34 36             SELTEXT  PSHS  Y,X,B,A
E0B7  30 8D 00 26                LEAX  IM.MMU,PC           ; POINT TO THE RAM IMAGE OF THE MMU REGISTERS
E0BB  34 10                      PSHS  X                   ; TEMP SAVE
E0BD  C6 36                      LDB   #BLOCK6.6           ; GET THE BLOCK WHICH CONTAINS THE HI-RES TEXT SCREEN
E0BF  E7 01                      STB   $01,X               ; AND SAVE IT IN THE MMU IMAGE OF TASK REGISTER 0
E0C1  8D 2E                      BSR   LE0F1               ; COPY THE RAM IMAGE OF THE MMU REGISTERS INTO THE MMU REGISTERS
E0C3  35 10                      PULS  X                   ; RESTORE THE MMU IMAGE PONTER
E0C5  C6 39                      LDB   #BLOCK7.1           ; GET BLOCK 7.1 (BASIC'S NORMAL LOGICAL BLOCK 1)
E0C7  E7 01                      STB   $01,X               ; AND SAVE IT IN THE MMU IMAGE
E0C9  35 B6                      PULS  A,B,X,Y,PC

E0CB  34 36             LE0CB    PSHS  Y,X,B,A
E0CD  30 8D 00 10                LEAX  IM.MMU,PC           ; POINT TO THE MMU RAM IMAGE
E0D1  34 10                      PSHS  X                   ; TEMP SAVE
E0D3  C6 34                      LDB   #BLOCK6.4           ; GET BLOCK 6.4
E0D5  E7 0E                      STB   14,X                ; AND SAVE IT IN LOGICAL BLOCK 6 OF TASK REGISTER 1
E0D7  8D 18                      BSR   LE0F1               ; COPY THE RAM IMAGE OF THE MMU REGISTERS INTO THE MMU REGISTERS
E0D9  35 10                      PULS  X                   ; RESTORE MMU IMAGE POINTER
E0DB  C6 35                      LDB   #BLOCK6.5           ; GET THE 'NORMAL' BLOCK FOR TASK REGISTER 1, LOGICAL BLOCK 6
E0DD  E7 0E                      STB   14,X                ; PUT IT BACK INTO TASK REGISTER 1 IMAGE
E0DF  35 B6                      PULS  A,B,X,Y,PC

* MASTER IMAGES USED TO PROGRAM THE CUSTOM CHIP'S MMU REGISTERS
* TASK REGISTER 0
E0E1  38 39 3A 3B 3C 3D IM.MMU   FCB   BLOCK7.0,BLOCK7.1,BLOCK7.2 ; DEFAULT VALUES
E0E7  3E 3F                            BLOCK7.3,BLOCK7.4,BLOCK7.5
                                       BLOCK7.6,BLOCK7.7
* TASK REGISTER 1
E0E9  38 30 31 32 33 3D LE0E9    FCB   BLOCK7.0,BLOCK6.0,BLOCK6.1 ; DEFAULT VALUES
E0EF  35 3F                            BLOCK6.2,BLOCK6.3,BLOCK7.5
                                       BLOCK6.5,BLOCK7.7

* COPY 16 BYTES INTO THE MMU REGISTERS
* ENTER WITH X POINTING TO THE 16 BYTES
E0F1  10 8E FF A0       LE0F1    LDY   #MMUREG             ; POINT TO THE MMU REGISTERS
E0F5  C6 10                      LDB   #16                 ; 16 MMU REGISTERS
E0F7  A6 80             LE0F7    LDA   ,X+                 ; GET A BYTE
E0F9  A7 A0                      STA   ,Y+                 ; AND PUT IT INTO THE MMU REGISTER
E0FB  5A                         DECB                      ; DECREMENT THE BYTE COUNT
E0FC  26 F9                      BNE   LE0F7               ; KEEP GOING UNTIL ALL REGISTERS MOVED
E0FE  39                         RTS

* SELECT TASK REGISTER 0 AS THE ACTIVE TASK REGISTER
* ENTER WITH THE STACK POINTING TO A TEMPORARY LOCATION; THE PERMANENT
* STACK POINTER WAS SAVED ON THIS TEMPORARY STACK WHEN TASK REGISTER 1
* WAS SELECTED AS THE ACTIVE TASK REGISTER

E0FF  DD 40             SELTASK0 STD   V40                 ; TEMPORARILY SAVE ACCD
E101  EC E4                      LDD   ,S                  ; GET THE RETURN ADDRESS OFF THE STACK
E103  DD 42                      STD   V42                 ; AND TEMPORARILY SAVE IT IN V42
E105  EC 62                      LDD   $02,S               ; GET THE PERMANENT STACK POINTER FROM THE STACK
E107  DD 44                      STD   V44                 ; AND TEMPORARILY SAVE IT IN V44
E109  5F                         CLRB                      ; TASK REGISTER 0 AND TIMER INPUT OF 63.5 MICROSECONDS
E10A  F7 FF 91                   STB   INIT1               ; PROGRAM INITIALIZATION REGISTER 1
E10D  10 DE 44                   LDS   V44                 ; RESET THE STACK POINTER
E110  DC 42                      LDD   V42                 ; GET BACK THE RETURN ADDRESS
E112  34 06                      PSHS  B,A                 ; AND PUT IT ONTO THE STACK
E114  DC 40                      LDD   V40                 ; RESTORE ACCD
E116  1C AF                      ANDCC #$AF                ; TURN ON IRQ, FIRQ
E118  39                         RTS

* SELECT TASK REGISTER 1 AS THE ACTIVE TASK REGISTER
* EXIT WITH THE STACK POINTER SET TO A TEMPORARY LOCATION
E119  1A 50             SELTASK1 ORCC  #$50                ; DISABLE INTERRUPTS
E11B  DD 40                      STD   V40                 ; TEMPORARILY SAVE ACCD IN V40
E11D  35 06                      PULS  A,B                 ; GET THE RETURN ADDRESS
E11F  DD 42                      STD   V42                 ; AND TEMPORARILY SAVE IT IN V42
E121  10 DF 44                   STS   V44                 ; TEMPORARILY SAVE THE STACK POINTER IN V44
E124  C6 01                      LDB   #$01                ; TASK REGISTER 1 AND TIMER INPUT AT 63.5 MICROSECONDS
E126  F7 FF 91                   STB   INIT1               ; SETUP INITIALIZATION REGISTER 1
E129  10 CE DF FF                LDS   #TMPSTACK           ; PUT THE STACK JUST BELOW THE START OF ENHANCED BASIC
E12D  DC 44                      LDD   V44                 ; GET THE OLD STACK POINTER BACK
E12F  34 06                      PSHS  B,A                 ; AND STUFF IT ONTO THE STACK
E131  DC 42                      LDD   V42                 ; GET THE RETURN ADDRESS BACK
E133  34 06                      PSHS  B,A                 ; AND STUFF IT ONTO THE STACK TOO
E135  DC 40                      LDD   V40                 ; GET BACK ACCD
E137  39                         RTS

* CRUNCH A TOKEN PATCH ENTERED FROM $B8D4
E138  0D 41             ALINK2   TST   V41                 ; CHECK THE TOKEN FLAG
E13A  26 16                      BNE   LE152               ; BRANCH IF IT IS A FUNCTION TOKEN
E13C  96 42                      LDA   V42                 ; GET THE TOKEN COUNTER
E13E  81 62                      CMPA  #$62                ; COMPARE TO THE FIRST ENHANCED BASIC TOKEN
E140  23 06                      BLS   LE148               ; BRANCH IF BEFORE FIRST TOKEN
E142  CE 01 1B                   LDU   #COMVEC-5           ; POINT U TO EXTENDED COLOR BASIC'S INTERPRETATION TABLE
E145  7E B8 D7                   JMP   LB8D7               ; RE-ENTER THE MAIN STREAM CODE
E148  86 62             LE148    LDA   #$62                ; FORCE THE TOKEN COUNTER TO THE FIRST ENHANCED BASIC TOKEN NUMBER
E14A  CE E1 58                   LDU   LE158               ; POINT TO ENHANCED BASIC'S COMMAND INTERPRETATION TABLE
E14D  97 42             LE14D    STA   V42                 ; SAVE THE NEW TOKEN COUNTER
E14F  7E B8 9D                   JMP   LB89D               ; RE-ENTER THE MAIN STREAM CODE
E152  96 42             LE152    LDA   V42                 ; GET THE TOKEN COUNTER
E154  81 29                      CMPA  #$29                ; COMPARE TO THE FIRST ENHANCED FUNCTION TOKEN NUMBER
E156  23 03                      BLS   LE15B               ; BRANCH IF LESS THAN ENHANCED TOKEN NUMBER
E158  7E B8 D7          LE158    JMP   LB9D7               ; RE-ENTER THE MAIN STREAM CODE
E15B  86 29             LE15B    LDA   #$29                ; FORCE COUNTER TO FIRST ENHANCED FUNCTION
E15D  CE E1 5D          LE15D    LDU   #LE15D              ; POINT TO THE ENHANCED FUNCTION INTERPRETATION TABLE
E160  20 EB                      BRA   LE14D

* BASIC 2.0 COMMAND INTERPRETATION VECTOR TABLE
E162  17                EBCOMTAB FCB   23                  ; 23 BASIC 2.0 COMMANDS
E163  E1 C5             LE163    FDB   COMDIC20            ; BASIC 2.0'S COMMAND DICTIONARY
E165  E1 92             LE165    FDB   ALINK4              ; COMMAND PROCESSING ROUTINE ENTRY POINT
E167  05                LE167    FCB   5                   ; 5 BASIC 2.0 FUNCTIONS
E168  E2 64             LE168    FDB   FUNDIC20            ; FUNCTION DICTIONARY TABLE
E16A  E1 A6             LE16A    FDB   ALINK5              ; FUNCTION PROCESSING ROUTINE ENTRY POINT
E16C  00 00 00 00 00 00 LE16C    FCB   $00,$00,$00,$00,$00,$00 ; DUMMY SPACE USED TO SIMULATE AN EMPTY COMMAND INTERP. VECTOR TABLE

* UNCRUNCH A TOKEN PATCH ENTERED FROM $B7F3
E172  33 4A             ALINK3   LEAU  10,U                ; SKIP TO THE NEXT COMMAND INTERPRETATION TABLE
E174  6D C4                      TST   ,U                  ; IS THIS A VALID TABLE?
E176  10 26 D6 7F                LBNE  LD67F               ; YES - RE-ENTER THE MAIN STREAM CODE
E17A  30 1F                      LEAX  $-01,X              ; UNNECESSARY INSTRUCTION; NEXT ONE SHOULD JUST BE LDA -1,X
E17C  A6 80                      LDA   ,X+                 ; GET THE TOKEN FROM BASIC'S INPUT LINE
E17E  84 7F                      ANDA  #$7F                ; STRIP OFF THE $80 COMMAND TOKEN BIAS
E180  81 62                      CMPA  #$62                ; FIRST LEGAL BASIC 2.0 COMMAND TOKEN NUMBER
E182  25 07                      BCS   LE18B               ; BRANCH IF LEGAL TOKEN
E184  80 62                      SUBA  #$62                ; ADJUST BASIC 2.0 TOKENS TO START AT 0
E186  CE E1 58                   LDU   #LE158              ; POINT TO ENHANCED BASIC'S COMMAND INTERPRETATION TABLE
E189  20 E7                      BRA   ALINK3
E18B  80 29             LE18B    SUBA  #$29                ; SUBTRACT OUT THE FIRST ENHANCED FUNCTION TABLE
E18D  CE E1 5D                   LDU   #LE15D              ; POINT U TO BE ABLE TO SEARCH FOR AN ENHANCED FUNCTION TOKEN
E190  20 E0                      BRA   ALINK3

* BASIC 2.0 COMMAND PROCESSING ROUTINE ENTRY POINT PATCH ENTERED FROM $8150
E192  81 E2             ALINK4   CMPA  #$E2                ; TOKEN NUMBER OF FIRST ENHANCED BASIC COMMAND
E194  25 04                      BCS   LE19A               ; BRANCH IF LESS THAN ENHANCED TOKEN
E196  81 F8                      CMPA  #$F8                ; COMPARE TO THE HIGHEST ENHANCED BASIC TOKEN
E198  23 04                      BLS   LE19E               ; BRANCH IF ENHANCED BASIC TOKEN
E19A  6E 9F 01 37       LE19A    JMP   [COMVEC+23]         ; GO TO DISK BASIC'S COMMAND HANDLER
E19E  80 E2             LE19E    SUBA  #$E2                ; SUBTRACT OUT THE NON-ENHANCED BASIC TOKENS
E1A0  8E E2 36                   LDX   #COMDIS20           ; POINT X TO ENHANCED BASIC'S COMMAND DISPATCH TABLE
E1A3  7E AD D4                   JMP   LADD4               ; RE-ENTER THE MAIN STREAM CODE

* BASIC 2.0 FUNCTION PROCESSING ROUTINE PATCH ENTERED FROM $816C
E1A6  C1 52             ALINK5   CMPB  #$52                ; COMPARE TO THE FIRST ENHANCED BASIC FUNCTION TOKEN
E1A8  25 04                      BCS   LE1AE               ; BRANCH IF LESS THAN ENHANCED TOKEN
E1AA  C1 5A                      CMPB  #$5A                ; COMPARE TO THE HIGHEST FUNCTION TOKEN
E1AC  23 04                      BLS   LE1B2               ; BRANCH IF ENHANCED TOKEN
E1AE  6E 9F 01 3C       LE1AE    JMP   [COMVEC+28]         ; JUMP TO DISK BASIC'S FUNCTION HANDLER
E1B2  C0 52             LE1B2    SUBB  #$52                ; SUBTRACT OUT THE NON-ENHANCED BASIC TOKENS
E1B4  C1 04                      CMPB  #2*2                ; CHECK FOR LPEEK, BUTTON, HPOINT
E1B6  24 07                      BCC   LE1BF               ; BRANCH IF ERNO, ERLIN
E1B8  34 04                      PSHS  B                   ; SAVE THE TOKEN COUNTER
E1BA  BD B2 62                   JSR   LB262               ; EVALUATE AN EXPRESSION IN PARENTHESIS
E1BD  35 04                      PULS  B                   ; RESTORE THE TOKEN COUNTER
E1BF  8E E2 7E          LE1BF    LDX   #FUNDIS20           ; POINT TO ENHANCED BASIC'S FUNCTION DISPATCH TABLE
E1C2  7E B2 CE                   JMP   LB2CE               ; RE-ENTER THE MAIN STREAM CODE
*
* BASIC 2.0 COMMAND DICTIONARY TABLE
*
* TOKEN #
E1C5  57 49 44 54 C8    COMDIC20 FCC   'WIDT',$80+'H'      ; E2
E1CA  50 41 4C 45 54 54 LE1CA    FCC   'PALETT',$80+'E'    ; E3
E1D0  C5
E1D1  48 53 43 52 45 45 LE1D1    FCC   'HSCREE',$80+'N'    ; E4
E1D7  CE
E1D8  4C 50 4F 4B C5    LE1D8    FCC   'LPOK',$80+'E'      ; E5
E1DD  48 43 4C D3       LE1DD    FCC   'HCL',$80+'S'       ; E6
E1E1  48 43 4F 4C 4F D2 LE1E1    FCC   'HCOLO',$80+'R'     ; E7
E1E7  48 50 41 49 4E D4 LE1E7    FCC   'HPAIN',$80+'T'     ; E8
E1ED  48 43 49 52 43 4C LE1ED    FCC   'HCIRCL',$80+'E'    ; E9
E1F3  C5
E1F4  48 4C 49 4E C5    LE1F4    FCC   'HLIN',$80+'E'      ; EA
E1F9  48 47 45 D4       LE1F9    FCC   'HGE',$80+'T'       ; EB
E1FD  48 50 55 D4       LE1FD    FCC   'HPU',$80+'T'       ; EC
E201  48 42 55 46 C6    LE201    FCC   'HBUF',$80+'F'      ; ED
E206  48 50 52 49 4E D4 LE206    FCC   'HPRIN',$80+'T'     ; EE
E20C  45 52 D2          LE20C    FCC   'ER',$80+'R'        ; EF
E20F  42 52 CB          LE20F    FCC   'BR',$80+'K'        ; F0
E212  4C 4F 43 41 54 C5 LE212    FCC   'LOCAT',$80+'E'     ; F1
E218  48 53 54 41 D4    LE218    FCC   'HSTA',$80+'T'      ; F2
E21D  48 53 45 D4       LE21D    FCC   'HSE',$80+'T'       ; F3
E221  48 52 45 53 45 D4 LE221    FCC   'HRESE',$80+'T'     ; F4
E227  48 44 52 41 D7    LE227    FCC   'HDRA',$80+'W'      ; F5
E22C  43 4D D0          LE22C    FCC   'CM',$80+'P'        ; F6
E22F  52 47 C2          LE22F    FCC   'RG',$80+'B'        ; F7
E232  41 54 54 D2       LE232    FCC   'ATT',$80+'R'       ; F8
