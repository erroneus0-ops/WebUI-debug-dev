# ugBASIC compiler notes (targeting the `coco` platform)

Confirmed bugs and workarounds found while porting a real BASIC program
(Nick Marentes' HERO) from interpreted Extended Color BASIC to ugBASIC.
Source of truth: `hero-port/BUGS-SITREP.md` and
`hero-port/upstream-reports/*.md` in the main repo — check those directly
for the fullest detail and current filing status; this file is the
practical "what to do about it" summary.

## Fixed upstream — no longer a constraint

**Peephole optimizer deleted non-redundant `STA ,X+` (auto-increment)
stores** ([ugbasic#1247](https://github.com/spotlessmind1975/ugbasic/issues/1247)).
Fixed and released same day it was filed; independently re-verified
against the fixed revision. No longer needs a workaround.

## Real bugs with a workaround — not blocking, just need discipline

**`POKE` + `-W` fatal interaction**
([ugbasic#1248](https://github.com/spotlessmind1975/ugbasic/issues/1248)).
Root cause: `-W` turns warning W001 into a fatal compile error
specifically for `POKE` statements — `POKE` itself isn't broken. Without
`-W`, identical source compiles fine. **Doesn't matter if the port avoids
`POKE` entirely and uses inline assembly instead**, which is the
recommended approach anyway (see `6809-techniques.md`'s BASIC-test-
harness pattern for verifying the equivalent assembly directly).

**String concatenation chain limit**
([ugbasic#1249](https://github.com/spotlessmind1975/ugbasic/issues/1249)).
Not actually a bug — a default resource limit (32 simultaneous dynamic
strings / 512 bytes). Fix: `DEFINE STRING COUNT 127` /
`DEFINE STRING SPACE 1024`, confirmed working. Only matters if building
long strings via many chained `+` operations — a loop-accumulator style
(`x$ = x$ + chr$(...)` inside a `FOR`) sidesteps it entirely and reads
more naturally.

## Real bugs, not yet filed upstream — must work around

**Identifiers can't start with an uppercase letter.** The *first
character* of any identifier must be lowercase, regardless of what
follows. **This affects every single variable name when porting Nick's
original source**, which is 100% uppercase (`PX`, `L1`, `BM`, ...).
Mechanical fix: lowercase the first letter of every identifier,
everywhere, before anything will compile.

**Procedure parameters default to a 16-bit word; an 8-bit register read
grabs the wrong byte.** Any parameter without an explicit type silently
becomes a 16-bit `fdb`; reading it with an 8-bit load (e.g. `LDB`) grabs
the high byte (always 0 for small values). Fix: declare small parameters
`AS BYTE` explicitly in the procedure signature.

**Peephole optimizer forces immediate addressing onto procedure-local
values computed from a parameter.** `addr = STRPTR(data$)` inside a
procedure, called more than once with different arguments, has its
*read* silently replaced with a hardcoded immediate placeholder by the
optimizer — the store still runs correctly, but nothing reads what it
wrote. Confirmed fixed by `-p 0` (disables the peephole optimizer
globally); **not** fixed by pre-declaring the local with `DIM`.
Alternative fix: restructure so the value is passed in as a genuine
parameter rather than computed internally.

**`GET`/`PUT` image `valueBuffer` gap.** Classic
`GET(x,y)-(x2,y2),name` doesn't set the image's `valueBuffer`, so `PUT`
always reports "uninitialized image variable" immediately after a
successful `GET`. See
`hero-port/upstream-reports/ugbasic-get-put-image-valuebuffer-gap.md`
for the full repro and any workaround found.

## Build-tooling issue (not ugBASIC itself)

**toolshed's MinGW `_mkdir` compile error** (Windows builds only).
`libnativemakdir.c` calls `_mkdir()` without including `<direct.h>`.
Patched directly in
`hero-port/patches/toolshed-mingw-mkdir.patch`; not yet filed upstream
to `spotlessmind1975/toolshed`.

## Before assuming a new ugBASIC quirk is a real bug

1. Check `hero-port/BUGS-SITREP.md` for current status — some entries
   here may since be fixed upstream; the sitrep is the living log.
2. Reproduce with the smallest possible repro, the same way every entry
   above was found — don't generalize from a large, complex program.
3. Verify against real 6809 semantics using the BASIC/`DATA`/`POKE`/
   `EXEC` test pattern in `6809-techniques.md` before concluding the
   *compiler* (rather than an assumption about CoCo hardware) is at
   fault.
