; Extended Color BASIC 1.1 -- $86BE-$8870
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: VARPTR=$86BE, STRING=$874E, INSTR=$877E, XVEC19=$87E5, XVEC15=$8846

* VARPTR
86BE  BD B2 6A          VARPTR   JSR   LB26A               ; SYNTAX CHECK FOR '('
86C1  DC 1F                      LDD   ARYEND              ; GET ADDR OF END OF ARRAYS
86C3  34 06                      PSHS  B,A                 ; SAVE IT ON STACK
86C5  BD B3 57                   JSR   LB357               ; GET VARIABLE DESCRIPTOR
86C8  BD B2 67                   JSR   LB267               ; SYNTAX CHECK FOR ')'
86CB  35 06                      PULS  A,B                 ; GET END OF ARRAYS ADDR BACK
86CD  1E 10                      EXG   X,D                 ; SWAP END OF ARRAYS AND VARIABLE DESCRIPTOR
86CF  9C 1F                      CMPX  ARYEND              ; COMPARE TO NEW END OF ARRAYS
86D1  26 51                      BNE   L8724               ; 'FC' ERROR IF VARIABLE WAS NOT DEFINED PRIOR TO CALLING VARPTR
86D3  7E B4 F4                   JMP   GIVABF              ; CONVERT VARIABLE DESCRIPTOR INTO A FP NUMBER

* MID$(OLDSTRING,POSITION,LENGTH)=REPLACEMENT
86D6  9D 9F             L86D6    JSR   GETNCH              ; GET INPUT CHAR FROM BASIC
86D8  BD B2 6A                   JSR   LB26A               ; SYNTAX CHECK FOR '('
86DB  BD B3 57                   JSR   LB357               ; * GET VARIABLE DESCRIPTOR ADDRESS AND
86DE  34 10                      PSHS  X                   ; * SAVE IT ON THE STACK
86E0  EC 02                      LDD   $02,X               ; POINT ACCD TO START OF OLDSTRING
86E2  10 93 21                   CMPD  FRETOP              ; COMPARE TO START OF CLEARED SPACE
86E5  23 04                      BLS   L86EB               ; BRANCH IF <=
86E7  93 27                      SUBD  MEMSIZ              ; SUBTRACT OUT TOP OF CLEARED SPACE
86E9  23 12                      BLS   L86FD               ; BRANCH IF STRING IN STRING SPACE
86EB  E6 84             L86EB    LDB   ,X                  ; GET LENGTH OF OLDSTRING
86ED  BD B5 6D                   JSR   LB56D               ; RESERVE ACCB BYTES IN STRING SPACE
86F0  34 10                      PSHS  X                   ; SAVE RESERVED SPACE STRING ADDRESS ON STACK
86F2  AE 62                      LDX   $02,S               ; POINT X TO OLDSTRING DESCRIPTOR
86F4  BD B6 43                   JSR   LB643               ; MOVE OLDSTRING INTO STRING SPACE
86F7  35 50                      PULS  X,U                 ; * GET OLDSTRING DESCRIPTOR ADDRESS AND RESERVED STRING
86F9  AF 42                      STX   $02,U               ; * ADDRESS AND SAVE RESERVED ADDRESS AS OLDSTRING ADDRESS
86FB  34 40                      PSHS  U                   ; SAVE OLDSTRING DESCRIPTOR ADDRESS
86FD  BD B7 38          L86FD    JSR   LB738               ; SYNTAX CHECK FOR COMMA AND EVALUATE LENGTH EXPRESSION
8700  34 04                      PSHS  B                   ; SAVE POSITION PARAMETER ON STACK
8702  5D                         TSTB                      ; * CHECK POSITION PARAMETER AND BRANCH
8703  27 1F                      BEQ   L8724               ; * IF START OF STRING
8705  C6 FF                      LDB   #$FF                ; DEFAULT REPLACEMENT LENGTH = $FF
8707  81 29                      CMPA  #')'                ; * CHECK FOR END OF MID$ STATEMENT AND
8709  27 03                      BEQ   L870E               ; * BRANCH IF AT END OF STATEMENT
870B  BD B7 38                   JSR   LB738               ; SYNTAX CHECK FOR COMMA AND EVALUATE LENGTH EXPRESSION
870E  34 04             L870E    PSHS  B                   ; SAVE LENGTH PARAMETER ON STACK
8710  BD B2 67                   JSR   LB267               ; SYNTAX CHECK FOR ')'
8713  C6 B3                      LDB   #$B3                ; TOKEN FOR =
8715  BD B2 6F                   JSR   LB26F               ; SYNTAX CHECK FOR "='
8718  8D 2E                      BSR   L8748               ; EVALUATE REPLACEMENT STRING
871A  1F 13                      TFR   X,U                 ; SAVE REPLACEMENT STRING ADDRESS IN U
871C  AE 62                      LDX   $02,S               ; POINT X TO OLOSTRING DESCRIPTOR ADDRESS
871E  A6 84                      LDA   ,X                  ; GET LENGTH OF OLDSTRING
8720  A0 61                      SUBA  $01,S               ; SUBTRACT POSITION PARAMETER
8722  24 03                      BCC   L8727               ; INSERT REPLACEMENT STRING INTO OLDSTRING
8724  7E B4 4A          L8724    JMP   LB44A               ; 'FC' ERROR IF POSITION > LENGTH OF OLDSTRING
8727  4C                L8727    INCA                      ; * NOW ACCA = NUMBER OF CHARACTERS TO THE RIGHT
* * (INCLUSIVE) OF THE POSITION PARAMETER
8728  A1 E4                      CMPA  ,S                  ; COMPARE TO LENGTH PARAMETER
872A  24 02                      BCC   L872E               ; BRANCH IF NEW STRING WILL FIT IN OLDSTRING
872C  A7 E4                      STA   ,S                  ; IF NOT, USE AS MUCH OF LENGTH PARAMETER AS WILL FIT
872E  A6 61             L872E    LDA   $01,S               ; GET POSITION PARAMETER
8730  1E 89                      EXG   A,B                 ; ACCA=LENGTH OF REPL STRING, ACCB=POSITION PARAMETER
8732  AE 02                      LDX   $02,X               ; POINT X TO OLDSTRING ADDRESS
8734  5A                         DECB                      ; * BASIC'S POSITION PARAMETER STARTS AT 1; THIS ROUTINE
* * WANTS IT TO START AT ZERO
8735  3A                         ABX                       ; POINT X TO POSITION IN OLDSTRING WHERE THE REPLACEMENT WILL GO
8736  4D                         TSTA                      ; * IF THE LENGTH OF THE REPLACEMENT STRING IS ZERO
8737  27 0D                      BEQ   L8746               ; * THEN RETURN
8739  A1 E4                      CMPA  ,S                  ; = IF THE LENGTH OF REPLACEMENT STRING IS <= THE
873B  23 02                      BLS   L873F               ;   ADJUSTED LENGTH PARAMETER, THEN BRANCH
873D  A6 E4                      LDA   ,S                  ; OTHERWISE USE AS MUCH ROOM AS IS AVAILABLE
873F  1F 89             L873F    TFR   A,B                 ; SAVE NUMBER OF BYTES TO MOVE IN ACCB
8741  1E 31                      EXG   U,X                 ; SWAP SOURCE AND DESTINATION POINTERS
8743  BD A5 9A                   JSR   LA59A               ; MOVE (B) BYTES FROM (X) TO (U)
8746  35 96             L8746    PULS  A,B,X,PC            ; CLEAN UP THE STACK AND RETURN
8748  BD B1 56          L8748    JSR   LB156               ; EVALUATE EXPRESSION
874B  7E B6 54                   JMP   LB654               ; *'TM' ERROR IF NUMERIC; RETURN WITH X POINTING
* *TO STRING, ACCB = LENGTH

* STRING
874E  BD B2 6A          STRING   JSR   LB26A               ; SYNTAX CHECK FOR '('
8751  BD B7 0B                   JSR   EVALEXPB            ; EVALUATE EXPRESSION; ERROR IF > 255
8754  34 04                      PSHS  B                   ; SAVE LENGTH OF STRING
8756  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
8759  BD B1 56                   JSR   LB156               ; EVALUATE EXPRESSION
875C  BD B2 67                   JSR   LB267               ; SYNTAX CHECK FOR ')'
875F  96 06                      LDA   VALTYP              ; GET VARIABLE TYPE
8761  26 05                      BNE   L8768               ; BRANCH IF STRING
8763  BD B7 0E                   JSR   LB70E               ; CONVERT FPA0 INTO AN INTEGER IN ACCB
8766  20 03                      BRA   L876B               ; SAVE THE STRING IN STRING SPACE
8768  BD B6 A4          L8768    JSR   LB6A4               ; GET FIRST BYTE OF STRING
876B  34 04             L876B    PSHS  B                   ; SAVE FIRST BYTE OF EXPRESSION
876D  E6 61                      LDB   $01,S               ; GET LENGTH OF STRING
876F  BD B5 0F                   JSR   LB50F               ; RESERVE ACCB BYTES IN STRING SPACE
8772  35 06                      PULS  A,B                 ; GET LENGTH OF STRING AND CHARACTER
8774  27 05                      BEQ   L877B               ; BRANCH IF NULL STRING
8776  A7 80             L8776    STA   ,X+                 ; SAVE A CHARACTER IN STRING SPACE
8778  5A                         DECB                      ; DECREMENT LENGTH
8779  26 FB                      BNE   L8776               ; BRANCH IF NOT DONE
877B  7E B6 9B          L877B    JMP   LB69B               ; PUT STRING DESCRIPTOR ONTO STRING STACK

* INSTR
877E  BD B2 6A          INSTR    JSR   LB26A               ; SYNTAX CHECK FOR '('
8781  BD B1 56                   JSR   LB156               ; EVALUATE EXPRESSION
8784  C6 01                      LDB   #$01                ; DEFAULT POSITION = 1 (SEARCH START)
8786  34 04                      PSHS  B                   ; SAVE START
8788  96 06                      LDA   VALTYP              ; GET VARIABLE TYPE
878A  26 10                      BNE   L879C               ; BRANCH IF STRING
878C  BD B7 0E                   JSR   LB70E               ; CONVERT FPA0 TO INTEGER IN ACCB
878F  E7 E4                      STB   ,S                  ; SAVE START SEARCH VALUE
8791  27 91                      BEQ   L8724               ; BRANCH IF START SEARCH AT ZERO
8793  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
8796  BD B1 56                   JSR   LB156               ; EVALUATE EXPRESSION - SEARCH STRING
8799  BD B1 46                   JSR   LB146               ; 'TM' ERROR IF NUMERIC
879C  9E 52             L879C    LDX   FPA0+2              ; SEARCH STRING DESCRIPTOR ADDRESS
879E  34 10                      PSHS  X                   ; SAVE ON THE STACK
87A0  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
87A3  BD 87 48                   JSR   >L8748              ; EVALUATE TARGET STRING EXPRESSION
87A6  34 14                      PSHS  X,B                 ; SAVE ADDRESS AND LENGTH ON STACK
87A8  BD B2 67                   JSR   LB267               ; SYNTAX CHECK FOR ')'
87AB  AE 63                      LDX   $03,S               ; * LOAD X WITH SEARCH STRING DESCRIPTOR ADDRESS
87AD  BD B6 59                   JSR   LB659               ; * AND GET THE LENGTH ANDADDRESS OF SEARCH STRING
87B0  34 04                      PSHS  B                   ; SAVE LENGTH ON STACK
*
* AT THIS POINT THE STACK HAS THE FOLLOWING INFORMATION
* ON IT: 0,S-SEARCH LENGTH; 1,S-TARGET LENGTH; 2 3,S-TARGET
* ADDRESS; 4 5,S-SEARCH DESCRIPTOR ADDRESS; 6,S-SEARCH POSITION
87B2  E1 66                      CMPB  $06,S               ; COMPARE LENGTH OF SEARCH STRING TO START
87B4  25 23                      BLO   L87D9               ; POSITION; RETURN 0 IF LENGTH < START
87B6  A6 61                      LDA   $01,S               ; GET LENGTH OF TARGET STRING
87B8  27 1C                      BEQ   L87D6               ; BRANCH IF TARGET STRING = NULL
87BA  E6 66                      LDB   $06,S               ; GET START POSITION
87BC  5A                         DECB                      ; MOVE BACK ONE
87BD  3A                         ABX                       ; POINT X TO POSITION IN SEARCH STRING WHERE SEARCHING WILL START
87BE  31 84             L87BE    LEAY  ,X                  ; POINT Y TO SEARCH POSITION
87C0  EE 62                      LDU   $02,S               ; POINT U TO START OF TARGET
87C2  E6 61                      LDB   $01,S               ; LOAD ACCB WITH LENGTH OF TARGET
87C4  A6 E4                      LDA   ,S                  ; LOAD ACCA WITH LENGTH OF SEARCH
87C6  A0 66                      SUBA  $06,S               ; SUBTRACT SEARCH POSITION FROM SEARCH LENGTH
87C8  4C                         INCA                      ; ADD ONE
87C9  A1 61                      CMPA  $01,S               ; COMPARE TO TARGET LENGTH
87CB  25 0C                      BLO   L87D9               ; RETURN 0 IF TARGET LENGTH > WHAT'S LEFT OF SEARCH STRING
87CD  A6 80             L87CD    LDA   ,X+                 ; GET A CHARACTER FROM SEARCH STRING
87CF  A1 C0                      CMPA  ,U+                 ; COMPARE IT TO TARGET STRING
87D1  26 0C                      BNE   L87DF               ; BRANCH IF NO MATCH
87D3  5A                         DECB                      ; DECREMENT TARGET LENGTH
87D4  26 F7                      BNE   L87CD               ; CHECK ANOTHER CHARACTER
87D6  E6 66             L87D6    LDB   $06,S               ; GET MATCH POSITION
87D8  21                L87D8    FCB   SKP1                ; SKIP NEXT BYTE
87D9  5F                L87D9    CLRB                      ; MATCH ADDRESS = 0
87DA  32 67                      LEAS  $07,S               ; CLEAN UP THE STACK
87DC  7E B4 F3                   JMP   LB4F3               ; CONVERT ACCB TO FP NUMBER
87DF  6C 66             L87DF    INC   $06,S               ; INCREMENT SEARCH POSITION
87E1  30 21                      LEAX  $01,Y               ; MOVE X TO NEXT SEARCH POSITION
87E3  20 D9                      BRA   L87BE               ; KEEP LOOKING FOR A MATCH

* ASCII TO FLOATING POINT CONVERSION RAM HOOK
87E5  81 26             XVEC19   CMPA  #'&'                ; *
87E7  26 5C                      BNE   L8845               ; * RETURN IF NOT HEX OR OCTAL VARIABLE
87E9  32 62                      LEAS  $02,S               ; PURGE RETURN ADDRESS FROM STACK
* PROCESS A VARIABLE PRECEEDED BY A '&' (&H,&O)
87EB  0F 52             L87EB    CLR   FPA0+2              ; * CLEAR BOTTOM TWO
87ED  0F 53                      CLR   FPA0+3              ; * BYTES OF FPA0
87EF  8E 00 52                   LDX   #FPA0+2             ; BYTES 2,3 OF FPA0 = (TEMPORARY ACCUMULATOR)
87F2  9D 9F                      JSR   GETNCH              ; GET A CHARACTER FROM BASIC
87F4  81 4F                      CMPA  #'O'                ; OCTAL VALUE?
87F6  27 12                      BEQ   L880A               ; YES
87F8  81 48                      CMPA  #'H'                ; HEX VALUE?
87FA  27 23                      BEQ   L881F               ; YES
87FC  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
87FE  20 0C                      BRA   L880C               ; DEFAULT TO OCTAL (&O)
8800  81 38             L8800    CMPA  #'8'                ; *
8802  10 22 2A 71                LBHI  LB277               ; * 'SYNTAX' ERROR IF
8806  C6 03                      LDB   #$03                ; BASE 8 MULTIPLIER
8808  8D 2A                      BSR   L8834               ; ADD DIGIT TO TEMPORARY ACCUMULATOR
* EVALUATE AN &O VARIABLE
880A  9D 9F             L880A    JSR   GETNCH              ; GET A CHARACTER FROM BASIC
880C  25 F2             L880C    BLO   L8800               ; BRANCH IF NUMERIC
880E  0F 50             L880E    CLR   FPA0                ; * CLEAR 2 HIGH ORDER
8810  0F 51                      CLR   FPA0+1              ; * BYTES OF FPA0
8812  0F 06                      CLR   VALTYP              ; SET VARXABLE TYPE TO NUMERIC
8814  0F 63                      CLR   FPSBYT              ; ZERO OUT SUB BYTE OF FPA0
8816  0F 54                      CLR   FP0SGN              ; ZERO OUT MANTISSA SIGN OF FPA0
8818  C6 A0                      LDB   #$A0                ; * SET EXPONENT OF FPA0
881A  D7 4F                      STB   FP0EXP              ; *
881C  7E BA 1C                   JMP   LBA1C               ; GO NORMALIZE FPA0
* EVALUATE AN &H VARIABLE
881F  9D 9F             L881F    JSR   GETNCH              ; GET A CHARACTER FROM BASIC
8821  25 0B                      BLO   L882E               ; BRANCH IF NUMERIC
8823  BD B3 A2                   JSR   LB3A2               ; SET CARRY IF NOT ALPHA
8826  25 E6                      BLO   L880E               ; BRANCH IF NOT ALPHA OR NUMERIC
8828  81 47                      CMPA  #'G'                ; CHECK FOR LETTERS A-F
882A  24 E2                      BCC   L880E               ; BRANCH IF >= G (ILLEGAL HEX LETTER)
882C  80 07                      SUBA  #'A'-('9'+1)        ; SUBTRACT ASCII DIFFERENCE BETWEEN A AND 9
882E  C6 04             L882E    LDB   #$04                ; BASE 16 DIGIT MULTIPLIER = 2**4
8830  8D 02                      BSR   L8834               ; ADD DIGIT TO TEMPORARY ACCUMULATOR
8832  20 EB                      BRA   L881F               ; KEEP EVALUATING VARIABLE
8834  68 01             L8834    ASL   $01,X               ; * MULTIPLY TEMPORARY
8836  69 84                      ROL   ,X                  ; * ACCUMULATOR BY TWO
8838  10 25 32 56                LBCS  LBA92               ; 'OV' OVERFLOW ERROR
883C  5A                         DECB                      ; DECREMENT SHIFT COUNTER
883D  26 F5                      BNE   L8834               ; MULTIPLY TEMPORARY ACCUMULATOR AGAIN
883F  80 30                      SUBA  #'0'                ; MASK OFF ASCII
8841  AB 01                      ADDA  $01,X               ; * ADD DIGIT TO TEMPORARY
8843  A7 01                      STA   $01,X               ; * ACCUMULATOR AND SAVE IT
8845  39                L8845    RTS

* EXPRESSION EVALUATION RAM HOOK
8846  35 40             XVEC15   PULS  U                   ; PULL RETURN ADDRESS AND SAVE IN U REGISTER
8848  0F 06                      CLR   VALTYP              ; SET VARIABLE TYPE TO NUMERIC
884A  9E A6                      LDX   CHARAD              ; CURRENT INPUT POINTER TO X
884C  9D 9F                      JSR   GETNCH              ; GET CHARACTER FROM BASIC
884E  81 26                      CMPA  #'&'                ; HEX AND OCTAL VARIABLES ARE PRECEEDED BY &
8850  27 99                      BEQ   L87EB               ; PROCESS A '&' VARIABLE
8852  81 CC                      CMPA  #$CC                ; TOKEN FOR FN
8854  27 5E                      BEQ   L88B4               ; PROCESS FN CALL
8856  81 FF                      CMPA  #$FF                ; CHECK FOR SECONDARY TOKEN
8858  26 08                      BNE   L8862               ; NOT SECONDARY
885A  9D 9F                      JSR   GETNCH              ; GET CHARACTER FROM BASIC
885C  81 83                      CMPA  #$83                ; TOKEN FOR USR
885E  10 27 00 CA                LBEQ  L892C               ; PROCESS USR CALL
8862  9F A6             L8862    STX   CHARAD              ; RESTORE BASIC'S INPUT POINTER
8864  6E C4                      JMP   ,U                  ; RETURN TO CALLING ROUTINE
8866  9E 68             L8866    LDX   CURLIN              ; GET CURRENT LINE NUMBER
8868  30 01                      LEAX  $01,X               ; IN DIRECT MODE?
886A  26 D9                      BNE   L8845               ; RETURN IF NOT IN DIRECT MODE
886C  C6 16                      LDB   #2*11               ; 'ILLEGAL DIRECT STATEMENT' ERROR
886E  7E AC 46          L886E    JMP   LAC46               ; PROCESS ERROR
