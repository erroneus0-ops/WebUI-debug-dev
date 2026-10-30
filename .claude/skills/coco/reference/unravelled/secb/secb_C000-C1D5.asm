; Super Extended Color BASIC 2.0 (CoCo 3) -- $C000-$C1D5
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: BEGMOVE=$C03F, NOWARM=$C0DE

C000                             ORG   $C000

C000  1A 50             LC000    ORCC  #$50                ; DISABLE IRQ, FIRQ INTERRUPTS
C002  10 CE 5E FF                LDS   #$5EFF              ; INITIALIZE STACK POINTER
C006  86 12                      LDA   #$12                ; PALETTE COLOR: COMPOSITE-GREEN, RGB-INDIGO
* INITIALIZE ALL PALETTE REGISTERS TO GREEN (COMPOSITE)
C008  C6 10                      LDB   #16                 ; 16 PALETTE REGISTERS
C00A  8E FF B0                   LDX   #PALETREG           ; POINT X TO THE PALETTE REGISTERS
C00D  A7 80             LC00D    STA   ,X+                 ; SAVE THE COLOR IN THE PALETTE REGISTER
C00F  5A                         DECB                      ; BUMP COUNTER
C010  26 FB                      BNE   LC00D               ; LOOP UNTIL ALL PALETTE REGISTERS DONE

C012  8E FF A0                   LDX   #MMUREG             ; POINT X TO THE MMU REGISTERS
C015  31 8D 02 2D                LEAY  MMUIMAGE,PC         ; POINT Y TO THE MMU REGISTER IMAGES
C019  C6 10                      LDB   #16                 ; 16 MMU REGISTERS
C01B  A6 A0             LC01B    LDA   ,Y+                 ; GET A BYTE FROM THE IMAGE
C01D  A7 80                      STA   ,X+                 ; SAVE IT IN THE MMU REGISTER
C01F  5A                         DECB                      ; BUMP COUNTER
C020  26 F9                      BNE   LC01B               ; LOOP UNTIL DONE
C022  86 CE                      LDA   #COCO+MMUEN+MC3+MC2+MC1 ; ENABLE COCO COMPATIBLE MODE; ENABLE MMU
C024  B7 FF 90                   STA   INIT0               ; AND TURN ON THE NORMAL SPARE CHIP SELECT
* MOVE THE INITIALIZATION CODE FROM ROM TO RAM($4000); THIS IS DONE IN
* PREPARATION FOR MOVING BASIC FROM ROM TO RAM.
C027  30 8D 00 14                LEAX  BEGMOVE,PC          ; POINT TO START OF ROM CODE
C02B  10 8E 40 00                LDY   #$4000              ; RAM LOAD ADDRESS
C02F  EC 81             LC02F    LDD   ,X++                ; GRAB TWO BYTES
C031  EE 81                      LDU   ,X++                ; GRAB TWO MORE BYTES
C033  ED A1                      STD   ,Y++                ; MOVE FIRST SET OF BYTES
C035  EF A1                      STU   ,Y++                ; AND THEN THE SECOND
C037  8C C3 6C                   CMPX  #ENDMOVE            ; ARE ALL BYTES MOVED?
C03A  25 F3                      BCS   LC02F               ; KEEP GOING UNTIL DONE
C03C  7E 40 00                   JMP   L4000               ; JUMP INTO THE MOVED CODE

* THE REST OF THE CODE IS MOVED INTO RAM TO BE EXECUTED
C03F  32 7F             BEGMOVE  LEAS  $-01,S              ; MAKE A TEMPORARY STORAGE LOCATION ON THE STACK
C041  12                         NOP
C042  12                         NOP
C043  12                         NOP
C044  12                         NOP
C045  12                         NOP                       ; SPACE FILLER NOPS - THEY SERVE NO PURPOSE
C046  86 FF                      LDA   #$FF
C048  B7 FF 94                   STA   V.TIMER
C04B  B7 FF 95                   STA   V.TIMER+1           ; SET THE TIMER TO $FFFF AND START IT COUNTING

* SET UP THE VIDEO CONTROL REGISTERS
C04E  30 8D 01 DC                LEAX  VIDIMAGE,PC         ; POINT X TO THE VIDEO CONTROL REGISTER IMAGE
C052  10 8E FF 98                LDY   #VIDEOREG           ; POINT Y TO THE VIDEO CONTROL REGISTERS
C056  A6 80             LC056    LDA   ,X+                 ; GET A BYTE FROM THE IMAGE
C058  A7 A0                      STA   ,Y+                 ; SAVE IT IN THE VIDEO REGISTER
C05A  10 8C FF A0                CMPY  #MMUREG             ; CHECK FOR THE END OF THE VIDEO MODE REGISTERS
C05E  26 F6                      BNE   LC056               ; LOOP UNTIL DONE
* INITIALIZE PIA1
C060  8E FF 20                   LDX   #PIA1               ; POINT X TO PIA 1
C063  CC FF 34                   LDD   #$FF34
C066  6F 01                      CLR   $01,X               ; CLEAR CONTROL REGISTER A
C068  6F 03                      CLR   $03,X               ; CLEAR CONTROL REGISTER B; ENABLE BOTH DATA DIRECTION REGISTERS
C06A  4A                         DECA                      ; SET ACCA TO $FE
C06B  A7 84                      STA   ,X                  ; BIT 0 INPUT, ALL OTHERS OUTPUT ON PORT A
C06D  86 F8                      LDA   #$F8
C06F  A7 02                      STA   $02,X               ; BITS 0-2 INPUT, 3-7 OUTPUT ON PORT B
C071  E7 01                      STB   $01,X               ; SET PORT TO PERIPHERAL REGISTER, CA1 DISABLED, CA2 ENABLED AS INPUT
C073  E7 03                      STB   $03,X               ; SET PORT TO PERIPHERAL REGISTER, CB1 DISABLED, CB2 ENABLED AS INPUT
C075  6F 02                      CLR   $02,X               ; SET THE GRAPHICS MODE TO NORMAL LO-RES COCO ALPHA
C077  86 02                      LDA   #$02
C079  A7 84                      STA   ,X                  ; SET THE DA OUTPUT TO ZERO AND THE RS232 OUTPUT TO MARKING
C07B  86 FF                      LDA   #$FF
* INITIALIZE PIA0
C07D  8E FF 00                   LDX   #PIA0               ; POINT X TO PIA 0
C080  6F 01                      CLR   $01,X               ; CLEAR CONTROL REGISTER A; ENABLE BOTH DATA DIRECTION REGISTERS
C082  6F 03                      CLR   $03,X               ; CLEAR CONTROL REGISTER B; ENABLE BOTH DATA DIRECTION REGISTERS
C084  6F 84                      CLR   ,X                  ; SET PORT A TO ALL INPUTS
C086  A7 02                      STA   $02,X               ; SET PORT B TO ALL OUTPUTS
C088  E7 01                      STB   $01,X               ; SET PORT TO PERIPHERAL REGISTER, CA1 DISABLED, CA2 ENABLED AS INPUT
C08A  E7 03                      STB   $03,X               ; SET PORT TO PERIPHERAL REGISTER, CB1 DISABLED, CB2 ENABLED AS INPUT
* INITIALIZE THE SAM MIRROR REGISTERS IN THE CUSTOM CHIP
C08C  C6 0C                      LDB   #12                 ; RESET 12 SAM IMAGE REGISTERS
C08E  CE FF C0                   LDU   #SAM                ; POINT U TO THE SAM REGISTERS
C091  A7 C1             LC091    STA   ,U++                ; CLEAR THE BIT AND SKIP TO THE NEXT BIT
C093  5A                         DECB                      ; BUMP COUNTER
C094  26 FB                      BNE   LC091               ; LOOP UNTIL ALL BITS CLEARED
C096  B7 FF C9                   STA   SAM+9               ; SET THE VIDEO DISPLAY PAGE TO $400
C099  1F 9B                      TFR   B,DP                ; SET THE DIRECT PAGE TO PAGE ZERO
C09B  6F 02                      CLR   $02,X               ; STROBE ALL KEYBOARD COLUMNS; USELESS INSTRUCTION
C09D  A7 5D                      STA   $-03,U              ; SAMREG+21 (FFD5); SELECT RAM PAGE 1; USELESS IN THE COCO 3
C09F  8E FF 00                   LDX   #PIA0               ; POINT X TO PIA 0; WHY?? IT'S ALREADY POINTED THERE
C0A2  C6 DF                      LDB   #$DF                ; COLUMN TWO STROBE
C0A4  E7 02                      STB   $02,X               ; STROBE THE COLUMNS
C0A6  A6 84                      LDA   ,X                  ; READ THE ROWS
C0A8  43                         COMA
C0A9  84 40                      ANDA  #$40                ; LOOK FOR ROW 6 ONLY (F1 KEY)
C0AB  A7 E4                      STA   ,S                  ; SAVE IN TEMPORARY STORAGE
* CHECK FOR THE CONTROL AND ALT KEYS
C0AD  10 8E 00 02                LDY   #2                  ; CHECK FOR TWO KEYS
C0B1  57                LC0B1    ASRB                      ; SHIFT THE COLUMN STROBE -- WASTED, SHOULD BE ASR 2,X
C0B2  E7 02                      STB   $02,X               ; SAVE THE NEW COLUMN STROBE
C0B4  A6 84                      LDA   ,X                  ; READ THE KEYBOARD ROWS
C0B6  43                         COMA
C0B7  84 40                      ANDA  #$40                ; KEEP ONLY ROW 6
C0B9  27 07                      BEQ   LC0C2               ; BRANCH IF KEY NOT DOWN
C0BB  31 3F                      LEAY  $-01,Y              ; LET'S CHECK FOT EH ALT KEY NOW
C0BD  26 F2                      BNE   LC0B1
C0BF  16 01 2E                   LBRA  LC1F0               ; GO DISPLAY THE HI-RES PICTURE IF CONTROL AND ALT KEYS ARE DOWN
C0C2  86 CA             LC0C2    LDA   #COCO+MMUEN+MC3+MC1 ; TURN OFF THE NORMAL SCS; THE EXTERNAL DISK CONTROLLER
C0C4  B7 FF 90                   STA   INIT0               ; MAY NOT BE ACCESSED NOW

* THE FOLLOWING CODE CHECKS TO DETERMINE IF A JUMP TO WARM START RESET CODE SHOULD BE DONE.
* THE JUMP TO A WARM START RESET WILL BE DONE IF 1) INT.FLAG CONTAINS A $55 AND,
* 2) RSTFLG CONTAINS A $55 AND, 3) THE ADDRESS IN RSTVEC POINTS TO A $12 (NOP INSTRUCTION.)
* IF THE ABOVE CONDITIONS ARE MET, BASIC WILL BE WARM-STARTED.  IF INT.FLAG DOES NOT CONTAIN
* A $55, BASIC WILL BE COLD-STARTED.  IF INT.FLAG DOES CONTAIN A $55, BUT 2) AND 3) ABOVE
* ARE NOT MET, BLOCK 6.0 (128K SYSTEM) OR BLOCK 0.0 (512K SYSTEM) WILL BE LOADED INTO CPU
* BLOCK 0. THIS WILL GIVE THE CPU A NEW DIRECT PAGE AND CHECKS 2) AND 3) ABOVE WILL BE
* PERFORMED ON THIS NEW DIRECT PAGE TO SEE IF BASIC SHOULD BE WARM-STARTED.

C0C7  B6 FE ED                   LDA   INT.FLAG            ; GET THE INTERRUPT JUMP TABLE VALIDITY FLAG.
C0CA  81 55                      CMPA  #$55                ; CHECK FOR VALID INTERRUPT JUMP TABLE FLAG
C0CC  26 28                      BNE   LC0F6               ; INTERRUPT JUMP TABLE IS NOT VALID' COPY ROM TO RAM
C0CE  96 71                      LDA   RSTFLG              ; GET THE SYSTEM RESET FLAG
C0D0  81 55                      CMPA  #$55                ; CHECK FOR THE WARM START FLAG
C0D2  26 0A                      BNE   NOWARM              ; BRANCH IF NO WARM START
C0D4  9E 72                      LDX   RSTVEC              ; GET THE SYSTEM RESET VECTOR
C0D6  A6 84                      LDA   ,X                  ; GET THE FIRST BYTE POINTED TO BY THE RESET VECTOR
C0D8  81 12                      CMPA  #$12                ; IS IT A NOP?
C0DA  10 27 00 AE                LBEQ  LC18C               ; DON'T COPY ROM TO RAM, ETC.
C0DE  7F FF A0          NOWARM   CLR   MMUREG              ; PUT BLOCK 6.0 (128K RAM) OR BLOCK 0.0 (512K RAM) INTO CPU BLOCK 0
C0E1  96 71                      LDA   RSTFLG
C0E3  81 55                      CMPA  #$55                ; CHECK FOT THE WARM START FLAG
C0E5  26 0A                      BNE   LC0F1               ; BRANCH IF NO WARM START
C0E7  9E 72                      LDX   RSTVEC              ; POINT X TO THE WARM START CODE
C0E9  A6 84                      LDA   ,X                  ; GET THE FIRST BYTE OF THE WARM START CODE
C0EB  81 12                      CMPA  #$12                ; IS IT A NOP?
C0ED  10 27 00 9B                LBEQ  LC18C               ; DON'T COPY ROM TO RAM IF IT IS.
C0F1  86 38             LC0F1    LDA   #BLOCK7.0           ; GET BACK BLOCK 7.0
C0F3  B7 FF A0                   STA   MMUREG              ; PUT IT BACK INTO CPU BLOCK 0
C0F6  8E C0 00          LC0F6    LDX   #DOSBAS             ; POINT TO THE END OF THE COLOR BASIC ROM
C0F9  10 8E 80 00                LDY   #EXBAS              ; POINT TO START OF EXTENDED BASIC
C0FD  17 00 AA                   LBSR  LC1AA               ; MOVE COLOR AND EXTENDED BASIC ROM TO RAM

* PATCH COLOR AND EXTENDED BASIC
C100  31 8D 01 52                LEAY  PATCHTAB,PC         ; POINT Y TO THE PATCH TABLE
C104  A6 A0                      LDA   ,Y+                 ; GET THE NUMBER OF PATCHES TO BE MADE
C106  34 02             LC106    PSHS  A                   ; SAVE THE PATCH COUNTER
C108  AE A1                      LDX   ,Y++                ; GET THE ADDRESS WHERE THE PATCH IS TO BE PLACED
C10A  E6 A0                      LDB   ,Y+                 ; GET THE NUMBER OB BYTES IN THE PATCH
C10C  A6 A0             LC10C    LDA   ,Y+                 ; GET A BYTE
C10E  A7 80                      STA   ,X+                 ; PATCH THE CODE IN RAM
C110  5A                         DECB                      ; BUMP THE COUNTER
C111  26 F9                      BNE   LC10C               ; LOOP UNTIL DONE
C113  35 02                      PULS  A                   ; RESTORE THE PATCH COUNTER
C115  4A                         DECA
C116  26 EE                      BNE   LC106               ; LOOP UNTIL ALL PATCHES DONE
C118  7F FF DE                   CLR   SAM+30              ; ENABLE THE ROM MODE
C11B  86 C8                      LDA   #COCO+MMUEN+MC3     ; ENABLE 16K INTERNAL, 16K EXTERNAL ROM
C11D  B7 FF 90                   STA   INIT0
C120  FC C0 00                   LDD   DOSBAS              ; GET THE FIRST TWO BYTES OF AN EXTERNAL ROM, IF ANY
* CHECK FOR A 'DK' AT $C000 (DISK BASIC) - THIS SHOULD BE CMPD
C123  81 44                      CMPA  #'D'
C125  26 10                      BNE   LC137
C127  C1 4B                      CMPB  #'K'
C129  26 0C                      BNE   LC137
* COPY THE DISK BASIC ROM INTO RAM
C12B  8E E0 00                   LDX   #SUPERVAR           ; POINT TO THE END OF THE DISK BASIC ROM
C12E  10 8E C0 00                LDY   #DOSBAS             ; POINT TO THE START OF THE DISK BASIC ROM
C132  8D 76                      BSR   LC1AA               ; COPY ROM INTO RAM
C134  17 01 EB                   LBSR  LC322               ; PATCH DISK BASIC
C137  7F FF DE          LC137    CLR   SAM+30              ; ENABLE ROM MODE
C13A  86 CA                      LDA   #COCO+MMUEN+MC3+MC1
C13C  B7 FF 90                   STA   INIT0               ; ENABLE 32K INTERNAL ROM

* COPY SUPER EXTENDED BASIC FROM ROM TO RAM
C13F  8E FE 00                   LDX   #H.CRSLOC           ; POINT TO THE END OF ENHANCED BASIC ROM
C142  10 8E E0 00                LDY   #SUPERVAR           ; POINT TO THE START OF ENHANCED BASIC ROM
C146  8D 62                      BSR   LC1AA               ; COPY ROM TO RAM
C148  17 00 93                   LBSR  LC1DE               ; PATCH THE ENHANCEMENTS (MOVE THE AUTHORS' DECODED NAMES)
C14B  31 8D 02 0A                LEAY  INTIMAGE,PC         ; POINT X TO THE INTERRUPT JUMP VECTOR IMAGES
C14F  8E FE ED                   LDX   #INT.FLAG           ; DESTINATION FOR INTERRUPT VECTORS
C152  C6 13                      LDB   #19                 ; 6 INTERRUPT JUMP ADDRESSES * 3 BYTES/JUMP ADDRESS + VALIDITY FLAG
C154  17 00 7F                   LBSR  MOVE.XY             ; COPY THE INTERRUPT JUMP VECTORS
C157  7F FF DF                   CLR   SAM+31              ; ENABLE THE RAM MODE
C15A  6D E4                      TST   ,S                  ; WAS THE F1 KEY DEPRESSED?
C15C  27 22                      BEQ   LC180               ; NO
C15E  8E E0 32                   LDX   #IM.TEXT            ; TEXT MODE VIDEO CONTROL REGISTER IMAGES IN SUPER EXTENDED BASIC
C161  C6 03                      LDB   #$03                ; THREE SETS OF IMAGES
C163  30 01                      LEAX  $01,X               ; SKIP PAST THE $FF90 TEXT MODE IMAGE
C165  A6 84             LC165    LDA   ,X                  ; GET THE INIT0 IMAGE
C167  8A 20                      ORA   #$20                ; FORCE THE ALTERNATE COLOR SET
C169  A7 84                      STA   ,X                  ; RE-SAVE THE INIT0 IMAGE
C16B  30 09                      LEAX  $09,X               ; SKIP TO NEXT SET OF IMAGES
C16D  5A                         DECB                      ; BUMP COUNTER
C16E  26 F5                      BNE   LC165               ; LOOP UNTIL DONE
C170  C6 02                      LDB   #$02                ; TWO SETS OF GRAPHICS MODE IMAGES
C172  8E E0 70                   LDX   #IM.GRAPH           ; GRAPHICS MODE VIDEO CONTROL REGISTER IMAGES IN SUPER EXTENDED BASIC
C175  A6 84             LC175    LDA   ,X                  ; GET THE INIT0 IMAGE
C177  8A 20                      ORA   #$20                ; FORCE THE ALTERNATE COLOR SET
C179  A7 84                      STA   ,X                  ; RE-SAVE THE INIT0 IMAGE
C17B  30 09                      LEAX  $09,X               ; SKIP TO NEXT SET OF IMAGES
C17D  5A                         DECB                      ; BUMP COUNTER
C17E  26 F5                      BNE   LC175               ; LOOP UNTIL DONE
* CLEAR THE LO-RES VIDEO SCREEN
C180  8E 04 00          LC180    LDX   #VIDRAM             ; POINT X TO THE START OF THE VIDEO DISPLAY
C183  86 60                      LDA   #$60                ; GREEN SPACE
C185  A7 80             LC185    STA   ,X+                 ; PUT A GREEN SPACE ON THE LO-RES SCREEN
C187  8C 06 00                   CMPX  #VIDRAM+512         ; AT THE END OF THE DISPLAY?
C18A  25 F9                      BCS   LC185               ; NO
C18C  86 CE             LC18C    LDA   #COCO+MMUEN+MC3+MC2+MC1
C18E  B7 FF 90                   STA   INIT0               ; ENABLE THE NORMAL SPARE CHIP SELECT (EXTERNAL $FF40)
C191  6D E4                      TST   ,S                  ; WAS THE F1 KEY DEPRESSED?
C193  27 05                      BEQ   LC19A               ; NO
C195  86 20                      LDA   #$20                ; ALTERNATE COLOR SET FLAG
C197  B7 FF 98                   STA   VIDEOREG            ; FORCE THE ALTERNATE COLOR SET
C19A  8E FF B0          LC19A    LDX   #PALETREG           ; POINT X TO THE PALETTE REGISTERS
C19D  31 8D 00 95                LEAY  PALIMAGE,PC         ; POINT Y TO THE PALETTE REGISTER IMAGES
C1A1  C6 10                      LDB   #16                 ; 16 PALETTE REGISTERS
C1A3  8D 31                      BSR   MOVE.XY             ; FILL THE PALETTE REGISTERS FROM THEIR IMAGE
C1A5  32 61                      LEAS  $01,S               ; REMOVE THE TEMPORARY STORAGE BYTE
C1A7  7E A0 27                   JMP   RESVEC              ; JUMP TO THE COCO 2 RESET ENTRY POINT

* COPY DATA POINTED TO BY (Y) FROM ROM TO RAM UNTIL THE ADDRESS IN
* (X) IS REACHED; PSHING AND PULING FROM U OR S WOULD BE MUCH MORE EFFICIENT
C1AA  BF 5F 02          LC1AA    STX   L5F02               ; TEMPORARILY SAVE THE END OF COPY ADDRESS
C1AD  10 FF 5F 00                STS   L5F00               ; AND THE STACK POINTER
C1B1  7F FF DE          LC1B1    CLR   SAM+30              ; ENABLE THE ROM
C1B4  EC A4                      LDD   ,Y
C1B6  AE 22                      LDX   $02,Y
C1B8  EE 24                      LDU   $04,Y
C1BA  10 EE 26                   LDS   $06,Y
C1BD  7F FF DF                   CLR   SAM+31              ; DISABLE THE ROM
C1C0  ED A4                      STD   ,Y                  ; NOW SAVE THE DATA FROM THE CPU REGISTERS INTO ROM
C1C2  AF 22                      STX   $02,Y
C1C4  EF 24                      STU   $04,Y
C1C6  10 EF 26                   STS   $06,Y
C1C9  31 28                      LEAY  $08,Y               ; MOVE THE COPY POINTER UP 8 BYTES
C1CB  10 BC 5F 02                CMPY  L5F02               ; CHECK FOR END OF THE COPY RANGE
C1CF  25 E0                      BCS   LC1B1
C1D1  10 FE 5F 00                LDS   L5F00               ; RESTORE THE STACK
C1D5  39                         RTS
