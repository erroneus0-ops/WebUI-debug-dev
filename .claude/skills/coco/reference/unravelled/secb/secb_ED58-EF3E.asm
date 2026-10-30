; Super Extended Color BASIC 2.0 (CoCo 3) -- $ED58-$EF3E
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: HBUFF=$ED58, HGET=$EDE5, HPUT=$EDED

* HBUFF
* THE HBUFF COMMAND WILL RESERVE SPACE IN THE HPUT/HGET BUFFER.  THERE MUST BE ENOUGH FREE RAM
* IN THE BUFFER FOR THE REQUESTED BUFFER SIZE AND A FIVE BYTE HEADER.  EACH BUFFER HAS A FIVE BYTE
* HEADER WHICH IS DESCRIBED AS FOLLOWS:
* BYTES 0,1: ADDRESS OF THE NEXT HPUT/HGET BUFFER IN THE BUFFER SPACE.  IF ZERO, THERE ARE
* NO MORE BUFFERS IN THE BUFFER SPACE.  IF $FFFF, THEN THERE ARE NO
* BUFFERS ALLOCATED AND THE ENTIRE BUFFER SPACE IS FREE.
* BYTE 2: BUFFER NUMBER; BYTES 3,4: SIZE OF THE BUFFER

* HBUFF
ED58  BD B7 3D          HBUFF    JSR   LB73D               ; EVALUATE BUFFER NUMBER ARGUMENT; RETURN VALUE IN X
ED5B  10 21 12 A1                LBRN  RAMLINK             ; RAM HOOK
ED5F  8C 00 FF                   CMPX  #255                ; MAXIMUM OF 255 BUFFERS ALLOWED
ED62  10 22 C6 E4                LBHI  ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR IF BUFFER NUMBER > 255
ED66  9F D1                      STX   VD1                 ; SAVE THE BUFFER NUMBER
ED68  27 08                      BEQ   LED72               ; DON'T GET THE SIZE OF THE BUFFER IF BUFFER 0 SELECTED
ED6A  BD B2 6D                   JSR   SYNCOMMA            ; DO A SYNTAX CHECK FOR A COMMA
ED6D  BD B7 3D                   JSR   LB73D               ; EVALUATE THE BUFFER SIZE ARGUMENT
ED70  9F D3                      STX   VD3                 ; SAVE THE BUFFER SIZE
ED72  BD E0 CB          LED72    JSR   LE0CB               ; PUT BLOCK 6.4 INTO LOGICAL BLOCK 6 ($C000) OF TASK REGISTER 1
ED75  BD E1 19                   JSR   SELTASK1            ; ENABLE TASK REGISTER 1
ED78  DC D1                      LDD   VD1                 ; GET THE NEW BUFFER NUMBER
ED7A  5D                         TSTB                      ; CHECK FOR BUFFER ZERO
ED7B  26 08                      BNE   LED85               ; BRANCH IF NOT BUFFER ZERO
ED7D  CC FF FF                   LDD   #$FFFF              ; EMPTY BUFFER FLAG
ED80  FD C0 00                   STD   HRESBUFF            ; RESET BUFFER SPACE TO EMPTY
ED83  20 38                      BRA   LEDBD               ; EXIT COMMAND
ED85  10 8E C0 00       LED85    LDY   #HRESBUFF           ; POINT TO THE START OF THE BUFFER SPACE
ED89  EC A4                      LDD   ,Y                  ; GET THE FIRST TWO BYTES OF THE HEADER BLOCK (HB.ADDR)
ED8B  10 83 FF FF                CMPD  #$FFFF              ; IS THE BUFFER EMPTY?
ED8F  26 04                      BNE   LED95               ; NO; CHECK FOR FIRST EMPTY HEADER SPOT
ED91  8D 31                      BSR   LEDC4               ; CHECK FOR ENOUGH FREE RAM IN THE BUFFER SPACE FOR THIS BUFFER
ED93  20 1B                      BRA   LEDB0
ED95  D6 D2             LED95    LDB   VD1+1               ; GET THE BUFFER NUMBER
ED97  E1 22             LED97    CMPB  $02,Y               ; COMPARE TO THE BUFFER NUMBER OF THE CURRENT HEADER (HB.NUM)
ED99  27 37                      BEQ   LEDD2               ; RE-DIMENSIONED ARRAY (DD) ERROR IF THE SAME
ED9B  EE A4                      LDU   ,Y                  ; GET THE ADDRESS OF THE NEXT BUFFER
ED9D  27 04                      BEQ   LEDA3               ; BRANCH IF THIS IS THE LAST HEADER
ED9F  1F 32                      TFR   U,Y                 ; POINT Y TO THE START OF THE NEXT BUFFER HEADER
EDA1  20 F4                      BRA   LED97               ; KEEP SEARCHING FOR THE LAST HEADER
EDA3  1F 23             LEDA3    TFR   Y,U                 ; SAVE THE START ADDRESS OF THE LAST HEADER IN U
EDA5  EC 23                      LDD   $03,Y               ; GET THE SIZE OF THE LAST HEADER (HB.SIZE)
EDA7  31 25                      LEAY  $05,Y               ; SKIP PAST THE HEADER DATA (HB.LEN)
EDA9  31 AB                      LEAY  D,Y                 ; NOW Y POINTS TOT THE START OF FREE BUFFER SPACE
EDAB  8D 17                      BSR   LEDC4               ; CHECK FOR ENOUGH FREE RAM IN THE BUFFER SPACE FOR THIS BUFFER
EDAD  10 AF C4                   STY   ,U                  ; SAVE THE ADDRESS OF THIS HEADER IN THE PREVIOUS HEADER
EDB0  CC 00 00          LEDB0    LDD   #0                  ; LAST ENTRY FLAG
EDB3  ED A4                      STD   ,Y                  ; MAKE THIS HEADER THE LAST ENTRY
EDB5  D6 D2                      LDB   VD1+1               ; GET THE BUFFER NUMBER AND
EDB7  E7 22                      STB   $02,Y               ; SAVE IT IN THE HEADER
EDB9  DC D3                      LDD   VD3                 ; GET THE SIZE OF THE BUFFER AND
EDBB  ED 23                      STD   $03,Y               ; SAVE IT IN THE HEADER TOO
EDBD  BD E0 FF          LEDBD    JSR   SELTASK0            ; ENABLE TASK REGISTER 0
EDC0  BD E0 97                   JSR   SETMMU              ; RESET MMU REGISTERS
EDC3  39                         RTS
EDC4  1F 21             LEDC4    TFR   Y,X                 ; USE X A TEMPORARY POINTER TO THE START OF BUFFER
EDC6  30 05                      LEAX  $05,X               ; SKIP PAST THE HEADER
EDC8  DC D3                      LDD   VD3                 ; GET THE SIZE OF THE BUFFER AND
EDCA  30 8B                      LEAX  D,X                 ; ADD IT TO THE BUFFER POINTER WHICH NOW POINTS TO THE BUFFER END
EDCC  8C DF 00                   CMPX  #HRESBUFF+$1F00     ; PAST THE END OF THE BUFFER SPACE?
EDCF  22 05                      BHI   LEDD6               ; 'OM' ERROR IF PAST END OF BUFFER SPACE
EDD1  39                         RTS
EDD2  C6 12             LEDD2    LDB   #9*2                ; REDIMENSIONED ARRAY ERROR (DD)
EDD4  20 02                      BRA   LEDD8
EDD6  C6 0C             LEDD6    LDB   #6*2                ; OUT OF MEMORY ERROR (OM)
EDD8  10 CE DF FD       LEDD8    LDS   #TMPSTACK-2         ; RESET THE STACK TO TEMPORARY LOCATON
EDDC  BD E0 FF                   JSR   SELTASK0            ; ENABLE TASK REGISTER 0
EDDF  BD E0 97                   JSR   SETMMU              ; RESET THE MMU REGISTERS
EDE2  7E AC 46                   JMP   LAC46               ; JUMP TO THE ERROR HANDLER

* HGET
EDE5  8E EE C0          HGET     LDX   #LEEC0              ; POINT X TO THE HGET MOVEMENT ROUTINE
EDE8  9F D5                      STX   VD5                 ; SAVE THE MOVEMENT ROUTINE ADDRESS
EDEA  5F                         CLRB                      ; HGET FLAG
EDEB  20 07                      BRA   LEDF4

* HPUT
EDED  8E EE EF          HPUT     LDX   #LEEEF              ; HPUT MOVEMENT ROUTINE ADDRESS
EDF0  9F D5                      STX   VD5                 ; SAVE THE MOVEMENT ROUTINE ADDRESS
EDF2  C6 01                      LDB   #$01                ; HPUT FLAG
EDF4  0D E6             LEDF4    TST   HRMODE              ; IS THE HI-RES GRAPHICS MODE ENABLED?
EDF6  10 27 F8 F5                LBEQ  LE6EF               ; 'HR' ERROR IF NOT IN HI-RES MODE
EDFA  10 21 12 02                LBRN  RAMLINK             ; RAM HOOK
EDFE  D7 D8                      STB   VD8                 ; SAVE THE GET/PUT FLAG
EE00  81 40                      CMPA  #'@'                ; ALLOW HGET@, HPUT@ AS LEGAL SYNTAX
EE02  26 02                      BNE   LEE06               ; BRANCH IF NOT @
EE04  9D 9F                      JSR   GETNCH              ; GET THE NEXT CHARACTER FROM BASIC'S INPUT LINE IF @ WAS THERE
EE06  BD E9 E1          LEE06    JSR   LE9E1               ; EVALUATE THE RECTANGLE BOUNDS
EE09  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
EE0C  BD B7 0B                   JSR   EVALEXPB            ; EVALUATE EXPRESSION, RETURN VALUE IN ACCB
EE0F  D7 D3                      STB   VD3                 ; SAVE THE BUFFER NUMBER
EE11  0F D4                      CLR   VD4                 ; SET THE ACTION FLAG TO SHOW AN ACTION SPECIFIED
EE13  9D A5                      JSR   GETCCH              ; GET BASIC'S CURRENT INPUT CHARACTER
EE15  27 21                      BEQ   LEE38               ; BRANCH IF END OF LINE - NO ACTION SPECIFIED
EE17  03 D4                      COM   VD4                 ; SET THE ACTION FLAG TO SHOW THAT AN ACTION WAS SPECIFIED
EE19  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
EE1C  0D D8                      TST   VD8                 ; CHECK THE GET/PUT FLAG
EE1E  26 03                      BNE   LEE23               ; BRANCH IF PUT
EE20  16 C4 54                   LBRA  LB277               ; 'SYNTAX' ERROR - HGET MAY NOT SPECIFY AN ACTION
EE23  C6 05             LEE23    LDB   #$05                ; FIVE POSSIBLE ACTIONS
EE25  8E EE E0                   LDX   #LEEE0              ; POINT TO THE ACTION ROUTINE ADDRESS
EE28  EE 81             LEE28    LDU   ,X++                ; GET THE ACTION ROUTINE ADDRESS
EE2A  A1 80                      CMPA  ,X+                 ; COMPARE THE DESIRED ACTION TO THIS ROUTINE'S TOKEN
EE2C  27 06                      BEQ   LEE34               ; SEARCH NO MORE - A MATCH WAS FOUND
EE2E  5A                         DECB                      ; DECREMENT COUNTER
EE2F  26 F7                      BNE   LEE28               ; LOOP UNTIL ALL ACTIONS CHECKED
EE31  7E B2 77                   JMP   LB277               ; 'SYNTAX' ERROR IF ILLEGAL ACTION DESIRED
EE34  DF D5             LEE34    STU   VD5                 ; SAVE THE ACTION ADDRESS
EE36  9D 9F                      JSR   GETNCH              ; GET A CHARACTER FROM BASIC'S INPUT LINE
EE38  BD E0 CB          LEE38    JSR   LE0CB               ; PUT THE HBUFF BLOCK INTO LOGICAL ADDRESS SPACE OF TASK REGISTER 1
EE3B  BD E1 19                   JSR   SELTASK1            ; SELECT TASK REGISTER 1
EE3E  D6 D3                      LDB   VD3                 ; GET THE BUFFER NUMBER
EE40  BD EF 18                   JSR   LEF18               ; GET THE START AND END OF THIS BUFFER'S DATA
EE43  DC BD                      LDD   HORBEG              ; GET THE STARING HORIZONTAL COORDINATE
EE45  10 93 C3                   CMPD  HOREND              ; COMPARE IT TO THE ENDING COORDINATE
EE48  2F 06                      BLE   LEE50               ; BRANCH IF START <= END COORDINATE
EE4A  9E C3                      LDX   HOREND              ; GET THE ENDING COORDINATE
EE4C  9F BD                      STX   HORBEG              ; SAVE IT AS THE STARTING COORDINATE
EE4E  DD C3                      STD   HOREND              ; NOW SAVE THE STARTING COORDINATE AS THE ENDING COORDINATE
EE50  DC BF             LEE50    LDD   VERBEG              ; GET THE VERTICAL STARTING COORDINATE
EE52  10 93 C5                   CMPD  VEREND              ; COMPARE IT TO THE ENDING COORDINATE
EE55  2F 06                      BLE   LEE5D               ; BRANCH IF START <= END COORDINATE
EE57  9E C5                      LDX   VEREND              ; GET THE ENDING COORDINATE
EE59  9F BF                      STX   VERBEG              ; SAVE IT AS THE STARTING COORDINATE
EE5B  DD C5                      STD   VEREND              ; NOW SAVE THE STARTING COORDINATE AS THE ENDING COORDINATE
* ROUND OFF THE HORIZONTAL START AND END COORDINATES TO AN EVEN NUMBER OF BYTES
EE5D  96 E6             LEE5D    LDA   HRMODE              ; GET THE HI-RES GRAPHICS MODE
EE5F  C6 F8                      LDB   #$F8                ; ROUND OFF MASK FOR HSCREEN 3 (EIGHT PIXELS PER BYTE)
EE61  81 03                      CMPA  #$03                ; HSCREEN 3?
EE63  27 08                      BEQ   LEE6D
EE65  C6 FC                      LDB   #$FC                ; ROUND OFF MASK FOR HSCREEN 1 OR 4 (FOUR PIXELS PER BYTE)
EE67  81 02                      CMPA  #$02                ; HSCREEN 2?
EE69  26 02                      BNE   LEE6D               ; NO IT'S HSCREEN 1 OR 4
EE6B  C6 FE                      LDB   #$FE                ; ROUND OFF MASK FOR HSCREEN 2 (TWO PIXELS PER BYTE)
EE6D  1F 98             LEE6D    TFR   B,A                 ; SAVE MASK IN BOTH ACCA AND ACCB
EE6F  94 BE                      ANDA  HORBEG+1            ; ROUND OFF HORIZONTAL START COORDINATE
EE71  97 BE                      STA   HORBEG+1            ; SAVE NEW START COORDINATE
EE73  D4 C4                      ANDB  HOREND+1            ; ROUND OFF HORIZONTAL END COORDINATE
EE75  D7 C4                      STB   HOREND+1            ; SAVE NEW END COORDINATE
EE77  BD E9 DB                   JSR   LE9DB               ; CALCULATE THE DIFFERENCE BETWEEN THE HORIZONTAL START AND END
EE7A  DD C3                      STD   HOREND              ; SAVE THE HORIZONTAL DIFFERENCE
EE7C  BD E9 CD                   JSR   LE9CD               ; CALCULATE THE DIFFERENCE BETWEEN THE VERTICAL START AND END
EE7F  C3 00 01                   ADDD  #1                  ; ADD ONE TO THE VERTICAL DIFFERENCE (INCLUSIVE START AND END)
EE82  DD C5                      STD   VEREND              ; SAVE THE VERTICAL DIFFERENCE

* CONVERT THE HORIZONTAL DIFFERENCE (IN PIXELS) INTO A BYTE DIFFERENCE
EE84  96 E6                      LDA   HRMODE              ; GET THE HI-RES GRAPHICS MODE
EE86  81 02                      CMPA  #$02                ; HSCREEN 2?
EE88  27 0C                      BEQ   LEE96               ; YES; DIVIDE PIXEL COUNT BY TWO (TWO PIXELS PER BYTE)
EE8A  81 03                      CMPA  #$03                ; HSCREEN 3?
EE8C  26 04                      BNE   LEE92               ; NO; DIVIDE PIXEL COUNT BY FOUR (FOUR PIXELS PER BYTE)
EE8E  04 C3                      LSR   HOREND              ; * HSCREEN 3; DIVIDE PIXEL COUNT BY EIGHT (EIGHT PIXELS PER BYTE)
EE90  06 C4                      ROR   HOREND+1            ; DIVIDE THE HORIZONTAL DIFFERENCE BY 2
EE92  04 C3             LEE92    LSR   HOREND
EE94  06 C4                      ROR   HOREND+1            ; DIVIDE THE HORIZONTAL DIFFERENCE BY 2
EE96  04 C3             LEE96    LSR   HOREND
EE98  06 C4                      ROR   HOREND+1            ; DIVIDE THE HORIZONTAL DIFFERENCE BY 2
EE9A  DC C3                      LDD   HOREND
EE9C  C3 00 01                   ADDD  #1                  ; ADD ONE TO THE HORIZONTAL DIFFERENCE (INCLUSIVE START AND END)
EE9F  DD C3                      STD   HOREND              ; SAVE THE HORIZONTAL DIFFERENCE
EEA1  BD E7 DA                   JSR   HCALPOS             ; POINT X TO THE FIRST BYTE TO MOVE
EEA4  10 9E D5                   LDY   VD5                 ; POINT Y TO THE ACTION ADDRESS
EEA7  D6 C4             LEEA7    LDB   HOREND+1            ; GET THE LS BYTE OF HORIZONTAL DIFFERENCE
EEA9  34 10                      PSHS  X                   ; SAVE THE MOVEMENT POINTER
EEAB  AD A4             LEEAB    JSR   ,Y                  ; PERFORM THE APPROPRIATE MOVEMENT ACTION
EEAD  5A                         DECB                      ; DECREMENT THE HORIZONTAL MOVEMENT COUNTER
EEAE  26 FB                      BNE   LEEAB               ; LOOP UNTIL ALL BYTES ON THIS ROW MOVED
EEB0  35 10                      PULS  X                   ; RESTORE THE MOVEMENT POINTER
EEB2  BD EA 45                   JSR   LEA45               ; MOVE THE MOVEMENT POINTER DOWN ONE ROW
EEB5  0A C6                      DEC   VEREND+1            ; DECREMENT THE VERTICAL DIFFERENCE (ROW COUNTER)
EEB7  26 EE                      BNE   LEEA7               ; LOOP UNTIL ALL ROWS MOVED
EEB9  BD E0 FF                   JSR   SELTASK0            ; SELECT TASK REGISTER 0 AS THE ACTIVE TASK
EEBC  BD E0 97                   JSR   SETMMU              ; SET UP THE MMU REGISTERS
EEBF  39                         RTS                       ; WHY NOT MAKE THE JSR ABOVE A JMP

* HGET'S BYTE MOVEMENT ROUTINE
EEC0  A6 80             LEEC0    LDA   ,X+                 ; GET A BBYTE FROM THE HI-RES SCREEN
EEC2  8D 03                      BSR   LEEC7               ; POINT U TO PROPER BUFFER LOCATION
EEC4  A7 C4                      STA   ,U                  ; SAVE THE BYTE IN THE BUFFER
EEC6  39                         RTS
EEC7  DE CF             LEEC7    LDU   VCF                 ; GET THE BUFFER POINTER
EEC9  33 41                      LEAU  $01,U               ; BUMP IT UP BY ONE
EECB  DF CF                      STU   VCF                 ; SAVE IT
EECD  11 93 D1                   CMPU  VD1                 ; COMPARE THE NEW POINTER TO THE END OF THE BUFFER SPACE
EED0  22 01                      BHI   LEED3               ; 'FC' FUNCTION CALL ERROR IF PAST THE END OF THE BUFFER
EED2  39                         RTS
EED3  10 CE DF FD       LEED3    LDS   #TMPSTACK-2         ; RESET THE TEMPORARY STACK POINTER
EED7  BD E0 FF                   JSR   SELTASK0            ; SELECT TASK REGISTER 0 AS THE ACTIVE TASK
EEDA  BD E0 97                   JSR   SETMMU              ; SET UP THE MMU REGISTERS
EEDD  7E B4 4A                   JMP   ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR

EEE0  EE EF             LEEE0    FDB   LEEEF               ; ADDRESS OF PSET ACTION ROUTINE
EEE2  BD                LEEE2    FCB   $BD                 ; TOKEN FOR PSET
EEE3  EE F6             LEEE3    FDB   LEEF6               ; ADDRESS OF PRESET ACTION ROUTINE
EEE5  BE                LEEE5    FCB   $BE                 ; TOKEN FOR PRESET
EEE6  EF 07             LEEE6    FDB   LEF07               ; ADDRESS OF OR ACTION ROUTINE
EEE8  B1                LEEE8    FCB   $B1                 ; TOKEN FOR OR
EEE9  EE FE             LEEE9    FDB   LEEFE               ; ADDRESS OF AND ACTION ROUTINE
EEEB  B0                LEEEB    FCB   $B0                 ; TOKEN FOR AND
EEEC  EF 10             LEEEC    FDB   LEF10               ; ADDRESS OF NOT ACTION ROUTINE
EEEE  A8                LEEEE    FCB   $A8                 ; TOKEN FOR NOT

* HPUT'S MOVEMENT ROUTINES
* PSET (DEFAULT ROUTINE)
EEEF  8D D6             LEEEF    BSR   LEEC7               ; POINT U TO THE PROPER BUFFER LOCATION
EEF1  A6 C4                      LDA   ,U                  ; GET A BYTE FROM THE BUFFER
EEF3  A7 80                      STA   ,X+                 ; PUT IT BACK ON THE SCREEN
EEF5  39                         RTS
* PRESET
EEF6  8D CF             LEEF6    BSR   LEEC7               ; POINT U TO THE PROPER BUFFER LOCATION
EEF8  A6 C4                      LDA   ,U                  ; GET A BYTE FROM THE BUFFER
EEFA  43                         COMA
EEFB  A7 80                      STA   ,X+                 ; PUT IT BACK ON THE SCREEN
EEFD  39                         RTS
* AND
EEFE  8D C7             LEEFE    BSR   LEEC7               ; POINT U TO THE PROPER BUFFER LOCATION
EF00  A6 C4                      LDA   ,U                  ; GET A BYTE FROM THE BUFFER
EF02  A4 84                      ANDA  ,X                  ; 'AND' IT WITH THE SCREEN DATA
EF04  A7 80                      STA   ,X+                 ; PUT IT BACK ON THE SCREEN
EF06  39                         RTS
* OR
EF07  8D BE             LEF07    BSR   LEEC7               ; POINT U TO THE PROPER BUFFER LOCATION
EF09  A6 C4                      LDA   ,U                  ; GET A BYTE FROM THE BUFFER
EF0B  AA 84                      ORA   ,X                  ; 'OR' IT WITH THE SCREEN DATA
EF0D  A7 80                      STA   ,X+                 ; PUT IT BACK ON THE SCREEN
EF0F  39                         RTS
* NOT
EF10  8D B5             LEF10    BSR   LEEC7               ; POINT U TO THE PROPER BUFFER LOCATION
* THIS IS A MAJOR BUG - SHOULD BE LDA ,U
EF12  A6 84                      LDA   ,X                  ; GET A BYTE FROM THE SCREEN, SHOULD BE FROM THE BUFFER
EF14  43                         COMA                      ; COMPLEMENT THE BYTE
EF15  A7 80                      STA   ,X+                 ; PUT IT BACK ON THE SCREEN
EF17  39                         RTS

EF18  10 8E C0 00       LEF18    LDY   #HRESBUFF           ; POINT Y TO THE START OF THE BUFFER SPACE
EF1C  A6 A4                      LDA   ,Y                  ; GET THE FIRST BYTE
EF1E  81 FF                      CMPA  #$FF                ; ARE ANY BUFFERS ACTIVE?
EF20  26 0A                      BNE   LEF2C               ; YES, SEARCH FOR THE CORRECT BUFFER
EF22  7E EE D3                   JMP   LEED3               ; 'FC' ERROR IF NO BUFFERS ACTIVE
EF25  10 AE A4          LEF25    LDY   ,Y                  ; SKIP TO NEXT BUFFER
EF28  10 27 FF A7                LBEQ  LEED3               ; 'FC' ERROR IF THERE ARE NO MORE ACTIVE BUFFERS
EF2C  E1 22             LEF2C    CMPB  $02,Y               ; COMPARE THE DESIRED BUFFER TO THE CURRENT BUFFER NUMBER
EF2E  26 F5                      BNE   LEF25               ; NO, MATCH, CHECK THE NEXT BUFFER
EF30  EC 23                      LDD   $03,Y               ; GET THE SIZE OF THE SELECTED BUFFER
EF32  31 24                      LEAY  $04,Y               ; SKIP TO ONE BYTE BEFORE THE START BUFFER DATA
EF34  10 9F CF                   STY   VCF                 ; SAVE THE START OF THE BUFFER DATA
EF37  31 21                      LEAY  $01,Y               ; MOVE TO THE ACTUAL START OF DATA
EF39  31 AB                      LEAY  D,Y                 ; ADD IN THE SIZE OF THE DATA
EF3B  10 9F D1                   STY   VD1                 ; SAVE THE ADDRESS OF THE END OF THE DATA
EF3E  39                         RTS
