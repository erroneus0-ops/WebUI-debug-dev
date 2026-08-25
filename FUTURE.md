# WebUI-debug-dev -- Future Plans

## XRoar WASM debugger integration

**XRoar WASM (Ciaran's emulator)**
Extended incrementally to support robust debugging:
- Load and run programs directly from the browser environment
- Debugger integration: breakpoints, register inspection, memory view
- Comment file support: display commented assembly source alongside
  disassembly in the debugger (lst2cmt, from the cocotools-wasm repo,
  produces these -- this is the bridge between source and running code)
- Goal: edit source → assemble → load into XRoar → debug with source
  comments visible, all without leaving the browser

**Debugger feature scope (2026-08-09), Daniel's own list plus common
features he hadn't named yet but confirmed wanting in scope too:**
- Browse and modify memory (wasm_read_byte/write_byte already exist)
- Check registers (6 register-getters already exist)
- Set breakpoints -- plain and conditional (break only when a given
  register/memory condition holds, not just at a fixed address)
- Watchpoints -- distinct from passively checking a value: halts the
  moment a specific memory location actually changes
- Step through instructions -- step into / step over / step out,
  the refinement that matters once subroutine calls are involved
- Register modification, not just reading -- set a register to a
  specific value while paused, to test "what if this were X instead"
- Call stack / backtrace -- the chain of subroutine calls that led
  to the current point, walking return addresses
- Cycle counting -- genuinely relevant for 6809/CoCo work specifically,
  since real code often has to fit a hard timing budget (a scanline,
  a frame) in a way that doesn't matter on modern hardware
- "Variables" for watching -- memory locations plus decode/display,
  which is exactly what wasm_read_byte + lst2cmt's source-symbol
  mapping already gives: knowing "the byte at $0400" is a named
  variable from the assembly listing, not just a bare address

Much of this is likely already implemented internally in XRoar's
native build (breakpoint.c and single-step execution have to exist
for native GDB remote debugging to work at all; snapshot.c -- state
save/restore, letting a scenario be replayed rather than re-run from
scratch -- also already exists in the source). The actual work is
probably exposing existing internal capability through new wasm_*
exports, following the same pattern as the 9 that already exist, not
building debugger logic from scratch.

**Specific planned experiment: VDG green/amber dual-mode display.**
Daniel wants to control VDG output mode (green vs. amber) with precise
timing to display both modes simultaneously -- this depends directly
on having register read/write access to whatever actually controls
VDG mode. Worth confirming which register that is before assuming: on
the original CoCo 1/2, the MC6847 VDG has no CPU-addressable registers
at all -- mode is controlled via PIA0 output lines instead. On CoCo 3
with the GIME chip specifically, there are genuine memory-mapped GIME
configuration registers that include video mode control. Since this
project's emulation target is CoCo 3 (per emcc_workflow/xroar's
coco3.c, the CoCo 3 keyboard SVGs), GIME's memory-mapped registers are
the more likely mechanism -- but this should be confirmed against the
actual source before building the experiment around it, not assumed.

**Memory editing, not just viewing (found 2026-08-25).** During live
diagnosis of the hero-port INKEY/TIMER hang, confirmed via hex dump that
the compiled program halts on a genuine `BRA *` self-loop ($20 $FE) at
the end of its run -- deliberate codegen, not a crash. Wanted to poke a
single `RTS` ($39) over it right there in the debugger to test the fix
live, but the current wasm_read_byte/write_byte pair (see above) isn't
exposed anywhere in the debug UI itself -- only used internally. Worth
adding: pull a block of memory from the hex dump view, edit bytes in
place, and a "write back" action that calls wasm_write_byte for each
changed byte. Doesn't need to be fancy -- editable hex dump cells plus
one button is enough to turn read-only inspection into actual live
patching during a debug session.

**"Print to file" support (found 2026-08-25).** Desktop XRoar has this
under File > Printer Control: a "print to file" radio button, an
Attach button to pick/create the target file, a running "characters
printed" counter, and a Flush button. No equivalent exists in the WASM
build. Worth investigating some form of this for the browser --
whether that's a visible output text window, routing print output into
the same stream as debugger output, or building toward an actual
downloadable-file save mechanism. Any of the three would close a real
gap between the native and WASM builds.

**"Load" should accept headerless/zero-address .bin files too (found
2026-08-25).** The web UI's Load function already handles snapshots and
proper DECB-format .bin files (5-byte header: $00 preamble, 2-byte
length, 2-byte load address, ..., $FF marker, 2-byte exec address) --
confirmed working by side-loading a raw ugbc.coco -O bin output directly,
skipping the .dsk/LOADM step entirely for quick single-binary tests.
Worth extending Load to also accept: (1) truly headerless raw binary
dumps (no metadata at all -- would need a way to ask the user for a
load address), and (2) files whose header technically specifies $0000
as the load address, which some tools use as a "no relocation info,
caller decides" convention rather than a literal instruction to load at
address zero.

Confirmed via the WASM UI's own Help > toolbox [...] log after a real
side-load: it correctly loads the bytes and reports the right exec
address, but a bare `EXEC` (no parameter) afterward doesn't work --
only `EXEC <addr>` does. Root cause: the side-load path pokes bytes
into RAM directly without updating `EXECJP` (\$9D, 2 bytes,
high-byte-first -- "*PV JUMP ADDRESS FOR EXEC COMMAND", per
memory-map-decb.csv), which is the specific variable a real `LOADM`
sets and bare `EXEC` reads. Fix: have the side-load routine write the
header's exec address into \$9D/\$9E the same way LOADM does, so bare
`EXEC` works identically after either loading method.

### The lst2cmt connection

lst2cmt (built in the cocotools-wasm repo) converts an lwasm listing
file to an XML comment file that XRoar's debugger (and MAME) can load
alongside the disassembly. This is the mechanism that makes
source-level debugging possible:
  assemble with --list → lst2cmt → load .xml into XRoar debugger
  → step through code with original source comments visible

This is the most powerful debugging workflow available without a
full IDE. Worth building toward explicitly.
