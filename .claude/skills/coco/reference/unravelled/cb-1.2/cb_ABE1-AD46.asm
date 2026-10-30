; Color BASIC 1.2 -- $ABE1-$AD46
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: NEW=$AD17

ABE1  20 45 52 52 4F 52 LABE1    FCC   ' ERROR'
ABE7  00                         FCB   $00
ABE8  20 49 4E 20       LABE8    FCC   ' IN '
ABEC  00                         FCB   $00
ABED  0D                LABED    FCB   CR
ABEE  4F 4B             LABEE    FCC   'OK'
ABF0  0D 00                      FCB   CR,$00
ABF2  0D                LABF2    FCB   CR
ABF3  42 52 45 41 4B             FCC   'BREAK'
ABF8  00                         FCB   $00
* SEARCH THE STACK FOR 'GOSUB/RETURN' OR 'FOR/NEXT' DATA.
* THE 'FOR/NEXT' INDEX VARIABLE DESCRIPTOR ADDRESS BEING
* SOUGHT IS STORED IN VARDES. EACH BLOCK OF FOR/NEXT DATA IS 18
* BYTES WITH A $80 LEADER BYTE AND THE GOSUB/RETURN DATA IS 5 BYTES
* WITH AN $A6 LEADER BYTE.  THE FIRST NON "FOR/NEXT" DATA
* IS CONSIDERED 'GOSUB/RETURN'
ABF9  30 64             LABF9    LEAX  4,S                 ; POINT X TO 3RD ADDRESS ON STACK - IGNORE THE
* FIRST TWO RETURN ADDRESSES ON THE STACK
ABFB  C6 12             LABFB    LDB   #18                 ; 18 BYTES SAVED ON STACK FOR EACH 'FOR' LOOP
ABFD  9F 0F                      STX   TEMPTR              ; SAVE POINTER
ABFF  A6 84                      LDA   ,X                  ; GET 1ST BYTE
AC01  80 80                      SUBA  #$80                ; * CHECK FOR TYPE OF STACK JUMP FOUND
AC03  26 15                      BNE   LAC1A               ; * BRANCH IF NOT 'FOR/NEXT'
AC05  AE 01                      LDX   1,X                 ; = GET INDEX VARIABLE DESCRIPTOR
AC07  9F 11                      STX   TMPTR1              ; = POINTER AND SAVE IT IN TMPTR1
AC09  9E 3B                      LDX   VARDES              ; GET INDEX VARIABLE BEING SEARCHED FOR
AC0B  27 09                      BEQ   LAC16               ; BRANCH IF DEFAULT INDEX VARIABLE - USE THE
* FIRST 'FOR/NEXT' DATA FOUND ON STACK
* IF NO INDEX VARIABLE AFTER 'NEXT'
AC0D  9C 11                      CMPX  TMPTR1              ; DOES THE STACK INDEX MATCH THE ONE
* BEING SEARCHED FOR?
AC0F  27 09                      BEQ   LAC1A               ; YES
AC11  9E 0F                      LDX   TEMPTR              ; * RESTORE INITIAL POINTER, ADD
AC13  3A                         ABX                       ; * 18 TO IT AND LOOK FOR
AC14  20 E5                      BRA   LABFB               ; * NEXT BLOCK OF DATA
AC16  9E 11             LAC16    LDX   TMPTR1              ; = GET 1ST INDEX VARIABLE FOUND AND
AC18  9F 3B                      STX   VARDES              ; = SAVE AS 'NEXT' INDEX
AC1A  9E 0F             LAC1A    LDX   TEMPTR              ; POINT X TO START OF 'FOR/NEXT' DATA
AC1C  4D                         TSTA                      ; SET ZERO FLAG IF 'FOR/NEXT' DATA
AC1D  39                         RTS
* CHECK FOR MEMORY SPACE FOR NEW TOP OF
* ARRAYS AND MOVE ARRAYS TO NEW LOCATION
AC1E  8D 17             LAC1E    BSR   LAC37               ;  ACCD = NEW BOTTOM OF FREE RAM - IS THERE
* ROOM FOR THE STACK?
* MOVE BYTES FROM V43(X) TO V41(U) UNTIL (X) = V47 AND
* SAVE FINAL VALUE OF U IN V45
AC20  DE 41             LAC20    LDU   V41                 ; POINT U TO DESTINATION ADDRESS (V41)
AC22  33 41                      LEAU  1,U                 ; ADD ONE TO U - COMPENSATE FOR FIRST PSHU
AC24  9E 43                      LDX   V43                 ; POINT X TO SOURCE ADDRESS (V43)
AC26  30 01                      LEAX  1,X                 ; ADD ONE - COMPENSATE FOR FIRST LDA ,X
AC28  A6 82             LAC28    LDA   ,-X                 ; GRAB A BYTE FROM SOURCE
AC2A  36 02                      PSHU  A                   ; MOVE IT TO DESTINATION
AC2C  9C 47                      CMPX  V47                 ; DONE?
AC2E  26 F8                      BNE   LAC28               ; NO - KEEP MOVING BYTES
AC30  DF 45                      STU   V45                 ; SAVE FINAL DESTINATION ADDRESS
AC32  39                LAC32    RTS
* CHECK TO SEE IF THERE IS ROOM TO STORE 2*ACCB
* BYTES IN FREE RAM - OM ERROR IF NOT
AC33  4F                LAC33    CLRA                      ; * ACCD CONTAINS NUMBER OF EXTRA
AC34  58                         ASLB                      ; * BYTES TO PUT ON STACK
AC35  D3 1F                      ADDD  ARYEND              ; END OF PROGRAM AND VARIABLES
AC37  C3 00 3A          LAC37    ADDD  #STKBUF             ; ADD STACK BUFFER - ROOM FOR STACK?
AC3A  25 08                      BCS   LAC44               ; BRANCH IF GREATER THAN $FFFF
AC3C  10 DF 17                   STS   BOTSTK              ; CURRENT NEW BOTTOM OF STACK STACK POINTER
AC3F  10 93 17                   CMPD  BOTSTK              ; ARE WE GOING TO BE BELOW STACK?
AC42  25 EE                      BCS   LAC32               ; YES - NO ERROR
AC44  C6 0C             LAC44    LDB   #6*2                ; OUT OF MEMORY ERROR

* ERROR SERVICING ROUTINE
AC46  BD 01 8E          LAC46    JSR   RVEC16              ; HOOK INTO RAM
AC49  BD 01 91                   JSR   RVEC17              ; HOOK INTO RAM
AC4C  BD A7 E9                   JSR   LA7E9               ; TURN OFF CASSETTE
AC4F  BD A9 74                   JSR   LA974               ; DISABLE ANA MUX
AC52  BD AD 33                   JSR   LAD33               ; RESET STACK, STRING STACK, CONTINUE POINTER
AC55  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
AC57  BD B9 5C                   JSR   LB95C               ; SEND A CR TO SCREEN
AC5A  BD B9 AF                   JSR   LB9AF               ; SEND A '?' TO SCREEN
AC5D  8E AB AF                   LDX   #LABAF              ; POINT TO ERROR TABLE
AC60  3A                         ABX                       ; ADD MESSAGE NUMBER OFFSET
AC61  8D 3D                      BSR   LACA0               ; * GET TWO CHARACTERS FROM X AND
AC63  8D 3B                      BSR   LACA0               ; * SEND TO CONSOLE OUT (SCREEN)
AC65  8E AB E0                   LDX   #LABE1-1            ; POINT TO "ERROR" MESSAGE
AC68  BD B9 9C          LAC68    JSR   LB99C               ; PRINT MESSAGE POINTED TO BY X
AC6B  96 68                      LDA   CURLIN              ; GET CURRENT LINE NUMBER (CURL IN)
AC6D  4C                         INCA                      ; TEST FOR DIRECT MODE
AC6E  27 03                      BEQ   LAC73               ; BRANCH IF DIRECT MODE
AC70  BD BD C5                   JSR   LBDC5               ; PRINT 'IN ****'

* THIS IS THE MAIN LOOP OF BASIC WHEN IN DIRECT MODE
AC73  BD B9 5C          LAC73    JSR   LB95C               ; MOVE CURSOR TO START OF LINE
AC76  8E AB ED                   LDX   #LABE1-1            ; POINT X TO 'OK', CR MESSAGE
AC79  BD B9 9C                   JSR   LB99C               ; PRINT 'OK', CR
AC7C  BD A3 90          LAC7C    JSR   LA390               ; GO GET AN INPUT LINE
AC7F  CE FF FF                   LDU   #FFFF               ; THE LINE NUMBER FOR DIRECT MODE IS $FFFF
AC82  DF 68                      STU   CURLIN              ; SAVE IT IN CURLIN
AC84  25 F6                      BCS   LAC7C               ; BRANCH IF LINE INPUT TERMINATED BY BREAK
AC86  0D 70                      TST   CINBFL              ; CHECK CONSOLE INPUT BUFFER STATUS
AC88  10 26 F8 33                LBNE  LA4BF               ; BRANCH IF BUFFER EMPTY - CLOSE FILE IF EMPTY
AC8C  9F A6                      STX   CHARAD              ; SAVE (X) AS CURRENT INPUT POINTER - THIS WILL
* ENABLE THE 'LIVE KEYBOARD' (DIRECT) MODE. THE
* LINE JUST ENTERED WILL BE INTERPRETED
AC8E  9D 9F                      JSR   GETNCH              ; GET NEXT CHARACTER FROM BASIC
AC90  27 EA                      BEQ   LAC7C               ; NO LINE INPUT - GET ANOTHER LINE
AC92  25 11                      BCS   LACA5               ; BRANCH IF NUMER1C - THERE WAS A LINE NUMBER BEFORE
* THE STATEMENT ENTERED, SO THIS STATEMENT
* WILL BE MERGED INTO THE BASIC PROGRAM
AC94  C6 30                      LDB   #2*24               ; 'DIRECT STATEMENT IN FILE' ERROR
AC96  0D 6F                      TST   DEVNUM              ; * CHECK DEVICE NUMBER AND
AC98  26 AC                      BNE   LAC46               ; * ISSUE 'DS' ERROR IF DEVNUM <> 0
AC9A  BD B8 21                   JSR   LB821               ; GO CRUNCH LINE
AC9D  7E AD C0                   JMP   LADC0               ; GO EXECUTE THE STATEMENT (LIVE KEYBOARD)
*
ACA0  A6 80             LACA0    LDA   ,X+                 ;  GET A CHARACTER
ACA2  7E B9 B1                   JMP   LB9B1               ; SEND TO CONSOLE OUT
* TAKE A LINE FROM THE LINE INPUT BUFFER
* AND INSERT IT INTO THE BASIC PROGRAM
ACA5  BD AF 67          LACA5    JSR   LAF67               ; CONVERT LINE NUMBER TO BINARY
ACA8  9E 2B                      LDX   BINVAL              ; GET CONVERTED LINE NUMBER
ACAA  BF 02 DA                   STX   LINHDR              ; STORE IT IN LINE INPUT HEADER
ACAD  BD B8 21                   JSR   LB821               ; GO CRUNCH THE LINE
ACB0  D7 03                      STB   TMPLOC              ; SAVE LINE LENGTH
ACB2  8D 4D                      BSR   LAD01               ; FIND OUT WHERE TO INSERT LINE
ACB4  25 12                      BCS   LACC8               ; BRANCH IF LINE NUMBER DOES NOT ALREADY EXIST
ACB6  DC 47                      LDD   V47                 ; GET ABSOLUTE ADDRESS OF LINE NUMBER
ACB8  A3 84                      SUBD  ,X                  ; SUBTRACT ADDRESS OF NEXT LINE NUMBER
ACBA  D3 1B                      ADDD  VARTAB              ; * ADD TO CURRENT END OF PROGRAM - THIS WILL REMOVE
ACBC  DD 1B                      STD   VARTAB              ; * THE LENGTH OF THIS LINE NUMBER FROM THE PROGRAM
ACBE  EE 84                      LDU   ,X                  ; POINT U TO ADDRESS OF NEXT LINE NUMBER
* DELETE OLD LINE FROM BASIC PROGRAM
ACC0  37 02             LACC0    PULU  A                   ; GET A BYTE FROM WHAT'S LEFT OF PROGRAM
ACC2  A7 80                      STA   ,X+                 ; MOVE IT DOWN
ACC4  9C 1B                      CMPX  VARTAB              ; COMPARE TO END OF BASIC PROGRAM
ACC6  26 F8                      BNE   LACC0               ; BRANCH IF NOT AT END
ACC8  B6 02 DC          LACC8    LDA   LINBUF              ; * CHECK TO SEE IF THERE IS A LINE IN
ACCB  27 1C                      BEQ   LACE9               ; * THE BUFFER AND BRANCH IF NONE
ACCD  DC 1B                      LDD   VARTAB              ; = SAVE CURRENT END OF
ACCF  DD 43                      STD   V43                 ; = PROGRAM IN V43
ACD1  DB 03                      ADDB  TMPLOC              ; * ADD LENGTH OF CRUNCHED LINE,
ACD3  89 00                      ADCA  #0                  ; * PROPOGATE CARRY AND SAVE NEW END
ACD5  DD 41                      STD   V41                 ; * OF PROGRAM IN V41
ACD7  BD AC 1E                   JSR   LAC1E               ; = MAKE SURE THERE'S ENOUGH RAM FOR THIS
* = LINE & MAKE A HOLE IN BASIC FOR NEW LINE
ACDA  CE 02 D8                   LDU   #LINHDR-2           ; POINT U TO LINE TO BE INSERTED
ACDD  37 02             LACDD    PULU  A                   ; GET A BYTE FROM NEW LINE
ACDF  A7 80                      STA   ,X+                 ; INSERT IT IN PROGRAM
ACE1  9C 45                      CMPX  V45                 ; * COMPARE TO ADDRESS OF END OF INSERTED
ACE3  26 F8                      BNE   LACDD               ; * LINE AND BRANCH IF NOT DONE
ACE5  9E 41                      LDX   V41                 ; = GET AND SAVE
ACE7  9F 1B                      STX   VARTAB              ; = END OF PROGRAM
ACE9  8D 36             LACE9    BSR   LAD21               ; RESET INPUT POINTER, CLEAR VARIABLES, INITIALIZE
ACEB  8D 02                      BSR   LACEF               ; ADJUST START OF NEXT LINE ADDRESSES
ACED  20 8D                      BRA   LAC7C               ; REENTER BASIC'S INPUT LOOP
* COMPUTE THE START OF NEXT LINE ADDRESSES FOR THE BASIC PROGRAM
ACEF  9E 19             LACEF    LDX   TXTTAB              ; POINT X TO START OF PROGRAM
ACF1  EC 84             LACF1    LDD   ,X                  ; GET ADDRESS OF NEXT LINE
ACF3  27 21                      BEQ   LAD16               ; RETURN IF END OF PROGRAM
ACF5  33 04                      LEAU  4,X                 ; POINT U TO START OF BASIC TEXT IN LINE
ACF7  A6 C0             LACF7    LDA   ,U+                 ; * SKIP THROUGH THE LINE UNTIL A
ACF9  26 FC                      BNE   LACF7               ; * ZERO (END OF LINE) IS FOUND
ACFB  EF 84                      STU   ,X                  ; SAVE THE NEW START OF NEXT LINE ADDRESS
ACFD  AE 84                      LDX   ,X                  ; POINT X TO START OF NEXT LINE
ACFF  20 F0                      BRA   LACF1               ; KEEP GOING
*
* FIND A LINE NUMBER IN THE BASIC PROGRAM
* RETURN WITH CARRY SET IF NO MATCH FOUND
AD01  DC 2B             LAD01    LDD   BINVAL              ; GET THE LINE NUMBER TO FIND
AD03  9E 19                      LDX   TXTTAB              ; BEGINNING OF PROGRAM
AD05  EE 84             LAD05    LDU   ,X                  ; GET ADDRESS OF NEXT LINE NUMBER
AD07  27 09                      BEQ   LAD12               ; BRANCH IF END OF PROG
AD09  10 A3 02                   CMPD  2,X                 ; IS IT A MATCH?
AD0C  23 06                      BLS   LAD14               ; CARRY SET IF LOWER; CARRY CLEAR IF MATCH
AD0E  AE 84                      LDX   ,X                  ; X = ADDRESS OF NEXT LINE
AD10  20 F3                      BRA   LAD05               ; KEEP LOOPING FOR LINE NUMBER
AD12  1A 01             LAD12    ORCC  #1                  ; SET CARRY FLAG
AD14  9F 47             LAD14    STX   V47                 ; SAVE MATCH LINE NUMBER OR NUMBER OF LINE JUST AFTER
; WHERE IT SHOULD HAVE BEEN
AD16  39                LAD16    RTS

* NEW
AD17  26 FB             NEW      BNE   LAD14               ; BRANCH IF ARGUMENT GIVEN
AD19  9E 19             LAD19    LDX   TXTTAB              ; GET START OF BASIC
AD1B  6F 80                      CLR   ,X+                 ; * PUT 2 ZERO BYTES THERE - ERASE
AD1D  6F 80                      CLR   ,X+                 ; * THE BASIC PROGRAM
AD1F  9F 1B                      STX   VARTAB              ; AND THE NEXT ADDRESS IS NOW THE END OF PROGRAM
AD21  9E 19             LAD21    LDX   TXTTAB              ; GET START OF BASIC
AD23  BD AE BB                   JSR   LAEBB               ; PUT INPUT POINTER ONE BEFORE START OF BASIC
* ERASE ALL VARIABLES
AD26  9E 27             LAD26    LDX   MEMSIZ              ; * RESET START OF STRING VARIABLES
AD28  9F 23                      STX   STRTAB              ; * TO TOP OF STRING SPACE
AD2A  BD AD E4                   JSR   RESTOR              ; RESET 'DATA' POINTER TO START OF BASIC
AD2D  9E 1B                      LDX   VARTAB              ; * GET START OF VARIABLES AND USE IT
AD2F  9F 1D                      STX   ARYTAB              ; * TO RESET START OF ARRAYS
AD31  9F 1F                      STX   ARYEND              ; RESET END OF ARRAYS
AD33  8E 01 A9          LAD33    LDX   #STRSTK             ; * RESET STRING STACK POINTER TO
AD36  9F 0B                      STX   TEMPPT              ; * BOTTOM OF STRING STACK
AD38  AE E4                      LDX   ,S                  ; GET RETURN ADDRESS OFF STACK
AD3A  10 DE 21                   LDS   FRETOP              ; RESTORE STACK POINTER
AD3D  6F E2                      CLR   ,-S                 ; PUT A ZERO BYTE ON STACK - TO CLEAR ANY RETURN OF
* FOR/NEXT DATA FROM THE STACK
AD3F  0F 2D                      CLR   OLDPTR              ; RESET 'CONT' ADDRESS SO YOU
AD41  0F 2E                      CLR   OLDPTR+1            ; 'CAN'T CONTINUE'
AD43  0F 08                      CLR   ARYDIS              ; CLEAR THE ARRAY DISABLE FLAG
AD45  6E 84                      JMP   ,X                  ; RETURN TO CALLING ROUTINE - THIS IS NECESSARY
