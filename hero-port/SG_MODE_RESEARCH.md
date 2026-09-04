# SG modes, PMODE, and the memory behind them

*Research notes -- what's confirmed directly from XRoar's source vs. what
still needs verification. Written toward: simulating and toggling these
modes in the character-dump memory inspection tool.*

## The two chips involved, and why that matters

CoCo 1/2 splits this across **two separate chips** that don't fully agree
with each other about what's happening -- the MC6883 SAM (memory addressing)
and the MC6847 VDG (what to do with the byte once fetched). Most of what
makes SG8/SG12/SG24 behave the way they do falls directly out of these two
chips not being told the same thing at the same time. CoCo 3's GIME chip
replaces both with one, more explicit system -- confirmed to work
differently, not just simplified (see below).

## SG4: the actual mechanism (fully confirmed)

Bit 7 of a screen-memory byte selects alpha vs. semigraphics
(`mc6847.c`, `nA_S = vdata & 0x80`). In alpha mode, the byte indexes a real
character glyph (12 rows x 8 bits, `font_6847t1[]`/`font_6847[]`). In
semigraphics mode, there's no font lookup at all -- 3 bits pick one of 8
colors, 4 bits directly define a 2x2 on/off quadrant pattern. This part was
fully traced and verified in earlier sessions; not new here.

## The SAM's real mode-select register (confirmed directly -- this is
the actual hardware table, mirrored in XRoar's own source comment)

```
V2 V1 V0    X div   Y div     Notes
 0  0  0      1      12       standard text mode -- one address per
                               full 12-scanline character height
 0  0  1      3       1
 0  1  0      1       3
 0  1  1      2       1
 1  0  0      1       2
 1  0  1      1       1
 1  1  0      1       1
 1  1  1      1       1       DMA MODE (no HS# clear at all)
```

"Y div" is how many scanlines share one fetched byte before the SAM
advances to the next address. Mode 000 (Y div 12) is standard SG4/text --
one byte genuinely does cover the whole character height. Every other mode
fetches new bytes more often (Y div 1, 2, or 3), which is the entire
mechanism behind the higher-resolution SG/PMODE variants -- there's no
separate "SG8 register," it's this same 3-bit field with a smaller Y
divisor.

**Confirmed** (found in Tim Lindner's CoCo/GIME/GIME-X Memory Map Reference,
which quotes the SAM's real register table at `$FFC0`-`$FFC5` directly --
this is the mapping flagged as unverified above, now resolved from an
actual source, not memory):

```
V2 V1 V0   Buffer size   Display modes
 0  0  0     512         AI, SG4, SG6
 0  0  1    1024         G1C, G1R
 0  1  0    2048         G2C, SG8
 0  1  1    1536         G2R
 1  0  0    3072         G3C, SG12
 1  0  1    3072         G3R
 1  1  0    6144         G6R, G6C, SG24
 1  1  1    Not used
```

Worth noting directly: SG4 and SG6 share the *same* SAM V-value (000).
The SAM's divisor table only distinguishes address-timing; the SG4 vs. SG6
difference must come from elsewhere -- almost certainly the VDG's own GM
bits (see above), not the SAM. Consistent with everything traced already:
two separate chips, two separate jobs.

## Why text characters can show ANY row, not just the top (confirmed by
tracing the actual render loop)

This was the specific phenomenon described as hard to put into words --
turns out to be precisely explainable from three lines of code.

`vdg->public.row` is a **free-running 0-11 counter**, incrementing every
scanline, wrapping back to 0 after 11 -- completely independent of how
often a new byte actually gets fetched:

```c
vdg->public.row++;
if (vdg->public.row > 11) vdg->public.row = 0;
if ((vdg->public.row % vdg->nLPR) == 0)  // only fetch a new byte here
```

`nLPR` defaults to 12 (matching SG4's Y div 12 -- fetch once per 12
rows). In a SAM mode with a smaller Y divisor, `nLPR` is smaller too, so
the `% nLPR == 0` condition is true far more often -- a new byte gets
fetched on almost every scanline.

Here's the actual mechanism: **`row` itself never resets when a new byte
gets fetched.** It just keeps counting 0-11 on its own schedule, completely
oblivious to whether the current byte is old or brand new. So if a text
character happens to get fetched at the exact moment `row` is sitting at,
say, 6 -- the glyph lookup is `font_6847t1[code*12 + 6]` -- row 6 of that
letter, a horizontal slice straight through the *middle* of it, not row 0.
Which row you actually see for any given character is purely a function of
*when*, in the free-running 0-11 cycle, that particular byte happened to
get fetched -- not anything to do with the character itself, or "always the
top." That's the whole explanation, traced directly, not inferred.

## The VDG's own, separate GM register (true bitmap graphics, still CoCo 1/2)

Distinct from both the SAM's V-bits and the alpha/semigraphics path above.
`vdg->GM = (mode >> 4) & 7` -- a separate 3-bit field, and when full
graphics mode is active (`nA_G`), the SAME free-running-`row` /
`nLPR`-gated-fetch mechanism applies again, just with a different lookup
table for how many rows share one byte:

```c
GM_nLPR[8] = { 3, 3, 3, 2, 2, 1, 1, 1 };
```

**Now fully confirmed** -- this closes the "which PIA bits drive GM"
question left open above. All of CSS, GM, and nA_G turn out to live in
the exact same register already used for EXT (`$FF22`, PIA1's "B side"),
confirmed directly in `dragon.c`:

```c
void dragon_update_vdg_mode(struct dragon *md) {
    unsigned vmode = (md->PIA1->b.out_source & md->PIA1->b.out_sink) & 0xf8;
    vmode |= (vmode & 0x10) << 4;   // reuses the same EXT bit
    mc6847_set_mode(md->VDG, vmode);
}
```

Full bit mapping of `$FF22`, all one register:

```
bit 3 (0x08)   CSS   -- green/amber select (-> CSSb -> text_border_colour etc.)
bit 4 (0x10)   EXT   -- character set selection (the bit already tested
                         directly tonight, via POKE &HFF22)
bits 4-6 (0x70) GM   -- 3-bit graphics mode; GM & 2 specifically drives
                         inverse_text
bit 7 (0x80)   nA_G  -- alpha/semigraphics mode vs. true bitmap graphics
```

Clean architectural split, confirmed rather than assumed: **PIA1
controls how the VDG interprets whatever byte it's currently looking
at** (palette, text-vs-graphics, inversion) -- entirely separate from
**the SAM**, which only controls which byte gets fetched and when (the
V2V1V0 addressing-timing mechanism above). Two chips, two genuinely
distinct jobs.

## GIME (CoCo 3): confirmed to be a genuinely different mechanism, not
just an extension

```c
gime->BP = val & 0x80;      // 0=text, 1=graphics -- direct bit, not inferred
gime->LPR = val & 7;        // Lines Per Row, written directly
LPR_rowmask[8] = { 0, 1, 2, 8, 9, 10, 11, 16 };
```

**Now fully cross-confirmed** against Tim Lindner's reference, register
`$FF98` (Video mode register), bits 2-0 -- and it turns out text and
graphics modes get genuinely *different* row-count tables, not one shared
table:

```
        Text mode              Graphics mode
000       1                      1
010       2                      2
011       8                      7
100       9                      8
101      10                      9
110      11                     10
111       infinite               infinite
```

XRoar's `LPR_rowmask` array (`{0,1,2,8,9,10,11,16}`) matches this closely
-- the trailing `16` is almost certainly a sentinel standing in for
"infinite" rather than a literal row count, since infinite isn't
representable as a finite number directly.

GIME's row-count is a **direct, deliberately-chosen value** written straight
into a register -- not an emergent side effect of address-timing divisors
the way the SAM produces it. This is a real, structural difference, not
just GIME being "the same thing but nicer." **Still not verified:** whether
GIME's own row-counter has the same "keeps running regardless of actual
fetch timing" property that causes the SG8-style mid-character text
slicing on CoCo 1/2. Given the mechanism looks more deliberate and direct
here, my honest guess is that specific artifact may not reproduce the same
way on CoCo 3 -- but that's a guess, not something traced yet.

## GIME-X and GIME-Z: community FPGA replacements (confirmed real, both
distinct projects)

Both are real, physical, purchasable products -- not software emulation
projects, actual FPGA-based chips that plug into a real CoCo 3's GIME
socket:

- **GIME-X** -- Gary Becker (Verilog/FPGA design, also behind the
  CoCo3FPGA project) and "Zippster" (hardware/PCB), documented at
  thezippsterzone.com. Confirmed additions beyond stock GIME: NTSC
  encoder plus composite/s-video output, support for >512K memory, and
  new video modes including 640x225-16 color, 320x225-256 color, and
  640x112-256 color -- resolutions/depths the original GIME never
  supported at all.
- **GIME-Z** -- a separate project, "AC's 8-bit Zone" (sold via
  cocobits.org). Confirmed to exist and be a real, distinct product;
  have not yet found detailed technical documentation on its specific
  feature set the way GIME-X's is documented.

**Confirmed, real addition specific to GIME-X:** a new register at `$FFEF`
("GIME-X information byte") that stock GIME never had -- major/minor
version bits plus a memory-type flag (DDR vs. SDR). This is genuinely
useful for the character-dump tool's mode-detection idea above: software
can read this register to tell whether it's running on real/emulated
stock GIME vs. GIME-X specifically, rather than guessing.

**Not yet verified, and the actual open question this whole section was
chasing:** the claim that GIME-X/GIME-Z do "a more complete job of
simulating SG modes" specifically. What's confirmed so far is real, new
*graphics* modes beyond stock GIME's repertoire (640x225-16, etc.) -- I
have not yet found a source specifically describing improvements to SG4/
SG6/SG8/SG12/SG24 fidelity, or fixes to known real-hardware GIME
quirks/bugs in those modes. Worth a dedicated follow-up search rather than
assuming the graphics-mode additions and the SG-mode improvements are the
same thing.

## GET/PUT are provably mode-blind -- confirmed directly from the ECB 1.1 ROM disassembly (2026-09-01)

Long-standing question, now settled by tracing the actual routines rather
than inferring from behavior: **does classic `GET`/`PUT` know or care
which display mode (SG4/SG8/SG12/SG24/PMODE) is actually active when it
copies bytes?** Answer: no, and it structurally *can't* -- there's nowhere
for that knowledge to live.

Both `GET` ($9755) and `PUT` ($9758) funnel through the same shared
address-computation routine, `L9298`, before doing any byte copying
(confirmed in `reference/xls-conversion/listings/ecb-1.1/`,
chunks `ecb_03000-03599.csv` and `ecb_02400-02999.csv`):

```
L928F  LDA  PMODE        ; read the STORED mode number -- whatever
                          ; BASIC's own PMODE statement last set
       ASLA               ; x2, word-sized table entries
       LDU  A,U            ; jump-table lookup
       RTS
L9298  BSR  L928F          ; go get the jump address
       JMP  ,U             ; jump into ONE of five fixed routines

L929C  FDB  L92A6          ; PMODE 0
L929E  FDB  L92C2          ; PMODE 1
L92A0  FDB  L92A6          ; PMODE 2
L92A2  FDB  L92C2          ; PMODE 3
L92A4  FDB  L92A6          ; PMODE 4
```

Five entries. `PMODE` 0 through 4, full stop -- no sixth entry, no
mechanism by which one could exist for SG12/SG24 or any semigraphics
mode. The `PMODE` variable this jump table reads only ever means "which
of BASIC's five real graphics resolutions did a `PMODE` statement last
select" -- it has zero representation for "the SAM/VDG registers have
since been hand-flipped into an undocumented reinterpretation via raw
pokes." `GET`/`PUT`'s addressing math (row-byte-count in `HORBYT`,
pixels-per-byte via a fixed number of `LSRB`s -- three for PMODE4's
2-colour/8-per-byte, two for PMODE 1/3's 4-colour/4-per-byte) is baked
into which of those five routines got selected, and stays fixed at
whatever it was computed as under the *last real `PMODE` statement* --
completely oblivious to any hardware trick applied afterward.

This is exactly why HERO's SG12 hack works at all: it draws using an
ordinary `PMODE 4` (2-colour, 8 pixels/byte, 32 bytes/row) so `GET`/`PUT`
keep doing PMODE4's own mundane, correct addressing the entire time --
the reinterpretation only happens downstream, at VDG scan-out, which
`GET`/`PUT` never touches. HERO's own collision formula,
`U = PY*32 + PX*.125`, is PMODE4's addressing math typed out by hand;
the fact that 32 bytes/row and 8 pixels/byte happen to match SG12's real
hardware row geometry is the entire trick, not a coincidence GET/PUT is
aware of.

**Practical consequence, worth stating plainly:** "does compiler/runtime
X support GET/PUT for SG mode Y" was never really a coherent question to
begin with -- not for DECB, not for any compiled-BASIC toolchain. No
implementation of GET/PUT anywhere has ever been "SG-aware," because the
real ROM never was either. What actually matters for any hand-rolled
replacement (this project's own `writerow`/`fillrow`, or an equivalent
built on another toolchain) is only whether its addressing math matches
the *target* mode's real row-byte-count and pixels-per-byte -- a
geometry question, fully answerable from the SAM's real V2V1V0 buffer
table earlier in this document, not a "mode support" question at all.

## Terminology: these are "quadrant" characters, not an ad-hoc description

Confirmed via Unicode's own charts (`Block Elements`, U+2580-U+259F):
the 2x2 four-cell mosaic subdivision semigraphics modes use --
upper-left, upper-right, lower-left, lower-right sub-cells within one
character position -- has a real, precise name: **quadrant**. Unicode
has had dedicated code points for exactly this concept since 1999
(`U+2598` QUADRANT UPPER LEFT, `U+259D` QUADRANT UPPER RIGHT, `U+2596`
QUADRANT LOWER LEFT, `U+2597` QUADRANT LOWER RIGHT, plus all
combinations). Worth knowing the sibling term to *avoid* here: "sextant"
is the Unicode committee's name (coined "by analogy with quadrant") for
teletext's denser *2x3*, six-cell mosaic scheme -- a different standard.
The VDG's semigraphics glyphs are quadrant characters, not sextant ones.
Use "quadrant sub-cell" going forward instead of describing the
subdivision by hand -- `FUTURE.md`'s existing "four quadrant sub-cells"
phrasing already independently landed on the correct term.

**Also confirmed directly and worth stating precisely:** the 2x2
quadrant subdivision is a VDG scan-out-time rendering choice about how
to paint *one character cell* -- it is never a real increase in
addressable resolution. The **32-characters-per-line limit is fixed
regardless of SG mode** (SG4/SG8/SG12/SG24 all still address 32 cells
per row; higher SG numbers add vertical resolution via smaller SAM Y
divisors -- see the V2V1V0 table above -- not more horizontal cells).
The subdivision is real pixels on the actual CRT, but it is entirely a
VDG-side illusion from the addressing/byte-layout side: nothing about
how bytes are fetched or laid out in RAM changes because of it.

## The SAM's write-only bit registers: confirmed mechanism, no settled community name

Directly confirmed from the real Motorola MC6883 SAM datasheet (via
Scribd-hosted copy), in almost exactly the words used informally
earlier in this project:

> To set any one of these 16 bits, the MPU simply writes to a unique
> odd address (within $FFC1 through $FFDF). To clear any one of these
> 16 bits, the MPU simply writes to a unique even address (within
> $FFC0 through $FFDE). **Note that the data on the MPU data bus is
> irrelevant.**

So every `STA $FFDF`/`STA $FFDE`-style poke used throughout this
project's SG12 work (and in the classic Hogg-1982/Rainbow-1987
ROM-shadow routines) genuinely only depends on the *address*, never the
value written -- confirmed from the primary source, not folklore. No
single widely-agreed proper name for the technique was found in general
EE literature beyond generic description ("address-decoded set/clear
register," "one-address-per-bit register") -- worth noting as an open
naming question rather than inventing a term for it.

## Byte-boundary discipline: a real, hardware-forced constraint, not just a speed trick

Confirmed directly from the same `L92B1`-`L92C0` addressing code traced
above: converting a horizontal pixel coordinate to a byte offset uses
`LSRB` (discarding the low 3 bits) then `ANDA #$07` to recover the
sub-byte bit position for masking. Any x-coordinate that's a multiple of
8 skips that masking work entirely -- long-known CoCo PMODE folklore as
a *speed* optimization. But it's more than that once hand-rolling a
`get`/`put` equivalent for a semigraphics buffer specifically: a "pixel"
in an SG-reinterpreted buffer isn't a bit anymore, it's a whole
quadrant-coded byte carrying color+pattern for 4 sub-cells at once.
Straddling a byte boundary mid-quadrant would genuinely corrupt the
image, not just cost cycles -- byte-boundary alignment is a
**correctness** requirement for any hand-rolled SG-mode blitter, not
merely a performance nicety the way it is for ordinary PMODE work.

## Toward simulating this in the character-dump tool

Three real hooks the memory inspector could use, each already partially
verified to exist:

1. **Mode detection**: reading the SAM's actual V-register and the VDG's
   GM bits (both real, addressable state, same pattern as the `$FF22`
   EXT-bit read already used for lowercase detection) would let the tool
   auto-detect which mode is currently active, rather than requiring the
   user to tell it.
2. **Mode-aware rendering**: the existing alpha/semigraphics decode already
   handles SG4 correctly. Higher SG modes would need the same free-running
   `row`-counter behavior modeled explicitly -- for a given screen address
   and its neighbors, compute which font row *would* have been showing at
   that scanline position, rather than assuming row 0.
3. **User-controlled mode override**: since this is a static memory
   inspector rather than a live raster simulation, letting the user
   explicitly pick "simulate as SG4 / SG8 / SG12 / PMODE N" and re-render
   the same bytes under that assumption seems more useful than trying to
   read live hardware mode state moment to moment -- lets someone
   experiment with "what would this same data look like under a different
   mode" directly, which real hardware can't offer at all.

## Open threads for next research pass

- The actual open question from this session: does GIME-X/GIME-Z improve
  SG-mode fidelity specifically, or just add new graphics modes/resolutions
  beyond stock GIME's repertoire? Confirmed real new modes (640x225-16,
  etc.); have not found a source specifically about SG4-24 improvements.
- Check whether GIME's own row-counter shares the SAM's free-running
  property (the mechanism behind the mid-character text slicing) -- the
  more direct, deliberate LPR register design suggests it might not, but
  that's a guess, not confirmed.
- Detailed GIME-Z technical documentation -- confirmed to exist as a real
  product, haven't yet found a feature-by-feature reference the way
  GIME-X's is documented at thezippsterzone.com.
- The "undocumented/unsupported" SG variants mentioned (SG1 naming
  confusion, and others not yet identified) -- specific research target,
  not yet investigated at all.
