; Super Extended Color BASIC 2.0 (CoCo 3) -- $C256-$E04C
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: PATCHTAB=$C256, INTIMAGE=$C359, ENDMOVE=$C36C, AUTHPIC=$C405, SUPERVAR=$E000, PRGTEXT=$E002, PRGGRAPH=$E004, PRGMMU=$E006, GETTEXT=$E008, GETBLOK0=$E00A, GETTASK0=$E00C, GETTASK1=$E00E, SPARE0=$E013, SPARE1=$E015, SPARE2=$E017, SETTEXT=$E019, IM.TEXT=$E032

* TABLE OF PATCHES TO BE MADE TO COLOR AND EXTENDED BASIC. THE FIRST BYTE
* IS THE TOTAL NUMBER OF PATCHES TO BE MADE FOLLOWED BY THE CODE FOR ALL OF
* THE PATCHES.  THE INDIVIDUAL PATCHES HAVE A THREE BYTE HEADER CONSISTING OF THE
* ADDRESS WHERE THE PATCH IS TO GO AND THE NUMBER OF BYTES IN THE PATCH.

C256  1B                PATCHTAB FCB   27                  ; NUMBER OF PATCHES

* PATCH 1 - ENABLE EXTENDED BASIC WARM START CODE
C257  80 C0             LC257    FDB   PATCH1              ; $80C0
C259  01                LC259    FCB   $01
C25A  12                LC25A    NOP

* PATCH 2 - CRUNCH A TOKEN
C25B  B8 D4             LC25B    FDB   PATCH2              ; $B8D4
C25D  03                LC25D    FCB   $03
C25E  7E E1 38          LC25E    JMP   ALINK2              ; $E138

* PATCH 3 - UNCRUNCH A TOKEN
C261  B7 F3             LC261    FDB   PATCH3              ; $B7F3
C263  03                LC263    FCB   $03
C264  7E E1 72          LC264    JMP   ALINK3              ; $E172

* PATCH 4 - EXTENDED BASIC'S COMMAND INTERPRETATION LOOP
C267  81 50             LC267    FDB   PATCH4              ; $8150
C269  04                LC269    FCB   $04
C26A  7E E1 92          LC26A    JMP   ALINK4              ; $E192
C26D  12                         NOP

* PATCH 5 - EXTENDED BASIC'S SECONDARY COMMAND HANDLER
C26E  81 6C             LC26E    FDB   PATCH5              ; $816C
C270  04                LC270    FCB   $04
C271  7E E1 A6          LC271    JMP   ALINK5              ; $E1A6
C274  12                         NOP

** PATCHES 6 - 11 MODIFY THE WAY A '&H' VARIABLE IS PROCESSED
* PATCH 6
C275  88 34             LC275    FDB   PATCH6              ; $8834
C277  12                LC277    FCB   $12
C278  7E E3 F8          LC278    JMP   ALINK6A             ; $E3F8
C27B  0F 51                      CLR   FPA0+1
C27D  0F 52                      CLR   FPA0+2
C27F  0F 53                      CLR   FPA0+3
C281  20 B0                      BRA   ((PATCH7+4)-(PATCH6+9))
C283  0F 50                      CLR   FPA0
C285  20 CF                      BRA   (PATCH6A-(PATCH6+13))
C287  7E E4 0C                   JMP   ALINK6B

* PATCH 7
C28A  87 EB             LC28A    FDB   PATCH7              ; $87EB
C28C  07                LC28C    FCB   $07
C28D  20 4A             LC28D    BRA   ((PATCH6+3)-PATCH7)
C28F  12                         NOP
C290  39                         RTS
C291  8E 00 51                   LDX   #FPA0+1

* PATCH 8
C294  88 0C             LC294    FDB   PATCH8              ; $880C
C296  02                LC296    FCB   $02
C297  20 35             LC297    BRA   ((PATCH6+15)-PATCH8)

* PATCH 9
C299  88 26             LC299    FDB   PATCH9              ; $8826
C29B  02                LC29B    FCB   $02
C29C  25 17             LC29C    BCS   ((PATCH6+11)-PATCH9)

* PATCH 10
C29E  87 E7             LC29E    FDB   PATCH10             ; $87E7
C2A0  02                LC2A0    FCB   $02
C2A1  26 05             LC2A1    BNE   ((PATCH7+3)-PATCH10)

* PATCH 11 - NEEDED BECAUSE PATCH 5 REMOVED AN RTS WHICH THIS ROUTINED USED
C2A3  88 6A             LC2A3    FDB   PATCH11             ; $886A
C2A5  02                LC2A5    FCB   $02
C2A6  26 82             LC2A6    BNE   ((PATCH7+3)-PATCH11)

* PATCH 12 - EX BASIC'S COPYRIGHT MESSAGE
C2A8  80 B2             LC2A8    FDB   PATCH12             ; $80B2
C2AA  03                LC2AA    FCB   $03
C2AB  7E E2 88          LC2AB    JMP   ALINK12             ; $E288

* PATCH 13 - REMOVE ONE CR FROM ONE OF EX BAS COPYRIGHT MESSAGE
C2AE  81 3A             LC2AE    FDB   PATCH13             ; $813A
C2B0  01                LC2B0    FCB   $01
C2B1  00                LC2B1    FCB   $00

* PATCH 14 - ADD ONTO END OF EX BAS GRAPHICS INITIALIZATION ROUTINE
C2B2  97 03             LC2B2    FDB   PATCH14             ; $9703
C2B4  03                LC2B4    FCB   $03
C2B5  7E E3 89          LC2B5    JMP   ALINK14             ; $E389

* PATCH 15 - BREAK CHECK
C2B8  AD F0             LC2B8    FDB   PATCH15             ; $ADF0
C2BA  04                LC2BA    FCB   $04
C2BB  7E E4 29          LC2BB    JMP   ALINK15             ; $E429
C2BE  12                         NOP

* PATCH 16 - CHECK FOR BREAK KEY ON BASIC'S LINE INPUT
C2BF  A3 C2             LC2BF    FDB   PATCH16             ; $A3C2
C2C1  04                LC2C1    FCB   $04
C2C2  7E E4 13          LC2C2    JMP   ALINK16             ; $E413
C2C5  12                         NOP

* PATCH 17 - PATCH INPUT TO RESPOND TO ON BRK
C2C6  B0 3D             LC2C6    FDB   PATCH17+1           ; $B03C+1
C2C8  02                LC2C8    FCB   $02
C2C9  E5 32             LC2C9    FDB   ALINK17             ; $E532

* PATCH 18 - 'ON' COMMAND
C2CB  AF 42             LC2CB    FDB   PATCH18             ; $AF42
C2CD  03                LC2CD    FCB   $03
C2CE  7E E3 B4          LC2CE    JMP   ALINK18             ; $E3B4

* PATCH 19 - END OF 'NEW' COMMAND
C2D1  AD 3F             LC2D1    FDB   PATCH19             ; $AD3F
C2D3  04                LC2D3    FCB   $04
C2D4  7E E4 D0          LC2D4    JMP   ALINK19             ; $E4D0
C2D7  12                         NOP

* PATCH 20 - ERROR SERVICING ROUTINE
C2D8  AC 46             LC2D8    FDB   PATCH20             ; $AC46
C2DA  03                LC2DA    FCB   $03
C2DB  7E E4 70          LC2DB    JMP   ALINK20             ; $E470

* PATCH 21 - BASIC'S MAIN LOOP IN THE DIRECT MODE
C2DE  AC 73             LC2DE    FDB   PATCH21             ; $AC73
C2E0  03                LC2E0    FCB   $03
C2E1  7E E5 02          LC2E1    JMP   ALINK21             ; $E502

* PATCH 22
C2E4  A3 0A             LC2E4    FDB   PATCH22             ; $A30A
C2E6  03                LC2E6    FCB   $03
C2E7  7E 8C 37          LC2E7    JMP   PATCH22A            ; $8C37

* PATCH 23 - 'CLS' ROUTINE
C2EA  A9 10             LC2EA    FDB   PATCH23             ; $A910
C2EC  03                LC2EC    FCB   $03
C2ED  7E 8C 46          LC2ED    JMP   PATCH23A            ; $8C46

* PATCH 24 - CURSOR BLINK
C2F0  A1 B1             LC2F0    FDB   PATCH24             ; $A1B1
C2F2  08                LC2F2    FCB   $08
C2F3  7E A0 CE          LC2F3    JMP   LA0CE               ; $A0CE
C2F6  12                         NOP
C2F7  12                         NOP
C2F8  12                         NOP
C2F9  12                         NOP
C2FA  12                         NOP

* PATCH 25 - PRINT @ COMMAND
C2FB  B9 02             LC2FB    FDB   PATCH25             ; $B902
C2FD  03                LC2FD    FCB   $03
C2FE  7E F8 C3          LC2FE    JMP   ALINK25             ; $F8C3

* PATCH 26
C301  B9 5C             LC301    FDB   PATCH26             ; $B95C
C303  03                LC303    FCB   $03
C304  7E F8 A3          LC304    JMP   ALINK26             ; $F8A3

* PATCH 27 - GET A BASIC INPUT LINE
C307  A3 8D             LC307    FDB   PATCH27             ; $A38D
C309  03                LC309    FCB   $03
C30A  7E F7 57          LC30A    JMP   ALINK27             ; $F757

* THESE DATA ARE THE NAMES OF THE AUTHORS IN COMPLEMENTED ASCII (T.Harris & T.Earles,CR,0)
C30D  AB D1 B7 9E 8D 8D LC30D    FCB   $AB,$D1,$B7,$9E,$8D,$8D
C313  96 8C DF D9 DF AB          FCB   $96,$8C,$DF,$D9,$DF,$AB
C319  D1 BA 9E 8D 93 9A          FCB   $D1,$BA,$9E,$8D,$93,$9A
C31F  8C F2 FF                   FCB   $8C,$F2,$FF

C322  B6 C0 04          LC322    LDA   DCNVEC              ; LOOK FOR THE MS BYTE OF THE ADDRESS OF DSKCON
C325  81 D6                      CMPA  #$D6                ; IF IT IS D6, THEN WE HAVE DISK BASIC 1.0
C327  26 0B                      BNE   LC334               ; BRANCH IF DISK BASIC 1.1
C329  8E C0 C6                   LDX   #PATCH28            ; POINT X TO DISK BASIC 1.0 PATCH ADDRESS ($C0C6)
C32C  31 8D 00 25                LEAY  LC355,PC            ; POINT Y TO THE PATCH DATA
C330  E6 A0                      LDB   ,Y+                 ; GET THE NUMBER OF BYTES TO PATCH
C332  20 15                      BRA   LC349
C334  8E C8 B4          LC334    LDX   #PATCH30            ; POINT X TO DISK BASIC 1.1 KEYBOARD PATCH ($C8B4)
C337  86 12                      LDA   #$12                ; OP CODE OF A NOP INSTRUCTION
C339  C6 0B                      LDB   #11                 ; PATCH 11 BYTES
C33B  A7 80             LC33B    STA   ,X+                 ; STORE A NOP
C33D  5A                         DECB                      ; DECREMENT COUNTER
C33E  26 FB                      BNE   LC33B               ; LOOP UNTIL DONE
C340  8E C0 D9                   LDX   #PATCH29            ; POINT X TO DISK BASIC 1.1 PATCH ADDRESS ($C0D9)
C343  31 8D 00 0A                LEAY  LC351,PC            ; POINT Y TO THE PATCH DATA
C347  E6 A0                      LDB   ,Y+                 ; GET THE NUMBER OF BYTES TO PATCH
C349  A6 A0             LC349    LDA   ,Y+                 ; GET A PATCH BYTE
C34B  A7 80                      STA   ,X+                 ; STORE THE PATCH BYTE
C34D  5A                         DECB                      ; DECREMENT THE PATCH COUNTER
C34E  26 F9                      BNE   LC349               ; LOOP UNTIL DONE
C350  39                         RTS
* DISK BASIC ROM PATCHES (COPYRIGHT MESSAGE)
C351  03                LC351    FCB   $03
C352  7E E2 9D          LC352    JMP   ALINK29             ; $E29D
C355  03                LC355    FCB   $03
C356  7E E2 97          LC356    JMP   ALINK28             ; $E297

* INTERRUPT VECTOR IMAGES
* THESE LBRAs WILL LINK TO BASIC'S RAM INTERRUPT VECTORS AT $100
C359  55                INTIMAGE FCB   $55                 ; VALIDITY FLAG (INTERRUPT VECTORS VALID/INVALID)
C35A  16 02 0F          LC35A    LBRA  (INTIMAGE+1)-(INT.JUMP)+SW3VEC
C35D  16 02 0F                   LBRA  (INTIMAGE+1)-(INT.JUMP)+SW2VEC
C360  16 02 18                   LBRA  (INTIMAGE+1)-(INT.JUMP)+FRQVEC
C363  16 02 12                   LBRA  (INTIMAGE+1)-(INT.JUMP)+IRQVEC
C366  16 02 09                   LBRA  (INTIMAGE+1)-(INT.JUMP)+SWIVEC
C369  16 02 09                   LBRA  (INTIMAGE+1)-(INT.JUMP)+NMIVEC

* END OF THE DATA COPIED INTO RAM
C36C                    ENDMOVE  RMB   153                 ; UNUSED

C405                    AUTHPIC  RMB   $1800               ; COCO 2 COMPATIBLE DIGITIZED PICTURE OF THE AUTHORS

DC05                    LDC05    RMB   1019                ; UNUSED

* THE NEW SUPER EXTENDED BASIC CODE STARTS HERE

* THE CODE FROM THIS POINT TO $FDFF IS THE ENHANCEMENTS ADDED TO THE 'OLD' COCO BASIC
* TO SUPPORT THE NEW FEATURES AVAILABLE IN THE COCO 3.

* THESE ARE THE ONLY 'SANCTIONED BY TANDY' LEGAL ENTRY POINTS INTO THE SUPER
* EXTENDED (ENHANCED) PORTION OF THE BASIC ROM

E000  00 E6             SUPERVAR FDB   HRMODE              ; ADDRESS OF DIRECT PAGE VARIABLES UNIQUE TO ENHANCED BASIC
E002  E0 19             PRGTEXT  FDB   SETTEXT             ; SET THE VIDEO CONTROL REGISTERS TO DISPLAY HI-RES TEXT
E004  E0 4D             PRGGRAPH FDB   SETGRAPH            ; SET THE VIDEO CONTROL REGISTERS TO DISPLAY HI-RES GRAPHICS
E006  E0 97             PRGMMU   FDB   SETMMU              ; PROGRAM THE MMU REGISTERS FROM THEIR IMAGES
E008  E0 B5             GETTEXT  FDB   SELTEXT             ; PLACE THE HI-RES TEXT SCREEN INTO LOGICAL BLOCK 1
E00A  E0 A1             GETBLOK0 FDB   SELBLOK0            ; PLACE THE BLOCK NUMBER IN ACCB INTO LOGICAL BLOCK 0
E00C  E0 FF             GETTASK0 FDB   SELTASK0            ; RE-SELECT TASK REGISTER 0
E00E  E1 19             GETTASK1 FDB   SELTASK1            ; SELECT TASK REGISTER 1
E010  7E A0 5E          LE010    JMP   EXECCART            ; EXECUTE A ROM CARTRIDGE ($A05E)
E013  00 00             SPARE0   FDB   $0000               ; UNDEFINED
E015  00 00             SPARE1   FDB   $0000               ; UNDEFINED
E017  00 00             SPARE2   FDB   $0000               ; UNDEFINED

* SET UP THE VIDEO CONTROL REGISTERS ACCORDING TO THE SELECTED WIDTH
E019  34 32             SETTEXT  PSHS  Y,X,A
E01B  10 21 1F E1                LBRN  RAMLINK             ; RAM HOOK
E01F  8E E0 32                   LDX   #IM.TEXT            ; POINT TO THE 32 COLUMN VIDEO MODE REGISTER TABLE
E022  96 E7                      LDA   HRWIDTH             ; CHECK THE HI-RES TEXT MODE
E024  27 5C                      BEQ   SETVIDEO            ; BRANCH IF 32 COLUMN MODE
E026  8E E0 3B                   LDX   #LE03B              ; POINT TO THE 40 COLUMN VIDEO MODE REGISTER TABLE
E029  81 01                      CMPA  #$01                ; VIDEO MODE WIDTH SET TO 40 COLUMN?
E02B  27 55                      BEQ   SETVIDEO            ; YES
E02D  8E E0 44                   LDX   #LE044              ; POINT TO THE 80 COLUMN VIDEO MODE REGISTER TABLE
E030  20 50                      BRA   SETVIDEO

* VIDEO MODE REGISTER IMAGES FOR THE HI-RES TEXT MODES
* INITIAL VIDEO CONTROL REGISTER DATA FOR 32 COLUMN COCO COMPATIBLE MODE
E032  CC                IM.TEXT  FCB   COCO+MMUEN+MC3+MC2  ; FF90
E033  00 00 00 00 0F E0 LE033    FCB   $00,$00,$00,$00,$0F,$E0 ; FF98
E039  00 00                      FCB   $00,$00
* INITIAL VIDEO CONTROL REGISTER DATA FOR 40 COLUMN HI-RES MODE
E03B  4C                LE03B    FCB   MMUEN+MC3+MC2       ; FF90
E03C  03 05 12 00 00 D8 LE03C    FCB   $03,$05,$12,$00,$00,$D8 ; FF98
E042  00 00                      FCB   $00,$00
* INITIAL VIDEO CONTROL REGISTER DATA FOR 80 COLUMN HI-RES MODE
E044  4C                LE044    FCB   MMUEN+MC3+MC2       ; FF90
E045  03 15 12 00 00 D8 LE045    FCB   $03,$15,$12,$00,$00,$D8 ; FF98
E04B  00 00                      FCB   $00,$00
