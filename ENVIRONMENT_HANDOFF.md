# Environment Handoff

This file holds everything specific to **the environment** -- the
actual running system: the XRoar WASM build, the served pages
(`index.html`, `index_new.html`, `index_custom.html`), the GitHub Pages
deployment, and the CoCo3 virtual keyboard work.

Extracted out of CLAUDE_MANIFESTO.md and merged with the standalone
SESSION_HANDOFF.md (2026-07-31) as the third and final piece of
splitting project-specific content out of the manifesto, alongside
BOOK_HANDOFF.md and TOOLS_HANDOFF.md.

**This project's own completion criterion is genuinely different from
the other two.** The book finishes when its planned chapters are
written; the tools are finite and describable. The environment doesn't
finish by reaching a fixed feature list -- it finishes by reaching a
state where *change itself* is repeatable and well-understood. The
lwtools 4.24->4.25 upgrade is the model for this: the point was never
just "get to 4.25," it was using that upgrade as a designed exercise to
validate the *process* of upgrading at all. Expect this project to keep
absorbing more of what might otherwise be separate tooling as it grows
(the keyboard-fixing scripts below are an early example) -- that's
expected, not scope creep.

---

## Older history (from the manifesto, predates the keyboard work below)

## Cartridge ROM Entry Mechanisms (CoCo $C000, confirmed by direct testing)

A cartridge ROM at $C000 can be entered two genuinely different ways, and
the closing instruction MUST match the entry mechanism or the result is
silent stack corruption that can look deceptively like success.

**Path A -- FIRQ autostart (real hardware: pin 8 tied to pin 7, CART* signal)**
CPU pushes only PC (2 bytes) then CC (1 byte), then JMPs (not JSRs) to
$C000 via the FIRQ vector chain. There is no JSR-style return-address
frame. The routine MUST end in RTI to correctly restore CC (unmasking
IRQ/FIRQ) and PC. Confirmed working: clean return to BASIC's own
cold-start sequence, full register restoration, keyboard and cursor
remain live afterward.

**Path B -- manual call (EXEC &HC000 from BASIC)**
EXEC pushes a normal 2-byte return address, same as any JSR. The routine
MUST end in RTS. Using RTI here pops a fabricated "CC" byte (actually
the low byte of the real return address) and miscomputes PC from
adjacent stack bytes -- an uncontrolled jump built from misaligned
stack data. Confirmed: this can land somewhere that happens to look
like a clean result (e.g. BASIC's cold-start banner reprinting) without
actually being one. Don't trust a plausible-looking result from a
known-mismatched entry/exit pairing.

**Using RTS after FIRQ entry** (the inverse mistake): pops [CC][low byte
of PC] as a bogus return address, leaves IRQ/FIRQ masked because RTS
never restores CC. Confirmed: keyboard and cursor go dead, machine
appears frozen, because the periodic VSYNC interrupt that drives system
housekeeping never fires again.

**XRoar WASM cart-loading notes (this build, confirmed via `strings xroar.wasm`):**
- `-cart` and `-cart-type` only accept a fixed set of named hardware
  profiles: cp450, delta, dragondos, gmc, ide, mcx128, mcx128a, mooh,
  orch90, rsdos. There is no generic "rom" type.
- A bare filename passed to `-cart` (e.g. `-cart STRTEST_CART.ROM`) is
  accepted and treated as an ad-hoc ROM cart -- this is how
  `daggorat.ccc` worked with a single argument.
- `-cart-autorun no` did NOT suppress the FIRQ autostart for a
  bare-filename `-cart` load in direct testing (twice). It may only
  apply to the named hardware profiles. Software equivalent of "taping
  over pin 8" is not yet confirmed working through this argument
  combination -- worth raising with Ciaran directly, with this session's
  test results as evidence.
- Swapping the active cartridge via the Hardware tab dropdown WITHOUT a
  reset reproduces the real documented hardware hazard of hot-swapping
  a cartridge while powered on (CoCopedia FAQ: "it is extremely
  dangerous to insert a ROM-Pack with the CoCo switched on"). Confirmed:
  this can hang the emulated machine, including surviving a soft reset,
  because RAM hooks patched by the previous cart's ROM still point into
  memory now occupied by different code (or NOP padding). Always pair a
  cart change with a hard reset.
- cocotools.py `makerom` command pads a raw binary to the standard 8K
  cartridge size (8192 bytes) with NOP ($12), not $FF (SWI) -- chosen
  deliberately so that if the CPU ever wanders into the padding it
  slides through harmlessly rather than trapping.

---

## XRoar WASM Page (wasm/index.html) -- Development History

### Why a rewrite instead of incremental edits

The original page came from the upstream XRoar Online distribution
(https://www.6809.org.uk/xroar/online/) -- a single index.html with all
CSS, layout, and the XRoar control panel markup tightly interwoven. The
goal was to add a CM-8 monitor bezel overlay around the emulator canvas
and restyle the controls panel. Attempting this as incremental CSS edits
against the original markup did not work cleanly -- the existing layout
rules fought the new bezel positioning and panel restyling at every
turn, producing fragile, hard-to-reason-about results.

The decision was made to build new scaffolding from scratch (clean CSS,
new layout structure, the bezel overlay system, the controls panel
redesign) as index_new.html, then import the *functional* guts of the
original page -- the actual working JS that talks to the compiled
xroar.wasm module -- into that new scaffolding, rather than trying to
reconcile two competing sets of CSS.

### What went wrong during the import, and how it surfaced

Some functional pieces ported cleanly (file loading, the type-text
modal, keyboard capture/blur logic). Two small pieces did not survive
the port intact: the Machine and Cartridge dropdown onchange handlers.
They were small enough to look trivial and got reinvented inline
(`wasm_set_machine(value)` / `wasm_set_cart(value)`, passing string
values) instead of being copied verbatim from the original, which used
`wasm_set_int('machine', value, 1)` / `wasm_set_int('cartridge', value, 1)`
-- XRoar's compiled WASM module expects integer index values for these
two controls, not strings.

The bug was invisible for days: the dropdowns rendered correctly, the
onchange fired, there was no console error -- the calls simply did
nothing downstream. It was only caught when machine/cartridge switching
was actually exercised, well after the rewrite session ended.

**Lesson:** when porting functional code into new scaffolding, copy-paste
the wiring verbatim first, before refactoring it -- even for handlers
that look trivial. The trivial-looking ones are exactly where a
plausible-but-wrong rewrite slips in unnoticed, because nothing about
the failure is visible without specifically exercising that control.

### CM-8 bezel: PNG -> hand-patched SVG

The bezel went through several iterations (see wasm/cm8_bezel_v2.svg
through v6, and the various cm8_rebuilt_*.png files) before settling on
a fully vector approach:

1. A clean screenshot was sourced from a YouTuber's 3D CM-8 model as the
   most accurate available reference (better than any owner's-manual
   line drawing).
2. Inkscape's trace function was run against that screenshot to get a
   vector starting point -- but the trace was never going to resolve
   the TANDY label correctly (the trace artifacts inside the CRT opening
   were also a known limitation of this approach, later patched over).
3. The TANDY label was hand-crafted separately and precisely, not
   traced: Microgramma D Extended font (a close match to the real label),
   three RGB color bars drawn by hand, and the whole label group given a
   `skewY(0.41435463)` transform (arrived at by eye, iterating until it
   matched the slight off-axis angle visible in the reference photo) to
   match the perspective of the rest of the traced image.
4. Trace artifacts inside the screen opening were masked with a black
   filled path placed on top -- invisible to users since the XRoar
   canvas sits on top of the bezel's transparent screen cutout anyway
   (z-index layering: canvas behind, bezel overlay on top, canvas shows
   through the transparent CRT opening).
5. The original bitmap PNGs were removed from the SVG entirely once the
   vector version was complete -- wasm/cm8_bezel.svg is now the single
   source of truth for the bezel, referenced directly in index.html's
   background-image.

This is why the bezel scales cleanly to any size with no blurring --
there's no embedded raster image left in the file at all.

### Size slider

`var monitorWidth` already existed as the single config value driving
`applyMonitorLayout()` (canvas position/size computed as a scale factor
against the bezel's native 1073x967 dimensions). The slider in the title
bar is a thin UI layer on top of that existing mechanism:
- Steps through standard display widths (400, 480, 640, 800, 1024, 1280,
  1366, 1400) rather than arbitrary increments, snapping to the nearest
  standard resolution.
- Clicking the pixel readout swaps it for a number input to type a
  custom value directly (any integer 400-1400), Enter/blur commits,
  Escape cancels.
- Implementation note: `sizeSteps`, `nearestIndex()`, and `applySize()`
  must live in GLOBAL scope, not inside a DOMContentLoaded closure --
  an earlier version scoped them locally and the slider silently did
  nothing because the inline `oninput` HTML attribute couldn't see them.
  The working version uses inline `oninput="applySize(...)"` directly on
  the `<input type=range>` element rather than an addEventListener,
  since addEventListener attachment timing proved unreliable against
  whatever DOM activity XRoar's own init does on load.

### Future development
See FUTURE.md for open items: vertical slider alternative (left-side
column, knob-style), cartridge ROM chapter material, and the
-cart-autorun investigation.

---

## XRoar WASM -- cart-autorun Investigation (July 2026)

**Summary:** `-no-cart-autorun` does not suppress FIRQ autostart for
bare-filename ad-hoc carts. Confirmed negative result by direct testing.
Source traced through XRoar's cart.c and xroar.c.

**Three separate code paths identified:**

1. **Bare-filename `-cart` path** (e.g. `-cart STRTEST_CART.ROM`):
   Goes through `cart_special[]` fingerprint table in cart.c. Unknown
   ROMs fall through to generic `cc->autorun = 1` unconditionally in
   the auto-detection logic, before `cart_config_complete()`'s
   `ANY_AUTO` check runs. `-no-cart-autorun` may be set too late to
   affect this path.

2. **Named hardware profile path** (e.g. `-cart rsdos`):
   Goes through `cart_config_complete()` which checks `ANY_AUTO`.
   `-no-cart-autorun` should work here via the standard option mechanism.

3. **`-load` path** (e.g. `-load STRTEST_CART.ROM`):
   Routes through `xroar_load_file_by_type()` -> `FILETYPE_ROM` case.
   Calls `cart_config_by_name()` then unconditionally sets
   `cc->autorun = autorun` where `autorun` comes from `do_load_binaries()`
   checking `autorun_media_slot == media_slot_binary`. The first/only
   media file specified always claims the autorun slot -- no suppression
   flag found for this path.

**`-no-machine-cart`** (`-nodos`): suppresses the default disk-controller
cart (RS-DOS). Confirmed working. Does not affect autorun of loaded ROMs.

**`cart_special[]` table:** hardwired in cart.c. Fingerprints known DOS
ROMs by CRC32 and sets `no_autorun=1` for them specifically. Custom/unknown
ROMs get the generic `autorun=1` fallback. Table is compiled into xroar.wasm.

**Ciaran's note:** "-i should add a note about boolean options - that's the
general form: `-no-<option>`" -- confirmed in xconfig.c: the `no-` prefix
is handled generically by stripping it and calling `unset_option()`.

**Status:** Report sent to Ciaran with test results. He acknowledged
"something screwy about how it auto-makes a rom cart." Open.

---

## XRoar WASM Page -- New Features (July 2026)

### Log Panel (Help tab)
`Module.print` and `Module.printErr` are now wired to a visible
`#xroar-log` div in the Help tab. XRoar's own console output (ROM CRC
results, cart loading, "unknown file type", etc.) appears there on demand.
Toggle with the "..." button. Messages accumulate while hidden.

### DECB .bin Header Parser
`file_input_onload()` now parses `.bin` files client-side before handing
them to `wasm_load_file()`. Reports: block count, bytes loaded, load
address, entry point. Flags entry points that are zero or outside loaded
data range as likely placeholders.

**DECB binary format (corrected):**
- Data block: `[0x00][len_hi][len_lo][addr_hi][addr_lo][data...]`
- EOF block: `[0xFF][0x00][0x00][exec_hi][exec_lo]`
- The EOF block has a 2-byte length field (always 0x0000) before the
  exec address. A common mistake is reading the length bytes as the
  exec address -- produces 0x0000 which looks like a missing exec addr.

### index_new.html
`wasm/index_new.html` is now the active development page (rebuilt clean
from index.html). `index.html` is the stable reference. The transparent
overlay scaffolding file was removed.

---

## GitHub Pages (July 2026)

The repo is now published at:
**https://erroneus0-ops.github.io/SuperComm-disassembled/**

Root `index.html` links to:
- COMTRAN TEN opcode map and instruction reference
- 6809 instruction reference (all groups)
- XRoar standard and development pages

**Do not link from the index:** FUTURE.md, CLAUDE_MANIFESTO.md,
source files, binaries, project JSON files, screenshots folder,
book draft `.md` files (render as plain text on Pages).

Book chapters get linked when converted to HTML and ready to publish.

---

## Screenshots and Similar Artifacts as a Communication Protocol (July 2026)

Screenshots (and by extension, other dropped-in files -- video, exported
assets) aren't just a narrow workflow for one purpose. They're a real
communication channel between Daniel and Claude, on par with text itself
-- a protocol, like any other, for passing rich information (visual
state, recorded behavior) across the gap between "what Daniel can see on
his own screen" and "what Claude can actually examine directly."

**The mechanics:** screenshots go in `screenshots/` at the repo root.
`make_screenshot_index.py` (repo root) generates `screenshots/index.html`
-- a browsable listing of all image files, with timestamps.

**Two ways they get pushed:**
- `git_update.bat` -- the full repo sync, regenerates the index and
  commits everything pending, screenshots included alongside whatever
  else changed.
- `push_images.bat` -- lightweight, dedicated, screenshots-only. Snap a
  screenshot, run this, done, without pulling in unrelated in-progress
  changes elsewhere in the repo. Regenerates the index, stages only
  `screenshots/`, commits, pulls --rebase --autostash, pushes. Exists
  specifically because `git add`/`git commit` *can* be scoped to a
  single subdirectory, but `git push` can't be selectively scoped the
  same way -- it sends whatever's committed, regardless of which paths
  were touched -- so the scoping has to happen at the commit step, and a
  separate dedicated script is the clean way to keep that narrow.

**For Claude:** check `screenshots/` via `git pull` when contextually
relevant. New files can also be fetched via GitHub Pages URL:
`https://erroneus0-ops.github.io/SuperComm-disassembled/screenshots/`

**Do not keep screenshots (or any downloaded/generated media -- video
frames, rendered images, extracted assets) sitting in the sandbox
workspace after they've served their purpose.** Once a screenshot or
similar file has actually been examined for whatever it was needed for,
delete it from the local working directory. Files left lying around in
Claude's own environment don't need to be tracked, explained, or handed
off to a future session the way repo-committed content does -- but only
if they're actually cleaned up. Leaving them around defeats that benefit
and just adds clutter for no reason.

---

## XRoar WASM Mobile Improvements (July 3 2026)

### Hamburger Menu Icon
- `wasm/hamburger.svg` -- custom SVG burger icon (actual hamburger design)
  Top bun as arc path, lettuce with ruffled edge, cheese with corner
  overhangs, thick patty, flat bottom bun. Designed collaboratively,
  geometry specified by Daniel before building.
- Appears in title bar to left of "XRoar Online" text
- Single tap: toggles controls panel show/hide (300ms delay to distinguish
  from double-tap)
- Double-tap (< 300ms): resets overlay to default position without toggling
- `oncontextmenu="return false"` and `-webkit-touch-callout:none` suppress
  browser long-press image menu
- Title bar has `z-index: 101` -- burger always above overlay (z-index 100)

### Mobile Controls Overlay
On mobile (detected by preponderance scoring -- see below):
- Controls panel hidden by default on load
- Shown as `position:fixed` overlay when burger tapped
- Wrapper div contains: drag handle title bar + controls-region (scrollable)
- Drag handle stays fixed above scrollable content -- title bar doesn't
  scroll away when Help tab log is open
- Drag constrained: cannot go above title bar (burger always accessible)
- Width matches monitorWidth, max 95vw
- Max-height 70vh, controls-region scrollable within wrapper
- `ui_set_fullscreen()` updated to use wrapper on mobile

### Mobile Detection (preponderance-of-evidence)
`isMobileDevice()` scores multiple signals, threshold 4/8:
- `ontouchstart` in window: 2pts
- `pointer: coarse` media query: 2pts
- `hover: none` media query: 1pt
- `window.innerWidth < 700`: 1pt
- UA string contains Mobile/Android/iPhone/iPad: 1pt
- `screen.width < 768`: 1pt

Result stored as `window._isMobile` (global, accessible outside IIFE).
Fixes landscape refresh glitch -- phone in landscape scores 6-7 regardless
of viewport width being > 700px.

### Mobile Keyboard Observations (OPEN)
- Soft keyboard appears for the size label input field (numeric keyboard)
- Only `-`, `.`, and tab pass through to the input -- SDL2 captures everything else
- Canvas element does not trigger soft keyboard on tap
- Same issue as Type Text dialog -- SDL2 keyboard capture at document level
- Fix path: hidden `<input type="text">` focused on canvas tap, keystrokes
  forwarded to XRoar. Requires asking Ciaran if WASM build exposes an input path.
- Worth asking Ciaran: is the built-in GDB debugger/monitor accessible in WASM?
  If so, execution trace could appear in the Help tab log panel.

### IIFE Scope Trap (recurring)
Functions defined inside the outer IIFE are invisible to inline event
handlers (`onclick=`) and to code outside the IIFE (like `ui_set_fullscreen`).
Pattern: always use `addEventListener` from inside the IIFE, and expose
values that need global access via `window._name`. This has bitten us
multiple times -- check scope before wondering why something doesn't fire.

---

## XRoar WASM Build from Source (July 7 2026)

### Environment
- Windows 10 LTSC 2021 (build 19044) -- upgraded from 1809 this session
- WSL2 with Ubuntu 22.04.1 LTS
- Emscripten 6.0.2 (installed via emsdk)
- XRoar source: https://www.6809.org.uk/git/xroar.git

### Setup commands
```bash
# Install emsdk
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh   # must run each session or add to .bashrc

# Clone XRoar
mkdir -p ~/src
cd ~/src
git clone https://www.6809.org.uk/git/xroar.git
cd xroar

# Dependencies (most already present on Ubuntu 22.04)
sudo apt install -y build-essential autoconf automake pkg-config \
    libsdl2-dev libpng-dev zlib1g-dev python3 texinfo
```

### Build commands
```bash
autoreconf -fi

emconfigure ./configure --enable-traps --host=wasm32-unknown-emscripten

emmake make -j$(nproc) GL_LIBS=""
```

### Known quirks
- `--host=wasm32-unknown-emscripten` required -- without it configure
  detects Objective-C and sets OBJCLD incorrectly, causing link failure
  with "none: No such file or directory"
- `GL_LIBS=""` required at make time -- configure sets GL_LIBS to the
  literal string "none required" (from the OpenGL check output) which
  gets passed to emcc as an input file and fails
- `texinfo` must be installed or doc build fails

### Output
- `src/xroar.wasm` -- 5.99MB (unoptimized, with debug symbols)
- Ciaran's release build is 1.3MB -- size difference due to -g flag
  and missing Emscripten-specific size optimizations
- Committed to repo as `wasm/xroar-custom.wasm`

### Next steps
- Study Ciaran's build flags for size optimization
- Add debug exports to wasm.c: wasm_set_trace, wasm_set_breakpoint,
  wasm_clear_breakpoint, wasm_get_registers
- Add to exported_functions
- Rebuild and test in browser
- Ciaran's note: build with --enable-traps for trap/breakpoint support

### WSL2 path to Windows files
D: drive is at /mnt/d/ in WSL2
Copy built WASM to repo: cp ~/src/xroar/src/xroar.wasm /mnt/d/git/supercomm/wasm/

---



---

## Recent work: the CoCo3 virtual keyboard (merged in from SESSION_HANDOFF.md)

# Session handoff -- keyboard drag, rebuilt (2026-07-29, updated)

This supersedes the first version of this file. The keyboard drag has
been rebuilt architecturally, not just patched further -- read this
version, not the debugging trail below it (kept for context only).

## Current state

`wasm/index_new.html`'s keyboard now has a **dedicated grab handle**
(`#mobile-kbd-handle`, a plain div sitting above the `<object>`, styled
to match the toolbox's "Controls" handle). Dragging happens entirely
via `wireKeyboardHandleDrag()`, a new, separate function that:

- Only listens on the handle itself (`mousedown`/`touchstart`) and the
  **outer document** (`mousemove`/`mouseup`/`touchmove`/`touchend`/
  `touchcancel`) -- never inside the `<object>`'s nested SVG document
  at all.
- Doesn't depend on the SVG being loaded, only on the handle/wrapper
  elements existing (which they always do). Wired unconditionally at
  page load, regardless of device type.
- Is the exact same pattern the toolbox's drag handle already used
  successfully the whole session.

All the old cross-document listener code (dual inner+outer attachment,
touch-identifier tracking for drag specifically, the manuallyPositioned
movement-threshold logic, the on-screen `[drag]` diagnostic logging)
has been **removed entirely**, not left in place alongside the new
code. The `<object>` is pointed back at the real `coco3_keyboard.svg`
(no longer needs to stay on the stripped-down dummy test file, since
the fix doesn't depend on what's inside the object at all).

The toolbox-on-desktop comparison scaffolding has been reverted --
toolbox is back to mobile-only, as it always was before that
comparison test.

**One TEMPORARY item still active**: the hamburger button on desktop
still toggles the test keyboard instead of the normal controls-panel
behavior (search `TEMPORARY (desktop testing only)` in
`index_new.html`). Kept because desktop testing is still ongoing.
Revisit once real mobile testing is reliable again.

## Why this should actually be structurally sound now, not just another attempt

Every bug this session traced back to the same root cause: the
keyboard's original drag code needed to listen for events *inside* the
`<object>`'s nested document, specifically to distinguish "did this
touch start on a key (which should type) or the bezel (which should
drag)". Both live inside the object, so that check had to happen
there. Everything downstream of that requirement -- the undershoot,
the `mouseup` apparently getting swallowed while the cursor was still
over the object, the rapid-restart bug -- were all different symptoms
of the same underlying cross-document event-propagation quirk.

A dedicated handle removes the requirement itself. It's a plain div in
the outer page, exactly like the toolbox's handle -- there's no key-vs-
bezel ambiguity to resolve, so there's no reason left to listen inside
the nested document for drag purposes at all.

## Immediate next step

**Test it.** This has not been tried against the live/local page yet.
Click the hamburger to show the keyboard, then drag it by the new
"Keyboard" handle bar (should look and behave like the toolbox's
handle). Confirm: tracks the cursor accurately, no undershoot, no
lag/lingering movement after release, works the same on desktop and
(whenever reachable) mobile.

If this works cleanly: the keyboard-drag saga from this session is
closed. Key presses were already confirmed working earlier in the
session (both PC and phone) and weren't touched by this change.

If something's still wrong: it would be a genuinely new, different
symptom, since the entire mechanism that caused every previous bug no
longer exists. Start fresh rather than assuming it's the same root
cause resurfacing.

## Bigger architectural point raised alongside this fix

Daniel raised a related, larger concern: the CM8 monitor bezel's
power-button/LED-light overlay is built as inline SVG hardcoded
directly into `index_new.html`'s own markup, tightly coupled to that
specific bezel image's exact pixel coordinates. Swapping to a
different monitor style would mean real rework, not just changing an
image file. This is a legitimate, separate architectural question --
worth its own dedicated session (per the book/environment/tools
discussion below), not something to fold into whatever comes next
immediately.

## On session structure (carried over from the previous version of this file, resolved/agreed)

Discussed and agreed: treat deep, hard debugging work as its own
bounded session (run until resolved or clearly blocked), and keep
structural/planning discussions (like this one) in separate, dedicated
sessions with nothing else competing for space -- never mid-debug, the
way part of this session went. Worth holding to deliberately, not just
noting once and forgetting.

## Standalone tools built this session, for reference

- `wasm/fix_keyboard_pointer_events.py` -- re-runnable, `--dry-run`
  capable, fixes the pointer-events-blocking issue after any Inkscape
  edit that might reset it.
- `wasm/fix_keyboard_label_naming.py` -- same pattern, for the agreed
  label naming scheme.

## Previous debugging trail (context only, superseded by the fix above)

Kept briefly for anyone curious about *why* things were built the way
they were before this rebuild -- not needed to continue the work, since
the whole mechanism these findings were about no longer exists:

1. Keys weren't clickable -- shader image and glyph labels sat on top
   of key cells in paint order, fixed with `pointer-events:none`.
2. `querySelectorAll('[id^="key-"]')` found zero keys in the nested
   document even though all 57 existed -- attribute selectors don't
   reliably match in a standalone XML document the way they do in
   HTML. Fixed by iterating and checking `.id` directly.
3. Pointer Events lacked `touch-action:none` and `{passive:false}`,
   letting native swipe/scroll gestures fire regardless of
   `preventDefault()`. Fixed by switching to the toolbox's separate
   touch/mouse event pattern -- this fix is why key presses work.
4. The drag-specific undershoot/jerkiness/vanishing bugs (the ones
   this handle rebuild makes moot): ruled out viewBox scaling, the
   real file's complexity, the embedded shader image, and dual-monitor
   DPI, in that order, each with direct evidence. Eventually traced to
   cross-document event propagation quirks between the inner SVG
   document and the outer page -- which the handle-based rebuild
   sidesteps entirely rather than continuing to patch around.

## Future item, explicitly not for now (added 2026-07-30)

**Multi-machine keyboard selection.** CoCo2 and Dragon keyboards share
most of their scheme with CoCo3 (Motorola reference implementation
common ancestry -- confirmed directly: real hardware only has one real
SHIFT switch, with both keycaps wired in parallel to the same matrix
line, which is why our shift-key-sharing fix earlier tonight was
correct, not just a simplification). Building a CoCo2/Dragon keyboard
SVG is expected to be mostly layout work -- moving/removing keys from
the existing CoCo3 artwork, no code changes needed for that part.

The separate, genuinely code-level piece: letting someone actually
*choose* which board is active at runtime. That means swapping the
`<object data="...">` source, probably wired to the existing "Machine:"
dropdown in the toolbox (since the active board should logically follow
whichever machine is being emulated), and very possibly needing its own
`KEY_SCANCODES` table per board, since different real machines could
have genuine differences in what their physical keys map to. Explicitly
deferred -- not started, not scoped in detail yet, just flagged so it
doesn't get lost.

Also still flagged from earlier, unresolved: whether CTRL has a similar
"two keycaps, one real matrix switch" story on real hardware (like
SHIFT does), which might explain why it didn't appear under its own
name in the direct raw-mode scancode table the same way SHIFT's
sharing did.

## Future item, not started -- custom machine-configuration system (added 2026-07-31)

Goal: let Daniel define named machine startup configurations (the
`-machine`/`-cart`/etc. options string XRoar takes) through the web UI
itself, without touching XRoar's source -- directly motivated by the
environment project's actual completion criterion being *maintainability*
of ongoing changes, not a fixed feature list (see the lwtools 4.24->4.25
upgrade-as-process-validation parallel Daniel drew).

Worked out design, in layers, each solving a genuinely different problem
-- discussed but not built:

- **A JSON config file, git-tracked** -- name + comment + options string
  per entry, plus a marker for which entry the file itself considers
  default. Portable between Daniel's own machines via normal `git pull`
  (home/office), which is the thing cookies/localStorage can never do,
  since those are tied to one browser on one device.
- **A textarea (view + copy/paste + edit + apply)** -- replaces a
  file-export/import dialog entirely. Shows the current config JSON,
  editable in place, "Apply" reloads the in-memory list from whatever's
  in the box. Also serves as the direct-editing interface -- no separate
  add/edit form needed. Fits how Daniel actually shares things in
  conversation (pasted text, not attached files) -- if someone needs to
  reproduce his exact setup for debugging, paste-and-apply covers it
  without any file at all.
- **`localStorage`** -- remembers only which single config was last
  selected, purely local to one browser, never the actual config data
  itself. Startup logic: check localStorage first; if it names a config
  still present in the list, use it; otherwise fall back to whatever the
  file/textarea-loaded list marks as its own default.

Explicitly considered and set aside for now: cookies (wrong tool --
their whole design purpose is automatic server visibility, irrelevant
for a static page with no server logic at all) and a URL-parameter
sharing mechanism (genuinely useful, but the textarea alone may already
cover the sharing case well enough -- open question whether it's worth
adding on top, not decided).

**New idea raised alongside this, also not started:** XRoar's own
built-in "Hardware" tab (in its native menu bar -- Software | File |
View | Hardware | Help) offers a limited, fixed selection of machine
configs. Once this custom system exists with its own more flexible,
user-definable list, consider hiding or replacing that native tab
entirely, since it would be redundant with (and more limited than) the
custom system.

## Future item, not started -- web-native disk image browser/editor, emulating DiskShed (added 2026-08-03)

Raised while investigating toolshed's newer release (2.6.0), which
turned out to include a new component called DiskShed -- a native
wxWidgets desktop GUI for browsing and editing OS-9 RBF and CoCo Disk
BASIC disk images. Confirmed directly from its own README, its actual
feature set: multiple image windows, native import/export dialogs,
multi-file drag and drop, rename/delete, OS-9 directory creation, and
an automatic `IMAGE.diskshed-backup` safety copy before any
modification.

**Explicitly decided against:** porting the actual wxWidgets application
to WASM. wxWidgets is a large native desktop GUI toolkit with its own
windowing/rendering model that doesn't map cleanly onto a browser --
"multiple image windows" specifically has no clean browser-tab
equivalent, and its native file dialogs assume a completely different
file-access model than a browser sandbox allows. Same category of
problem as the custom keyboard's native-vs-web translation issues, at
a much larger scale, with real uncertainty it's even achievable.

**The actual plan: build our own web-native frontend, calling into the
existing toolshed.wasm exports underneath.** DiskShed's real editing
logic sits entirely on the same toolshed C libraries (libdecb, librbf)
our toolshed.wasm already compiles and exports (`_ts_dskini`, `_ts_copy`,
`_ts_dir`, `_ts_cecb_run`, etc., per `wasm_builds/toolshed/build.sh`) -- DiskShed
itself is just a native frontend on that same shared foundation. So this
isn't starting from scratch: HTML panels for directory listings, the
browser's own native drag-and-drop API, standard file input/download for
import/export, calling into WASM functions we've already got compiled
and working. Same proven pattern as the keyboard/toolbox work this
session -- build native web UI, wire it to compiled WASM logic
underneath, don't try to drag a foreign native UI paradigm across
unchanged.

Not started, not scoped in detail -- a genuine future feature, not
something to build in the same session it was identified in.

Separately noted: toolshed's actual current version is 2.6.0 (confirmed
directly from its README), newer than the 2.5.1 previously referenced
throughout this project's build tooling and documentation.
