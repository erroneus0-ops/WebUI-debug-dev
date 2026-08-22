        ORG $7000
START   STS   REALS       ; save BASIC's real stack pointer
        LDS   CURPOS      ; S = $8000, our test/copy address
        CLRA
        STA   $FFDF       ; force ROM mode (address-triggered, value irrelevant)
        PULS  D,X,Y,U     ; read 8 bytes from $8000 while it's genuine ROM
        STA   $FFDE       ; force RAM mode (address-triggered, value irrelevant)
        PSHS  D,X,Y,U     ; write those same 8 bytes back to $8000, now backed by RAM
        LDS   REALS       ; restore BASIC's real stack pointer
        RTS

REALS   FDB   0
CURPOS  FDB   $8000
