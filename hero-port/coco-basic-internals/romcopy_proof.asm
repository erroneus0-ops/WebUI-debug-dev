* ROM-to-RAM single-chunk proof (Demo 3), redesigned 2026-10-30.
* Copies the 8 bytes at $8000 from ROM into the RAM underneath with a
* stack blast, then -- while still in all-RAM mode -- reads the RAM copy
* back into RAMCPY and checks that RAM there is genuinely writable, then
* returns to ROM mode before RTS so BASIC (still running from ROM) is safe.
* Refuses to run on a 32K machine (see the 64K check below).
* $FFDE selects ROM, $FFDF selects all-RAM (SAM TY bit; even=clear, odd=set).
        ORG $7000
START   ORCC  #$50         ; no interrupts while ROM is switched off
* 64K check: on a 32K machine, all-RAM mode makes $8000 an alias of $0000,
* so a "copy" would overwrite BASIC's direct page. Detect that and refuse.
        STA   $FFDF        ; all-RAM mode
        LDA   $0000
        COMA
        STA   $8000        ; on 32K this lands on $0000
        CMPA  $0000
        BNE   IS64K        ; $0000 unchanged: real RAM at $8000
        COMA
        STA   $0000        ; 32K: put $0000 back, report, and quit
        LDB   #2
        STB   STICKS
        BRA   DONE
IS64K   STA   $FFDE        ; back to ROM mode for the copy
        STS   REALS        ; save BASIC's stack pointer
        LDS   #$8000       ; S = source AND destination
        STA   $FFDE        ; force ROM mode
        PULS  D,X,Y,U      ; read 8 bytes of ROM; S advances by 8
        STA   $FFDF        ; force all-RAM mode
        PSHS  D,X,Y,U      ; write them to the RAM underneath; S back to $8000
        LDS   REALS        ; restore the real stack (in RAM below $8000: safe)
        LDX   #$8000       ; still in all-RAM mode: copy RAM $8000-$8007
        LDU   #RAMCPY      ; out to RAMCPY so BASIC can compare later
        LDB   #8
COPY    LDA   ,X+
        STA   ,U+
        DECB
        BNE   COPY
        LDA   $8000        ; writability test: change a byte...
        INCA
        STA   $8000
        CMPA  $8000        ; ...did it stick?
        BNE   NOSTICK
        LDB   #1
        STB   STICKS
NOSTICK DECA               ; put the original value back
        STA   $8000
DONE    STA   $FFDE        ; back to ROM mode before returning to BASIC
        ANDCC #$AF         ; interrupts back on
        RTS
REALS   FDB   0
STICKS  FCB   0            ; 0 = not writable, 1 = copied and writable, 2 = 32K machine, refused
RAMCPY  RMB   8            ; RAM copy of $8000-$8007, read in all-RAM mode
