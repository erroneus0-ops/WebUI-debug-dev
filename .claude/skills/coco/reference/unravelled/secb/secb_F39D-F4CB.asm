; Super Extended Color BASIC 2.0 (CoCo 3) -- $F39D-$F4CB
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: HDRAW=$F39D

* HDRAW
F39D  0D E6             HDRAW    TST   HRMODE              ; CHECK HI-RES GRAPHICS MODE
F39F  10 27 F3 4C                LBEQ  LE6EF               ; 'HR' ERROR IF HI-RES MODE NOT ENABLED
F3A3  10 21 0C 59                LBRN  RAMLINK             ; RAM HOOK
F3A7  8E 00 00                   LDX   #0                  ; * X=0, ACCB=1; END OF DRAW COMMAND LINE VALUES
F3AA  C6 01                      LDB   #$01                ; * WHEN THESE VALUES ARE PULLED OFF THE STACK,
F3AC  34 14                      PSHS  X,B                 ; * THE DRAW COMMAND WILL END
F3AE  D7 C2                      STB   SETFLG              ; SET PSET/PRESET FLAG TO PSET
F3B0  9F D5                      STX   VD5                 ; CLEAR UPDATE AND DRAW FLAGS
F3B2  BD E7 31                   JSR   LE731               ; SET ACTIVE COLOR BYTE
F3B5  BD B1 56                   JSR   LB156               ; EVALUATE EXPRESSION
F3B8  BD B6 54          LF3B8    JSR   LB654               ; GET LENGTH AND ADDRESS OF COMMAND STRING
F3BB  20 08                      BRA   LF3C5               ; INTERPRET THE COMMAND STRING
F3BD  BD F5 91          LF3BD    JSR   LF591               ; GET THE NEXT CHARACTER FROM THE COMMAND LINE
F3C0  7E F5 A7                   JMP   LF5A7               ; EVALUATE A DECIMAL VALUE IN COMMAND LINE
F3C3  35 14             LF3C3    PULS  B,X                 ; GET NEXT COMMAND LINE TO BE INTERPRETED FROM THE STACK
F3C5  D7 D8             LF3C5    STB   VD8                 ; SET COMMAND LENGTH COUNTER
F3C7  27 FA                      BEQ   LF3C3               ; GET NEW COMMAND LINE IF ZERO
F3C9  9F D9                      STX   VD9                 ; SET COMMAND LINE ADDRESS
F3CB  10 27 01 01                LBEQ  LF4D0               ; EXIT ROUTINE IF ADDRESS = 0
F3CF  0D D8             LF3CF    TST   VD8                 ; TEST COMMAND LENGTH COUNTER
F3D1  27 F0                      BEQ   LF3C3               ; GET NEW LINE IF 0
F3D3  BD F5 91                   JSR   LF591               ; GET A COMMAND CHARACTER
F3D6  81 3B                      CMPA  #';'                ; CHECK FOR A SEMI-COLON
F3D8  27 F5                      BEQ   LF3CF               ; IGNORE SEMI-COLONS
F3DA  81 27                      CMPA  #'''                ; CHECK FOR APOSTROPHE
F3DC  27 F1                      BEQ   LF3CF               ; IGNORE APOSTROPHE
F3DE  81 4E                      CMPA  #'N'                ; UPDATE CHECK?
F3E0  26 04                      BNE   LF3E6               ; BRANCH IF NOT
F3E2  03 D5                      COM   VD5                 ; TOGGLE UPDATE FLAG; 0 = UPDATE, FF = NO UPDATE
F3E4  20 E9                      BRA   LF3CF               ; GET NEXT COMMAND
F3E6  81 42             LF3E6    CMPA  #'B'                ; CHECK DRAW FLAG?
F3E8  26 04                      BNE   LF3EE               ; BRANCH IF NOT
F3EA  03 D6                      COM   VD6                 ; TOGGLE DRAW FLAG; 0 = DRAW LINE, FF = DON'T DRAW LINE
F3EC  20 E1                      BRA   LF3CF               ; GET ENXT COMMAND
F3EE  81 58             LF3EE    CMPA  #'X'                ; SUBSTRING?
F3F0  10 27 00 AD                LBEQ  LF4A1               ; GO EXECUTE A COMMAND SUBSTRING
F3F4  81 4D                      CMPA  #'M'                ; MOVE THE DRAW POSITION?
F3F6  10 27 01 52                LBEQ  LF54C               ; BRANCH IF YES, GO MOVE IT
F3FA  34 02                      PSHS  A                   ; SAVE CURRENT COMMAND
F3FC  C6 01                      LDB   #$01                ; DEFAULT VALUE IF NO NUMBER FOLLOWS COMMAND
F3FE  0F D3                      CLR   VD3                 ; CLEAR MS BYTE OF SUBCOMMAND VALUE
F400  D7 D4                      STB   VD4                 ; SAVE LS BYTE OF SUBCOMMAND VALUE
F402  0D D8                      TST   VD8                 ; CHECK COMMAND LENGTH COUNTER
F404  27 11                      BEQ   LF417               ; BRANCH IF NO COMMANDS LEFT
F406  BD F5 91                   JSR   LF591               ; GET A COMMAND CHARACTER
F409  BD B3 A2                   JSR   LB3A2               ; SET CARRY IF NOT ALPHA
F40C  34 01                      PSHS  CC                  ; SAVE CARRY FLAG
F40E  BD F5 F2                   JSR   LF5F2               ; MOVE COMMAND POINTER BACK ONE
F411  35 01                      PULS  CC                  ; RESTORE CARRY FLAG
F413  24 02                      BCC   LF417               ; BRANCH IF NEXT COMMAND IS ALPHA
F415  8D A6                      BSR   LF3BD               ; EVALUATE DECIMAL COMMAND LINE VALUE - RETURN VALUE IN ACCD & VD3
F417  35 02             LF417    PULS  A                   ; GET CURRENT COMMAND BACK
F419  81 43                      CMPA  #'C'                ; CHANGE COLOR?
F41B  27 28                      BEQ   LF445               ; BRANCH IF YES
F41D  81 41                      CMPA  #'A'                ; CHANGE ANGLE?
F41F  27 30                      BEQ   LF451               ; BRANCH IF YES
F421  81 53                      CMPA  #'S'                ; CHANGE SCALE?
F423  27 37                      BEQ   LF45C               ; BRANCH IF YES
F425  81 55                      CMPA  #'U'                ; GO UP?
F427  27 6D                      BEQ   LF496               ; BRANCH IF YES
F429  81 44                      CMPA  #'D'                ; GO DOWN?
F42B  27 65                      BEQ   LF492               ; BRANCH IF YES
F42D  81 4C                      CMPA  #'L'                ; GO LEFT?
F42F  27 5B                      BEQ   LF48C               ; BRANCH IF YES
F431  81 52                      CMPA  #'R'                ; GO RIGHT?
F433  27 50                      BEQ   LF485               ; BRANCH IF YES
F435  80 45                      SUBA  #'E'                ; MASK OFF ASCII FOR LETTER E-H COMMAND CHECKS
F437  27 3A                      BEQ   LF473               ; BRANCH IF E (45 DEGREES)
F439  4A                         DECA                      ; CHECK FOR F
F43A  27 31                      BEQ   LF46D               ; BRANCH IF F (135 DEGREES)
F43C  4A                         DECA                      ; CHECK FOR G
F43D  27 3E                      BEQ   LF47D               ; BRANCH IF G (225 DEGREES)
F43F  4A                         DECA                      ; CHECK FOR H
F440  27 25                      BEQ   LF467               ; BRANCH IF H (315 DEGREES)
F442  7E B4 4A                   JMP   ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR IF ILLEGAL SUBCOMMAND

* CHANGE COLOR
F445  BD E7 11          LF445    JSR   LE711               ; ADJUST COLOR CODE FOR PROPER GRAPHICS MODE
F448  F7 FE 0A                   STB   H.FCOLOR            ; SAVE NEW FOREGROUND COLOR
F44B  BD E7 31                   JSR   LE731               ; SET UP COLOR BYTES
F44E  16 FF 7E                   LBRA  LF3CF               ; GO PROCESS ANOTHER COMMAND
* CHANGE ANGLE
F451  C1 04             LF451    CMPB  #$04                ; ONLY ANGLES 0-3 ARE LEGAL
F453  10 24 BF F3                LBCC  ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR
F457  D7 E8                      STB   ANGLE               ; SAVE DRAW ANGLE
F459  16 FF 73                   LBRA  LF3CF               ; GO PROCESS ANOTHER COMMAND
* CHANGE SCALE
F45C  C1 3F             LF45C    CMPB  #63                 ; ONLY 0-63 ARE LEGAL
F45E  10 24 BF E8                LBCC  ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR
F462  D7 E9                      STB   SCALE               ; SAVE DRAW SCALE
F464  16 FF 68                   LBRA  LF3CF               ; GO PROCESS ANOTHER COMMAND
* 315 DEGREES
F467  96 D3             LF467    LDA   VD3                 ; NOW ACCD = VALUE OF THE SUBCOMMAND
F469  8D 61                      BSR   NEGACCD             ; MAKE HORIZONTAL DIFFERENCE NEGATIVE
F46B  20 02                      BRA   LF46F               ; BRANCH AROUND NEXT INSTRUCTION
* 135 DEGREES
F46D  96 D3             LF46D    LDA   VD3                 ; NOW ACCD = VALUE OF THE SUBCOMMAND
F46F  1F 01             LF46F    TFR   D,X                 ; COPY HORIZONTAL DIFFERENCE TO VERTICAL DIFFERENCE
F471  20 61                      BRA   LF4D4               ; GO MOVE THE DRAW POSITION
* 45 DEGREES
F473  96 D3             LF473    LDA   VD3                 ; NOW ACCD = VALUE OF THE SUBCOMMAND
F475  1F 01                      TFR   D,X                 ; COPY HORIZONTAL DIFFERENCE TO VERTICAL DIFFERENCE
F477  8D 53                      BSR   NEGACCD             ; MAKE HORIZONTAL DIFFERENCE NEGATIVE
F479  1E 01                      EXG   D,X                 ; SWAP HOR AND VER DIFFERENCES
F47B  20 57                      BRA   LF4D4               ; GO MOVE THE DRAW POSITION
* 225 DEGREES
F47D  96 D3             LF47D    LDA   VD3                 ; NOW ACCD = VALUE OF THE SUBCOMMAND
F47F  1F 01                      TFR   D,X                 ; COPY HORIZONTAL DIFFERENCE TO VERTICAL DIFFERENCE
F481  8D 49                      BSR   NEGACCD             ; MAKE HORIZONTAL DIFFERENCE NEGATIVE
F483  20 4F                      BRA   LF4D4               ; GO MOVE THE DRAW POSITION
* GO RIGHT
F485  96 D3             LF485    LDA   VD3                 ; NOW ACCD = VALUE OF THE SUBCOMMAND
F487  8E 00 00          LF487    LDX   #0                  ; X=0; VERT DIFFERENCE = 0
F48A  20 48                      BRA   LF4D4               ; GO MOVE THE DRAW POSITION
* GO LEFT
F48C  96 D3             LF48C    LDA   VD3                 ; NOW ACCD = VALUE OF THE SUBCOMMAND
F48E  8D 3C                      BSR   NEGACCD             ; MAKE HORIZONTAL DIFFERENCE NEGATIVE
F490  20 F5                      BRA   LF487               ; MAKE VERTICAL DIFFERENCE ZERO AND MOVE THE DRAW POSITION
* GO DOWN
F492  96 D3             LF492    LDA   VD3                 ; NOW ACCD = VALUE OF THE SUBCOMMAND
F494  20 04                      BRA   LF49A               ; MAKE VER DIFF=0, EXCHANGE HOR & VER DIFFS AND MOVE DRAW POSITION
* GO UP
F496  96 D3             LF496    LDA   VD3                 ; NOW ACCD = VALUE OF THE SUBCOMMAND
F498  8D 32                      BSR   NEGACCD             ; MAKE HORIZONTAL DIFFERENCE NEGATIVE
F49A  8E 00 00          LF49A    LDX   #0                  ; X=0; HORIZONTAL DIFFERENCE = 0
F49D  1E 10                      EXG   X,D                 ; SWAP HOR AND VER DIFFERENCES
F49F  20 33                      BRA   LF4D4               ; GO MOVE THE DRAW POSITION
* EXECUTE A COMMAND SUB STRING
F4A1  BD F6 11          LF4A1    JSR   LF611               ; INTERPRET CURRENT COMMAND AS IF IT WERE A BASIC VARIABLE
F4A4  C6 02                      LDB   #$02                ; =
F4A6  BD AC 33                   JSR   LAC33               ; = SEE IF AT LEAST FOUR BYTES OF FREE RAM ARE LEFT
F4A9  D6 D8                      LDB   VD8                 ; GET CURRENT COMMAND LENGTH
F4AB  9E D9                      LDX   VD9                 ; GET CURRENT COMMAND COUNTER
F4AD  34 14                      PSHS  X,B                 ; SAVE THEM ON THE STACK
F4AF  7E F3 B8                   JMP   LF3B8               ; EVALUATE NUMERICAL VALUE IN COMMAND LINE
* MULTIPLY HOR OR VER DIFFERENCE BY SCALE FACTOR, DIVIDE PRODUCT BY 4 AND RETURN VALUE IN ACCD
F4B2  D6 E9             LF4B2    LDB   SCALE               ; GET DRAW SCALE
F4B4  27 1B                      BEQ   LF4D1               ; BRANCH IF ZERO (DEFAULT TO FULL SCALE)
F4B6  4F                         CLRA                      ; CLEAR THE MS BYTE
F4B7  1E 01                      EXG   D,X                 ; SWAP DIFFERENCE AND SCALE FACTOR
F4B9  A7 E2                      STA   ,-S                 ; SAVE MS BYTE OF DIFFERENCE ON STACK (SIGN INFORMATION)
F4BB  2A 02                      BPL   LF4BF               ; BRANCH IF POSITIVE DIFFERENCE
F4BD  8D 0D                      BSR   NEGACCD             ; FORCE THE DIFFERENCE TO BE A POSITIVE VALUE
F4BF  BD EB CB          LF4BF    JSR   LEBCB               ; MULT DIFFERENCE BY SCALE FACTOR
F4C2  1F 30                      TFR   U,D                 ; SAVE 2 MS BYTES IN ACCD
F4C4  44                         LSRA
F4C5  56                         RORB                      ; DIVIDE ACCD BY 2
F4C6  44                         LSRA
F4C7  56                         RORB                      ; DO IT AGAIN, EACH SCALE INCREMENT IS 1/4 FULL SCALE
F4C8  6D E0                      TST   ,S+                 ; CHECK SIGN OF ORIGINAL DIFFERENCE
F4CA  2A 04                      BPL   LF4D0               ; RETURN IF IT WAS POSITIVE
