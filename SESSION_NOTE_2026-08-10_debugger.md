# Session note -- debugger scaffolding (2026-08-10)

Working against FUTURE.md's "Debugger feature scope (2026-08-09)" list.
Everything below is source-level only, **not built or run** -- this
sandbox has no emscripten toolchain and can't reach the domains emsdk's
installer needs (`storage.googleapis.com`), so nothing here has touched
a browser yet. Treat it as a reviewed, syntax-checked patch, not a
tested feature. See "Validation performed" below for exactly what was
and wasn't checked, and "To actually test" for what's left before this
is real.

## What's in the patch

`wasm-debugger-session.patch`, applies against `emcc_workflow/xroar/`
and `wasm/index_new.html` from repo root (`git apply
wasm-debugger-session.patch` from the repo root, or `patch -p1 <
wasm-debugger-session.patch`).

**`src/wasm/wasm.c` / `wasm.h` / `exported_functions`:**

- `wasm_pause()` / `wasm_resume()` / `wasm_is_paused()` -- a plain flag
  checked once per frame in `wasm_ui_run()`, gating the call to
  `xroar_run()`. Deliberately *not* built on gdb.c's pause mechanism
  (pthread condvar) -- that model would block the browser's one JS
  thread, which is the wrong shape for a single-threaded WASM build.
- `wasm_step()` -- calls `machine->single_step()` directly, which
  already exists (used internally by the GDB target) and runs exactly
  one instruction synchronously. Safe regardless of the pause flag.
- `wasm_get_dp()` / `wasm_get_u()` -- fills a gap in the original nine
  register getters (DP and U were missing).
- `wasm_set_pc/cc/a/b/dp/x/y/u/s()` -- register writers, paired with
  the existing/new getters.
- `wasm_set_breakpoint(addr)` / `wasm_clear_breakpoint(addr)` -- plain
  address breakpoints via `bp_add()`/`bp_remove()` against the
  machine's `"bp-session"` interface. A 32-slot static table tracks
  which `struct breakpoint` goes with which address (needed because
  `bp_remove()` requires the exact same pointer passed to `bp_add()`).
  On hit, the handler stops the CPU's current `run()` call (mirrors
  `coco3_trap()`), sets the pause flag, and calls a JS hook
  (`wasm_on_debug_stop(reason, addr)`) via `EM_ASM` so the UI updates
  immediately rather than waiting on the next poll.

**Watchpoints are explicitly NOT included.** Traced this down properly
rather than assuming: `bp_wp_add_range()`/`bp_wp_remove_range()` exist
and look like the right call, but the hooks that actually check those
lists on memory access (`bp_wp_read_hook()`/`bp_wp_write_hook()`, and
their call sites inside `coco3.c`'s `cpu_cycle()`/`cpu_cycle_noclock()`)
are compiled out entirely unless `WANT_GDB_TARGET` is defined.
`configure.ac` hard-defaults `enable_gdb_target=no` for the WASM target
regardless of pthread availability, so in this build a watchpoint
registered via those functions would silently register and never fire
-- no error, just nothing downstream. Same failure shape as the
machine/cartridge dropdown bug already written up in
ENVIRONMENT_HANDOFF.md. Building the wasm export without fixing the
underlying gate would have shipped exactly that kind of bug, so it's
left out until there's a real fix. Two paths, not yet decided between:

1. Small patch to `coco3.c`'s `cpu_cycle()`/`cpu_cycle_noclock()` to
   check the watch lists unconditionally (or under a WASM-specific
   guard) instead of only under `WANT_GDB_TARGET`. Small, but it's a
   change to `coco3.c` rather than staying purely additive in
   `wasm.c`, which is why it wasn't just done here without asking.
2. Build with pthreads enabled so `WANT_GDB_TARGET` compiles in
   naturally. Actively **not recommended** -- would need
   `-s USE_PTHREADS=1` plus `SharedArrayBuffer`/COOP-COEP headers on
   whatever serves the page (GitHub Pages doesn't let you set those),
   and gdb.c's blocking-condvar single-step model doesn't fit a single
   browser main thread even if it compiled.

**`wasm/index_new.html`:** a new "Debug" tab, following the existing
CSS-radio-button tab pattern exactly (no new tab-switching mechanism
introduced). Pause/Resume/Step buttons, a register grid (hex, editable,
commits on blur/enter via the new setters), a breakpoint address field
with Set/Clear, and a status line. Registers only refresh while paused
(reading them every frame while running would be 9 pointless ccall()s
for values that change every instruction anyway) -- refresh happens on
a 200ms poll gated to only run when the Debug tab is actually open, plus
immediately on the `wasm_on_debug_stop` hook when a breakpoint fires.

## Validation performed

- Cloned the repo's `emcc_workflow/xroar/` tree and read the actual
  source before writing anything (breakpoint.c, mc6809.h, coco3.c,
  gdb.c, configure.ac) rather than working from FUTURE.md's summary
  alone -- the watchpoint finding above only came from doing this.
- Confirmed brace balance and no accidental duplication in the edited
  `wasm.c` (`{`/`}` counts match; only one real definition of
  `wasm_ui_run`).
- Extracted the new C code into a standalone file with faithful stub
  headers (matching the real field names/types/macros confirmed via
  grep against the actual source: `struct MC6809`, `MC6809_REG_A/B`,
  `struct breakpoint`, `struct bp_session`, `DELEGATE_AS0`) and compiled
  it with `gcc -std=c11 -Wall -Wextra -Wpedantic`: clean, zero warnings.
  This is **not** the same as compiling the real file (no
  `top-config.h`, no real `sds.h`/`machine.h`/etc., no emscripten), but
  it does catch typos, wrong field names, and type mismatches, which is
  the class of bug most likely from hand-written C against an
  unfamiliar struct.
- Tried a real native (non-WASM) build via `autoreconf` + `configure`
  to get closer to ground truth, but `wasm.c` is only compiled for the
  WASM target and needs `emscripten.h`, which doesn't exist outside
  emscripten -- so a native build doesn't actually exercise this file.
  Confirmed emsdk itself can't be installed in this environment
  (installer needs `storage.googleapis.com`, not reachable here).
- Extracted the edited inline `<script>` block from `index_new.html`
  and ran it through `node --check`: valid JS syntax.
- Ran the whole HTML file through Python's `html.parser` checking tag
  balance: no unclosed or mismatched tags.

None of this is a substitute for actually building with emscripten and
loading the page. It rules out the most likely categories of
hand-written-code mistake; it doesn't rule out logic errors that only
show up at runtime (e.g. whether `wasm_bp_hit`'s `cpu->running = 0`
actually stops execution mid-`xroar_run()` the way `coco3_trap()`'s
does, or timing issues in the pause/resume tickerr handling).

## To actually test (needs the WSL2 environment, per ENVIRONMENT_HANDOFF.md)

1. Apply the patch against `emcc_workflow/xroar/`.
2. Rebuild per the existing documented steps (`autoreconf -fi`;
   `emconfigure ./configure --enable-traps
   --host=wasm32-unknown-emscripten`; `emmake make -j$(nproc)
   GL_LIBS=""`).
3. Copy the built `xroar.wasm`/`.js` into `wasm/` alongside the patched
   `index_new.html`.
4. Load a program, set a breakpoint at a known address (e.g. somewhere
   in BASIC's input loop), confirm: the "Debug" tab shows "paused
   (breakpoint)" and register values when it's hit; Step advances PC by
   one instruction each click; editing a register field and pressing
   Enter/blur actually changes CPU state (check PC edit specifically --
   redirecting execution is the easiest one to observe); Resume
   continues normal execution and the log panel/canvas keep updating.
5. Specifically check: does hitting a breakpoint from a *fast* run
   (large `nticks` in one `wasm_ui_run()` call, e.g. after tab was
   backgrounded) resume cleanly, or does the "stop mid-`xroar_run()`"
   mechanism leave anything in an inconsistent state? This is the one
   piece of the design without a directly-confirmed precedent (coco3's
   own trap usage assumes the GDB path's per-instruction granularity
   context, not necessarily identical to a wasm frame boundary).
