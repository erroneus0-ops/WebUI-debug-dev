# ugBASIC vs. BASIC-To-6809 for the HERO port -- combined assessment

> **Update 2026-09-04: the trigger condition below has fired.** See
> "Update 2026-09-04" section near the end -- PNGtoCCSB now documents
> compiled-sprite support reaching SG12/SG24. Recommendation revised
> from "stay on ugBASIC, watch for this" to "prototype BASIC-To-6809
> now." Original 2026-09-01 assessment kept below intact for record.

Combines what was already recorded in this repo (`BUGS-SITREP.md`, this
port's own test files) with a deeper review of BASIC-To-6809 done
2026-09-01. Both compilers checked against their actual current state
that day: ugBASIC `main` HEAD (commit `31b6d7e`, 2026-08-21; latest
tagged release `v1.18.1`, 2026-05-29 -- the maintainer's own install
docs recommend tracking `main` in production, not the tag, since it
carries ongoing hotfixes the tag doesn't); BASIC-To-6809 HEAD (commit
`362658508`, 2026-08-23, `V5.45`). Author: Glenn Newlett
(`nowhereman999`), also known in the CoCo Discord community for
hardware-accurate CoCo3 ports of Joust/Defender/Robotron.

## What HERO actually needs from either toolchain

Recap, traced in `HERO-SOURCE-ANALYSIS.md` and confirmed against the
real ECB 1.1 ROM disassembly (see `SG_MODE_RESEARCH.md`):

1. **The SG12 hack itself**: draw normally in an ordinary 2-colour
   graphics mode (real CoCo `PMODE 4` -- 8 pixels/byte, 32 bytes/row),
   then flip the VDG's `nA_G` bit off and drive the SAM's V2V1V0 bits to
   `100` via direct hardware register writes. The *same bytes* get
   reinterpreted by the VDG as 8-colour semigraphics at scan-out time --
   nothing about the buffer's contents or addressing changes.
2. **GET/PUT-equivalent sprite blitting**: HERO slices a loaded sprite
   sheet into ~50 sub-images once, then blits them constantly during
   play (`walk`, `fly`, creature, digit, and hazard sprites). Now
   **confirmed directly from ROM disassembly** (see
   `SG_MODE_RESEARCH.md`'s new section) that classic `GET`/`PUT` was
   never "mode-aware" for any mode, on real hardware or otherwise --
   its addressing math only ever depends on whatever `PMODE` (0-4) was
   last set via a real `PMODE` statement, with no representation at all
   for a hand-flipped SG reinterpretation. So "does X support GET/PUT
   for SG12" was never a coherent ask -- what actually matters is
   whether a hand-rolled equivalent's addressing math matches SG12's
   real row-byte-count (32 bytes/row) and byte-boundary discipline
   (confirmed as a correctness requirement, not just a speed
   optimization, once a "pixel" is really a whole quadrant-coded byte).

## ugBASIC: current state

**Real, current bugs, from `BUGS-SITREP.md` (2026-08-21) and this port's
own upstream reports:**
- `POKE` + `-W` is a fatal-error interaction (upstream #1248, root
  cause found and confirmed after the maintainer couldn't reproduce the
  original report) -- not a real breakage, just needs `-W` dropped.
  Doesn't affect this port in practice; it uses inline assembly for all
  hardware register access anyway.
- Identifiers can't start uppercase -- mechanical fix, applies
  everywhere in Nick's all-uppercase original source.
- Procedure parameters default to 16-bit; an unqualified 8-bit register
  read silently grabs the wrong byte -- fix: declare `AS BYTE`
  explicitly.
- Peephole optimizer forces immediate addressing onto procedure-local
  values computed from a parameter -- fix: `-p 0`, or restructure to
  pass the value in directly.
- **Classic `GET`/`PUT` genuinely doesn't work for capture-then-redraw**
  (traced through `get_image.c`/`put_image.c`/`_infrastructure.c`:
  `GET` never sets `valueBuffer`; every `PUT` variant unconditionally
  checks it and refuses). This is the one with real, ongoing impact --
  every one of HERO's ~50 sprite calls needs a hand-written inline-asm
  replacement instead of a syntax-level translation.

**What's already built and proven, as a direct result of the above:**
`PMODE 4`'s buffer confirmed byte-for-byte real-6847-accurate (this
port's own `sg12_hypothesis_test.bas`); the actual SG12 register flip
reproduced by hand via inline assembly (working around the `POKE`/`-W`
issue) and confirmed to recolour the screen without corrupting shape;
`writerow`/`fillrow` procedures already written and working as the
`GET`/`PUT` replacement, directly against this confirmed buffer layout.
**The hardest, most uncertain part of this specific port is done.**

## BASIC-To-6809: current state (deeper review, 2026-09-01)

**Confirmed working, better than ugBASIC on these specific points:**
- `POKE` is a plain, unconditionally-working handler
  (`Case "POKE" -> GoTo DoPOKE`) -- no flag interaction to know about.
- Inline assembly is a documented, first-class feature: any `GOSUB`
  target can be raw 6809 assembly, delimited by `' ADDASSEM:` /
  `' ENDASSEM:` markers, with automatic BASIC-variable interop
  (`_Var_name` for numerics, `_StrVar_name` for strings, length byte
  first) -- same underlying idea as ugBASIC's `BEGIN ASM`/`END ASM`
  with underscore-prefixed variables, arguably smoother since it isn't
  adjacent to any known bug.
- Explicitly ROM-independent: README states directly, "Doesn't use any
  ROM calls (Extended BASIC ROM not required), possible to use all of
  the 64k of RAM on Coco 1 & 2." Confirmed further by a real V5.45
  changelog entry: `CHAIN`/`SDC_CHAIN` "now force all-RAM mode before
  loading."
- **SG-mode `GMODE` support is already built, not just planned** --
  found this session, and this is the one that most changes the
  picture: `Basic_Includes/GraphicCommands/` has real, non-stub
  subfolders for `SG4`, `SG4H`, `SG6`, `SG6H`, `SG8`, `SG12`, and
  `SG24`, each with genuine `_Main.asm`/`_Draw.asm`/`_Line.asm`/
  `_Circle.asm`/`_Paint.asm`/`_Locate.asm`/`_Print_Graphic_Screen.asm`
  files -- the same pattern as every other confirmed-working mode.
  Wired into the live `GMODE` dispatch table right now
  (`01_Arrays_Constants.bas`), not disconnected scaffolding:
  ```
  GModeName$(7) = "SG12" : GModeStartAddress$(7) = "E00"
                           GModeScreenSize$(7)   = "C00"   ' 3072 bytes
  ```
  That buffer size checks out exactly against the SAM's real V2V1V0
  table in `SG_MODE_RESEARCH.md` (SG8=2048, SG12=3072, SG24=6144 bytes
  -- all four match). `git log` on that directory shows it's been in
  the tree since **March 2026**, five months before this comparison was
  first raised -- predates any influence this project's own questions
  might have had.

**Confirmed real, current gap:** the manual states directly and plainly
-- *"At this point PNGtoCCSB doesn't support semigraphics screen modes
for sprites"* and, separately, *"GET & PUT commands are not
available"* at all (a documented design choice, not a bug -- replaced
by `SPRITE`/`SPRITE_LOAD`, which itself doesn't reach semigraphics yet
either). So: pixel-level plotting into SG12 already works; sprite
capture/redraw into SG12 does not, on either compiler, today.

**Not yet verified (flagged, not assumed):** whether the addressing
math inside `SG12_Draw.asm`/`SG12_Main.asm` is actually correct --
confirmed only that the registered buffer *size* matches real hardware,
not that the internal row/column math does. This is the same kind of
claim that took real tracing (the `L9298` ROM dive) to nail down for
GET/PUT's own PMODE math -- worth doing the equivalent pass on this
source specifically before relying on it, not assumed correct by
extension.

## Assessment: stay on ugBASIC, watch BASIC-To-6809, don't switch yet

Netting it out: **neither compiler's native sprite mechanism reaches
into semigraphics** -- so the actual hard work (a hand-written
`get`/`put` equivalent, byte-boundary-disciplined, blitting directly
against a confirmed SG12 buffer) has to be built by hand either way.
That work is not a ugBASIC-specific tax avoidable by switching; it's
the current state of the art on both toolchains.

On ugBASIC, that work is **already done and validated end-to-end** --
`PMODE 4`'s hardware accuracy confirmed, the SG12 register flip
reproduced and confirmed non-corrupting, `writerow`/`fillrow` built and
working. On BASIC-To-6809, the equivalent confidence doesn't exist yet
-- the buffer *geometry* is confirmed correct, but the addressing math
inside its SG12 routines is unverified, and its own sprite tooling
explicitly doesn't reach SG modes at all. Switching now would mean
discarding a finished, working unlock to go re-earn the same confidence
somewhere else, with no guarantee it comes out cheaper.

**Recommendation: continue the port on ugBASIC.** Not because it's the
better toolchain in the abstract -- on current evidence BASIC-To-6809
may genuinely be that, given working `POKE`, cleaner inline-asm interop,
and already-hardware-correct SG12 buffer geometry -- but because the
specific hard-won unlock this port depends on already exists and works
on ugBASIC, and nothing about BASIC-To-6809's current state removes the
need to redo that unlock from scratch.

## Next steps

1. **Cheap due diligence, not a rewrite.** Trace
   `SG12_Draw.asm`/`SG12_Main.asm` the way `L9298` was traced for the
   ROM (see `SG_MODE_RESEARCH.md`). A few hours, not a toolchain switch.
   Useful either way: banks real intel if it holds up, or surfaces a
   real problem cheaply if it doesn't.
2. **Real trigger condition for revisiting this comparison**: not "Glenn
   adds semigraphics" (already true, since March 2026) and not "his
   general reputation is excellent" (true, but not evidence about this
   specific gap) -- watch specifically for `SPRITE_LOAD`/`PNGtoCCSB`
   gaining semigraphics support. Reported (unconfirmed) via Discord that
   this is exactly what he's working toward, possibly prompted by a
   question raised during this same investigation. The moment that
   ships, BASIC-To-6809 wouldn't just match ugBASIC's hand-built
   solution, it would hand over a native, maintained version of it from
   someone whose specific track record is hardware-accuracy under
   exactly this kind of constraint -- worth re-opening the comparison
   immediately at that point.
3. If useful as a parallel, low-commitment exploration (not a
   replacement for continuing the ugBASIC port): a small standalone
   prototype of a hand-rolled `get`/`put` pair on BASIC-To-6809, using
   its already-working `GMODE 7`/SG12 plotting plus its documented
   inline-assembly interop, mirroring what `writerow`/`fillrow` already
   proved on ugBASIC. Would directly answer the open addressing-math
   question in (1) and produce a real point of comparison rather than
   an inferred one.

*(Note: item 2's trigger condition fired 2026-09-04, three days after
the above was written -- see the update section below. Item 3 above is
superseded by that update's own next steps, but left here for the
record of what was actually planned before the news arrived.)*

## Update 2026-09-04: PNGtoCCSB now documents semigraphics sprite support

News received same-day, from the CoCo Discord group; confirmed
independently against `PNGtoCCSB_User_Manual.pdf` (PNGtoCCSB v1.11,
BasTo6809 compiler v5.46, dated August 2026) and the current repo
(pulled same day, `V5.50`, commit `3747a69`). This is the exact trigger
flagged three days earlier as the thing to watch for -- it fired
faster than expected.

**What the manual actually documents, directly:**
- The compiled-sprite support table marks GMODEs `3, 5-8` -- SG4H,
  SG6H, SG8, **SG12**, SG24, per the compiler's own `GModeName$()`
  table -- as **Yes** for compiled sprites, described as "two
  horizontal subpixels share each colour cell... PNGtoCCSB corrects
  vertical proportions automatically." GMODE 4 (plain SG6) gets its own
  row, also **Yes**, with a real hardware caveat worth remembering for
  this project specifically: true SG6 needs an original MC6847 -- the
  CoCo 2B's 6847T1 does not render it correctly. (This caveat is
  attached to SG6 specifically in the manual, not to SG12 -- worth
  confirming it doesn't quietly apply to SG12 too before assuming it's
  fine on 6847T1-equipped hardware, rather than assuming the exemption
  by extension.)
- Background handling is native, not something to hand-roll: "creates
  the drawing and background-restoration routines" is listed as
  automatic tool output, and the described workflow (two graphics
  pages, `GCOPY 0,1` to seed the background, `SPRITE` commands,
  `WAIT VBL` for updates) is a real double-buffered sprite system, not
  bare pixel plotting.
- Byte-boundary alignment -- flagged in this document's earlier
  ROM-tracing work as a correctness requirement, not just a speed
  optimization, for any hand-rolled SG blitter -- is handled *by the
  tool*: "creates all alignment versions needed when a sprite begins
  between packed-byte boundaries." The manual's alignment table still
  recommends cell-aligned placement for best colour fidelity where it
  matters, but misalignment no longer means broken output, just
  suboptimal colour.

**What's confirmed vs. what still needs hands-on verification:**
confirmed directly from the manual's own support table (unambiguous:
GMODE 7/SG12 marked Yes). *Not* yet confirmed: the manual's worked
command examples show `-g2` (SG4) and `-g4` (SG6) concretely, not `-g7`
(SG12) by name -- no printed end-to-end SG12 example exists in the
manual text pulled. The table entry is explicit and should be reliable,
but an actual `-g7` conversion hasn't been watched work, only read
about.

## Revised recommendation

**Prototype BASIC-To-6809 now, in parallel with the ongoing ugBASIC
port -- this is no longer just "worth watching," it's worth spending
real time on.** Concretely: take one real HERO sprite -- the player
walk-cycle is a good first test, since it's multi-frame, needs clean
background restore against a moving background, and its correctness is
easy to eyeball -- run it through `PNGtoCCSB -g7` (SG12), load it via
`SPRITE_LOAD`, and confirm it actually looks right on real SG12 output,
not just that the tool exits without error. That single test answers
the one open item above (does `-g7` really work end-to-end) and gives
a real, current point of comparison against the already-working
ugBASIC `writerow`/`fillrow` path, instead of a comparison based on
reading two manuals.

If that test holds up, the calculus from 2026-09-01 flips: BASIC-To-6809
would then offer working `POKE`, cleaner documented inline-assembly
interop, hardware-correct SG12 buffer geometry, *and* a native,
tool-generated, alignment-safe sprite-and-background system reaching
the exact mode this port depends on -- at which point continuing to
hand-maintain `writerow`/`fillrow` on ugBASIC stops being the safer
choice and starts being the more work for the same result.
