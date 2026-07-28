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

## 2. portalib/sds.c / sds.h -- defensive NULL-checks (NEEDS WRITE-UP)

Three added NULL-guards in sds.c (string-handling library), plus a
`FUNC_ATTR_NONNULL_V(2)` annotation added to `sdscatvprintf`'s declaration
in sds.h. General-purpose, not WASM-specific. Looks like genuine
hardening. Still need: a clear, similarly low-key write-up once we've
confirmed exactly what scenario each guard prevents (haven't traced call
sites the way we did for gdb.c yet).

## 3. xroar.c -- config/snapshot serialization no longer emits "type" or
"trace" (NEEDS DANIEL'S CONTEXT)

Config-writing code no longer re-emits queued auto-keyboard-typing
strings (`type`) or the trace-toggle (`trace`) when serializing current
state, with an explicit comment marking both as "startup-only, assumed
command-line only." Reads like a deliberate, reasoned fix -- possibly
for a saved config that kept re-triggering the same auto-typed string on
every reload -- but I don't have the story behind it. **Waiting on
Daniel to confirm what problem this was solving before it goes anywhere
near a patch.**

## 4. mpi.c -- mpi_free removed (UNRESOLVED, DO NOT SUBMIT YET)

Our tree is missing `mpi_free()` entirely -- the function body, both
forward declarations, the `.free = mpi_free` vtable wiring, and the
`mpi_active` static variable it managed. Doesn't read as a fix; reads
like something was removed, deliberately or not. **Not characterized yet
-- do not include in any patch until this is understood.** Possible this
was an intentional simplification for the WASM build, possible it's an
accidental loss. Needs Daniel's memory of what happened here, or a closer
look at whether MPI is even reachable/relevant in a WASM build context.

## Separately: the WASM debug/register accessors (different category)

`wasm_read_byte`, `wasm_write_byte`, `wasm_get_pc/cc/a/b/x/y/s` in
`src/wasm/wasm.c` + `wasm.h` + `src/wasm/exported_functions`. Not a bug
fix -- a feature addition, built for a future in-browser monitor/debugger
page. Clean, additive, doesn't touch existing behavior. This is a
different kind of submission than the gdb.c/sds.c fixes above (a
"here's something new you might want" rather than "here's something
broken") and probably deserves its own framing whenever it's proposed,
separate from the bug-fix patches.
