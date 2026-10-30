; Disk Extended Color BASIC 1.1 -- $C893-$CA47
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "DECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 10bdc5aa2d7d7f205f67b47b19003a4bd89defd1). See ../README.md for line format.
; Named entry points here: DVEC2=$C893, DVEC11=$C8A9, DVEC20=$C8B0, DVEC14=$C90C, SAVE=$C9E0, MERGE=$CA39, DVEC18=$CA3E

* SET PRINT PARAMETERS RAM HOOK
C893  0D 6F             DVEC2    TST   DEVNUM              ; *CHECK DEVICE NUMBER AND
C895  2F 18                      BLE   LC8AF               ; *RETURN IF NOT DISK FILE
C897  32 62                      LEAS  $02,S               ; PURGE RETURN ADDRESS OFF OF THE STACK
C899  34 16                      PSHS  X,B,A               ; SAVE REGISTERS
C89B  0F 6E                      CLR   PRTDEV              ; SET PRINT DEVICE NUMBER TO NON-CASSETTE
C89D  BD C7 44                   JSR   LC744               ; POINT X TO FCB
C8A0  E6 06                      LDB   FCBPOS,X            ; GET PRINT POSITION
C8A2  4F                         CLRA                      ; PRINT WIDTH (256)
C8A3  8E 10 00                   LDX   #$1000              ; TAB FIELD WIDTH AND TAB ZONE
C8A6  7E A3 7C                   JMP   LA37C               ; SAVE THE PRINT PARAMETERS

* BREAK CHECK RAM HOOK
C8A9  0D 6F             DVEC11   TST   DEVNUM              ; * CHECK DEVICE NUMBER AND RETURN
C8AB  2F 02                      BLE   LC8AF               ; * IF NOT A DISK FILE
C8AD  32 62                      LEAS  $02,S               ; = PURGE RETURN ADDRESS OFF OF THE STACK - DON'T
C8AF  39                LC8AF    RTS                       ; = DO A BREAK CHECK IF DISK FILE

* COMMAND INTERPRETATION RAM HOOK
C8B0  32 62             DVEC20   LEAS  $02,S               ; PURGE RETURN ADDRESS OFF OF THE STACK
C8B2  1C AF             LC8B2    ANDCC #$AF                ; ENABLE IRQ & FIRQ
C8B4  7F FF 02                   CLR   PIA0+2              ; STROBE ALL KEYS (COLUMN STROBE)
C8B7  B6 FF 00                   LDA   PIA0                ; READ KEYBOARD ROWS
C8BA  43                         COMA                      ; INVERT KEYBOARD ROW DATA
C8BB  84 7F                      ANDA  #$7F                ; MASK OFF JOYSTICK INPUT BIT
C8BD  27 03                      BEQ   LC8C2               ; BRANCH IF NO KEY DOWN
C8BF  BD AD EB                   JSR   LADEB               ; GO DO A BREAK CHECK IF A KEY IS DOWN
C8C2  9E A6             LC8C2    LDX   CHARAD              ; GET INPUT POINTER INTO X
C8C4  9F 2F                      STX   TINPTR              ; TEMP SAVE IT
C8C6  A6 80                      LDA   ,X+                 ; SEARCH FOR THE END OF CURRENT LINE
C8C8  27 07                      BEQ   LC8D1               ; BRANCH IF END OF LINE
C8CA  81 3A                      CMPA  #':'                ; CHECK FOR END OF SUB LINE, TOO
C8CC  27 25                      BEQ   LC8F3               ; BRANCH IF END OF SUB LINE
C8CE  7E B2 77                   JMP   LB277               ; 'SYNTAX' ERROR IF NOT END OF LINE
C8D1  A6 81             LC8D1    LDA   ,X++                ; *GET MS BYTE OF ADDRESS OF NEXT BASIC LINE
C8D3  97 00                      STA   ENDFLAG             ; *AND SAVE IT IN CURLIN
C8D5  26 03                      BNE   LC8DA               ; BRANCH IF NOT END OF PROGRAM
C8D7  7E AE 15                   JMP   LAE15               ; GO 'STOP' THE SYSTEM
C8DA  EC 80             LC8DA    LDD   ,X+                 ; *GET LINE NUMBER OF THIS LINE AND
C8DC  DD 68                      STD   CURLIN              ; *SAVE IT IN CURLIN
C8DE  9F A6                      STX   CHARAD              ; RESET BASIC'S INPUT POINTER
C8E0  96 AF                      LDA   TRCFLG              ; * CHECK THE TRACE FLAG AND
C8E2  27 0F                      BEQ   LC8F3               ; * BRANCH IF TRACE OFF
C8E4  86 5B                      LDA   #'<'                ; < LEFT DELIMITER OF TRON
C8E6  BD A2 82                   JSR   LA282               ; SEND CHARACTER TO CONSOLE OUT
C8E9  96 68                      LDA   CURLIN              ; GET NUMBER OF CURRENT LINE NUMBER
C8EB  BD BD CC                   JSR   LBDCC               ; CONVERT ACCD TO DECIMAL & PRINT IT ON SCREEN
C8EE  86 5D                      LDA   #'>'                ; > RIGHT DELIMITER OF TRON
C8F0  BD A2 82                   JSR   LA282               ; SEND A CHARACTER TO CONSOLE OUT
C8F3  9D 9F             LC8F3    JSR   GETNCH              ; GET NEXT CHARACTER FROM BASIC
C8F5  1F A9                      TFR   CC,B                ; SAVE STATUS REGISTER IN ACCB
C8F7  81 98                      CMPA  #$98                ; CSAVE TOKEN?
C8F9  26 03                      BNE   LC8FE               ; NO
C8FB  7E 83 16                   JMP   L8316               ; GO CHECK FOR CSAVEM
C8FE  81 97             LC8FE    CMPA  #$97                ; CLOAD TOKEN?
C900  26 03                      BNE   LC905               ; NO
C902  7E 83 11                   JMP   L8311               ; JUMP TO EXBAS' CLOAD ROUTINE
C905  1F 9A             LC905    TFR   B,CC                ; RESTORE STATUS REGISTER
C907  BD AD C6                   JSR   LADC6               ; LOOP THROUGH BASIC'S MAIN INTERPRETATION LOOP
C90A  20 A6                      BRA   LC8B2

* EOF RAM HOOK
C90C  32 62             DVEC14   LEAS  $02,S               ; PURGE RETURN ADDRESS OFF OF THE STACK
C90E  96 6F                      LDA   DEVNUM              ; * GET DEVICE NUMBER AND SAVE
C910  34 02                      PSHS  A                   ; * IT ON THE STACK
C912  BD A5 AE                   JSR   LA5AE               ; STRIP DEVICE NUMBER OFF OF INPUT LINE
C915  BD A3 ED                   JSR   LA3ED               ; VERIFY THAT THE FILE TYPE WAS 'INPUT'
C918  0D 6F                      TST   DEVNUM              ; * CHECK DEVICE NUMBER AND
C91A  10 2F DC BC                LBLE  LA5DA               ; * BRANCH BACK TO  BASIC'S EOF IF NOT DISK FILE
C91E  BD C7 44                   JSR   LC744               ; POINT X TO FCB
C921  E6 00                      LDB   FCBTYP,X            ; GET FILE TYPE
C923  C1 40                      CMPB  #RANFIL             ; RANDOM FILE?
C925  10 27 DC ED                LBEQ  LA616               ; 'FM' BAD FILE MODE ERROR IF RANDOM
C929  5F                         CLRB                      ; FILE NOT EMPTY FLAG - SET TO NOT EMPTY
C92A  A6 88 10                   LDA   FCBCFL,X            ; *CHECK THE CACHE FLAG - BRANCH IF
C92D  26 03                      BNE   LC932               ; *THERE IS A CHARACTER WHICH HAS BEEN CACHED
C92F  E6 88 17                   LDB   FCBDFL,X            ; GET SEQUENTIAL INPUT FILE STATUS
C932  7E A5 E4          LC932    JMP   LA5E4               ; LINK BACK TO BASIC'S EOF STATEMENT

* GET FILENAME/EXTENSION: DRIVE NUMBER FROM BASIC
C935  8E C2 A9          LC935    LDX   #DEFEXT             ; POINT TO '   ' BLANK (DEFAULT) EXTENSION
C938  6F E2                      CLR   ,-S                 ; CLEAR A BYTE ON STACK FOR USE AS A DRIVES FLAG
C93A  B6 09 5A                   LDA   DEFDRV              ; * GET DEFAULT DISK NUMBER
C93D  97 EB                      STA   DCDRV               ; * STORE IN DSKCON PARAMETER
C93F  CE 09 4C                   LDU   #DNAMBF             ; DISK FILENAME BUFFER
C942  CC 20 08                   LDD   #$2008              ; STORE 8 BLANKS IN RAM (DEFAULT FILE NAME)
C945  A7 C0             LC945    STA   ,U+                 ; STORE A BLANK IN FILE NAME
C947  5A                         DECB                      ; DECREMENT COUNTER
C948  26 FB                      BNE   LC945               ; BRANCH IF NOT DONE
C94A  C6 03                      LDB   #$03                ; 3 BYTES IN EXTENSION
C94C  BD A5 9A                   JSR   LA59A               ; MOVE B BYTES FROM (X) TO (U)
C94F  BD 87 48                   JSR   L8748               ; EVALUATE A STRING EXPRESSION
C952  33 84                      LEAU  ,X                  ; POINT U TO START OF STRING
C954  C1 02                      CMPB  #$02                ; * CHECK LENGTH OF STRING AND
C956  25 12                      BLO   LC96A               ; * BRANCH IF < 2
C958  A6 41                      LDA   $01,U               ; = GET 2ND CHARACTER IN STRING AND
C95A  81 3A                      CMPA  #':'                ; = CHECK FOR COLON
C95C  26 0C                      BNE   LC96A               ; BRANCH IF NO DRIVE NUMBER
C95E  A6 C4                      LDA   ,U                  ; * GET 1ST CHARACTER
C960  81 30                      CMPA  #'0'                ; * IN STRING AND
C962  25 06                      BLO   LC96A               ; * CHECK TO SEE
C964  81 33                      CMPA  #'3'                ; * IF IT IS IN
C966  22 02                      BHI   LC96A               ; * THE RANGE 0-3
C968  8D 33                      BSR   LC99D               ; GET DRIVE NUMBER
C96A  8E 09 4C          LC96A    LDX   #DNAMBF             ; POINT X TO FILE NAME BUFFER
C96D  5C                         INCB                      ; COMPENSATE FOR DECB BELOW
C96E  5A                LC96E    DECB                      ; DECREMENT STRING LENGTH
C96F  26 0C                      BNE   LC97D               ; BRANCH IF MORE CHARACTERS IN STRING
C971  32 61                      LEAS  $01,S               ; CLEAN UP STACK - REMOVE DRIVE FLAG
C973  8C 09 4C          LC973    CMPX  #DNAMBF             ; POINTER STILL AT START OF BUFFER?
C976  26 67                      BNE   LC9DF               ; RETURN IF NOT
C978  C6 3E             LC978    LDB   #2*31               ; 'BAD FILENAME' ERROR IF NULL FILENAME
C97A  7E AC 46                   JMP   LAC46               ; ERROR HANDLER
C97D  A6 C0             LC97D    LDA   ,U+                 ; GET A CHARACTER FROM STRING
C97F  81 2E                      CMPA  #'.'                ; LOOK FOR PERIOD?
C981  27 2D                      BEQ   LC9B0               ; YES
C983  81 2F                      CMPA  #'/'                ; SLASH?
C985  27 29                      BEQ   LC9B0               ; YES
C987  81 3A                      CMPA  #':'                ; COLON?
C989  27 09                      BEQ   LC994               ; YES
C98B  8C 09 54                   CMPX  #DEXTBF             ; COMPARE POINTER TO END OF FILENAME BUFFER
C98E  27 E8                      BEQ   LC978               ; 'BAD FILENAME' ERROR - FILENAME TOO LONG
C990  8D 3E                      BSR   LC9D0               ; PUT A CHARACTER IN FILENAME
C992  20 DA                      BRA   LC96E               ; GET ANOTHER CHARACTER FROM STRING
C994  8D DD             LC994    BSR   LC973               ; 'BAD FILENAME' ERROR IF NO FILENAME YET
C996  8D 05                      BSR   LC99D               ; GET DRIVE NUMBER
C998  5D                         TSTB                      ; * CHECK LENGTH OF STRING
C999  26 DD                      BNE   LC978               ; * ''BAD FILENAME' ERROR IF MORE CHARACTERS LEFT
C99B  35 82             LC99B    PULS  A,PC                ; REMOVE DRIVES FLAG FROM STACK AND RETURN

* GRAB DRIVE NUMBER
C99D  63 62             LC99D    COM   $02,S               ; TOGGLE DRIVE FLAG
C99F  27 D7                      BEQ   LC978               ; 'BAD FILENAME' ERROR IF DRIVE NUMBER DEFINED TWICE
C9A1  A6 C1                      LDA   ,U++                ; ASCII VALUE OF DRIVE NUMBER TO ACCA
C9A3  C0 02                      SUBB  #$02                ; DECREMENT STRING LENGTH BY 2 FOR DRIVE (:X)
C9A5  80 30                      SUBA  #'0'                ; SUBTRACT ASCII BIAS
C9A7  25 CF                      BLO   LC978               ; DRIVE NUMBER TOO LOW - 'BAD FILENAME' ERROR
C9A9  81 03                      CMPA  #$03                ; MAX OF 4 DRIVES
C9AB  22 CB                      BHI   LC978               ; DRIVE NUMBER TOO HIGH - 'BAD FILENAME' ERROR
C9AD  97 EB                      STA   DCDRV               ; STORE IN DSKCON DRIVE NUMBER
C9AF  39                         RTS

* GRAB EXTENSION
C9B0  8D C1             LC9B0    BSR   LC973               ; 'BAD FILENAME' ERROR IF NO FILENAME YET
C9B2  8E 09 57                   LDX   #DFLTYP             ; POINT X TO END OF EXTENSION BUFFER
C9B5  86 20                      LDA   #SPACE              ; BLANK
C9B7  A7 82             LC9B7    STA   ,-X                 ; *
C9B9  8C 09 54                   CMPX  #DEXTBF             ; * FILL EXTENSION WITH
C9BC  26 F9                      BNE   LC9B7               ; * BLANKS (DEFAULT)
C9BE  5A                LC9BE    DECB                      ; DECREMENT STRING COUNTER
C9BF  27 DA                      BEQ   LC99B               ; RETURN IF ZERO
C9C1  A6 C0                      LDA   ,U+                 ; GET A CHARACTER FROM STRING
C9C3  81 3A                      CMPA  #':'                ; *CHECK FOR DRIVE SEPARATOR
C9C5  27 CD                      BEQ   LC994               ; *
C9C7  8C 09 57                   CMPX  #DFLTYP             ; =CHECK FOR END OF ESTENSION RAM BUFFER &
C9CA  27 AC                      BEQ   LC978               ; = 'BAD FILENAME' ERROR IF EXTENSION TOO LONG
C9CC  8D 02                      BSR   LC9D0               ; PUT A CHARACTER IN EXTENSION BUFFER
C9CE  20 EE                      BRA   LC9BE               ; GET ANOTHER EXTENSION CHARACTER

* INSERT CHARACTER INTO FILENAME OR EXTENSION
C9D0  A7 80             LC9D0    STA   ,X+                 ; STORE CHARACTER IN FILENAME BUFFER
C9D2  27 A4                      BEQ   LC978               ; 'BAD FILENAME' ERROR; ZEROES ARE ILLEGAL
C9D4  81 2E                      CMPA  #'.'                ; PERIOD?
C9D6  27 A0                      BEQ   LC978               ; 'BAD FILENAME' ERROR IF PERIOD
C9D8  81 2F                      CMPA  #'/'                ; SLASH?
C9DA  27 9C                      BEQ   LC978               ; 'BAD FILENAME' ERROR IF SLASH
C9DC  4C                         INCA                      ; CHECK FOR $FF
C9DD  27 99                      BEQ   LC978               ; 'BAD FILENAME' ERROR IF $FF
C9DF  39                LC9DF    RTS

* SAVE COMMAND
C9E0  81 4D             SAVE     CMPA  #'M'                ; *
C9E2  10 27 05 82                LBEQ  LCF68               ; *BRANCH IF SAVEM
C9E6  8D 4B                      BSR   LCA33               ; GO GET FILENAME, ETC. FROM BASIC
C9E8  9E 8A                      LDX   ZERO                ; ZERO OUT X REG
C9EA  BF 09 57                   STX   DFLTYP              ; SET FILE TYPE AND ASCII FLAG TO ZERO
C9ED  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER FROM BASIC
C9EF  27 21                      BEQ   LCA12               ; BRANCH IF END OF LINE
C9F1  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
C9F4  C6 41                      LDB   #'A'                ; *ASCII FILE?
C9F6  BD B2 6F                   JSR   LB26F               ; *SYNTAX CHECK ON CONTENTS OF ACCB
C9F9  26 E4                      BNE   LC9DF               ; RETURN IF NO MORE CHARACTERS ON LINE
C9FB  73 09 58                   COM   DASCFL              ; SET CRUNCHED/ASCII FLAG TO ASCII
C9FE  8D 04                      BSR   LCA04               ; OPEN A SEQUENTIAL FILE FOR OUTPUT
CA00  4F                         CLRA                      ; SET ZERO FLAG - CAUSE ENTIRE FILE TO BE LISTED
CA01  7E B7 64                   JMP   LIST                ; 'LIST' THE FILE TO CONSOLE OUT

* OPEN A SEQUENTIAL FILE FOR INPUT/OUTPUT - USE THE SYSTEM
* FCB LOCATED AT THE TOP OF FCBS
CA04  86 4F             LCA04    LDA   #'O'                ; OUTPUT FILE TYPE
CA06  8C                LCA06    CMPX  #$8649              ; SKIP TWO BYTES
CA07  86 49             LCA07    LDA   #'I'                ; INPUT FILE TYPE
CA09  F6 09 5B                   LDB   FCBACT              ; GET NUMBER OF RESERVED FILES CURRENTLY RESERVED
CA0C  5C                         INCB                      ; ADD ONE - USE ONE ABOVE HIGHEST RESERVED FCB
CA0D  D7 6F                      STB   DEVNUM              ; SAVE IT IN DEVICE NUMBER
CA0F  7E C4 8D                   JMP   LC48D               ; OPEN A FILE & INITIALIZE FCB
* SAVE A CRUNCHED FILE - A PREAMBLE OF THREE BYTES WILL PRECEED CRUNCHED
* FILES: BYTE 1 = $FF, 2,3 = LENGTH OF BASIC PROGRAM
CA12  8D F0             LCA12    BSR   LCA04               ; OPEN A SEQUENTIAL FILE FOR OUTPUT
CA14  86 FF                      LDA   #$FF                ; BASIC FILE FLAG
CA16  BD CC 24                   JSR   LCC24               ; CONSOLE OUT
CA19  DC 1B                      LDD   VARTAB              ; LOAD ACCD WITH START OF VARIABLES
CA1B  93 19                      SUBD  TXTTAB              ; SUBTRACT START OF BASIC
CA1D  BD CC 24                   JSR   LCC24               ; CONSOLE OUT FILE LENGTH MS BYTE
CA20  1F 98                      TFR   B,A                 ; PULL LS BYTE INTO ACCA
CA22  BD CC 24                   JSR   LCC24               ; CONSOLE OUT FILE LENGTH LS BYTE
CA25  9E 19                      LDX   TXTTAB              ; POINT X TO START OF BASIC
CA27  A6 80             LCA27    LDA   ,X+                 ; GET BYTE FROM BASIC
CA29  BD CC 24                   JSR   LCC24               ; SEND TO CONSOLE OUT
CA2C  9C 1B                      CMPX  VARTAB              ; COMPARE TO END OF BASIC
CA2E  26 F7                      BNE   LCA27               ; KEEP GOING IF NOT AT END
CA30  7E A4 2D                   JMP   LA42D               ; CLOSE FILE
CA33  8E C2 A6                   LDX   #BASEXT             ; POINT TO 'BAS' EXTENSION (DEFAULT)
CA36  7E C9 38                   JMP   LC938               ; GET FILENAME.EXT FROM BASIC

* MERGE COMMAND
CA39  4F                MERGE    CLRA                      ; RUN FLAG (0 = DON'T RUN)
CA3A  C6 FF                      LDB   #$FF                ; MERGE FLAG ($FF = MERGE)
CA3C  20 12                      BRA   LCA50               ; GO LOAD THE FILE

* RUN RAM VECTOR
CA3E  81 22             DVEC18   CMPA  #'"'                ; CHECK FOR FILENAME DELIMITER (DOUBLE QUOTE)
CA40  10 26 B8 58                LBNE  XVEC18              ; NONE - JUMP TO EXBAS RUN RAM HOOK
CA44  86 02                      LDA   #$02                ; RUN FLAG - DON'T CLOSE ALL FILES BEFORE RUN
CA46  20 07                      BRA   LCA4F               ; LOAD THE FILE
