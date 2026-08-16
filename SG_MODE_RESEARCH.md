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

**Not yet verified:** which exact V2V1V0 value the community names "SG8"
vs. "SG12" vs. specific PMODE numbers correspond to. I have the real
divisor table; I do not yet have a confirmed source mapping those divisor
values to the conventional mode names. Worth treating any specific
"V=001 is SG8" claim (mine or anyone else's) as unverified until checked
directly -- exactly the kind of detail that's easy to get subtly wrong.

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

GIME's row-count is a **direct, deliberately-chosen value** written straight
into a register -- not an emergent side effect of address-timing divisors
the way the SAM produces it. This is a real, structural difference, not
just GIME being "the same thing but nicer." **Not yet verified:** whether
GIME's own row-counter has the same "keeps running regardless of actual
fetch timing" property that causes the SG8-style mid-character text
slicing on CoCo 1/2. Given the mechanism looks more deliberate and direct
here, my honest guess is that specific artifact may not reproduce the same
way on CoCo 3 -- but that's a guess, not something traced yet, and worth
checking before stating it as fact.

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

- Confirm the actual V2V1V0-to-SGn name mapping from a source, not memory.
- Find which PIA bits actually drive the VDG's GM register (same pattern
  as the confirmed `$FF22`/EXT discovery, not yet done for GM).
- Check whether GIME's row-counter shares the SAM's free-running property.
- The "undocumented/unsupported" SG variants mentioned (SG1 naming
  confusion, and others not yet identified) -- specific research target,
  not yet investigated at all.
