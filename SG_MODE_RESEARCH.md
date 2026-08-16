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

This is the register BASIC's `PMODE` command is presumably setting
(likely via specific PIA bit writes, same general pattern as the `$FF22`
EXT bit found earlier -- not yet directly confirmed which exact PIA
bits map to GM, worth checking before building on this specifically).

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
- Find which PIA bits actually drive the VDG's GM register (same pattern
  as the confirmed `$FF22`/EXT discovery, not yet done for GM).
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
