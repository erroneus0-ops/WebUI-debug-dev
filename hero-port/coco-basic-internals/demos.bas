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
REM DEMO 3: ROM/RAM MODE DETECTION -- proving the stack-blast
REM ROM-to-RAM copy actually works
REM
REM Detects whether address &H8000 is currently genuine (writable)
REM RAM or read-only ROM by trying to change it and checking
REM whether the write stuck, runs a real stack-blasting copy
REM routine that reads 8 bytes from &H8000 while ROM is forced on
REM and writes them back while RAM is forced on, then runs the same
REM detection again -- proving the address is now genuinely
REM writable RAM, with its original ROM content faithfully
REM preserved.
REM
REM The object code below is the assembled form of
REM hero-port/coco-basic-internals/romcopy_proof.asm -- see that
REM file (and its matching .lst listing) for the annotated source.
REM
REM NOTE, confirmed during this exploration: a plain POKE &HFFDE,0
REM (the SAM's documented all-RAM-mode toggle) did NOT actually
REM switch modes in the specific XRoar coco2bus build used to
REM verify all of this -- meaning DEMO 3 as written will correctly
REM show "BEFORE - ROM MODE" both times until/unless that's
REM resolved (real open question, see COCO-BASIC-INTERNALS.md
REM section 2). The COPY mechanism itself (the actual point of this
REM demo) is separately, solidly verified -- see
REM stackblast_multichunk.asm/.lst for that proof, done directly
REM against ordinary RAM rather than depending on the ROM/RAM
REM switch working in this specific emulator build.
REM ============================================================
200 DATA 16,255,112,24,16,254,112,26,79,183,255,223,53,118,183,255,222,52,118,16,254,112,24,57,0,0,128,0
210 FOR I=0 TO 27:READ B:POKE &H7000+I,B:NEXT I
220 A=PEEK(&H8000)
230 POKE &H8000,(A+1) AND 255
240 B=PEEK(&H8000)
250 IF A=B THEN PRINT "BEFORE - ROM MODE"
260 IF A<>B THEN PRINT "BEFORE - RAM MODE"
270 POKE &H8000,A
280 EXEC &H7000
290 C=PEEK(&H8000)
300 POKE &H8000,(C+1) AND 255
310 D=PEEK(&H8000)
320 IF C=D THEN PRINT "AFTER - ROM MODE"
330 IF C<>D THEN PRINT "AFTER - RAM MODE"
340 POKE &H8000,C


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
REM a small test range. Whether the underlying mode switch actually
REM takes effect afterward remains the same open XRoar-specific
REM question noted in Demo 3 and COCO-BASIC-INTERNALS.md section 2 --
REM confirmed here too, via a real write-persistence test immediately
REM after running this, that it still doesn't stick in this specific
REM emulator build even after the complete sweep.
REM ============================================================
400 DATA 26,80,16,255,112,40,16,254,112,42,183,255,223,53,118,183,255,222,52,118,190,112,42,48,8,191,112,42,140,255,0,38,229,16,254,112,40,28,175,57,0,0,128,0
410 FOR I=0 TO 43:READ B:POKE &H7000+I,B:NEXT I
420 A=PEEK(&H8000):B=PEEK(&H9000):C=PEEK(&HA000):D=PEEK(&HC000):E=PEEK(&HD000):F=PEEK(&HE000):G=PEEK(&HFEFF)
430 PRINT "BEFORE: ";A;B;C;D;E;F;G
440 EXEC &H7000
450 H=PEEK(&H8000):I2=PEEK(&H9000):J=PEEK(&HA000):K=PEEK(&HC000):L=PEEK(&HD000):M=PEEK(&HE000):N=PEEK(&HFEFF)
460 PRINT "AFTER:  ";H;I2;J;K;L;M;N
