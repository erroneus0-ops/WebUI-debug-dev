; Super Extended Color BASIC 2.0 (CoCo 3) -- $E98D-$EA48
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here:         INITIALLY SET TO ABSOLUTE VALUE OF LARGEST DELTA=$

** DRAW THE LINE HERE - AT THIS POINT THE STACK HAS THE DRAW DATA ON IT
* 0 1,S=MINOR COORDINATE INCREMENT COUNTER
* 2 3,S=ABSOLUTE VALUE OF THE SMALLEST DELTA COORDINATE
* 4 5,S=ABSOLUTE VALUE OF THE LARGEST DELTA COORDINATE
* 6 7,S=LARGEST COORDINATE COUNTER (HOW MANY TIMES THROUGH THE DRAW LOOP)
                                INITIALLY SET TO ABSOLUTE VALUE OF LARGEST DELTA
* 8 9,S=ADDRESS OF THE ROUTINE WHICH WILL INCREMENT OR DECREMENT THE LARGEST DELTA COORDINATE

E98D  AD C4             LE98D    JSR   ,U                  ; CONVERT (X,Y) COORDINATES TO ABSOLUTE SCREEN ADDRESS
E98F  BD E7 88                   JSR   LE788               ; TURN ON A PIXEL
E992  AE 66                      LDX   $06,S               ; GET DISTANCE COUNTER
E994  27 17                      BEQ   LE9AD               ; BRANCH IF LINE COMPLETELY DRAWN
E996  30 1F                      LEAX  $-01,X              ; DECR ONE
E998  AF 66                      STX   $06,S               ; SAVE IT
E99A  AD F8 08                   JSR   [$08,S]             ; INCR/DECR COORDINATE WHICH HAS THE SMALLEST DELTA
E99D  EC E4                      LDD   ,S                  ; GET THE MINOR COORDINATE INCREMENT COUNTER
E99F  E3 62                      ADDD  $02,S               ; ADD THE SMALLEST DIFFERENCE
E9A1  ED E4                      STD   ,S                  ; SAVE NEW MINOR COORDINATE INCREMENT COUNTER
E9A3  A3 64                      SUBD  $04,S               ; SUBTACT OUT THE LARGEST DIFFERENCE
E9A5  25 E6                      BCS   LE98D               ; BRANCH IF RESULT NOT > LARGEST DIFFERENCE
E9A7  ED E4                      STD   ,S                  ; IF >=, THEN STORE NEW MINOR COORDINATE INCREMENT
E9A9  AD A4                      JSR   ,Y                  ; INCR/DECR COORDINATE WHICH HAS THE SMALLEST DELTA
E9AB  20 E0                      BRA   LE98D               ; KEEP GOING
E9AD  35 10             LE9AD    PULS  X                   ; CLEAN UP STACK
E9AF  35 F6                      PULS  A,B,X,Y,U,PC        ; CLEAN UP STACK AND RETURN

* THESE ROUTINES ARE USED TO INCREMENT OR DECREMENT THE HORIZONTAL AND VERTICAL
* COORDINATES. THEY NEED TO BE KEPT IN THIS ORDER (INCR, INCR, DECR, DECR)
E9B1  9E BD             LE9B1    LDX   HORBEG              ; GET HORIZONTAL COORD
E9B3  30 01                      LEAX  $01,X               ; ADD ONE
E9B5  9F BD                      STX   HORBEG              ; SAVE NEW HORIZONTAL COORD
E9B7  39                         RTS
E9B8  9E BF                      LDX   VERBEG              ; GET VERTICAL COORD
E9BA  30 01                      LEAX  $01,X               ; ADD ONE
E9BC  9F BF                      STX   VERBEG              ; SAVE NEW VERTICAL COORD
E9BE  39                         RTS
E9BF  9E BD             LE9BF    LDX   HORBEG              ; GET HORIZONTAL COORD
E9C1  30 1F                      LEAX  $-01,X              ; SUBTRACT ONE
E9C3  9F BD                      STX   HORBEG              ; SAVE NEW HORIZONTAL COORD
E9C5  39                         RTS
E9C6  9E BF                      LDX   VERBEG              ; GET VERTICAL COORD
E9C8  30 1F                      LEAX  $-01,X              ; SUBTRACT ONE
E9CA  9F BF                      STX   VERBEG              ; SAVE NEW VERTICAL COORD
E9CC  39                LE9CC    RTS

E9CD  DC C5             LE9CD    LDD   VEREND              ; GET VERTICAL ENDING ADDRESS
E9CF  93 BF                      SUBD  VERBEG              ; SUBTRACT OUT VERTICAL BEGINNING ADDRESS
E9D1  24 F9             LE9D1    BCC   LE9CC               ; RETURN IF END >= START
E9D3  34 01                      PSHS  CC                  ; SAVE STATUS (WHICH COORDINATE IS GREATER)

* THE NEXT THREE INSTRUCTIONS WILL NEGATE ACCD
E9D5  40                         NEGA
E9D6  50                         NEGB
E9D7  82 00                      SBCA  #$00                ; NEGATE ACCB
E9D9  35 81                      PULS  CC,PC               ; RESTORE STATUS AND RETURN

E9DB  DC C3             LE9DB    LDD   HOREND              ; GET HORIZONTAL END COORD
E9DD  93 BD                      SUBD  HORBEG              ; SUBTRACT OUT HORIZONTAL START COORD
E9DF  20 F0                      BRA   LE9D1               ; GET ABSOLUTE VALUE

* EVALUATE TWO SETS OF COORDINATES SEPERATED BY A MINUS
* SIGN. PUT 1ST SET OF COORDINATES AT (HORBEG,VERBEG), SECOND
* SET AT (HOREND,VEREND). IF NOTHING BEFORE MINUS SIGN, PUT
* (HORDEF,VERDEF) DEFAULTS AT (HORBEG,VERBEG).

E9E1  9E C7             LE9E1    LDX   HORDEF              ; GET THE LAST HORIZONTAL END POINT
E9E3  9F BD                      STX   HORBEG              ; PUT AS START POINT
E9E5  9E C9                      LDX   VERDEF              ; GET THE LAST VERTICAL END POINT
E9E7  9F BF                      STX   VERBEG              ; PUT AS VERTICAL START POINT
E9E9  81 AC                      CMPA  #$AC                ; CHECK FOR MINUS SIGN (-) TOKEN
E9EB  27 03                      BEQ   LE9F0               ; BRANCH IF NO STARTING COORDINATES GIVEN
E9ED  BD EA 04                   JSR   LEA04               ; GO GET THE STARTING COORDINATES
E9F0  C6 AC             LE9F0    LDB   #$AC                ; TOKEN FOR THE MINUS SIGN (-)
E9F2  BD B2 6F                   JSR   LB26F               ; DO A SYNTAX CHECK FOR A MINUS SIGN
E9F5  BD B2 6A                   JSR   LB26A               ; SYNTAX CHECK FOR A '('
E9F8  BD B7 34                   JSR   LB734               ; EVALUATE 2 EXPRESSIONS
E9FB  10 8E 00 C3                LDY   #HOREND             ; TEMP STORAGE LOCS FOR END COORDS OF LINE COMMAND
E9FF  BD E7 B9                   JSR   LE7B9               ; GET END POINT COORDINATES
EA02  20 06                      BRA   LEA0A               ; SYNTAX CHECK FOR A ')'
EA04  BD B2 6A          LEA04    JSR   LB26A               ; SYNTAX CHECK FOR A '('
EA07  BD E7 B2                   JSR   LE7B2               ; EVALUATE  HORIZONTAL & VERTICAL COORDINATES WITH RANGE CHECK
EA0A  7E B2 67          LEA0A    JMP   LB267               ; SYNTAX CHECK FOR ')' AND RETURN
EA0D  BD E7 AD          LEA0D    JSR   LE7AD               ; POINT U TO HORBEG; USELESS GIVEN THE FOLLOWINF INSTRUCTION
EA10  CE 00 C3                   LDU   #HOREND             ; POINT U TO HOREND
EA13  7E E7 B0                   JMP   LE7B0               ; JUMP TO AN RTS; ONCE WAS A JUMP TO NORMALIZATION ROUTINE

* POINT U TO ROUTINE WHICH WILL MOVE PIXEL ONE TO RIGHT
EA16  CE EA 25          LEA16    LDU   #LEA25              ; POINT TO JUMP TABLE
EA19  D6 E6                      LDB   HRMODE              ; GET HI-RES GRAPHICS MODE VALUE
EA1B  C0 01                      SUBB  #$01                ; ADJUST OUT MODE 0 (WHY NOT DECB)
EA1D  58                         ALSB                      ; TWO BYTES PER ENTRY
EA1E  EE C5                      LDU   B,U                 ; GET JUMP ADDRESS
EA20  39                         RTS

EA21  CE EA 45          LEA21    LDU   #LEA45              ; POINT U TO ROUTINE TO MOVE ABSOLUTE POS DOWN ONE ROW
EA24  39                         RTS

* JUMP TABLE OF ADDRESSES OF ROUTINES WHICH WILL MOVE THE
* ABSOLUTE SCREEN ADDRESS POINTER ONE PIXEL TO THE RIGHT
EA25  EA 34             LEA25    FDB   LEA34               ; HSCREEN 1
EA27  EA 3D             LEA27    FDB   LEA3D               ; HSCREEN 2
EA29  EA 2D             LEA29    FDB   LEA2D               ; HSCREEN 3
EA2B  EA 34             LEA2B    FDB   LEA34               ; HSCREEN 4

* ENTER WITH ABSOLUTE SCREEN POSITION IN X, PIXEL MASK
* IN ACCA - ADJUST X AND ACCA TO THE NEXT PIXEL TO THE RIGHT FOR HSCREEN 3
EA2D  44                LEA2D    LSRA                      ; SHIFT ONE BIT TO THE RIGHT
EA2E  24 03                      BCC   LEA33               ; BRANCH IF SAME BYTE
EA30  46                         RORA                      ; SET BIT 7 OF ACCA IF JUST MOVED TO NEXT BYTE
EA31  30 01                      LEAX  $01,X               ; ADD ONE TO SCREEN POSITION
EA33  39                LEA33    RTS

* ENTER WITH ABSOLUTE SCREEN POSITION IN X, PIXEL MASK IN ACCA -
* ADJUST X AND ACCA TO THE NEXT PIXEL TO THE RIGHT FOR HSCREEN 1 & 4
EA34  44                LEA34    LSRA                      ; SHIFT MASK ONE BIT TO THE RIGHT
EA35  44                         LSRA                      ; DO IT AGAIN
EA36  24 FB                      BCC   LEA33               ; BRANCH IF SAME BYTE
EA38  86 C0                      LDA   #$C0                ; SET PIXEL #3 IF NEW BYTE
EA3A  30 01                      LEAX  $01,X               ; ADD ONE TO SCREEN ADDRESS
EA3C  39                         RTS

* ENTER WITH ABSOLUTE SCREEN POSITION IN X, PIXEL MASK IN ACCA -
* ADJUST X AND ACCA TO THE NEXT PIXEL TO THE RIGHT FOR HSREEN 2
EA3D  43                LEA3D    COMA                      ; SET TO ALTERNATE PIXEL
EA3E  81 F0                      CMPA  #$F0                ; SEE IF TOP HALF OF BYTE
EA40  26 02                      BNE   LEA44               ; BRANCH IF SAME BYTE
EA42  30 01                      LEAX  $01,X               ; MOVE POINTER TO NEXT SCREEN ADDRESS
EA44  39                LEA44    RTS

* ROUTINE TO MOVE DOWN ONE ROW
* ENTER WITH ABSOLUTE SCREEN ADDRESS IN X
EA45  D6 B9             LEA45    LDB   HORBYT              ; GET NUMBER OF BYTES PER HORIZONTAL GRAPHICS ROW
EA47  3A                         ABX                       ; ADD A ROW TO CURRENT ADDRESS (MOVE DOWN ONE ROW)
EA48  39                         RTS
