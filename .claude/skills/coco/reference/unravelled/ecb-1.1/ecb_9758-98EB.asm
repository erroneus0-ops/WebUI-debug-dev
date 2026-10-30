; Extended Color BASIC 1.1 -- $9758-$98EB
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: PUT=$9758

* PUT
9758  C6 01             PUT      LDB   #$01                ; 'PUT' FLAG
975A  D7 D8             L975A    STB   VD8                 ; SAVE GET/PUT FLAG
975C  BD 01 A0                   JSR   RVEC22              ; HOOK INTO RAM
975F  81 40                      CMPA  #'@'                ; CHECK FOR @ SIGN
9761  26 02                      BNE   L9765               ; NO @ SIGN
9763  9D 9F                      JSR   GETNCH              ; GO GET NEXT INPUT CHARACTER
9765  BD 93 8F          L9765    JSR   L938F               ; GO EVALUATE START AND END POINTS - STORE START AT
; (HORBEG,VERSEG), END AT (HOREND,VEREND)
9768  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
976B  BD 98 CC                   JSR   L98CC               ; GET POINTER TO ARRAY DESCRIPTOR
976E  1F 10                      TFR   X,D                 ; SAVE DESCRIPTOR + 2 IN ACCD
9770  EE 84                      LDU   ,X                  ; SAVE OFFSET TO NEXT ARRAY IN U
9772  33 5E                      LEAU  $-02,U              ; POINT U TO START OF DESCRIPTOR
9774  33 CB                      LEAU  D,U                 ; POINT U TO END OF ARRAY
9776  DF D1                      STU   VD1                 ; SAVE END OF DATA (END OF ARRAY)
9778  30 02                      LEAX  $02,X               ; POINT X TO NUMBER OF DIMENSIONS AND
977A  E6 84                      LDB   ,X                  ; GET NUMBER DIMENSIONS IN ACCB
977C  58                         ASLB                      ; TIMES 2 - 2 BYTES/DIMENSION
977D  3A                         ABX                       ; POINT X TO START OF ARRAY DATA
977E  9F CF                      STX   VCF                 ; SAVE START OF DATA (START OF ARRAY DATA)
9780  96 06                      LDA   VALTYP              ; CHECK VARIABLE TYPE
9782  26 CE                      BNE   L9752               ; 'FC' ERROR IF STRING VARIABLE
9784  0F D4                      CLR   VD4                 ; GET/PUT GRAPHIC/ACTION FLAG
9786  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHAR
9788  27 2D                      BEQ   L97B7               ; BRANCH IF END OF LINE
978A  03 D4                      COM   VD4                 ; TOGGLE GET/PUT GRAPHIC/ACTION FLAG
978C  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
978F  0D D8                      TST   VD8                 ; CHECK GET/PUT FLAG
9791  26 07                      BNE   L979A               ; BRANCH IF PUT
9793  C6 47                      LDB   #'G'                ; CHECK FOR FULL GRAPHIC OPTION
9795  BD B2 6F                   JSR   LB26F               ; DO A SYNTAX CHECK FOR A 'G'
9798  20 30                      BRA   L97CA               ; SKIP AROUND THE 'NO G' OPTION CODE
979A  C6 05             L979A    LDB   #$05                ; FIVE LEGAL TOKENS AT END OF PUT
979C  8E 98 39                   LDX   #L9839              ; POINT X TO LOOK UP TABLE
979F  EE 81             L979F    LDU   ,X++                ; GET 'CLEAR BIT' ACTION ROUTINE ADDRESS
97A1  10 AE 81                   LDY   ,X++                ; GET "SET BIT' ACTION ROUTINE ADDRESS
97A4  A1 80                      CMPA  ,X+                 ; CHECK FOR ONE OF THE FIVE LEGAL TOKENS
97A6  27 06                      BEQ   L97AE               ; FOUND ONE
97A8  5A                         DECB                      ; CHECKED ALL FIVE?
97A9  26 F4                      BNE   L979F               ; NO - KEEP GOING
97AB  7E B2 77                   JMP   LB277               ; 'SYNTAX' ERROR IF TOKEN NOT FOUND
97AE  10 9F D5          L97AE    STY   VD5                 ; ARRAY 'SET BIT' ACTION ROUTINE ADDRESS
97B1  DF D9                      STU   VD9                 ; ARRAY 'CLEAR BIT' ACTION ROUTINE ADDRESS
97B3  9D 9F                      JSR   GETNCH              ; GET INPUT CHAR FROM BASIC
97B5  20 13                      BRA   L97CA               ; SKIP AROUND THE 'NO G' OPTION CODE

* NO 'G' OPTION OR ACTION SPECIFIED BY BASIC INPUT LINE
97B7  C6 F8             L97B7    LDB   #$F8                ; BOTTOM 3 BITS MASK (8 PIXELS/BYTE)
97B9  96 B6                      LDA   PMODE               ; GET CURRENT PMODE
97BB  46                         RORA                      ; BIT 0 TO CARRY
97BC  24 02                      BCC   L97C0               ; BRANCH IF PMODE 0,2,4 (2 COLOR)
97BE  C6 FC                      LDB   #$FC                ; BOTTOM 2 BITS MASK (4 COLOR MODE - 4 PIXELS/BYTE)
97C0  1F 98             L97C0    TFR   B,A                 ; SAVE ACCB IN ACCA
97C2  D4 BE                      ANDB  HORBEG+1            ; *
97C4  D7 BE                      STB   HORBEG+1            ; * MASK THE PIXEL COUNTER (BITS 0,1=
97C6  94 C4                      ANDA  HOREND+1            ; * 4 COLOR, BITS 0-2=2 COLOR) BITS OFF
97C8  97 C4                      STA   HOREND+1            ; * THE HORIZONTAL DIFFERENCE
97CA  BD 97 1D          L97CA    JSR   L971D               ; CALC HORIZ DIFFERENCE ABS(HOREND-HORBEG)
97CD  24 04                      BCC   L97D3               ; BRANCH IF END > START
97CF  9E C3                      LDX   HOREND              ; * MAKE START = END IF
97D1  9F BD                      STX   HORBEG              ; * START > END
97D3  DD C3             L97D3    STD   HOREND              ; SAVE HORIZ DIFFERENCE
97D5  BD 97 10                   JSR   L9710               ; CALC VERT DIFFERENCE ABS (VEREND-VERBEG)
97D8  24 04                      BCC   L97DE               ; BRANCH IF END > START
97DA  9E C5                      LDX   VEREND              ; * MAKE START = END IF
97DC  9F BF                      STX   VERBEG              ; * START > END
97DE  DD C5             L97DE    STD   VEREND              ; SAVE VERT DIFFERENCE
97E0  96 B6                      LDA   PMODE               ; * GET PMODE BIT 0
97E2  46                         RORA                      ; * TO THE CARRY FLAG
97E3  DC C3                      LDD   HOREND              ; GET HORIZ DIFFERENCE
97E5  24 04                      BCC   L97EB               ; BRANCH IF PMODE = 0,2,4(2 COLOR)
97E7  D3 C3                      ADDD  HOREND              ; * DOUBLE HORIZ DIFF - 2X AS MANY BYTES FOR
97E9  DD C3                      STD   HOREND              ; * NUMBER OF PIXELS IN PMODES 1,3
97EB  BD 94 20          L97EB    JSR   L9420               ; NORMALIZE DIFFERENCES
97EE  DC C3                      LDD   HOREND              ; GET HORIZ DIFFERENCE
97F0  9E C5                      LDX   VEREND              ; *
97F2  30 01                      LEAX  $01,X               ; *
97F4  9F C5                      STX   VEREND              ; * ADD 1 TO VERT DIFFERENCE
97F6  0D D4                      TST   VD4                 ; = CHECK FOR 'G' OPTION OR GET ACTION
97F8  26 58                      BNE   L9852               ; = AND BRANCH IF GIVEN
97FA  44                         LSRA                      ; *
97FB  56                         RORB                      ; *
97FC  44                         LSRA                      ; *
97FD  56                         RORB                      ; *
97FE  44                         LSRA                      ; *
97FF  56                         RORB                      ; * DIVIDE HORIZONTAL DIFFERENCE BY 8
9800  C3 00 01                   ADDD  #1                  ; ADD ONE TO QUOTIENT
9803  DD C3                      STD   HOREND              ; SAVE NEW HOR DIFFERENCE
9805  BD 92 98                   JSR   L9298               ; *CONVERT (HORBEG,VERSEG) INTO ABSOLUTE SCREEN
; *POS (X) AND PIXEL MASK (ACCA)
9808  D6 C4             L9808    LDB   HOREND+1            ; GET HORIZ DIFFERENCE
980A  34 10                      PSHS  X                   ; SAVE SCREEN POSITION
980C  0D D8             L980C    TST   VD8                 ; CHECK THE GET/PUT FLAG
980E  27 21                      BEQ   L9831               ; BRANCH IF 'GET'
9810  8D 11                      BSR   L9823               ; INCREMENT ARRAY DATA POINTER
9812  A6 C4                      LDA   ,U                  ; GET DATA FROM ARRAY
9814  A7 80                      STA   ,X+                 ; PUT IT ON THE SCREEN
9816  5A                L9816    DECB                      ; DECREMENT HORIZ DIFFERENCE
9817  26 F3                      BNE   L980C               ; BRANCH IF NOT AT END OF HORIZ LINE
9819  35 10                      PULS  X                   ; GET SCREEN POSITION BACK
981B  BD 92 E9                   JSR   L92E9               ; MOVE ABS POSITION DOWN ONE ROW
981E  0A C6                      DEC   VEREND+1            ; DECREMENT VERTICAL DIFFERENCE
9820  26 E6                      BNE   L9808               ; BRANCH IF NOT DONE
9822  39                L9822    RTS

9823  DE CF             L9823    LDU   VCF                 ; *
9825  33 41                      LEAU  $01,U               ; *
9827  DF CF                      STU   VCF                 ; * ADD ONE TO CURRENT ARRAY DATA POINTER
9829  11 93 D1                   CMPU  VD1                 ; COMPARE TO END OF DATA
982C  26 F4                      BNE   L9822               ; RETURN IF NOT AT END
982E  7E B4 4A          L982E    JMP   LB44A               ; 'ILLEGAL FUNCTION CALL'

9831  A6 80             L9831    LDA   ,X+                 ; GET DATA FROM SCREEN
9833  8D EE                      BSR   L9823               ; INCREMENT ARRAY DATA POINTER
9835  A7 C4                      STA   ,U                  ; STORE IN ARRAY
9837  20 DD                      BRA   L9816               ; KEEP LOOPING TILL DONE
*
9839  98 94 98 9B       L9839    FDB   L9894,L989B
983D  BD                L983D    FCB   $BD                 ; TOKEN FOR PSET
983E  98 9B 98 94       L983E    FDB   L989B,L9894
9842  BE                L9842    FCB   $BE                 ; TOKEN FOR PRESET
9843  98 B1 98 9B       L9843    FDB   L98B1,L989B
9847  B1                L9847    FCB   $B1                 ; TOKEN FOR OR
9848  98 94 98 B1       L9848    FDB   L9894,L98B1
984C  B0                L984C    FCB   $B0                 ; TOKEN FOR AND
984D  98 A1 98 A1       L984D    FDB   L98A1,L98A1
9851  A8                L9851    FCB   $A8                 ; TOKEN FOR NOT

* GET/PUT WITH 'G' OPTION SPECIFIED
9852  C3 00 01          L9852    ADDD  #1                  ; ADD ONE TO HORIZ DIFFERENCE
9855  DD C3                      STD   HOREND              ; AND SAVE IT
9857  96 D8                      LDA   VD8                 ; *CHECK GET/PUT FLAG AND
9859  26 09                      BNE   L9864               ; *BRANCH IF PUT
985B  DE D1                      LDU   VD1                 ; GET END OF ARRAYS
985D  A7 C2             L985D    STA   ,-U                 ; *THIS CODE WILL
985F  11 93 CF                   CMPU  VCF                 ; *ZERO OUT THE ENTIRE
9862  22 F9                      BHI   L985D               ; *'GET' ARRAY
9864  BD 92 98          L9864    JSR   L9298               ; =CONVERT (HORBEG,VERBEG) INTO ABSOLUTE SCREEN POSITION
* =(X) AND PIXEL MASK (ACCA)
9867  D6 B6                      LDB   PMODE               ; GET CURRENT PMODE
9869  56                         RORB                      ; BIT 0 TO CARRY
986A  24 02                      BCC   L986E               ; BRANCH IF PMODE 0,2,4 (2 COLOR)
986C  84 AA                      ANDA  #$AA                ; USE $AA AS THE PIXEL MASK IN 4 COLOR MODE
986E  C6 01             L986E    LDB   #$01                ; INITIALIZE SHIFT CTR
9870  10 9E CF                   LDY   VCF                 ; POINT Y TO ARRAY DATA
9873  34 12             L9873    PSHS  X,A                 ; SAVE PIXEL MASK (ACCA) AND ABS SCRN POS (X) ON STACK
9875  DE C3                      LDU   HOREND              ; GET THE HORIZONTAL DIFFERENCE
9877  34 42             L9877    PSHS  U,A                 ; SAVE PIXEL MASK AND HORIZ DIFF
9879  54                         LSRB                      ; SHIFT BIT CTR RIGHT
987A  24 08                      BCC   L9884               ; BRANCH IF ALL 8 SHIFTS NOT DONE
987C  56                         RORB                      ; SHIFT CARRY BACK INTO ACCB
987D  31 21                      LEAY  $01,Y               ; INCREMENT ARRAY DATA POINTER
987F  10 9C D1                   CMPY  VD1                 ; COMPARE TO END OF ARRAY
9882  27 AA                      BEQ   L982E               ; 'FC' ERROR IF AT END
9884  0D D8             L9884    TST   VD8                 ; CHECK THE GET/PUT FLAG AND
9886  27 1F                      BEQ   L98A7               ; BRANCH IF GET
9888  E5 A4                      BITB  ,Y                  ; TEST A BIT IN ARRAY DATA
988A  27 04                      BEQ   L9890               ; BRANCH IF ZERO
988C  6E 9F 00 D5                JMP   [VD5]               ; JUMP TO ACTION ROUTINE FOR ARRAY BIT SET
9890  6E 9F 00 D9       L9890    JMP   [VD9]               ; JUMP TO ACTION ROUTINE FOR ARRAY BIT CLEAR
9894  43                L9894    COMA                      ; *MASK SOURCE DATA
9895  A4 84                      ANDA  ,X                  ; *OFF OF SCREEN DATA
9897  A7 84                      STA   ,X                  ; SAVE TO SCREEN
9899  20 16                      BRA   L98B1
989B  AA 84             L989B    ORA   ,X                  ; 'OR' SOURCE DATA WITH SCREEN
989D  A7 84                      STA   ,X                  ; SAVE TO SCREEN
989F  20 10                      BRA   L98B1
98A1  A8 84             L98A1    EORA  ,X                  ; INVERT THE PIXEL
98A3  A7 84                      STA   ,X                  ; SAVE TO SCREEN
98A5  20 0A                      BRA   L98B1
98A7  A5 84             L98A7    BITA  ,X                  ; TEST THE PIXEL
98A9  27 06                      BEQ   L98B1               ; BRANCH IF IT IS OFF
98AB  1F 98                      TFR   B,A                 ; PUT SHIFT CTR IN ACCA
98AD  AA A4                      ORA   ,Y                  ; TURN ON PROPER BIT IN
98AF  A7 A4                      STA   ,Y                  ; THE ARRAY DATA
98B1  35 42             L98B1    PULS  A,U                 ; RESTORE PIXEL MASK AND HOR DIFF
98B3  BD 92 ED                   JSR   L92ED               ; MOVE SCRN POS & PIXEL MASK ONE TO RIGHT (TWO COLOR MODE)
98B6  33 5F                      LEAU  $-01,U              ; *
98B8  11 93 8A                   CMPU  ZERO                ; * DECR HORIZ DIFFERENCE AND
98BB  26 BA                      BNE   L9877               ; * BRANCH IF NOT ZERO
98BD  AE 61                      LDX   $01,S               ; GET ABS SCRN POS FROM STACK
98BF  96 B9                      LDA   HORBYT              ; GET NUMBER BYTES/GRAPHIC ROW
98C1  30 86                      LEAX  A,X                 ; MOVE SCRN POS DOWN ONE ROW
98C3  35 02                      PULS  A                   ; PULL PIXEL MASK OFF THE STACK
98C5  32 62                      LEAS  $02,S               ; GET X OFF THE STACK
98C7  0A C6                      DEC   VEREND+1            ; DECR VERT ROW CTR
98C9  26 A8                      BNE   L9873               ; BRANCH IF NOT DONE
98CB  39                         RTS                       ; RETURN FROM GET/PUT COMMAND

98CC  BD B3 57          L98CC    JSR   LB357               ; EVAL ALPHA EXPR, RETURN DESCRIPTOR PTR IN X
98CF  E6 82                      LDB   ,-X                 ; *STRIP OFF THE VARIABLE
98D1  A6 82                      LDA   ,-X                 ; *NAME (2 ALPHA-NUMERIC CHARACTERS) AND
98D3  1F 03                      TFR   D,U                 ; *STORE THEM IN U
98D5  9E 1D                      LDX   ARYTAB              ; GET START OF ARRAYS
98D7  9C 1F             L98D7    CMPX  ARYEND              ; COMPARE TO END OF ARRAYS
98D9  10 27 1B 6D                LBEQ  LB44A               ; 'FC' ERROR IF UNDEFINED ARRAY
98DD  11 A3 84                   CMPU  ,X                  ; COMPARE TARGET NAME TO ARRAY NAME
98E0  27 06                      BEQ   L98E8               ; RETURN IF CORRECT ARRAY FOUND
98E2  EC 02                      LDD   $02,X               ; * GET OFFSET TO NEXT ARRAY AND
98E4  30 8B                      LEAX  D,X                 ; * ADD TO POINTER
98E6  20 EF                      BRA   L98D7               ; KEEP SEARCHING FOR MATCH
98E8  30 02             L98E8    LEAX  $02,X               ; MOVE POINTER TO OFFSET TO NEXT ARRAY
98EA  39                         RTS                       ; WASTED BYTE
98EB  39                L98EB    RTS
