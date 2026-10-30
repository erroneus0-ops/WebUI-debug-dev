; Disk Extended Color BASIC 1.0 -- $CF3F-$D07F
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: RENAME=$CF3F, WRITE=$CF8A, FIELD=$CFE0, RSET=$D025, LSET=$D026

* RENAME COMMAND
CF3F  9E A6             RENAME   LDX   CHARAD              ; * SAVE CURRENT INPUT POINTER
CF41  34 10                      PSHS  X                   ; * ON THE STACK
CF43  8D 35                      BSR   LCF7A               ; GET FILENAME OF SOURCE FILE
CF45  96 EB                      LDA   DCDRV               ; * SAVE DRIVE NUMBER
CF47  34 02                      PSHS  A                   ; * ON THE STACK
CF49  8D 2A                      BSR   LCF75               ; SYNTAX CHECK FOR 'TO' AND GET NEW FILENAME
CF4B  35 02                      PULS  A                   ; GET SOURCE DRIVE NUMBER
CF4D  91 EB                      CMPA  DCDRV               ; COMPARE TO NEW FILE DRIVE NUMBER
CF4F  10 26 E4 F7                LBNE  LB44A               ; 'FC' ERROR IF FlIES ON DIFFERENT DRIVES
CF53  8D 28                      BSR   LCF7D               ; VERIFY THAT NEW FILE DOES NOT ALREADY EXIST
CF55  35 10                      PULS  X                   ; * RESTORE INPUT POINTER
CF57  9F A6                      STX   CHARAD              ; *
CF59  8D 1F                      BSR   LCF7A               ; GET SOURCE FILENAME AGAIN
CF5B  BD C6 5F                   JSR   LC65F               ; SCAN DIRECTORY FOR SOURCE FILENAME
CF5E  BD C6 B8                   JSR   LC6B8               ; 'NE' ERROR IF NOT FOUND
CF61  8D 12                      BSR   LCF75               ; SYNTAX CHECK FOR 'TO' AND GET NEW FILENAME
CF63  8E 09 4C                   LDX   #DNAMBF             ; POINT X TO FILENAME
CF66  FE 09 74                   LDU   V974                ; POINT U TO DIRECTORY ENTRY OF SOURCE FILE
CF69  C6 0B                      LDB   #11                 ; 11 CHARACTERS IN FILENAME AND EXTENSION
CF6B  BD A5 9A                   JSR   LA59A               ; COPY NEW FILENAME TO SOURCE FILE DIRECTORY RAM IMAGE
CF6E  C6 03                      LDB   #$03                ; * GET WRITE OP CODE AND
CF70  D7 EA                      STB   DCOPC               ; * SAVE IN DSKCON VARIABLE
CF72  7E D5 FF                   JMP   LD5FF               ; WRITE NEW DIRECTORY SECTOR

* DO A SYNTAX CHECK FOR 'TO' AND STRIP A FILENAME FROM BASIC
CF75  C6 A5             LCF75    LDB   #$A5                ; 'TO' TOKEN
CF77  BD B2 6F                   JSR   LB26F               ; SYNTAX CHECK FOR 'TO'
CF7A  7E C8 87          LCF7A    JMP   LC887               ; GET FILENAME FROM BASIC
CF7D  BD C6 5F          LCF7D    JSR   LC65F               ; SCAN DIRECTORY FOR FILENAME
CF80  C6 42                      LDB   #33*2               ; 'FILE ALREADY EXISTS' ERROR
CF82  7D 09 73                   TST   V973                ; CHECK FOR A MATCH
CF85  10 26 DC BD                LBNE  LAC46               ; 'AE' ERROR IF FILE IN DIRECTORY
CF89  39                         RTS

* WRITE COMMAND
CF8A  10 27 E9 CA       WRITE    LBEQ  LB958               ; PRINT CARRIAGE RETURN TO CONSOLE OUT IF END OF LINE
CF8E  8D 03                      BSR   LCF93               ; GO WRITE AN ITEM LIST
CF90  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
CF92  39                LCF92    RTS
CF93  81 23             LCF93    CMPA  #'#'                ; CHECK FOR DEVICE NUMBER FLAG
CF95  26 0F                      BNE   LCFA6               ; DEFAULT TO CURRENT DEVICE NUMBER IF NONE GIVEN
CF97  BD A5 A5                   JSR   LA5A5               ; SET DEVICE NUMBER; CHECK VALIDITY
CF9A  BD A4 06                   JSR   LA406               ; MAKE SURE SELECTED FILE IS AN OUTPUT FILE
CF9D  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
CF9F  10 27 E9 B5                LBEQ  LB958               ; PRINT CR TO CONSOLE OUT IF END OF LINE
CFA3  BD B2 6D          LCFA3    JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
CFA6  BD B1 56          LCFA6    JSR   LB156               ; EVALUATE EXPRESSION
CFA9  96 06                      LDA   VALTYP              ; GET VARIABLE TYPE
CFAB  26 1E                      BNE   LCFCB               ; BRANCH IF STRING
CFAD  BD BD D9                   JSR   LBDD9               ; CONVERT FP NUMBER TO ASCII STRING
CFB0  BD B5 16                   JSR   LB516               ; PUT ON TEMPORARY STRING STACK
CFB3  BD B9 9F                   JSR   LB99F               ; PRINT STRING TO CONSOLE OUT

* PRINT ITEM SEPARATOR TO CONSOLE OUT
CFB6  9D A5             LCFB6    JSR   GETCCH              ; GET CURRENT CHARACTER
CFB8  10 27 E9 9C                LBEQ  LB958               ; PUT CR TO CONSOLE OUT IF END OF LINE
CFBC  86 2C                      LDA   #','                ; COMMA: NON-CASSETTE SEPARATOR
CFBE  BD A3 5F                   JSR   LA35F               ; SET PRINT PARAMETERS
CFC1  0D 6E                      TST   PRTDEV              ; * GET CONSOLE PRINT DEVICE AND
CFC3  27 02                      BEQ   LCFC7               ; * BRANCH IF NOT CASSETTE
CFC5  86 0D                      LDA   #CR                 ; GET CARRIAGE RETURN - CASSETTE ITEM SEPARATOR
CFC7  8D 14             LCFC7    BSR   LCFDD               ; SEND SEPARATOR TO CONSOLE OUT
CFC9  20 D8                      BRA   LCFA3               ; GET NEXT ITEM

* PRINT A STRING TO CONSOLE OUT
CFCB  8D 07             LCFCB    BSR   LCFD4               ; PRINT LEADING STRING DELIMITER (")
CFCD  BD B9 9F                   JSR   LB99F               ; PRINT STRING TO CONSOLE OUT
CFD0  8D 02                      BSR   LCFD4               ; PRINT ENDING STRING DELIMITER (")
CFD2  20 E2                      BRA   LCFB6               ; GO PRINT SEPARATOR

* PRINT STRING DELIMITER (") TO CONSOLE OUT
CFD4  BD A3 5F          LCFD4    JSR   LA35F               ; SET PRINT PARAMETERS
CFD7  0D 6E                      TST   PRTDEV              ; * GET CONSOLE PRINT DEVICE AND
CFD9  26 B7                      BNE   LCF92               ; * RETURN IF CASSETTE
CFDB  86 22                      LDA   #'"'                ; QUOTE: NON-CASSETTE STRING DELIMITER
CFDD  7E A2 82          LCFDD    JMP   LA282               ; SEND TO CONSOLE OUT

* FIELD COMMAND
CFE0  BD C7 FE          FIELD    JSR   LC7FE               ; EVALUATE DEVICE NUMBER & VERIFY RANDOM FILE OPEN
CFE3  4F                         CLRA                      ; *
CFE4  5F                         CLRB                      ; * CLEAR TOTAL FIELD LENGTH COUNTER
CFE5  34 16                      PSHS  X,B,A               ; SAVE FCB POINTER & INITIALIZE TOTAL FIELD LENGTH TO ZERO
CFE7  9D A5             LCFE7    JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
CFE9  26 02                      BNE   LCFED               ; BRANCH IF NOT END OF LINE
CFEB  35 96                      PULS  A,B,X,PC            ; CLEAN UP STACK AND RETURN
CFED  BD B7 38          LCFED    JSR   LB738               ; SYNTAX CHECK FOR COMMA, EVALUATE EXPRESSION
CFF0  34 14                      PSHS  X,B                 ; *SAVE FIELD LENGTH (ACCB) ON STACK, X IS A DUMMY WHICH WILL
* *RESERVE 2 BYTES FOR THE ADDRESS WHICH WILL BE CALCULATED BELOW
* AT THIS POINT THE STACK WILL HAVE THE FOLLOWING INFORMATION ON IT:
* ,S = FIELD LENGTH   1 2,S = RANDOM FILE BUFFER ADDRESS
* 3 4,S = TOTAL FIELD LENGTH  5 6,S = FCD POINTER
CFF2  4F                         CLRA                      ; CLEAR MS BYTE
CFF3  E3 63                      ADDD  $03,S               ; ADD FIELD LENGTH TO TOTAL FIELD LENGTH COUNTER
CFF5  25 07                      BLO   LCFFE               ; 'FO' ERROR IF SUM > $FFFF
CFF7  AE 65                      LDX   $05,S               ; POINT X TO FCB
CFF9  10 A3 09                   CMPD  FCBRLN,X            ; * COMPARE TO RECORD LENGTH & BRANCH IF
CFFC  23 05                      BLS   LD003               ; *TOTAL FIELD LENGTH < RECORD LENGTH
CFFE  C6 44             LCFFE    LDB   #34*2               ; 'FIELD OVERFLOW' ERROR
D000  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR DRIVER
D003  EE 63             LD003    LDU   $03,S               ; LOAD U WITH OLD TOTAL LENGTH OF ALL FIELDS
D005  ED 63                      STD   $03,S               ; SAVE NEW TOTAL FIELD LENGTH
D007  EC 0B                      LDD   FCBBUF,X            ; POINT ACCD TO START OF RANDOM FILE BUFFER
D009  33 CB                      LEAU  D,U                 ; *POINT U TO THIS FIELD'S SLOT IN THE RANDOM
D00B  EF 61                      STU   $01,S               ; *FILE BUFFER AND SAVE IT ON THE STACK
D00D  C6 FF                      LDB   #$FF                ; SECONDARY TOKEN
D00F  BD B2 6F                   JSR   LB26F               ; SYNTAX CHECK FOR SECONDARY TOKEN
D012  C6 A7                      LDB   #$A7                ; 'AS' TOKEN
D014  BD B2 6F                   JSR   LB26F               ; SYNTAX CHECK FOR 'AS' TOKEN
D017  BD B3 57                   JSR   LB357               ; EVALUATE VARIABLE
D01A  BD B1 46                   JSR   LB146               ; 'TM' ERROR IF NUMERIC VARIABLE
D01D  35 44                      PULS  B,U                 ; * PULL STRING ADDRESS AND LENGTH
D01F  E7 84                      STB   ,X                  ; * OFF OF THE STACK AND SAVE THEM
D021  EF 02                      STU   $02,X               ; * IN STRING DESCRIPTOR
D023  20 C2                      BRA   LCFE7               ; CHECK FOR ANOTHER FIELD SPECIFICATION

* RSET COMMAND
D025  86 4F             RSET     LDA   #$4F                ; SKIP ONE BYTE

* LSET COMMAND
D026  4F                LSET     CLRA                      ; LSET FLAG = 0
D027  34 02                      PSHS  A                   ; SAVE RSET($4F),LSET(00) FLAG ON THE STACK
D029  BD B3 57                   JSR   LB357               ; EVALUATE FIELD STRING VARIABLE
D02C  BD B1 46                   JSR   LB146               ; 'TM' ERROR IF NUMERIC VARIABLE
D02F  34 10                      PSHS  X                   ; SAVE STRING DESCRIPTOR ON STACK
D031  AE 02                      LDX   $02,X               ; POINT X TO ADDRESS OF STRING
D033  8C 09 89                   CMPX  #DFLBUF             ; * COMPARE STRING ADDRESS TO START OF RANDOM
D036  25 05                      BLO   LD03D               ; * FILE BUFFER; 'SE' ERROR IF < RANDOM FILE BUFFER
D038  BC 09 4A                   CMPX  FCBADR              ; = COMPARE STRING ADDRESS TO TOP OF RANDOM FILE BUFFER
D03B  25 05                      BLO   LD042               ; = AREA - BRANCH IF STRING IN RANDOM FILE BUFFER
D03D  C6 46             LD03D    LDB   #2*35               ; 'SET TO NON-FIELDED STRING' ERROR
D03F  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER
D042  C6 B3             LD042    LDB   #$B3                ; *
D044  BD B2 6F                   JSR   LB26F               ; * SYNTAX CHECK FOR '=' TOKEN
D047  BD 87 48                   JSR   L8748               ; =EVALUATE DATA STRING EXPRESSION; RETURN WITH X
* =POINTING TO STRING; ACCB = LENGTH
D04A  35 20                      PULS  Y                   ; POINT Y TO FIELD STRING DESCRIPTOR
D04C  A6 A4                      LDA   ,Y                  ; GET LENGTH OF FIELD STRING
D04E  27 2E                      BEQ   LD07E               ; RETURN IF NULL STRING
D050  34 04                      PSHS  B                   ; SAVE LENGTH OF DATA STRING ON STACK
D052  C6 20                      LDB   #SPACE              ; PREPARE TO FILL DATA STRING WITH BLANKS
D054  EE 22                      LDU   $02,Y               ; POINT U TO FIELD STRING ADDRESS
* FILL THE FIELDED STRING WITH BLANKS
D056  E7 C0             LD056    STB   ,U+                 ; STORE A SPACE IN FIELDED STRING
D058  4A                         DECA                      ; DECREMENT LENGTH COUNTER
D059  26 FB                      BNE   LD056               ; KEEP FILLING W/SPACES IF NOT DONE
D05B  E6 E0                      LDB   ,S+                 ; *GET THE LENGTH OF THE DATA STRING AND
D05D  27 1F                      BEQ   LD07E               ; *RETURN IF IT IS NULL (ZERO)
D05F  E1 A4                      CMPB  ,Y                  ; =COMPARE LENGTH OF DATA STRING TO LENGTH OF FIELD
D061  25 04                      BLO   LD067               ; =STRING, BRANCH IF FIELD STRING > DATA STRING
D063  E6 A4                      LDB   ,Y                  ; *GET THE LENGTH OF THE FIELD STRING AND FORCE THE
D065  6F E4                      CLR   ,S                  ; *RSET/LSET FLAG TO LSET (0) IF DATA STRING LENGTH IS
* *>= THE FIELD STRING LENGTH. THIS WILL CAUSE THE RIGHT
* *SIDE OF THE DATA STRING TO BE TRUNCATED
D067  EE 22             LD067    LDU   $02,Y               ; LOAD U WITH THE ADDRESS OF THE FIELD STRING
D069  6D E0                      TST   ,S+                 ; * GET THE RSET/LSET FLAG FROM THE STACK
D06B  27 0E                      BEQ   LD07B               ; * AND BRANCH IF LSET
* RSET ROUTINE
D06D  34 04                      PSHS  B                   ; SAVE THE NUMBER OF BYTES TO MOVE INTO THE FIELD STRING
D06F  4F                         CLRA                      ; = TAKE THE 2'S COMPLEMENT OF AN UNSIGNED
D070  50                         NEGB                      ; = NUMBER IN ACCB - LEAVE THE DOUBLE BYTE SIGNED
D071  82 00                      SBCA  #$00                ; = RESULT IN ACCD
D073  EB A4                      ADDB  ,Y                  ; * ADD THE LENGTH OF THE FIELD STRING TO THE INVERSE
D075  89 00                      ADCA  #$00                ; * OF THE NUMBER OF BYTES TO BE MOVED
D077  33 CB                      LEAU  D,U                 ; =ADD RESULT TO START OF FIELD STRING. NOW U
; =WILL POINT TO (-NUMBER OF BYTES TO MOVE)
; =FROM THE RIGHT SIDE OF THE FIELD STRING
D079  35 04                      PULS  B                   ; GET THE NUMBER OF BYTES TO MOVE
D07B  7E A5 9A          LD07B    JMP   LA59A               ; MOVE ACCB BYTES FROM X TO U (DATA TO FIELD STRING)
D07E  35 82             LD07E    PULS  A,PC                ; PULL LSET/RSET FLAG OFF OF STACK AND RETURN
