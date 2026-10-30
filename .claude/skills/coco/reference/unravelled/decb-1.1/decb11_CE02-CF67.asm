; Disk Extended Color BASIC 1.1 -- $CE02-$CF67
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: MKN=$CE02, LOC=$CE10, LOF=$CE37, FREE=$CE9C, DRIVE=$CEC5, DVEC15=$CED2, DXCVEC=$CF0A, DXIVEC=$CF32

* MKN$ COMMAND
CE02  BD B1 43          MKN      JSR   LB143               ; 'TM' ERROR IF VALTYP=STRING
CE05  C6 05                      LDB   #$05                ; FIVE BYTES IN A FLOATING POINT NUMBER
CE07  BD B5 0F                   JSR   LB50F               ; RESERVE FIVE BYTES IN STRING SPACE
CE0A  BD BC 35                   JSR   LBC35               ; PACK FPA0 AND STORE IT IN STRING SPACE
CE0D  7E B6 9B                   JMP   LB69B               ; SAVE STRING DESCRIPTOR ON STRING STACK

* LOC COMMAND
CE10  8D 07             LOC      BSR   LCE19               ; POINT X TO FILE BUFFER
CE12  EC 07                      LDD   FCBREC,X            ; GET RECORD NUMBER (RANDOM FILE) OR SECTOR CTR (SEQUENTIAL)
CE14  DD 52             LCE14    STD   FPA0+2              ; *SAVE ACCD IN BOTTOM 2 BYTES OF FPA0 AND
CE16  7E 88 0E                   JMP   L880E               ; *CONVERT TO FLOATING POINT NUMBER

* STRIP A DEVICE NUMBER FROM A BASIC STATEMENT, SET PRINT
* PARAMETERS ACCORDING TO IT - ERROR IF FILE NOT
* OPEN. RETURN WITH (X) POINTING TO THAT FILE'S FCB
CE19  96 6F             LCE19    LDA   DEVNUM              ; * GET CURRENT DEVICE NUMBER AND
CE1B  34 02                      PSHS  A                   ; * SAVE IT ON THE STACK
CE1D  BD B1 43                   JSR   LB143               ; 'TM' ERROR IF VALTYP=STRING
CE20  BD A5 AE                   JSR   LA5AE               ; CHECK FOR VALID DEVICE NUMBER/SET PRINT PARAMETERS
CE23  0D 6F                      TST   DEVNUM              ; * CHECK DEVICE NUMBER
CE25  10 2F E6 21                LBLE  LB44A               ; * BRANCH IF NOT DISK FILE 'ILLEGAL FUNCTION CALL'
CE29  BD C7 44                   JSR   LC744               ; POINT (X) TO FILE BUFFER
CE2C  35 02                      PULS  A                   ; * GET OLD DEVICE NUMBER OFF OF THE STACK AND
CE2E  97 6F                      STA   DEVNUM              ; * SAVE IT AS DEVICE NUMBER
CE30  6D 00                      TST   FCBTYP,X            ; IS FILE OPEN?
CE32  10 27 D5 C5                LBEQ  LA3FB               ; 'FILE NOT OPEN' ERROR IF NOT OPEN
CE36  39                         RTS

* LOF
CE37  8D E0             LOF      BSR   LCE19               ; POINT X TO FILE BUFFER
CE39  A6 01                      LDA   FCBDRV,X            ; * GET DRIVE NUMBER AND SAVE IT
CE3B  97 EB                      STA   DCDRV               ; * IN DSKCON VARIABLE
CE3D  E6 02                      LDB   FCBFGR,X            ; GET FIRST GRANULE OF FILE
CE3F  34 10                      PSHS  X                   ; SAVE FCB POINTER ON STACK
CE41  BD CD 1E                   JSR   LCD1E               ; FIND TOTAL NUMBER OF GRANULES IN THIS FILE
CE44  4A                         DECA                      ; SUBTRACT THE LAST GRANULE IN THE FILE
CE45  C4 3F                      ANDB  #$3F                ; GET NUMBER OF SECTORS USED IN LAST GRANULE
CE47  34 04                      PSHS  B                   ; SAVE NUMBER OF SECTORS IN LAST GRANULE ON STACK
CE49  1F 89                      TFR   A,B                 ; * CONVERT ACCA TO POSITIVE
CE4B  4F                         CLRA                      ; * 2 BYTE VALUE IN ACCD
CE4C  BD C7 79                   JSR   LC779               ; MULT NUMBER OF FULL GRANULES BY 9
CE4F  EB E0                      ADDB  ,S+                 ; ADD NUMBER SECTORS IN LAST TRACK
CE51  89 00                      ADCA  #$00                ; PROPAGATE CARRY TO MS BYTE OF ACCD
CE53  35 10                      PULS  X                   ; GET FCB POINTER BACK
CE55  34 02                      PSHS  A                   ; SAVE ACCA ON STACK
CE57  A6 00                      LDA   FCBTYP,X            ; * GET FILE TYPE OF THIS FCB AND
CE59  81 40                      CMPA  #RANFIL             ; * CHECK TO SEE IF IT'S A RANDOM FILE
CE5B  35 02                      PULS  A                   ; RESTORE ACCA
CE5D  26 B5                      BNE   LCE14               ; IF NOT A RANDOM FILE, THEN THE TOTAL NUMBER OF SECTORS IN THE FILE
* IS THE LENGTH OF THE FILE

* CALCULATE LOF FOR A RANDOM FILE - THE LENGTH OF A RANDOM FILE IS THE
* NUMBER OF RECORDS IN THE FILE.
CE5F  34 10                      PSHS  X                   ; SAVE FCB POINTER ON STACK
CE61  93 8A                      SUBD  ZERO                ; SUBTRACT ZERO FROM ACCD (NUMBER OF SECTORS)
CE63  27 03                      BEQ   LCE68               ; BRANCH IF ZERO SECTORS
CE65  83 00 01                   SUBD  #$0001              ; SUBTRACT ONE SECTOR - THE LAST SECTOR MAY NOT BE IOOZ USED
CE68  8D AA             LCE68    BSR   LCE14               ; PUT ACCD INTO FPA0
CE6A  D6 4F                      LDB   FP0EXP              ; GET EXPONENT OF FPA0
CE6C  27 04                      BEQ   LCE72               ; BRANCH IF FPA0 = 0
CE6E  CB 08                      ADDB  #$08                ; * ADD 8 TO EXPONENT (MULTIPLY FPA0 BY
CE70  D7 4F                      STB   FP0EXP              ; * 256 BYTES/SECTOR) AND SAVE NEW EXPONENT
CE72  BD BC 5F          LCE72    JSR   LBC5F               ; SAVE NUMBER OF BYTES IN FULL SECTORS IN FPA1
CE75  AE E4                      LDX   ,S                  ; POINT X TO FCB
CE77  EC 88 13                   LDD   FCBLST,X            ; GET NUMBER OF BYTES IN LAST SECTOR
CE7A  84 7F                      ANDA  #$7F                ; MASK OFF THE PRE-SAVED BYTE
CE7C  8D 96                      BSR   LCE14               ; PUT NUMBER BYTES IN LAST SECTOR INTO FPA0
CE7E  0F 62                      CLR   RESSGN              ; FORCE SUM SIGN = POSITIVE
CE80  96 5C                      LDA   FP1EXP              ; * GET EXPONENTS OF FPA0 AND
CE82  D6 4F                      LDB   FP0EXP              ; * FPA1 PRIOR TO ADDITION
CE84  BD B9 C5                   JSR   LB9C5               ; ADD NUMBER BYTES IN LAST SECTOR TO NUMBER OF
; BYTES IN FULL SECTORS
CE87  BD BC 5F                   JSR   LBC5F               ; SAVE TOTAL NUMBER OF BYTES IN FPA1
CE8A  35 10                      PULS  X                   ; POINT X TO FCB
CE8C  EC 09                      LDD   FCBRLN,X            ; * GET RECORD LENGTH
CE8E  8D 84                      BSR   LCE14               ; * PUT IT INTO FPA0
CE90  0F 62                      CLR   RESSGN              ; FORCE QUOTIENT SIGN = POSITIVE
CE92  96 5C                      LDA   FP1EXP              ; * GET EXPONENTS OF FPA0 AND
CE94  D6 4F                      LDB   FP0EXP              ; * FPA1 PRIOR TO DIVISION
CE96  BD BB 91                   JSR   LBB91               ; DIVIDE TOTAL NUMBER OF BYTES BY NUMBER OF BYTES IN A RECORD
CE99  7E BC EE                   JMP   INT                 ; CONVERT FPA0 TO AN INTEGER

* FREE COMMAND
CE9C  BD B1 43          FREE     JSR   LB143               ; * NUMBER TYPE CHECK
CE9F  BD B7 0E                   JSR   LB70E               ; *EVALUATE NUMERIC EXPRESSION AND RETURN VALUE IN ACCB
CEA2  C1 03                      CMPB  #$03                ; ONLY 4 LEGAL DRIVES
CEA4  10 22 D7 77                LBHI  LA61F               ; 'DEVICE NUMBER' ERROR IF DRIVE NUMBER IS > 3
CEA8  D7 EB                      STB   DCDRV               ; SAVE IN DRIVE NUMBER
CEAA  BD C7 9D                   JSR   LC79D               ; GET FILE ALLOCATION TABLE AND STORE IN BUFFER
CEAD  BD C7 55                   JSR   LC755               ; POINT X TO START OF FILE ALLOCATION TABLE BUFFER
CEB0  30 06                      LEAX  FATCON,X            ; MOVE TO FIRST GRANULE DATA BYTE
CEB2  6F E2                      CLR   ,-S                 ; SPACE FOR FREE GRANULE COUNTER
CEB4  C6 44                      LDB   #GRANMX             ; GET MAXIMUM NUMBER OF GRANULES
CEB6  A6 80             LCEB6    LDA   ,X+                 ; GET GRANULE DATA
CEB8  43                         COMA                      ; *FREE GRANULES $FF
CEB9  26 02                      BNE   LCEBD               ; *BRANCH IF NOT FREE
CEBB  6C E4                      INC   ,S                  ; INCREMENT FREE GRANULE COUNTER
CEBD  5A                LCEBD    DECB                      ; DECREMENT GRANULE COUNTER
CEBE  26 F6                      BNE   LCEB6               ; BRANCH IF NOT DONE
CEC0  35 04                      PULS  B                   ; GET FREE GRANULE COUNTER TO ACCB
CEC2  7E B4 F3                   JMP   LB4F3               ; LOAD ACCB INTO FPA0

* DRIVE COMMAND
CEC5  BD B7 0B          DRIVE    JSR   EVALEXPB            ; EVALUATE EXPR; RETURN VALUE IN ACCB
CEC8  C1 03                      CMPB  #$03                ; MAX DRIVE NUMBER = 3
CECA  10 22 D7 51                LBHI  LA61F               ; 'DEVICE #' ERROR IF DRIVE NUMBER > 3
CECE  F7 09 5A                   STB   DEFDRV              ; SAVE DEFAULT DRIVE NUMBER
CED1  39                         RTS

* EVALUATE EXPRESSION RAM VECTOR
CED2  A6 64             DVEC15   LDA   $04,S               ; = CHECK STACKED PRECEDENCE FLAG AND IF IT IS NOT AN END
CED4  26 13                      BNE   LCEE9               ; = OF OPERATION, BRANCH TO EXTENDED BASIC'S EXPRESSION
; = EVALUATION ROUTINE
CED6  AE 65                      LDX   $05,S               ; *
CED8  8C AF 9A                   CMPX  #LAF9A              ; *
CEDB  26 0C                      BNE   LCEE9               ; * CHECK TWO RETURN ADDRESSES BACK ON THE STACK
CEDD  AE 62                      LDX   $02,S               ; * TO SEE IF THE CALL TO EVALUATE EXPRESSION IS
CEDF  8C B1 66                   CMPX  #LB166              ; * COMING FROM THE 'LET' COMMAND - BRANCH OUT IF
CEE2  26 05                      BNE   LCEE9               ; * NOT COMING FROM 'LET'
CEE4  8E CE EC                   LDX   #LCEEC              ; = IF COMING FROM 'LET', REPLACE THE RETURN ADDR
CEE7  AF 65                      STX   $05,S               ; = WITH THE DISK BASIC 'LET' MODIFIER ADDRESS
CEE9  7E 88 46          LCEE9    JMP   XVEC15              ; EXTENDED BASIC EXPRESSION EVALUATION

* LET MODIFIER
CEEC  35 02                      PULS  A                   ; PULL VARIABLE TYPE OFF OF THE STACK
CEEE  46                         RORA                      ; SET CARRY IF SIRING, CLEAR CARRY IF NUMERIC
CEEF  BD B1 48                   JSR   LB148               ; DO A 'TM' CHECK
CEF2  10 27 ED 3D                LBEQ  LBC33               ; IF NUMERIC VARIABLE, PACK FPA0 INTO VARDES
CEF6  9E 52                      LDX   FPA0+2              ; POINT X TO STRING DESCRIPTOR
CEF8  EC 02                      LDD   $02,X               ; GET ADDRESS OF SIRING
CEFA  10 83 09 89                CMPD  #DFLBUF             ; * COMPARE TO START OF RANDOM FILE BUFFERS
CEFE  25 07                      BLO   LCF07               ; * AND BRANCH IF LOWER
CF00  B3 09 4A                   SUBD  FCBADR              ; SUBTRACT OUT THE END OF RANDOM FILE BUFFERS
CF03  10 25 E0 AA                LBCS  LAFB1               ; BRANCH IF STRING STORED IN RANDOM FILE BUFFER -
; MOVE IT INTO THE STRING SPACE
CF07  7E AF A4          LCF07    JMP   LAFA4               ; BRANCH BACK TO BASIC'S 'LET' COMMAND

*MODIFIER FOR EXBAS COMMAND INTERPRETATION HANDLER
CF0A  81 CA             DXCVEC   CMPA  #$CA                ; TOKEN FOR DLOAD?
CF0C  27 1C                      BEQ   LCF2A               ; YES
CF0E  81 C8                      CMPA  #$C8                ; TOKEN FOR PMODE?
CF10  10 26 B2 28                LBNE  L813C               ; NO
* DISK BASIC MODIFIER FOR PMODE - ALLOWS FOR THE RAM THE DOS USES
CF14  9D 9F                      JSR   GETNCH              ; GET NEXT CHARACTER FROM BASIC
CF16  81 2C                      CMPA  #','                ; CHECK FOR COMMA
CF18  10 27 C7 34                LBEQ  L9650               ; BRANCH IF COMMA
CF1C  BD B7 0B                   JSR   EVALEXPB            ; EVALUATE EXPRESSION; RETURN VALUE IN ACCB
CF1F  C1 04                      CMPB  #$04                ; CHECK FOR PMODE 4
CF21  10 22 E5 25                LBHI  LB44A               ; 'FC' ERROR IF PMODE > 4
CF25  96 BC                      LDA   GRPRAM              ; NUMBER BLOCKS BEFORE GRAPHICS PAGES
CF27  7E 96 2E                   JMP   L962E               ; JUMP TO EXEAS' PMODE COMMAND

* DISK BASIC DLOAD MODIFIER
CF2A  BD A4 29          LCF2A    JSR   LA429               ; CLOSE FILES
CF2D  9D 9F                      JSR   GETNCH              ; GET NEXT CHARACTER FROM BASIC
CF2F  7E 8C 1B                   JMP   L8C1B               ; JUMP TO EXEAS' DLOAD

CF32  C1 34             DXIVEC   CMPB  #($9A-$80)*2        ; MODIFIED TOKEN FOR POS
CF34  10 26 B2 30                LBNE  L8168               ; IF NOT POS, GO TO EXBAS SECONDARY COMM HANDLER
CF38  BD B2 62                   JSR   LB262               ; SYNTAX CHECK FOR '(' AND EVALUATE EXPRESSION
CF3B  96 6F                      LDA   DEVNUM              ; * GET DEVICE NUMBER AND
CF3D  34 02                      PSHS  A                   ; * SAVE IT ON STACK
CF3F  BD A5 AE                   JSR   LA5AE               ; EVALUATE DEVICE NUMBER
CF42  BD A4 06                   JSR   LA406               ; TEST DEVICE NUMBER
CF45  0D 6F                      TST   DEVNUM              ; * CHECK DEVICE NUMBER AND BRANCH
CF47  2F 13                      BLE   LCF5C               ; * IF NOT A DISK FILE
CF49  BD C7 44                   JSR   LC744               ; POINT X TO FCB
CF4C  E6 00                      LDB   FCBTYP,X            ; GET FILE TYPE
CF4E  C1 40                      CMPB  #RANFIL             ; DIRECT/RANDOM FILE?
CF50  26 0A                      BNE   LCF5C               ; BRANCH IF NOT A RANDOM FILE
CF52  35 02                      PULS  A                   ; * RESTORE DEVICE NUMBER
CF54  97 6F                      STA   DEVNUM              ; *
CF56  EC 88 17                   LDD   FCBPUT,X            ; =GRAB THE 'PUT' DATA ITEM COUNTER AND CONVERT
CF59  7E B4 F4                   JMP   GIVABF              ; =IT TO A FLOATING POINT NUMBER
CF5C  BD A3 5F          LCF5C    JSR   LA35F               ; SET PRINT PARAMETERS
CF5F  35 02                      PULS  A                   ; * RESTORE DEVICE NUMBER
CF61  97 6F                      STA   DEVNUM              ; *
CF63  D6 6C                      LDB   DEVPOS              ; =GET PRINT POSITION AND
CF65  7E B4 F3                   JMP   LB4F3               ; =CONVERT IT TO FLOATING POINT NUMBER IN FPA0
