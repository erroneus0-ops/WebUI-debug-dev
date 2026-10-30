; Disk Extended Color BASIC 1.0 -- $C860-$CA4A
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.0"
; Object bytes verified against genuine ROM image (SHA-1 04115be3f97952b9d9310b52f806d04f80b40d03). See ../README.md for line format.
; Named entry points here: DVEC14=$C860, SAVE=$C932, MERGE=$C98B, DVEC18=$C990, LOAD=$C99A, DVEC13=$CA36, DVEC7=$CA3B

* EOF RAM HOOK
C860  32 62             DVEC14   LEAS  $02,S               ; PURGE RETURN ADDRESS OFF OF THE STACK
C862  96 6F                      LDA   DEVNUM              ; * GET DEVICE NUMBER AND SAVE
C864  34 02                      PSHS  A                   ; * IT ON THE STACK
C866  BD A5 AE                   JSR   LA5AE               ; STRIP DEVICE NUMBER OFF OF INPUT LINE
C869  BD A3 ED                   JSR   LA3ED               ; VERIFY THAT THE FILE TYPE WAS 'INPUT'
C86C  0D 6F                      TST   DEVNUM              ; * CHECK DEVICE NUMBER AND
C86E  10 2F DD 68                LBLE  LA5DA               ; * BRANCH BACK TO  BASIC'S EOF IF NOT DISK FILE
C872  BD C7 14                   JSR   LC714               ; POINT X TO FCB
C875  E6 00                      LDB   FCBTYP,X            ; GET FILE TYPE
C877  C1 40                      CMPB  #RANFIL             ; RANDOM FILE?
C879  27 9A                      BEQ   LC815               ; 'BAD FILE MODE' ERROR IF RANDOM
C87B  5F                         CLRB                      ; FILE NOT EMPTY FLAG - SET TO NOT EMPTY
C87C  A6 88 10                   LDA   FCBCFL,X            ; *CHECK THE CACHE FLAG - BRANCH IF
C87F  26 03                      BNE   LC884               ; *THERE IS A CHARACTER WHICH HAS BEEN CACHED
C881  E6 88 17                   LDB   FCBDFL,X            ; GET SEQUENTIAL INPUT FILE STATUS
C884  7E A5 E4          LC884    JMP   LA5E4               ; LINK BACK TO BASIC'S EOF STATEMENT

* GET FILENAME/EXTENSION: DRIVE NUMBER FROM BASIC
C887  8E C2 91          LC887    LDX   #DEFEXT             ; POINT TO '   ' BLANK (DEFAULT) EXTENSION
C88A  6F E2             LC88A    CLR   ,-S                 ; CLEAR A BYTE ON STACK FOR USE AS A DRIVES FLAG
C88C  B6 09 5A                   LDA   DEFDRV              ; * GET DEFAULT DISK NUMBER
C88F  97 EB                      STA   DCDRV               ; * STORE IN DSKCON PARAMETER
C891  CE 09 4C                   LDU   #DNAMBF             ; DISK FILENAME BUFFER
C894  CC 20 08                   LDD   #$2008              ; STORE 8 BLANKS IN RAM (DEFAULT FILE NAME)
C897  A7 C0             LC897    STA   ,U+                 ; STORE A BLANK IN FILE NAME
C899  5A                         DECB                      ; DECREMENT COUNTER
C89A  26 FB                      BNE   LC897               ; BRANCH IF NOT DONE
C89C  C6 03                      LDB   #$03                ; 3 BYTES IN EXTENSION
C89E  BD A5 9A                   JSR   LA59A               ; MOVE B BYTES FROM (X) TO (U)
C8A1  BD 87 48                   JSR   L8748               ; EVALUATE A STRING EXPRESSION
C8A4  33 84                      LEAU  ,X                  ; POINT U TO START OF STRING
C8A6  C1 02                      CMPB  #$02                ; * CHECK LENGTH OF STRING AND
C8A8  25 12                      BLO   LC8BC               ; * BRANCH IF < 2
C8AA  A6 41                      LDA   $01,U               ; = GET 2ND CHARACTER IN STRING AND
C8AC  81 3A                      CMPA  #':'                ; = CHECK FOR COLON
C8AE  26 0C                      BNE   LC8BC               ; BRANCH IF NO DRIVE NUMBER
C8B0  A6 C4                      LDA   ,U                  ; * GET 1ST CHARACTER
C8B2  81 30                      CMPA  #'0'                ; * IN STRING AND
C8B4  25 06                      BLO   LC8BC               ; * CHECK TO SEE
C8B6  81 33                      CMPA  #'3'                ; * IF IT IS IN
C8B8  22 02                      BHI   LC8BC               ; * THE RANGE 0-3
C8BA  8D 33                      BSR   LC8EF               ; GET DRIVE NUMBER
C8BC  8E 09 4C          LC8BC    LDX   #DNAMBF             ; POINT X TO FILE NAME BUFFER
C8BF  5C                         INCB                      ; COMPENSATE FOR DECB BELOW
C8C0  5A                LC8C0    DECB                      ; DECREMENT STRING LENGTH
C8C1  26 0C                      BNE   LC8CF               ; BRANCH IF MORE CHARACTERS IN STRING
C8C3  32 61                      LEAS  $01,S               ; CLEAN UP STACK - REMOVE DRIVE FLAG
C8C5  8C 09 4C                   CMPX  #DNAMBF             ; POINTER STILL AT START OF BUFFER?
C8C8  26 67                      BNE   LC931               ; RETURN IF NOT
C8CA  C6 3E             LC8CA    LDB   #2*31               ; 'BAD FILENAME' ERROR IF NULL FILENAME
C8CC  7E AC 46                   JMP   LAC46               ; ERROR HANDLER
C8CF  A6 C0             LC8CF    LDA   ,U+                 ; GET A CHARACTER FROM STRING
C8D1  81 2E                      CMPA  #'.'                ; LOOK FOR PERIOD?
C8D3  27 2D                      BEQ   LC902               ; YES
C8D5  81 2F                      CMPA  #'/'                ; SLASH?
C8D7  27 29                      BEQ   LC902               ; YES
C8D9  81 3A                      CMPA  #':'                ; COLON?
C8DB  27 09                      BEQ   LC8E6               ; YES
C8DD  8C 09 54                   CMPX  #DEXTBF             ; COMPARE POINTER TO END OF FILENAME BUFFER
C8E0  27 E8                      BEQ   LC8CA               ; 'BAD FILENAME' ERROR - FILENAME TOO LONG
C8E2  8D 3E                      BSR   LC922               ; PUT A CHARACTER IN FILENAME
C8E4  20 DA                      BRA   LC8C0               ; GET ANOTHER CHARACTER FROM STRING
C8E6  8D DD             LC8E6    BSR   LC8C5               ; 'BAD FILENAME' ERROR IF NO FILENAME YET
C8E8  8D 05                      BSR   LC8EF               ; GET DRIVE NUMBER
C8EA  5D                         TSTB                      ; * CHECK LENGTH OF STRING
C8EB  26 DD                      BNE   LC8CA               ; * 'BAD FILENAME' ERROR IF MORE CHARACTERS LEFT
C8ED  35 82             LC8ED    PULS  A,PC                ; REMOVE DRIVES FLAG FROM STACK AND RETURN

* GRAB DRIVE NUMBER
C8EF  63 62             LC8EF    COM   $02,S               ; TOGGLE DRIVE FLAG
C8F1  27 D7                      BEQ   LC8CA               ; 'BAD FILENAME' ERROR IF DRIVE NUMBER DEFINED TWICE
C8F3  A6 C1                      LDA   ,U++                ; ASCII VALUE OF DRIVE NUMBER TO ACCA
C8F5  C0 02                      SUBB  #$02                ; DECREMENT STRING LENGTH BY 2 FOR DRIVE (:X)
C8F7  80 30                      SUBA  #'0'                ; SUBTRACT ASCII BIAS
C8F9  25 CF                      BLO   LC8CA               ; DRIVE NUMBER TOO LOW - 'BAD FILENAME' ERROR
C8FB  81 03                      CMPA  #$03                ; MAX OF 4 DRIVES
C8FD  22 CB                      BHI   LC8CA               ; DRIVE NUMBER TOO HIGH - 'BAD FILENAME' ERROR
C8FF  97 EB                      STA   DCDRV               ; STORE IN DSKCON DRIVE NUMBER
C901  39                         RTS

* GRAB EXTENSION
C902  8D C1             LC902    BSR   LC8C5               ; 'BAD FILENAME' ERROR IF NO FILENAME YET
C904  8E 09 57                   LDX   #DNAMBF+11          ; POINT X TO END OF EXTENSION BUFFER
C907  86 20                      LDA   #SPACE              ; BLANK
C909  A7 82             LC909    STA   ,-X                 ; *
C90B  8C 09 54                   CMPX  #DEXTBF             ; * FILL EXTENSION WITH
C90E  26 F9                      BNE   LC909               ; * BLANKS (DEFAULT)
C910  5A                LC910    DECB                      ; DECREMENT STRING COUNTER
C911  27 DA                      BEQ   LC8ED               ; RETURN IF ZERO
C913  A6 C0                      LDA   ,U+                 ; GET A CHARACTER FROM STRING
C915  81 3A                      CMPA  #':'                ; *CHECK FOR DRIVE SEPARATOR
C917  27 CD                      BEQ   LC8E6               ; *
C919  8C 09 57                   CMPX  #DNAMBF+11          ; =CHECK FOR END OF ESTENSION RAM BUFFER &
C91C  27 AC                      BEQ   LC8CA               ; ='BAD FILENAME' ERROR IF EXTENSION TOO LONG
C91E  8D 02                      BSR   LC922               ; PUT A CHARACTER IN EXTENSION BUFFER
C920  20 EE                      BRA   LC910               ; GET ANOTHER EXTENSION CHARACTER

* INSERT CHARACTER INTO FILENAME OR EXTENSION
C922  A7 80             LC922    STA   ,X+                 ; STORE CHARACTER IN FILENAME BUFFER
C924  27 A4                      BEQ   LC8CA               ; 'BAD FILENAME' ERROR; ZEROES ARE ILLEGAL
C926  81 2E                      CMPA  #'.'                ; PERIOD?
C928  27 A0                      BEQ   LC8CA               ; 'BAD FILENAME' ERROR IF PERIOD
C92A  81 2F                      CMPA  #'/'                ; SLASH?
C92C  27 9C                      BEQ   LC8CA               ; 'BAD FILENAME' ERROR IF SLASH
C92E  4C                         INCA                      ; CHECK FOR $FF
C92F  27 99                      BEQ   LC8CA               ; 'BAD FILENAME' ERROR IF $FF
C931  39                LC931    RTS

* SAVE COMMAND
C932  81 4D             SAVE     CMPA  #'M'                ; *
C934  10 27 05 54                LBEQ  LCE8C               ; *BRANCH IF SAVEM
C938  8D 4B                      BSR   LC985               ; GO GET FILENAME, ETC. FROM BASIC
C93A  9E 8A                      LDX   ZERO                ; ZERO OUT X REG
C93C  BF 09 57                   STX   DFLTYP              ; SET FILE TYPE AND ASCII FLAG TO ZERO
C93F  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER FROM BASIC
C941  27 21                      BEQ   LC964               ; BRANCH IF END OF LINE
C943  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
C946  C6 41                      LDB   #'A'                ; *ASCII FILE?
C948  BD B2 6F                   JSR   LB26F               ; *SYNTAX CHECK ON CONTENTS OF ACCB
C94B  26 E4                      BNE   LC931               ; RETURN IF NO MORE CHARACTERS ON LINE
C94D  73 09 58                   COM   DASCFL              ; SET CRUNCHED/ASCII FLAG TO ASCII
C950  8D 04                      BSR   LC956               ; OPEN A SEQUENTIAL FILE FOR OUTPUT
C952  4F                         CLRA                      ; SET ZERO FLAG - CAUSE ENTIRE FILE TO BE LISTED
C953  7E B7 64                   JMP   LIST                ; 'LIST' THE FILE TO CONSOLE OUT

* OPEN A SEQUENTIAL FILE FOR INPUT/OUTPUT - USE THE SYSTEM
* FCB LOCATED AT THE TOP OF FCBS
C956  86 4F             LC956    LDA   #'O'                ; OUTPUT FILE TYPE
C958  8C 86 49          LC958    CMPX  #$8649              ; SKIP TWO BYTES
C959  86 49             LC959    LDA   #'I'                ; INPUT FILE TYPE
C95B  F6 09 5B                   LDB   FCBACT              ; GET NUMBER OF RESERVED FILES CURRENTLY RESERVED
C95E  5C                         INCB                      ; ADD ONE - USE ONE ABOVE HIGHEST RESERVED FCB
C95F  D7 6F                      STB   DEVNUM              ; SAVE IT IN DEVICE NUMBER
C961  7E C4 68                   JMP   LC468               ; OPEN A FILE & INITIALIZE FCB
* SAVE A CRUNCHED FILE - A PREAMBLE OF THREE BYTES WILL PRECEED CRUNCHED
* FILES: BYTE 1 = $FF, 2,3 = LENGTH OF BASIC PROGRAM
C964  8D F0             LC964    BSR   LC956               ; OPEN A SEQUENTIAL FILE FOR OUTPUT
C966  86 FF                      LDA   #$FF                ; BASIC FILE FLAG
C968  BD CB 52                   JSR   LCB52               ; CONSOLE OUT
C96B  DC 1B                      LDD   VARTAB              ; LOAD ACCD WITH START OF VARIABLES
C96D  93 19                      SUBD  TXTTAB              ; SUBTRACT START OF BASIC
C96F  BD CB 52                   JSR   LCB52               ; CONSOLE OUT FILE LENGTH MS BYTE
C972  1F 98                      TFR   B,A                 ; PULL LS BYTE INTO ACCA
C974  BD CB 52                   JSR   LCB52               ; CONSOLE OUT FILE LENGTH LS BYTE
C977  9E 19                      LDX   TXTTAB              ; POINT X TO START OF BASIC
C979  A6 80             LC979    LDA   ,X+                 ; GET BYTE FROM BASIC
C97B  BD CB 52                   JSR   LCB52               ; SEND TO CONSOLE OUT
C97E  9C 1B                      CMPX  VARTAB              ; COMPARE TO END OF BASIC
C980  26 F7                      BNE   LC979               ; KEEP GOING IF NOT AT END
C982  7E A4 2D                   JMP   LA42D               ; CLOSE FILE
C985  8E C2 8E          LC985    LDX   #BASEXT             ; POINT TO 'BAS' EXTENSION (DEFAULT)
C988  7E C8 8A                   JMP   LC88A               ; GET FILENAME.EXT FROM BASIC

* MERGE COMMAND
C98B  4F                MERGE    CLRA                      ; RUN FLAG (0 = DON'T RUN)
C98C  C6 FF                      LDB   #$FF                ; MERGE FLAG ($FF = MERGE)
C98E  20 12                      BRA   LC9A2               ; GO LOAD THE FILE

* RUN RAM VECTOR
C990  81 22             DVEC18   CMPA  #'"'                ; CHECK FOR FILENAME DELIMITER (DOUBLE QUOTE)
C992  10 26 B9 06                LBNE  XVEC18              ; NONE - JUMP TO EXBAS RUN RAM HOOK
C996  86 02                      LDA   #$02                ; RUN FLAG - DON'T CLOSE ALL FILES BEFORE RUN
C998  20 07                      BRA   LC9A1               ; LOAD THE FILE

* LOAD COMMAND
C99A  81 4D             LOAD     CMPA  #'M'                ; *
C99C  10 27 05 45                LBEQ  LCEE5               ; *BRANCH IF LOADM
C9A0  4F                         CLRA                      ; RUN FLAG = ZERO (DON'T RUN)
C9A1  5F                LC9A1    CLRB                      ; CLEAR MERGE FLAG
C9A2  B7 09 59          LC9A2    STA   DRUNFL              ; RUN FLAG (0 = DON'T RUN, 2 = RUN)
C9A5  F7 09 5E                   STB   DMRGFL              ; MERGE FLAG (0 = NO MERGE, $FF = MERGE)
C9A8  8D DB                      BSR   LC985               ; GO GET FILENAME, ETC. FROM BASIC
C9AA  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHAR
C9AC  27 10                      BEQ   LC9BE               ; BRANCH IF END OF LINE
C9AE  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
C9B1  C6 52                      LDB   #'R'                ; *
C9B3  BD B2 6F                   JSR   LB26F               ; *IS NEXT CHAR 'R'? RUN AFTER LOAD
C9B6  BD A5 C7                   JSR   LA5C7               ; SYNTAX ERROR IF ANY MORE CHARS ON LINE
C9B9  86 03                      LDA   #$03                ; *SET FLAGS TO RUN AND CLOSE ALL FILES
C9BB  B7 09 59                   STA   DRUNFL              ; *BEFORE THE FILE IS RUN
C9BE  8D 99             LC9BE    BSR   LC959               ; GRAB FCB FOR INPUT FILE
C9C0  B6 09 58                   LDA   DASCFL              ; *CHECK ASCII FLAG AND BRANCH
C9C3  27 0B                      BEQ   LC9D0               ; *IF CRUNCHED BASIC FILE
C9C5  7D 09 5E                   TST   DMRGFL              ; IS THIS A MERGE?
C9C8  26 03                      BNE   LC9CD               ; BRANCH IF MERGE
C9CA  BD AD 19                   JSR   LAD19               ; DO A 'NEW' - ERASE VARIABLES, RESET VARIABLES
C9CD  7E AC 7C          LC9CD    JMP   LAC7C               ; GO TO BASIC'S MAIN LOOP, IT WILL LOAD PROGRAM

* LOAD IN A CRUNCHED BASIC FILE
C9D0  B6 09 57          LC9D0    LDA   DFLTYP              ; *CHECK FILE TYPE (MUST BE BASIC:0) & CHECK
C9D3  BA 09 5E                   ORA   DMRGFL              ; *MERGE FLAG (MUST BE NO MERGE: 0)
C9D6  10 26 DC 3C                LBNE  LA616               ; 'BAD FILE MODE' ERROR IF MERGE OR NON-BASIC
C9DA  BD AD 19                   JSR   LAD19               ; DO A 'NEW' - RESET POINTERS, ERASE VARIABLES
C9DD  73 09 5D                   COM   DLODFL              ; * SET THE LOAD FLAG TO $FF - THIS WILL CAUSE A NEW TO
* * OCCUR IF AN ERROR OCCURS WHILE THE PROGRAM IS BEING LOADED
C9E0  BD CC E2                   JSR   LCCE2               ; GET CHAR FROM BUFFER - SHOULD BE $FF
C9E3  BD CC E2                   JSR   LCCE2               ; GET ANOTHER - MS BYTE OF LENGTH
C9E6  34 02                      PSHS  A                   ; SAVE MS BYTE ON STACK
C9E8  BD CC E2                   JSR   LCCE2               ; LS BYTE OF LENGTH OF PROGRAM
C9EB  1F 89                      TFR   A,B                 ; PUT LS BYTE INTO ACCB
C9ED  35 02                      PULS  A                   ; NOW ACCD CONTAINS LENGTH OF PROGRAM
C9EF  D3 19                      ADDD  TXTTAB              ; ADD BEGINNING OF BASIC
C9F1  BD AC 37                   JSR   LAC37               ; SEE OF ENOUGH ROOM IN RAM FOR THIS FILE
C9F4  9E 19                      LDX   TXTTAB              ; GET START OF BASIC
C9F6  BD C5 97          LC9F6    JSR   LC597               ; READ A CHAR FROM CONSOLE IN
C9F9  D6 70                      LDB   CINBFL              ; BUFFER EMPTY?
C9FB  26 04                      BNE   LCA01               ; BRANCH IF SO
C9FD  A7 80                      STA   ,X+                 ; STORE CHAR
C9FF  20 F5                      BRA   LC9F6               ; GET ANOTHER CHARACTER

CA01  7F 09 5D          LCA01    CLR   DLODFL              ; CLEAR LOAD FLAG - LOAD WAS ERROR FREE
CA04  9F 1B                      STX   VARTAB              ; SAVE NEW START OF VARIABLES
* MAKE SURE LAST THREE BYTES LOADED WERE ZERO
CA06  C6 03                      LDB   #$03                ; CHECK THREE BYTES
CA08  A6 82             LCA08    LDA   ,-X                 ; CHECK A BYTE
CA0A  26 03                      BNE   LCA0F               ; BRANCH IF NON-ZERO
CA0C  5A                         DECB                      ; DECREMENT COUNTER
CA0D  26 F9                      BNE   LCA08               ; KEEP CHECKING IF NOT DONE
CA0F  9E 1B             LCA0F    LDX   VARTAB              ; GET START OF VARIABLES
CA11  9F 1B             LCA11    STX   VARTAB              ; SAVE START OF VARIABLES
CA13  6F 80                      CLR   ,X+                 ; CLEAR A BYTE
CA15  5A                         DECB                      ; DECREMRNT COUNTER
CA16  2A F9                      BPL   LCA11               ; KEEP CLEARING BYTES IF NOT DONE
CA18  BD A4 2D          LCA18    JSR   LA42D               ; CLOSE SELECTED FILE
CA1B  BD AD 21                   JSR   LAD21               ; DO PART OF NEW - ERASE VARIABLES, RESET INPUT PTR
CA1E  BD 82 9C                   JSR   XVEC18              ; INITIALIZE EXBAS GRAPHICS VARIABLES
CA21  BD AC EF                   JSR   LACEF               ; RELOCATE ALL THE BASIC NEXT LINE POINTERS
CA24  77 09 59                   ASR   DRUNFL              ; CHECK LSB OF RUN FLAG
CA27  25 03                      BLO   LCA2C               ; BRANCH IF DON'T CLOSE ALL FILES
CA29  BD A4 26                   JSR   LA426               ; CLOSE ALL FILES
CA2C  77 09 59          LCA2C    ASR   DRUNFL              ; TEST BIT 1 OF RUN FLAG
CA2F  10 25 E3 6B                LBCS  LAD9E               ; BRANCH TO COMM INTERPRETATION LOOP IF BIT 1 SET
CA33  7E AC 73                   JMP   LAC73               ; RETURN TO DIRECT MODE

CA36  0D 6F             DVEC13   TST   DEVNUM              ; * CHECK DEVICE NUMBER AND
CA38  2E DE                      BGT   LCA18               ; * TRY TO RUN FILE IF IT IS A DISK FILE
CA3A  39                         RTS

* CLOSE ALL FILE BUFFERS RAM VECTOR
CA3B  F6 09 5B          DVEC7    LDB   FCBACT              ; GET THE NUMBER OF RESERVED FILE BUFFERS
CA3E  5C                         INCB                      ; ADD ONE
CA3F  34 04             LCA3F    PSHS  B                   ; SAVE IT
CA41  D7 6F                      STB   DEVNUM              ; STORE IT IN DEVICE NUMBER
CA43  8D 0E                      BSR   LCA53               ; CLOSE FILE
CA45  35 04                      PULS  B                   ; GET BACK NUMBER OF FILE BUFFERS
CA47  5A                         DECB                      ; DECREMENT FILE BUFFER COUNTER
CA48  26 F5                      BNE   LCA3F               ; BRANCH IF ALL FILES NOT CLOSED
CA4A  39                LCA4A    RTS
