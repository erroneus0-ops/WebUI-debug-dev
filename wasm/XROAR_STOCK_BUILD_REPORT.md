# XRoar stock WASM Build Report

**Built:** 2026-08-01 14:02 UTC
**Source:** xroar-1.12.1/ (pure upstream, unmodified -- https://www.6809.org.uk/xroar/dl/xroar-1.12.1.tar.gz)
**Build flags:** CFLAGS/LDFLAGS = -O3 -flto (per Ciaran's own XRoar Online build recommendation)
**WASM size:** 1320978 bytes

This replaces the live wasm/xroar.js and wasm/xroar.wasm used by
index.html and index_new.html, AND wasm/xroar-custom-patched.js /
.wasm used by index_custom.html. Pure upstream, no custom
modifications -- the custom debug-register functions (wasm_get_pc
etc.) are not part of this build. Nothing in the UI calls them yet,
so using stock here too costs nothing functionally. Extracted and
documented in CUSTOM_DEBUG_FUNCTIONS_EXTRACTED.md for a future
rebase, if that work is picked back up.

Also built: wasm/xroar-version.js / xroar-version.wasm -- a tiny,
separate, MODULARIZE-d companion program (not part of xroar's own
source) that reports the version string from the same config.h
this build generated. Exists so the page can query the version at
runtime without touching xroar.wasm itself at all.
