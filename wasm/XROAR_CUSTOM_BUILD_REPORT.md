# XRoar custom WASM Build Report

**Built:** 2026-08-17 14:36 UTC
**Source:** emcc_workflow/xroar-1.12.1/ -- patched, NOT pristine upstream (see build_xroar_stock_wasm.yml for the genuinely untouched copy)
**Build tag:** debug-exports (reported version becomes e.g. "XRoar 1.12.1+debug-exports", SemVer build-metadata convention)
**WASM size:** 1325758 bytes

## Debug exports found in built JS glue
```
wasm_clear_breakpoint
wasm_clear_watchpoint
wasm_dump_memory
wasm_free_dump_buffer
wasm_get_auto_refresh
wasm_get_register
wasm_get_stop_address
wasm_get_stop_reason
wasm_get_tv_standard
wasm_get_watchpoint_was_read
wasm_is_paused
wasm_pause
wasm_read_byte
wasm_register_by_name
wasm_register_count
wasm_register_name
wasm_resume
wasm_set_auto_refresh
wasm_set_breakpoint
wasm_set_register
wasm_set_watchpoint
wasm_step
wasm_write_byte
```

This is what index_custom.html actually loads (xroar-custom-patched.js/.wasm),
along with the build-tagged version reporter (xroar-version-custom.js/.wasm).
index.html and index_new.html load the separate stock build instead --
see build_xroar_stock_wasm.yml.
