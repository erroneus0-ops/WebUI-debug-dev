; Color BASIC 1.2 -- $A5F6-$A77B
; Source: Color BASIC Unravelled series (Spectral Associates; rev. W. Zydhek), via Unravelled II.xls tab "CB 1.2"
; Object bytes verified against genuine ROM image (SHA-1 0f14dc46c647510eb0b7bd3f53e33da07907d04f). See ../README.md for line format.
; Named entry points here: OPEN=$A5F6, GETBLK=$A70B

* OPEN
A5F6  BD 01 5E          OPEN     JSR   RVEC0               ; HOOK INTO RAM
A5F9  BD B1 56                   JSR   LB156               ; GET FILE STATUS (INPUT,OUTPUT)
A5FC  BD B6 A4                   JSR   LB6A4               ; GET FIRST BYTE OF STATUS STRING TO ACCB
A5FF  34 04                      PSHS  B                   ; SAVE IT ON STACK
A601  8D 9F                      BSR   LA5A2               ; CHECK FOR SYNTAX AND GET DEVICE NUMBER
A603  BD B2 6D                   JSR   LB26D               ; SYNTAX CHECK FOR COMMA, SYNTAX ERROR IF NOT
A606  8D BD                      BSR   LA5C5               ; GET FILE NAME
A608  96 6F                      LDA   DEVNUM              ; GET DEVICE NUMBER
A60A  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
A60C  35 04                      PULS  B                   ; GET STATUS AGAIN
A60E  C1 49                      CMPB  #'I                 ; IS IT INPUT MODE?
A610  27 12                      BEQ   LA624               ; YES
A612  C1 4F                      CMPB  #'O                 ; IS IT OUTPUT MODE?
A614  27 42                      BEQ   LA658               ; YES

* IF IT ISN'T INPUT OR OUTPUT, BAD FILE MODE
A616  C6 2A             LA616    LDB   #21*2               ; ERROR # 21 'BAD FILE MODE'
A618  8C                         FCB   SKP2                ; SKIP TWO BYTES
A619  C6 28             LA619    LDB   #20*2               ; ERROR # 20 'I/O ERROR
A61B  8C                         FCB   SPK2                ; SKIP TWO BYTES
A61C  C6 24             LA61C    LDB   #18*2               ; ERROR # 18 'FILE ALREADY OPEN'
A61E  8C                         FCB   SKP2                ; SKIP TWO BYTES
A61F  C6 26             LA61F    LDB   #19*2               ; ERROR # 19 'DEVICE NUMBER ERROR'
A621  7E AC 46                   JMP   LAC46               ; JUMP TO ERROR HANDLER
*
A624  4C                LA624    INCA                      ; DEVICE NUMBER SET TO TAPE?
A625  2B EF                      BMI   LA616               ; 'BAD FILE MODE' IF DEVNUM = NEG BUT NOT CASSETTE
A627  26 2E                      BNE   LA657               ; RETURN IF DEVNUM WAS SET TO SCREEN OR DISK
* SET TO TAPE
A629  8D 1D                      BSR   LA648               ; GET HEADER BLOCK
A62B  B6 01 E3                   LDA   CASBUF+9            ; GET ASCII FLAG
A62E  B4 01 E4                   ANDA  CASBUF+10           ; 'AND' IT WITH FILE MODE
A631  27 E3                      BEQ   LA616               ; 'BAD FILE MODE' - CRUNCHED FlLE OR MACH LANG
A633  0C 78                      INC   FILSTA              ; OPEN FILE FOR INPUT
A635  BD A7 01          LA635    JSR   LA701               ; START TAPE, READ A BLOCK
A638  26 DF                      BNE   LA619               ; 'I/O ERROR'
A63A  0D 7C                      TST   BLKTYP              ; CHECK BLOCK NUMBER
A63C  27 DB                      BEQ   LA619               ; 'I/O ERROR' IF HEADER BLOCK
A63E  2B 17                      BMI   LA657               ; BRANCH IF THIS IS THE LAST BLOCK
A640  96 7D                      LDA   BLKLEN              ; CHAR COUNT
A642  27 F1                      BEQ   LA635               ; READ ANOTHER BLOCK IF NULL BLOCK
A644  97 79             LA644    STA   CINCTR              ; STORE IN TEMP CHARACTER COUNTER
A646  20 0A                      BRA   LA652               ; RESET BUFFER POINTER

* SEARCH FOR FILE NAME IN CNMBUF
A648  0D 78             LA648    TST   FILSTA              ; IS THE FILE OPEN?
A64A  26 D0                      BNE   LA61C               ; YES- 'FILE ALREADY OPEN'
A64C  8D 33                      BSR   LA681               ; SEARCH FOR CORRECT FILE NAME
A64E  26 C9                      BNE   LA619               ; 'I/O ERROR'
A650  0F 79             LA650    CLR   CINCTR              ; CLEAR CHARACTER COUNTER
A652  8E 01 DA          LA652    LDX   #CASBUF             ; CASSETTE INPUT BUFFER ADDRESS
A655  9F 7A                      STX   CINPTR              ; RESET IT
A657  39                LA657    RTS

* WRITE OUT THE HEADER BLOCK

** CASBUF FILE NAME
** CASBUF+8 FILE TYPE
** CASBUF+9 ASCII FLAG
** CASBUF+10 FILE MODE
** CASBUF+11,12 TRANSFER ADDRESS
** CASBUF+13,14 START ADDRESS

* ENTER HERE FOR DATA FILES W/DEVICE NUMBER IN ACCA
A658  4C                LA658    INCA                      ; CHECK FOR CASSETTE DEVICE NUMBER
A659  26 FC                      BNE   LA657               ; RETURN IF DEVICE NUMBER WASN'T TAPE
A65B  4C                         INCA                      ; MAKE FILE TYPE = 1
* ENTER HERE FOR ASCII FILES
A65C  8E FF FF          LA65C    LDX   #$FFFF              ; SET ASCII FLAG AND MODE = $FF
A65F  0D 78             LA65F    TST   FILSTA              ; IS FILE OPEN?
A661  26 B9                      BNE   LA61C               ; YES- 'FILE ALREADY OPEN'
A663  CE 01 DA                   LDU   #CASBUF             ; CASSETTE INPUT BUFFER
A666  DF 7E                      STU   CBUFAD              ; STORE IN STARTING ADDRESS
A668  A7 48                      STA   8,U                 ; FILE TYPE IN CASBUF+8
A66A  AF 49                      STX   9,U                 ; ASCII FLAG & MODE IN CASBUF+9, CASBUF+10
*         CASBUF     +8      +9    +10
*                                           TYPE   ASCII   MODE
* BASIC CRUNCHED                00      00     00
* BASIC ASCII                          00      FF     FF
* DATA                                    01      FF     FF
* MACHINE LANGUAGE        02      00     00
* MACHINE BLK LOAD         02      00     FF

A66C  8E 01 D2                   LDX   #CFNBUF+1           ; POINT X TO FILE NAME BUFFER
A66F  BD A5 98                   JSR   LA598               ; MOVE 8 BYTES FROM (X) TO (U)
A672  0F 7C                      CLR   BLKTYP              ; ZERO BLOCK NUMBER
A674  86 0F                      LDA   #15                 ; 15 BYTES IN THE HEADER BLOCK
A676  97 7D                      STA   BLKLEN              ; CHAR COUNT
A678  BD A7 E5                   JSR   LA7E5               ; GO WRITE ONE BLOCK
A67B  86 02                      LDA   #2                  ; OUTPUT FILE
A67D  97 78                      STA   FILSTA              ; STORE IN FILE MODE
A67F  20 CF                      BRA   LA650               ; RESET POINTERS

* SEARCH FOR CORRECT CASSETTE FILE NAME
A681  8E 01 DA          LA681    LDX   #CASBUF             ; CASSETTE BUFFER
A684  9F 7E                      STX   CBUFAD              ; LOAD ADDRESS POINTER
A686  96 68             LA686    LDA   CURLIN              ; GET CURRENT LINE NUMBER MSB (CURLIN)
A688  4C                         INCA                      ; IN DIRECT MODE IF ACCA = $FF
A689  26 0B                      BNE   LA696               ; BRANCH IF NOT DIRECT MODE
A68B  BD A9 28                   JSR   LA928               ; CLEAR SCREEN
A68E  9E 88                      LDX   CURPOS              ; CURRENT SCREEN CHAR POSITION
A690  C6 53                      LDB   #'S                 ; 'S' MEANS SEARCHING
A692  E7 81                      STB   ,X++                ; PUT AN 'S' ON THE SCREEN
A694  9F 88                      STX   CURPOS              ; STORE NEW CURSOR LOCATION
A696  8D 69             LA696    BSR   LA701               ; READ ONE BLOCK FROM TAPE
A698  DA 7C                      ORB   BLKTYP              ; 'OR' ERROR FLAG WITH BLOCK NUMBER
A69A  26 34                      BNE   LA6D0               ; BRANCH IF NOT BLOCK ZERO OR ERROR
A69C  8E 01 DA                   LDX   #CASBUF             ; POINT TO CASSETTE BUFFER
A69F  CE 01 D2                   LDU   #CFNBUF+1           ; POINT TO DESIRED NAME
A6A2  C6 08                      LDB   #8                  ; EIGHT CHARACTERS MAX IN NAME
A6A4  6F E2                      CLR   ,-S                 ; ZERO A BYTE ON THE STACK
A6A6  A6 80             LA6A6    LDA   ,X+                 ; GET CHAR FROM CASSETTE BLOCK
A6A8  10 9E 68                   LDY   CURLIN              ; GET CURLIN
A6AB  31 21                      LEAY  1,Y                 ; DIRECT MODE?
A6AD  26 05                      BNE   LA6B4               ; FALL THROUGH IF DIRECT MODE
A6AF  0F 6F                      CLR   DEVNUM              ; SET DEVICE NUMBER TO SCREEN
A6B1  BD A2 82                   JSR   PUTCHR              ; OUTPUT A CHAR
A6B4  A0 C0             LA6B4    SUBA  ,U+                 ; SUBTRACT A CHAR FROM DESIRED NAME
; NON-ZERO RESULT IF NO MATCH
A6B6  AA E4                      ORA   ,S                  ; 'OR' WITH TOP OF STACK, RESULT WILL BE NON-ZERO IF MISMATCH
A6B8  A7 E4                      STA   ,S                  ; SAVE IT
A6BA  5A                         DECB                      ; DONE ALL 8 CHARACTERS?
A6BB  26 E9                      BNE   LA6A6               ; NO
A6BD  A6 E0                      LDA   ,S+                 ; SEE IF ALL CHARS WERE OK
A6BF  27 0A                      BEQ   LA6CB               ; BRANCH IF GOOD COMPARE
A6C1  6D 57                      TST   -9,U                ; CHECK THE NUMBER OF CHARACTERS IN THE CLOAD STATEMENT
A6C3  27 06                      BEQ   LA6CB               ; IF NO NAME SPECIFIED, ANY FILE IS OK
* DIDN'T FIND THE RIGHT FILE IF HERE
A6C5  8D 0A                      BSR   LA6D1               ; LOOK FOR FILE
A6C7  26 07                      BNE   LA6D0               ; RETURN IF ERROR
A6C9  20 BB                      BRA   LA686               ; GO LOOK SOME MORE
A6CB  86 46             LA6CB    LDA   #'F                 ; *
A6CD  8D 29                      BSR   LA6F8               ; * PUT 'F' ON THE SCREEN IF DIRECT MODE
A6CF  4F                         CLRA                      ; SET ZERO FLAG TO INDICATE NO ERRORS
A6D0  39                LA6D0    RTS
A6D1  7D 01 E4          LA6D1    TST   CASBUF+10           ; CHECK FILE MODE
A6D4  26 09                      BNE   LA6DF               ; BRANCH IF ASCII OR DATA
A6D6  BD A7 7C                   JSR   CASON               ; TURN ON TAPE DECK
A6D9  8D 30             LA6D9    BSR   GETBLK              ; LOAD A BLOCK FROM TAPE
A6DB  8D 08                      BSR   LA6E5               ; CHECK FOR ERROR OR LAST BLOCK
A6DD  20 FA                      BRA   LA6D9               ; KEEP GOING
A6DF  8D 20             LA6DF    BSR   LA701               ; READ ONE BLOCK FROM TAPE
A6E1  8D 02                      BSR   LA6E5               ; CHECK FOR ERROR OR LAST BLOCK
A6E3  20 FA                      BRA   LA6DF               ; KEEP READING BLOCKS
A6E5  26 06             LA6E5    BNE   LA6ED               ; GOT AN ERROR ON READING IN BLOCK
A6E7  96 7C                      LDA   BLKTYP              ; GET BLOCK NUMBER
A6E9  40                         NEGA                      ; CHECK FOR LAST BLOCK
A6EA  2B 14                      BMI   LA700               ; RETURN IF NOT AN END OF PROGRAM BLOCK
A6EC  4A                         DECA                      ; IF BLOCK NUMBER WAS $FF, ACCA IS NOW ZERO - THIS WILL
* CAUSE CLOAD TO IGNORE ERRORS IN THE
* BLOCKS WHICH IT IS SKIPPING WHILE
* LOOKING FOR THE CORRECT FILE NAME.
A6ED  97 81             LA6ED    STA   CSRERR              ; STORE ACCA TO ERROR FLAG
A6EF  32 62                      LEAS  2,S                 ; REMOVE RETURN ADDRESS FROM STACK
A6F1  20 12                      BRA   LA705               ; TURN OFF MOTOR
A6F3  B6 04 00          LA6F3    LDA   VIDRAM              ; GET FIRST CHAR ON SCREEN
A6F6  88 40                      EORA  #$40                ; REVERSE THE VIDEO
A6F8  D6 68             LA6F8    LDB   CURLIN              ; GET CURLIN MSB
A6FA  5C                         INCB                      ; CHECK FOR DIRECT MODE
A6FB  26 03                      BNE   LA700               ; BRANCH IF NOT DIRECT MODE
A6FD  B7 04 00                   STA   VIDRAM              ; PUT IT ON SCREEN
A700  39                LA700    RTS

* READ A BLOCK FROM CASSETTE
A701  8D 79             LA701    BSR   CASON               ; START TAPE, AND LOOK FOR A BUNCH OF $55 OR $AA BYTES
A703  8D 06                      BSR   GETBLK              ; READ A BLOCK
A705  BD A7 E9          LA705    JSR   LA7E9               ; TURN OFF MOTOR
A708  D6 81                      LDB   CSRERR              ; GET ERROR STATUS
A70A  39                         RTS
A70B  1A 50             GETBLK   ORCC  #$50                ; DISABLE IRQ,FIRQ
A70D  8D E4                      BSR   LA6F3               ; REVERSE VIDEO UPPER LEFT CHAR IF DIRECT MODE
A70F  9E 7E                      LDX   CBUFAD              ; GET LOAD ADDRESS
A711  4F                         CLRA                      ; RESET ACCA
A712  8D 41             LA712    BSR   LA755               ; READ A BIT FROM TAPE, RETURN IT IN CARRY FLAG
A714  46                         RORA                      ; PUT BIT IN MSB OF ACCA
A715  81 3C                      CMPA  #$3C                ; GET SYNC'ED ON $3C
A717  26 F9                      BNE   LA712               ; NOT SYNC'ED YET
A719  8D 2E                      BSR   LA749               ; GET BLOCK NUMBER
A71B  97 7C                      STA   BLKTYP              ; SAVE IT
A71D  8D 2A                      BSR   LA749               ; GET CHAR COUNT
A71F  97 7D                      STA   BLKLEN              ; SAVE IT
A721  9B 7C                      ADDA  BLKTYP              ; ACCUMULATE CHECKSUM
A723  97 80                      STA   CCKSUM              ; SAVE IT
A725  96 7D                      LDA   BLKLEN              ; GET BACK CHAR COUNT
A727  97 81                      STA   CSRERR              ; TEMP SAVE
A729  27 10                      BEQ   LA73B               ; NULL SET OF CHARACTERS
A72B  8D 1C             LA72B    BSR   LA749               ; GET BYTE FROM TAPE
A72D  A7 84                      STA   ,X                  ; FILL MEMORY WITH TAPE DATA
A72F  A1 80                      CMPA  ,X+                 ; SEE IF WE READ BACK SAME THING
A731  26 11                      BNE   LA744               ; BRANCH IF NOT PUTTING IT IN RAM
A733  9B 80                      ADDA  CCKSUM              ; ACCUMULATE CHECKSUM
A735  97 80                      STA   CCKSUM              ; TEMP STORE CHECKSUM
A737  0A 81                      DEC   CSRERR              ; DECR TEMP CHAR COUNT
A739  26 F0                      BNE   LA72B               ; GET ANOTHER CHARACTER
A73B  8D 0C             LA73B    BSR   LA749               ; GET CHECKSUM FROM TAPE
A73D  90 80                      SUBA  CCKSUM              ; COMPARE TO CALCULATED CHECKSUM
A73F  27 05                      BEQ   LA746               ; BRANCH IF OK
A741  86 01                      LDA   #1                  ; CHECKSUM ERROR FLAG
A743  8C                         FCB   SKP2                ; SKIP TWO BYTES
A744  86 02             LA744    LDA   #2                  ; NON-RAM ERROR FLAG
A746  97 81             LA746    STA   CSRERR              ; 1 IF CHECKSUM ERROR, 2 IF LOADING INTO NON-RAM
A748  39                         RTS

* GET A BYTE FROM TAPE
A749  86 08             LA749    LDA   #8                  ; 8 BITS/BYTE
A74B  97 82                      STA   CPULWD              ; TEMP COUNTER
A74D  8D 06             LA74D    BSR   LA755               ; READ A BIT FROM TAPE
A74F  46                         RORA                      ; PUT IT INTO ACCA
A750  0A 82                      DEC   CPULWD              ; GOT ALL 8 BITS
A752  26 F9                      BNE   LA74D               ; NO
A754  39                         RTS

* READ A BIT FROM THE TAPE
A755  8D 06             LA755    BSR   LA75D               ; GET THE TIME BETWEEN TRANSITIONS
A757  D6 83                      LDB   CPERTM              ; * GET PERIOD TIMER
A759  5A                         DECB                      ; *
A75A  D1 8F                      CMPB  CMPMID              ; CMPMID CONTAINS 18 INITIALLY, AND IS USED TO DETERMINE
* WHETHER THE BIT READ IS A ONE OR ZERO
* IF THE PERIOD TIMER IS < 18, THE BIT
* IS CONSIDERED TO BE A ONE, IF > 18, IT IS ZERO
A75C  39                         RTS

* MAIN TIMING LOOP
A75D  0F 83             LA75D    CLR   CPERTM              ; RESET PERIOD TIMER
A75F  0D 84                      TST   CBTPHA              ; CHECK TO SEE IF SYNC'ED ON THE HI-LO TRANSITION OR LO-HI
A761  26 10                      BNE   LA773               ; BRANCH ON HI-LO TRANSITION
* LO - HI TRANSITION
A763  8D 07             LA763    BSR   LA76C               ; READ CASSETTE INPUT BIT
A765  25 FC                      BCS   LA763               ; LOOP UNTIL IT IS LO
A767  8D 03             LA767    BSR   LA76C               ; READ CASSETTE INPUT DATA
A769  24 FC                      BCC   LA767               ; WAIT UNTIL IT GOES HI
A76B  39                         RTS

* READ CASSETTE INPUT BIT OF THE PIA
A76C  0C 83             LA76C    INC   CPERTM              ; INCREMENT PERIOD TIMER
A76E  F6 FF 20                   LDB   PIA1                ; GET CASSETTE INPUT BIT
A771  56                         RORB                      ; PUT CASSETTE BIT INTO THE CARRY FLAG
A772  39                         RTS

* WAIT FOR HI - LO TRANSITION
A773  8D F7             LA773    BSR   LA76C               ; READ CASSETTE INPUT DATA
A775  24 FC                      BCC   LA773               ; LOOP UNTIL IT IS HI
A777  8D F3             LA777    BSR   LA76C               ; READ CASSETTE INPUT
A779  25 FC                      BCS   LA777               ; LOOP UNTIL IT IS LO
A77B  39                         RTS
