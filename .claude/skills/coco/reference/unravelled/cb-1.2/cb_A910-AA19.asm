; Color BASIC 1.2 -- $A910-$AA19
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: CLS=$A910, SOUND=$A94B, AUDIO=$A990, BIRQSV=$A9B3, JOYSTK=$A9C6, GETJOY=$A9DE

* CLS
A910  BD 01 A0          CLS      JSR   RVEC22              ; HOOK INTO RAM
A913  27 13                      BEQ   LA928               ; BRANCH IF NO ARGUMENT
A915  BD B7 0B                   JSR   LB70B               ; CALCULATE ARGUMENT, RETURN VALUE IN ACCB
A918  C1 08                      CMPB  #8                  ; VALID ARGUMENT?
A91A  22 1B                      BHI   LA937               ; IF ARGUMENT >8, GO PRINT 'MICROSOFT'
A91C  5D                         TSTB                      ; SET FLAGS
A91D  27 06                      BEQ   LA925               ; COLOR 0
A91F  5A                         DECB                      ; ACCB NOW CONTAINS 0-7
A920  86 10                      LDA   #$10                ; EACH GRAPHIC BLOCK SEPARATED BY $10 FROM ONE ANOTHER
A922  3D                         MUL                       ; ACCB CONTAINS ONE OF 8 OFFSETS
A923  CA 0F                      ORB   #$0F                ; BITS 0-3 SET FOR SOLID COLOR GRAPHIC BLOCK
A925  CA 80             LA925    ORB   #$80                ; BIT 7 SET FOR GRAPHICS
A927  8C                         FCB   SKP2                ; SKIP TWO BYTES

* CLEAR SCREEN
A928  C6 60             LA928    LDB   #$60                ; BLANK
A92A  8E 04 00                   LDX   #VIDRAM             ; GET ADDR OF START OF SCREEN BUFFER
A92D  9F 88             LA92D    STX   CURPOS              ; SAVE IT IN CURPOS
A92F  E7 80             LA92F    STB   ,X+                 ; FILL SCREEN WITH CONTENTS OF ACCB
A931  8C 05 FF                   CMPX  #VIDRAM+511         ; END OF SCREEN?
A934  23 F9                      BLS   LA92F               ; NO
A936  39                         RTS
A937  8D EF             LA937    BSR   LA928               ; CLEAR SCREEN
A939  8E A1 65                   LDX   #LA166-1            ; *
A93C  7E B9 9C                   JMP   LB99C               ; * PRINT 'MICROSOFT'

A93F  BD B2 6D          LA93F    JSR   LB26D               ; SYNTAX CHECK FOR A COMMA
A942  BD B7 0B          LA942    JSR   LB70B               ; EVALUATE EXPRESSION, RETURN VALUE IN ACCB
A945  5D                         TSTB                      ; SET FLAGS
A946  26 3C                      BNE   LA984               ; RETURN IF NON ZERO
A948  7E B4 4A          LA948    JMP   LB44A               ; 'ILLEGAL FUNCTION CALL' IF ZERO

* SOUND
A94B  8D F5             SOUND    BSR   LA942               ; EVALUATE EXPRESSION (FREQUENCY)
A94D  D7 8C                      STB   SNDTON              ; SAVE IT
A94F  8D EE                      BSR   LA93F               ; EVALUATE EXPRESSION (SOUND LENGTH)
A951  86 04                      LDA   #4                  ; CONSTANT FACTOR
A953  3D                         MUL                       ; EXPAND LENGTH EXPRESSION
A954  DD 8D                      STD   SNDDUR              ; SAVE LENGTH OF SOUND
A956  B6 FF 03                   LDA   PIA0+3              ; GET CONTROL REGISTER OF PIA0, PORT B
A959  8A 01                      ORA   #1                  ; *
A95B  B7 FF 03                   STA   PIA0+3              ; * ENABLE 60 HZ INTERRUPT (PIA0 IRQ)
A95E  0F 08                      CLR   ARYDIS              ; CLEAR THE ARRAY DISABLE FLAG - FOR NO APPARENT REASON
A960  8D 40                      BSR   LA9A2               ; CONNECT D/A SOUND INPUT TO OUTPUT OF SOUND MUX
A962  8D 12                      BSR   LA976               ; TURN ON AUDIO - ENABLE SOUND MUX
A964  8D 1F             LA964    BSR   LA985               ; STORE 2.5 VOLTS TO D/A AND WAIT
A966  86 FE                      LDA   #$FE                ; DATA TO MAKE D/A OUT = 5 VOLTS
A968  8D 1D                      BSR   LA987               ; STORE IT TO D/A AND WAIT
A96A  8D 19                      BSR   LA985               ; STORE 2.5 VOLTS TO D/A AND WAIT
A96C  86 02                      LDA   #2                  ; DATA TO MAKE D/A OUT = 0 VOLTS
A96E  8D 17                      BSR   LA987               ; STORE IT TO D/A AND WAIT
A970  9E 8D                      LDX   SNDDUR              ; * IS SNDDUR = 0? - THE IRQ INTERRUPT SERVICING
* * ROUTINE WILL DECREMENT SNDDUR
A972  26 F0                      BNE   LA964               ; NOT DONE YET

* THESE ROUTINES WILL ENABLE/DISABLE THE ANALOG MUX
A974  4F                LA974    CLRA                      ; BIT 3 OF ACCA = 0, DISABLE ANALOG MUX
A975  8C                         FCB   SKP2                ; SKIP TWO BYTES
A976  86 08             LA976    LDA   #8                  ; BIT 3 OF ACCA = 1, ENABLE ANALOG MUX
A978  A7 E2                      STA   ,-S                 ; SAVE ACCA ON STACK
A97A  B6 FF 23                   LDA   PIA1+3              ; GET CONTROL REGISTER OF PIA1, PORT B
A97D  84 F7                      ANDA  #$F7                ; RESET BIT 3
A97F  AA E0                      ORA   ,S+                 ; OR IN BIT 3 OF ACCA (SAVED ON STACK)
A981  B7 FF 23                   STA   PIA1+3              ; SET/RESET CB2 OF U4
A984  39                LA984    RTS
A985  86 7E             LA985    LDA   #$7E                ; DATA VALUE TO MAKE D/A OUTPUT = 2.5 VOLTS
A987  B7 FF 20          LA987    STA   DA                  ; STORE IT IN D/A
A98A  96 8C                      LDA   SNDTON              ; GET FREQUENCY
A98C  4C                LA98C    INCA                      ; INCREMENT IT
A98D  26 FD                      BNE   LA98C               ; LOOP UNTIL DONE
A98F  39                         RTS

* AUDIO
A990  1F 89             AUDIO    TFR   A,B                 ; SAVE ON/OFF TOKEN IN ACCB
A992  9D 9F                      JSR   GETNCH              ; MOVE BASIC POINTER TO NEXT CHARACTER
A994  C1 AA                      CMPB  #$AA                ; 'OFF' TOKEN?
A996  27 DC                      BEQ   LA974               ; YES - TURN OFF ANALOG MUX
A998  C0 88                      SUBB  #$88                ; 'ON' TOKEN
A99A  BD A5 C9                   JSR   LA5C9               ; SYNTAX ERROR IF NOT 'OFF' OR 'ON'
A99D  5C                         INCB                      ; NOW ACCB = 1
A99E  8D 02                      BSR   LA9A2               ; ROUTE CASSETTE TO SOUND MULTIPLEXER
A9A0  20 D4                      BRA   LA976               ; ENABLE SOUND MULTIPLEXER

* THIS ROUTINE WILL TRANSFER BIT 0 OF ACCB TO SEL 1 OF
* THE ANALOG MULTIPLEXER AND BIT 1 OF ACCB TO SEL 2.
A9A2  CE FF 01          LA9A2    LDU   #PIA0+1             ; POINT U TO PIA0 CONTROL REG
A9A5  8D 00                      BSR   LA9A7               ; PROGRAM 1ST CONTROL REGISTER
A9A7  A6 C4             LA9A7    LDA   ,U                  ; GET PIA CONTROL REGISTER
A9A9  84 F7                      ANDA  #$F7                ; RESET CA2 (CB2) OUTPUT BIT
A9AB  57                         ASRB                      ; SHIFT ACCB BIT 0 TO CARRY FLAG
A9AC  24 02                      BCC   LA9B0               ; BRANCH IF CARRY = ZERO
A9AE  8A 08                      ORA   #$08                ; FORCE BIT 3=1; SET CA2(CB2)
A9B0  A7 C1             LA9B0    STA   ,U++                ; PUT IT BACK IN THE PIA CONTROL REGISTER
A9B2  39                         RTS

* IRQ SERVICE
A9B3  B6 FF 03          BIRQSV   LDA   PIA0+3              ; CHECK FOR 60HZ INTERRUPT
A9B6  2A 0D                      BPL   LA9C5               ; RETURN IF 63.5 MICROSECOND INTERRUPT
A9B8  B6 FF 02                   LDA   PIA0+2              ; RESET PIA0, PORT B INTERRUPT FLAG
A9BB  BE 00 8D                   LDX   >SNDDUR             ; GET INTERRUPT TIMER (SOUND COMMAND)
A9BE  27 05                      BEQ   LA9C5               ; RETURN IF TIMER = 0
A9C0  30 1F                      LEAX  -1,X                ; DECREMENT TIMER IF NOT = 0
A9C2  BF 00 8D                   STX   >SNDDUR             ; SAVE NEW TIMER VALUE
A9C5  3B                LA9C5    RTI                       ; RETURN FROM INTERRUPT

* JOYSTK
A9C6  BD B7 0E          JOYSTK   JSR   LB70E               ; EVALUATE JOYSTICK ARGUMENT
A9C9  C1 03                      CMPB  #3                  ; TWO JOYSTICKS MAXIMUM (HOR & VER FOR EACH)
A9CB  10 22 0A 7B                LBHI  LB44A               ; 'ILLEGAL FUNCTION CALL' IF >3
A9CF  5D                         TSTB                      ; SET FLAGS
A9D0  26 02                      BNE   LA9D4               ; GET NEW DATA ONLY IF JOYSTK(0)
A9D2  8D 0A                      BSR   GETJOY              ; GET NEW DATA FOR ALL JOYSTICKS
A9D4  8E 01 5A          LA9D4    LDX   #POTVAL             ; POINT X TO JOYSTICK DATA BUFFER
A9D7  D6 53                      LDB   FPA0+3              ; WHICH JOYSTICK DID YOU WANT?
A9D9  E6 85                      LDB   B,X                 ; PUT ITS DATA INTO ACCB
A9DB  7E B4 F3                   JMP   LB4F3               ; CONVERT ACCB INTO FLOATING POINT NUMBER
*
* JOYSTK DATA AT:
*     $15A      $15B      $15C      $15D
*     LEFT      LEFT      RIGHT     RIGHT
*     VERT      HORIZ     VERT      HORIZ

** THIS IS A 6 BIT SOFTWARE A/D CONVERSION ROUTINE
A9DE  8D 94             GETJOY   BSR   LA974               ; TURN OFF AUDIO
A9E0  8E 01 5E                   LDX   #POTVAL+4           ; POINT X TO JOYSTICK DATA BUFFER
A9E3  C6 03                      LDB   #3                  ; GET FOUR SETS OF DATA (4 JOYSTICKS)
A9E5  86 0A             LA9E5    LDA   #10                 ; 10 TRIES TO GET STABLE READING
A9E7  ED E3                      STD   ,--S                ; STORE JOYSTICK NUMBER AND TRY NUMBER ON THE STACK
A9E9  8D B7                      BSR   LA9A2               ; SET THE SELECT INPUTS ON ANALOG MULTIPLEXER
A9EB  CC 40 80          LA9EB    LDD   #$4080              ; ACCA IS A SHIFT COUNTER OF HOW MANY BITS TO CONVERT
* AND WIlL BE $40 (6 BITS) FOR THE COLOR
* COMPUTER. ACCB CONTAINS A VALUE EQUAL TO 1/2
* THE CURRENT TRIAL DIFFERENCE. INITIALLY =$80 (2.5 VOLTS).
A9EE  A7 E2             LA9EE    STA   ,-S                 ; TEMP STORE SHIFT COUNTER ON STACK
A9F0  CA 02                      ORB   #2                  ; KEEP RS 232 SERIAL OUT MARKING
A9F2  F7 FF 20                   STB   DA                  ; STORE IN D/A CONVERTER
A9F5  C8 02                      EORB  #2                  ; PUT R5232 OUTPUT BIT BACK TO ZERO
A9F7  B6 FF 00                   LDA   PIA0                ; HIGH BIT IS FROM COMPARATOR
A9FA  2B 03                      BMI   LA9FF               ; BRANCH IF COMPARATOR OUTPUT IS HIGH
A9FC  E0 E4                      SUBB  ,S                  ; SUBTRACT 1/2 THE CURRENT TRIAL DIFFERENCE
A9FE  8C                         FCB   SKP2                ; SKIP NEXT TWO BYTES
A9FF  EB E4             LA9FF    ADDB  ,S                  ; ADD 1/2 OF THE CURRENT TRIAL DIFFERENCE
AA01  A6 E0                      LDA   ,S+                 ; PULL SHIFT COUNTER OFF THE STACK
AA03  44                         LSRA                      ; SHIFT IT RIGHT ONCE
AA04  81 01                      CMPA  #1                  ; HAVE ALL THE SHIFTS BEEN DONE?
AA06  26 E6                      BNE   LA9EE               ; NO
AA08  54                         LSRB                      ; YES - THE DATA IS IN THE TOP 6 BYTES OF ACCB
AA09  54                         LSRB                      ; PUT IT INTO THE BOTTOM SIX
AA0A  E1 1F                      CMPB  -1,X                ; IS THIS VALUE EQUAL TO THE LAST TRY?
AA0C  27 04                      BEQ   LAA12               ; YES - GO SAVE THE VALUE
AA0E  6A E4                      DEC   ,S                  ; NO-DECREMENT TRIES COUNTER
AA10  26 D9                      BNE   LA9EB               ; BRANCH IF YOU HAVEN'T TRIED 10 TIMES
* IF YOU FALL THROUGH HERE YOU HAVE TRIED TO GET THE SAME READING
* 10 TIMES AND NEVER GOTTEN A MATCH. AS A RESULT YOU JUST FALL
* THROUGH AND USE THE LAST VALUE READ IN.
AA12  E7 82             LAA12    STB   ,-X                 ; SAVE THE DIGITIZED VALUE
AA14  EC E1                      LDD   ,S++                ; GET THE NUMBER OF THE JOYSTICK JUST DONE
AA16  5A                         DECB                      ; DECR JOYSTK NUMBER
AA17  2A CC                      BPL   LA9E5               ; BRANCH IF THE LAST ONE DONE WASN'T NUMBER 0
AA19  39                         RTS
