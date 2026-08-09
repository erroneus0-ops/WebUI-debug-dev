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

### The lst2cmt connection

lst2cmt (built in the cocotools-wasm repo) converts an lwasm listing
file to an XML comment file that XRoar's debugger (and MAME) can load
alongside the disassembly. This is the mechanism that makes
source-level debugging possible:
  assemble with --list → lst2cmt → load .xml into XRoar debugger
  → step through code with original source comments visible

This is the most powerful debugging workflow available without a
full IDE. Worth building toward explicitly.
