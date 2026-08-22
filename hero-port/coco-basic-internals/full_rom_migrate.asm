        ORG $7000
START   ORCC  #$50        ; disable IRQ+FIRQ -- critical: an interrupt firing
                           ; while we're briefly in RAM mode, before the
                           ; interrupt vectors near $FFF0-$FFFF have actually
                           ; been copied yet, would read garbage as its vector
                           ; and jump into invalid memory
        STS   REALS        ; save BASIC's real stack pointer first
LOOP1   LDS   CURPOS       ; S = current position -- this IS both source and dest
        STA   $FFDF        ; force ROM mode
        PULS  D,X,Y,U      ; read 8 bytes; S advances forward by 8
        STA   $FFDE        ; force RAM mode
        PSHS  D,X,Y,U      ; write same 8 bytes back; S returns to CURPOS's value exactly
        LDX   CURPOS       ; reload X from the SEPARATE tracker (untouched by the blast)
        LEAX  8,X          ; advance to next chunk
        STX   CURPOS       ; save new position
        CMPX  #ENDPOS
        BNE   LOOP1
        LDS   REALS        ; restore BASIC's real stack pointer
        ANDCC #$AF         ; re-enable IRQ+FIRQ
        RTS

REALS   FDB   0
CURPOS  FDB   $8000        ; start of ROM address space
ENDPOS  EQU   $FF00        ; PIA0 (real hardware I/O) starts here -- must NOT go past this
