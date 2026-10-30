; Disk Extended Color BASIC 1.1 -- $CF68-$D15B
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: LCF568=$CF68, RENAME=$D01B, WRITE=$D066, FIELD=$D0BC, RSET=$D101, LSET=$D102

* SAVEM COMMAND
CF68  9D 9F             LCF568   JSR   GETNCH              ; GET NEXT INPUT CHARACTER
CF6A  8D 4F                      BSR   LCFBB               ; GET FILENAME, ETC.
CF6C  BD 83 6C                   JSR   L836C               ; EVALUATE EXPRESSION, PUT II (2 BYTES) ON STACK
CF6F  BD 83 6C                   JSR   L836C               ; DITTO
CF72  AC 62                      CMPX  $02,S               ; COMPARE END ADDRESS TO START ADDRESS
CF74  10 25 E4 D2                LBCS  LB44A               ; IF START > END, THEN 'ILLEGAL FUNCTION CALL'
CF78  BD 83 6C                   JSR   L836C               ; EVAL EXPRESSION (TRANSFER ADDRESS), PUT ON STACK
CF7B  BD A5 C7                   JSR   LA5C7               ; SYNTAX ERROR IF ANY MORE CHARS ON THIS LINE
CF7E  CC 02 00                   LDD   #$0200              ; * FILE TYPE=2, ASCII FLAG = CRUNCHED (0)
CF81  FD 09 57                   STD   DFLTYP              ; *
CF84  BD CA 04                   JSR   LCA04               ; GET NEXT UNOPEN FILE AND INITIALIZE FCB
CF87  4F                         CLRA                      ; *ZERO FLAG - FIRST BYTE OF PREAMBLE
CF88  8D 2B                      BSR   LCFB5               ; *WRITE A BYTE TO BUFFER
CF8A  EC 62                      LDD   $02,S               ; GET END ADDRESS
CF8C  A3 64                      SUBD  $04,S               ; SUBTRACT THE START ADDRESS
CF8E  C3 00 01                   ADDD  #$0001              ; THE SAVED DATA BLOCK WILL INCLUDE BOTH THE FIRST AND LAST BYTES
CF91  1F 02                      TFR   D,Y                 ; SAVE LENGTH IN Y
CF93  8D 1E                      BSR   LCFB3               ; WRITE FILE LENGTH TO BUFFER - FIRST ARGUMENT OF PREAMBLE
CF95  EC 64                      LDD   $04,S               ; GET THE START ADDRESS
CF97  8D 1A                      BSR   LCFB3               ; WRITE OUT THE START ADDRESS - SECOND PREAMBLE ARGUMENT
CF99  AE 64                      LDX   $04,S               ; GET START ADDRESS
CF9B  A6 80             LCF9B    LDA   ,X+                 ; GRAB A BYTE
CF9D  BD CC 24                   JSR   LCC24               ; WRITE IT OUT
CFA0  31 3F                      LEAY  -1,Y                ; DECREMENT BYTE COUNTER
CFA2  26 F7                      BNE   LCF9B               ; BRANCH IF ALL BYTES NOT DONE
CFA4  86 FF                      LDA   #$FF                ; FIRST BYTE OF POSTAMBLE
CFA6  8D 0D                      BSR   LCFB5               ; WRITE IT OUT - EOF RECORD
CFA8  4F                         CLRA                      ; * FIRST ARGUMENT OF POSTAMBLE IS
CFA9  5F                         CLRB                      ; * A DUMMY - ZERO VALUE
CFAA  8D 07                      BSR   LCFB3               ; WRITE OUT POSTAMBLE FIRST ARGUMENT
CFAC  35 36                      PULS  A,B,X,Y             ; GET CONTROL ADDRESSES FROM THE STACK
CFAE  8D 03                      BSR   LCFB3               ; WRITE OUT THE TRANSFER ADDRESS - 2ND ARGUMENT
CFB0  7E A4 2D                   JMP   LA42D               ; GO CLOSE ALL FILES

* WRITE ACCD TO THE BUFFER
CFB3  8D 00             LCFB3    BSR   LCFB5               ; WRITE ACCA TO BUFFER, THEN SWAP ACCA,ACCB
CFB5  BD CC 24          LCFB5    JSR   LCC24               ; WRITE ACCA TO BUFFER
CFB8  1E 89                      EXG   A,B                 ; SWAP ACCA,ACCB
CFBA  39                         RTS
CFBB  8E C2 AF          LCFBB    LDX   #BINEXT             ; POINT TO .BIN EXTENSION
CFBE  7E C9 38                   JMP   LC938               ; GET FILENAME, ETC.

* LOADM COMMAND
CFC1  9D 9F             LCFC1    JSR   GETNCH              ; GET NEXT INPUT CHARACTER
CFC3  8D F6                      BSR   LCFBB               ; GET FILENAME, ETC.
CFC5  BD CA 07                   JSR   LCA07               ; OPEN NEXT AVAILABLE FILE FOR INPUT
CFC8  FC 09 57                   LDD   DFLTYP              ; GET FILE TYPE AND ASCII FLAG
CFCB  83 02 00                   SUBD  #$0200              ; FOR LOADM FILE: TYPE=2, ASCII FLAG=0
CFCE  10 26 D6 44                LBNE  LA616               ; 'BAD FILE MODE' ERROR
CFD2  9E 8A                      LDX   ZERO                ; ZERO OUT X REG - DEFAULT VALUE OF OFFSET
CFD4  9D A5                      JSR   GETCCH              ; GET CURRENT CHARACTER FROM BASIC
CFD6  27 06                      BEQ   LCFDE               ; BRANCH IF END OF LINE - NO OFFSET
CFD8  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
CFDB  BD B7 3D                   JSR   LB73D               ; EVALUATE EXPRESSION
CFDE  9F D3             LCFDE    STX   VD3                 ; STORE OFFSET IN VD3
CFE0  BD A5 C7                   JSR   LA5C7               ; SYNTAX ERROR IF OTHER CHARACTERS ON LINE

* GET PREAMBLE/POSTAMBLE
CFE3  BD CD BC          LCFE3    JSR   LCDBC               ; GET FIRST BYTE
CFE6  34 02                      PSHS  A                   ; SAVE IT ON THE STACK
CFE8  8D 29                      BSR   LD013               ; GET FIRST ARGUMENT
CFEA  1F 02                      TFR   D,Y                 ; SAVE IT IN Y
CFEC  8D 25                      BSR   LD013               ; GET THE SECOND ARGUMENT
CFEE  D3 D3                      ADDD  VD3                 ; ADD IT TO THE OFFSET
CFF0  DD 9D                      STD   EXECJP              ; STORE IT IN THE JUMP ADDRESS OF THE EXEC COMMAND
CFF2  1F 01                      TFR   D,X                 ; SAVE IT IN X
CFF4  A6 E0                      LDA   ,S+                 ; GET THE FIRST BYTE OFF OF THE STACK
CFF6  10 26 D4 33                LBNE  LA42D               ; CLOSE FILE IF POSTAMBLE (EOF)

* GET RECORD BYTE(S)
CFFA  BD C5 C4          LCFFA    JSR   LC5C4               ; GET BYTE FROM BUFFER
CFFD  D6 70                      LDB   CINBFL              ; GET STATUS OF CONSOLE IN BUFFER
CFFF  27 03                      BEQ   LD004               ; BRANCH IF BUFFER NOT EMPTY
D001  7E C3 52                   JMP   LC352               ; 'INPUT PAST END OF FILE' ERROR
D004  A7 84             LD004    STA   ,X                  ; STORE BYTE IN MEMORY
D006  A1 80                      CMPA  ,X+                 ; *TEST TO SEE IF IT STORED PROPERLY AND
D008  27 03                      BEQ   LD00D               ; *BRANCH IF PROPER STORE (NOT IN ROM OR BAD RAM)
D00A  7E D7 09                   JMP   LD709               ; 'I/O ERROR' IF BAD STORE
D00D  31 3F             LD00D    LEAY  -1,Y                ; DECREMENT BYTE COUNT
D00F  26 E9                      BNE   LCFFA               ; GET NEXT BYTE IF NOT DONE
D011  20 D0                      BRA   LCFE3               ; READ ANOTHER PRE/POST AMBLE
* READ TWO BYTES FROM BUFFER - RETURN THEM IN ACCD
D013  8D 00             LD013    BSR   LD015               ; READ A BYTE, SAVE IT IN ACCB
D015  BD CD BC          LD015    JSR   LCDBC               ; GET A CHARACTER FROM INPUT BUFFER, RETURN IT IN ACCA
D018  1E 89                      EXG   A,B                 ; SWAP ACCA,ACCB
D01A  39                         RTS

* RENAME COMMAND
D01B  9E A6             RENAME   LDX   CHARAD              ; * SAVE CURRENT INPUT POINTER
D01D  34 10                      PSHS  X                   ; * ON THE STACK
D01F  8D 35                      BSR   LD056               ; GET FILENAME OF SOURCE FILE
D021  96 EB                      LDA   DCDRV               ; * SAVE DRIVE NUMBER
D023  34 02                      PSHS  A                   ; * ON THE STACK
D025  8D 2A                      BSR   LD051               ; SYNTAX CHECK FOR 'TO' AND GET NEW FILENAME
D027  35 02                      PULS  A                   ; GET SOURCE DRIVE NUMBER
D029  91 EB                      CMPA  DCDRV               ; COMPARE TO NEW FILE DRIVE NUMBER
D02B  10 26 E4 1B                LBNE  LB44A               ; 'FC' ERROR IF FlIES ON DIFFERENT DRIVES
D02F  8D 28                      BSR   LD059               ; VERIFY THAT NEW FILE DOES NOT ALREADY EXIST
D031  35 10                      PULS  X                   ; * RESTORE INPUT POINTER
D033  9F A6                      STX   CHARAD              ; *
D035  8D 1F                      BSR   LD056               ; GET SOURCE FILENAME AGAIN
D037  BD C6 8C                   JSR   LC68C               ; SCAN DIRECTORY FOR SOURCE FILENAME
D03A  BD C6 E5                   JSR   LC6E5               ; 'NE' ERROR IF NOT FOUND
D03D  8D 12                      BSR   LD051               ; SYNTAX CHECK FOR 'TO' AND GET NEW FILENAME
D03F  8E 09 4C                   LDX   #DNAMBF             ; POINT X TO FILENAME
D042  FE 09 74                   LDU   V974                ; POINT U TO DIRECTORY ENTRY OF SOURCE FILE
D045  C6 0B                      LDB   #$0B                ; 11 CHARACTERS IN FILENAME AND EXTENSION
D047  BD A5 9A                   JSR   LA59A               ; COPY NEW FILENAME TO SOURCE FILE DIRECTORY RAM IMAGE
D04A  C6 03                      LDB   #$03                ; * GET WRITE OP CODE AND
D04C  D7 EA                      STB   DCOPC               ; * SAVE IN DSKCON VARIABLE
D04E  7E D6 F2                   JMP   LD6F2               ; WRITE NEW DIRECTORY SECTOR

* DO A SYNTAX CHECK FOR 'TO' AND STRIP A FILENAME FROM BASIC
D051  C6 A5             LD051    LDB   #$A5                ; 'TO' TOKEN
D053  BD B2 6F                   JSR   LB26F               ; SYNTAX CHECK FOR 'TO'
D056  7E C9 35          LD056    JMP   LC935               ; GET FILENAME FROM BASIC
D059  BD C6 8C          LD059    JSR   LC68C               ; SCAN DIRECTORY FOR FILENAME
D05C  C6 42                      LDB   #33*2               ; 'FILE ALREADY EXISTS' ERROR
D05E  7D 09 73                   TST   V973                ; CHECK FOR A MATCH
D061  10 26 DB E1                LBNE  LAC46               ; 'AE' ERROR IF FILE IN DIRECTORY
D065  39                         RTS

* WRITE COMMAND
D066  10 27 E8 EE       WRITE    LBEQ  LB958               ; PRINT CARRIAGE RETURN TO CONSOLE OUT IF END OF LINE
D06A  8D 03                      BSR   LD06F               ; GO WRITE AN ITEM LIST
D06C  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
D06E  39                LD06E    RTS
D06F  81 23             LD06F    CMPA  #'#'                ; CHECK FOR DEVICE NUMBER FLAG
D071  26 0F                      BNE   LD082               ; DEFAULT TO CURRENT DEVICE NUMBER IF NONE GIVEN
D073  BD A5 A5                   JSR   LA5A5               ; SET DEVICE NUMBER; CHECK VALIDITY
D076  BD A4 06                   JSR   LA406               ; MAKE SURE SELECTED FILE IS AN OUTPUT FILE
D079  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
D07B  10 27 E8 D9                LBEQ  LB958               ; PRINT CR TO CONSOLE OUT IF END OF LINE
D07F  BD B2 6D          LD07F    JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
D082  BD B1 56          LD082    JSR   LB156               ; EVALUATE EXPRESSION
D085  96 06                      LDA   VALTYP              ; GET VARIABLE TYPE
D087  26 1E                      BNE   LD0A7               ; BRANCH IF STRING
D089  BD BD D9                   JSR   LBDD9               ; CONVERT FP NUMBER TO ASCII STRING
D08C  BD B5 16                   JSR   LB516               ; PUT ON TEMPORARY STRING STACK
D08F  BD B9 9F                   JSR   LB99F               ; PRINT STRING TO CONSOLE OUT

* PRINT ITEM SEPARATOR TO CONSOLE OUT
D092  9D A5             LD092    JSR   GETCCH              ; GET CURRENT CHARACTER
D094  10 27 E8 C0                LBEQ  LB958               ; PUT CR TO CONSOLE OUT IF END OF LINE
D098  86 2C                      LDA   #','                ; COMMA: NON-CASSETTE SEPARATOR
D09A  BD A3 5F                   JSR   LA35F               ; SET PRINT PARAMETERS
D09D  0D 6E                      TST   PRTDEV              ; * GET CONSOLE PRINT DEVICE AND
D09F  27 02                      BEQ   LD0A3               ; * BRANCH IF NOT CASSETTE
D0A1  86 0D                      LDA   #CR                 ; GET CARRIAGE RETURN - CASSETTE ITEM SEPARATOR
D0A3  8D 14             LD0A3    BSR   LD0B9               ; SEND SEPARATOR TO CONSOLE OUT
D0A5  20 D8                      BRA   LD07F               ; GET NEXT ITEM

* PRINT A STRING TO CONSOLE OUT
D0A7  8D 07             LD0A7    BSR   LD0B0               ; PRINT LEADING STRING DELIMITER (")
D0A9  BD B9 9F                   JSR   LB99F               ; PRINT STRING TO CONSOLE OUT
D0AC  8D 02                      BSR   LD0B0               ; PRINT ENDING STRING DELIMITER (")
D0AE  20 E2                      BRA   LD092               ; GO PRINT SEPARATOR

* PRINT STRING DELIMITER (") TO CONSOLE OUT
D0B0  BD A3 5F          LD0B0    JSR   LA35F               ; SET PRINT PARAMETERS
D0B3  0D 6E                      TST   PRTDEV              ; * GET CONSOLE PRINT DEVICE AND
D0B5  26 B7                      BNE   LD06E               ; * RETURN IF CASSETTE
D0B7  86 22                      LDA   #'"'                ; QUOTE: NON-CASSETTE STRING DELIMITER
D0B9  7E A2 82          LD0B9    JMP   LA282               ; SEND TO CONSOLE OUT

* FIELD COMMAND
D0BC  BD C8 2E          FIELD    JSR   LC82E               ; EVALUATE DEVICE NUMBER & VERIFY RANDOM FILE OPEN
D0BF  4F                         CLRA                      ; *
D0C0  5F                         CLRB                      ; * CLEAR TOTAL FIELD LENGTH COUNTER
D0C1  34 16                      PSHS  X,B,A               ; SAVE FCB POINTER & INITIALIZE TOTAL FIELD LENGTH TO ZERO
D0C3  9D A5             LD0C3    JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
D0C5  26 02                      BNE   LD0C9               ; BRANCH IF NOT END OF LINE
D0C7  35 96                      PULS  A,B,X,PC            ; CLEAN UP STACK AND RETURN
D0C9  BD B7 38          LD0C9    JSR   LB738               ; SYNTAX CHECK FOR COMMA, EVALUATE EXPRESSION
D0CC  34 14                      PSHS  X,B                 ; SAVE FIELD LENGTH (ACCB) ON STACK, X IS A DUMMY WHICH WILL
; RESERVE 2 BYTES FOR THE ADDRESS WHICH WILL BE CALCULATED BELOW
* AT THIS POINT THE STACK WILL HAVE THE FOLLOWING INFORMATION ON IT:
* ,S = FIELD LENGTH   1 2,S = RANDOM FILE BUFFER ADDRESS
* 3 4,S = TOTAL FIELD LENGTH  5 6,S = FCD POINTER
D0CE  4F                         CLRA                      ; CLEAR MS BYTE
D0CF  E3 63                      ADDD  $03,S               ; ADD FIELD LENGTH TO TOTAL FIELD LENGTH COUNTER
D0D1  25 07                      BLO   LD0DA               ; 'FO' ERROR IF SUM > $FFFF
D0D3  AE 65                      LDX   $05,S               ; POINT X TO FCB
D0D5  10 A3 09                   CMPD  FCBRLN,X            ; * COMPARE TO RECORD LENGTH & BRANCH IF
D0D8  23 05                      BLS   LD0DF               ; *TOTAL FIELD LENGTH < RECORD LENGTH
D0DA  C6 44             LD0DA    LDB   #34*2               ; 'FIELD OVERFLOW' ERROR
D0DC  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR DRIVER
D0DF  EE 63             LD0DF    LDU   $03,S               ; LOAD U WITH OLD TOTAL LENGTH OF ALL FIELDS
D0E1  ED 63                      STD   $03,S               ; SAVE NEW TOTAL FIELD LENGTH
D0E3  EC 0B                      LDD   FCBBUF,X            ; POINT ACCD TO START OF RANDOM FILE BUFFER
D0E5  33 CB                      LEAU  D,U                 ; *POINT U TO THIS FIELD'S SLOT IN THE RANDOM
D0E7  EF 61                      STU   $01,S               ; *FILE BUFFER AND SAVE IT ON THE STACK
D0E9  C6 FF                      LDB   #$FF                ; SECONDARY TOKEN
D0EB  BD B2 6F                   JSR   LB26F               ; SYNTAX CHECK FOR SECONDARY TOKEN
D0EE  C6 A7                      LDB   #$A7                ; 'AS' TOKEN
D0F0  BD B2 6F                   JSR   LB26F               ; SYNTAX CHECK FOR 'AS' TOKEN
D0F3  BD B3 57                   JSR   LB357               ; EVALUATE VARIABLE
D0F6  BD B1 46                   JSR   LB146               ; 'TM' ERROR IF NUMERIC VARIABLE
D0F9  35 44                      PULS  B,U                 ; * PULL STRING ADDRESS AND LENGTH
D0FB  E7 84                      STB   ,X                  ; * OFF OF THE STACK AND SAVE THEM
D0FD  EF 02                      STU   $02,X               ; * IN STRING DESCRIPTOR
D0FF  20 C2                      BRA   LD0C3               ; CHECK FOR ANOTHER FIELD SPECIFICATION

* RSET COMMAND
D101  86                RSET     LDA   #$4F                ; SKIP ONE BYTE

* LSET COMMAND
D102  4F                LSET     CLRA                      ; LSET FLAG = 0
D103  34 02                      PSHS  A                   ; SAVE RSET($4F),LSET(00) FLAG ON THE STACK
D105  BD B3 57                   JSR   LB357               ; EVALUATE FIELD STRING VARIABLE
D108  BD B1 46                   JSR   LB146               ; 'TM' ERROR IF NUMERIC VARIABLE
D10B  34 10                      PSHS  X                   ; SAVE STRING DESCRIPTOR ON STACK
D10D  AE 02                      LDX   $02,X               ; POINT X TO ADDRESS OF STRING
D10F  8C 09 89                   CMPX  #DFLBUF             ; * COMPARE STRING ADDRESS TO START OF RANDOM
D112  25 05                      BLO   LD119               ; * FILE BUFFER; 'SE' ERROR IF < RANDOM FILE BUFFER
D114  BC 09 4A                   CMPX  FCBADR              ; = COMPARE STRING ADDRESS TO TOP OF RANDOM FILE BUFFER
D117  25 05                      BLO   LD11E               ; = AREA - BRANCH IF STRING IN RANDOM FILE BUFFER
D119  C6 46             LD119    LDB   #2*35               ; 'SET TO NON-FIELDED STRING' ERROR
D11B  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER
D11E  C6 B3             LD11E    LDB   #$B3                ; *
D120  BD B2 6F                   JSR   LB26F               ; * SYNTAX CHECK FOR '=' TOKEN
D123  BD 87 48                   JSR   L8748               ; =EVALUATE DATA STRING EXPRESSION; RETURN WITH X
* =POINTING TO STRING; ACCB = LENGTH
D126  35 20                      PULS  Y                   ; POINT Y TO FIELD STRING DESCRIPTOR
D128  A6 A4                      LDA   ,Y                  ; GET LENGTH OF FIELD STRING
D12A  27 2E                      BEQ   LD15A               ; RETURN IF NULL STRING
D12C  34 04                      PSHS  B                   ; SAVE LENGTH OF DATA STRING ON STACK
D12E  C6 20                      LDB   #SPACE              ; PREPARE TO FILL DATA STRING WITH BLANKS
D130  EE 22                      LDU   $02,Y               ; POINT U TO FIELD STRING ADDRESS
* FILL THE FIELDED STRING WITH BLANKS
D132  E7 C0             LD132    STB   ,U+                 ; STORE A SPACE IN FIELDED STRING
D134  4A                         DECA                      ; DECREMENT LENGTH COUNTER
D135  26 FB                      BNE   LD132               ; KEEP FILLING W/SPACES IF NOT DONE
D137  E6 E0                      LDB   ,S+                 ; *GET THE LENGTH OF THE DATA STRING AND
D139  27 1F                      BEQ   LD15A               ; *RETURN IF IT IS NULL (ZERO)
D13B  E1 A4                      CMPB  ,Y                  ; =COMPARE LENGTH OF DATA STRING TO LENGTH OF FIELD
D13D  25 04                      BLO   LD143               ; =STRING, BRANCH IF FIELD STRING > DATA STRING
D13F  E6 A4                      LDB   ,Y                  ; *GET THE LENGTH OF THE FIELD STRING AND FORCE THE
D141  6F E4                      CLR   ,S                  ; *RSET/LSET FLAG TO LSET (0) IF DATA STRING LENGTH IS
* *>= THE FIELD STRING LENGTH. THIS WILL CAUSE THE RIGHT
* *SIDE OF THE DATA STRING TO BE TRUNCATED
D143  EE 22             LD143    LDU   $02,Y               ; LOAD U WITH THE ADDRESS OF THE FIELD STRING
D145  6D E0                      TST   ,S+                 ; * GET THE RSET/LSET FLAG FROM THE STACK
D147  27 0E                      BEQ   LD157               ; * AND BRANCH IF LSET
* RSET ROUTINE
D149  34 04                      PSHS  B                   ; SAVE THE NUMBER OF BYTES TO MOVE INTO THE FIELD STRING
D14B  4F                         CLRA                      ; = TAKE THE 2'S COMPLEMENT OF AN UNSIGNED
D14C  50                         NEGB                      ; = NUMBER IN ACCB - LEAVE THE DOUBLE BYTE SIGNED
D14D  82 00                      SBCA  #$00                ; = RESULT IN ACCD
D14F  EB A4                      ADDB  ,Y                  ; * ADD THE LENGTH OF THE FIELD STRING TO THE INVERSE
D151  89 00                      ADCA  #$00                ; * OF THE NUMBER OF BYTES TO BE MOVED
D153  33 CB                      LEAU  D,U                 ; =ADD RESULT TO START OF FIELD STRING. NOW U
* =WILL POINT TO (-NUMBER OF BYTES TO MOVE)
* =FROM THE RIGHT SIDE OF THE FIELD STRING
D155  35 04                      PULS  B                   ; GET THE NUMBER OF BYTES TO MOVE
D157  7E A5 9A          LD157    JMP   LA59A               ; MOVE ACCB BYTES FROM X TO U (DATA TO FIELD STRING)
D15A  35 82             LD15A    PULS  A,PC                ; PULL LSET/RSET FLAG OFF OF STACK AND RETURN
