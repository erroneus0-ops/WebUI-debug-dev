; Extended Color BASIC 1.1 -- $9339-$93BA
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: PPOINT=$9339, PSET=$9361, PRESET=$9365

* PPOINT
9339  BD 93 B2          PPOINT   JSR   >L93B2              ; EVAL TWO EXPRESSIONS, RETURN VALUES IN (HORBEG,VERBEG)
933C  BD 93 1D                   JSR   >L931D              ; NORMALIZE EXPRESSIONS FOR PROPER PMODE
933F  BD 92 98                   JSR   L9298               ; CONVERT COORDS INTO ABS SCREEN POSITION & PIXEL MASK
9342  A4 84                      ANDA  ,X                  ; AND PIXEL MASK WITH CONTENTS OF SCREEN
9344  D6 B6                      LDB   PMODE               ; GET CURRENT PMODE
9346  56                         RORB                      ; SHIFT RIGHT
9347  24 12                      BCC   L935B               ; BRANCH IF PMODE 0,2,4 (2 COLOR)
9349  81 04             L9349    CMPA  #$04                ; * IS THE 'ON' PIXEL IN THE 2 RIGHTMOST BITS?
934B  25 04                      BLO   L9351               ; BRANCH IF IT IS
934D  46                         RORA                      ; =SHIFT RIGHT
934E  46                         RORA                      ; =ONE PIXEL
934F  20 F8                      BRA   L9349               ; KEEP CHECKING
9351  4C                L9351    INCA                      ; ADD 1 TO COLOR - BASIC USES 1 TO 4, NOT 0 TO 3
9352  48                         ASLA                      ; TIMES 2
9353  9B C1                      ADDA  CSSVAL              ; ADD COLOR SET (0 OR 8)
9355  44                         LSRA                      ; DIVIDE ACCB BY TWO - COLORS RANGE FROM 0 - 8
9356  1F 89             L9356    TFR   A,B                 ; *TRANSFER COLOR INFO INTO ACCB
9358  7E B4 F3                   JMP   LB4F3               ; *CONVERT ACCB TO FP NUMBER
935B  4D                L935B    TSTA                      ; IS 2 COLOR PIXEL ON?
935C  27 F8                      BEQ   L9356               ; NO
935E  4F                         CLRA                      ; * FORCE THE TWO-COLOR 'ON' VALUE TO BE
935F  20 F0                      BRA   L9351               ; * ONE OR FIVE (DEPENDING ON CSS).

* PSET
9361  86 01             PSET     LDA   #$01                ; PSET FLAG
9363  20 01                      BRA   L9366

* PRESET
9365  4F                PRESET   CLRA                      ; PRESET FLAG
9366  97 C2             L9366    STA   SETFLG              ; STORE FLAG 0 = PRESET, 1 = PSET
9368  BD B2 6A                   JSR   LB26A               ; SYNTAX CHECK FOR '('
936B  BD 93 1A                   JSR   >L931A              ; EVAL HOR & VER COORDS AND NORMALIZE
936E  BD 95 81                   JSR   L9581               ; *EVALUATE COLOR - RETURN IN WCOLOR; ALLCOL
* *WILL BE ONE BYTE WITH ALL PIXELS SET TO THAT COLOR
9371  BD B2 67                   JSR   LB267               ; SYNTAX CHECK FOR ')'
9374  BD 92 98                   JSR   L9298               ; *CALCULATE THE ABSOLUTE ADDRESS OF THE
* *BYTE TO PSET/PRESET - RETURN ADDRESS IN X - THE MASK
* *OF PIXEL TO CHANGE RETURNED IN ACCA SET A PIXEL ON
* *SCREEN - ABS POSIT IN X, MASK IN ACCA, COLOR IN ALLCOL

* TURN ON THE PIXEL (POINTED TO BY X, PIXEL MASK IN ACCA) TO THE COLOR
* IN ALLCOL.  SET CHGFLG <> 0 IF THE PIXEL COLOR IS CHANGED.
9377  E6 84             L9377    LDB   ,X                  ; GET BYTE FROM THE SCREEN
9379  34 04                      PSHS  B                   ; SAVE IT ON STACK
937B  1F 89                      TFR   A,B                 ; PUT PIXEL MASK IN ACCB
937D  43                         COMA                      ; INVERT PIXEL MASK
937E  A4 84                      ANDA  ,X                  ; * 'AND' WITH SCREEN DATA - KEEP ALL PIXELS
; * EXCEPT THE ONE TO MODIFY
9380  D4 B5                      ANDB  ALLCOL              ; CONVERT PIXEL IN THE PIXEL MASK TO THE PROPER COLOR
9382  34 04                      PSHS  B                   ; SAVE IT ON STACK
9384  AA E0                      ORA   ,S+                 ; 'OR' IT INTO THE REST OF THE PIXELS
9386  A7 84                      STA   ,X                  ; PUT IT ON SCREEN
9388  A0 E0                      SUBA  ,S+                 ; SUBTRACT OLD BYTE FROM NEW BYTE; ACCA=0 IF NEW BYTE = OLD BYTE
938A  9A DB                      ORA   CHGFLG              ; 'OR' DIFFERENCE WITH CHANGE FLAG
938C  97 DB                      STA   CHGFLG              ; SAVE IT - CHGFLG WILL BE = 0 IF THE GRAPHIC BYTE IS UNCHANGED
938E  39                         RTS
* EVALUATE TWO SETS OF COORDINATES SEPARATED BY A MINUS
* SIGN.  PUT 1ST SET OF COORDS AT (HORBEG,VERBEG), SECOND
* SET AT (HOREND,VEREND). IF NOTHING BEFORE MINUS SIGN, PUT
* (HORDEF,VERDEF) AT (HORBEG, VERBEG)
938F  9E C7             L938F    LDX   HORDEF              ; GET LAST HORIZ END POINT
9391  9F BD                      STX   HORBEG              ; PUT IN START POINT STORAGE LOC
9393  9E C9                      LDX   VERDEF              ; GET LAST VERT END POINT
9395  9F BF                      STX   VERBEG              ; PUT IN START POINT VERT STORAGE LOC
9397  81 AC                      CMPA  #$AC                ; TOKEN FOR MINUS SIGN
9399  27 03                      BEQ   L939E               ; BRANCH IF NO STARTING COORDINATES GIVEN
939B  BD 93 B2                   JSR   >L93B2              ; GO GET STARTING COORDINATES
939E  C6 AC             L939E    LDB   #$AC                ; TOKEN FOR MINUS SIGN
93A0  BD B2 6F                   JSR   LB26F               ; GO DO A SYNTAX CHECK
93A3  BD B2 6A                   JSR   LB26A               ; SYNTAX CHECK FOR A '('
93A6  BD B7 34                   JSR   LB734               ; EVALUATE 2 EXPRESSIONS
93A9  10 8E 00 C3                LDY   #HOREND             ; TEMP STORAGE LOCATION FOR END COORDINATES OF LINE COMMAND
93AD  BD 93 03                   JSR   L9303               ; GET END POINT COORDS
93B0  20 06                      BRA   L93B8               ; CHECK SYNTAX FOR ')'
93B2  BD B2 6A          L93B2    JSR   LB26A               ; SYNTAX CHECK FOR '('
93B5  BD 92 FC                   JSR   L92FC               ; EVALUATE 2 EXPRESSIONS
93B8  7E B2 67          L93B8    JMP   LB267               ; SYNTAX CHECK FOR ' )' AND RETURN
