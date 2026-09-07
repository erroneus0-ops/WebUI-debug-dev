; Sprite Name            : SAUCER_ONE
; Source PNG Width       : 24 
; Sprite Width in pixels : 48 
; Sprite Height in pixels: 40 
; # of Colours           :9
; # of Animation Frames  : 1 
; Required GMODE         : 7 
; Each PNG pixel occupies one complete two-subpixel semigraphics colour cell
SAUCER_ONE_Draw:
        FDB     SAUCER_ONE_0_0      ; Address to draw semigraphics sprite
        FDB     SAUCER_ONE_0_1      ; Address to draw semigraphics sprite
; Restore the background behind the sprite VSYNC 1
Restore_SAUCER_ONE_1:
        LEAY    3072,X              ; Point at the top left edge of the screen 1 sprite location
SAUCER_ONE__2:
; 000 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 001 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 002 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 003 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 004 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 005 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 006 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 007 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 008 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 009 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 010 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 011 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 012 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 013 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 014 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 015 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 016 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 017 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 018 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 019 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 020 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 021 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 022 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 023 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 024 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 025 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 026 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 027 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 028 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 029 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 030 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 031 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 032 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 033 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 034 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 035 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 036 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 037 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 038 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
; 039 111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
        LDB     #32                 ; Amount to move down the screen to the next row
; Row 0 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 1 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 2 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 3 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 4 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 5 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 6 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 7 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 8 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 9 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 10 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 11 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 12 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 13 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 14 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 15 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 16 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 17 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 18 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 19 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 20 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 21 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 22 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 23 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 24 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 25 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 26 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 27 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 28 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 29 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 30 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 31 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 32 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 33 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 34 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 35 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 36 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 37 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 38 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        ABX                         ; Move down a row
        LEAY    32,Y                ; Move down a row on the scrollable screen
; Row 39 
        LDU     ,X                  ; read the sprite data on screen 0
        STU     ,Y                  ; write the sprite data on screen 1
        LDU     2,X                 ; read the sprite data on screen 0
        STU     2,Y                 ; write the sprite data on screen 1
        LDU     4,X                 ; read the sprite data on screen 0
        STU     4,Y                 ; write the sprite data on screen 1
        LDU     6,X                 ; read the sprite data on screen 0
        STU     6,Y                 ; write the sprite data on screen 1
        LDU     8,X                 ; read the sprite data on screen 0
        STU     8,Y                 ; write the sprite data on screen 1
        LDU     10,X                ; read the sprite data on screen 0
        STU     10,Y                ; write the sprite data on screen 1
        LDU     12,X                ; read the sprite data on screen 0
        STU     12,Y                ; write the sprite data on screen 1
        LDU     14,X                ; read the sprite data on screen 0
        STU     14,Y                ; write the sprite data on screen 1
        LDU     16,X                ; read the sprite data on screen 0
        STU     16,Y                ; write the sprite data on screen 1
        LDU     18,X                ; read the sprite data on screen 0
        STU     18,Y                ; write the sprite data on screen 1
        LDU     20,X                ; read the sprite data on screen 0
        STU     20,Y                ; write the sprite data on screen 1
        LDU     22,X                ; read the sprite data on screen 0
        STU     22,Y                ; write the sprite data on screen 1
        LDA     24,X                ; read the sprite data on screen 0
        STA     24,Y                ; write the sprite data on screen 1
        RTS                         ; Done drawing the sprite, Return

; Restore the background behind the sprite VSYNC 0
Restore_SAUCER_ONE_0:
        PSHS    DP                  ; Save DP
        STS     @SaveSHere+2        ; Backup the stack pointer's value at the end of the backup routine (self mod)
        LDS     #SAUCER_ONE_BackupStart+32    ; Set S pointer to the end of the last row of the backup buffer + 32 extra space for stack during F/IRQ
        LEAU    1273,X              ; Point at the bottom, right edge of the sprite backup location
; Restoring row 39 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 38 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 37 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 36 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 35 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 34 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 33 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 32 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 31 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 30 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 29 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 28 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 27 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 26 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 25 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 24 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 23 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 22 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 21 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 20 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 19 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 18 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 17 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 16 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 15 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 14 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 13 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 12 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 11 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 10 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 9 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 8 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 7 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 6 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 5 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 4 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 3 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 2 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 1 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        LEAU    -7,U                ; Move to the correct position to write data on screen
; Restoring row 0 
        PULS    D,X                 ; Get Data to restore
        PSHU    D,X                 ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
        PULS    D,DP,X,Y            ; Get Data to restore
        PSHU    D,DP,X,Y            ; Write a Data to the screen
@SaveSHere
        LDS     #$FFFF              ; Self mod restore stack pointer
        PULS    DP,PC               ; Restore DP & Return

; Backup Sprite data for SAUCER_ONE
; Enter with X pointing at the memory location on screen to backup the data behind the sprite
; Sprite Width is: 25 Bytes to backup
; Height is: 40 Rows
SAUCER_ONE_BackupStart:
        RMB     25*40+32            ; Reserve space for sprite background, plus a little extra for the stack (If F/IRQ happens)
SAUCER_ONE_BackupEnd:
Backup_SAUCER_ONE:
        PSHS    DP                  ; Save Condition Codes & DP
        STS     @SaveSHere+2        ; Backup the stack pointer's value at the end of the backup routine (self mod)
        LDS     #SAUCER_ONE_BackupEnd    ; Set S pointer to the end of the backup buffer
        LEAU    ,X                  ; U = X
; Backup row 0 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 1 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 2 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 3 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 4 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 5 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 6 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 7 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 8 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 9 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 10 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 11 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 12 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 13 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 14 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 15 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 16 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 17 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 18 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 19 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 20 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 21 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 22 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 23 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 24 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 25 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 26 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 27 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 28 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 29 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 30 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 31 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 32 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 33 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 34 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 35 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 36 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 37 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 38 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
        LEAU    32-25,U             ; Move down to the start of the next row to copy
; Backup row 39 
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,DP,X,Y            ; Get seven bytes from the screen
        PSHS    D,DP,X,Y            ; Save seven bytes from the screen
        PULU    D,X                 ; Get four bytes from the screen
        PSHS    D,X                 ; Save four bytes from the screen
@SaveSHere
        LDS     #$FFFF              ; Self mod restore stack pointer
        PULS    DP,PC               ; Restore DP & Return

; Frame Number: 0  pixel shift: 0 
SAUCER_ONE_0_0:
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$BF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        RTS                         ; Done drawing the sprite

; Frame Number: 0  pixel shift: 1 
SAUCER_ONE_0_1:
        LDA     #$B5                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$B5                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$BF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$BA                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     24,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     24,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     24,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     24,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     24,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     24,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     24,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     ,X                  ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     1,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     2,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     3,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     21,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     22,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     23,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     24,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        LEAX    32,X                ; Next semigraphics row
        LDA     #$C5                ; Semigraphics cell
        STA     4,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     5,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     6,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     7,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     8,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     9,X                 ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     10,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     11,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     12,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     13,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     14,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     15,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     16,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     17,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     18,X                ; Draw two-pixel cell
        LDA     #$CF                ; Semigraphics cell
        STA     19,X                ; Draw two-pixel cell
        LDA     #$CA                ; Semigraphics cell
        STA     20,X                ; Draw two-pixel cell
        RTS                         ; Done drawing the sprite

