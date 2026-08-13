# XRoar stock WASM Build Report

**Built:** 2026-08-13 15:01 UTC
**Source:** emcc_workflow/xroar-1.12.1-pristine/ -- genuinely untouched upstream, refreshed manually only when a real new release drops (see https://www.6809.org.uk/xroar/dl/)
**Build flags:** CFLAGS/LDFLAGS = -O3 -flto (per Ciaran's own XRoar Online build recommendation)
**WASM size:** 1322937 bytes

This replaces the live wasm/xroar.js and wasm/xroar.wasm used by
index.html and index_new.html. Pure upstream, no custom modifications
at all -- the debug/register/breakpoint/memory-access functions live
only in the separately-built xroar-custom-patched.js/.wasm, produced
by build_xroar_wasm.yml from the patched tree, used only by
index_custom.html. This workflow no longer touches those files at all.

Also built: wasm/xroar-version.js / xroar-version.wasm -- a tiny,
separate, MODULARIZE-d companion program (not part of xroar's own
source) that reports the version string from the same config.h
this build generated. Reports the bare version (e.g. "XRoar 1.12.1")
with no build tag, since this really is unmodified upstream.
