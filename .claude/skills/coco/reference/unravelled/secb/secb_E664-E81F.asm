; Super Extended Color BASIC 2.0 (CoCo 3) -- $E664-$E81F
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: IM.RGB=$E664, RGB=$E674, CMP=$E676, IM.PALET=$E678, HSCREEN=$E688, HCLS=$E6CF, CLRHIRES=$E6D8, HCOLOR=$E6F4, PIXELFIL=$E742, HSET=$E761, HRESET=$E765, HCALPOS=$E7DA, CALTABLE=$E7DE, PIX1MASK=$E7F1, PIX2MASK=$E7F9, PIX4MASK=$E7FD, G1BITPIX=$E7FF

* PALETTE COLORS FOR AN RGB MONITOR
E664  12 36 09 24 3F 1B IM.RGB   FCB   18,54,9,36,63,27
E66A  2D 26 00 12 00 3F          FCB   45,38,0,18,0,63
E670  00 12 00 26                FCB   0,18,0,38

E674  20 84             RGB      BRA   LE5FA

E676  20 8E             CMP      BRA   LE606

* MASTER IMAGES USED TO PROGRAM THE CUSTOM CHIP'S PALETTE REGISTERS
E678  12 24 0B 07 3F 1F IM.PALET FCB   18,36,11,7,63,31
E67E  09 26 00 12 00 3F          FCB   9,38,0,18,0,63
E684  00 12 00 26                FCB   0,18,0,38

* HSCREEN
E688  81 00             HSCREEN  CMPA  #$00                ; CHECK FOR END OF LINE
E68A  10 21 19 72                LBRN  RAMLINK             ; RAM HOOK
E68E  26 03                      BNE   LE693               ; BRANCH IF NOT END OF LINE
E690  5F                         CLRB                      ; IF END OF LINE, SET ARGUMENT TO ZERO
E691  20 09                      BRA   LE69C               ; SET THE HSCREEN MODE
E693  BD B7 0B          LE693    JSR   EVALEXPB            ; EVALUATE EXPRESSION, RETURN VALUE IN ACCB
E696  C1 04                      CMPB  #$04                ; ONLY 4 HSCREEN MODES ALLOWED
E698  10 22 CD AE                LBHI  ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR
E69C  D7 E6             LE69C    STB   HRMODE              ; SAVE THE HI-RES GRAPHICS MODE
E69E  C1 00                      CMPB  #$00                ; CHECK FOR MODE 0
E6A0  26 03                      BNE   LE6A5               ; BRANCH IF NOT HSCREEN 0
E6A2  7E E0 19                   JMP   SETTEXT             ; SETUP THE VIDEO MODE REGISTERS FOR COCO  COMPATIBLE MODE
E6A5  D7 E6             LE6A5    STB   HRMODE              ; SAVE THE HI-RES GRAPHICS MODE
E6A7  8E E6 CB                   LDX   #LE6CB              ; POINT TO THE TABLE OF NUMBER OF BYTES/HORIZONTAL ROW
E6AA  C0 01                      SUBB  #$01                ; CONVERT THE HI-RES MODE FROM 1-4 TO 0-3
E6AC  A6 85                      LDA   B,X                 ; GET THE NUMBER OF BYTES/HORIZONTAL ROW
E6AE  97 B9                      STA   HORBYT              ; AND SAVE IT
E6B0  C1 01                      CMPB  #$01                ; ONE OF THE FIRST TWO MODES?
E6B2  2E 05                      BGT   LE6B9               ; BRANCH IF NOT
E6B4  CC 00 A0                   LDD   #160                ; HORIZONTAL CENTER OF 320 COORDINATE SCREEN
E6B7  20 03                      BRA   LE6BC
E6B9  CC 01 40          LE6B9    LDD   #320                ; HORIZONTAL CENTER OF 640 COORDINATE SCREEN
E6BC  DD C7             LE6BC    STD   HORDEF              ; SAVE AS HORIZONTAL DEFAULT COORD
E6BE  CC 00 60                   LDD   #96                 ; VERTICAL CENTER COORDINATE
E6C1  DD C9                      STD   VERDEF              ; SAVE AS VERTICAL DEFAULT
E6C3  F6 FE 0B                   LDB   H.BCOLOR            ; GET THE BACKGROUND COLOR
E6C6  8D 10                      BSR   CLRHIRES            ; CLEAR THE HI-RES GRAPHICS SCREEN TO THE BACKGROUND COLOR
E6C8  7E E0 4D                   JMP   SETGRAPH            ; GROGRAM THE VIDEO RESOLUTION MODE

* TABLE OF THE NUMBER OF BYTES PER HORIZONTAL ROW FOR EACH HSCREEN MODE
E6CB  50 A0 50 A0       LE6CB    FCB   80,160,80,160

* HCLS
E6CF  26 05             HCLS     BNE   LE6D6               ; BRANCH IF NOT END OF LINE
E6D1  F6 FE 0B                   LDB   H.BCOLOR            ; GET THE BACKGROUND COLOR
E6D4  20 02                      BRA   CLRHIRES            ; CLEAR THE SCREEN TO THE BACKGROUND COLOR
E6D6  8D 36             LE6D6    BSR   LE70E               ; EVALUATE AN EXPRESSION, SYNTAX CHECK FOR NOT > 16

* CLEAR THE HI-RES GRAPHICS SCREEN TO THE COLOR IN ACCB
E6D8  0D E6             CLRHIRES TST   HRMODE              ; CHECK THE HI-RES MODE
E6DA  27 13                      BEQ   LE6EF               ; HR' ERROR IF IN THE 32 COLUMN MODE
E6DC  8D 64                      BSR   PIXELFIL            ; FILL ACCB WITH THE SELECTED COLOR
E6DE  BD E1 19                   JSR   SELTASK1            ; SELECT TASK REGISTER 1 AS THE ACTIVE TASK REGISTER
* FILL MEMORY FROM HRESSCRN TO $A000 WITH ACCB; THIS IS THE HI-RES GRAPHICS SCREEN
E6E1  8E 20 00                   LDX   #HRESSCRN           ; POINT TO START OF HI-RES GRAPHICS SCREEN
E6E4  E7 80             LE6E4    STB   ,X+                 ; 'CLEAR' A BYTE
E6E6  8C A0 00                   CMPX  #BASIC              ; CHECK FOR END OF THE HI-RES GRAPHICS SCREEN
E6E9  26 F9                      BNE   LE6E4               ; KEEP 'CLEARING' UNTIL DONE
E6EB  BD E0 FF                   JSR   SELTASK0            ; SET TASK REGISTER 0 AS THE ACTIVE TASK REGISTER
E6EE  39                         RTS
E6EF  C6 4C             LE6EF    LDB   #38*2               ; 'HR' ERROR
E6F1  7E AC 46                   JMP   LAC46               ; JUMP TO THE ERROR HANDLER

* HCOLOR
E6F4  81 2C             HCOLOR   CMPA  #','                ; CHECK FOR COMMA, FIRST ARGUMENT NOT GIVEN
E6F6  10 21 19 06                LBRN  RAMLINK             ; RAM HOOK
E6FA  27 09                      BEQ   LE705               ; BRANCH IF FIRST ARGUMENT NOT GIVEN
E6FC  8D 10                      BSR   LE70E               ; EVALUATE EXPRESSION, SYNTAX CHECK FOR EXPRESSION > 16
E6FE  F7 FE 0A                   STB   H.FCOLOR            ; SAVE THE NEW FORGROUND COLOR
E701  9D A5                      JSR   GETCCH              ; GET BASIC'S CURRENT INPUT CHARACTER
E703  27 08                      BEQ   LE70D               ; BRANCH IF END OF LINE, NO BACKGROUND COLOR GIVEN
E705  BD B2 6D          LE705    JSR   SYNCOMMA            ; DO A SYNTAX CHECK FOR A COMMA
E708  8D 04                      BSR   LE70E               ; EVALUATE EXPRESSION, SYNTAX CHECK FOR EXPRESSION > 16
E70A  F7 FE 0B                   STB   H.BCOLOR            ; SAVE THE NEW BACKGROUND COLOR
E70D  39                LE70D    RTS

E70E  BD B7 0B          LE70E    JSR   EVALEXPB            ; EVALUATE EXPRESSION, RETURN VALUE IN ACCB
E711  C1 10             LE711    CMPB  #16                 ; MAXIMUM OF 16 DIFFERENT COLORS
E713  10 24 CD 33                LBCC  ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR
E717  39                         RTS

E718  BD E7 31          LE718    JSR   LE731               ; SET THE WORKING COLOR AND ALL PIXEL BYTES TO DEFAULT VALUES
E71B  9D A5                      JSR   GETCCH              ; GET BASIC'S CURRENT INPUT CHARACTER
E71D  27 10                      BEQ   LE72F               ; BRANCH IF END OF LINE
E71F  81 29                      CMPA  #')'                ; SYNTAX CHECK FOR ')'
E721  27 0C                      BEQ   LE72F               ; EXIT IF ')'
E723  BD B2 6D                   JSR   SYNCOMMA            ; DO A SYNTAX CHECK FOR A COMMA
E726  81 2C                      CMPA  #','                ; SYNTAX CHECK FOR A COMMA
E728  27 05                      BEQ   LE72F               ; USE DEFAULT COLORS IF TWO COMMAS
E72A  BD E7 0E                   JSR   LE70E               ; EVALUATE COLOR ARGUMENT
E72D  8D 0C                      BSR   LE73B               ; SET THE WORKING AND ALL COLOR BYTES TO THE COLOR ARGUMENT
E72F  0E A5             LE72F    JMP   GETCCH              ; GET BASIC'S CURRENT INPUT CHARACTER AND RETURN

E731  F6 FE 0A          LE731    LDB   H.FCOLOR            ; GET THE FOREGOUND COLOR
E734  0D C2                      TST   SETFLG              ; TEST THE HSET/HRESET FLAG
E736  26 03                      BNE   LE73B               ; BRANCH IF HSET
E738  F6 FE 0B                   LDB   H.BCOLOR            ; GET THE BACKGROUND COLOR IF HRESET
E73B  D7 B4             LE73B    STB   WCOLOR              ; SAVE THE NEW WORKING COLOR
E73D  8D 03                      BSR   PIXELFIL            ; FILL ALL PIXELS IN A BYTE WITH THE WORKING COLOR
E73F  D7 B5                      STB   ALLCOL              ; SAVE THE FILLED WITH WORKING COLOR BYTE
E741  39                         RTS

* FILL ACCB WITH PIXELS OF THE COLOR CONTAINED IN ACCB
E742  34 10             PIXELFIL PSHS  X
E744  96 E6                      LDA   HRMODE              ; GET THE HI-RES GRAPHICS MODE
E746  80 01                      SUBA  #$01                ; CONVERT 1-4 TO 0-3
E748  8E E7 59                   LDX   #LE759              ; POINT TO THE TABLE OF PIXEL MASKS
E74B  E4 86                      ANDB  A,X                 ; KEEP ONLY ONE PIXEL'S WORTH OF COLOR INFORMATION
E74D  96 E6                      LDA   HRMODE              ; * BOTH OF THESE INSTRUCTIONS
E74F  80 01                      SUBA  #$01                ; * ARE SUPERFLUOUS
E751  8E E7 5D                   LDX   #LE75D              ; POINT TO THE TABLE OF MULTIPLIERS
E754  A6 86                      LDA   A,X                 ; GET THE APPROPRIATE MULTIPLIER
E756  3D                         MUL                       ; NOW THE COLOR INFORMATION IS IN EVERY PIXEL IN THE BYTE
E757  35 90                      PULS  X,PC

* PIXEL MASKS FOR THE HI-RES GRAPHICS MODES
E759  03 0F 01 03       LE759    FCB   $03,$0F,$01,$03

* MULTIPLIERS TO SPREAD HI-RES PIXELS THROUGH AN ENTIRE BYTE
E75D  55 11 FF 55       LE75D    FCB   $55,$11,$FF,$55

* HSET
E761  86 01             HSET     LDA   #$01                ; HSET FLAG
E763  20 05                      BRA   LE76A

* HRESET
E765  4F                HRESET   CLRA                      ; HRESET FLAG
E766  10 21 18 96                LBRN  RAMLINK
E76A  0D E6             LE76A    TST   HRMODE              ; IS THE HI-RES GRAPHICS MODE ENABLED?
E76C  27 81                      BEQ   LE6EF               ; HR' ERROR IF HI-RES MODE NOT ENABLED
E76E  97 C2                      STA   SETFLG              ; SAVE THE HSET/HRESET FLAG
E770  BD B2 6A                   JSR   LB26A               ; SYNTAX CHECK FOR '('
E773  BD E7 AA                   JSR   LE7AA               ; EVALUATE TWO EXPRESSIONS
E776  0D C2                      TST   SETFLG              ; CHECK THE HSER/HRESET FLAG
E778  26 05                      BNE   LE77F               ; BRANCH IF HSET
E77A  BD E7 31                   JSR   LE731               ; SET THE WORKING COLOR AND ALL PIXEL BYTE
E77D  20 03                      BRA   LE782
E77F  BD E7 18          LE77F    JSR   LE718               ; GET THE HSET COLOR
E782  BD B2 67          LE782    JSR   LB267               ; SYNTAX CHECK FOR ')'
E785  BD E7 DA                   JSR   HCALPOS             ; LOAD X WITH PIXEL BYTE ADDRESS; ACCA WITH PIXEL MASK
E788  BD E1 19          LE788    JSR   SELTASK1            ; MAKE TASK REGISTER 1 THE ACTIVE TASK REGISTER
E78B  BD E7 92                   JSR   LE792               ; SET OR RESET A PIXEL
E78E  BD E0 FF                   JSR   SELTASK0            ; RESET TASK REGISTER 0 TO BE THE ACTIVE TASK REGISTER
E791  39                         RTS

* HSET/HRESET A PIXEL; ENTER W/X POINTING TO THE BYTE CONTAINING THE PIXEL AND
* ACCA POINTING TO THE MASK FOR THE PROPER PIXEL
E792  E6 84             LE792    LDB   ,X                  ; GET THE BYTE WHICH CONTAINS THE PIXEL
E794  34 04                      PSHS  B                   ; AND SAVE IT ON THE STACK
E796  1F 89                      TFR   A,B                 ; COPY THE MASK TO ACCB
E798  43                         COMA                      ; INVERT THE MASK
E799  A4 84                      ANDA  ,X                  ; ERASE OLD PIXEL DATA
E79B  D4 B5                      ANDB  ALLCOL              ; FORCE THE PIXEL MASK TO BE THE CORRECT COLOR
E79D  34 04                      PSHS  B                   ; AND SAVE THE 'COLORED' DATA ON THE STACK
E79F  AA E0                      ORA   ,S+                 ; REPLACE THE 'ERASED' PIXEL WITH THE NEW COLOR DATA
E7A1  A7 84                      STA   ,X                  ; AND SAVE IT IN THE SCREEN MEMORY
E7A3  A0 E0                      SUBA  ,S+                 ; ACCA=0 IF OLD AND NEW PIXELS WERE IDENTICAL
E7A5  9A DB                      ORA   CHGFLG              ; SET CHGFLG <> 0 IF THE PIXEL WAS CHANGED
E7A7  97 DB                      STA   CHGFLG              ; SAVE THE 'CHANGED' STATUS
E7A9  39                         RTS
E7AA  BD E7 B2          LE7AA    JSR   LE7B2               ; EVALUATE TWO EXPRESSIONS
E7AD  CE 00 BD          LE7AD    LDU   #HORBEG             ; POINT U TO EVALUATED COORDINATES' STORAGE LOCATIONS
* THE 'NORMALIZATION' ($9320) ROUTINE FROM EXTENDED BASIC WENT HERE - IT IS NOT NEEDED
* IN ENHANCED BASIC SO IT WAS REPLACED WITH AN RTS.
E7B0  39                LE7B0    RTS
E7B1  39                         RTS                       ; WASTED BYTE

* EVALUATE TWO EXPRESSIONS - NORMALLY A HORIZONTAL AND VERTICAL COORDINATE
* PERFORM COORDINATE SYNTAX RANGE CHECKS ON THE EXPRESSIONS
E7B2  BD B7 34          LE7B2    JSR   LB734               ; EVALUATE TWO EXPRESSIONS; RETURN 1ST VALUE IN BINVAL, SECOND IN ACCB
E7B5  10 8E 00 BD                LDY   #HORBEG             ; POINT TO THE COORDINATE STORAGE VARIABLES
E7B9  C1 C0             LE7B9    CMPB  #192                ; CHECK FOR MAXIMUM VERTICAL COORDINATE
E7BB  25 02                      BCS   LE7BF               ; BRANCH IF WITHIN RANGE
E7BD  C6 BF                      LDB   #192-1              ; FORCE TO MAXIMUM VALUE IF OUT OF RANGE
E7BF  4F                LE7BF    CLRA                      ; CLEAR THE MOST SIGNIFICANT BYTE OF ACCD
E7C0  ED 22                      STD   $02,Y               ; SAVE THE VERTICAL COORDINATE
E7C2  96 E6                      LDA   HRMODE              ; GET THE HI-RES GRAPHICS MODE
E7C4  81 02                      CMPA  #$02                ; IS MAXIMUM PIXEL WIDTH=320?
E7C6  2E 05                      BGT   LE7CD               ; NO
E7C8  CC 01 3F                   LDD   #320-1              ; LOAD ACCD WITH MAXIMUM HORIZONTAL COORDINATE FORE 320 PIXEL WIDE
E7CB  20 03                      BRA   LE7D0               ; DO THE HORIZONTAL RANGE CHECK
E7CD  CC 02 7F          LE7CD    LDD   #640-1              ; LOAD ACCD WITH MAXIMUM HORIZONTAL COORDINATE FORE 640 PIXEL WIDE
E7D0  10 93 2B          LE7D0    CMPD  BINVAL              ; IS THE HORIZONTAL COORDINATE > MAXIMUM VALUE?
E7D3  25 02                      BCS   LE7D7               ; YES, USE THE MAXIMUM HORIZONTAL COORDINATE
E7D5  DC 2B                      LDD   BINVAL              ; GET THE NEW HORIZONTAL COORDINATE
E7D7  ED A4             LE7D7    STD   ,Y                  ; SAVE THE HORIZONTAL COORDINATE
E7D9  39                         RTS

* THIS ROUTINE WILL CONVERT THE X,Y COORDINATES OF A PIXEL INTO THE SCREEN ADDRESS (X REG) AND
* PIXEL OFFSET (ACCA) OF THE BYTE ON THE SCREEN CONTAINING THE PIXEL.
E7DA  8D 0A             HCALPOS  BSR   LE7E6               ; POINT U TO THE HCALPOS SUBROUTINE FOR THE CURRENT HRMODE
E7DC  6E C4                      JMP   ,U                  ; EXECUTE THE HCALPOS SUBROUTINE

* CALTABLE
E7DE  E8 20 E8 3F E7 FF CALTABLE FDB   G2BITBIX,G4BITPIX,G1BITPIX
E7E4  E8 20                      FDB   G2BITBIX

* POINT U TO THE PROPER CALPOS SUBROUTINE
E7E6  CE E7 DE          LE7E6    LDU   #CALTABLE           ; POINT U TO THE CALPOS ADDRESS TABLE
E7E9  96 E6                      LDA   HRMODE              ; GET THE HI-RS GRAPHICS MODE
E7EB  80 01                      SUBA  #$01                ; (DECA WOULD DO) CONVERT FROM 1-4 TO 0-3
E7ED  48                         ALSA                      ; X2 BYTES PER ADDRESS
E7EE  EE C6                      LDU   A,U                 ; GET THE APPROPRIATE CALPOS ADDRESS FROM THE TABLE
E7F0  39                         RTS

* TABLE OF 1 BIT PIXEL MASKS
E7F1  80 40 20 10 08 04 PIX1MASK FCB   $80,$40,$20,$10,$08,$04
E7F7  02 01                      FCB   $02,$01

* TABLE OF 2 BIT PIXEL MASKS
E7F9  C0 30 0C 03       PIX2MASK FCB   $C0,$30,$0C,$03

* TABLE OF 4 BIT PIXEL MASKS
E7FD  F0 0F             PIX4MASK FCB   $F0,$0F

**************

* CONVERT HORIZONTAL, VERTICAL COORDINATES INTO THE ADDRESS (X) FOR THE BYTE WHICH CONTAINS THE DESIRED
* PIXEL AND A MASK (ACCA) WHICH HAS ONLY THOSE BITS WHICH CORRESPOND TO THE DESIRED PIXEL

E7FF  34 44             G1BITPIX PSHS  U,B                 ; SAVE REGISTERS
E801  D6 B9                      LDB   HORBYT              ; GET THE NUMBER OF BYTES PER HORIZONTAL ROW
E803  96 C0                      LDA   VERBEG+1            ; GET THE VERTICAL COORDINATE
E805  3D                         MUL                       ; NOW ACCD CONTAINS THE ROW OFFSET IN BYTES FROM THE TOP OF SCREEN
E806  C3 20 00                   ADDD  #HRESSCRN           ; ADD THE ROW OFFSET TO THE START OF THE SCREEN
E809  1F 01                      TFR   D,X                 ; X CONTAINS THE ADDRESS OF THE START OF THE ROW CONTAINING A PIXEL
E80B  DC BD                      LDD   HORBEG              ; GET THE HORIZONTAL COORDINATE
E80D  44                         LSRA
E80E  56                         RORB
E80F  44                         LSRA
E810  56                         RORB
E811  44                         LSRA                      ; * DIVIDE HORIZONTAL COORDINATE BY EIGHT - THERE ARE 8 PIXELS PER BYTE
E812  56                         RORB                      ; * ACCD CONTAINS THE COLUMN OFFSET TO THE PIXEL IN BYTES
E813  30 8B                      LEAX  D,X                 ; ADD THE COLUMN OFFSET - X POINTS TO THE BYTE CONTAINING THE PIXEL
E815  96 BE                      LDA   HORBEG+1            ; GET THE LEAST SIGNIFICANT BYTE OF THE HORIZONTAL COORDINATE
E817  84 07                      ANDA  #$07                ; KEEP BITS 0-2 WHICH ARE THE PIXEL POSITION IN THE BYTE
E819  CE E7 F1                   LDU   #PIX1MASK           ; POINT TO THE TABLE OF TWO COLOR PIXEL MASKS
E81C  A6 C6                      LDA   A,U                 ; GET THE CORRECT PIXEL MASK
E81E  35 C4                      PULS  B,U,PC              ; RESTORE THE REGISTERS
