; Disk Extended Color BASIC 1.0 -- $CD5B-$CF3E
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: LOF=$CD5B, FREE=$CDC0, DRIVE=$CDE9, DVEC15=$CDF6, DXCVEC=$CE2E, DXIVEC=$CE56

* LOF COMMAND
CD5B  8D E0             LOF      BSR   LCD3D               ; POINT X TO FILE BUFFER
CD5D  A6 01                      LDA   FCBDRV,X            ; * GET DRIVE NUMBER AND SAVE IT
CD5F  97 EB                      STA   DCDRV               ; * IN DSKCON VARIABLE
CD61  E6 02                      LDB   FCBFGR,X            ; GET FIRST GRANULE OF FILE
CD63  34 10                      PSHS  X                   ; SAVE FCB POINTER ON STACK
CD65  BD CC 44                   JSR   LCC44               ; FIND TOTAL NUMBER OF GRANULES IN THIS FILE
CD68  4A                         DECA                      ; SUBTRACT THE LAST GRANULE IN THE FILE
CD69  C4 3F                      ANDB  #$3F                ; GET NUMBER OF SECTORS USED IN LAST GRANULE
CD6B  34 04                      PSHS  B                   ; SAVE NUMBER OF SECTORS IN LAST GRANULE ON STACK
CD6D  1F 89                      TFR   A,B                 ; * CONVERT ACCA TO POSITIVE
CD6F  4F                         CLRA                      ; * 2 BYTE VALUE IN ACCD
CD70  BD C7 49                   JSR   LC749               ; MULT NUMBER OF FULL GRANULES BY 9
CD73  EB E0                      ADDB  ,S+                 ; ADD NUMBER SECTORS IN LAST TRACK
CD75  89 00                      ADCA  #$00                ; PROPAGATE CARRY TO MS BYTE OF ACCD
CD77  35 10                      PULS  X                   ; GET FCB POINTER BACK
CD79  34 02                      PSHS  A                   ; SAVE ACCA ON STACK
CD7B  A6 00                      LDA   FCBTYP,X            ; * GET FILE TYPE OF THIS FCB AND
CD7D  81 40                      CMPA  #RANFIL             ; * CHECK TO SEE IF IT'S A RANDOM FILE
CD7F  35 02                      PULS  A                   ; RESTORE ACCA
CD81  26 B7                      BNE   LCD3A               ; *IF NOT A RANDOM FILE, THEN THE TOTAL NUMBER OF SECTORS IN THE FILE
* *IS THE LENGTH OF THE FILE

* CALCULATE LOF FOR A RANDOM FILE - THE LENGTH OF A RANDOM FILE IS THE
* NUMBER OF RECORDS IN THE FILE.
CD83  34 10                      PSHS  X                   ; SAVE FCB POINTER ON STACK
CD85  93 8A                      SUBD  ZERO                ; SUBTRACT ZERO FROM ACCD (NUMBER OF SECTORS)
CD87  27 03                      BEQ   LCD8C               ; BRANCH IF ZERO SECTORS
CD89  83 00 01                   SUBD  #$0001              ; SUBTRACT ONE SECTOR - THE LAST SECTOR MAY NOT BE IOOZ USED
CD8C  8D AC             LCD8C    BSR   LCD3A               ; PUT ACCD INTO FPA0
CD8E  D6 4F                      LDB   FP0EXP              ; GET EXPONENT OF FPA0
CD90  27 04                      BEQ   LCD96               ; BRANCH IF FPA0 = 0
CD92  CB 08                      ADDB  #$08                ; * ADD 8 TO EXPONENT (MULTIPLY FPA0 BY
CD94  D7 4F                      STB   FP0EXP              ; * 256 BYTES/SECTOR) AND SAVE NEW EXPONENT
CD96  BD BC 5F          LCD96    JSR   LBC5F               ; SAVE NUMBER OF BYTES IN FULL SECTORS IN FPA1
CD99  AE E4                      LDX   ,S                  ; POINT X TO FCB
CD9B  EC 88 13                   LDD   FCBLST,X            ; GET NUMBER OF BYTES IN LAST SECTOR
CD9E  84 7F                      ANDA  #$7F                ; MASK OFF THE PRE-SAVED BYTE
CDA0  8D 98                      BSR   LCD3A               ; PUT NUMBER BYTES IN LAST SECTOR INTO FPA0
CDA2  0F 62                      CLR   RESSGN              ; FORCE SUM SIGN = POSITIVE
CDA4  96 5C                      LDA   FP1EXP              ; * GET EXPONENTS OF FPA0 AND
CDA6  D6 4F                      LDB   FP0EXP              ; * FPA1 PRIOR TO ADDITION
CDA8  BD B9 C5                   JSR   LB9C5               ; =ADD NUMBER BYTES IN LAST SECTOR TO NUMBER OF
* =BYTES IN FULL SECTORS
CDAB  BD BC 5F                   JSR   LBC5F               ; SAVE TOTAL NUMBER OF BYTES IN FPA1
CDAE  35 10                      PULS  X                   ; POINT X TO FCB
CDB0  EC 09                      LDD   FCBRLN,X            ; * GET RECORD LENGTH
CDB2  8D 86                      BSR   LCD3A               ; * PUT IT INTO FPA0
CDB4  0F 62                      CLR   RESSGN              ; FORCE QUOTIENT SIGN = POSITIVE
CDB6  96 5C                      LDA   FP1EXP              ; * GET EXPONENTS OF FPA0 AND
CDB8  D6 4F                      LDB   FP0EXP              ; * FPA1 PRIOR TO DIVISION
CDBA  BD BB 91                   JSR   LBB91               ; DIVIDE TOTAL NUMBER OF BYTES BY NUMBER OF BYTES IN A RECORD
CDBD  7E BC EE                   JMP   INT                 ; CONVERT FPA0 TO AN INTEGER

* FREE COMMAND
CDC0  BD B1 43          FREE     JSR   LB143               ; * NUMBER TYPE CHECK
CDC3  BD B7 0E                   JSR   LB70E               ; *EVALUATE NUMERIC EXPRESSION AND RETURN VALUE IN ACCB
CDC6  C1 03                      CMPB  #$03                ; ONLY 4 LEGAL DRIVES
CDC8  10 22 D8 53                LBHI  LA61F               ; 'DEVICE NUMBER' ERROR IF DRIVE NUMBER IS > 3
CDCC  D7 EB                      STB   DCDRV               ; SAVE IN DRIVE NUMBER
CDCE  BD C7 6D                   JSR   LC76D               ; GET FILE ALLOCATION TABLE AND STORE IN BUFFER
CDD1  BD C7 25                   JSR   LC725               ; POINT X TO START OF FILE ALLOCATION TABLE BUFFER
CDD4  30 06                      LEAX  FATCON,X            ; MOVE TO FIRST GRANULE DATA BYTE
CDD6  6F E2                      CLR   ,-S                 ; SPACE FOR FREE GRANULE COUNTER
CDD8  C6 44                      LDB   #GRANMX             ; GET MAXIMUM NUMBER OF GRANULES
CDDA  A6 80             LCDDA    LDA   ,X+                 ; GET GRANULE DATA
CDDC  43                         COMA                      ; *FREE GRANULES $FF
CDDD  26 02                      BNE   LCDE1               ; *BRANCH IF NOT FREE
CDDF  6C E4                      INC   ,S                  ; INCREMENT FREE GRANULE COUNTER
CDE1  5A                LCDE1    DECB                      ; DECREMENT GRANULE COUNTER
CDE2  26 F6                      BNE   LCDDA               ; BRANCH IF NOT DONE
CDE4  35 04                      PULS  B                   ; GET FREE GRANULE COUNTER TO ACCB
CDE6  7E B4 F3                   JMP   LB4F3               ; LOAD ACCB INTO FPA0

* DRIVE COMMAND
CDE9  BD B7 0B          DRIVE    JSR   EVALEXPB            ; EVALUATE EXPR; RETURN VALUE IN ACCB
CDEC  C1 03                      CMPB  #$03                ; MAX DRIVE NUMBER = 3
CDEE  10 22 D8 2D                LBHI  LA61F               ; 'DEVICE #' ERROR IF DRIVE NUMBER > 3
CDF2  F7 09 5A                   STB   DEFDRV              ; SAVE DEFAULT DRIVE NUMBER
CDF5  39                         RTS

* EVALUATE EXPRESSION RAM VECTOR
CDF6  A6 64             DVEC15   LDA   $04,S               ; = CHECK STACKED PRECEDENCE FLAG AND IF IT IS NOT AN END
CDF8  26 13                      BNE   LCE0D               ; = OF OPERATION, BRANCH TO EXTENDED BASIC'S EXPRESSION
* = EVALUATION ROUTINE
CDFA  AE 65                      LDX   $05,S               ; *
CDFC  8C AF 9A                   CMPX  #LAF9A              ; *
CDFF  26 0C                      BNE   LCE0D               ; * CHECK TWO RETURN ADDRESSES BACK ON THE STACK
CE01  AE 62                      LDX   $02,S               ; * TO SEE IF THE CALL TO EVALUATE EXPRESSION IS
CE03  8C B1 66                   CMPX  #LB166              ; * COMING FROM THE 'LET' COMMAND - BRANCH OUT IF
CE06  26 05                      BNE   LCE0D               ; * NOT COMING FROM 'LET'
CE08  8E CE 10                   LDX   #LCE10              ; = IF COMING FROM 'LET', REPLACE THE RETURN ADDR
CE0B  AF 65                      STX   $05,S               ; = WITH THE DISK BASIC 'LET' MODIFIER ADDRESS
CE0D  7E 88 46          LCE0D    JMP   XVEC15              ; EXTENDED BASIC EXPRESSION EVALUATION

* LET MODIFIER
CE10  35 02             LCE10    PULS  A                   ; PULL VARIABLE TYPE OFF OF THE STACK
CE12  46                         RORA                      ; SET CARRY IF SIRING, CLEAR CARRY IF NUMERIC
CE13  BD B1 48                   JSR   LB148               ; DO A 'TM' CHECK
CE16  10 27 EE 19                LBEQ  LBC33               ; IF NUMERIC VARIABLE, PACK FPA0 INTO VARDES
CE1A  9E 52                      LDX   FPA0+2              ; POINT X TO STRING DESCRIPTOR
CE1C  EC 02                      LDD   $02,X               ; GET ADDRESS OF SIRING
CE1E  10 83 09 89                CMPD  #DFLBUF             ; * COMPARE TO START OF RANDOM FILE BUFFERS
CE22  25 07                      BLO   LCE2B               ; * AND BRANCH IF LOWER
CE24  B3 09 4A                   SUBD  FCBADR              ; SUBTRACT OUT THE END OF RANDOM FILE BUFFERS
CE27  10 25 E1 86                LBCS  LAFB1               ; *BRANCH IF STRING STORED IN RANDOM FILE BUFFER -
* *MOVE IT INTO THE STRING SPACE
CE2B  7E AF A4          LCE2B    JMP   LAFA4               ; BRANCH BACK TO BASIC'S 'LET' COMMAND

*MODIFIER FOR EXBAS COMMAND INTERPRETATION HANDLER
CE2E  81 CA             DXCVEC   CMPA  #$CA                ; TOKEN FOR DLOAD?
CE30  27 1C                      BEQ   LCE4E               ; YES
CE32  81 C8                      CMPA  #$C8                ; TOKEN FOR PMODE?
CE34  10 26 B3 04                LBNE  L813C               ; NO
* DISK BASIC MODIFIER FOR PMODE - ALLOWS FOR THE RAM THE DOS USES
CE38  9D 9F                      JSR   GETNCH              ; GET NEXT CHARACTER FROM BASIC
CE3A  81 2C                      CMPA  #','                ; CHECK FOR COMMA
CE3C  10 27 C8 10                LBEQ  L9650               ; BRANCH IF COMMA
CE40  BD B7 0B                   JSR   EVALEXPB            ; EVALUATE EXPRESSION; RETURN VALUE IN ACCB
CE43  C1 04                      CMPB  #$04                ; CHECK FOR PMODE 4
CE45  10 22 E6 01                LBHI  LB44A               ; 'FC' ERROR IF PMODE > 4
CE49  96 BC                      LDA   GRPRAM              ; NUMBER BLOCKS BEFORE GRAPHICS PAGES
CE4B  7E 96 2E                   JMP   L962E               ; JUMP TO EXEAS' PMODE COMMAND

* DISK BASIC DLOAD MODIFIER
CE4E  BD A4 29          LCE4E    JSR   LA429               ; CLOSE FILES
CE51  9D 9F                      JSR   GETNCH              ; GET NEXT CHARACTER FROM BASIC
CE53  7E 8C 1B                   JMP   L8C1B               ; JUMP TO EXEAS' DLOAD

CE56  C1 34             DXIVEC   CMPB  #($9A-$80)*2        ; MODIFIED TOKEN FOR POS
CE58  10 26 B3 0C                LBNE  L8168               ; IF NOT POS, GO TO EXBAS SECONDARY COMM HANDLER
CE5C  BD B2 62                   JSR   LB262               ; SYNTAX CHECK FOR '(' AND EVALUATE EXPRESSION
CE5F  96 6F                      LDA   DEVNUM              ; * GET DEVICE NUMBER AND
CE61  34 02                      PSHS  A                   ; * SAVE IT ON STACK
CE63  BD A5 AE                   JSR   LA5AE               ; EVALUATE DEVICE NUMBER
CE66  BD A4 06                   JSR   LA406               ; TEST DEVICE NUMBER
CE69  0D 6F                      TST   DEVNUM              ; * CHECK DEVICE NUMBER AND BRANCH
CE6B  2F 13                      BLE   LCE80               ; * IF NOT A DISK FILE
CE6D  BD C7 14                   JSR   LC714               ; POINT X TO FCB
CE70  E6 00                      LDB   FCBTYP,X            ; GET FILE TYPE
CE72  C1 40                      CMPB  #RANFIL             ; DIRECT/RANDOM FILE?
CE74  26 0A                      BNE   LCE80               ; BRANCH IF NOT A RANDOM FILE
CE76  35 02                      PULS  A                   ; * RESTORE DEVICE NUMBER
CE78  97 6F                      STA   DEVNUM              ; *
CE7A  EC 88 17                   LDD   FCBPUT,X            ; =GRAB THE 'PUT' DATA ITEM COUNTER AND CONVERT
CE7D  7E B4 F4                   JMP   GIVABF              ; =IT TO A FLOATING POINT NUMBER
CE80  BD A3 5F          LCE80    JSR   LA35F               ; SET PRINT PARAMETERS
CE83  35 02                      PULS  A                   ; * RESTORE DEVICE NUMBER
CE85  97 6F                      STA   DEVNUM              ; *
CE87  D6 6C                      LDB   DEVPOS              ; =GET PRINT POSITION AND
CE89  7E B4 F3                   JMP   LB4F3               ; =CONVERT IT TO FLOATING POINT NUMBER IN FPA0

* SAVEM COMMAND
CE8C  9D 9F             LCE8C    JSR   GETNCH              ; GET NEXT INPUT CHARACTER
CE8E  8D 4F                      BSR   LCEDF               ; GET FILENAME, ETC.
CE90  BD 83 6C                   JSR   L836C               ; EVALUATE EXPRESSION, PUT II (2 BYTES) ON STACK
CE93  BD 83 6C                   JSR   L836C               ; DITTO
CE96  AC 62                      CMPX  $02,S               ; COMPARE END ADDRESS TO START ADDRESS
CE98  10 25 E5 AE                LBCS  LB44A               ; IF START > END, THEN 'ILLEGAL FUNCTION CALL'
CE9C  BD 83 6C                   JSR   L836C               ; EVAL EXPRESSION (TRANSFER ADDRESS), PUT ON STACK
CE9F  BD A5 C7                   JSR   LA5C7               ; SYNTAX ERROR IF ANY MORE CHARS ON THIS LINE
CEA2  CC 02 00                   LDD   #$0200              ; * FILE TYPE=2, ASCII FLAG = CRUNCHED (0)
CEA5  FD 09 57                   STD   DFLTYP              ; *
CEA8  BD C9 56                   JSR   LC956               ; GET NEXT UNOPEN FILE AND INITIALIZE FCB
CEAB  4F                         CLRA                      ; *ZERO FLAG - FIRST BYTE OF PREAMBLE
CEAC  8D 2B                      BSR   LCED9               ; *WRITE A BYTE TO BUFFER
CEAE  EC 62                      LDD   $02,S               ; GET END ADDRESS
CEB0  A3 64                      SUBD  $04,S               ; SUBTRACT THE START ADDRESS
CEB2  C3 00 01                   ADDD  #$0001              ; THE SAVED DATA BLOCK WILL INCLUDE BOTH THE FIRST AND LAST BYTES
CEB5  1F 02                      TFR   D,Y                 ; SAVE LENGTH IN Y
CEB7  8D 1E                      BSR   LCED7               ; WRITE FILE LENGTH TO BUFFER - FIRST ARGUMENT OF PREAMBLE
CEB9  EC 64                      LDD   $04,S               ; GET THE START ADDRESS
CEBB  8D 1A                      BSR   LCED7               ; WRITE OUT THE START ADDRESS - SECOND PREAMBLE ARGUMENT
CEBD  AE 64                      LDX   $04,S               ; GET START ADDRESS
CEBF  A6 80             LCEBF    LDA   ,X+                 ; GRAB A BYTE
CEC1  BD CB 52                   JSR   LCB52               ; WRITE IT OUT
CEC4  31 3F                      LEAY  -1,Y                ; DECREMENT BYTE COUNTER
CEC6  26 F7                      BNE   LCEBF               ; BRANCH IF ALL BYTES NOT DONE
CEC8  86 FF                      LDA   #$FF                ; FIRST BYTE OF POSTAMBLE
CECA  8D 0D                      BSR   LCED9               ; WRITE IT OUT - EOF RECORD
CECC  4F                         CLRA                      ; * FIRST ARGUMENT OF POSTAMBLE IS
CECD  5F                         CLRB                      ; * A DUMMY - ZERO VALUE
CECE  8D 07                      BSR   LCED7               ; WRITE OUT POSTAMBLE FIRST ARGUMENT
CED0  35 36                      PULS  A,B,X,Y             ; GET CONTROL ADDRESSES FROM THE STACK
CED2  8D 03                      BSR   LCED7               ; WRITE OUT THE TRANSFER ADDRESS - 2ND ARGUMENT
CED4  7E A4 2D                   JMP   LA42D               ; GO CLOSE ALL FILES

* WRITE ACCD TO THE BUFFER
CED7  8D 00             LCED7    BSR   LCED9               ; WRITE ACCA TO BUFFER, THEN SWAP ACCA,ACCB
CED9  BD CB 52          LCED9    JSR   LCB52               ; WRITE ACCA TO BUFFER
CEDC  1E 89                      EXG   A,B                 ; SWAP ACCA,ACCB
CEDE  39                         RTS
CEDF  8E C2 97          LCEDF    LDX   #BINEXT             ; POINT TO .BIN EXTENSION
CEE2  7E C8 8A                   JMP   LC88A               ; GET FILENAME, ETC.

* LOADM COMMAND
CEE5  9D 9F             LCEE5    JSR   GETNCH              ; GET NEXT INPUT CHARACTER
CEE7  8D F6                      BSR   LCEDF               ; GET FILENAME, ETC.
CEE9  BD C9 59                   JSR   LC959               ; OPEN NEXT AVAILABLE FILE FOR INPUT
CEEC  FC 09 57                   LDD   DFLTYP              ; GET FILE TYPE AND ASCII FLAG
CEEF  83 02 00                   SUBD  #$0200              ; FOR LOADM FILE: TYPE=2, ASCII FLAG=0
CEF2  10 26 D7 20                LBNE  LA616               ; 'BAD FILE MODE' ERROR
CEF6  9E 8A                      LDX   ZERO                ; ZERO OUT X REG - DEFAULT VALUE OF OFFSET
CEF8  9D A5                      JSR   GETCCH              ; GET CURRENT CHARACTER FROM BASIC
CEFA  27 06                      BEQ   LCF02               ; BRANCH IF END OF LINE - NO OFFSET
CEFC  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
CEFF  BD B7 3D                   JSR   LB73D               ; EVALUATE EXPRESSION
CF02  9F D3             LCF02    STX   VD3                 ; STORE OFFSET IN VD3
CF04  BD A5 C7                   JSR   LA5C7               ; SYNTAX ERROR IF OTHER CHARACTERS ON LINE

* GET PREAMBLE/POSTAMBLE
CF07  BD CC E2          LCF07    JSR   LCCE2               ; GET FIRST BYTE
CF0A  34 02                      PSHS  A                   ; SAVE IT ON THE STACK
CF0C  8D 29                      BSR   LCF37               ; GET FIRST ARGUMENT
CF0E  1F 02                      TFR   D,Y                 ; SAVE IT IN Y
CF10  8D 25                      BSR   LCF37               ; GET THE SECOND ARGUMENT
CF12  D3 D3                      ADDD  VD3                 ; ADD IT TO THE OFFSET
CF14  DD 9D                      STD   EXECJP              ; STORE IT IN THE JUMP ADDRESS OF THE EXEC COMMAND
CF16  1F 01                      TFR   D,X                 ; SAVE IT IN X
CF18  A6 E0                      LDA   ,S+                 ; GET THE FIRST BYTE OFF OF THE STACK
CF1A  10 26 D5 0F                LBNE  LA42D               ; CLOSE FILE IF POSTAMBLE (EOF)

* GET RECORD BYTE(S)
CF1E  BD C5 97          LCF1E    JSR   LC597               ; GET BYTE FROM BUFFER
CF21  D6 70                      LDB   CINBFL              ; GET STATUS OF CONSOLE IN BUFFER
CF23  27 03                      BEQ   LCF28               ; BRANCH IF BUFFER NOT EMPTY
CF25  7E C3 34                   JMP   LC334               ; 'INPUT PAST END OF FILE' ERROR
CF28  A7 84             LCF28    STA   ,X                  ; STORE BYTE IN MEMORY
CF2A  A1 80                      CMPA  ,X+                 ; *TEST TO SEE IF IT STORED PROPERLY AND
CF2C  27 03                      BEQ   LCF31               ; *BRANCH IF PROPER STORE (NOT IN ROM OR BAD RAM)
CF2E  7E D6 16                   JMP   LD616               ; 'I/O ERROR' IF BAD STORE
CF31  31 3F             LCF31    LEAY  -1,Y                ; DECREMENT BYTE COUNT
CF33  26 E9                      BNE   LCF1E               ; GET NEXT BYTE IF NOT DONE
CF35  20 D0                      BRA   LCF07               ; READ ANOTHER PRE/POST AMBLE
* READ TWO BYTES FROM BUFFER - RETURN THEM IN ACCD
CF37  8D 00             LCF37    BSR   LCF39               ; READ A BYTE, SAVE IT IN ACCB
CF39  BD CC E2          LCF39    JSR   LCCE2               ; GET A CHARACTER FROM INPUT BUFFER, RETURN IT IN ACCA
CF3C  1E 89                      EXG   A,B                 ; SWAP ACCA,ACCB
CF3E  39                         RTS
