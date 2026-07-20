#!/bin/bash
set -e

if [ -z "$TOOLSHED" ]; then
    TOOLSHED=$(find $(cd ../.. && pwd) -maxdepth 1 -type d -name "toolshed-*" | sort -V | tail -1)
fi

TS_VERSION=$(grep "^VERSION" "$TOOLSHED/build/unix/rules.mak" | awk '{print $3}')
INCLUDE="$TOOLSHED/include"
LIBMISC="$TOOLSHED/libmisc"

echo "Building tocgen WASM..."
echo "  toolshed: $TOOLSHED ($TS_VERSION)"

LIBMISC_SRCS=$(find "$LIBMISC" -name "*.c" ! -name "os9diskfuncs.c" | tr '\n' ' ')
LIBCOCO="$TOOLSHED/libcoco"
LIBCOCO_SRCS=$(find "$LIBCOCO" -name "*.c" | tr '\n' ' ')
LIBNATIVE="$TOOLSHED/libnative"
LIBNATIVE_SRCS="$LIBNATIVE/libnativeopen.c $LIBNATIVE/libnativewrite.c $LIBNATIVE/libnativeseek.c $LIBNATIVE/libnativeread.c $LIBNATIVE/libnativereadln.c $LIBNATIVE/libnativedelete.c $LIBNATIVE/libnativerename.c $LIBNATIVE/libnativemakdir.c"

emcc \
    tocgen_wrapper.c \
    ../toolshed/native_stubs.c \
    "$TOOLSHED/tocgen/tocgen_main.c" \
    $LIBMISC_SRCS \
    $LIBCOCO_SRCS \
    $LIBNATIVE_SRCS \
    -I"$INCLUDE" \
    -Dmain=tocgen_main \
    -DTOOLSHED_VERSION="\"\"" \
    -o tocgen.js \
    -s EXPORTED_FUNCTIONS='["_tocgen_version","_tocgen_run"]' \
    -s EXPORTED_RUNTIME_METHODS='["FS","ccall","cwrap"]' \
    -s MODULARIZE=1 \
    -s EXPORT_NAME='TocgenModule' \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s FORCE_FILESYSTEM=1 \
    -s EXIT_RUNTIME=0 \
    -s INVOKE_RUN=0 \
    -O2

echo "source: toolshed-$TS_VERSION" > VERSION
echo "built: $(date -u '+%d%b%Y')" >> VERSION
echo "Done."
