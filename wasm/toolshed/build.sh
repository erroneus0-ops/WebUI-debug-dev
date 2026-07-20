#!/bin/bash
# build.sh -- compile toolshed decb operations to WASM using Emscripten
#
# Run from: wasm/toolshed/
# Output: toolshed.js + toolshed.wasm

set -e

# Auto-detect toolshed directory -- finds highest versioned toolshed-* folder
if [ -z "$TOOLSHED" ]; then
    TOOLSHED=$(ls -d $(cd ../.. && pwd)/toolshed-* 2>/dev/null | sort -V | tail -1)
    if [ -z "$TOOLSHED" ]; then
        echo "ERROR: no toolshed-* directory found in repo root"
        exit 1
    fi
fi

LIBDECB="$TOOLSHED/libdecb"
LIBNATIVE="$TOOLSHED/libnative"
LIBMISC="$TOOLSHED/libmisc"
DECB="$TOOLSHED/decb"
INCLUDE="$TOOLSHED/include"

echo "Building toolshed WASM..."
echo "  toolshed: $TOOLSHED"

# Excluded files -- Emscripten libc compatibility issues
# When upgrading toolshed, scan with:
#   grep -rl "_fileno|ftruncate|digittoint" toolshed-NEW/libnative/ toolshed-NEW/libdecb/
#
# libdecbsrec.c:  digittoint() -- BSD extension not in Emscripten libc
# libnativegs.c:  path->fd->_fileno -- glibc internal, not in Emscripten libc
# libnativess.c:  ftruncate with _fileno -- same issue
# libcoco:        routing layer pulls in OS9/CECB deps we don't need
# decbcopy.c:     uses libcoco; ts_copy implemented directly with _decb_* instead

LIBDECB_SRCS=$(find "$LIBDECB" -name "*.c" ! -name "libdecbsrec.c" | tr '\n' ' ')

LIBNATIVE_SRCS="
    $LIBNATIVE/libnativeopen.c
    $LIBNATIVE/libnativewrite.c
    $LIBNATIVE/libnativeseek.c
    $LIBNATIVE/libnativeread.c
    $LIBNATIVE/libnativereadln.c
    $LIBNATIVE/libnativedelete.c
    $LIBNATIVE/libnativerename.c
    $LIBNATIVE/libnativemakdir.c
"

LIBMISC_SRCS="
    $LIBMISC/libmiscutil.c
    $LIBMISC/libmisccococonv.c
    $LIBMISC/libmiscendian.c
"

DECB_SRCS="$DECB/decbdir.c $DECB/decbdskini.c $DECB/decbkill.c"

emcc \
    toolshed_wrapper.c \
    $LIBDECB_SRCS \
    $LIBNATIVE_SRCS \
    $LIBMISC_SRCS \
    $DECB_SRCS \
    -I"$INCLUDE" \
    -o toolshed.js \
    -s EXPORTED_FUNCTIONS='["_ts_dskini","_ts_copy","_ts_dir","_ts_kill"]' \
    -s EXPORTED_RUNTIME_METHODS='["FS","ccall","cwrap"]' \
    -s MODULARIZE=1 \
    -s EXPORT_NAME='ToolshedModule' \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s FORCE_FILESYSTEM=1 \
    -s EXIT_RUNTIME=0 \
    -s INVOKE_RUN=0 \
    -O2

echo "Done. Output: toolshed.js + toolshed.wasm"
