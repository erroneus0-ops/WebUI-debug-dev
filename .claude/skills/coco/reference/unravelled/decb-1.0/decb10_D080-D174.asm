; Disk Extended Color BASIC 1.0 -- $D080-$D174
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: FILES=$D080, UNLOAD=$D146

* FILES COMMAND
D080  BD 95 AC          FILES    JSR   L95AC               ; RESET SAM DISPLAY PAGE AND VDG MODE
D083  FC 09 4A                   LDD   FCBADR              ; GET START OF FILE BUFFERS
D086  83 09 89                   SUBD  #DFLBUF             ; SUBTRACT THE START OF RANDOM FILE BUFFER SPACE
D089  34 06                      PSHS  B,A                 ; SAVE DEFAULT VALUE OF RANDOM FILE BUFFER SPACE ON STACK
D08B  F6 09 5B                   LDB   FCBACT              ; * GET CURRENT NUMBER OF FCBS
D08E  34 04                      PSHS  B                   ; * AND SAVE ON THE STACK (DEFAULT VALUE)
D090  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHAR
D092  81 2C                      CMPA  #','                ; CHECK FOR COMMA
D094  27 0F                      BEQ   LD0A5               ; BRANCH IF COMMA - NO BUFFER NUMBER PARAMETER GIVEN
D096  BD B7 0B                   JSR   EVALEXPB            ; EVALUATE EXPRESSION (BUFFER NUMBER)
D099  C1 0F                      CMPB  #15                 ; 15 FCBS MAX
D09B  10 22 E3 AB                LBHI  LB44A               ; BRANCH IF > 15 - 'ILLEGAL FUNCTION CALL'
D09F  E7 E4                      STB   ,S                  ; SAVE NUMBER OF FCBS ON STACK
D0A1  9D A5                      JSR   GETCCH              ; CHECK CURRENT INPUT CHAR
D0A3  27 0B                      BEQ   LD0B0               ; BRANCH IF END OF LINE
D0A5  BD B2 6D          LD0A5    JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
D0A8  BD B3 E6                   JSR   LB3E6               ; EVALUATE EXPRESSION, RETURN VALUE IN ACCD
D0AB  C3 00 01                   ADDD  #$0001              ; ADD ONE BYTE
D0AE  ED 61                      STD   $01,S               ; SAVE RANDOM FILE BUFFER SIZE ON STACK
D0B0  BD CA 3B          LD0B0    JSR   DVEC7               ; CLOSE FILES
D0B3  E6 E4                      LDB   ,S                  ; * GET THE NUMBER OF BUFFERS TO MAKE AND
D0B5  34 04                      PSHS  B                   ; * INITIALIZE A BUFFER COUNTER ON THE STACK
D0B7  CC 09 89                   LDD   #DFLBUF             ; GET START OF RANDOM FILE BUFFERS
D0BA  E3 62                      ADDD  $02,S               ; ADD THE NEWLY SPECIFIED RANDOM FILE BUFFER SPACE
D0BC  25 5D                      BLO   LD11B               ; 'OUT OF MEMORY' ERROR IF > $FFFF
D0BE  ED 62                      STD   $02,S               ; SAVE START OF FCBS
* RESERVE SPACE FOR FCBS
D0C0  C3 01 19          LD0C0    ADDD  #FCBLEN             ; FCBLEN REQUIRED FOR EACH BUFFER
D0C3  25 56                      BLO   LD11B               ; 'OUT OF MEMORY' ERROR IF > $FFFF
D0C5  6A E4                      DEC   ,S                  ; DECREMENT BUFFER COUNTER
D0C7  2A F7                      BPL   LD0C0               ; *BRANCH IF NOT DONE - THE BPL WILL SET UP ONE MORE BUFFER
* *THAN THE NUMBER REQUESTED. THIS EXTRA BUFFER IS THE SYSTEM BUFFER
* *AND IS LOCATED AT THE END OF THE NORMAL FCBS. ONLY SYSTEM ROUTINES
* *(COPY, BACKUP, MERGE ETC.) MAY ACCESS THIS BUFFER.
D0C9  5D                         TSTB                      ; AT AN EXACT 256 BYTE BOUNDARY?
D0CA  27 03                      BEQ   LD0CF               ; YES
D0CC  4C                         INCA                      ; NO - ADD 256
D0CD  27 4C                      BEQ   LD11B               ; 'OUT OF MEMORY' ERROR IF PAST $FFFF
D0CF  A7 E4             LD0CF    STA   ,S                  ; SAVE MS BYTE OF NEW GRAPHIC RAM START
D0D1  DC 1B                      LDD   VARTAB              ; GET START OF VARIABLES
D0D3  90 BC                      SUBA  GRPRAM              ; *SUBTRACT THE OLD GRAPHIC RAM START - ACCD CONTAINS LENGTH
* *OF PROGRAM PLUS RESERVED GRAPHIC RAM
D0D5  AB E4                      ADDA  ,S                  ; ADD IN THE AMOUNT OF RAM CALCULATED ABOVE
D0D7  25 42                      BLO   LD11B               ; 'OUT OF MEMORY' ERROR IF > $FFFF
D0D9  1F 01                      TFR   D,X                 ; SAVE NEW VARTAB IN X
D0DB  4C                         INCA                      ; *ADD 256 - TO GUARANTEE ENOUGH ROOM SINCE ALL CALCULATIONS USE
* *ONLY THE MSB OF THE ADDRESS
D0DC  27 3D                      BEQ   LD11B               ; 'OUT OF MEMORY' ERROR IF PAST $FFFF
D0DE  10 93 21                   CMPD  FRETOP              ; IS IT GREATER THAN THE START OF STRING SPACE
D0E1  24 38                      BHS   LD11B               ; 'OUT OF MEMORY' IF > START OF STRING SPACE
D0E3  4A                         DECA                      ; SUBTRACT 256 - COMPENSATE FOR INCA ABOVE
D0E4  93 1B                      SUBD  VARTAB              ; SUBTRACT START OF VARIABLES
D0E6  D3 19                      ADDD  TXTTAB              ; ADD START OF BASIC
D0E8  1F 02                      TFR   D,Y                 ; Y HAS NEW START OF BASIC
D0EA  A6 E4                      LDA   ,S                  ; * GET THE GRAPHIC RAM START, SUBTRACT
D0EC  90 BC                      SUBA  GRPRAM              ; * THE OLD GRAPHIC RAN START AND SAVE
D0EE  1F 89                      TFR   A,B                 ; * THE DIFFERENCE IN ACCA AND ACCB
D0F0  9B BA                      ADDA  BEGGRP              ; = ADD THE OLD GRAPHIC PAGE START AND
D0F2  97 BA                      STA   BEGGRP              ; = STORE THE NEW START OF GRAPHICS RAM
D0F4  DB B7                      ADDB  ENDGRP              ; * ADD THE OLD GRAPHIC RAM END ADDRESS AND
D0F6  D7 B7                      STB   ENDGRP              ; * STORE THE NEW END OF GRAPHICS RAM
D0F8  35 46                      PULS  A,B,U               ; = ACCA=MSB OF START OF GRAPHIC RAM; ACCB=NUMBER OF FILE BUFFERS
* = U=START OF FILE BUFFERS
D0FA  97 BC                      STA   GRPRAM              ; SAVE NEW START OF GRAPHIC RAM
D0FC  F7 09 5B                   STB   FCBACT              ; NUMBER OF FILE BUFFERS
D0FF  FF 09 4A                   STU   FCBADR              ; START OF FILE BUFFERS
D102  DE 1B             LD102    LDU   VARTAB              ; POINT U TO OLD START OF VARIABLES
D104  9F 1B                      STX   VARTAB              ; SAVE NEW START OF VARIBLES
D106  11 93 1B                   CMPU  VARTAB              ; * COMPARE OLD START OF VARIABLES TO NEW START OF
D109  22 13                      BHI   LD11E               ; * VARIABLES & BRANCH IF OLD > NEW
* MOVE BASIC PROGRAM IF OLD START ADDRESS <= NEW START ADDRESS
D10B  A6 C2             LD10B    LDA   ,-U                 ; GET A BYTE
D10D  A7 82                      STA   ,-X                 ; MOVE lT
D10F  11 93 19                   CMPU  TXTTAB              ; AT START OF BASIC PROGRAM?
D112  26 F7                      BNE   LD10B               ; NO
D114  10 9F 19                   STY   TXTTAB              ; STORE NEW START OF BASIC PROGRAM
D117  6F 3F                      CLR   -1,Y                ; RESET START OF PROGRAM FLAG
D119  20 13                      BRA   LD12E               ; CLOSE ALL FILES
D11B  7E AC 44          LD11B    JMP   LAC44               ; 'OUT OF MEMORY' ERROR
* MOVE BASIC PROGRAM IF OLD START ADDRESS > NEW START ADDRESS
D11E  DE 19             LD11E    LDU   TXTTAB              ; POINT U TO OLD START OF BASIC
D120  10 9F 19                   STY   TXTTAB              ; SAVE NEW START OF BASIC
D123  6F 3F                      CLR   -1,Y                ; RESET START OF BASIC FLAG
D125  A6 C0             LD125    LDA   ,U+                 ; GET A BYTE
D127  A7 A0                      STA   ,Y+                 ; MOVE IT
D129  10 9C 1B                   CMPY  VARTAB              ; AT START OF VARIABLES
D12C  26 F7                      BNE   LD125               ; NO - MOVE ANOTHER BYTE

* CLOSE ALL FCBS AND RECALCULATE FCB START ADDRESSES
D12E  CE 09 28          LD12E    LDU   #FCBV1              ; POINT U TO FILE BUFFER POINTERS
D131  BE 09 4A                   LDX   FCBADR              ; POINT X TO START OF BUFFERS
D134  5F                         CLRB                      ; RESET FILE COUNTER
D135  AF C1             LD135    STX   ,U++                ; STORE FILE ADDRESS IN VECTOR TABLE
D137  6F 00                      CLR   FCBTYP,X            ; RESET FILE TYPE TO CLOSED
D139  30 89 01 19                LEAX  FCBLEN,X            ; GO TO NEXT FCB
D13D  5C                         INCB                      ; INCREMENT FILE COUNTER
D13E  F1 09 5B                   CMPB  FCBACT              ; CLOSE ALL ACTIVE BUFFERS AND SYSTEM FCB
D141  23 F2                      BLS   LD135               ; BRANCH IF NOT DONE
D143  7E 96 CB                   JMP   L96CB               ; READJUST LINE NUMBERS, ETC.

* UNLOAD COMMAND
D146  8D 1A             UNLOAD   BSR   LD162               ; GET DRIVE NUMBER
D148  5F                         CLRB                      ; CLEAR FILE COUNTER
D149  5C                LD149    INCB                      ; INCREMENT FILE COUNTER
D14A  BD C7 19                   JSR   LC719               ; POINT X TO FCB
D14D  27 0D                      BEQ   LD15C               ; BRANCH IF FILE NOT OPEN
D14F  A6 01                      LDA   FCBDRV,X            ; CHECK DRIVE NUMBER
D151  91 EB                      CMPA  DCDRV               ; DOES IT MATCH THE 'UNLOAD' DRIVE NUMBER?
D153  26 07                      BNE   LD15C               ; NO MATCH - DO NOT CLOSE THE FILE
D155  34 04                      PSHS  B                   ; SAVE FILE COUNTER ON THE STACK
D157  BD CA 58                   JSR   LCA58               ; CLOSE FCB
D15A  35 04                      PULS  B                   ; RESTORE FILE COUNTER
D15C  F1 09 5B          LD15C    CMPB  FCBACT              ; CHECKED ALL FILES?
D15F  23 E8                      BLS   LD149               ; NO
D161  39                         RTS
* GET DRIVE NUMBER FROM BASIC - USE THE DEFAULT DRIVE IF NONE GIVEN
D162  F6 09 5A          LD162    LDB   DEFDRV              ; GET DEFAULT DRIVE NUMBER
D165  9D A5                      JSR   GETCCH              ; GET NEXT INPUT CHAR
D167  27 09                      BEQ   LD172               ; USE DEFAULT DRIVE NUMBER IF NONE GIVEN
D169  BD B7 0B          LD169    JSR   EVALEXPB            ; EVALUATE EXPRESSION
D16C  C1 03                      CMPB  #$03                ; 4 DRIVES MAX
D16E  10 22 D4 AD                LBHI  LA61F               ; 'DEVICE NUMBER ERROR' IF > 3
D172  D7 EB             LD172    STB   DCDRV               ; STORE IN DSKCON VARIABLE
D174  39                         RTS
