# "I wasn't clear to Claude, so he did it the hard way" -- the original 3-sprite saucer

Preserved as a labeled historical artifact, not a live demo -- this is
the literal, over-decomposed first attempt at "flying saucer with a
dome, an arc on top, an arc on bottom": three separate sprite objects
(`ARC_TOP`, `ARC_BOTTOM`, `DOME_ORIGINAL`, the last with a 2-frame
blink), individually loaded and layered with manually-tuned Y offsets.

**It fails.** `SAUCER_STRUGGLE.dsk` boots to `?IO ERROR`, confirmed
freshly rebuilt and re-tested locally (2026-09-05) via a real XRoar
build pinned to the same commit CI uses -- same failure as originally
observed. Compiles to `$1E42-$C99F` / 40013 bytes.

At the time this was first hit, the failure was misdiagnosed as an
address-range problem (spilling into `$C000+`, Disk BASIC's own ROM).
That diagnosis was wrong, disproven later the same evening by a
*much* smaller single-sprite program (never anywhere near `$C000`)
failing identically. The real, only cause -- confirmed by full
instruction-trace bisection, see `hero-port/basto6809-tests/saucer/SAUCER.BAS`'s
own comments -- is a hard `LOADM` size ceiling somewhere between
21625 and 23569 bytes. This 40KB attempt was always going to fail for
that reason alone; the three-sprite decomposition (and the resulting
$C99F address) was never the actual problem, just a correlated
symptom of being too large in the first place.

The live, working demo lives one directory up, as a single sprite
with a color-cycling region -- what was actually asked for.
