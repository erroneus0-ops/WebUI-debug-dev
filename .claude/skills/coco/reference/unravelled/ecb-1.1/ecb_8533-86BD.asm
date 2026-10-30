; Extended Color BASIC 1.1 -- $8533-$86BD
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "ECB 1.1"
; Object bytes verified against genuine ROM image (SHA-1 ad927fb4f30746d820cb8b860ebb585e7f095dea). See ../README.md for line format.
; Named entry points here: EDIT=$8533, TRON=$86A7, TROFF=$86A8, POS=$86AC

* EDIT
8533  BD 89 AE          EDIT     JSR   L89AE               ; GET LINE NUMBER FROM BASIC
8536  32 62                      LEAS  $02,S               ; PURGE RETURN ADDRESS OFF OF THE STACK
8538  86 01             L8538    LDA   #$01                ; 'LIST' FLAG
853A  97 D8                      STA   VD8                 ; SET FLAG TO LIST LINE
853C  BD AD 01                   JSR   LAD01               ; GO FIND THE LINE NUMBER IN PROGRAM
853F  10 25 29 8F                LBCS  LAED2               ; ERROR #7 'UNDEFINED LINE #'
8543  BD B7 C2                   JSR   LB7C2               ; GO UNCRUNCH LINE INTO BUFFER AT LINBUF+1
8546  1F 20                      TFR   Y,D                 ; PUT ABSOLUTE ADDRESS OF END OF LINE TO ACCD
8548  83 02 DE                   SUBD  #LINBUF+2           ; SUBTRACT OUT THE START OF LINE
854B  D7 D7                      STB   VD7                 ; SAVE LENGTH OF LINE
854D  DC 2B             L854D    LDD   BINVAL              ; GET THE HEX VALUE OF LINE NUMBER
854F  BD BD CC                   JSR   LBDCC               ; LIST THE LINE NUMBER ON THE SCREEN
8552  BD B9 AC                   JSR   LB9AC               ; PRINT A SPACE
8555  8E 02 DD                   LDX   #LINBUF+1           ; POINT X TO BUFFER
8558  D6 D8                      LDB   VD8                 ; * CHECK TO SEE IF LINE IS TO BE
855A  26 25                      BNE   L8581               ; * LISTED TO SCREEN - BRANCH IF IT IS
855C  5F                L855C    CLRB                      ; RESET DIGIT ACCUMULATOR - DEFAULT VALUE
855D  BD 86 87          L855D    JSR   L8687               ; GET KEY STROKE
8560  BD 90 AA                   JSR   L90AA               ; SET CARRY IF NOT NUMERIC
8563  25 0B                      BLO   L8570               ; BRANCH IF NOT NUMERIC
8565  80 30                      SUBA  #'0'                ; MASK OFF ASCII
8567  34 02                      PSHS  A                   ; SAVE IT ON STACK
8569  86 0A                      LDA   #10                 ; NUMBER BEING CONVERTED IS BASE 10
856B  3D                         MUL                       ; MULTIPLY ACCUMULATED VALUE BY BASE (10)
856C  EB E0                      ADDB  ,S+                 ; ADD DIGIT TO ACCUMULATED VALUE
856E  20 ED                      BRA   L855D               ; CHECK FOR ANOTHER DIGIT
8570  C0 01             L8570    SUBB  #$01                ; * REPEAT PARAMETER IN ACCB; IF IT
8572  C9 01                      ADCB  #$01                ; *IS 0, THEN MAKE IT '1'
8574  81 41                      CMPA  #'A'                ; ABORT?
8576  26 05                      BNE   L857D               ; NO
8578  BD B9 58                   JSR   LB958               ; PRINT CARRIAGE RETURN TO SCREEN
857B  20 BB                      BRA   L8538               ; RESTART EDIT PROCESS - CANCEL ALL CHANGES
857D  81 4C             L857D    CMPA  #'L'                ; LIST?
857F  26 0B                      BNE   L858C               ; NO
8581  8D 31             L8581    BSR   L85B4               ; LIST THE LINE
8583  0F D8                      CLR   VD8                 ; RESET THE LIST FLAG TO 'NO LIST'
8585  BD B9 58                   JSR   LB958               ; PRINT CARRIAGE RETURN
8588  20 C3                      BRA   L854D               ; GO INTERPRET ANOTHER EDIT COMMAND
858A  32 62             L858A    LEAS  $02,S               ; PURGE RETURN ADDRESS OFF OF THE STACK
858C  81 0D             L858C    CMPA  #CR                 ; ENTER KEY?
858E  26 0D                      BNE   L859D               ; NO
8590  8D 22                      BSR   L85B4               ; ECHO THE LINE TO THE SCREEN
8592  BD B9 58          L8592    JSR   LB958               ; PRINT CARRIAGE RETURN
8595  8E 02 DD                   LDX   #LINBUF+1           ; * RESET BASIC'S INPUT POINTER
8598  9F A6                      STX   CHARAD              ; * TO THE LINE INPUT BUFFER
859A  7E AC A8                   JMP   LACA8               ; GO PUT LINE BACK IN PROGRAM
859D  81 45             L859D    CMPA  #'E'                ; EXIT?
859F  27 F1                      BEQ   L8592               ; YES - SAME AS ENTER EXCEPT NO ECHO
85A1  81 51                      CMPA  #'Q'                ; QUIT?
85A3  26 06                      BNE   L85AB               ; NO
85A5  BD B9 58                   JSR   LB958               ; PRINT CARRIAGE RETURN TO SCREEN
85A8  7E AC 73                   JMP   LAC73               ; GO TO COMMAND LEVEL - MAKE NO CHANGES
85AB  8D 02             L85AB    BSR   L85AF               ; INTERPRET THE REMAINING COMMANDS AS SUBROUTINES
85AD  20 AD                      BRA   L855C               ; GO INTERPRET ANOTHER EDIT COMMAND
85AF  81 20             L85AF    CMPA  #SPACE              ; SPACE BAR?
85B1  26 10                      BNE   L85C3               ; NO
85B3  8C                L85B3    FCB   SKP2                ; SKIP TWO BYTES
* DISPLAY THE NEXT ACCB BYTES OF THE LINE IN THE BUFFER TO THE SCREEN
*
85B4  C6 F9             L85B4    LDB   #LBUFMX-1           ; 250 BYTES MAX IN BUFFER
85B6  A6 84             L85B6    LDA   ,X                  ; GET A CHARACTER FROM BUFFER
85B8  27 08                      BEQ   L85C2               ; EXIT IF IT'S A 0
85BA  BD A2 82                   JSR   LA282               ; SEND CHAR TO CONSOLE OUT
85BD  30 01                      LEAX  $01,X               ; MOVE POINTER UP ONE
85BF  5A                         DECB                      ; DECREMENT CHARACTER COUNTER
85C0  26 F4                      BNE   L85B6               ; LOOP IF NOT DONE
85C2  39                L85C2    RTS
85C3  81 44             L85C3    CMPA  #'D'                ; DELETE?
85C5  26 48                      BNE   L860F               ; NO
85C7  6D 84             L85C7    TST   ,X                  ; * CHECK FOR END OF LINE
85C9  27 F7                      BEQ   L85C2               ; * AND BRANCH IF SO
85CB  8D 04                      BSR   L85D1               ; REMOVE A CHARACTER
85CD  5A                         DECB                      ; DECREMENT REPEAT PARAMETER
85CE  26 F7                      BNE   L85C7               ; BRANCH IF NOT DONE
85D0  39                         RTS
* REMOVE ONE CHARACTER FROM BUFFER
85D1  0A D7             L85D1    DEC   VD7                 ; DECREMENT LENGTH OF BUFFER
85D3  31 1F                      LEAY  $-01,X              ; POINT Y TO ONE BEFORE CURRENT BUFFER POINTER
85D5  31 21             L85D5    LEAY  $01,Y               ; INCREMENT TEMPORARY BUFFER POINTER
85D7  A6 21                      LDA   $01,Y               ; GET NEXT CHARACTER
85D9  A7 A4                      STA   ,Y                  ; PUT IT IN CURRENT POSITION
85DB  26 F8                      BNE   L85D5               ; BRANCH IF NOT END OF LINE
85DD  39                         RTS
85DE  81 49             L85DE    CMPA  #'I'                ; INSERT?
85E0  27 13                      BEQ   L85F5               ; YES
85E2  81 58                      CMPA  #'X'                ; EXTEND?
85E4  27 0D                      BEQ   L85F3               ; YES
85E6  81 48                      CMPA  #'H'                ; HACK?
85E8  26 5C                      BNE   L8646               ; NO
85EA  6F 84                      CLR   ,X                  ; TURN CURRENT BUFFER POINTER INTO END OF LINE FLAG
85EC  1F 10                      TFR   X,D                 ; PUT CURRENT BUFFER POINTER IN ACCD
85EE  83 02 DE                   SUBD  #LINBUF+2           ; SUBTRACT INITIAL POINTER POSITION
85F1  D7 D7                      STB   VD7                 ; SAVE NEW BUFFER LENGTH
85F3  8D BF             L85F3    BSR   L85B4               ; DISPLAY THE LINE ON THE SCREEN
85F5  BD 86 87          L85F5    JSR   L8687               ; GET A KEYSTROKE
85F8  81 0D                      CMPA  #CR                 ; ENTER KEY?
85FA  27 8E                      BEQ   L858A               ; YES - INTERPRET ANOTHER COMMAND - PRINT LINE
85FC  81 1B                      CMPA  #ESC                ; ESCAPE?
85FE  27 25                      BEQ   L8625               ; YES - RETURN TO COMMAND LEVEL - DON'T PRINT LINE
8600  81 08                      CMPA  #BS                 ; BACK SPACE?
8602  26 22                      BNE   L8626               ; NO
8604  8C 02 DD                   CMPX  #LINBUF+1           ; COMPARE POINTER TO START OF BUFFER
8607  27 EC                      BEQ   L85F5               ; DO NOT ALLOW BS IF AT START
8609  8D 45                      BSR   L8650               ; MOVE POINTER BACK ONE, BS TO SCREEN
860B  8D C4                      BSR   L85D1               ; REMOVE ONE CHARACTER FROM BUFFER
860D  20 E6                      BRA   L85F5               ; GET INSERT SUB COMMAND
860F  81 43             L860F    CMPA  #'C'                ; CHANGE?
8611  26 CB                      BNE   L85DE               ; NO
8613  6D 84             L8613    TST   ,X                  ; CHECK CURRENT BUFFER CHARACTER
8615  27 0E                      BEQ   L8625               ; BRANCH IF END OF LINE
8617  BD 86 87                   JSR   L8687               ; GET A KEYSTROKE
861A  25 02                      BLO   L861E               ; BRANCH IF LEGITIMATE KEY
861C  20 F5                      BRA   L8613               ; TRY AGAIN IF ILLEGAL KEY
861E  A7 80             L861E    STA   ,X+                 ; INSERT NEW CHARACTER INTO BUFFER
8620  8D 37                      BSR   L8659               ; SEND NEW CHARACTER TO SCREEN
8622  5A                         DECB                      ; DECREMENT REPEAT PARAMETER
8623  26 EE                      BNE   L8613               ; BRANCH IF NOT DONE
8625  39                L8625    RTS
8626  D6 D7             L8626    LDB   VD7                 ; GET LENGTH OF LINE
8628  C1 F9                      CMPB  #LBUFMX-1           ; COMPARE TO MAXIMUM LENGTH
862A  26 02                      BNE   L862E               ; BRANCH IF NOT AT MAXIMUM
862C  20 C7                      BRA   L85F5               ; IGNORE INPUT IF LINE AT MAXIMUM LENGTH
862E  34 10             L862E    PSHS  X                   ; SAVE CURRENT BUFFER POINTER
8630  6D 80             L8630    TST   ,X+                 ; * SCAN THE LINE UNTIL END OF
8632  26 FC                      BNE   L8630               ; * LINE (0) IS FOUND
8634  E6 82             L8634    LDB   ,-X                 ; DECR TEMP LINE POINTER AND GET A CHARACTER
8636  E7 01                      STB   $01,X               ; PUT CHARACTER BACK DOWN ONE SPOT
8638  AC E4                      CMPX  ,S                  ; HAVE WE REACHED STARTING POINT?
863A  26 F8                      BNE   L8634               ; NO - KEEP GOING
863C  32 62                      LEAS  $02,S               ; PURGE BUFFER POINTER FROM STACK
863E  A7 80                      STA   ,X+                 ; INSERT NEW CHARACTER INTO THE LINE
8640  8D 17                      BSR   L8659               ; SEND A CHARACTER TO CONSOLE OUT
8642  0C D7                      INC   VD7                 ; ADD ONE TO BUFFER LENGTH
8644  20 AF                      BRA   L85F5               ; GET INSERT SUB COMMAND
8646  81 08             L8646    CMPA  #BS                 ; BACKSPACE?
8648  26 12                      BNE   L865C               ; NO
864A  8D 04             L864A    BSR   L8650               ; MOVE POINTER BACK 1, SEND BS TO SCREEN
864C  5A                         DECB                      ; DECREMENT REPEAT PARAMETER
864D  26 FB                      BNE   L864A               ; LOOP UNTIL DONE
864F  39                         RTS
8650  8C 02 DD          L8650    CMPX  #LINBUF+1           ; COMPARE POINTER TO START OF BUFFER
8653  27 D0                      BEQ   L8625               ; DO NOT ALLOW BS IF AT START
8655  30 1F                      LEAX  $-01,X              ; MOVE POINTER BACK ONE
8657  86 08                      LDA   #BS                 ; BACK SPACE
8659  7E A2 82          L8659    JMP   LA282               ; SEND TO CONSOLE OUT
865C  81 4B             L865C    CMPA  #'K'                ; KILL?
865E  27 05                      BEQ   L8665               ; YES
8660  80 53                      SUBA  #'S'                ; SEARCH?
8662  27 01                      BEQ   L8665               ; YES
8664  39                         RTS
8665  34 02             L8665    PSHS  A                   ; SAVE KILL/SEARCH FLAG ON STACK
8667  8D 1E                      BSR   L8687               ; * GET A KEYSTROKE (TARGET CHARACTER)
8669  34 02                      PSHS  A                   ; * AND SAVE IT ON STACK
866B  A6 84             L866B    LDA   ,X                  ; = GET CURRENT BUFFER CHARACTER
866D  27 16                      BEQ   L8685               ; = AND RETURN IF END OF LINE
866F  6D 61                      TST   $01,S               ; CHECK KILL/SEARCH FLAG
8671  26 06                      BNE   L8679               ; BRANCH IF KILL
8673  8D E4                      BSR   L8659               ; SEND A CHARACTER TO CONSOLE OUT
8675  30 01                      LEAX  $01,X               ; INCREMENT BUFFER POINTER
8677  20 03                      BRA   L867C               ; CHECK NEXT INPUT CHARACTER
8679  BD 85 D1          L8679    JSR   L85D1               ; REMOVE ONE CHARACTER FROM BUFFER
867C  A6 84             L867C    LDA   ,X                  ; GET CURRENT INPUT CHARACTER
867E  A1 E4                      CMPA  ,S                  ; COMPARE TO TARGET CHARACTER
8680  26 E9                      BNE   L866B               ; BRANCH IF NO MATCH
8682  5A                         DECB                      ; DECREMENT REPEAT PARAMETER
8683  26 E6                      BNE   L866B               ; BRANCH IF NOT DONE
8685  35 A0             L8685    PULS  Y,PC                ; THE Y PULL WILL CLEAN UP THE STACK FOR THE 2 PSHS A
*
* GET A KEYSTRKE
8687  BD A1 71          L8687    JSR   LA171               ; CALL CONSOLE IN : DEV NBR=SCREEN
868A  81 7F                      CMPA  #$7F                ; GRAPHIC CHARACTER?
868C  24 F9                      BCC   L8687               ; YES - GET ANOTHER CHAR
868E  81 5F                      CMPA  #$5F                ; SHIFT UP ARROW (QUIT INSERT)
8690  26 02                      BNE   L8694               ; NO
8692  86 1B                      LDA   #ESC                ; REPLACE W/ESCAPE CODE
8694  81 0D             L8694    CMPA  #CR                 ; ENTER KEY
8696  27 0E                      BEQ   L86A6               ; YES
8698  81 1B                      CMPA  #ESC                ; ESCAPE?
869A  27 0A                      BEQ   L86A6               ; YES
869C  81 08                      CMPA  #BS                 ; BACKSPACE?
869E  27 06                      BEQ   L86A6               ; YES
86A0  81 20                      CMPA  #SPACE              ; SPACE
86A2  25 E3                      BLO   L8687               ; GET ANOTHER CHAR IF CONTROL CHAR
86A4  1A 01                      ORCC  #$01                ; SET CARRY
86A6  39                L86A6    RTS

* TRON
86A7  86                TRON     FCB   SKP1LD              ; SKIP ONE BYTE AND LDA #$4F

* TROFF
86A8  4F                TROFF    CLRA                      ; TROFF FLAG
86A9  97 AF                      STA   TRCFLG              ; TRON/TROFF FLAG:0=TROFF, <> 0=TRON
86AB  39                         RTS

* POS
86AC  96 6F             POS      LDA   DEVNUM              ; GET DEVICE NUMBER
86AE  34 02                      PSHS  A                   ; SAVE IT ON STACK
86B0  BD A5 AE                   JSR   LA5AE               ; GET DEVICE NUMBER
86B3  BD A4 06                   JSR   LA406               ; FILE STATUS CHECK
86B6  BD A3 5F                   JSR   LA35F               ; SET UP TAB FIELD WIDTH
86B9  D6 6C                      LDB   DEVPOS              ; GET PRINT POSITION
86BB  7E A5 E4                   JMP   LA5E4               ; CONVERT PRINT POSITION TO FLOATING POINT
