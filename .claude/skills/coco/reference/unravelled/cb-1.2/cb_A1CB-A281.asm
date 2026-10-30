; Color BASIC 1.2 -- $A1CB-$A281
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: KEYIN=$A1CB, CONTAB=$A26E

A1CB  34 54             KEYIN    PSHS  U,X,B               ; SAVE REGISTERS
A1CD  CE FF 00                   LDU   #PIA0               ; POINT U TO PIA0
A1D0  8E 01 52                   LDX   #KEYBUF             ; POINT X TO KEYBOARD MEMORY BUFFER
A1D3  4F                         CLRA                      ; * CLEAR CARRY FLAG, SET COLUMN COUNTER (ACCA)
A1D4  4A                         DECA                      ; * TO $FF
A1D5  34 12                      PSHS  X,A                 ; SAVE COLUMN CTR & 2 BLANK (X REG) ON STACK
A1D7  A7 42                      STA   2,U                 ; INITIALIZE COLUMN STROBE TO $FF
A1D9  69 42             LA1D9    ROL   2,U                 ; * ROTATE COLUMN STROBE DATA LEFT 1 BIT, CARRY
A1DB  24 43                      BCC   LA220               ; * INTO BIT 0 - BRANCH IF 8 SHIFTS DONE
A1DD  6C 60                      INC   ,S                  ; INCREMENT COLUMN COUNTER
A1DF  8D 59                      BSR   LA23A               ; READ KEYBOARD ROW DATA
A1E1  A7 61                      STA   1,S                 ; TEMP STORE KEY DATA
A1E3  A8 84                      EORA  ,X                  ; SET ANY BIT WHERE A KEY HAS MOVED
A1E5  A4 84                      ANDA  ,X                  ; ACCA=0 IF NO NEW KEY DOWN, <70 IF KEY WAS RELEASED
A1E7  E6 61                      LDB   1,S                 ; GET NEW KEY DATA
A1E9  E7 80                      STB   ,X+                 ; STORE IT IN KEY MEMORY
A1EB  4D                         TSTA                      ; WAS A NEW KEY DOWN?
A1EC  27 EB                      BEQ   LA1D9               ; NO-CHECK ANOTHER COLUMN
A1EE  E6 42                      LDB   2,U                 ; * GET COLUMN STROBE DATA AND
A1F0  E7 62                      STB   2,S                 ; * TEMP STORE IT ON THE STACK
* THIS ROUTINE CONVERTS THE KEY DEPRESSION INTO A NUMBER
* FROM 0-50 IN ACCB CORRESPONDING TO THE KEY THAT WAS DOWN
A1F2  C6 F8                      LDB   #$F8                ; TO MAKE SURE ACCB=0 AFTER FIRST ADDB #8
A1F4  CB 08             LA1F4    ADDB  #$08                ; ADD 8 FOR EACH ROW OF KEYBOARD
A1F6  44                         LSRA                      ; ACCA HAS THE ROW NUMBER OF THIS KEY - ADD 8 FOR EACH ROW
A1F7  24 FB                      BCC   LA1F4               ; GO ON UNTIL A ZERO APPEARS IN THE CARRY FLAG
A1F9  EB 60                      ADDB  ,S                  ; ADD IN THE COLUMN NUMBER
* NOW CONVERT THE VALUE IN ACCB INTO ASCII
A1FB  27 48                      BEQ   LA245               ; THE 'AT SIGN' KEY WAS DOWN
A1FD  C1 1A                      CMPB  #26                 ; WAS IT A LETTER?
A1FF  22 46                      BHI   LA247               ; NO
A201  CA 40                      ORB   #$40                ; YES, CONVERT TO UPPER CASE ASCII
A203  8D 29                      BSR   LA22E               ; CHECK FOR THE SHIFT KEY
A205  BA 01 1A                   ORA   CASFLG              ; * 'OR' IN THE CASE FLAG & BRANCH IF IN UPPER
A208  26 02                      BNE   LA20C               ; * CASE MODE OR SHIFT KEY DOWN
A20A  CA 20                      ORB   #$20                ; CONVERT TO LOWER CASE
A20C  E7 60             LA20C    STB   ,S                  ; TEMP STORE ASCII VALUE
A20E  BE 01 1B                   LDX   DEBVAL              ; GET KEYBOARD DEBOUNCE
A211  8D 9B                      BSR   LA1AE
A213  C6 FF                      LDB   #$FF                ; SET COLUMN STROBE TO ALL ONES (NO
A215  8D 21                      BSR   LA238               ; STROBE) AND READ KEYBOARD
A217  4C                         INCA                      ; = INCR ROW DATA, ACCA NOW 0 IF NO JOYSTICK
A218  26 06                      BNE   LA220               ; = BUTTON DOWN. BRANCH IF JOYSTICK BUTTON DOWN
A21A  E6 62             LA21A    LDB   2,S                 ; GET COLUMN STROBE DATA
A21C  8D 1A                      BSR   LA238               ; READ A KEY
A21E  A1 61                      CMPA  1,S                 ; IS IT THE SAME KEY AS BEFORE DEBOUNCE?
A220  35 12             LA220    PULS  A,X                 ; REMOVE TEMP SLOTS FROM THE STACK AND RECOVER
* THE ASCII VALUE OF THE KEY
A222  26 07                      BNE   LA22B               ; NOT THE SAME KEY OR JOYSTICK BUTTON
A224  81 12                      CMPA  #$12                ; IS SHIFT ZERO DOWN?
A226  26 04                      BNE   LA22C               ; NO
A228  73 01 1A                   COM   CASFLG              ; YES, TOGGLE UPPER CASE/LOWER CASE FLAG
A22B  4F                LA22B    CLRA                      ; SET ZERO FLAG TO INDICATE NO NEW KEY DOWN
A22C  35 D4             LA22C    PULS  B,X,U,PC            ; RESTORE REGISTERS

* TEST FOR THE SHIFT KEY
A22E  86 7F             LA22E    LDA   #$7F                ; COLUMN STROBE
A230  A7 42                      STA   2,U                 ; STORE TO PlA
A232  A6 C4                      LDA   ,U                  ; READ KEY DATA
A234  43                         COMA                      ; *
A235  84 40                      ANDA  #$40                ; * SET BIT 6 IF SHIFT KEY DOWN
A237  39                         RTS                       ; RETURN

* READ THE KEYBOARD
A238  E7 42             LA238    STB   2,U                 ; SAVE NEW COLUMN STROBE VALUE
A23A  A6 C4             LA23A    LDA   ,U                  ; READ PIA0, PORT A TO SEE IF KEY IS DOWN
* A BIT WILL BE ZERO IF ONE IS
A23C  8A 80                      ORA   #$80                ; MASK OFF THE JOYSTICK COMPARATOR INPUT
A23E  6D 42                      TST   $02,U               ; ARE WE STROBING COLUMN 7?
A240  2B 02                      BMI   LA244               ; NO
A242  8A C0                      ORA   #$C0                ; YES, FORCE ROW 6 TO BE HIGH - THIS WILL CAUSE
* THE SHIFT KEY TO BE IGNORED
A244  39                LA244    RTS                       ; RETURN

A245  C6 33             LA245    LDB   #51                 ; CODE FOR 'AT SIGN'
A247  8E A2 38          LA247    LDX   #CONTAB-$36         ; POINT X TO CONTROL CODE TABLE
A24A  C1 21                      CMPB  #33                 ; KEY NUMBER <33?
A24C  25 16                      BLO   LA264               ; YES (ARROW KEYS, SPACE BAR, ZERO)
A24E  8E A2 1A                   LDX   #CONTAB-$54         ; POINT X TO MIDDLE OF CONTROL TABLE
A251  C1 30                      CMPB  #48                 ; KEY NUMBER >48?
A253  24 0F                      BHS   LA264               ; YES (ENTER,CLEAR,BREAK,AT SIGN)
A255  8D D7                      BSR   LA22E               ; CHECK SHIFT KEY (ACCA WILL CONTAIN STATUS)
A257  C1 2B                      CMPB  #43                 ; IS KEY A NUMBER, COLON OR SEMICOLON?
A259  23 02                      BLS   LA25D               ; YES
A25B  88 40                      EORA  #$40                ; TOGGLE BIT 6 OF ACCA WHICH CONTAINS THE SHIFT DATA
* ONLY FOR SLASH,HYPHEN,PERIOD,COMMA
A25D  4D                LA25D    TSTA                      ; SHIFT KEY DOWN?
A25E  26 AC                      BNE   LA20C               ; YES
A260  CB 10                      ADDB  #$10                ; NO, ADD IN ASCII OFFSET CORRECTION
A262  20 A8                      BRA   LA20C               ; GO CHECK FOR DEBOUNCE
A264  58                LA264    ASLB                      ; MULT ACCB BY 2 - THERE ARE 2 ENTRIES IN CONTROL
* TABLE FOR EACH KEY - ONE SHIFTED, ONE NOT
A265  8D C7                      BSR   LA22E               ; CHECK SHIFT KEY
A267  27 01                      BEQ   LA26A               ; NOT DOWN
A269  5C                         INCB                      ; ADD ONE TO GET THE SHIFTED VALUE
A26A  E6 85             LA26A    LDB   B,X                 ; GET ASCII CODE FROM CONTROL TABLE
A26C  20 9E                      BRA   LA20C               ; GO CHECK DEBOUNCE
*
*
* CONTROL TABLE   UNSHIFTED, SHIFTED VALUES
A26E  5E 5F             CONTAB   FCB   $5E,$5F             ; UP ARROW
A270  0A 5B                      FCB   $0A,$5B             ; DOWN ARROW
A272  08 15                      FCB   $08,$15             ; RIGHT ARROW
A274  09 5D                      FCB   $09,$5D             ; LEFT ARROW
A276  20 20                      FCB   $20,$20             ; SPACE BAR
A278  30 12                      FCB   $30,$12             ; ZERO
A27A  0D 0D                      FCB   $0D,$0D             ; ENTER
A27C  0C 5C                      FCB   $0C,$5C             ; CLEAR
A27E  03 03                      FCB   $03,$03             ; BREAK
A280  40 13                      FCB   $40,$13             ; AT SIGN
