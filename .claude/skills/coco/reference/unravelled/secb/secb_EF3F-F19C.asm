; Super Extended Color BASIC 2.0 (CoCo 3) -- $EF3F-$F19C
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: HPRINT=$EF3F

* HPRINT
EF3F  0D E6             HPRINT   TST   HRMODE              ; CHECK THE HI-RES GRAPHICS MODE
EF41  10 27 F7 AA                LBEQ  LE6EF               ; 'HR' ERROR IF NOT HI-RES GRAPHICS MODE
EF45  10 21 10 B7                LBRN  RAMLINK             ; RAM HOOK
EF49  BD B2 6A                   JSR   LB26A               ; SYNTAX CHECK FOR '('
EF4C  BD E7 B2                   JSR   LE7B2               ; EVALUATE HORIZONTAL AND VERTICAL COORDINATE
EF4F  BD B2 67                   JSR   LB267               ; SYNTAX CHECK FOR ')'
EF52  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CECK FOR COMMA
EF55  BD B1 56                   JSR   LB156               ; EVALUATE EXPRESSION
EF58  0D 06                      TST   VALTYP              ; CHECK THE TYPE OF VARIABLE EVALUATED
EF5A  26 06                      BNE   LEF62               ; BRANCH IF NOT NUMERIC - REALLY SHOULD BE BMI
EF5C  BD BD D9                   JSR   LBDD9               ; CONVERT FLOATING POINT NUMBER INTO A STRING
EF5F  BD B5 16                   JSR   LB516               ; SAVE THE STRING IN STRING SPACE
EF62  BD B6 57          LEF62    JSR   LB657               ; CALCULATE THE LENGTH AND ADDRESS OF THE STRING
EF65  F7 FE 18                   STB   H.PCOUNT            ; SAVE THE LENGTH OF THE STRING
EF68  10 8E FE 19                LDY   #H.PBUF             ; POINT TO THE HPRINT BUFFER
EF6C  5A                LEF6C    DECB                      ; DECREMENT THE CHARACTER COUNT
EF6D  2B 06                      BMI   LEF75               ; BRANCH IF ALL CHARACTERS PRINTED
EF6F  A6 80                      LDA   ,X+                 ; GET A CHARACTER FROM THE STRING
EF71  A7 A0                      STA   ,Y+                 ; SAVE IT IN THE HPRINT BUFFER
EF73  20 F7                      BRA   LEF6C               ; KEEP GOING UNTIL DONE
EF75  96 E6             LEF75    LDA   HRMODE              ; GET THE HI-RES GRAPHICS MODE
EF77  C6 28                      LDB   #40                 ; 40 CHARACTERS MAX IN THE 320 PIXEL WIDE MODE
EF79  81 03                      CMPA  #$03                ; CHECK THE HSCREEN MODE
EF7B  25 02                      BCS   LEF7F               ; BRANCH IF 40 COLUMN RESOLUTION
EF7D  C6 50                      LDB   #80                 ; 80 CHARACTERS MAX IN THE 640 PIXEL WIDE MODE
EF7F  4F                LEF7F    CLRA                      ; CLEAR THE MOST SIGNIFICANT BYTE OF ACCD
EF80  93 BD                      SUBD  HORBEG              ; SUBTRACT THE HORIZONTAL PRINT POSITION
EF82  2B 7D                      BMI   LF001               ; EXIT IF HORIZONTAL PRINT POSITION > LINE LENGTH
EF84  F1 FE 18                   CMPB  H.PCOUNT            ; IS THE PRINT CHARACTER COUNT > LINE LENGTH?
EF87  22 05                      BHI   LEF8E               ; BRANCH IF NOT
EF89  F7 FE 18                   STB   H.PCOUNT            ; FORCE THE PRINT CHARACTER COUNT TO EQUAL THE LINE LENGTH
EF8C  27 73                      BEQ   LF001               ; EXIT IF LINE LENGTH = 0
EF8E  86 17             LEF8E    LDA   #ROWMAX-1           ; GET THE HIGHEST POSSIBLE ROW NUMBER
EF90  91 C0                      CMPA  VERBEG+1            ; AND COMPARE IT TO THE PRINT ROW
EF92  2C 02                      BGE   LEF96               ; BRANCH IF PRINTING ON A LEGAL ROW NUMBER
EF94  97 C0                      STA   VERBEG+1            ; PRINT ON BOTTOM ROW (HIGHEST NUMBER) IF ILLEGAL ROW SPECIFIED
EF96  BD F0 8C          LEF96    JSR   LF08C               ; ADJUST ROW AND COLUMN NUMBERS FOR PRINTING ON HI-RES SCREEN
EF99  BD E7 DA                   JSR   HCALPOS             ; POINT X TO THE SCREEN ADDRESS; ACCA = PIXEL MASK
EF9C  10 8E FE 19                LDY   #H.PBUF             ; POINT TO THE HPRINT BUFFER
EFA0  F6 FE 18                   LDB   H.PCOUNT            ; GET THE NUMBER OF CHARACTERS IN THE PRINT BUFFER
EFA3  A6 A4             LEFA3    LDA   ,Y                  ; GET A CHARACTER FROM THE PRINT BUFFER
EFA5  84 7F                      ANDA  #$7F                ; MASK OFF THE GRAPHICS BIT (BIT 7)
EFA7  80 20                      SUBA  #$20                ; SUBTRACT OUT THE CONTROL CODES
EFA9  2A 02                      BPL   LEFAD               ; BRANCH IF IT WAS NOT A CONTROL CODE
EFAB  86 00                      LDA   #$00                ; FORCE A CONTROL CODE TO PRINT A BLANK
EFAD  A7 A0             LEFAD    STA   ,Y+                 ; PUT THE 'MASSAGED' CHARACTER BACK INTO THE BUFFER
EFAF  5A                         DECB                      ; BUMP CHARACTER DOWN ONE
EFB0  2E F1                      BGT   LEFA3               ; LOOP UNTIL ALL CHARACTERS DONE
EFB2  96 E6                      LDA   HRMODE              ; GET THE HI-RES GRAPHICS MODE
EFB4  4A                         DECA                      ; CONVERT 1-4 TO 0-3
EFB5  48                         ALSA                      ; MULTIPLY BY TWO - THE LOOKUP TABLE HAS TWO BYTES/ENTRY
EFB6  10 8E F0 02                LDY   #LF002              ; POINT TO THE CHARACTER PRINT ROUTINE ADDRESS TABLE
EFBA  10 AE A6                   LDY   A,Y                 ; GET THE ADDRESS OF THE CHARACTER PRINT ROUTINE
EFBD  10 9F D1                   STY   VD1                 ; AND SAVE IT IN VD1

* THIS SECTION OF CODE WILL PRINT THE BUFFER TO THE HI-RES SCREEN
EFC0  86 08                      LDA   #$08                ; 8 ROWS PER HI-RES CHARACTER
EFC2  97 D3                      STA   VD3                 ; TEMP SAVE THE ROW COUNTER
EFC4  10 8E FE 19                LDY   #H.PBUF             ; POINT TO THE PRINT BUFFER
EFC8  CE F0 9D                   LDU   #LF09D              ; POINT TO THE HI-RES CHARACTER GENERATOR 'ROM'
EFCB  F6 FE 0A                   LDB   H.FCOLOR            ; GET THE FOREGROUND COLOR
EFCE  BD E7 42                   JSR   PIXELFIL            ; FILL ACCB WITH ALL FOREGROUND COLOR PIXELS
EFD1  D7 B5                      STB   ALLCOL              ; SAVE THE PIXEL-FILLED BYTE
EFD3  BD E1 19                   JSR   SELTASK1            ; SWITCH IN TASK REGISTER 1
EFD6  B6 FE 18                   LDA   H.PCOUNT            ; GET THE CHARACTER COUNT
EFD9  34 32             LEFD9    PSHS  Y,X,A
EFDB  E6 A0             LEFDB    LDB   ,Y+                 ; GET A CHARACTER FROM THE PRINT BUFFER
EFDD  4F                         CLRA                      ; CLEAR THE MOST SIGNIFICANT BYTE OF ACCD
EFDE  58                         ALSB
EFDF  58                         ALSB
EFE0  49                         ROLA
EFE1  58                         ALSB
EFE2  49                         ROLA                      ; MULTIPLY ACCD BY 8 - 8 BYTES PER CHARACTER
EFE3  A6 CB                      LDA   D,U                 ; GET THE FIRST BYTE OF THE GRAPHIC CHARACTER FROM THE 'ROM'
EFE5  AD 9F 00 D1                JSR   [VD1]               ; PUT THE BYTE ON THE HI-RES SCREEN
EFE9  7A FE 18                   DEC   H.PCOUNT            ; DECREMENT CHARACTER COUNT
EFEC  2E ED                      BGT   LEFDB               ; KEEP GOING UNTIL ALL CHARACTERS DONE
EFEE  35 32                      PULS  A,X,Y               ; RESTORE THE PRINT BUFFER POINTER, 'ROM' POINTER & CHAR COUNT
EFF0  0A D3                      DEC   VD3                 ; BUMP THE ROW COUNTER DOWN ONE
EFF2  27 0A                      BEQ   LEFFE               ; BRANCH IF ALL ROWS DONE
EFF4  B7 FE 18                   STA   H.PCOUNT            ; RESET THE CHARACTER COUNT
EFF7  33 41                      LEAU  $01,U               ; ADJUST THE 'ROM' POINTER DOWN ONE ROW
EFF9  BD EA 45                   JSR   LEA45               ; MOVE X DONW ONE HI-RES ROW
EFFC  20 DB                      BRA   LEFD9               ; KEEP LOOPING UNTIL THE WHOLE ROW IS DONE
EFFE  BD E0 FF          LEFFE    JSR   SELTASK0            ; MAKE TASK REGISTER 0 ACTIVE
F001  39                LF001    RTS

* TABLE OF ADDRESSES OF HI-RES PRINT DRIVERS
F002  F0 1A             LF002    FDB   LF01A               ; MODE 1
F004  F0 45             LF004    FDB   LF045               ; MODE 2
F006  F0 0A             LF006    FDB   LF00A               ; MODE 3
F008  F0 1A             LF008    FDB   LF01A               ; MODE 4

* MODE 3 PRINT DRIVER
F00A  34 02             LF00A    PSHS  A                   ; SAVE THE CHARACTER MASK
F00C  43                         COMA                      ; INVERT THE MASK
F00D  A4 84                      ANDA  ,X                  ; 'AMD' IT WITH THE SCREEN DATA - CREATE A HOLE FOR THE CHARACTER
F00F  A7 84                      STA   ,X                  ; DATA AND THEN PUT IT BACK ON THE SCREEN
F011  35 02                      PULS  A                   ; GET THE CHARACTER MASK BACK
F013  94 B5                      ANDA  ALLCOL              ; 'AND' IT WITH THE PIXEL COLOR BYTE - 'COLOR' THE DATA
F015  AA 84                      ORA   ,X                  ; 'OR' IT WITH THE SCREEN DATA - FILL THE 'HOLE' CREATED ABOVE
F017  A7 80                      STA   ,X+                 ; WITH THE 'COLORED' CHARACTER DATA AND PUT THE DATA ON THE SCREEN
F019  39                         RTS

* MODES 1,4 PRINT DRIVER
F01A  34 20             LF01A    PSHS  Y                   ; SAVE THE PRINT BUFFER POINTER
F01C  10 8E F0 35                LDY   #LF035              ; POINT TO THE TABLE OF 4 COLOR PIXEL MASKS
F020  1F 89                      TFR   A,B                 ; COPY CHARACTER DATA TO ACCB
F022  44                         LSRA
F023  44                         LSRA
F024  44                         LSRA
F025  44                         LSRA                      ; SHIFT THE HIGH ORDER NIBBLE TO THE LOW ORDER NIBBLE
F026  A6 A6                      LDA   A,Y                 ; GET THE PIXEL MASK FOR THE HIGH NIBBLE
F028  BD F0 0A                   JSR   LF00A               ; DISPLAY THE HIGH ORDER NIBBLE DATA ON THE SCREEN
F02B  C4 0F                      ANDB  #$0F                ; MASK OFF THE HIGH ORDER NIBBLE
F02D  A6 A5                      LDA   B,Y                 ; GET THE PIXEL MASK FOR THE LOW NIBBLE
F02F  BD F0 0A                   JSR   LF00A               ; DISPLAY THE LOW ORDER NIBBLE DATA ON THE SCREEN
F032  35 20                      PULS  Y                   ; RESTORE THE PRINT BUFFER POINTER
F034  39                         RTS

* FOUR COLOR PIXEL MASKS
F035  00 03 0C 0F 30 33 LF035    FCB   $00,$03,$0C,$0F,$30,$33 ; 4 COLOR PIXEL MASKS
F03B  3C 3F C0 C3 CC CF          FCB   $3C,$3F,$C0,$C3,$CC,$CF
F041  F0 F3 FC FF                FCB   $F0,$F3,$FC,$FF

* MODE 2 PRINT DRIVER
F045  34 22             LF045    PSHS  Y,A                 ; SAVE THE PRINT BUFFER POINTER AND THE CHARACTER DATA
F047  10 8E F0 6C                LDY   #LF06C              ; POINT TO THE TABLE OF 16 COLOR MASKS
F04B  44                         LSRA
F04C  44                         LSRA
F04D  44                         LSRA
F04E  44                         LSRA                      ; SHIFT THE HIGH ORDER PIXEL TO BITS 0-3
F04F  48                         ALSA                      ; MULTIPLY BY 2, THERE ARE 2 BYTES PER TABLE ENTRY
F050  EC A6                      LDD   A,Y                 ; GET THE FIRST FOUR PIXEL MASKS FROM THE TABLE
F052  BD F0 0A                   JSR   LF00A               ; DISPLAY THE FIRST TWO PIXELS
F055  1F 98                      TFR   B,A                 ; PUT THE NEXT TWO PIXELS' DATA INTO ACCA
F057  BD F0 0A                   JSR   LF00A               ; DISPLAY THE NEXT TWO PIXELS
F05A  35 02                      PULS  A                   ; GET THE CHARACTER DATA BACK
F05C  84 0F                      ANDA  #$0F                ; MASK OFF THE HIGH NIBBLE
F05E  48                         ALSA                      ; MULTIPLY BY 2, THERE ARE 2 BYTES PER TABLE ENTRY
F05F  EC A6                      LDD   A,Y                 ; GET THE LAST FOUR PIXEL MASKS FROM THE TABLE
F061  BD F0 0A                   JSR   LF00A               ; DISPLAY THE NEXT TWO PIXELS
F064  1F 98                      TFR   B,A                 ; PUT THE NEXT TWO PIXELS' DATA INTO ACCA
F066  BD F0 0A                   JSR   LF00A               ; DISPLAY THE LAST TWO PIXELS
F069  35 20                      PULS  Y                   ; RESTORE THE PRINT BUFFER POINTER
F06B  39                         RTS                       ; WASTED; THIS AND ABOVE INSTRUCTION SHOULD BE PULS Y,PC

* 16 COLOR PIXEL MASKS - DOUBLE BYTE WIDE
F06C  00 00 00 0F 00 F0 LF06C    FDB   $0000,$000F,$00F0
F072  00 FF 0F 00 0F 0F          FDB   $00FF,$0F00,$0F0F
F078  0F F0 0F FF F0 00          FDB   $0FF0,$0FFF,$F000
F07E  F0 0F F0 F0 F0 FF          FDB   $F00F,$F0F0,$F0FF
F084  FF 00 FF 0F FF F0          FDB   $FF00,$FF0F,$FFF0
F08A  FF FF                      FDB   $FFFF

* CONVERT THE PRINT POSITION FROM CHARACTER ROWS AND COLUMNS TO PIXEL ROWS
* AND COLUMNS; EACH CHARACTER IS 8 PIXELS WIDE AND 8 PIXELS DEEP.
F08C  DC BD             LF08C    LDD   HORBEG              ; GET THE PRINT COLUMN POSITION
F08E  58                         ALSB
F08F  58                         ALSB
F090  49                         ROLA
F091  58                         ALSB
F092  49                         ROLA                      ; SHIFT ACCD LEFT THREE TIMES; MULTIPLY COLUMN POSITION BY EIGHT
F093  DD BD                      STD   HORBEG              ; SAVE NEW COLUMN POSITION IN TERMS OF PIXELS (8 PIXELS/CHARACTER)
F095  96 C0                      LDA   VERBEG+1            ; GET THE PRINT ROW NUMBER
F097  48                         ALSA
F098  48                         ALSA
F099  48                         ALSA                      ; SHIFT ACCA LEFT THREE TIMES; MULTIPLY ROW POSITION BY EIGHT
F09A  97 C0                      STA   VERBEG+1            ; SAVE NEW ROW POSITION IN TERMS OF PIXELS (8 PIXELS/CHARACTER)
F09C  39                         RTS

* HI-RES CHARACTER GENERATOR 'ROM'
* SPECIAL CHARACTERS AND NUMBERS
F09D  00 00 00 00 00 00 LF09D    FCB   $00,$00,$00,$00,$00,$00 ; BLANK
F0A3  00 00                      FCB   $00,$00
F0A5  10 10 10 10 10 00 LF0A5    FCB   $10,$10,$10,$10,$10,$00 ; !
F0AB  10 00                      FCB   $10,$00
F0AD  28 28 28 00 00 00 LF0AD    FCB   $28,$28,$28,$00,$00,$00 ; "
F0B3  00 00                      FCB   $00,$00
F0B5  28 28 7C 28 7C 28 LF0B5    FCB   $28,$28,$7C,$28,$7C,$28 ; #
F0BB  28 00                      FCB   $28,$00
F0BD  10 3C 50 38 14 78 LF0BD    FCB   $10,$3C,$50,$38,$14,$78 ; $
F0C3  10 00                      FCB   $10,$00
F0C5  60 64 08 10 20 4C LF0C5    FCB   $60,$64,$08,$10,$20,$4C ; %
F0CB  0C 00                      FCB   $0C,$00
F0CD  20 50 50 20 54 48 LF0CD    FCB   $20,$50,$50,$20,$54,$48 ; &
F0D3  34 00                      FCB   $34,$00
F0D5  10 10 20 00 00 00 LF0D5    FCB   $10,$10,$20,$00,$00,$00 ; '
F0DB  00 00                      FCB   $00,$00
F0DD  08 10 20 20 20 10 LF0DD    FCB   $08,$10,$20,$20,$20,$10 ; (
F0E3  08 00                      FCB   $08,$00
F0E5  20 10 08 08 08 10 LF0E5    FCB   $20,$10,$08,$08,$08,$10 ; )
F0EB  20 00                      FCB   $20,$00
F0ED  00 10 54 38 38 54 LF0ED    FCB   $00,$10,$54,$38,$38,$54 ; *
F0F3  10 00                      FCB   $10,$00
F0F5  00 10 10 7C 10 10 LF0F5    FCB   $00,$10,$10,$7C,$10,$10 ; +
F0FB  00 00                      FCB   $00,$00
F0FD  00 00 00 00 00 10 LF0FD    FCB   $00,$00,$00,$00,$00,$10 ; ,
F103  10 20                      FCB   $10,$20
F105  00 00 00 7C 00 00 LF105    FCB   $00,$00,$00,$7C,$00,$00 ; -
F10B  00 00                      FCB   $00,$00
F10D  00 00 00 00 00 00 LF10D    FCB   $00,$00,$00,$00,$00,$00 ; .
F113  10 00                      FCB   $10,$00
F115  00 04 08 10 20 40 LF115    FCB   $00,$04,$08,$10,$20,$40 ; /
F11B  00 00                      FCB   $00,$00
F11D  38 44 4C 54 64 44 LF11D    FCB   $38,$44,$4C,$54,$64,$44 ; 0
F123  38 00                      FCB   $38,$00
F125  10 30 10 10 10 10 LF125    FCB   $10,$30,$10,$10,$10,$10 ; 1
F12B  38 00                      FCB   $38,$00
F12D  38 44 04 38 40 40 LF12D    FCB   $38,$44,$04,$38,$40,$40 ; 2
F133  7C 00                      FCB   $7C,$00
F135  38 44 04 08 04 44 LF135    FCB   $38,$44,$04,$08,$04,$44 ; 3
F13B  38 00                      FCB   $38,$00
F13D  08 18 28 48 7C 08 LF13D    FCB   $08,$18,$28,$48,$7C,$08 ; 4
F143  08 00                      FCB   $08,$00
F145  7C 40 78 04 04 44 LF145    FCB   $7C,$40,$78,$04,$04,$44 ; 5
F14B  38 00                      FCB   $38,$00
F14D  38 40 40 78 44 44 LF14D    FCB   $38,$40,$40,$78,$44,$44 ; 6
F153  38 00                      FCB   $38,$00
F155  7C 04 08 10 20 40 LF155    FCB   $7C,$04,$08,$10,$20,$40 ; 7
F15B  40 00                      FCB   $40,$00
F15D  38 44 44 38 44 44 LF15D    FCB   $38,$44,$44,$38,$44,$44 ; 8
F163  38 00                      FCB   $38,$00
F165  38 44 44 38 04 04 LF165    FCB   $38,$44,$44,$38,$04,$04 ; 9
F16B  38 00                      FCB   $38,$00
F16D  00 00 10 00 00 10 LF16D    FCB   $00,$00,$10,$00,$00,$10 ; :
F173  00 00                      FCB   $00,$00
F175  00 00 10 00 00 10 LF175    FCB   $00,$00,$10,$00,$00,$10 ; ;
F17B  10 20                      FCB   $10,$20
F17D  08 10 20 40 20 10 LF17D    FCB   $08,$10,$20,$40,$20,$10 ; >
F183  08 00                      FCB   $08,$00
F185  00 00 7C 00 7C 00 LF185    FCB   $00,$00,$7C,$00,$7C,$00 ; =
F18B  00 00                      FCB   $00,$00
F18D  20 10 08 04 08 10 LF18D    FCB   $20,$10,$08,$04,$08,$10 ; <
F193  20 00                      FCB   $20,$00
F195  38 44 04 08 10 00 LF195    FCB   $38,$44,$04,$08,$10,$00 ; ?
F19B  10 00                      FCB   $10,$00
