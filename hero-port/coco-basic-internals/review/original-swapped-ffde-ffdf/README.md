# Original ROM-to-RAM routines (before the $FFDE/$FFDF fix)

These are the routines exactly as they were on `main` before PR #4
(commit `aaa1a2c`), kept for review and comparison. **They don't work as
intended**: the SAM ROM/RAM switch addresses are swapped.

- `$FFDE` clears SAM bit TY: map type 0, **ROM enabled**.
- `$FFDF` sets SAM bit TY: map type 1, **all-RAM** (64K machines only).

These files use them the other way round, so they read in all-RAM mode,
write in ROM mode (writes to `$8000+` are discarded there) and finish in ROM
mode. Tested in headless XRoar on a 64K CoCo 2: the sweep runs and BASIC
survives, but nothing is copied and a POKE to `$8000` never sticks afterward.
That's the "mode switch doesn't take effect" puzzle the old notes recorded.

They were written for the CoCo 2, where a 64K machine powers up running BASIC
from ROM, using only 32K, and software must copy the ROM to RAM itself
before it can patch BASIC.

The fixed and tested versions are one level up in `coco-basic-internals/`.
`demos.bas` here is the whole original demo file, for its Demo 3 and Demo 4.
