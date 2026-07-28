# XRoar stock WASM Build Report

**Built:** 2026-07-28 10:48 UTC
**Source:** xroar-1.12.1/ (pure upstream, unmodified -- https://www.6809.org.uk/xroar/dl/xroar-1.12.1.tar.gz)
**Build flags:** CFLAGS/LDFLAGS = -O3 -flto (per Ciaran's own XRoar Online build recommendation)
**WASM size:** 1321059 bytes

This replaces the live wasm/xroar.js and wasm/xroar.wasm used by
index.html, index_new.html, and index_custom.html. Pure upstream --
no custom modifications. The debug/register-accessor build stays
separate as wasm/xroar-custom.js / xroar-custom.wasm.
