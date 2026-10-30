# Color BASIC 1.2 -- listing index

ROM image: $A000-$BFFF, SHA-1 `0f14dc46c647510eb0b7bd3f53e33da07907d04f`.
Chunks are split only at named-label boundaries (a routine is never cut mid-way), ~260 lines max.
To find an address: pick the chunk whose range contains it. To find a label: `grep` ../SYMBOLS.txt.

| File | Range | Named entry points |
|---|---|---|
| cb_A000-A1CA.asm | $A000-$A1CA | POLCAT, CHROUT, CSRDON, BLKIN, BLKOUT, JOYIN, WRTLDR, RESVEC, BACDST, BAWMST, BFRQSV |
| cb_A1CB-A281.asm | $A1CB-$A281 | KEYIN, CONTAB |
| cb_A282-A44B.asm | $A282-$A44B | PUTCHR, CLOSE |
| cb_A44C-A5F5.asm | $A44C-$A5F5 | CSAVE, CLOAD, EXEC, INKEY, EOF, SKIPF |
| cb_A5F6-A77B.asm | $A5F6-$A77B | OPEN, GETBLK |
| cb_A77C-A90F.asm | $A77C-$A90F | CASON, MOTOR, WRLDR, SNDBLK, SET, RESET, POINT |
| cb_A910-AA19.asm | $A910-$AA19 | CLS, SOUND, AUDIO, BIRQSV, JOYSTK, GETJOY |
| cb_AA1A-ABE0.asm | $AA1A-$ABE0 | BROMHK |
| cb_ABE1-AD46.asm | $ABE1-$AD46 | NEW |
| cb_AD47-AEE2.asm | $AD47-$AEE2 | FOR, RESTOR, END, STOP, CONT, CLEAR, RUN, GO, RETURN, DATA, ELSE |
| cb_AEE3-B045.asm | $AEE3-$B045 | REM, IF, ON, LET, INPUT |
| cb_B046-B0F7.asm | $B046-$B0F7 | READ |
| cb_B0F8-B28F.asm | $B0F8-$B28F | NEXT |
| cb_B290-B3EC.asm | $B290-$B3EC | DIM |
| cb_B3ED-B4FC.asm | $B3ED-$B4FC | INTCNV, IN COEFPT. RETURN RESULT IN ACCD, BS ERROR IF > $FFFF, MEM, GIVABF |
| cb_B4FD-B69F.asm | $B4FD-$B69F | STR, LEN, CHR |
| cb_B6A0-B763.asm | $B6A0-$B763 | ASC, LEFT, RIGHT, MID, VAL, PEEK, POKE, LLIST |
| cb_B764-B8F6.asm | $B764-$B8F6 | LIST |
| cb_B8F7-BA5B.asm | $B8F7-$BA5B | PRINT |
| cb_BA5C-BB90.asm | $BA5C-$BB90 | BA5C, $ THE RIGHT (B) TIMES. OVERFLOW RETAINED IN ACCA. |
| cb_BB91-BCED.asm | $BB91-$BCED | SGN, ABS |
| cb_BCEE-BE4A.asm | $BCEE-$BE4A | INT |
| cb_BE4B-BFFF.asm | $BE4B-$BFFF | RND, RSEED, SIN |
