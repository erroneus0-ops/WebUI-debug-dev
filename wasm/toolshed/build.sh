#!/bin/bash
# build.sh -- compile toolshed decb operations to WASM using Emscripten
#
# Run from: wasm/toolshed/
# toolshed source expected at: ../../toolshed-2.5.1/
#
# Output:
#   toolshed.js    -- Emscripten JS loader
#   toolshed.wasm  -- the WASM binary

set -e

# Auto-detect toolshed directory -- finds the highest versioned toolshed-* folder
# Set TOOLSHED env var to override
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
LIBCOCOPATH="$TOOLSHED/libcocopath"
DECB="$TOOLSHED/decb"
INCLUDE="$TOOLSHED/include"

echo "Building toolshed WASM..."
echo "  toolshed: $TOOLSHED"

# Collect source files
# Excluded files -- Emscripten libc compatibility issues
# When upgrading toolshed, if the build fails on a missing function,
# identify which .c file causes it and add ! -name "that_file.c" here.
# Only exclude files whose functionality we don't need (see README.md).
# libdecbsrec.c: uses digittoint() -- BSD extension, not in Emscripten libc
#                S-record format not needed for CoCo DECB use case
LIBDECB_SRCS=$(find "$LIBDECB" -name "*.c" ! -name "libdecbsrec.c" | tr '\n' ' ')
LIBNATIVE_SRCS="
    $LIBNATIVE/libnativeopen.c
    $LIBNATIVE/libnativewrite.c
    $LIBNATIVE/libnativeseek.c
    $LIBNATIVE/libnativeread.c
    $LIBNATIVE/libnativereadln.c
    $LIBNATIVE/libnativegs.c
    $LIBNATIVE/libnativedelete.c
    $LIBNATIVE/libnativerename.c
    $LIBNATIVE/libnativemakdir.c
"
LIBMISC_SRCS="
    $LIBMISC/libmiscutil.c
    $LIBMISC/libmisccococonv.c
    $LIBMISC/libmiscendian.c
"
LIBCOCOPATH_SRCS=$(find "$LIBCOCOPATH" -name "*.c" 2>/dev/null | tr '\n' ' ')
DECB_SRCS="$DECB/decbcopy.c $DECB/decbdir.c $DECB/decbdskini.c $DECB/decbkill.c"

emcc \
    toolshed_wrapper.c \
    $LIBDECB_SRCS \
    $LIBNATIVE_SRCS \
    $LIBMISC_SRCS \
    $LIBCOCOPATH_SRCS \
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
