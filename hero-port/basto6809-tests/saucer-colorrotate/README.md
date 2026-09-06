# In-place colour rotation, verified via direct memory reads

The actual "drop to assembly" implementation of the idea discussed
earlier: instead of `PNGtoCCSB -aN` baking N complete duplicate
sprite bitmaps (one per colour -- confirmed earlier this session as
the direct cause of the LOADM size-ceiling failures), this recolours
the *existing* compiled sprite bytes in place, using self-modifying
code.

## Why this works: colour and shape are separate bit fields

Confirmed by inspecting the compiler's own generated output
(`SAUCER_ONE.asm`): every "dome" character cell compiles to the
identical literal byte `$BF` baked in as an `LDA #$BF` immediate
operand (semigraphics flag + colour 3 + full on-pattern); every
"disc" cell compiles to `$CF` (colour 4, same pattern). Since colour
lives in bits 4-6 and shape/pattern lives in bits 0-3, and every dome
cell currently holds one shared value, recolouring is a flat
find-and-replace over a known address range -- no per-pixel mask
table needed, contrary to what seemed necessary before actually
looking at the generated code.

```
' ADDASSEM:
        LDA   _Var_DOMENEXT+1   ; new colour byte
        LDX   #SAUCER_ONE_0_0   ; start of the sprite's own compiled draw code
RecolorScan:
        CMPX  #SAUCER_ONE_0_1   ; end boundary (compiler-generated label)
        BEQ   RecolorDone
        LDB   ,X
        CMPB  _Var_DOMECUR+1    ; does this byte match the CURRENT dome colour?
        BNE   RecolorSkip
        STA   ,X                ; yes -- swap in the new one
RecolorSkip:
        LEAX  1,X
        BRA   RecolorScan
RecolorDone:
' ENDASSEM:
```

`SAUCER_ONE_0_0`/`SAUCER_ONE_0_1` are the compiler's own generated
labels (one alignment variant of the sprite's draw routine) --
referenced directly by name from inline assembly, the same way the
manual's own examples reference `_Var_name`.

Result: 16413 bytes total, *smaller* than the old 2-frame baked
version (19380 bytes) despite doing something the old version
couldn't (arbitrary colour, not just 2 pre-baked choices) -- direct
proof the duplicate-frame approach was the expensive part, not the
sprite itself.

## The bug that cost the most time: 8-bit ops on 16-bit variables

First version used `LDA _Var_DOMENEXT` / `CMPB _Var_DOMECUR` directly
-- compiled clean, ran without error, and silently never recoloured
anything. `DIM ... AS INTEGER` variables are 16-bit (confirmed
directly: `_Var_DOMECUR RMB 2` in the compiled listing), stored
big-endian (high byte at the base address, low byte at +1 -- matches
`STD`'s own natural byte order). An 8-bit `LDA`/`CMPB` against the
base address reads the *high* byte, which is `$00` for any value
under 256 -- so the comparison against `$BF` could never match.
Fixed by addressing `_Var_DOMENEXT+1` / `_Var_DOMECUR+1` (the low
byte) instead.

Confirmed both the bug and the fix by reading the actual byte at
`$2DEB` (a known dome-cell operand) directly out of running memory,
polling repeatedly -- broken version: static at `$BF` across 6+
seconds of real runtime; fixed version: `$AF -> $DF -> $FF -> $AF ->
...`, a genuine repeating cycle. Not inferred from a screenshot --
read directly via `wasm_read_byte` through the WASM debugger's
`Module.ccall` interface (headless Chromium + Playwright), the same
tool the project's own maintainer pointed at partway through this
session.

## What's not built yet

- Only the dome recolours; the "clamshell" spinning-illusion effect
  (a shifting multi-colour sequence across the disc, not a flat
  colour swap) is designed conceptually but not implemented.
- X position is fixed. Moving it would eventually cross a
  byte-alignment boundary and start using the sprite's *other*
  compiled variant (`SAUCER_ONE_0_1`), which this recolour routine
  doesn't touch -- would need either a second scan targeting that
  variant too, or restricting movement to stay within one alignment.
- Wall-hit sound: not attempted.
