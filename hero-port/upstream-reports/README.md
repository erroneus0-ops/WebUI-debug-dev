# Upstream bug reports (ugBASIC)

Draft bug reports for real, verified issues found in ugBASIC while working
on the HERO port, kept here so they're not lost in an ephemeral session --
not filed upstream automatically (no push access to spotlessmind1975/ugbasic,
and filing a bug report on someone else's behalf isn't something to do
without a human actually reading and posting it themselves).

## Status

Three filed and confirmed live on GitHub as of 2026-08-20, three more
drafted and pending:

- `ugbasic-poke-broken.md` -- filed as
  [issue #1248](https://github.com/spotlessmind1975/ugbasic/issues/1248).
  POKE fails to compile at all for the coco target (confirmed via
  minimal repro: even a completely bare `POKE 4096, 9` fails silently).
- `ugbasic-peephole-autoincrement-bug.md` -- filed as
  [issue #1247](https://github.com/spotlessmind1975/ugbasic/issues/1247).
  The peephole optimizer silently deletes non-redundant `STA ,X+`
  (auto-increment) stores, plus a related feature request for a
  block-scoped "don't optimize this" directive for inline assembly, and
  a documented STRPTR()-based workaround that sidesteps the bug entirely
  (rather than just disabling optimization globally).
- `ugbasic-string-concat-chain-limit.md` -- filed as
  [issue #1249](https://github.com/spotlessmind1975/ugbasic/issues/1249).
  A separate bug found while building the STRPTR workaround above:
  chaining more than ~15 string concatenations in one expression
  silently corrupts the result, with zero error at compile or run time.
- `ugbasic-uppercase-identifier-bug.md` -- **not yet filed upstream**.
  Any identifier starting with an uppercase letter fails to parse at
  all, regardless of whether it resembles a keyword.
- `ugbasic-get-put-image-valuebuffer-gap.md` -- **not yet filed
  upstream**. Classic `GET(x,y)-(x2,y2),name` doesn't set the image's
  `valueBuffer`, so `PUT` always reports "uninitialized image
  variable" immediately after a successful `GET`.
- `ugbasic-peephole-forces-immediate-on-procedure-locals.md` -- **not
  yet filed upstream**. A procedure-local value computed from a
  parameter (e.g. `addr = STRPTR(data$)`) gets its *read* silently
  replaced with a hardcoded immediate placeholder by the peephole
  optimizer, disconnected from the real per-call computation --
  confirmed fixed by `-p 0`, not fixed by pre-declaring the local with
  `DIM`. Also documents a related but distinct bug found in the same
  investigation: untyped procedure parameters default to a 16-bit
  word, and reading them with an 8-bit register load silently reads
  the wrong byte -- fixed by declaring the parameter `AS BYTE`, not by
  `-p 0`.

Update this file (or just delete the relevant entry) once either of these
has actually been posted to https://github.com/spotlessmind1975/ugbasic/issues.
