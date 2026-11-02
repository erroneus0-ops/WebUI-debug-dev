        ORG $7000
START   STS   REALS        ; save BASIC's real stack pointer first
LOOP1   LDS   CURPOS       ; S = current position -- this IS both source and dest
        STA   $FFDF        ; force ROM mode
        PULS  D,X,Y,U      ; read 8 bytes; S advances forward by 8; X now holds DATA, not position!
        STA   $FFDE        ; force RAM mode
        PSHS  D,X,Y,U      ; write same 8 bytes back; S returns to CURPOS's value exactly
        LDX   CURPOS       ; reload X from the SEPARATE tracker (untouched by the blast)
        LEAX  8,X          ; advance to next chunk
        STX   CURPOS       ; save new position
        CMPX  #ENDPOS
        BNE   LOOP1
        LDS   REALS        ; restore BASIC's real stack pointer
        RTS

REALS   FDB   0
CURPOS  FDB   $7100
ENDPOS  EQU   $7118        ; test range: 3 chunks of 8 bytes = 24 bytes, $7100 to $7118

        ORG $7100
SRCDATA FCB   $01,$02,$03,$04,$05,$06,$07,$08
        FCB   $11,$12,$13,$14,$15,$16,$17,$18
        FCB   $21,$22,$23,$24,$25,$26,$27,$28
