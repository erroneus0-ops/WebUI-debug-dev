# Upstream bug reports (ugBASIC)

Draft bug reports for real, verified issues found in ugBASIC while working
on the HERO port, kept here so they're not lost in an ephemeral session --
not filed upstream automatically (no push access to spotlessmind1975/ugbasic,
and filing a bug report on someone else's behalf isn't something to do
without a human actually reading and posting it themselves).

## Status

- `ugbasic-poke-broken.md` -- **not yet filed upstream**. POKE fails to
  compile at all for the coco target (confirmed via minimal repro: even a
  completely bare `POKE 4096, 9` fails silently).
- `ugbasic-peephole-autoincrement-bug.md` -- **not yet filed upstream**.
  The peephole optimizer silently deletes non-redundant `STA ,X+`
  (auto-increment) stores, plus a related feature request for a
  block-scoped "don't optimize this" directive for inline assembly.

Update this file (or just delete the relevant entry) once either of these
has actually been posted to https://github.com/spotlessmind1975/ugbasic/issues.
