# Reset, the ROM-to-RAM copy, and why patches survive RESET

Verified against the SECB listing (`../../coco/reference/unravelled/secb/`,
reset code in `secb_C000-C1D5.asm`, picture code in `secb_C1D6-C255.asm`).

## BASIC runs from RAM

At cold start the CoCo 3 copies Color, Extended, Disk and Super Extended
BASIC from ROM into RAM (`LC1AA` copy loop, called from `$C0FD`, `$C132`,
`$C146`) and runs from the copy. So POKEs into "ROM" addresses work: they
change the RAM copy. Programs routinely patch BASIC this way, for example:

- BASIC Burger Time restores the CoCo 1/2 "any key down?" fast path at
  `$A1C1`, disables BREAK (`$ADEB`, `$E414`, `$E42A`) and makes `HSCREEN`
  skip clearing the screen (`$E6C6`).
- SUNRISE.BAS turns `HSCREEN 2` into a 160x192x16 mode by patching `$E06D`
  (GIME mode table), `$E6CC` (bytes per row) and the three `320-1` width
  limits at `$E7C9`, `$EB6F`, `$F5D6`.

## A plain RESET keeps the patches

The reset code at `$C0C7` warm-starts **without recopying the ROMs** when
all three hold:

1. `INT.FLAG` (`$FEED`) is `$55` (interrupt jump table valid),
2. `RSTFLG` (`$71`) is `$55`,
3. `RSTVEC` (`$72`) points at a `NOP` (`$12`).

So after a plain RESET, a patched BASIC stays patched. If `INT.FLAG` is
valid but 2/3 fail in the current direct page, it also retries the check
with block 6.0 (128K) / 0.0 (512K) mapped into CPU block 0.

## CTRL+ALT+RESET restores factory BASIC

At reset the code reads the keyboard; if CTRL and ALT are both down it
jumps to `LC1F0`, which:

- clears `INT.FLAG` and `RSTFLG` ("FORCE THE ROMS TO BE COPIED INTO RAM"),
- shows `AUTHPIC` ($C405-$DC04, 6,144 bytes): the digitized photo of the
  Microware authors of SECB, captioned "M. Hawkins  T. Harris  T. Earles",
  in the CoCo 2 256x192 two-color mode at `$0E00`, then loops forever.

The **next** RESET finds the flags invalid and does a full cold start with a
fresh ROM copy. That two-step sequence is the reliable way to undo any BASIC
patches. (The picture's 6K was famously resented as wasted ROM space.)
