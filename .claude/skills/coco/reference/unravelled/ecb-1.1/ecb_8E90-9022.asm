; Extended Color BASIC 1.1 -- $8E90-$9022
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: XVEC9=$8E90

* PRINT RAM HOOK
8E90  81 CD             XVEC9    CMPA  #$CD                ; USING TOKEN
8E92  27 01                      BEQ   L8E95               ; BRANCH IF PRINT USING
8E94  39                         RTS

* PRINT USING
* VDA IS USED AS A STATUS BYTE: BIT 6 = COMMA FORCE
* BIT 5=LEADING ASTERISK FORCE; BIT 4 = FLOATING $ FORCE
* BIT 3 = PRE SIGN FORCE; BIT 2 = POST SIGN FORCE; BIT 0 = EXPONENTIAL FORCE
8E95  32 62             L8E95    LEAS  $02,S               ; PURGE RETURN ADDRESS OFF THE STACK
8E97  BD B1 58                   JSR   LB158               ; EVALUATE FORMAT STRING
8E9A  BD B1 46                   JSR   LB146               ; 'TM' ERROR IF VARIABLE TYPE = NUMERIC
8E9D  C6 3B                      LDB   #';'                ; CHECK FOR ITEM LIST SEPARATOR
8E9F  BD B2 6F                   JSR   LB26F               ; SYNTAX CHECK FOR ;
8EA2  9E 52                      LDX   FPA0+2              ; * GET FORMAT STRING DESCRIPTOR ADDRESS
8EA4  9F D5                      STX   VD5                 ; * AND SAVE IT IN VD5
8EA6  20 06                      BRA   L8EAE               ; GO PROCESS FORMAT STRING
8EA8  96 D7             L8EA8    LDA   VD7                 ; *CHECK NEXT PRINT ITEM FLAG AND
8EAA  27 08                      BEQ   L8EB4               ; *'FC' ERROR IF NO FURTHER PRINT ITEMS
8EAC  9E D5                      LDX   VD5                 ; RESET FORMAT STRING POINTER TO START OF STRING
8EAE  0F D7             L8EAE    CLR   VD7                 ; RESET NEXT PRINT ITEM FLAG
8EB0  E6 84                      LDB   ,X                  ; GET LENGTH OF FORMAT STRING
8EB2  26 03                      BNE   L8EB7               ; INTERPRET FORMAT STRING IF LENGTH > 0
8EB4  7E B4 4A          L8EB4    JMP   LB44A               ; 'FC' ERROR IF FORMAT STRING = NULL
8EB7  AE 02             L8EB7    LDX   $02,X               ; POINT X TO START OF FORMAT STRING
* INTERPRET THE FORMAT STRING
8EB9  0F DA             L8EB9    CLR   VDA                 ; CLEAR THE STATUS BYTE
8EBB  0F D9             L8EBB    CLR   VD9                 ; CLEAR LEFT DIGIT COUNTER
8EBD  A6 80                      LDA   ,X+                 ; GET A CHARACTER FROM FORMAT STRING
8EBF  81 21                      CMPA  #'!'                ; EXCLAMATION POINT?
8EC1  10 27 FF 72                LBEQ  L8E37               ; YES - STRING TYPE FORMAT
8EC5  81 23                      CMPA  #'#'                ; NUMBER SIGN? (DIGIT LOCATOR)
8EC7  27 5B                      BEQ   L8F24               ; YES - NUMERIC TYPE FORMAT
8EC9  5A                         DECB                      ; DECREMENT FORMAT STRING LENGTH
8ECA  26 16                      BNE   L8EE2               ; BRANCH IF NOT DONE
8ECC  BD 8F D8                   JSR   L8FD8               ; SEND A '+' TO CONSOLE OUT IF VDA <> 0
8ECF  BD A2 82                   JSR   LA282               ; SEND CHARACTER TO CONSOLE OUT
8ED2  9D A5             L8ED2    JSR   GETCCH              ; GET CURRENT CHARACTER FROM BASIC
8ED4  26 D2                      BNE   L8EA8               ; BRANCH IF NOT END OF LINE
8ED6  96 D7                      LDA   VD7                 ; GET NEXT PRINT ITEM FLAG
8ED8  26 03             L8ED8    BNE   L8EDD               ; BRANCH IF MORE PRINT ITEMS
8EDA  BD B9 58                   JSR   LB958               ; SEND A CARRIAGE RETURN TO CONSOLE OUT
8EDD  9E D5             L8EDD    LDX   VD5                 ; POINT X TO FORMAT STRING DESCRIPTOR
8EDF  7E B6 59                   JMP   LB659               ; RETURN ADDRESS AND LENGTH OF FORMAT STRING - EXIT PRINT USING
8EE2  81 2B             L8EE2    CMPA  #'+'                ; CHECK FOR '+' (PRE-SIGN FORCE)
8EE4  26 09                      BNE   L8EEF               ; NO PLUS
8EE6  BD 8F D8                   JSR   L8FD8               ; SEND A '+' TO CONSOLE OUT IF VDA <> 0
8EE9  86 08                      LDA   #$08                ; * LOAD THE STATUS BYTE WITH 8;
8EEB  97 DA                      STA   VDA                 ; * PRE-SIGN FORCE FLAG
8EED  20 CC                      BRA   L8EBB               ; INTERPRET THE REST OF THE FORMAT STRING
8EEF  81 2E             L8EEF    CMPA  #'.'                ; DECIMAL POINT?
8EF1  27 4E                      BEQ   L8F41               ; YES
8EF3  81 25                      CMPA  #'%'                ; PERCENT SIGN?
8EF5  10 27 FF 70                LBEQ  L8E69               ; YES
8EF9  A1 84                      CMPA  ,X                  ; COMPARE THE PRESENT FORMAT STRING INPUT
* CHARACTER TO THE NEXT ONE IN THE STRING
8EFB  26 8B             L8EFB    BNE   L8E88               ; NO MATCH - ILLEGAL CHARACTER
* TWO CONSECUTIVE EQUAL CHARACTERS IN FORMAT STRING
8EFD  81 24                      CMPA  #'$'                ; DOLLAR SIGN?
8EFF  27 19                      BEQ   L8F1A               ; YES - MAKE THE DOLLAR SIGN FLOAT
8F01  81 2A                      CMPA  #'*'                ; ASTERISK?
8F03  26 F6                      BNE   L8EFB               ; NO - ILLEGAL CHARACTER
8F05  96 DA                      LDA   VDA                 ; * GRAB THE STATUS BYTE AND BET BIT 5
8F07  8A 20                      ORA   #$20                ; * TO INDICATE THAT THE OUTPUT WILL
8F09  97 DA                      STA   VDA                 ; * BE LEFT PADDED WITH ASTERISKS
8F0B  C1 02                      CMPB  #2                  ; = CHECK TO SEE IF THE $$ ARE THE LAST TWO
8F0D  25 11                      BLO   L8F20               ; = CHARACTERS IN THE FORMAT STRING AND BRANCH IF SO
8F0F  A6 01                      LDA   $01,X               ; GET THE NEXT CHARACTER AFTER **
8F11  81 24                      CMPA  #'$'                ; CHECK FOR **$
8F13  26 0B                      BNE   L8F20               ; CHECK FOR MORE CHARACTERS
8F15  5A                         DECB                      ; DECREMENT STRING LENGTH COUNTER
8F16  30 01                      LEAX  $01,X               ; MOVE FORMAT STRING POINTER UP ONE
8F18  0C D9                      INC   VD9                 ; ADD ONE TO LEFT DIGIT COUNTER - FOR ASTERISK PAD AND
* FLOATING DOLLAR SIGN COMBINATION
8F1A  96 DA             L8F1A    LDA   VDA                 ; * GET THE STATUS BYTE AND SET
8F1C  8A 10                      ORA   #$10                ; * BIT 4 TO INDICATE A
8F1E  97 DA                      STA   VDA                 ; * FLOATING DOLLAR SIGN
8F20  30 01             L8F20    LEAX  $01,X               ; MOVE FORMAT STRING POINTER UP ONE
8F22  0C D9                      INC   VD9                 ; ADD ONE TO LEFT DIGIT (FLOATING $ OR ASTERISK PAD)
* PROCESS CHARACTERS TO THE LEFT OF THE DECIMAL POINT IN THE FORMAT STRING
8F24  0F D8             L8F24    CLR   VD8                 ; CLEAR THE RIGHT DIGIT COUNTER
8F26  0C D9             L8F26    INC   VD9                 ; ADD ONE TO LEFT DIGIT COUNTER
8F28  5A                         DECB                      ; DECREMENT FORMAT STRING LENGTH COUNTER
8F29  27 49                      BEQ   L8F74               ; BRANCH IF END OF FORMAT STRING
8F2B  A6 80                      LDA   ,X+                 ; GET THE NEXT FORMAT CHARACTER
8F2D  81 2E                      CMPA  #'.'                ; DECIMAL POINT?
8F2F  27 1E                      BEQ   L8F4F               ; YES
8F31  81 23                      CMPA  #'#'                ; NUMBER SIGN?
8F33  27 F1                      BEQ   L8F26               ; YES
8F35  81 2C                      CMPA  #','                ; COMMA?
8F37  26 21                      BNE   L8F5A               ; NO
8F39  96 DA                      LDA   VDA                 ; * GET THE STATUS BYTE
8F3B  8A 40                      ORA   #$40                ; * AND SET BIT 6 WHICH IS THE
8F3D  97 DA                      STA   VDA                 ; * COMMA SEPARATOR FLAG
8F3F  20 E5                      BRA   L8F26               ; PROCESS MORE CHARACTERS TO LEFT OF DECIMAL POINT
* PROCESS DECIMAL POINT IF NO DIGITS TO LEFT OF IT
8F41  A6 84             L8F41    LDA   ,X                  ; GET NEXT FORMAT CHARACTER
8F43  81 23                      CMPA  #'#'                ; IS IT A NUMBER SIGN?
8F45  10 26 FF 3F                LBNE  L8E88               ; NO
8F49  86 01                      LDA   #1                  ; * SET THE RIGHT DIGIT COUNTER TO 1 -
8F4B  97 D8                      STA   VD8                 ; * ALLOW ONE SPOT FOR DECIMAL POINT
8F4D  30 01                      LEAX  $01,X               ; MOVE FORMAT POINTER UP ONE
* PROCESS DIGITS TO RIGHT OF DECIMAL POINT
8F4F  0C D8             L8F4F    INC   VD8                 ; ADD ONE TO RIGHT DIGIT COUNTER
8F51  5A                         DECB                      ; DECREMENT FORMAT LENGTH COUNTER
8F52  27 20                      BEQ   L8F74               ; BRANCH IF END OF FORMAT STRING
8F54  A6 80                      LDA   ,X+                 ; GET A CHARACTER FROM FORMAT STRING
8F56  81 23                      CMPA  #'#'                ; IS IT NUMBER SIGN?
8F58  27 F5                      BEQ   L8F4F               ; YES - KEEP CHECKING
* CHECK FOR EXPONENTIAL FORCE
8F5A  81 5E             L8F5A    CMPA  #$5E                ; CHECK FOR UP ARROW
8F5C  26 16                      BNE   L8F74               ; NO UP ARROW
8F5E  A1 84                      CMPA  ,X                  ; IS THE NEXT CHARACTER AN UP ARROW?
8F60  26 12                      BNE   L8F74               ; NO
8F62  A1 01                      CMPA  $01,X               ; AND THE NEXT CHARACTER?
8F64  26 0E                      BNE   L8F74               ; NO
8F66  A1 02                      CMPA  $02,X               ; HOW ABOUT THE 4TH CHARACTER?
8F68  26 0A                      BNE   L8F74               ; NO, ALSO
8F6A  C1 04                      CMPB  #4                  ; * CHECK TO SEE IF THE 4 UP ARROWS ARE IN THE
8F6C  25 06                      BLO   L8F74               ; * FORMAT STRING AND BRANCH IF NOT
8F6E  C0 04                      SUBB  #4                  ; = MOVE POINTER UP 4 AND SUBTRACT
8F70  30 04                      LEAX  $04,X               ; = FOUR FROM LENGTH
8F72  0C DA                      INC   VDA                 ; INCREMENT STATUS BYTE - EXPONENTIAL FORM

* CHECK FOR A PRE OR POST - SIGN FORCE AT END OF FORMAT STRING
8F74  30 1F             L8F74    LEAX  $-01,X              ; MOVE POINTER BACK ONE
8F76  0C D9                      INC   VD9                 ; ADD ONE TO LEFT DIGIT COUNTER FOR PRE-SIGN FORCE
8F78  96 DA                      LDA   VDA                 ; * PRE-SIGN
8F7A  85 08                      BITA  #$08                ; * FORCE AND
8F7C  26 18                      BNE   L8F96               ; * BRANCH IF SET
8F7E  0A D9                      DEC   VD9                 ; DECREMENT LEFT DIGIT — NO PRE-SIGN FORCE
8F80  5D                         TSTB                      ; * CHECK LENGTH COUNTER AND BRANCH
8F81  27 13                      BEQ   L8F96               ; * IF END OF FORMAT STRING
8F83  A6 84                      LDA   ,X                  ; GET NEXT FORMAT STRING CHARACTER
8F85  80 2D                      SUBA  #'-'                ; CHECK FOR MINUS SIGN
8F87  27 06                      BEQ   L8F8F               ; BRANCH IF MINUS SIGN
8F89  81 FE                      CMPA  #('+')-('-')        ; CHECK FOR PLUS SIGN
8F8B  26 09                      BNE   L8F96               ; BRANCH IF NO PLUS SIGN
8F8D  86 08                      LDA   #$08                ; GET THE PRE-SIGN FORCE FLAG
8F8F  8A 04             L8F8F    ORA   #$04                ; 'OR' IN POST-SIGN FORCE FLAG
8F91  9A DA                      ORA   VDA                 ; 'OR' IN THE STATUS BYTE
8F93  97 DA                      STA   VDA                 ; SAVE THE STATUS BYTE
8F95  5A                         DECB                      ; DECREMENT FORMAT STRING LENGTH

* EVALUATE NUMERIC ITEM-LIST
8F96  9D A5             L8F96    JSR   GETCCH              ; GET CURRENT CHARACTER
8F98  10 27 FF 3C                LBEQ  L8ED8               ; BRANCH IF END OF LINE
8F9C  D7 D3                      STB   VD3                 ; SAVE FORMAT STRING LENGTH WHEN FORMAT EVALUATION ENDED
8F9E  BD B1 41                   JSR   LB141               ; EVALUATE EXPRESSION
8FA1  96 D9                      LDA   VD9                 ; GET THE LEFT DIGIT COUNTER
8FA3  9B D8                      ADDA  VD8                 ; ADD IT TO THE RIGHT DIGIT COUNTER
8FA5  81 11                      CMPA  #17                 ; *
8FA7  10 22 24 9F                LBHI  LB44A               ; *'FC' ERROR IF MORE THAN 16 DIGITS AND DECIMAL POiNT
8FAB  BD 8F E5                   JSR   >L8FE5              ; CONVERT ITEM-LIST TO FORMATTED ASCII STRING
8FAE  30 1F                      LEAX  $-01,X              ; MOVE BUFFER POINTER BACK ONE
8FB0  BD B9 9C                   JSR   STRINOUT            ; DISPLAY THE FORMATTED STRING TO CONSOLE OUT
8FB3  0F D7             L8FB3    CLR   VD7                 ; RESET NEXT PRINT ITEM FLAG
8FB5  9D A5                      JSR   GETCCH              ; GET CURRENT INPUT CHARACTER
8FB7  27 0D                      BEQ   L8FC6               ; BRANCH IF END OF LINE
8FB9  97 D7                      STA   VD7                 ; SAVE CURRENT CHARACTER (<>0) IN NEXT PRINT ITEM FLAG
8FBB  81 3B                      CMPA  #';'                ; * CHECK FOR ; - ITEM-LIST SEPARATOR AND
8FBD  27 05                      BEQ   L8FC4               ; * BRANCH IF SEMICOLON
8FBF  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR COMMA
8FC2  20 02                      BRA   L8FC6               ; PROCESS NEXT PRINT ITEM
8FC4  9D 9F             L8FC4    JSR   GETNCH              ; GET NEXT INPUT CHARACTER
8FC6  9E D5             L8FC6    LDX   VD5                 ; GET FORMAT STRING DESCRIPTOR ADDRESS
8FC8  E6 84                      LDB   ,X                  ; GET LENGTH OF FORMAT STRING
8FCA  D0 D3                      SUBB  VD3                 ; SUBTRACT AMOUNT OF FORMAT STRING LEFT AFTER LAST PRINT ITEM
8FCC  AE 02                      LDX   $02,X               ; *GET FORMAT STRING START ADDRESS AND ADVANCE
8FCE  3A                         ABX                       ; *POINTER TO START OF UNUSED FORMAT STRING
8FCF  D6 D3                      LDB   VD3                 ; =GET AMOUNT OF UNUSED FORMAT STRING
8FD1  10 26 FE E4                LBNE  L8EB9               ; =REINTERPRET FORMAT STRING FROM THAT POINT
8FD5  7E 8E D2                   JMP   L8ED2               ; REINTERPRET FORMAT STRING FROM THE START IF ENTIRELY
* USED ON LAST PRINT ITEM

* PRINT A '+' TO CONSOLE OUT IF THE STATUS BYTE <> 0
8FD8  34 02             L8FD8    PSHS  A                   ; RESTORE ACCA AND RETURN
8FDA  86 2B                      LDA   #'+'                ; GET ASCII PLUS SIGN
8FDC  0D DA                      TST   VDA                 ; * CHECK THE STATUS BYTE AND
8FDE  27 03                      BEQ   L8FE3               ; * RETURN IF = 0
8FE0  BD A2 82                   JSR   LA282               ; SEND A CHARACTER TO CONSOLE OUT
8FE3  35 82             L8FE3    PULS  A,PC                ; RETURN ACCA AND RETURN

* CONVERT ITEM-LIST TO DECIMAL ASCII STRING
8FE5  CE 03 DB          L8FE5    LDU   #STRBUF+4           ; POINT U TO STRING BUFFER
8FE8  C6 20                      LDB   #SPACE              ; BLANK
8FEA  96 DA                      LDA   VDA                 ; * GET THE STATUS FLAG AND
8FEC  85 08                      BITA  #$08                ; * CHECK FOR A PRE-SIGN FORCE
8FEE  27 02                      BEQ   L8FF2               ; * BRANCH IF NO PRE-SIGN FORCE
8FF0  C6 2B                      LDB   #'+'                ; PLUS SIGN
8FF2  0D 54             L8FF2    TST   FP0SGN              ; CHECK THE SIGN OF FPA0
8FF4  2A 04                      BPL   L8FFA               ; BRANCH IF POSITIVE
8FF6  0F 54                      CLR   FP0SGN              ; FORCE FPA0 SIGN TO BE POSITIVE
8FF8  C6 2D                      LDB   #'-'                ; MINUS SIGN
8FFA  E7 C0             L8FFA    STB   ,U+                 ; SAVE THE SIGN IN BUFFER
8FFC  C6 30                      LDB   #'0'                ; * PUT A ZERO INTO THE BUFFER
8FFE  E7 C0                      STB   ,U+                 ; *
9000  84 01                      ANDA  #$01                ; = CHECK THE EXPONENTIAL FORCE FLAG IN
9002  10 26 01 07                LBNE  L910D               ; = THE STATUS BYTE - BRANCH IF ACTIVE
9006  8E BD C0                   LDX   #LBDC0              ; POINT X TO FLOATING POINT 1E + 09
9009  BD BC A0                   JSR   LBCA0               ; COMPARE FPA0 TO (X)
900C  2B 15                      BMI   L9023               ; BRANCH IF FPA0 < 1E+09
900E  BD BD D9                   JSR   LBDD9               ; CONVERT FP NUMBER TO ASCII STRING
9011  A6 80             L9011    LDA   ,X+                 ; * ADVANCE POINTER TO END OF
9013  26 FC                      BNE   L9011               ; * ASCII STRING (ZERO BYTE)
9015  A6 82             L9015    LDA   ,-X                 ; = MOVE THE
9017  A7 01                      STA   $01,X               ; = ENTIRE STRING
9019  8C 03 DA                   CMPX  #STRBUF+3           ; = UP ONE
901C  26 F7                      BNE   L9015               ; = BYTE
901E  86 25                      LDA   #'%'                ; * INSERT A % SIGN AT START OF
9020  A7 84                      STA   ,X                  ; * STRING - OVERFLOW ERROR
9022  39                         RTS
