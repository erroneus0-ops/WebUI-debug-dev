; ================================================================
; STRTEST_CART.ASM -- Cartridge ROM variant, ORG $C000
;
; Same test as STRTEST.ASM, but built as an 8K cartridge ROM image
; rather than a DECB-loadable .BIN file.
;
; On real hardware, a cartridge with pin 8 tied to pin 7 generates
; a CART* interrupt on power-up/reset that jumps the CPU to $C000.
; This code prints its test string, then RTS -- handing control
; back to whatever called it (BASIC's own startup), the same way
; disk11.rom patches its hooks and returns rather than taking over
; completely (as a game cartridge like Dungeons of Daggorath does).
;
; Screen result:
;   Row 7, col 10: HELLO
;
; Assemble:
;   python3 cocotools.py asm STRTEST_CART.ASM -o STRTEST_CART.RAW
;   python3 cocotools.py makerom STRTEST_CART.RAW STRTEST_CART.ROM
;
; XRoar cart profile (passive, no autostart):
;   -cart-type rom -cart-rom STRTEST_CART.ROM -cart-autorun no
; ================================================================

; -- ROM Entry Points ---------------------------------------------
STRINOUT EQU    $B99C           ; print string: X = ptr to length byte + chars
CLRSCR  EQU     $A928           ; clear text screen

; -- RAM Variables ------------------------------------------------
CURPOS  EQU     $88             ; cursor position: 16-bit address

; -- Screen Layout ------------------------------------------------
SCREEN  EQU     $0400
COLS    EQU     32

HELLO_POS EQU  SCREEN+(7*COLS)+10   ; row 7, col 10

; ================================================================
; MAIN -- entry point for cartridge autostart (CART* IRQ -> $C000)
; ================================================================

        ORG     $C000

Start
        JSR     CLRSCR          ; clear screen

        LDD     #HELLO_POS      ; position cursor at row 7, col 10
        STD     <CURPOS

        LDX     #HelloStr       ; X = pointer to length byte
        JSR     >STRINOUT       ; print it

        RTS                     ; return to caller (BASIC startup)

; ================================================================
; STRING DATA
; length byte + characters + null terminator ($00)
; STRINOUT scans to $00, not the length byte
; ================================================================
HelloStr FCB    5               ; length = 5
         FCC    "HELLO"         ; characters
         FCB    0               ; null terminator

        END     Start
