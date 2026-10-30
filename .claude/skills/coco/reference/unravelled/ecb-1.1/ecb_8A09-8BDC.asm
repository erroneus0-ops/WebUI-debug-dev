; Extended Color BASIC 1.1 -- $8A09-$8BDC
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: RENUM=$8A09

* RENUM
8A09  BD AD 26          RENUM    JSR   LAD26               ; ERASE VARIABLES
8A0C  CC 00 0A                   LDD   #10                 ; DEFAULT LINE NUMBER INTERVAL
8A0F  DD D5                      STD   VD5                 ; SAVE DEFAULT RENUMBER START LINE NUMBER
8A11  DD CF                      STD   VCF                 ; SAVE DEFAULT INTERVAL
8A13  5F                         CLRB                      ; NOW ACCD = 0
8A14  DD D1                      STD   VD1                 ; DEFAULT LINE NUMBER OF WHERE TO START RENUMBERING
8A16  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
8A18  24 06                      BCC   L8A20               ; BRANCH IF NOT NUMERIC
8A1A  8D E0                      BSR   L89FC               ; CONVERT DECIMAL NUMBER IN BASIC PROGRAM TO BINARY
8A1C  9F D5                      STX   VD5                 ; SAVE LINE NUMBER WHERE RENUMBERING STARTS
8A1E  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
8A20  27 1B             L8A20    BEQ   L8A3D               ; BRANCH IF END OF LINE
8A22  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
8A25  24 06                      BCC   L8A2D               ; BRANCH IF NEXT CHARACTER NOT NUMERIC
8A27  8D D3                      BSR   L89FC               ; CONVERT DECIMAL NUMBER IN BASIC PROGRAM TO BINARY
8A29  9F D1                      STX   VD1                 ; SAVE NEW RENUMBER LINE
8A2B  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
8A2D  27 0E             L8A2D    BEQ   L8A3D               ; BRANCH IF END OF LINE
8A2F  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
8A32  24 06                      BCC   L8A3A               ; BRANCH IF NEXT CHARACTER NOT NUMERIC
8A34  8D C6                      BSR   L89FC               ; CONVERT DECIMAL NUMBER IN BASIC PROGRAM TO BINARY
8A36  9F CF                      STX   VCF                 ; SAVE NEW INTERVAL
8A38  27 49                      BEQ   L8A83               ; 'FC' ERROR
8A3A  BD A5 C7          L8A3A    JSR   LA5C7               ; CHECK FOR MORE CHARACTERS ON LINE - 'SYNTAX' ERROR IF ANY
8A3D  8D C3             L8A3D    BSR   L8A02               ; GO GET ADDRESS OF OLD NUMBER BEING RENUMBERED
8A3F  9F D3                      STX   VD3                 ; SAVE ADDRESS
8A41  9E D5                      LDX   VD5                 ; GET NEXT RENUMBERED LINE NUMBER TO USE
8A43  8D BF                      BSR   L8A04               ; FIND THE LINE NUMBER IN THE BASIC PROGRAM
8A45  9C D3                      CMPX  VD3                 ; COMPARE TO ADDRESS OF OLD LINE NUMBER
8A47  25 3A                      BLO   L8A83               ; 'FC' ERROR IF NEW ADDRESS < OLD ADDRESS
8A49  8D 1C                      BSR   L8A67               ; MAKE SURE RENUMBERED LINE NUMBERS WILL BE IN RANGE
8A4B  BD 8A DD                   JSR   L8ADD               ; CONVERT ASCII LINE NUMBERS TO 'EXPANDED' BINARY
8A4E  BD AC EF                   JSR   LACEF               ; RECALCULATE NEXT LINE RAM ADDRESSES
8A51  8D AF                      BSR   L8A02               ; GET RAM ADDRESS OF FIRST LINE TO BE RENUMBERED
8A53  9F D3                      STX   VD3                 ; SAVE IT
8A55  8D 3A                      BSR   L8A91               ; MAKE SURE LINE NUMBERS EXIST
8A57  8D 0F                      BSR   L8A68               ; INSERT NEW LINE NUMBERS IN LINE HEADERS
8A59  8D 36                      BSR   L8A91               ; INSERT NEW LINE NUMBERS IN PROGRAM STATEMENTS
8A5B  BD 8B 7B                   JSR   L8B7B               ; CONVERT PACKED BINARY LINE NUMBERS TO ASCII
8A5E  BD AD 26                   JSR   LAD26               ; ERASE VARIABLES
8A61  BD AC EF                   JSR   LACEF               ; RECALCULATE NEXT LINE RAM ADDRESS
8A64  7E AC 73                   JMP   LAC73               ; GO BACK TO BASIC'S MAIN LOOP
8A67  86                L8A67    FCB   SKP1LD              ; SKIP ONE BYTE - LDA #$4F
8A68  4F                L8A68    CLRA                      ; NEW LINE NUMBER FLAG - 0; INSERT NEW LINE NUMBERS
8A69  97 D8                      STA   VD8                 ; SAVE NEW LINE NUMBER FLAG; 0 = INSERT NEW NUMBERS
8A6B  9E D3                      LDX   VD3                 ; GET ADDRESS OF OLD LINE NUMBER BEING RENUMBERED
8A6D  DC D5                      LDD   VD5                 ; GET THE CURRENT RENUMBERED LINE NUMBER
8A6F  8D 15                      BSR   L8A86               ; RETURN IF END OF PROGRAM
8A71  0D D8             L8A71    TST   VD8                 ; CHECK NEW LINE NUMBER FLAG
8A73  26 02                      BNE   L8A77               ; BRANCH IF NOT INSERTING NEW LINE NUMBERS
8A75  ED 02                      STD   $02,X               ; STORE THE NEW LINE NUMBER IN THE BASIC PROGRAM
8A77  AE 84             L8A77    LDX   ,X                  ; POINT X TO THE NEXT LINE IN BASIC
8A79  8D 0B                      BSR   L8A86               ; RETURN IF END OF PROGRAM
8A7B  D3 CF                      ADDD  VCF                 ; ADD INTERVAL TO CURRENT RENUMBERED LINE NUMBER
8A7D  25 04                      BLO   L8A83               ; 'FC' ERROR IF LINE NUMBER > $FFFF
8A7F  81 FA                      CMPA  #MAXLIN             ; LARGEST LINE NUMBER = $F9FF
8A81  25 EE                      BLO   L8A71               ; BRANCH IF LEGAL LINE NUMBER
8A83  7E B4 4A          L8A83    JMP   LB44A               ; 'FC' ERROR IF LINE NUMBER MS BYTE > $F9
* TEST THE TWO BYTES POINTED TO BY (X).
* NORMAL RETURN IF <> 0. IF = 0 (END OF
* PROGRAM) RETURN IS PULLED OFF STACK AND
* YOU RETURN TO PREVIOUS SUBROUTINE CALL.
8A86  34 06             L8A86    PSHS  B,A                 ; SAVE ACCD
8A88  EC 84                      LDD   ,X                  ; TEST THE 2 BYTES POINTED TO BY X
8A8A  35 06                      PULS  A,B                 ; RESTORE ACCD
8A8C  26 02                      BNE   L8A90               ; BRANCH IF NOT END OF PROGRAM
8A8E  32 62                      LEAS  $02,S               ; PURGE RETURN ADDRESS FROM STACK
8A90  39                L8A90    RTS
8A91  9E 19             L8A91    LDX   TXTTAB              ; GET START OF BASIC PROGRAM
8A93  30 1F                      LEAX  $-01,X              ; MOVE POINTER BACK ONE
8A95  30 01             L8A95    LEAX  $01,X               ; MOVE POINTER UP ONE
8A97  8D ED                      BSR   L8A86               ; RETURN IF END OF PROGRAM
8A99  30 03             L8A99    LEAX  $03,X               ; SKIP OVER NEXT LINE ADDRESS AND LINE NUMBER
8A9B  30 01             L8A9B    LEAX  $01,X               ; MOVE POINTER TO NEXT CHARACTER
8A9D  A6 84                      LDA   ,X                  ; CHECK CURRENT CHARACTER
8A9F  27 F4                      BEQ   L8A95               ; BRANCH IF END OF LINE
8AA1  9F 0F                      STX   TEMPTR              ; SAVE CURRENT POINTER
8AA3  4A                         DECA                      ; =
8AA4  27 0C                      BEQ   L8AB2               ; =BRANCH IF START OF PACKED NUMERIC LINE
8AA6  4A                         DECA                      ; *
8AA7  27 2A                      BEQ   L8AD3               ; *BRANCH IF LINE NUMBER EXISTS
8AA9  4A                         DECA                      ; =
8AAA  26 EF                      BNE   L8A9B               ; =MOVE TO NEXT CHARACTER IF > 3
8AAC  86 03             L8AAC    LDA   #$03                ; * SET 1ST BYTE = 3 TO INDICATE LINE
8AAE  A7 80                      STA   ,X+                 ; * NUMBER DOESN'T CURRENTLY EXIST
8AB0  20 E7                      BRA   L8A99               ; GO GET ANOTHER CHARACTER
8AB2  EC 01             L8AB2    LDD   $01,X               ; GET MS BYTE OF LINE NUMBER
8AB4  6A 02                      DEC   $02,X               ; DECREMENT ZERO CHECK BYTE
8AB6  27 01                      BEQ   L8AB9               ; BRANCH IF MS BYTE <> 0
8AB8  4F                         CLRA                      ; CLEAR MS BYTE
8AB9  E6 03             L8AB9    LDB   $03,X               ; GET LS BYTE OF LINE NUMBER
8ABB  6A 04                      DEC   $04,X               ; DECREMENT ZERO CHECK FLAG
8ABD  27 01                      BEQ   L8AC0               ; BRANCH IF IS BYTE <> 0
8ABF  5F                         CLRB                      ; CLEAR LS BYTE
8AC0  ED 01             L8AC0    STD   $01,X               ; SAVE BINARY LINE NUMBER
8AC2  DD 2B                      STD   BINVAL              ; SAVE TRIAL LINE NUMBER
8AC4  BD AD 01                   JSR   LAD01               ; FIND RAM ADDRESS OF A BASIC LINE NUMBER
8AC7  9E 0F             L8AC7    LDX   TEMPTR              ; GET BACK POINTER TO START OF PACKED LINE NUMBER
8AC9  25 E1                      BLO   L8AAC               ; BRANCH IF NO LINE NUMBER MATCH FOUND
8ACB  DC 47                      LDD   V47                 ; GET START ADDRESS OF LINE NUMBER
8ACD  6C 80                      INC   ,X+                 ; * SET 1ST BYTE = 2, TO INDICATE LINE NUMBER EXISTS IF CHECKING FOR
* * EXISTENCE OF LINE NUMBER, SET IT = 1 IF INSERTING LINE NUMBERS

8ACF  ED 84                      STD   ,X                  ; SAVE RAM ADDRESS OF CORRECT LINE NUMBER
8AD1  20 C6                      BRA   L8A99               ; GO GET ANOTHER CHARACTER
8AD3  6F 84             L8AD3    CLR   ,X                  ; CLEAR CARRY FLAG AND 1ST BYTE
8AD5  AE 01                      LDX   $01,X               ; POINT X TO RAM ADDRESS OF CORRECT LINE NUMBER
8AD7  AE 02                      LDX   $02,X               ; PUT CORRECT LINE NUMBER INTO (X)
8AD9  9F 47                      STX   V47                 ; SAVE IT TEMPORARILY
8ADB  20 EA                      BRA   L8AC7               ; GO INSERT IT INTO BASIC LINE
8ADD  9E 19             L8ADD    LDX   TXTTAB              ; GET BEGINNING OF BASIC PROGRAM
8ADF  20 04                      BRA   L8AE5
8AE1  9E A6             L8AE1    LDX   CHARAD              ; *GET CURRENT INPUT POINTER
8AE3  30 01                      LEAX  $01,X               ; *AND BUMP IT ONE
8AE5  8D 9F             L8AE5    BSR   L8A86               ; RETURN IF END OF PROGRAM
8AE7  30 02                      LEAX  $02,X               ; SKIP PAST NEXT LINE ADDRESS
8AE9  30 01             L8AE9    LEAX  $01,X               ; ADVANCE POINTER BY ONE
8AEB  9F A6             L8AEB    STX   CHARAD              ; SAVE NEW BASIC INPUT POINTER
8AED  9D 9F             L8AED    JSR   GETNCH              ; GET NEXT CHARACTER FROM BASIC
8AEF  4D                L8AEF    TSTA                      ; CHECK THE CHARACTER
8AF0  27 EF                      BEQ   L8AE1               ; BRANCH IF END OF LINE
8AF2  2A F9                      BPL   L8AED               ; BRANCH IF NOT A TOKEN
8AF4  9E A6                      LDX   CHARAD              ; GET CURRENT INPUT POINTER
8AF6  81 FF                      CMPA  #$FF                ; IS THIS A SECONDARY TOKEN?
8AF8  27 EF                      BEQ   L8AE9               ; YES - IGNORE IT
8AFA  BD 01 A0                   JSR   RVEC22              ; HOOK INTO RAM AND CHECK FOR USER ADDED TOKENS
8AFD  81 A7                      CMPA  #$A7                ; TOKEN FOR THEN?
8AFF  27 12                      BEQ   L8B13               ; YES
8B01  81 84                      CMPA  #$84                ; TOKEN FOR ELSE?
8B03  27 0E                      BEQ   L8B13               ; YES
8B05  81 81                      CMPA  #$81                ; TOKEN FOR GO?
8B07  26 E4                      BNE   L8AED               ; NO
8B09  9D 9F                      JSR   GETNCH              ; GET A CHARACTER FROM BASIC
8B0B  81 A5                      CMPA  #$A5                ; TOKEN FOR TO?
8B0D  27 04                      BEQ   L8B13               ; YES
8B0F  81 A6                      CMPA  #$A6                ; TOKEN FOR SUB?
8B11  26 D8                      BNE   L8AEB               ; NO
8B13  9D 9F             L8B13    JSR   GETNCH              ; GET A CHARACTER FROM BASIC
8B15  25 04                      BLO   L8B1B               ; BRANCH IF NUMERIC
8B17  9D A5             L8B17    JSR   GETCCH              ; GET CURRENT BASIC INPUT CHARRACTER
8B19  20 D4                      BRA   L8AEF               ; KEEP CHECKING THE LINE
8B1B  9E A6             L8B1B    LDX   CHARAD              ; GET CURRENT INPUT ADDRESS
8B1D  34 10                      PSHS  X                   ; SAVE IT ON THE STACK
8B1F  BD AF 67                   JSR   LAF67               ; CONVERT DECIMAL BASIC NUMBER TO BINARY
8B22  9E A6                      LDX   CHARAD              ; GET CURRENT INPUT POINTER
8B24  A6 82             L8B24    LDA   ,-X                 ; GET PREVIOUS INPUT CHARACTER
8B26  BD 90 AA                   JSR   L90AA               ; CLEAR CARRY IF NUMERIC INPUT VALUE
8B29  25 F9                      BLO   L8B24               ; BRANCH IF NON-NUMERIC
8B2B  30 01                      LEAX  $01,X               ; MOVE POINTER UP ONE
8B2D  1F 10                      TFR   X,D                 ; NOW ACCD POINTS TO ONE PAST END OF LINE NUMBER
8B2F  E0 61                      SUBB  $01,S               ; SUBTRACT PRE-NUMERIC POINTER LS BYTE
8B31  C0 05                      SUBB  #$05                ; MAKE SURE THERE ARE AT LEAST 5 CHARACTERS IN THE NUMERIC LINE
*
8B33  27 20                      BEQ   L8B55               ; BRANCH IF EXACTLY 5
8B35  25 0A                      BLO   L8B41               ; BRANCH IF < 5
8B37  33 84                      LEAU  ,X                  ; TRANSFER X TO U
8B39  50                         NEGB                      ; NEGATE B
8B3A  30 85                      LEAX  B,X                 ; MOVE X BACK B BYTES
8B3C  BD 89 B8                   JSR   L89B8               ; *MOVE BYTES FROM (U) TO (X) UNTIL
* *U = END OF BASIC; (I) = NEW END OF BASIC
8B3F  20 14                      BRA   L8B55
* FORCE FIVE BYTES OF SPACE FOR THE LINE NUMBER
8B41  9F 47             L8B41    STX   V47                 ; SAVE END OF NUMERIC VALUE
8B43  9E 1B                      LDX   VARTAB              ; GET END OF BASIC PROGRAM
8B45  9F 43                      STX   V43                 ; SAVE IT
8B47  50                         NEGB                      ; NEGATE B
8B48  30 85                      LEAX  B,X                 ; ADD IT TO END OF NUMERIC POiNTER
8B4A  9F 41                      STX   V41                 ; SAVE POINTER
8B4C  9F 1B                      STX   VARTAB              ; STORE END OF BASIC PROGRAM
8B4E  BD AC 1E                   JSR   LAC1E               ; ACCD = TOP OF ARRAYS - CHECK FOR ENOUGH ROOM
8B51  9E 45                      LDX   V45                 ; * GET AND SAVE THE
8B53  9F A6                      STX   CHARAD              ; * NEW CURRENT INPUT POINTER
8B55  35 10             L8B55    PULS  X                   ; RESTORE POINTER TO START OF NUMERIC VALUE
8B57  86 01                      LDA   #$01                ; NEW LINE NUMBER FLAG
8B59  A7 84                      STA   ,X                  ; * SAVE NEW LINE FLAG
8B5B  A7 02                      STA   $02,X               ; *
8B5D  A7 04                      STA   $04,X               ; *
8B5F  D6 2B                      LDB   BINVAL              ; GET MS BYTE OF BINARY LINE NUMBER
8B61  26 04                      BNE   L8B67               ; BRANCH IF IT IS NOT ZERO
8B63  C6 01                      LDB   #$01                ; SAVE A 1 IF BYTE IS 0; OTHERWISE, BASIC WILL
; THINK IT IS THE END OF A LINE
8B65  6C 02                      INC   $02,X               ; IF 2,X = 2, THEN PREVIOUS BYTE WAS A ZERO
8B67  E7 01             L8B67    STB   $01,X               ; SAVE MS BYTE OF BINARY LINE NUMBER
8B69  D6 2C                      LDB   BINVAL+1            ; GET IS BYTE OF BINARY LINE NUMBER
8B6B  26 04                      BNE   L8B71               ; BRANCH IF NOT A ZERO BYTE
8B6D  C6 01                      LDB   #$01                ; SAVE A 1 IF BYTE IS A 0
8B6F  6C 04                      INC   $04,X               ; IF 4,X = 2, THEN PREVIOUS BYTE WAS A 0
8B71  E7 03             L8B71    STB   $03,X               ; SAVE LS BYTE OF BINARY LINE NUMBER
8B73  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
8B75  81 2C                      CMPA  #','                ; IS IT A COMMA?
8B77  27 9A                      BEQ   L8B13               ; YES - PROCESS ANOTHER NUMERIC VALUE
8B79  20 9C                      BRA   L8B17               ; NO - GO GET AND PROCESS AN INPUT CHARACTER
8B7B  9E 19             L8B7B    LDX   TXTTAB              ; POINT X TO START OF BASIC PROGRAM
8B7D  30 1F                      LEAX  $-01,X              ; MOVE POINTER BACK ONE
8B7F  30 01             L8B7F    LEAX  $01,X               ; MOVE POINTER UP ONE
8B81  EC 02                      LDD   $02,X               ; GET ADDRESS OF NEXT LINE
8B83  DD 68                      STD   CURLIN              ; SAVE IT IN CURLIN
8B85  BD 8A 86                   JSR   L8A86               ; RETURN IF END OF PROGRAM
8B88  30 03                      LEAX  $03,X               ; SKIP OVER ADDRESS OF NEXT LINE AND 1ST BYTE OF LINE NUMBER
8B8A  30 01             L8B8A    LEAX  $01,X               ; MOVE POINTER UP ONE
8B8C  A6 84             L8B8C    LDA   ,X                  ; GET CURRENT CHARACTER
8B8E  27 EF                      BEQ   L8B7F               ; BRANCH IF END OF LINE
8B90  4A                         DECA                      ; INPUT CHARACTER = 1? - VALID LINE NUMBER
8B91  27 1B                      BEQ   L8BAE               ; YES
8B93  80 02                      SUBA  #$02                ; INPUT CHARACTER 3? - UL LINE NUMBER
8B95  26 F3                      BNE   L8B8A               ; NO
8B97  34 10                      PSHS  X                   ; SAVE CURRENT POSITION OF INPUT POINTER
8B99  8E 8B D8                   LDX   #L8BD9-1            ; POINT X TO 'UL' MESSAGE
8B9C  BD B9 9C                   JSR   STRINOUT            ; PRINT STRING TO THE SCREEN
8B9F  AE E4                      LDX   ,S                  ; GET INPUT POINTER
8BA1  EC 01                      LDD   $01,X               ; GET THE UNDEFINED LINE NUMBER
8BA3  BD BD CC                   JSR   LBDCC               ; CONVERT NUMBER IN ACCD TO DECIMAL AND DISPLAY IT
8BA6  BD BD C5                   JSR   LBDC5               ; PRINT 'IN XXXX' XXXX = CURRENT LINE NUMBER
8BA9  BD B9 58                   JSR   LB958               ; SEND A CR TO CONSOLE OUT
8BAC  35 10                      PULS  X                   ; GET INPUT POINTER BACK
8BAE  34 10             L8BAE    PSHS  X                   ; SAVE CURRENT POSITION OF INPUT POINTER
8BB0  EC 01                      LDD   $01,X               ; LOAD ACCD WITH BINARY VALUE OF LINE NUMBER
8BB2  DD 52                      STD   FPA0+2              ; SAVE IN BOTTOM 2 BYTES OF FPA0
8BB4  BD 88 0E                   JSR   L880E               ; ADJUST REST OF FPA0 AS AN INTEGER
8BB7  BD BD D9                   JSR   LBDD9               ; CONVERT FPA0 TO ASCII, STORE IN LINE NUMBER
8BBA  35 40                      PULS  U                   ; LOAD U WITH PREVIOUS ADDRESS OF INPUT POINTER
8BBC  C6 05                      LDB   #$05                ; EACH EXPANDED LINE NUMBER USES 5 BYTES
8BBE  30 01             L8BBE    LEAX  $01,X               ; MOVE POINTER FORWARD ONE
8BC0  A6 84                      LDA   ,X                  ; GET AN ASCII BYTE
8BC2  27 05                      BEQ   L8BC9               ; BRANCH IF END OF NUMBER
8BC4  5A                         DECB                      ; DECREMENT BYTE COUNTER
8BC5  A7 C0                      STA   ,U+                 ; STORE ASCII NUMBER IN BASIC LINE
8BC7  20 F5                      BRA   L8BBE               ; CHECK FOR ANOTHER DIGIT
8BC9  30 C4             L8BC9    LEAX  ,U                  ; TRANSFER NEW LINE POINTER TO (X)
8BCB  5D                         TSTB                      ; DOES THE NEW LINE NUMBER REQUIRE 5 BYTES?
8BCC  27 BE                      BEQ   L8B8C               ; YES - GO GET ANOTHER INPUT CHARACTER
8BCE  31 C4                      LEAY  ,U                  ; SAVE NEW LINE POINTER IN Y
8BD0  33 C5                      LEAU  B,U                 ; POINT U TO END OF 5 BYTE PACKED LINE NUMBER BLOCK
8BD2  BD 89 B8                   JSR   L89B8               ; MOVE BYTES FROM (U) TO (X) UNTIL END OF PROGRAM
8BD5  30 A4                      LEAX  ,Y                  ; LOAD (X) WITH NEW LINE POINTER
8BD7  20 B3                      BRA   L8B8C               ; GO GET ANOTHER INPUT CHARACTER

8BD9  55 4C 20          L8BD9    FCC   'UL '               ; UNKNOWN LINE NUMBER MESSAGE
8BDC  00                         FCB   0
