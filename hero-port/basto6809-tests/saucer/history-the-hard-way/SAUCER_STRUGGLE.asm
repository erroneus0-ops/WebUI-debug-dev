; Automatically calculated low-memory layout
NOTEXT_LAYOUT       EQU      0        ; 1 means the normal $0400-$05FF text page is not reserved
MEMORY_LAYOUT_BASE  EQU     $600
SDC_CHAIN_BASE      EQU     $600
DISK_CHAIN_BASE     EQU     $600
CHAIN_LOADERS_END   EQU     $600       ; First byte after resident loaders
CHAIN_SHARED_START  EQU     $600
CHAIN_SHARED_SIZE   EQU     $0
CHAIN_SHARED_END    EQU     $600       ; Exclusive end address
GRAPHICS_PAGE_START EQU     $600
PROGRAM_SAFE_START  EQU     $1E00

        ORG     $1E00         ; Program code starts here
        SETDP   $1E           ; Direct page is setup here
CoCoHardware    RMB     1     ; CoCoHardware Desriptor byte
; Bit 0 is the Computer Type, 0 = CoCo 1 or CoCo 2, 1 = CoCo 3
; Bit 7 is the CPU type,      0 = 6809, 1 = 6309
Seed1           RMB     1     ; Random number seed location
Seed2           RMB     1     ; Random number seed location
Seed3           RMB     1     ; Used by Random number generator
Seed4           RMB     1     ; Used by Random number generator
_Var_Timer      RMB     2     ; TIMER value
StartClearHere:
; Temporary Numbers:
_Var_PF00    RMB     2
_Var_PF01    RMB     2
_Var_PF02    RMB     2
_Var_PF03    RMB     2
_Var_PF04    RMB     2
_Var_PF05    RMB     2
_Var_PF06    RMB     2
_Var_PF07    RMB     2
_Var_PF08    RMB     2
_Var_PF09    RMB     2
_Var_PF10    RMB     2
Temp1           RMB     1     ; Temporary byte used for many routines
Temp2           RMB     1     ; Temporary byte used for many routines
Temp3           RMB     1     ; Temporary byte used for many routines
Temp4           RMB     1     ; Temporary byte used for many routines
Denominator     RMB     2     ; Denominator, used in division
Numerator       RMB     2     ; Numerator, used in division
DATAPointer     RMB     2     ; Variable that points to the current DATA location
SwapTypes       RMB     8     ; Temp bytes for Numeric conversions
; Numeric Variables Used: 4 
_Var_SY    RMB      2     Type of variable is: Integer
_Var_VY    RMB      2     Type of variable is: Integer
_Var_SX    RMB      2     Type of variable is: Integer
_Var_DOMEX    RMB      2     Type of variable is: Integer
SoundTone       RMB     1     ; SOUND Tone value
SoundDuration   RMB     2     ; SOUND Command duration value
CASFLG          RMB     1     ; Case flag for keyboard output $FF=UPPER (normal), 0=LOWER
OriginalIRQ     RMB     3     ; We save the original branch and location of the IRQ here, restored before we exit
EndClearHere:
PLAYFIELD   EQU     0                              
Scrolling   EQU     0                              
VideoRamBlock           FCB     %00000000       ; Set default to 0 Meg to 0.5 Meg location                              
VerticalPosition        FDB     $0000           ; Offset                              
HorizontalPosition      FCB     %00000000       ; Bit 7 set = Horizontal scrolling enabled                              
; Sound and Timer 60hz IRQ                               
BASIC_IRQ:                              
        LDA     $FF03         ; CHECK FOR 60HZ INTERRUPT
        BPL     Not60Hz       ; RETURN IF 63.5 MICROSECOND INTERRUPT
        LDA     $FF02         ; RESET PIA0, PORT B INTERRUPT FLAG
        LDX     SoundDuration ; Get the new Sound duration value
        BEQ     >             ; Done if Sound duration is zero
        LEAX    -1,X          ; Decrement Sound duration
        STX     SoundDuration ; Save the new Sound duration value
!       INC     _Var_Timer+1  ; Increment the LSB of the Timer Value
        BNE     Not60Hz       ; Skip ahead if not zero
        INC     _Var_Timer    ; Increment the MSB of the Timer Value
Not60Hz RTI                   ; RETURN FROM INTERRUPT
ClearHere2nd:
_StrVar_PF00    RMB     256     ; Temp String Variable
_StrVar_PF01    RMB     256     ; Temp String Variable
_StrVar_IFRight    RMB     256     ; Temp String Variable for IF Compares
; String Variables Used: 0 
; Numeric Arrays Used: 0 
; String Arrays Used: 0 
EndClearHere2nd:
; General Commands Used: 19 
; '
; DIM
; AS
; INTEGER
; SPRITE_LOAD
; GMODE
; GCLS
; SCREEN
; GCOPY
; SPRITE
; LOCATE
; BACKUP
; SHOW
; WAIT
; VBL
; ERASE
; IF
; THEN
; GOTO
; Numeric Commands Used: 0 
; String Commands Used: 0 
; Section of necessary included code:
; Adding the Compiled Sprites and pointers...
GmodeBytesPerRow EQU     32        ; # of bytes per graphics row, used by the sprite rendering code                              
ScreenSize       EQU     3072        ; Size of a graphics screen                              
PixelsMaxX       EQU     63        ; Screen width Max from 0 to this value                              
NumberOfColours  EQU     9        ; Number of Colours on this screen                              
SemiGraphics     EQU     1         ; Two horizontal pixels share each semigraphics byte                              
Artifacting      EQU     0         ; Not using Artifact colours                              
        INCLUDE     ./ARC_BOTTOM.asm
        INCLUDE     ./ARC_TOP.asm
        INCLUDE     ./DOME_ORIGINAL.asm
SpriteDrawTable:                              
        FDB     ARC_BOTTOM_Draw   ; Points to the Sprite Drawing Table (in the compiled sprite.asm file)
        FDB     ARC_TOP_Draw  ; Points to the Sprite Drawing Table (in the compiled sprite.asm file)
        FDB     DOME_ORIGINAL_Draw   ; Points to the Sprite Drawing Table (in the compiled sprite.asm file)
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
        FDB     $0000         ; No sprite loaded in this slot
SpriteBackupTable:                              
        FDB     Backup_ARC_BOTTOM   ; Address of the Make Backup code
        FDB     Backup_ARC_TOP   ; Address of the Make Backup code
        FDB     Backup_DOME_ORIGINAL   ; Address of the Make Backup code
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
        FDB     $0000         ; No Sprite for this slot
SpriteRestoreTable:                              
        FDB     Restore_ARC_BOTTOM_0   ; Address of the restore code Buffer 0
        FDB     Restore_ARC_BOTTOM_1   ; Address of the restore code Buffer 1
        FDB     Restore_ARC_TOP_0   ; Address of the restore code Buffer 0
        FDB     Restore_ARC_TOP_1   ; Address of the restore code Buffer 1
        FDB     Restore_DOME_ORIGINAL_0   ; Address of the restore code Buffer 0
        FDB     Restore_DOME_ORIGINAL_1   ; Address of the restore code Buffer 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        FDB     $0000         ; No Sprite for this slot 0
        FDB     $0000         ; No Sprite for this slot 1
        INCLUDE     ./Basic_Includes/GraphicCommands/GraphicVariables.asm
        INCLUDE     ./Basic_Includes/GraphicCommands/SG12/SG12_Main.asm
        INCLUDE     ./Basic_Includes/GraphicCommands/SpriteHandler.asm
        INCLUDE     ./Basic_Includes/Math_Integer16.asm
        INCLUDE     ./Basic_Includes/Equates.asm
        INCLUDE     ./Basic_Includes/Print.asm
        INCLUDE     ./Basic_Includes/PrintA.asm
        INCLUDE     ./Basic_Includes/Print_Serial.asm
        INCLUDE     ./Basic_Includes/Math_Variables.asm
        INCLUDE     ./Basic_Includes/CPUSpeed.asm
        INCLUDE     ./Basic_Includes/StringCommands.asm
        INCLUDE     ./Basic_Includes/Random.asm
        INCLUDE     ./Basic_Includes/Math_Fast_Floating_Point.asm
                              
                              
* Main Program
START:
        PSHS    CC,D,DP,X,Y,U ; Save the original BASIC Register values
        STS     RestoreStack+2   ; save the original BASIC stack pointer value (try to Return at the end of the program) (self modify code)
        LDS     #$0400        ; Set up the stack pointer
        ORCC    #$50          ; Turn off the interrupts
        LDA     #$1E          
        TFR     A,DP          ; Setup the Direct page to use our variable location
        TST     $FF02         ; Reset the VSYNC flag
!       ADDD    #$0001        ; Increment the counter
        TST     $FF03         ; Test for new Vsync
        BPL     <             ; If bit 7 is not set (Vsync hasn't happened yet) keep looping
        STD     >Seed3        ; Save 16 bit random seed, seed1 & 2 will use the timer
* Enable 6 Bit DAC output                              
        LDA     $FF23         ; * PIA1_Byte_3_IRQ_Ct_Snd * $FF23 GET PIA
        ORA     #%00001000    ; * SET 6-BIT SOUND ENABLE
        STA     $FF23         ; * PIA1_Byte_3_IRQ_Ct_Snd * $FF23 STORE
        JMP     SkipClear     ; On startup skip ahead and do a BSR to this section to clear the variables, as CLEAR will use this code
ClearVariables:                              
        LDX     #StartClearHere   ; Set the start address of the variables that will be cleared to zero when the program starts
        CLRA                  ; Clear Accumulator A
!       STA     ,X+           ; Clear the variable space, move pointer forward
        CMPX    #EndClearHere ; Compare the current address to the end of the variables that will be cleared to zero when the program starts
        BNE     <             ; Loop until all cleared
        LDX     #ClearHere2nd ; Set the start address of the variables that will be cleared to zero when the program starts
        CLRA                  ; Clear Accumulator A
!       STA     ,X+           ; Clear the variable space, move pointer forward
        CMPX    #EndClearHere2nd   ; Compare the current address to the end of the variables that will be cleared to zero when the program starts
        BNE     <             ; Loop until all cleared
        LDD     #DataStart    ; Get the Address where DATA starts
        STD     DATAPointer   ; Save it in the DATAPointer variable
        RTS                   ; Return from clearing the variables
SkipClear:                              
        JSR     ClearVariables   ; Go clear the all the variables
        LDA     #$FF          
        STA     CASFLG        ; set the case flag to $FF = Normal uppercase
        LDD     >$0112        ; Get the Extended BASIC's TIMER value
        STD     _Var_Timer    ; Use Basic's Timer as a starting point for the TIMER value, just in case someone uses it for Randomness
        STD     Seed1         ; Save TIMER value as the Random number seed value
* Let's detect the CPU type:
        LDX     #$8000        ; X = $8000
        TFR     X,A           ; If it's 6809 then A will equal $00, if it's a 6309 then A will now equal $80
* Let's detect the CoCo version:
        LDX     $FFFE         ; Get the RESET location
        CMPX    #$8C1B        ; Check if it's a CoCo 3
        BNE     SaveCoCo1     ; Setup IRQ, using CoCo 1 IRQ Jump location
        ORA     #%00000001    ; If it's CoCo 3 then we set bit 0 of the CoCoHardware Desriptor byte
        LDX     #$FEF7        ; X = Address for the COCO 3 IRQ JMP
        LDY     #$FEFD        ; Y = Address for the COCO 3 NMI JMP
        BRA     >             ; Skip ahead
SaveCoCo1                              
        LDX     #$010C        ; X = Address for the COCO 1 IRQ JMP
        LDY     #$0109        ; Y = Address for the COCO 1 NMI JMP
!       STA     CoCoHardware  ; Save the CoCoHardware Desriptor byte
        LDU     #OriginalIRQ  ; U=Address of the IRQ
        LDA     ,X            ; A = Branch Instruction
        STA     ,U            ; Save Branch Instruction
        LDD     1,X           ; D = Address
        STD     1,U           ; Backup the Address of the IRQ
        CLRB                  ; B=0, make the CPU max speed as default
        JSR     SetCPUSpeedB  ; Save max speed and set the CPU to Max speed it can handle
        LDB     #$7E          ; JMP instruction
        LDA     #$3B          ; RTI instruction
        STA     ,Y            ; Save RTI Instruction instead of NMI IRQ JMP
        STB     ,X            ; A = JMP Instruction
        LDU     #BASIC_IRQ    ; U=Address of our IRQ
        STU     1,X           ; U=Address of the IRQ
        LDA     #$3B          ; RTI instruction
        STA     $010F         ; Save instruction for the FIRQ CoCo1
* This is where we enable the IRQ                              
        ANDCC   #%11101111    ; = %11101111 this will Enable the IRQ to start
; *** User's Program code starts here ***                              
; '  SAUCER_STRUGGLE.BAS -- the original , over-literal 3-sprite attempt 
; '  at "flying saucer with a dome, top arc, bottom arc" -- before the 
; '  user clarified they meant ONE sprite with a color-changing region. 
; '  Preserved here as a labeled historical artifact , not a live demo. 
; '  This is the version that failed:compilesto$1E42-$C99F,wellpast 
; '  the real (now understood) LOADM size ceiling of ~23569 bytes -- this 
; '  file alone is ~40KB. At the time , the failure was misdiagnosed as an 
; '  address-range ($C000+) problem ; it was always just total size. 
; DIM SY AS INTEGER ,VY AS INTEGER 
; DIM SX AS INTEGER ,DOMEX AS INTEGER 
; SPRITE_LOAD "ARC_BOTTOM.asm",0
; SPRITE_LOAD "ARC_TOP.asm",1
; SPRITE_LOAD "DOME_ORIGINAL.asm",2,2
; GMODE 7,1
        LDB     #1            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        STB     GModePage     ; Save the screen Page #
        CLRA                  ; Get the screen Page #
        LDB     GModePage     ; Get the screen Page #
        BEQ     >             ; If first page then skip calc where to set the graphics page viewer
        LDX     #$0C00        ; X = the screen size
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; 16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits
        PULS    D             ; Get the low 16 bit result in D, fix the stack
!       ADDD    #$0600        ; D = Screen Page + Screen start location
@UpdateScreenStart                      
        STD     BEGGRP        ; Update the Screen starting location

; GMODE 7,0
        LDB     #0            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        STB     GModePage     ; Save the screen Page #
        CLRA                  ; Get the screen Page #
        LDB     GModePage     ; Get the screen Page #
        BEQ     >             ; If first page then skip calc where to set the graphics page viewer
        LDX     #$0C00        ; X = the screen size
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; 16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits
        PULS    D             ; Get the low 16 bit result in D, fix the stack
!       ADDD    #$0600        ; D = Screen Page + Screen start location
@UpdateScreenStart                      
        STD     BEGGRP        ; Update the Screen starting location

; GCLS 0
        LDB     #0            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        JSR     GCLS_SG12     ; Go colour the screen with the colour in B
; SCREEN 1,0
        LDB     $FF02         ; Reset Vsync flag
!       LDB     $FF03         ; See if Vsync has occurred yet
        BPL     <             ; If not then keep looping, until the Vsync occurs
        LDB     #1            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        PSHS    B             ; Save Screen Mode # on the stack
        LDB     #0            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        TSTB                  ; Test B
        BEQ     >             ; IF B = 0, use B as is
        LDB     #%00001000    ; ELSE make B = 8
!       STB     CSSVAL        ; Save the CSSVAL for setting the VDG CSS settings
        PULS    B             ; Get the Screen Mode off the stack
        TSTB                  ; Test B
        BNE     @DoGraphicMode   ; Skip ahead if graphics mode requested
        LDX     #$0400        ; Text screen starts here
        STX     BEGGRP        ; Update the Screen starting location
        LDA     #$0F          ; $0F Back to Text Mode for the CoCo 3
        STA     $FF9C         ; Neccesary for CoCo 3 GIME to use this mode
        LDA     #Internal_Alphanumeric   ; A = Text mode requested
        BRA     >             
@DoGraphicMode:                      
        LDA     #9            ; Use 2 scanlines per row for the $0C00 SG12 layout
        STA     $FF9C         ; Set the CoCo 3 GIME legacy row height
        CLRA                  ; D=B
        LDB     GModePage     ; Get the screen Page #
        BEQ     @Skip1        ; If first page skip ahead, else calc where to set the graphics page viewer
        LDX     #$C00         ; X = the screen size
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; 16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits
        PULS    D             ; Get the low 16 bit result in D, fix the stack
@Skip1  ADDD    #$600         ; D = Screen Page + relocated screen start location
@UpdateScreenStart                      
        STD     BEGGRP        ; Update the Screen starting location
        LDA     #Semi_graphic_12   ; A = Graphic mode requested
!       ORA     CSSVAL        ; Add in the colour select value into A
        JSR     SetGraphicModeA   ; Go setup the mode
        LDA     BEGGRP        ; Update the Screen starting location
        LSRA                  ; Divide by 2 - 512 bytes per start location
        JSR     SetGraphicsStartA   ; Go set the address of the screen
@Done                         

; GCOPY 0,1
        LDB     #0            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        PSHS    B             ; Save the Source Graphics Page # on the stack
        LDB     #1            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        CLRA                  ; Clear MSB
        LDX     #$C00         ; Get the Size of a graphics screen
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; 16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits
        LEAU    $600,X        ; U = Destination screen location
        CLRA                  ; Clear MSB
        LDB     2,S           ; Get the Source Graphics Page #
        LDX     #$C00         ; Get the Size of a graphics screen
        PSHS    D,X           ; Save the two 16 bit WORDS on the stack, to be multiplied
        JSR     MUL16         ; 16 bit multiply ,S * 2,S D = high 16 bits of the result, X and ,S = low 16 bits
        LEAX    $600,X        ; X = Source screen location
        LEAS    5,S           ; Fix the stack
        LDD     #$C00         ; Get the Size of a graphics screen
        LSRA                  ; Logical Shift Right
        RORB                  ; D=D/2, two bytes copied at a time
        TFR     D,Y           ; Save the # of words to copy in Y
!       LDD     ,X++          ; Get a word from the source graphics screen
        STD     ,U++          ; Save the word to the destination graphics screen
        LEAY    -1,Y          ; Decrement the word counter
        BNE     <             ; If not zero yet then keep copying
; SX =4
        LDD     #$0004        ; D is a 16 bit integer from -32768 to 32767 (signed Integer) % format
;        PSHS    D             ; Save D on the stack
;        PULS    D             ; Get value off the stack, fix the stack
        STD     _Var_SX       ; Save Numeric variable
; DOMEX =20
        LDD     #$0014        ; D is a 16 bit integer from -32768 to 32767 (signed Integer) % format
;        PSHS    D             ; Save D on the stack
;        PULS    D             ; Get value off the stack, fix the stack
        STD     _Var_DOMEX    ; Save Numeric variable
; SY =52
        LDD     #$0034        ; D is a 16 bit integer from -32768 to 32767 (signed Integer) % format
;        PSHS    D             ; Save D on the stack
;        PULS    D             ; Get value off the stack, fix the stack
        STD     _Var_SY       ; Save Numeric variable
; VY =1
        LDD     #$0001        ; D is a 16 bit integer from -32768 to 32767 (signed Integer) % format
;        PSHS    D             ; Save D on the stack
;        PULS    D             ; Get value off the stack, fix the stack
        STD     _Var_VY       ; Save Numeric variable
_LMainLoop
; SPRITE LOCATE 0,SX ,SY 
        LDB     #0            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        PSHS    B             ; Save the sprite #
        LDD     _Var_SX       ; Get the value of the variable
;        PSHS    D             ; Save the value on the stack
;        PULS    D             ; Get value in D and Fix the stack
        PSHS    D             ; Save the x co-ordinate
        LDD     _Var_SY       ; Get the value of the variable
;        PSHS    D             ; Save the value on the stack
;        PULS    D             ; Get value in D and Fix the stack
        PSHS    D             ; Save the y co-ordinate
        JSR     SpriteLocate  ; Change the screen location of the sprite
        LEAS    5,S           ; Fix the Stack
; SPRITE BACKUP 0
        LDB     #0            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        JSR     BackupSpriteB ; Jump to code to Backup Sprite B
; SPRITE SHOW 0,0
        LDB     #0            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        PSHS    B             ; Save the Sprite #
        LDB     #0            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        PSHS    B             ; Save the frame #
        JSR     ShowSpriteFrame   ; Jump to code to change the sprite frame #
        LEAS    2,S           ; Fix the Stack
; SPRITE LOCATE 1,SX ,SY -32
        LDB     #1            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        PSHS    B             ; Save the sprite #
        LDD     _Var_SX       ; Get the value of the variable
;        PSHS    D             ; Save the value on the stack
;        PULS    D             ; Get value in D and Fix the stack
        PSHS    D             ; Save the x co-ordinate
        LDD     _Var_SY       ; Get the value of the variable
        PSHS    D             ; Save the value on the stack
        LDB     #32           ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
        PSHS    B             ; Save B on the stack
; Doing Subtraction                      
        LDB     ,S            ; Get the right 8 bit value
        CLRA                  ; Clear MSB
        STD     ,-S           ; Store 16 bit version of the right value on the stack
        LDD     2,S           ; Get the left 16 bit value
        SUBD    ,S++          ; D = left 16 bit value - right 16 bit value, fix the stack
        STD     ,S            ; Save the new 16 bit value
        PULS    D             ; Get value in D and Fix the stack
        PSHS    D             ; Save the y co-ordinate
        JSR     SpriteLocate  ; Change the screen location of the sprite
        LEAS    5,S           ; Fix the Stack
; SPRITE BACKUP 1
        LDB     #1            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        JSR     BackupSpriteB ; Jump to code to Backup Sprite B
; SPRITE SHOW 1,0
        LDB     #1            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        PSHS    B             ; Save the Sprite #
        LDB     #0            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        PSHS    B             ; Save the frame #
        JSR     ShowSpriteFrame   ; Jump to code to change the sprite frame #
        LEAS    2,S           ; Fix the Stack
; SPRITE LOCATE 2,DOMEX ,SY -52
        LDB     #2            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        PSHS    B             ; Save the sprite #
        LDD     _Var_DOMEX    ; Get the value of the variable
;        PSHS    D             ; Save the value on the stack
;        PULS    D             ; Get value in D and Fix the stack
        PSHS    D             ; Save the x co-ordinate
        LDD     _Var_SY       ; Get the value of the variable
        PSHS    D             ; Save the value on the stack
        LDB     #52           ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
        PSHS    B             ; Save B on the stack
; Doing Subtraction                      
        LDB     ,S            ; Get the right 8 bit value
        CLRA                  ; Clear MSB
        STD     ,-S           ; Store 16 bit version of the right value on the stack
        LDD     2,S           ; Get the left 16 bit value
        SUBD    ,S++          ; D = left 16 bit value - right 16 bit value, fix the stack
        STD     ,S            ; Save the new 16 bit value
        PULS    D             ; Get value in D and Fix the stack
        PSHS    D             ; Save the y co-ordinate
        JSR     SpriteLocate  ; Change the screen location of the sprite
        LEAS    5,S           ; Fix the Stack
; SPRITE BACKUP 2
        LDB     #2            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        JSR     BackupSpriteB ; Jump to code to Backup Sprite B
; SPRITE SHOW 2,0
        LDB     #2            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        PSHS    B             ; Save the Sprite #
        LDB     #0            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        PSHS    B             ; Save the frame #
        JSR     ShowSpriteFrame   ; Jump to code to change the sprite frame #
        LEAS    2,S           ; Fix the Stack
; WAIT VBL 
        JSR     DoWaitVBL     ; Wait for Vertical Blank then update the sprites
; SPRITE ERASE 2
        LDB     #2            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        JSR     EraseSpriteB  ; Jump to code to Erase SpriteB and restore it's background
; SPRITE ERASE 1
        LDB     #1            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        JSR     EraseSpriteB  ; Jump to code to Erase SpriteB and restore it's background
; SPRITE ERASE 0
        LDB     #0            ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
;        PSHS    B             ; Save B on the stack
;        PULS    B             ; Get value in B and Fix the stack
        JSR     EraseSpriteB  ; Jump to code to Erase SpriteB and restore it's background
; SY =SY +VY 
        LDD     _Var_SY       ; Get the value of the variable
        PSHS    D             ; Save the value on the stack
        LDD     _Var_VY       ; Get the value of the variable
;        PSHS    D             ; Save the value on the stack
; Doing ADD:                      
;        PULS    D             ; D = left 16 bit value, move the stack
        ADDD    ,S++          ; D=D+ right 16 bit value, fix the stack
;        PSHS    D             ; Save the new 16 bit right side value
;        PULS    D             ; Get value off the stack, fix the stack
        STD     _Var_SY       ; Save Numeric variable
; IF SY <52THEN 
; Starting if                      
        LDD     _Var_SY       ; Get the value of the variable
        PSHS    D             ; Save the value on the stack
        LDB     #52           ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
        PSHS    B             ; Save B on the stack
; *** Doing CompareOp                      
; Doing Function GreaterOrEqual                      
; LeftType= 5                      
; RightType= 4                      
        LDD     1,S           ; D = signed 16-bit, move stack 1 bytes
        BMI     @False        ; If LEFT<0 then False
        LDU     #$FFFF        ; Default is True
        CLR     ,-S           ; ext=0 for unsigned RIGHT
        CMPD    ,S+           ; Compare LEFT vs RIGHT as unsigned, fix the stack
        BHS     @True         ; If LEFT >= RIGHT keep True
@False  LDU     #$0000        ; Set as False
@True   LEAS    1,S           ; Move the stack
        STU     ,S+           ; Save U and move the stack forward, we only need to save the result as an 8 bit value
                              
        LDA     ,S+           ; get result off stack, fix stack
        LBNE    _IFDone_01    ; IF Not Equal then jump
; Expression is parsed                      
_IFTrue_01                      
; SY =52
        LDD     #$0034        ; D is a 16 bit integer from -32768 to 32767 (signed Integer) % format
;        PSHS    D             ; Save D on the stack
;        PULS    D             ; Get value off the stack, fix the stack
        STD     _Var_SY       ; Save Numeric variable
; VY =-VY 
        LDD     _Var_VY       ; Get the value of the variable
        PSHS    D             ; Save the value on the stack
; Doing Function Neg                      
; LeftType= 5                      
        LDD     ,S            
                              ; Get the value off the stack
        NEGA                  ; Negate A
        NEGB                  ; Negate B
        SBCA    #0            ; Add carry to A
        STD     ,S            ; Store negative value back on the stack
        PULS    D             ; Get value off the stack, fix the stack
        STD     _Var_VY       ; Save Numeric variable
; END IF 
_IFDone_01                      ; Label: END IF
; IF SY >63THEN 
; Starting if                      
        LDD     _Var_SY       ; Get the value of the variable
        PSHS    D             ; Save the value on the stack
        LDB     #63           ; B is an 8 bit integer from 0 to 255 (_Unsigned _Byte) ~%% format
        PSHS    B             ; Save B on the stack
; *** Doing CompareOp                      
; Doing Function LessOrEqual                      
; LeftType= 5                      
; RightType= 4                      
        LDU     #$FFFF        ; Default is True
        LDD     1,S           ; D = signed 16-bit, move stack 1 bytes
        BMI     @True         ; If LEFT<0 then True
        CLR     ,-S           ; ext=0 for unsigned RIGHT, move stack back
        CMPD    ,S+           ; Compare LEFT vs RIGHT as unsigned, move the stack
        BLS     @True         ; If LEFT <= RIGHT keep True
        LDU     #$0000        ; Set False
@True   LEAS    1,S           
        STU     ,S+           ; Store result, move stack
                              
        LDA     ,S+           ; get result off stack, fix stack
        LBNE    _IFDone_02    ; IF Not Equal then jump
; Expression is parsed                      
_IFTrue_02                      
; SY =63
        LDD     #$003F        ; D is a 16 bit integer from -32768 to 32767 (signed Integer) % format
;        PSHS    D             ; Save D on the stack
;        PULS    D             ; Get value off the stack, fix the stack
        STD     _Var_SY       ; Save Numeric variable
; VY =-VY 
        LDD     _Var_VY       ; Get the value of the variable
        PSHS    D             ; Save the value on the stack
; Doing Function Neg                      
; LeftType= 5                      
        LDD     ,S            
                              ; Get the value off the stack
        NEGA                  ; Negate A
        NEGB                  ; Negate B
        SBCA    #0            ; Add carry to A
        STD     ,S            ; Store negative value back on the stack
        PULS    D             ; Get value off the stack, fix the stack
        STD     _Var_VY       ; Save Numeric variable
; END IF 
_IFDone_02                      ; Label: END IF
; GOTO MainLoop
        JMP     _LMainLoop    ; GOTO MainLoop
EXITProgram:
        ORCC    #$50          ; Turn off the interrupts
        STA     $FFD8         ; Put Coco back in normal speed
        BRA     *             ; Endless loop, do not return to BASIC
        LDX     $FFFE         ; Get the RESET location
        CMPX    #$8C1B        ; Check if it's a CoCo 3
        BNE     RestoreCoCo1  ; Setup IRQ, using CoCo 1 IRQ Jump location
        LDX     #$FEF7        ; X = Address for the COCO 3 IRQ JMP
        BRA     >             ; Skip ahead
RestoreCoCo1                      
        LDX     #$010C        ; X = Address for the COCO 1 IRQ JMP
!       LDU     #OriginalIRQ  ; U = Address of the original IRQ
        LDA     ,U            ; A = Branch Instruction
        STA     ,X            ; Save Branch Instruction
        LDD     1,U           ; D = address
        STD     1,X           ; Restore the Address of the IRQ
RestoreStack:
        LDS     #$0000        ; Selfmodified when this programs starts - this restores S just how BASIC had it
        PULS    CC,D,DP,X,Y,U,PC   ; Restore the original BASIC Register values and return to BASIC, if it can
DataStart:
        END     START         
