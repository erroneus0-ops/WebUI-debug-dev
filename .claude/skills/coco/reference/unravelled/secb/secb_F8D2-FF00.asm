; Super Extended Color BASIC 2.0 (CoCo 3) -- $F8D2-$FF00
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "SECB"
; Object bytes verified against genuine ROM image (SHA-1 9a05652fd80ab87219102800fe6a44a4ecacd8c3). See ../README.md for line format.
; Named entry points here: LOCATE=$F8D2, HSTAT=$F925, ATTR=$F9B9

* LOCATE
F8D2  D6 E7             LOCATE   LDB   HRWIDTH             ; IS THE HI-RES TEXT MODE ENABLED?
F8D4  10 21 07 28                LBRN  RAMLINK             ; RAM HOOK
F8D8  27 F3                      BEQ   LF8CD               ; 'HP' ERROR IF NOT ENABLED
F8DA  34 04                      PSHS  B                   ; SAVE THE HI-RES TEXT MODE
F8DC  BD E7 B2                   JSR   LE7B2               ; EVALUATE TWO EXPRESSIONS
F8DF  96 2C                      LDA   BINVAL+1            ; GET THE FIRST OF THE TWO EXPRESSIONS (COLUMN NUMBER)
F8E1  35 04                      PULS  B                   ; RESTORE THE FIRST ARGUMENT
F8E3  C1 01                      CMPB  #$01                ; GET BACK THE HI-RES TEXT MODE
F8E5  26 04                      BNE   LF8EB               ; BRANCH IF NOT 40 COLUMN MODE
F8E7  81 28                      CMPA  #40                 ; 40 COLUMNS MAXIMUM IN 40 COLUMN MODE
F8E9  20 02                      BRA   LF8ED               ; DO A RANGE CHECK
F8EB  81 50             LF8EB    CMPA  #80                 ; 80 COLUMNS MAXIMUM IN 80 COLUMN MODE
F8ED  10 24 BB 59       LF8ED    LBCC  ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR
F8F1  D6 C0                      LDB   VERBEG+1            ; GET THE SECOND ARGUMENT (ROW NUMBER)
F8F3  C1 18                      CMPB  #ROWMAX             ; RANGE CHECK ON THE ROW NUMBER
F8F5  24 F6                      BCC   LF8ED               ; 'FC' ERROR IF ROW NUMBER IS TOO LARGE
F8F7  34 06                      PSHS  B,A                 ; SAVE THE COLUMN AND ROW NUMBERS
F8F9  17 FE 76                   LBSR  LF772               ; PUT THE HI-RES TEXT SCREEN INTO THE LOGICAL ADDRESS SPACE
F8FC  FD FE 02                   STD   H.CURSX             ; SAVE THE NEW COLUMN AND ROW NUMBERS AS THOSE OF THE CURSOR
F8FF  BE FE 00                   LDX   H.CRSLOC            ; GET THE CURRENT CURSOR POINTER
F902  B6 FE 08                   LDA   H.CRSATT            ; GET THE CURSOR ATTRIBUTES RAM IMAGE
F905  A7 01                      STA   $01,X               ; AND SAVE IT AS THE ATTRIBUTES IN THE OLD CURSOR POSITION
F907  B6 FE 04                   LDA   H.COLUMN            ; GET THE NUMBER OF CHARACTERS/ROW
F90A  48                         ALSA                      ; MULTIPLY BY TWO - TWO BYTES PER CHARACTER (CHAR AND ATTR)
F90B  3D                         MUL                       ; GET THE ROW OFFSET TO THE PROPER CHARACTER
F90C  8E 20 00                   LDX   #HRESSCRN           ; POINT TO THE START OF THE HI-RES TEXT SCREEN
F90F  30 8B                      LEAX  D,X                 ; ADD ROW OFFSET TO THE START OF THE HI-RES TEXT SCREEN
F911  35 06                      PULS  A,B                 ; RESTORE THE NEW CURSOR COLUMN AND ROW NUMBERS
F913  48                         ALSA                      ; MULTIPLY COLUMN NUMBER BY TWO - TWO BYTES PER CHARACTER (CHAR AND ATTR)
F914  1F 89                      TFR   A,B                 ; SAVE COLUMN OFFSET IN ACCB
F916  3A                         ABX                       ; ADD THE COLUMN OFFSET TO THE CURRENT CURSOR POINTER
F917  B6 FE 08                   LDA   H.CRSATT            ; GET THE CURSOR ATTRIBUTES RAM IMAGE
F91A  8A 40                      ORA   #$40                ; FORCE UNDERLINE ATTRIBUTE
F91C  A7 01                      STA   $01,X               ; SAVE THE NEW CURSOR ATTRIBUTE IN THE HI-RES TEXT SCREEN
F91E  BF FE 00                   STX   H.CRSLOC            ; SAVE THE NEW CURSOR POINTER
F921  17 FE 54                   LBSR  LF778               ; RESTORE THE NORMAL BASIC PROGRAM BLOCK TO LOGICAL BLOCK 1
F924  39                         RTS

* HSTAT
F925  0D E7             HSTAT    TST   HRWIDTH             ; IS THE HI-RES TEXT MODE ENABLED?
F927  10 21 06 D5                LBRN  RAMLINK             ; RAM HOOK
F92B  27 A0                      BEQ   LF8CD               ; 'HP' ERROR IF HI-RES TEXT MODE NOT ENABLED
F92D  17 FE 42                   LBSR  LF772               ; PUT THE HI-RES TEXT SCREEN INTO THE LOGICAL ADDRESS SPACE
F930  BE FE 00                   LDX   H.CRSLOC            ; GET THE CURRENT CURSOR POINTER
F933  EC 84                      LDD   ,X                  ; GET THE CURSOR CHARACTER ATTRIBUTES
F935  DD CB                      STD   VCB                 ; AND SAVE THEM
F937  FC FE 02                   LDD   H.CURSX             ; GET THE CURRENT COLUMN AND ROW NUMBER
F93A  DD CD                      STD   VCD                 ; AND SAVE THEM
F93C  17 FE 39                   LBSR  LF778               ; RESTORE THE NORMAL BASIC PROGRAM BLOCK TO LOGICAL BLOCK 1
F93F  BD B3 57                   JSR   LB357               ; EVALUATE A VARIABLE; RETURN X POINTING TO THE VARIABLE DESCRIPTOR
F942  9F 3B                      STX   VARDES              ; SAVE THE VARIABLE DESCRIPTOR
F944  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR A COMMA
F947  C6 01                      LDB   #$01
F949  BD B5 6D                   JSR   LB56D               ; RESERVE SPACE FOR A ONE CHARACTER STRING IN STRING SPACE
F94C  96 CB                      LDA   VCB                 ; GET THE CURSOR CHARACTER
F94E  BD B5 11                   JSR   LB511               ; THIS IS REALLY A WASTE - THE JSR LB56D ABOVE SHOULD JUST BE A
; JSR LB50D AND THE JSR LB511 WOULD NOT BE NECESSARY
F951  A7 84                      STA   ,X                  ; SAVE THE CURSOR CHARACTER IN THE NEWLY RESERVED STRING SPACE
F953  BD B5 4C                   JSR   LB54C               ; PUT THE STRING ONTO THE STRING STACK
F956  9E 3B                      LDX   VARDES              ; POINT TO THE STRING'S VARIABLE DESCRIPTOR
F958  6D 1F                      TST   $-01,X              ; CHECK THE SECOND CHARACTER OF THE VARIABLE NAME
F95A  10 2A B7 F3                LBPL  TMERROR             ; TYPE MISMATCH ERROR IF NUMERIC VARIABLE
F95E  10 9E 52                   LDY   FPA0+2              ; POINT Y TO THE START OF THE STRING DESCRIPTOR
F961  C6 05                      LDB   #$05                ; VARIABLE DESCRIPTORS ARE 5 BYTES LONG
F963  A6 A0             LF963    LDA   ,Y+                 ; * COPY THE DATA FROM THE STRING DESCRIPTOR
F965  A7 80                      STA   ,X+                 ; * TO THE VARIABLE DESCRIPTOR
F967  5A                         DECB                      ; DECREMENT THE DESCRIPTOR COUNTER
F968  26 F9                      BNE   LF963               ; LOOP UNTIL DONE
F96A  9E 0B                      LDX   TEMPPT              ; * THIS CODE IS DESIGNED TO REMOVE THE ABOVE ALLOCATED STRING FROM
F96C  30 1B                      LEAX  $-05,X              ; * THE STRING STACK - IT MAY CAUSE BUGS BECAUSE IT DOESN'T RESET
F96E  9F 0B                      STX   TEMPPT              ; * LASTPT; LDX LASTPT, JSR LB675 WOULD BE MUCH BETTER
F970  BD B3 57                   JSR   LB357               ; EVALUATE A VARIABLE; RETURN X POINTING TO THE VARIABLE DESCRIPTOR
F973  9F 3B                      STX   VARDES              ; SAVE THE VARIABLE DESCRIPTOR
F975  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR A COMMA
F978  4F                         CLRA                      ; ZERO OUT THE MS BYTE OF ACCD
F979  D6 CC                      LDB   VCB+1               ; GET THE CURSOR ATTRIBUTES
F97B  BD B4 F4                   JSR   GIVABF              ; CONVERT ACCD TO FLOATING POINT
F97E  9E 3B                      LDX   VARDES              ; POINT X TO THE VARIABLE DESCRIPTOR
F980  6D 1F                      TST   $-01,X              ; CHECK THE SECOND CHARACTER OF THE VARIABLE NAME
F982  10 2B B7 CB                LBMI  TMERROR             ; TYPE MISMATCH ERROR IF STRING VARIABLE
F986  BD BC 35                   JSR   LBC35               ; PACK FPA0 AND STORE IT IN THE DESCRIPTOR POINTED TO BY X
F989  BD B3 57                   JSR   LB357               ; EVALUATE A VARIABLE; RETURN X POINTING TO THE VARIABLE DESCRIPTOR
F98C  9F 3B                      STX   VARDES              ; SAVE THE VARIABLE DESCRIPTOR
F98E  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR A COMMA
F991  4F                         CLRA                      ; ZERO OUT THE MS BYTE OF ACCD
F992  D6 CD                      LDB   VCD                 ; GET THE X COORDINATE OF THE CURSOR POSITION
F994  BD B4 F4                   JSR   GIVABF              ; CONVERT ACCD TO FLOATING POINT
F997  9E 3B                      LDX   VARDES              ; POINT X TO THE VARIABLE DESCRIPTOR
F999  6D 1F                      TST   $-01,X              ; CHECK THE SECOND CHARACTER OF THE VARIABLE NAME
F99B  10 2B B7 B2                LBMI  TMERROR             ; TYPE MISMATCH ERROR IF STRING VARIABLE
F99F  BD BC 35                   JSR   LBC35               ; PACK FPA0 AND STORE IT IN THE DESCRIPTOR POINTED TO BY X
F9A2  BD B3 57                   JSR   LB357               ; EVALUATE A VARIABLE; RETURN X POINTING TO THE VARIABLE DESCRIPTOR
F9A5  9F 3B                      STX   VARDES              ; SAVE THE VARIABLE DESCRIPTOR
F9A7  4F                         CLRA                      ; ZERO OUT THE MS BYTE OF ACCD
F9A8  D6 CE                      LDB   VCD+1               ; GET THE Y COORDINATE OF THE CURSOR POSITION
F9AA  BD B4 F4                   JSR   GIVABF              ; CONVERT ACCD TO FLOATING POINT
F9AD  9E 3B                      LDX   VARDES              ; POINT X TO THE VARIABLE DESCRIPTOR
F9AF  6D 1F                      TST   $-01,X              ; CHECK THE SECOND CHARACTER OF THE VARIABLE NAME
F9B1  10 2B B7 9C                LBMI  TMERROR             ; TYPE MISMATCH ERROR IF STRING VARIABLE
F9B5  BD BC 35                   JSR   LBC35               ; PACK FPA0 AND STORE IT IN THE DESCRIPTOR POINTED TO BY X
F9B8  39                         RTS

* ATTR
F9B9  BD B7 0B          ATTR     JSR   EVALEXPB            ; EVALUATE EXPRESSION, RETURN VALUE IN ACCB (CHARACTER COLOR)
F9BC  10 21 06 40                LBRN  RAMLINK             ; RAM HOOK
F9C0  C1 08                      CMPB  #$08                ; 8 CHARACTER COLORS MAXIMUM
F9C2  10 24 BA 84                LBCC  ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR IF CHARACTER COLOR > 8
F9C6  58                         ALSB
F9C7  58                         ALSB
F9C8  58                         ALSB                      ; SHIFT THE CHARACTER COLOR INTO BITS 3-6
F9C9  34 04                      PSHS  B                   ; SAVE THE SHIFTED COLOR ON THE STACK
F9CB  9D A5                      JSR   GETCCH              ; GET THE CURRENT INPUT CHARACTER
F9CD  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR A COMMA
F9D0  BD B7 0B                   JSR   EVALEXPB            ; EVALUATE EXPRESSION, RETURN VALUE IN ACCB (BACKGROUND COLOR)
F9D3  C1 08                      CMPB  #$08                ; 8 MAXIMUM BACKGROUND COLORS
F9D5  10 24 BA 71                LBCC  ILLFUNC             ; ILLEGAL FUNCTION CALL ERROR IF > 8
F9D9  EA E4                      ORB   ,S                  ; 'OR' IN THE CHARACTER COLOR
F9DB  32 61                      LEAS  $01,S               ; REMOVE TEMPORARY CHARACTER FROM STACK; ORB ,S+ ABOVE IS MORE EFFICIENT
F9DD  C4 3F                      ANDB  #3F                 ; MASK OFF BITS 6,7; THIS INSTRUCTION IS UNNECESSARY
F9DF  34 04                      PSHS  B                   ; SAVE THE CHARACTER AND BACKGROUND COLORS ON THE STACK
F9E1  9D A5                      JSR   GETCCH              ; GET THE CURRENT INPUT CHARACTER
F9E3  27 21             LF9E3    BEQ   LFA06               ; BRANCH IF END OF LINE
F9E5  BD B2 6D                   JSR   SYNCOMMA            ; SYNTAX CHECK FOR A COMMA
F9E8  81 42                      CMPA  #'B'                ; CHECK FOR THE BLINK ATTRIBUTE FLAG
F9EA  26 0A                      BNE   LF9F6               ; BRANCH IF NOR BLINK ATTRIBUTE FLAG
F9EC  35 04                      PULS  B
F9EE  CA 80                      ORB   #$80                ; SET BIT 7 WHICH IS THE BLINK ATTRIBUTE BIT
F9F0  34 04                      PSHS  B
F9F2  9D 9F                      JSR   GETNCH              ; GET A CHARACTER FROM BASIC'S INPUT LINE
F9F4  20 ED                      BRA   LF9E3               ; KEEP CHECKING FOR ATTRIBUTE FLAGS
F9F6  81 55             LF9F6    CMPA  #'U'                ; CHECK FOR THE UNDERLINE ATTRIBUTE
F9F8  10 26 BA 4E                LBNE  ILLFUNC             ; ILLEGAL FUNCION CALL ERROR
F9FC  35 04                      PULS  B
F9FE  CA 40                      ORB   #$40                ; SET BIT 6 WHICH IS THE UNDERLINE ATTRIBUTE BIT
FA00  34 04                      PSHS  B
FA02  9D 9F                      JSR   GETNCH              ; GET A CHARACTER FROM BASIC'S INPUT LINE
FA04  20 DD                      BRA   LF9E3               ; KEEP CHECKING FOR ATTRIBUTE FLAGS
FA06  35 04             LFA06    PULS  B                   ; GET THE NEW ATTRIBUTE BYTE FROM THE STACK
FA08  F7 FE 08                   STB   H.CRSATT            ; AND SAVE IT AS THE CURSOR ATTRIBUTES
FA0B  39                         RTS


FA0C                    LFA0C    RMB   1012                ; UNUSED BYTES
FE00                    LFE00    RMB   256                 ; $FE00 SECONDARY VECTORS AREA
FF00                    LFF00    RMB   256                 ; $FF00 INPUT/OUTPUT AREA
