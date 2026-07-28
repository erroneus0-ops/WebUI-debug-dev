# Notes toward a patch submission for Ciaran Anscomb (XRoar)

Working notes only. Nothing here has been sent. This file exists so that
by the time something *is* ready to send, it's a considered, respectful
submission rather than a rushed dump of everything that got touched along
the way.

## Context, for whenever this actually gets sent

This project is AI-assisted throughout, but every decision in it -- what
to change, what to leave alone, what needs explaining before it gets
touched at all -- has been Daniel's call. Worth saying plainly up front
in whatever actually gets sent to Ciaran, not glossed over: given how much
concern exists right now about AI-generated contributions landing on
maintainers uninvited, the honest framing is also the respectful one.

## Diff baseline

**Update 2026-07-28:** Ciaran released 1.12 then 1.12.1 in quick succession
(2026-07-27, per his own Discord post and confirmed directly against the
live site). Our working tree (`xroar/`) and everything below is still
pinned to 1.11 -- each remaining item needs re-checking against
`xroar-1.12.1/` (now also in the repo) before anything is submitted,
the same way item 1 below just got re-checked and turned out to already
be fixed. Given the scale of the 1.12 changes (register handling
reworked from a fixed table to "defined per-machine"), don't assume any
of the remaining items still apply cleanly -- check each one the same
careful way, file by file, before trusting old notes.

Comparing our working tree (`xroar/`, based on XRoar 1.11) against a
pristine copy of the same release (`xroar-1.11/`, fetched directly from
`https://www.6809.org.uk/xroar/dl/xroar-1.11.tar.gz`). Excluded from
consideration entirely: autotools-regenerated build files (`Makefile.in`,
`config.h.in`, `aclocal.m4`, `autom4te.cache/`, `compile`, `config.guess`,
`config.sub`, `depcomp`, `install-sh`, `missing`, `ar-lib`,
`doc/mdate-sh`, `doc/texinfo.tex`) -- these only differ because our local
`autogen.sh` run regenerated them with whatever autotools version happens
to be installed in the build environment, not because of any deliberate
change. Also excluded: stray local artifacts (`a.wasm`, `config.h.in~`,
`.gitignore` additions) that shouldn't be committed at all, let alone
submitted anywhere.

## 1. gdb.c -- off-by-one in send_packet_hexstring (RESOLVED UPSTREAM -- DO NOT SUBMIT)

**Status:** Ciaran independently fixed this exact bug in 1.12/1.12.1, before
we ever had a chance to submit it. Confirmed 2026-07-28 by diffing our
patched gdb.c against the fresh xroar-1.12.1 source: his fix is
`xmalloc((count * 2) + 1)` + `snprintf(hsp, 3, "%02x", (uint8_t)string[i])`
-- essentially identical to what we wrote independently. Good
confirmation the original finding was real and correct; nothing left to
submit here. This sits inside what looks like a much larger internal
rework in 1.12 (register handling changed from a fixed table to
"defined per-machine", matching the "target description sent to GDB"
changelog note) -- almost certainly unrelated to us, just two people
finding the same small bug during unrelated close reading of the same
function.

**What it was, for the record:** `send_packet_hexstring()` allocated a
buffer sized exactly for the hex-encoded output (`count * 2` bytes), but
the final `sprintf` call in the encoding loop also writes a null
terminator, landing one byte past the end of that allocation, every
time the function is called. Real, always-triggered, but low impact in
practice given the function's only two callers at the time (both
printable-ASCII only). Now moot -- fixed upstream, in our tree, and
this note stays only as a record of what was found and confirmed.

## 2. portalib/sds.c / sds.h -- defensive NULL-checks (RESOLVED UPSTREAM -- DO NOT SUBMIT)

**Status:** confirmed 2026-07-28 against fresh xroar-1.12.1. Ciaran did a
broader null-check hardening pass across sds.c between 1.11 and 1.12 --
seven `current == NULL` guards and four `join == NULL` guards, not just
the three we'd found. Our finding was a strict subset of his more
thorough version; he even caught an intermediate case we'd missed
(checking `join` again immediately after an `sdscat` call inside a loop,
not just at the outer two spots). sds.h's `FUNC_ATTR_NONNULL_V(2)`
addition is now identical between our tree and 1.12.1 too. Nothing left
to submit -- resolved more completely than we'd have proposed it.

## 3. xroar.c -- "type"/"trace" serialization comment (NEVER A CUSTOM CHANGE -- explained, not just resolved)

**Status:** this was never something anyone added to our tree. Confirmed
2026-07-28: Ciaran's own 1.12.1 has the identical comment, word for word
-- `// Not emitting "type" (startup-only, assumed command-line only)`.
Diffing 1.11 against 1.12.1 shows this is upstream's own change,
introduced somewhere in the 1.11->1.12 development cycle. Our tree
already had it before we ever compared against 1.12.1, which means our
base `xroar/` checkout was built from a git snapshot somewhere between
the 1.11 and 1.12 releases -- not strictly the 1.11 tarball -- and
happened to already include this bit of his in-progress work. There
was never a mystery custom change here to explain; it's simply his own
code. Nothing to submit.

## 4. mpi.c -- mpi_free removal (SAME EXPLANATION AS #3 -- never custom, resolved)

**Status:** identical situation to item 3, confirmed the same way.
Diffing 1.11 against 1.12.1 shows Ciaran himself removed `mpi_free()`,
its forward declarations, the `.free = mpi_free` vtable wiring, and the
`mpi_active` static variable between those releases. Diffing our tree
against 1.12.1 shows we already match his 1.12.1 state exactly on this
point (the only remaining differences are an unrelated `_Bool`->`bool`
modernization sweep he did across the file). So this was never a
custom removal to characterize or worry about -- same as item 3, our
base checkout already included this upstream change before we went
looking for an explanation. Nothing to submit.

## Where this leaves things (updated 2026-07-28)

All four original findings are now resolved or explained, and none of
them are worth submitting: two (gdb.c, sds.c) turned out to be bugs
Ciaran found and fixed independently, in some cases more thoroughly
than our own fix; two (xroar.c, mpi.c) turned out to never be custom
changes at all -- just upstream's own in-progress work that our base
checkout happened to already include. The only thing left in this whole
project that's genuinely ours to potentially discuss with Ciaran is the
WASM debug/register accessor work below -- a real feature addition, not
a bug fix, and the one thing here that didn't turn out to already exist
in some form upstream.

## The WASM debug/register accessors (still the one live item)

`wasm_read_byte`, `wasm_write_byte`, `wasm_get_pc/cc/a/b/x/y/s` in
`src/wasm/wasm.c` + `wasm.h` + `src/wasm/exported_functions`. Not a bug
fix -- a feature addition, built for a future in-browser monitor/debugger
page. Clean, additive, doesn't touch existing behavior. Worth noting:
1.12's changelog includes "New option -gdb-pseudo-regs exposes more
state as faux registers to GDB" -- conceptually adjacent to this work
(more CPU state exposed for debugging purposes) but via a completely
different mechanism (GDB remote protocol, requiring a separate debugger
client, versus direct in-process WASM function calls for an in-browser
UI with no separate process involved). Worth understanding that new
option properly before deciding whether our approach is complementary,
redundant, or should change shape -- not yet investigated.
