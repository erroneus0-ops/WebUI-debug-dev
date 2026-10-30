; Disk Extended Color BASIC 1.1 -- $D15C-$D261
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: FILES=$D15C, UNLOAD=$D233

* FILES COMMAND
D15C  BD 95 AC          FILES    JSR   L95AC               ; RESET SAM DISPLAY PAGE AND VDG MODE
D15F  FC 09 4A                   LDD   FCBADR              ; GET START OF FILE BUFFERS
D162  83 09 89                   SUBD  #DFLBUF             ; SUBTRACT THE START OF RANDOM FILE BUFFER SPACE
D165  34 06                      PSHS  B,A                 ; SAVE DEFAULT VALUE OF RANDOM FILE BUFFER SPACE ON STACK
D167  F6 09 5B                   LDB   FCBACT              ; * GET CURRENT NUMBER OF FCBS
D16A  34 04                      PSHS  B                   ; * AND SAVE ON THE STACK (DEFAULT VALUE)
D16C  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHAR
D16E  81 2C                      CMPA  #','                ; CHECK FOR COMMA
D170  27 0F                      BEQ   LD181               ; BRANCH IF COMMA - NO BUFFER NUMBER PARAMETER GIVEN
D172  BD B7 0B                   JSR   EVALEXPB            ; EVALUATE EXPRESSION (BUFFER NUMBER)
D175  C1 0F                      CMPB  #15                 ; 15 FCBS MAX
D177  10 22 E2 CF                LBHI  LB44A               ; BRANCH IF > 15 - 'ILLEGAL FUNCTION CALL'
D17B  E7 E4                      STB   ,S                  ; SAVE NUMBER OF FCBS ON STACK
D17D  9D A5                      JSR   GETCCH              ; CHECK CURRENT INPUT CHAR
D17F  27 08                      BEQ   LD189               ; BRANCH IF END OF LINE
D181  BD B2 6D          LD181    JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
D184  BD B3 E6                   JSR   LB3E6               ; EVALUATE EXPRESSION, RETURN VALUE IN ACCD
D187  ED 61                      STD   $01,S               ; SAVE RANDOM FILE BUFFER SIZE ON STACK
D189  BD CA E9          LD189    JSR   DVEC7               ; CLOSE FILES
D18C  E6 E4                      LDB   ,S                  ; * GET THE NUMBER OF BUFFERS TO MAKE AND
D18E  34 04                      PSHS  B                   ; * INITIALIZE A BUFFER COUNTER ON THE STACK
D190  CC 09 89                   LDD   #DFLBUF             ; GET START OF RANDOM FILE BUFFERS
D193  E3 62                      ADDD  $02,S               ; ADD THE NEWLY SPECIFIED RANDOM FILE BUFFER SPACE
D195  25 71                      BLO   LD208               ; 'OUT OF MEMORY' ERROR IF > $FFFF
D197  ED 62                      STD   $02,S               ; SAVE START OF FCBS
* RESERVE SPACE FOR FCBS
D199  C3 01 19          LD199    ADDD  #FCBLEN             ; FCBLEN REQUIRED FOR EACH BUFFER
D19C  25 6A                      BLO   LD208               ; 'OUT OF MEMORY' ERROR IF > $FFFF
D19E  6A E4                      DEC   ,S                  ; DECREMENT BUFFER COUNTER
D1A0  2A F7                      BPL   LD199               ; *BRANCH IF NOT DONE - THE BPL WILL SET UP ONE MORE BUFFER
* *THAN THE NUMBER REQUESTED. THIS EXTRA BUFFER IS THE SYSTEM BUFFER
* *AND IS LOCATED AT THE END OF THE NORMAL FCBS. ONLY SYSTEM ROUTINES
* *(COPY, BACKUP, MERGE ETC.) MAY ACCESS THIS BUFFER.
D1A2  5D                         TSTB                      ; AT AN EXACT 256 BYTE BOUNDARY?
D1A3  27 03                      BEQ   LD1A8               ; YES
D1A5  4C                         INCA                      ; NO - ADD 256
D1A6  27 60                      BEQ   LD208               ; 'OUT OF MEMORY' ERROR IF PAST $FFFF
D1A8  85 01             LD1A8    BITA  #$01                ; ON A 512 BYTE BOUNDARY?
D1AA  27 03                      BEQ   LD1AF               ; YES
D1AC  4C                         INCA                      ; NO - ADD 256
D1AD  27 59                      BEQ   LD208               ; 'OM' ERROR IF PAST $FFFF
D1AF  A7 E4             LD1AF    STA   ,S                  ; SAVE MS BYTE OF NEW GRAPHIC RAM START
D1B1  DC 1B                      LDD   VARTAB              ; GET START OF VARIABLES
D1B3  90 BC                      SUBA  GRPRAM              ; *SUBTRACT THE OLD GRAPHIC RAM START - ACCD CONTAINS LENGTH
* *OF PROGRAM PLUS RESERVED GRAPHIC RAM
D1B5  AB E4                      ADDA  ,S                  ; ADD IN THE AMOUNT OF RAM CALCULATED ABOVE
D1B7  25 4F                      BLO   LD208               ; 'OUT OF MEMORY' ERROR IF > $FFFF
D1B9  1F 01                      TFR   D,X                 ; SAVE NEW VARTAB IN X
D1BB  4C                         INCA                      ; *ADD 256 - TO GUARANTEE ENOUGH ROOM SINCE ALL CALCULATIONS USE
* *ONLY THE MSB OF THE ADDRESS
D1BC  27 4A                      BEQ   LD208               ; 'OUT OF MEMORY' ERROR IF PAST $FFFF
D1BE  10 93 21                   CMPD  FRETOP              ; IS IT GREATER THAN THE START OF STRING SPACE
D1C1  24 45                      BHS   LD208               ; 'OUT OF MEMORY' IF > START OF STRING SPACE
D1C3  4A                         DECA                      ; SUBTRACT 256 - COMPENSATE FOR INCA ABOVE
D1C4  93 1B                      SUBD  VARTAB              ; SUBTRACT START OF VARIABLES
D1C6  D3 19                      ADDD  TXTTAB              ; ADD START OF BASIC
D1C8  1F 02                      TFR   D,Y                 ; Y HAS NEW START OF BASIC
D1CA  A6 E4                      LDA   ,S                  ; * GET THE GRAPHIC RAM START, SUBTRACT
D1CC  90 BC                      SUBA  GRPRAM              ; * THE OLD GRAPHIC RAN START AND SAVE
D1CE  1F 89                      TFR   A,B                 ; * THE DIFFERENCE IN ACCA AND ACCB
D1D0  9B BA                      ADDA  BEGGRP              ; = ADD THE OLD GRAPHIC PAGE START AND
D1D2  97 BA                      STA   BEGGRP              ; = STORE THE NEW START OF GRAPHICS RAM
D1D4  DB B7                      ADDB  ENDGRP              ; * ADD THE OLD GRAPHIC RAM END ADDRESS AND
D1D6  D7 B7                      STB   ENDGRP              ; * STORE THE NEW END OF GRAPHICS RAM
D1D8  35 46                      PULS  A,B,U               ; = ACCA=MSB OF START OF GRAPHIC RAM; ACCB=NUMBER OF FILE BUFFERS
* = U=START OF FILE BUFFERS
D1DA  97 BC                      STA   GRPRAM              ; SAVE NEW START OF GRAPHIC RAM
D1DC  F7 09 5B                   STB   FCBACT              ; NUMBER OF FILE BUFFERS
D1DF  FF 09 4A                   STU   FCBADR              ; START OF FILE BUFFERS
D1E2  96 68                      LDA   CURLIN              ; GET CURRENT LINE NUMBER
D1E4  4C                         INCA                      ; ARE WE IN DIRECT MODE?
D1E5  27 08                      BEQ   LD1EF               ; YES - MOVE BASIC PROGRAM
D1E7  1F 20                      TFR   Y,D                 ; MOVE NEW START OF BASIC TO ACCD
D1E9  93 19                      SUBD  TXTTAB              ; SUBTRACT OLD START OF BASIC
D1EB  D3 A6                      ADDD  CHARAD              ; ADD OLD INPUT POINTER
D1ED  DD A6                      STD   CHARAD              ; SAVE NEW INPUT POINTER
D1EF  DE 1B             LD1EF    LDU   VARTAB              ; POINT U TO OLD START OF VARIABLES
D1F1  9F 1B                      STX   VARTAB              ; SAVE NEW START OF VARIBLES
D1F3  11 93 1B                   CMPU  VARTAB              ; * COMPARE OLD START OF VARIABLES TO NEW START OF
D1F6  22 13                      BHI   LD20B               ; * VARIABLES & BRANCH IF OLD > NEW
* MOVE BASIC PROGRAM IF OLD START ADDRESS <= NEW START ADDRESS
D1F8  A6 C2             LD1F8    LDA   ,-U                 ; GET A BYTE
D1FA  A7 82                      STA   ,-X                 ; MOVE lT
D1FC  11 93 19                   CMPU  TXTTAB              ; AT START OF BASIC PROGRAM?
D1FF  26 F7                      BNE   LD1F8               ; NO
D201  10 9F 19                   STY   TXTTAB              ; STORE NEW START OF BASIC PROGRAM
D204  6F 3F                      CLR   -1,Y                ; RESET START OF PROGRAM FLAG
D206  20 13                      BRA   LD21B               ; CLOSE ALL FILES
D208  7E AC 44          LD208    JMP   LAC44               ; 'OUT OF MEMORY' ERROR
* MOVE BASIC PROGRAM IF OLD START ADDRESS > NEW START ADDRESS
D20B  DE 19             LD20B    LDU   TXTTAB              ; POINT U TO OLD START OF BASIC
D20D  10 9F 19                   STY   TXTTAB              ; SAVE NEW START OF BASIC
D210  6F 3F                      CLR   -1,Y                ; RESET START OF BASIC FLAG
D212  A6 C0             LD212    LDA   ,U+                 ; GET A BYTE
D214  A7 A0                      STA   ,Y+                 ; MOVE IT
D216  10 9C 1B                   CMPY  VARTAB              ; AT START OF VARIABLES
D219  26 F7                      BNE   LD212               ; NO - MOVE ANOTHER BYTE

* CLOSE ALL FCBS AND RECALCULATE FCB START ADDRESSES
D21B  CE 09 28          LD21B    LDU   #FCBV1              ; POINT U TO FILE BUFFER POINTERS
D21E  BE 09 4A                   LDX   FCBADR              ; POINT X TO START OF BUFFERS
D221  5F                         CLRB                      ; RESET FILE COUNTER
D222  AF C1             LD222    STX   ,U++                ; STORE FILE ADDRESS IN VECTOR TABLE
D224  6F 00                      CLR   FCBTYP,X            ; RESET FILE TYPE TO CLOSED
D226  30 89 01 19                LEAX  FCBLEN,X            ; GO TO NEXT FCB
D22A  5C                         INCB                      ; INCREMENT FILE COUNTER
D22B  F1 09 5B                   CMPB  FCBACT              ; CLOSE ALL ACTIVE BUFFERS AND SYSTEM FCB
D22E  23 F2                      BLS   LD222               ; BRANCH IF NOT DONE
D230  7E 96 CB                   JMP   L96CB               ; READJUST LINE NUMBERS, ETC.

* UNLOAD COMMAND
D233  8D 1A             UNLOAD   BSR   LD24F               ; GET DRIVE NUMBER
D235  5F                         CLRB                      ; CLEAR FILE COUNTER
D236  5C                LD236    INCB                      ; INCREMENT FILE COUNTER
D237  BD C7 49                   JSR   LC749               ; POINT X TO FCB
D23A  27 0D                      BEQ   LD249               ; BRANCH IF FILE NOT OPEN
D23C  A6 01                      LDA   FCBDRV,X            ; CHECK DRIVE NUMBER
D23E  91 EB                      CMPA  DCDRV               ; DOES IT MATCH THE 'UNLOAD' DRIVE NUMBER?
D240  26 07                      BNE   LD249               ; NO MATCH - DO NOT CLOSE THE FILE
D242  34 04                      PSHS  B                   ; SAVE FILE COUNTER ON THE STACK
D244  BD CB 06                   JSR   LCB06               ; CLOSE FCB
D247  35 04                      PULS  B                   ; RESTORE FILE COUNTER
D249  F1 09 5B          LD249    CMPB  FCBACT              ; CHECKED ALL FILES?
D24C  23 E8                      BLS   LD236               ; NO
D24E  39                         RTS
* GET DRIVE NUMBER FROM BASIC - USE THE DEFAULT DRIVE IF NONE GIVEN
D24F  F6 09 5A          LD24F    LDB   DEFDRV              ; GET DEFAULT DRIVE NUMBER
D252  9D A5                      JSR   GETCCH              ; GET NEXT INPUT CHAR
D254  27 09                      BEQ   LD25F               ; USE DEFAULT DRIVE NUMBER IF NONE GIVEN
D256  BD B7 0B          LD256    JSR   EVALEXPB            ; EVALUATE EXPRESSION
D259  C1 03                      CMPB  #$03                ; 4 DRIVES MAX
D25B  10 22 D3 C0                LBHI  LA61F               ; 'DEVICE NUMBER ERROR' IF > 3
D25F  D7 EB             LD25F    STB   DCDRV               ; STORE IN DSKCON VARIABLE
D261  39                         RTS
