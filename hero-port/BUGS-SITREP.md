# ugBASIC compiler bug sitrep (as of 2026-08-21, rev b96846a73)

## Fixed, no longer an issue

**Peephole optimizer deletes non-redundant `STA ,X+` stores** ([#1247](https://github.com/spotlessmind1975/ugbasic/issues/1247))
Fixed and released same day it was filed. Independently re-verified by
us against the actual fixed revision -- confirmed both in generated
assembly and a real boot test. No longer a constraint on how we write
inline assembly loops.

## Real bug, filed, has a workaround -- not blocking, just needs discipline

**`POKE` + `-W` fatal interaction** ([#1248](https://github.com/spotlessmind1975/ugbasic/issues/1248), mis-titled originally)
Actual root cause, found after the maintainer couldn't reproduce our
original report: it's not that `POKE` is broken -- it's that `-W`
turns warning W001 into a fatal compile error specifically for `POKE`
statements. Without `-W`, identical source compiles fine all the way
to a bootable disk. Follow-up comment drafted
(`hero-port/upstream-reports/1248-followup-comment.md`), not yet
posted. **Doesn't affect us in practice** -- we don't use `POKE` at
all in the actual port, everything goes through inline assembly.

**String concatenation chain limit** ([#1249](https://github.com/spotlessmind1975/ugbasic/issues/1249))
Not actually a bug -- a default resource limit (32 simultaneous
dynamic strings / 512 bytes). Maintainer's fix
(`DEFINE STRING COUNT 127` / `DEFINE STRING SPACE 1024`) verified
working by us directly. **Only matters if we build long strings via
many chained `+` operations** -- the loop-accumulator style
(`x$ = x$ + chr$(...)` inside a `FOR`) sidesteps it entirely and reads
more naturally anyway.

## Real bug, not yet filed, has a workaround

**Identifiers can't start with an uppercase letter**
Confirmed precisely: the *first character* must be lowercase,
regardless of what follows. **This affects every single variable name
in the port** -- Nick's original source is 100% uppercase
(`PX`, `L1`, `BM`, ...). Mechanical fix (lowercase the first letter of
every name), but it must be applied everywhere, without exception,
before any of his code will compile at all.

**Procedure parameters default to a 16-bit word; an 8-bit register read grabs the wrong byte**
Confirmed: any parameter not given an explicit type silently becomes a
16-bit `fdb`, and reading it with `LDB` grabs the high byte (always 0
for small values). Fix: declare small parameters `AS BYTE` explicitly
in the procedure signature.

**Peephole optimizer forces immediate addressing onto procedure-local values computed from a parameter**
Confirmed: `addr = STRPTR(data$)` inside a procedure, called more than
once with different arguments, has its *read* silently replaced with
a hardcoded placeholder by the optimizer -- the store still runs
correctly, but nothing reads what it wrote. Two independent fixes,
either works: compile the whole program with `-p 0`, or restructure so
the value is passed in as a genuine parameter rather than computed
internally.

**toolshed's MinGW `_mkdir` compile error** (Windows-build-specific, not ugBASIC itself)
`libnativemakdir.c` calls `_mkdir()` without including `<direct.h>`.
Patched directly (`hero-port/patches/toolshed-mingw-mkdir.patch`),
never filed upstream to `spotlessmind1975/toolshed` -- worth doing at
some point, but only affects building the toolchain on Windows, not
anything about the port itself.

## The one with real, ongoing impact on how we write the port

**Classic `GET(x,y)-(x2,y2),name` / `PUT(...)` doesn't actually work for runtime capture-then-redraw**
Confirmed via deep tracing through `get_image.c`/`put_image.c`/
`_infrastructure.c`: `GET` never sets the image variable's
`valueBuffer`, but every `PUT` variant unconditionally checks it and
refuses with "uninitialized image variable." No combination of `DIM`
declarations we tried gets past this for a plain capture-then-redraw
round trip.

**This is the one that actually changes the shape of the port.** We
are not going to get to translate Nick's ~50 `GET`/`PUT` sprite calls
close to verbatim, the way the matching classic syntax first suggested
we might. Instead, every sprite operation needs our own hand-written
inline-assembly equivalent (raw memory copies against the known
PMODE4/SG12 framebuffer layout via `BITMAPADDRESS`) -- which we've
already proven works, and already wrapped in reusable procedures
(`writerow`/`fillrow`-style), but it's real, ongoing extra work per
sprite call rather than a syntax-level translation.

## Open, unresolved

**`fillrow` called multiple times in sequence, combined with `writerow`, showed an unexplained discrepancy**
In the four-call border/text demo (`fillrow`, `writerow`, `fillrow`,
`fillrow`), even after both the `-p 0` and `AS BYTE` fixes, the first
`fillrow` call (meant to render just above the text) didn't appear to
render at all in one test, while an isolated three-`fillrow`-call test
(no `writerow` involved) looked plausible once we accounted for
adjacent rows merging visually. Never conclusively isolated which of
these is actually correct behaviour versus a real remaining bug.
**Needs a clean, minimal two-call isolation (`fillrow` immediately
followed by `writerow`, nothing else) before trusting multi-procedure
sequences without double-checking each one visually.**

## Net effect on the port

None of the above blocks moving forward. But two things need to become
firm habits for every single line of new BASIC we write from here on:
every identifier starts lowercase, and every sprite-drawing call is a
hand-written memory-copy routine, not a native `GET`/`PUT`. The open
`fillrow` question means: verify visually, don't assume, whenever we
chain more than one of our own procedures together in a new context.
