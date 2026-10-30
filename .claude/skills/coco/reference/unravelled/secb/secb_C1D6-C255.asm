; Super Extended Color BASIC 2.0 (CoCo 3) -- $C1D6-$C255
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: MOVE.XY=$C1D6, WAITLOOP=$C22C, VIDIMAGE=$C22E, PALIMAGE=$C236, MMUIMAGE=$C246

* MOVE ACCB BYTES FROM (Y) TO (X)
C1D6  A6 A0             MOVE.XY  LDA   ,Y+
C1D8  A7 80                      STA   ,X+
C1DA  5A                         DECB
C1DB  26 F9                      BNE   MOVE.XY
C1DD  39                         RTS

* DECODE AND COPY THE AUTHOR'S NAMES INTO RAM
C1DE  8E F7 1B          LC1DE    LDX   #AUTHORMS           ; POINT X TO THE DESTINATION FOR THE AUTHORS' NAMES
C1E1  31 8D 01 28                LEAY  LC30D,PC            ; POINT Y TO THE CODED NAMES OF THE AUTHORS
C1E5  C6 15                      LDB   #21                 ; 21 BYTES IN THE AUTHORS' NAMES
C1E7  A6 A0             LC1E7    LDA   ,Y+                 ; GET A CODED BYTE OF THE AUTHORS' NAMES
C1E9  43                         COMA                      ; DECODE THE BYTE
C1EA  A7 80                      STA   ,X+                 ; SAVE THE UNCODED BYTE
C1EC  5A                         DECB                      ; BUMP COUNTER DOWN ONE.
C1ED  26 F8                      BNE   LC1E7               ; LOOP UNTIL ALL BYTES DECODED
C1EF  39                         RTS

* THIS IS THE CODE WHICH DISPLAYS THE HIGH RESOLUTION PICTURE OF THE
* AUTHORS OF SUPER EXTENDED BASIC
C1F0  4F                LC1F0    CLRA
C1F1  B7 FE ED                   STA   INT.FLAG            ; SET THE INTERRUPT FLAG TO NOT VALID (NOT INITIALIZED)
C1F4  97 71                      STA   RSTFLG              ; FORCE THE ROMS TO BE COPIED INTO RAM
C1F6  B7 FF DE                   STA   SAM+30              ; ENABLE THE ROMS
C1F9  C6 09                      LDB   #$09
C1FB  F7 FF BA                   STB   PALETREG+10
C1FE  C6 3F                      LDB   #63                 ; WHITE (COMPOSITE AND RGB)
C200  F7 FF BB                   STB   PALETREG+11
C203  8E C4 05                   LDX   #AUTHPIC            ; POINT X TO THE AUTHORS' PICTURE DATA
C206  10 8E 0E 00                LDY   #$0E00              ; DESTINATION OF THE AUTHORS' PICTURE DATA
C20A  EC 81             LC20A    LDD   ,X++
C20C  EE 81                      LDU   ,X++                ; GET FOUR BYTES OF PICTURE DATA
C20E  ED A1                      STD   ,Y++
C210  EF A1                      STU   ,Y++                ; PUT THE DATA ON THE HI-RES SCREEN
C212  8C DC 05                   CMPX  #LDC05              ; AT THE END OF THE PICTURE DATA?
C215  25 F3                      BCS   LC20A               ; NO
C217  86 F9                      LDA   #$F9                ; 256x192 GREEN/BUFF COCO 2 HI-RES GRAPHICS MODE
C219  B7 FF 22                   STA   PIA1+2              ; PROGRAM THE GRAPHICS MODE INTO THE PIA AND THE GIME CHIP
C21C  4F                         CLRA
C21D  8E FF C0                   LDX   #SAM                ; POINT X TO THE SAM REGISTERS
C220  A7 84                      STA   ,X
C222  A7 03                      STA   $03,X
C224  A7 05                      STA   $05,X               ; PROGRAM THE SAM REGISTERS FOR HI-RES MODE
C226  A7 07                      STA   $07,X
C228  A7 09                      STA   $09,X
C22A  A7 0B             LC22A    STA   $0B,X               ; SET THE VIDEO DISPLAY PAGE TO $E00
C22C  20 FE             WAITLOOP BRA   WAITLOOP            ; ENDLESS WAIT LOOP

* IMAGES OF THE VIDEO CONTROL REGISTERS (FF98-FF9F)
C22E  00 00 00 00 0F E0 VIDIMAGE FCB   $00,$00,$00,$00,$0F,$E0
C234  00 00                      FCB   $00,$00

* IMAGES OF THE PALETTE REGISTERS (FFB0-FFBF)
C236  12 24 0B 07 3F 1F PALIMAGE FCB   18,36,11,7,63,31
C23C  09 26 00 12 00 3F          FCB   9,38,0,18,0,63
C242  00 12 00 26                FCB   0,18,0,38

* IMAGES OF THE MMU REGISTERS (FFA0-FFAF)

* TASK REGISTER 0
C246  38 39 34          MMUIMAGE FCB   BLOCK7.0,BLOCK7.1,BLOCK6.4
C249  3B 3C 3D                         BLOCK7.3,BLOCK7.4,BLOCK7.5
C24C  3E 3F                            BLOCK7.6,BLOCK7.7

* TASK REGISTER 1
C24E  38 30 31          LC24E    FCB   BLOCK 7.0,BLOCK6.0,BLOCK6.1
C251  32 33 3D                         BLOCK6.2,BLOCK6.3,BLOCK7.5
C254  35 3F                            BLOCK6.5,BLOCK7.7
