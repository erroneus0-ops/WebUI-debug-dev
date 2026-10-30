; Extended Color BASIC 1.1 -- $8BDD-$8CF0
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: HEXDOL=$8BDD, DLOAD=$8C18, $ AMBLE. THE PREAMBLE CONTAINS A BLOCK LENGTH AND A LOAD ADDRESS SO=$

* CONVERT AN INTEGER INTO AN ASCII STRING AND PRINT IT ON THE SCREEN
8BDD  BD B7 40          HEXDOL   JSR   LB740               ; CONVERT FPA0 INTO A POSITIVE 2 BYTE INTEGER
8BE0  8E 03 D9                   LDX   #STRBUF+2           ; POINT TO TEMPORARY BUFFER
8BE3  C6 04                      LDB   #$04                ; CONVERT 4 NIBBLES
8BE5  34 04             L8BE5    PSHS  B                   ; SAVE NIBBLE COUNTER
8BE7  5F                         CLRB                      ; CLEAR CARRY FLAG
8BE8  86 04                      LDA   #$04                ; 4 SHIFTS
8BEA  08 53             L8BEA    ASL   FPA0+3              ; * SHIFT BOTTOM TWO BYTES OF
8BEC  09 52                      ROL   FPA0+2              ; * FPA0 LEFT ONE BIT (X2)
8BEE  59                         ROLB                      ; IF OVERFLOW, ACCB <> 0
8BEF  4A                         DECA                      ; * DECREMENT SHIFT COUNTER AND
8BF0  26 F8                      BNE   L8BEA               ; * BRANCH IF NOT DONE
8BF2  5D                         TSTB                      ; CHECK FOR OVERFLOW
8BF3  26 0A                      BNE   L8BFF               ; BRANCH IF OVERFLOW
8BF5  A6 E4                      LDA   ,S                  ; * GET NIBBLE COUNTER,
8BF7  4A                         DECA                      ; * DECREMENT IT AND
8BF8  27 05                      BEQ   L8BFF               ; * BRANCH IF DONE
8BFA  8C 03 D9                   CMPX  #STRBUF+2           ; = DO NOT DO A CONVERSION UNTIL A NON-ZERO
8BFD  27 0C                      BEQ   L8C0B               ; = BYTE IS FOUND - LEADING ZERO SUPPRESSION
8BFF  CB 30             L8BFF    ADDB  #'0'                ; ADD IN ASCII ZERO
8C01  C1 39                      CMPB  #'9'                ; COMPARE TO ASCII 9
8C03  23 02                      BLS   L8C07               ; BRANCH IF < 9
8C05  CB 07                      ADDB  #'A'-('9'+1)        ; ADD ASCII OFFSET IF HEX LETTER
8C07  E7 80             L8C07    STB   ,X+                 ; STORE HEX VALUE AND ADVANCE POINTER
8C09  6F 84                      CLR   ,X                  ; CLEAR NEXT BYTE - END OF STRING FLAG
8C0B  35 04             L8C0B    PULS  B                   ; * GET NIBBLE COUNTER,
8C0D  5A                         DECB                      ; * DECREMENT IT AND
8C0E  26 D5                      BNE   L8BE5               ; * BRANCH IF NOT DONE
8C10  32 62                      LEAS  $02,S               ; PURGE RETURN ADDRESS OFF OF STACK
8C12  8E 03 D8                   LDX   #STRBUF+1           ; RESET POINTER
8C15  7E B5 18                   JMP   LB518               ; SAVE STRING ON STRING STACK

* DLOAD
8C18  BD A4 29          DLOAD    JSR   LA429               ; CLOSE FILES
8C1B  9D A5             L8C1B    JSR   GETCCH              ; GET THE CURRENT INPUT CHARACTER
8C1D  80 4D                      SUBA  #'M'                ; CHECK FOR DLOADM
8C1F  34 02                      PSHS  A                   ; SAVE DLOADM (=0), OLOAD (<>0) FLAG
8C21  26 02                      BNE   L8C25               ; BRANCH IF OLOAD
8C23  9D 9F                      JSR   GETNCH              ; GET AN INPUT CHAR FROM BASIC
8C25  BD A5 78          L8C25    JSR   LA578               ; GET THE NAME OF FILE FROM BASIC
8C28  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHAR FROM BASIC
8C2A  27 18                      BEQ   L8C44               ; BRANCH IF END OF LINE
8C2C  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
8C2F  81 2C                      CMPA  #','                ; CHECK FOR TWO CONSECUTIVE COMMAS
8C31  27 11                      BEQ   L8C44               ; *BRANCH IF,, - IF THIS CASE IS SELECTED
* *THE BAUD DELAY MUST HAVE BEEN PREVIOUSLY STORED IN DIBAUD
8C33  BD B7 0B                   JSR   EVALEXPB            ; EVAL EXPR, RETURN VALUE IN ACCB
8C36  86 B0                      LDA   #44*4               ; DELAY VALUE FOR 300 BAUD
8C38  5D                         TSTB                      ; WAS ARGUMENT = 0?
8C39  27 07                      BEQ   L8C42               ; YES - 300 BAUD
8C3B  86 2C                      LDA   #44                 ; DELAY VALUE FOR 1200 BAUD
8C3D  5A                         DECB                      ; CHECK FOR ARGUMENT OF 1
8C3E  10 26 28 08                LBNE  LB44A               ; 'FC' ERROR IF NOT ZERO OR ONE OR COMMA
8C42  97 E6             L8C42    STA   DLBAUD              ; SAVE DELAY VALUE
8C44  BD 8C D0          L8C44    JSR   L8CD0               ; TRANSMIT FILE NAME AND READ IN FILE STATUS
8C47  34 02                      PSHS  A                   ; SAVE ACCA
8C49  86 FD                      LDA   #-3                 ; DLOAD DEVICE NUMBER TO -3
8C4B  97 6F                      STA   DEVNUM              ; SET DEVICE NUMBER TO DLOAD
8C4D  35 02                      PULS  A                   ; RESTORE ACCA
8C4F  6D E0                      TST   ,S+                 ; DLOAD OR DLOADM?
8C51  27 32                      BEQ   L8C85               ; DLOADM

* READ IN A DLOAD FILE
8C53  BD A5 C7                   JSR   LA5C7               ; CHECK FOR END OF LINE - SYNTAX ERROR IF NOT
8C56  5D                         TSTB                      ; CHECK ASCII FLAG
8C57  27 06                      BEQ   L8C5F               ; 'FM' ERROR IF NOT ASCII
8C59  BD AD 19                   JSR   LAD19               ; GO DO A 'NEW'
8C5C  7E AC 7C                   JMP   LAC7C               ; *JUMP BACK TO BASIC'S MAIN INPUT LOOP;
* *DLOAD FILES MUST BE ASCII FILES
8C5F  7E A6 16          L8C5F    JMP   LA616               ; 'BAD FILE MODE' ERROR

* EXBAS CLOAD PROCESSOR
8C62  9D 9F             L8C62    JSR   GETNCH              ; GET A CHAR FROM BASIC
8C64  81 4D                      CMPA  #'M'                ; CHECK FOR CLOADM
8C66  10 26 18 2E                LBNE  LA498               ; GO DO A CLOAD
8C6A  0F 78                      CLR   FILSTA              ; CLOSE FILES
8C6C  9D 9F                      JSR   GETNCH              ; GET A CHAR FROM BASIC
8C6E  BD A5 78                   JSR   LA578               ; STRIP A FILENAME OFF OF THE BASIC LINE
8C71  BD A6 48                   JSR   LA648               ; SEARCH FOR FILE
8C74  7D 01 E4                   TST   CASBUF+10           ; CHECK FILE MODE
8C77  10 27 18 8A                LBEQ  LA505               ; BRANCH TO CLOADM IF NOT BLOCK LOAD
8C7B  FE 01 E2                   LDU   CASBUF+8            ; SAVE FILE TYPE AND ASCII FLAG IN U
8C7E  0A 6F                      DEC   DEVNUM              ; SET DEVICE NUMBER TO -1 (CASSETTE)
8C80  BD A6 35                   JSR   LA635               ; GO READ IN A DATA BLOCK
8C83  1F 30                      TFR   U,D                 ; PUT FILE TYPE & ASCII FLAG BACK IN ACCD

* STRIP A LOAD OFFSET FROM THE BASIC LINE, THEN LOAD IN BLOCKS OF
* DATA (CLOADM,DLOADM) WHICH ARE PRECEEDED BY A 5 BYTE PRE OR POST-
                        $ AMBLE. THE PREAMBLE CONTAINS A BLOCK LENGTH AND A LOAD ADDRESS SO
* THAT ANY NUMBER OF NON-CONTIGUOUS BLOCKS MAY BE LOADED. THE POST-
* AMBLE WILL TERMINATE THE LOADING PROCESS AND PROVIDE A TRANSFER ADDRESS
8C85  83 02 00          L8C85    SUBD  #$200               ; * CHECK FILE STATUS;
8C88  26 D5                      BNE   L8C5F               ; * 'FM' ERROR IF MODE <> 2 OR TYPE <> 0
8C8A  9E 8A                      LDX   ZERO                ; ZERO THE X REG - DEFAULT OFFSET
8C8C  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
8C8E  27 06                      BEQ   L8C96               ; BRANCH IF END OF LINE
8C90  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
8C93  BD B7 3D                   JSR   LB73D               ; EVAL INTEGER EXPR - RETURN VALUE IN X
8C96  9F D3             L8C96    STX   VD3                 ; SAVE OFFSET
8C98  BD A5 C7                   JSR   LA5C7               ; SYNTAX ERROR IF MORE CHARS ON LINE
8C9B  8D 29             L8C9B    BSR   L8CC6               ; GO GET EOF FLAG FROM CONSOLE IN
8C9D  34 02                      PSHS  A                   ; SAVE IT ON THE STACK
8C9F  8D 1E                      BSR   L8CBF               ; * READ IN BLOCK LENGTH FROM CONSOLE IN
8CA1  1F 02                      TFR   D,Y                 ; * AND SAVE IT IN Y
8CA3  8D 1A                      BSR   L8CBF               ; GET LOAD ADDRESS FROM CONSOLE IN
8CA5  D3 D3                      ADDD  VD3                 ; ADD OFFSET TO LOAD ADDRESS
8CA7  DD 9D                      STD   EXECJP              ; SAVE IN EXEC ADDRESS
8CA9  1F 01                      TFR   D,X                 ; SAVE LOAD ADDRESS IN X
8CAB  A6 E0                      LDA   ,S+                 ; GET EOF FLAG FROM STACK
8CAD  10 26 17 7C                LBNE  LA42D               ; CLOSE FILES IF POSTAMBLE BLOCK
8CB1  8D 13             L8CB1    BSR   L8CC6               ; GET A CHARACTER FROM CONSOLE IN
8CB3  A7 84                      STA   ,X                  ; SAVE IT IN RAM
8CB5  A1 80                      CMPA  ,X+                 ; COMPARE SAVED BYTE TO ACTUAL BYTE
8CB7  26 14                      BNE   L8CCD               ; 'IO' ERROR IF NOT = (SAVED IN ROM OR BAD RAM)
8CB9  31 3F                      LEAY  $-01,Y              ; DECREMENT BYTE COUNT
8CBB  26 F4                      BNE   L8CB1               ; READ MORE CHARACTERS
8CBD  20 DC                      BRA   L8C9B               ; LOOK FOR ANOTHER BLOCK OF DATA
* GET 2 CHARACTERS - RETURN THEM IN ACCD
8CBF  8D 00             L8CBF    BSR   L8CC1               ; GET A CHARACTER IN ACCB
8CC1  8D 03             L8CC1    BSR   L8CC6               ; GET A CHARACTER IN ACCA
8CC3  1E 89                      EXG   A,B                 ; SAVE IT IN ACCB
8CC5  39                L8CC5    RTS

8CC6  BD A1 76          L8CC6    JSR   LA176               ; GET A CHARACTER FROM CONSOLE IN
8CC9  0D 70                      TST   CINBFL              ; IS FILE EMPTY?
8CCB  27 F8                      BEQ   L8CC5               ; RETURN IF NOT EMPTY
8CCD  7E A6 19          L8CCD    JMP   LA619               ; 'IO' ERROR IF EMPTY
8CD0  8D 42             L8CD0    BSR   L8D14               ; TRANSMIT FILE NAME, RETURN FILE STATUS
8CD2  34 06                      PSHS  B,A                 ; SAVE FILE STATUS ON STACK
8CD4  4C                         INCA                      ; CHECK FILE TYPE
8CD5  27 06                      BEQ   L8CDD               ; 'NE' ERROR IF FILE NOT FOUND
8CD7  DE 8A                      LDU   ZERO                ; ZERO U REG :FIRST BLOCK NUMBER
8CD9  8D 09                      BSR   L8CE4               ; READ IN 128 CHARACTERS
8CDB  35 86                      PULS  A,B,PC              ; GET FILE STATUS BACK AND RETURN
8CDD  C6 34             L8CDD    LDB   #2*26               ; 'NE' ERROR
8CDF  7E AC 46                   JMP   LAC46               ; GO TO ERROR SERVICING ROUTINE
* REFILL CONSOLE IN CHARACTER BUFFER FROM DLOAD
8CE2  DE 7E             L8CE2    LDU   CBUFAD              ; GET BLOCK NUMBER
8CE4  30 41             L8CE4    LEAX  $01,U               ; * INCREMENT BLOCK NUMBER
8CE6  9F 7E                      STX   CBUFAD              ; * AND SAVE IT
8CE8  8E 01 DA                   LDX   #CASBUF             ; USE CASBUF AS DLOAD INPUT BUFFER
8CEB  BD 8D 7C                   JSR   L8D7C               ; READ 128 CHARACTERS (ONE BLOCK) INTO BUFFER
8CEE  7E A6 44                   JMP   LA644               ; RESET CONSOLE IN BUFFER
