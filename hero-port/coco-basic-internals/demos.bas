REM ============================================================
REM DEMO 1: T1 LOWERCASE HACK -- the real, correct pokes
REM
REM Confirmed by Ciaran Anscomb (author of XRoar) and independently
REM verified here. See hero-port/COCO-BASIC-INTERNALS.md for the
REM full disassembled explanation of exactly why these two specific
REM addresses work, and why an older, widely-circulated hack using
REM &H95AC instead can fail (ROM revision dependency, and requires
REM 64K/all-RAM mode to even be a writable address at all).
REM
REM Type this in directly (or RUN it as a stored program) on a
REM machine/emulator profile with a 6847T1 VDG (e.g. XRoar's
REM coco2b / coco2bus machine types). Line 30 just holds the
REM program running so you can see the result -- without POKE 359,
REM the mode reverts to normal the instant anything else prints.
REM ============================================================
10 POKE 359,57:POKE &HFF22,16
20 PRINT "Look, ma! Lowercase!"
30 A$=INKEY$:IFA$=""THEN30


REM ============================================================
REM DEMO 2: FULL CHARACTER MAP (corrected two-loop version)
REM
REM Shows, side by side: what raw POKEing every value 0-255 into
REM screen memory displays (top rows) versus what PRINT/CHR$
REM actually displays for values 0-127 (rows below that) -- reveals
REM which "control codes" are genuinely invisible, which have real
REM side effects (8=backspace erases the ONE preceding character;
REM 13=carriage return clears from the cursor to the end of the
REM current line), and shows the SG4 semigraphics block encoding
REM for values 128-255 (colour + 2x2 quadrant pattern, repeating
REM every 16 values as the quadrant bits cycle for each of the 8
REM colours).
REM
REM The original one-line version of this had NEXT nested inside
REM an IF ("...THEN PRINT...;:NEXT"), which silently terminates the
REM whole loop the moment the IF condition first goes false (at
REM I=128) -- POKE still happens for every I 0-255 since it comes
REM before the IF, but the loop itself dies right there. This
REM two-loop version avoids that trap entirely. CLS4 sets the
REM background to a distinct dark red specifically so you can see
REM at a glance which screen positions PRINT genuinely never
REM touches (still showing that background colour) versus which
REM ones it overwrites as a side effect of a control code.
REM ============================================================
40 CLS4
50 A=&H400:B=8*32
60 FOR I=0 TO 127
70 POKE A+I,I
80 PRINT @B+I,CHR$(I);
90 NEXT I
100 FOR I=128 TO 255
110 POKE A+I,I
120 NEXT I


REM ============================================================
REM DEMO 3: ROM-TO-RAM SINGLE-CHUNK PROOF (redesigned 2026-10-30)
REM
REM The machine code (romcopy_proof.asm) stack-blasts the 8 bytes
REM at &H8000 from ROM into the RAM underneath, then, while still in
REM all-RAM mode, copies that RAM back out to &H7045 and tests that
REM RAM at &H8000 really is writable (flag at &H7044). It switches
REM back to ROM mode before returning, because BASIC itself is still
REM running from ROM and only 8 bytes were copied. It first checks
REM for a 64K machine: on 32K, all-RAM mode makes $8000 an alias of
REM $0000, and copying would overwrite BASIC's own variables.
REM $FFDE selects ROM, $FFDF selects all-RAM.
REM
REM TESTED 2026-10-30, headless XRoar 1.12.1, coco2bus 64K: copy
REM matches ROM, RAM writable, back in ROM mode, BASIC running; on
REM a 32K machine it detects the $8000->$0000 alias and refuses.
REM (The old version had $FFDE/$FFDF swapped and always showed ROM.)
REM Bytes assembled by lwasm.wasm from romcopy_proof.asm.
REM ============================================================
200 DATA 26,80,183,255,223,150,0,67,183,128,0,145,0,38,10,67,151,0,198,2,247,112,94,32,61,183,255,222,16,255,112,92,16,206,128,0
202 DATA 183,255,222,53,118,183,255,223,52,118,16,254,112,92,142,128,0,206,112,95,198,8,166,128,167,192,90,38,249,182,128,0,76,183,128,0
204 DATA 177,128,0,38,5,198,1,247,112,94,74,183,128,0,183,255,222,28,175,57,0,0,0,0,0,0,0,0,0,0,0
220 FOR I=0 TO 102:READ B:POKE &H7000+I,B:NEXT I
230 EXEC &H7000
235 IF PEEK(&H705E)=2 THEN PRINT "32K MACHINE: NO RAM UNDER ROM.":PRINT "REFUSED (ALL-RAM MODE WOULD":PRINT "OVERWRITE $0000-$7FFF)":GOTO 320
240 PRINT "ROM  @8000:";:FOR I=0 TO 7:PRINT PEEK(&H8000+I);:NEXT I:PRINT
250 PRINT "RAM COPY  :";:FOR I=0 TO 7:PRINT PEEK(&H705F+I);:NEXT I:PRINT
260 M=1:FOR I=0 TO 7:IF PEEK(&H8000+I)<>PEEK(&H705F+I) THEN M=0
270 NEXT I
280 IF M=1 THEN PRINT "RAM COPY MATCHES ROM" ELSE PRINT "COPY MISMATCH"
290 IF PEEK(&H705E)=1 THEN PRINT "RAM WAS WRITABLE IN 64K MODE" ELSE PRINT "RAM NOT WRITABLE"
300 A=PEEK(&H8000):POKE &H8000,(A+1) AND 255
310 IF PEEK(&H8000)=A THEN PRINT "BACK IN ROM MODE" ELSE PRINT "STILL IN RAM MODE":POKE &H8000,A
320 REM END OF DEMO 3


REM ============================================================
REM DEMO 4: THE COMPLETE ROM-TO-RAM MIGRATION
REM
REM Runs the actual full sweep -- all ~32.5K of real ROM address
REM space ($8000 up to, but not including, $FF00 where PIA0 and
REM the rest of real hardware I/O begins), 4064 chunks of 8 bytes
REM each, using the exact same mechanism as Demo 3's single-chunk
REM proof, just scaled up to the entire range.
REM
REM The object code below is the assembled form of
REM hero-port/coco-basic-internals/full_rom_migrate.asm -- see that
REM file (and its .lst) for the fully annotated source.
REM
REM Confirmed by real testing, not assumed: this REQUIRES disabling
REM interrupts (ORCC #$50) before the loop starts, restoring them
REM (ANDCC #$AF) only once it's fully finished. Without that, this
REM hangs indefinitely partway through -- CoCo's timer/keyboard-scan
REM interrupt fires constantly, and if one fires during one of the
REM loop's many brief moments in RAM mode, before the interrupt
REM vectors near $FFF0-$FFFF have actually been copied yet (since
REM the sweep proceeds from $8000 upward, they're among the very
REM last things touched), the CPU reads garbage as its own interrupt
REM vector and jumps into invalid memory. This was found the hard
REM way, by a real hang during testing, not anticipated in advance.
REM
REM What's actually confirmed by running this: every spot-checked
REM address across the ENTIRE range (the very start, several points
REM through the middle, and the very last byte before I/O begins)
REM comes back byte-for-byte identical before and after -- the copy
REM itself is proven correct across the whole of real ROM, not just
REM a small test range. CORRECTION (2026-10-30): those earlier runs
REM had $FFDE/$FFDF swapped, so they read in all-RAM mode, wrote in
REM ROM mode and ended in ROM mode; the before/after PEEKs both read
REM ROM, which is why they matched and writes never stuck. The DATA
REM below is now fixed: the sweep ends in all-RAM mode with BASIC
REM running from its RAM copy, and a POKE to e.g. &H8000 sticks.
REM TESTED 2026-10-30, headless XRoar 1.12.1, coco2bus 64K: old code ->
REM writes never stick; fixed code -> values identical before/after,
REM POKE &H8000 sticks, BASIC keeps running. (tools/xroar_headless/)
REM WARNING: 64K MACHINES ONLY. On 32K, all-RAM mode makes $8000-$FEFF
REM alias $0000-$7EFF, so this sweep would copy the ROM over BASIC's
REM own RAM and crash. (Found 2026-10-30; Demo 3 now checks for this.)
REM ============================================================
400 DATA 26,80,16,255,112,40,16,254,112,42,183,255,222,53,118,183,255,223,52,118,190,112,42,48,8,191,112,42,140,255,0,38,229,16,254,112,40,28,175,57,0,0,128,0
410 FOR I=0 TO 43:READ B:POKE &H7000+I,B:NEXT I
420 A=PEEK(&H8000):B=PEEK(&H9000):C=PEEK(&HA000):D=PEEK(&HC000):E=PEEK(&HD000):F=PEEK(&HE000):G=PEEK(&HFEFF)
430 PRINT "BEFORE: ";A;B;C;D;E;F;G
440 EXEC &H7000
450 H=PEEK(&H8000):I2=PEEK(&H9000):J=PEEK(&HA000):K=PEEK(&HC000):L=PEEK(&HD000):M=PEEK(&HE000):N=PEEK(&HFEFF)
460 PRINT "AFTER:  ";H;I2;J;K;L;M;N
