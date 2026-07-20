#!/bin/bash
# build.sh -- compile lwasm to WASM using Emscripten
#
# Run from: wasm/lwasm/
# lwtools source expected at: ../../lwtools-4.24/ (or set LWTOOLS env var)
#
# Output:
#   lwasm.js    -- Emscripten JS loader
#   lwasm.wasm  -- the WASM binary

set -e

LWTOOLS="${LWTOOLS:-$(cd ../.. && pwd)/lwtools-4.24}"
LWASM_SRC="$LWTOOLS/lwasm"
LWLIB_SRC="$LWTOOLS/lwlib"
INCLUDE="$LWTOOLS/lwasm $LWTOOLS/lwlib $LWTOOLS/common"

echo "Building lwasm WASM..."
echo "  lwtools: $LWTOOLS"

# Collect ALL lwasm C sources including main.c
LWASM_SRCS=$(find "$LWASM_SRC" -name "*.c" | tr '\n' ' ')
LWLIB_SRCS=$(find "$LWLIB_SRC" -name "*.c" | tr '\n' ' ')

# Build include flags
IFLAGS=""
for d in $INCLUDE; do
    IFLAGS="$IFLAGS -I$d"
done

# Rename lwasm main() to lwasm_main() at compile time
# This must be applied to main.c specifically
MAIN_WRAP="-Dmain=lwasm_main"

emcc \
    lwasm_wrapper.c \
    $LWASM_SRCS \
    $LWLIB_SRCS \
    $IFLAGS \
    $MAIN_WRAP \
    -o lwasm.js \
    -s EXPORTED_FUNCTIONS='["_lwasm_assemble"]' \
    -s EXPORTED_RUNTIME_METHODS='["FS","ccall","cwrap"]' \
    -s MODULARIZE=1 \
    -s EXPORT_NAME='LwasmModule' \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s FORCE_FILESYSTEM=1 \
    -O2

echo "Done. Output: lwasm.js + lwasm.wasm"
