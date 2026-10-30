; Color BASIC 1.2 -- $B4FD-$B69F
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: STR=$B4FD, LEN=$B681, CHR=$B68C

* STR$
B4FD  BD B1 43          STR      JSR   LB143               ; 'TM' ERROR IF STRING VARIABLE
B500  CE 03 D9                   LDU   #STRBUF+2           ; *CONVERT FP NUMBER TO ASCII STRING IN
B503  BD BD DC                   JSR   LBDDC               ; *THE STRING BUFFER
B506  32 62                      LEAS  2,S                 ; PURGE THE RETURN ADDRESS FROM THE STACK
B508  8E 03 D8                   LDX   #STRBUF+1           ; *POINT X TO STRING BUFFER AND SAVE
B50B  20 0B                      BRA   LB518               ; *THE STRING IN THE STRING SPACE
* RESERVE ACCB BYTES OF STRING SPACE. RETURN START
* ADDRESS IN (X) AND FRESPC
B50D  9F 4D             LB50D    STX   V4D                 ; SAVE X IN V4D
B50F  8D 5C             LB50F    BSR   LB56D               ; RESERVE ACCB BYTES IN STRING SPACE
B511  9F 58             LB511    STX   STRDES+2            ; SAVE NEW STRING ADDRESS
B513  D7 56                      STB   STRDES              ; SAVE LENGTH OF RESERVED BLOCK
B515  39                         RTS
B516  30 1F             LB516    LEAX  -1,X                ; MOVE POINTER BACK ONE
* SCAN A LINE FROM (X) UNTIL AN END OF LINE FLAG (ZERO) OR
* EITHER OF THE TWO TERMINATORS STORED IN CHARAC OR ENDCHR IS MATCHED.
* THE RESULTING STRING IS STORED IN THE STRING SPACE
* ONLY IF THE START OF THE STRING IS <= STRBUF+2
B518  86 22             LB518    LDA   #'"                 ; * INITIALIZE
B51A  97 01             LB51A    STA   CHARAC              ; * TERMINATORS [label LB51A moved here from $B51C: the ROM bytes of the code that references it point here]
B51C  97 02                      STA   ENDCHR              ; * TO "
B51E  30 01             LB51E    LEAX  1,X                 ; MOVE POINTER UP ONE
B520  9F 62                      STX   RESSGN              ; TEMPORARILY SAVE START OF STRING
B522  9F 58                      STX   STRDES+2            ; SAVE START OF STRING IN TEMP DESCRIPTOR
B524  C6 FF                      LDB   #-1                 ; INITIALIZE CHARACTER COUNTER TO - 1
B526  5C                LB526    INCB                      ; INCREMENT CHARACTER COUNTER
B527  A6 80                      LDA   ,X+                 ; GET CHARACTER
B529  27 0C                      BEQ   LB537               ; BRANCH IF END OF LINE
B52B  91 01                      CMPA  CHARAC              ; * CHECK FOR TERMINATORS
B52D  27 04                      BEQ   LB533               ; * IN CHARAC AND ENDCHR
B52F  91 02                      CMPA  ENDCHR              ; * DON'T MOVE POINTER BACK
B531  26 F3                      BNE   LB526               ; * ONE IF TERMINATOR IS "MATCHED"
B533  81 22             LB533    CMPA  #'"                 ; = COMPARE CHARACTER TO STRING DELIMITER
B535  27 02                      BEQ   LB539               ; = & DON'T MOVE POINTER BACK IF SO
B537  30 1F             LB537    LEAX  -1,X                ; MOVE POINTER BACK ONE
B539  9F 64             LB539    STX   COEFPT              ; SAVE END OF STRING ADDRESS
B53B  D7 56                      STB   STRDES              ; SAVE STRING LENGTH IN TEMP DESCRIPTOR
B53D  DE 62                      LDU   RESSGN              ; GET INITlAL STRING START
B53F  11 83 03 D9                CMPU  #STRBUF+2           ; COMPARE TO START OF STRING BUFFER
B543  22 07             LB543    BHI   LB54C               ; BRANCH IF > START OF STRING BUFFER
B545  8D C6                      BSR   LB50D               ; GO RESERVE SPACE FOR THE STRING
B547  9E 62                      LDX   RESSGN              ; POINT X TO THE BEGINNING OF THE STRING
B549  BD B6 45                   JSR   LB645               ; MOVE (B) BYTES FROM (X) TO
* [FRESPC] - MOVE STRING DATA
* PUT DIRECT PAGE STRING DESCRIPTOR BUFFER DATA
* ON THE STRING STACK. SET VARIABLE TYPE TO STRING
B54C  9E 0B             LB54C    LDX   TEMPPT              ; GET NEXT AVAILABLE STRING STACK DESCRIPTOR
B54E  8C 01 D1                   CMPX  #CFNBUF             ; COMPARE TO TOP OF STRING DESCRIPTOR STACK
B551  26 05                      BNE   LB558               ; FORMULA O.K.
B553  C6 1E                      LDB   #15*2               ; 'STRING FORMULA TOO COMPLEX' ERROR
B555  7E AC 46          LB555    JMP   LAC46               ; JUMP TO ERROR SERVICING ROUTINE
B558  96 56             LB558    LDA   STRDES              ; * GET LENGTH OF STRING AND SAVE IT
B55A  A7 00                      STA   ,X                  ; * IN BYTE 0 OF DESCRIPTOR
B55C  DC 58                      LDD   STRDES+2            ; = GET START ADDRESS OF ACTUAL STRING
B55E  ED 02                      STD   2,X                 ; = AND SAVE IN BYTES 2,3 OF DESCRIPTOR
B560  86 FF                      LDA   #$FF                ; * VARIABLE TYPE = STRING
B562  97 06                      STA   VALTYP              ; * SAVE IN VARIABLE TYPE FLAG
B564  9F 0D                      STX   LASTPT              ; = SAVE START OF DESCRIPTOR
B566  9F 52                      STX   FPA0+2              ; = ADDRESS IN LASTPT AND FPA0
B568  30 05                      LEAX  5,X                 ; 5 BYTES/STRING DESCRIPTOR
B56A  9F 0B                      STX   TEMPPT              ; NEXT AVAILABLE STRING VARIABLE DESCRIPTOR
B56C  39                         RTS
* RESERVE ACCB BYTES IN STRING STORAGE SPACE
* RETURN WITH THE STARTING ADDRESS OF THE
* RESERVED STRING SPACE IN (X) AND FRESPC
B56D  0F 07             LB56D    CLR   GARBFL              ; CLEAR STRING REORGANIZATION FLAG
B56F  4F                LB56F    CLRA                      ; * PUSH THE LENGTH OF THE
B570  34 06                      PSHS  B,A                 ; * STRING ONTO THE STACK
B572  DC 23                      LDD   STRTAB              ; GET START OF STRING VARIABLES
B574  A3 E0                      SUBD  ,S+                 ; SUBTRACT STRING LENGTH
B576  10 93 21                   CMPD  FRETOP              ; COMPARE TO START OF STRING STORAGE
B579  25 0A                      BCS   LB585               ; IF BELOW START, THEN REORGANIZE
B57B  DD 23                      STD   STRTAB              ; SAVE NEW START OF STRING VARIABLES
B57D  9E 23                      LDX   STRTAB              ; GET START OF STRING VARIABLES
B57F  30 01                      LEAX  1,X                 ; ADD ONE
B581  9F 25                      STX   FRESPC              ; SAVE START ADDRESS OF NEWLY RESERVED SPACE
B583  35 84                      PULS  B,PC                ; RESTORE NUMBER OF BYTES RESERVED AND RETURN
B585  C6 1A             LB585    LDB   #2*13               ; 'OUT OF STRING SPACE' ERROR
B587  03 07                      COM   GARBFL              ; TOGGLE REORGANIZATiON FLAG
B589  27 CA                      BEQ   LB555               ; ERROR IF FRESHLY REORGANIZED
B58B  8D 04                      BSR   LB591               ; GO REORGANIZE STRING SPACE
B58D  35 04                      PULS  B                   ; GET BACK THE NUMBER OF BYTES TO RESERVE
B58F  20 DE                      BRA   LB56F               ; TRY TO RESERVE ACCB BYTES AGAIN
* REORGANIZE THE STRING SPACE
B591  9E 27             LB591    LDX   MEMSIZ              ; GET THE TOP OF STRING SPACE
B593  9F 23             LB593    STX   STRTAB              ; SAVE TOP OF UNORGANIZED STRING SPACE
B595  4F                         CLRA                      ; * ZERO OUT ACCD
B596  5F                         CLRB                      ; * AND RESET VARIABLE
B597  DD 4B                      STD   V4B                 ; * POINTER TO 0
B599  9E 21                      LDX   FRETOP              ; POINT X TO START OF STRING SPACE
B59B  9F 47                      STX   V47                 ; SAVE POINTER IN V47
B59D  8E 01 A9                   LDX   #STRSTK             ; POINT X TO START OF STRING DESCRIPTOR STACK
B5A0  9C 0B             LB5A0    CMPX  TEMPPT              ; COMPARE TO ADDRESS OF NEXT AVAILABLE DESCRIPTOR
B5A2  27 04                      BEQ   LB5A8               ; BRANCH IF TOP OF STRING STACK
B5A4  8D 32                      BSR   LB5D8               ; CHECK FOR STRING IN UNORGANIZED STRING SPACE
B5A6  20 F8                      BRA   LB5A0               ; KEEP CHECKING
B5A8  9E 1B             LB5A8    LDX   VARTAB              ; GET THE END OF BASIC PROGRAM
B5AA  9C 1D             LB5AA    CMPX  ARYTAB              ; COMPARE TO END OF VARIABLES
B5AC  27 04                      BEQ   LB5B2               ; BRANCH IF AT TOP OF VARIABLES
B5AE  8D 22                      BSR   LB5D2               ; CHECK FOR STRING IN UNORGANIZED STRING SPACE
B5B0  20 F8                      BRA   LB5AA               ; KEEP CHECKING VARIABLES
B5B2  9F 41             LB5B2    STX   V41                 ; SAVE ADDRESS OF THE END OF VARIABLES
B5B4  9E 41             LB5B4    LDX   V41                 ; GET CURRENT ARRAY POINTER
B5B6  9C 1F             LB5B6    CMPX  ARYEND              ; COMPARE TO THE END OF ARRAYS
B5B8  27 35                      BEQ   LB5EF               ; BRANCH IF AT END OF ARRAYS
B5BA  EC 02                      LDD   2,X                 ; GET LENGTH OF ARRAY AND DESCRIPTOR
B5BC  D3 41                      ADDD  V41                 ; * ADD TO CURRENT ARRAY POINTER
B5BE  DD 41                      STD   V41                 ; * AND SAVE IT
B5C0  A6 01                      LDA   1,X                 ; GET 1ST CHARACTER OF VARIABLE NAME
B5C2  2A F0                      BPL   LB5B4               ; BRANCH IF NUMERIC ARRAY
B5C4  E6 04                      LDB   4,X                 ; GET THE NUMBER OF DIMENSIONS IN THIS ARRAY
B5C6  58                         ASLB                      ; MULTIPLY BY 2
B5C7  CB 05                      ADDB  #5                  ; ADD FIVE BYTES (VARIABLE NAME, ARRAY
* LENGTH, NUMBER DIMENSIONS)
B5C9  3A                         ABX                       ; X NOW POINTS TO START OF ARRAY ELEMENTS
B5CA  9C 41             LB5CA    CMPX  V41                 ; AT END OF THIS ARRAY?
B5CC  27 E8                      BEQ   LB5B6               ; YES - CHECK FOR ANOTHER
B5CE  8D 08                      BSR   LB5D8               ; CHECK FOR STRING LOCATED IN
* UNORGANIZED STRING SPACE
B5D0  20 F8                      BRA   LB5CA               ; KEEP CHECKING ELEMENTS IN THIS ARRAY
B5D2  A6 01             LB5D2    LDA   1,X                 ; GET F1RST BYTE OF VARIABLE NAME
B5D4  30 02                      LEAX  2,X                 ; MOVE POINTER TO DESCRIPTOR
B5D6  2A 14                      BPL   LB5EC               ; BRANCH IF VARIABLE IS NUMERIC
* SEARCH FOR STRING - ENTER WITH X POINTING TO
* THE STRING DESCRIPTOR. IF STRING IS STORED
* BETWEEN V47 AND STRTAB, SAVE DESCRIPTOR POINTER
* IN V4B AND RESET V47 TO STRING ADDRESS
B5D8  E6 84             LB5D8    LDB   ,X                  ; GET THE LENGTH OF THE STRING
B5DA  27 10                      BEQ   LB5EC               ; BRANCH IF NULL - NO STRING
B5DC  EC 02                      LDD   2,X                 ; GET STARTING ADDRESS OF THE STRING
B5DE  10 93 23                   CMPD  STRTAB              ; COMPARE TO THE START OF STRING VARIABLES
B5E1  22 09                      BHI   LB5EC               ; BRANCH IF THIS STRING IS STORED IN
* THE STRING VARIABLES
B5E3  10 93 47                   CMPD  V47                 ; COMPARE TO START OF STRING SPACE
B5E6  23 04                      BLS   LB5EC               ; BRANCH IF NOT STORED IN THE STRING SPACE
B5E8  9F 4B                      STX   V4B                 ; SAVE VARIABLE POINTER IF STORED IN STRING SPACE
B5EA  DD 47                      STD   V47                 ; SAVE STRING STARTING ADDRESS
B5EC  30 05             LB5EC    LEAX  5,X                 ; MOVE TO NEXT VARIABLE DESCRIPTOR
B5EE  39                LB5EE    RTS
B5EF  9E 4B             LB5EF    LDX   V4B                 ; GET ADDRESS OF THE DESCRIPTOR FOR THE
* STRING WHICH IS STORED IN THE HIGHEST RAM ADDRESS IN
* THE UNORGANIZED STRING SPACE
B5F1  27 FB                      BEQ   LB5EE               ; BRANCH IF NONE FOUND AND REORGANIZATION DONE
B5F3  4F                         CLRA                      ; CLEAR MS BYTE OF LENGTH
B5F4  E6 84                      LDB   ,X                  ; GET LENGTH OF STRING
B5F6  5A                         DECB                      ; SUBTRACT ONE
B5F7  D3 47                      ADDD  V47                 ; ADD LENGTH OF STRING TO ITS STARTING ADDRESS
B5F9  DD 43                      STD   V43                 ; SAVE AS MOVE STARTING ADDRESS
B5FB  9E 23                      LDX   STRTAB              ; POINT X TO THE START OF ORGANIZED STRING VARIABLES
B5FD  9F 41                      STX   V41                 ; SAVE AS MOVE ENDING ADDRESS
B5FF  BD AC 20                   JSR   LAC20               ; MOVE STRING FROM CURRENT POSITION TO THE
* TOP OF UNORGANIZED STRING SPACE
B602  9E 4B                      LDX   V4B                 ; POINT X TO STRING DESCRIPTOR
B604  DC 45                      LDD   V45                 ; * GET NEW STARTING ADDRESS OF STRING AND
B606  ED 02                      STD   2,X                 ; * SAVE IT IN DESCRIPTOR
B608  9E 45                      LDX   V45                 ; GET NEW TOP OF UNORGANIZED STRING SPACE
B60A  30 1F                      LEAX  -1,X                ; MOVE POINTER BACK ONE
B60C  7E B5 93                   JMP   >LB593              ; JUMP BACK AND REORGANIZE SOME MORE

* CONCATENATE TWO STRINGS
B60F  DC 52             LB60F    LDD   FPA0+2              ; * GET DESCRIPTOR ADDRESS OF STRING A
B611  34 06                      PSHS  B,A                 ; * AND SAVE IT ON THE STACK
B613  BD B2 23                   JSR   LB223               ; GET DESCRIPTOR ADDRESS OF STRING B
B616  BD B1 46                   JSR   LB146               ; 'TM' ERROR IF NUMERIC VARIABLE
B619  35 10                      PULS  X                   ; * POINT X TO STRING A DESCRIPTOR
B61B  9F 62                      STX   RESSGN              ; * ADDRESS AND SAVE IT IN RESSGN
B61D  E6 84                      LDB   ,X                  ; GET LENGTH OF STRING A
B61F  9E 52                      LDX   FPA0+2              ; POINT X TO DESCRIPTOR OF STRING B
B621  EB 84                      ADDB  ,X                  ; ADD LENGTH OF STRING B TO STR1NG A
B623  24 05                      BCC   LB62A               ; BRANCH IF LENGTH < 256
B625  C6 1C                      LDB   #2*14               ; 'STRING TOO LONG' ERROR IF LENGTH > 255
B627  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR SERVICING ROUTINE
B62A  BD B5 0D          LB62A    JSR   LB50D               ; RESERVE ROOM IN STRING SPACE FOR NEW STRING
B62D  9E 62                      LDX   RESSGN              ; GET DESCRIPTOR ADDRESS OF STRING A
B62F  E6 84                      LDB   ,X                  ; GET LENGTH OF STRING A
B631  8D 10                      BSR   LB643               ; MOVE STRING A INTO RESERVED BUFFER IN STRING SPACE
B633  9E 4D                      LDX   V4D                 ; GET DESCRIPTOR ADDRESS OF STRING B
B635  8D 22                      BSR   LB659               ; GET LENGTH AND ADDRESS OF STRING B
B637  8D 0C                      BSR   LB645               ; MOVE STRING B INTO REST OF RESERVED BUFFER
B639  9E 62                      LDX   RESSGN              ; POINT X TO DESCRIPTOR OF STRING A
B63B  8D 1C                      BSR   LB659               ; DELETE STRING A IF LAST STRING ON STRING STACK
B63D  BD B5 4C                   JSR   LB54C               ; PUT STRING DESCRIPTOR ON THE STRING STACK
B640  7E B1 68                   JMP   LB168               ; BRANCH BACK TO EXPRESSION EVALUATION

* MOVE (B) BYTES FROM 2,X TO FRESPC
B643  AE 02             LB643    LDX   2,X                 ; POINT X TO SOURCE ADDRESS
B645  DE 25             LB645    LDU   FRESPC              ; POINT U TO DESTINATION ADDRESS
B647  5C                         INCB                      ; COMPENSATION FOR THE DECB BELOW
B648  20 04                      BRA   LB64E               ; GO MOVE THE BYTES
* MOVE B BYTES FROM (X) TO (U)
B64A  A6 80             LB64A    LDA   ,X+                 ; * GET A SOURCE BYTE AND MOVE IT
B64C  A7 C0                      STA   ,U+                 ; * TO THE DESTINATION
B64E  5A                LB64E    DECB                      ; DECREMENT BYTE COUNTER
B64F  26 F9                      BNE   LB64A               ; BRANCH IF ALL BYTES NOT MOVED
B651  DF 25                      STU   FRESPC              ; SAVE ENDING ADDRESS IN FRESPC
B653  39                         RTS
* RETURN LENGTH (ACCB) AND ADDRESS (X) OF
* STRING WHOSE DESCRIPTOR IS IN FPA0+2
* DELETE THE STRING IF IT IS THE LAST ONE
* PUT ON THE STRING STACK. REMOVE STRING FROM STRING
* SPACE IF IT IS AT THE BOTTOM OF STRING VARIABLES.
B654  BD B1 46          LB654    JSR   LB146               ; 'TM' ERROR IF VARIABLE TYPE = NUMERIC
B657  9E 52             LB657    LDX   FPA0+2              ; GET ADDRESS OF SELECTED STRING DESCRIPTOR
B659  E6 84             LB659    LDB   ,X                  ; GET LENGTH OF STRING
B65B  8D 18                      BSR   LB675               ; * CHECK TO SEE IF THIS STRING DESCRIPTOR WAS
B65D  26 13                      BNE   LB672               ; * THE LAST ONE PUT ON THE STRING STACK AND
* * BRANCH IF NOT
B65F  AE 07                      LDX   5+2,X               ; GET START ADDRESS OF STRING JUST REMOVED
B661  30 1F                      LEAX  -1,X                ; MOVE POINTER DOWN ONE
B663  9C 23                      CMPX  STRTAB              ; COMPARE TO START OF STRING VARIABLES
B665  26 08                      BNE   LB66F               ; BRANCH IF THIS STRING IS NOT AT THE BOTTOM
* OF STRING VARIABLES
B667  34 04                      PSHS  B                   ; SAVE LENGTH; ACCA WAS CLEARED
B669  D3 23                      ADDD  STRTAB              ; * ADD THE LENGTH OF THE JUST REMOVED STRING
B66B  DD 23                      STD   STRTAB              ; * TO THE START OF STRING VARIABLES - THIS WILL
* * REMOVE THE STRING FROM THE STRING SPACE
B66D  35 04                      PULS  B                   ; RESTORE LENGTH
B66F  30 01             LB66F    LEAX  1,X                 ; ADD ONE TO POINTER
B671  39                         RTS
B672  AE 02             LB672    LDX   2,X                 ; *POINT X TO ADDRESS OF STRING NOT
B674  39                         RTS                       ; *ON THE STRING STACK
* REMOVE STRING FROM STRING STACK. ENTER WITH X
* POINTING TO A STRING DESCRIPTOR - DELETE THE
* STRING FROM STACK IF IT IS ON TOP OF THE
* STACK. IF THE STRING IS DELETED, SET THE ZERO FLAG
B675  9C 0D             LB675    CMPX  LASTPT              ; *COMPARE TO LAST USED DESCRIPTOR ADDRESS
B677  26 07                      BNE   LB680               ; *ON THE STRING STACK, RETURN IF DESCRIPTOR
* *ADDRESS NOT ON THE STRING STACK
B679  9F 0B                      STX   TEMPPT              ; SAVE LAST USED DESCRIPTOR AS NEXT AVAILABLE
B67B  30 1B                      LEAX  -5,X                ; * MOVE LAST USED DESCRIPTOR BACK 5 BYTES
B67D  9F 0D                      STX   LASTPT              ; * AND SAVE AS THE LAST USED DESCRIPTOR ADDR
B67F  4F                         CLRA                      ; SET ZERO FLAG
B680  39                LB680    RTS

* LEN
B681  8D 03             LEN      BSR   LB686               ; POINT X TO PROPER STRING AND GET LENGTH
B683  7E B4 F3          LB683    JMP   LB4F3               ; CONVERT ACCB TO FP NUMBER IN FPA0
* POINT X TO STRING ADDRESS LOAD LENGTH INTO
* ACCB. ENTER WITH THE STRING DESCRIPTOR IN
* BOTTOM TWO BYTES OF FPA0
B686  8D CC             LB686    BSR   LB654               ; GET LENGTH AND ADDRESS OF STRING
B688  0F 06                      CLR   VALTYP              ; SET VARIABLE TYPE TO NUMERIC
B68A  5D                         TSTB                      ; SET FLAGS ACCORDING TO LENGTH
B68B  39                         RTS

* CHR$
B68C  BD B7 0E          CHR      JSR   >LB70E              ; CONVERT FPA0 TO AN INTEGER IN ACCD
B68F  C6 01             LB68F    LDB   #1                  ; * RESERVE ONE BYTE IN
B691  BD B5 6D                   JSR   LB56D               ; * THE STRING SPACE
B694  96 53                      LDA   FPA0+3              ; GET ASCII STRING VALUE
B696  BD B5 11                   JSR   LB511               ; SAVE RESERVED STRING DESCRIPTOR IN TEMP DESCRIPTOR
B699  A7 84                      STA   ,X                  ; SAVE THE STRING (IT'S ONLY ONE BYTE)
B69B  32 62             LB69B    LEAS  2,X                 ; PURGE THE RETURN ADDRESS OFF OF THE STACK
B69D  7E B5 4C          LB69D    JMP   LB54C               ; PUT TEMP DESCRIPTOR DATA ONTO STRING STACK
