# XRoar custom WASM Build Report

**Built:** 2026-08-10 21:26 UTC
**Source:** emcc_workflow/xroar/ (local checkout, XRoar 1.11 base + debug/register accessor additions)
**WASM size:** 1127857 bytes

## Debug exports found in built JS glue
```
wasm_get_a
wasm_get_b
wasm_get_cc
wasm_get_pc
wasm_get_s
wasm_get_x
wasm_get_y
wasm_read_byte
wasm_write_byte
```

**Note:** this build is NOT wired into index_new.html or index.html.
It sits alongside the live xroar.js/xroar.wasm as xroar-custom.js/xroar-custom.wasm
until deliberately wired in for the future monitor/debugger page.
