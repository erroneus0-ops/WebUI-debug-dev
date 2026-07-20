#!/bin/bash
# build.sh -- compile toolshed as monolithic WASM (DECB + OS-9 + CECB)
#
# Run from: wasm/toolshed/
# Output: toolshed.js + toolshed.wasm

set -e

# Auto-detect toolshed directory
if [ -z "$TOOLSHED" ]; then
    TOOLSHED=$(find $(cd ../.. && pwd) -maxdepth 1 -type d -name "toolshed-*" | sort -V | tail -1)
    if [ -z "$TOOLSHED" ]; then
        echo "ERROR: no toolshed-* directory found in repo root"
        exit 1
    fi
fi

LIBDECB="$TOOLSHED/libdecb"
LIBNATIVE="$TOOLSHED/libnative"
LIBMISC="$TOOLSHED/libmisc"
LIBCOCO="$TOOLSHED/libcoco"
LIBRBF="$TOOLSHED/librbf"
LIBCECB="$TOOLSHED/libcecb"
DECB="$TOOLSHED/decb"
OS9="$TOOLSHED/os9"
CECB="$TOOLSHED/cecb"
INCLUDE="$TOOLSHED/include"

echo "Building toolshed WASM (monolithic)..."
echo "  toolshed: $TOOLSHED"

# Excluded files -- Emscripten libc compatibility issues
# Scan with: grep -rl "_fileno|ftruncate|digittoint" toolshed-NEW/lib*/
# libdecbsrec.c:  digittoint() -- BSD extension
# libnativegs.c:  path->fd->_fileno -- glibc internal
# libnativess.c:  ftruncate with _fileno -- glibc internal

LIBDECB_SRCS=$(find "$LIBDECB" -name "*.c" ! -name "libdecbsrec.c" | tr '\n' ' ')
LIBRBF_SRCS=$(find "$LIBRBF" -name "*.c" | tr '\n' ' ')
LIBCECB_SRCS=$(find "$LIBCECB" -name "*.c" | tr '\n' ' ')
LIBCOCO_SRCS=$(find "$LIBCOCO" -name "*.c" | tr '\n' ' ')

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

# Use all libmisc sources (includes libmiscqueue.c for qAddNode etc.)
LIBMISC_SRCS=$(find "$LIBMISC" -name "*.c" | tr '\n' ' ')

LIBSYS="$TOOLSHED/libsys"
LIBSYS_SRCS=$(find "$LIBSYS" -name "*.c" | tr '\n' ' ')

LIBTOOLSHED="$TOOLSHED/libtoolshed"
LIBTOOLSHED_SRCS=$(find "$LIBTOOLSHED" -name "*.c" | tr '\n' ' ')

# CLI source files -- rename main() to avoid conflicts
DECB_SRCS=$(find "$DECB" -name "*.c" ! -name "decb_main.c" ! -name "decbcopy.c" | tr '\n' ' ')
OS9_SRCS=$(find "$OS9" -name "*.c" ! -name "os9_main.c" | tr '\n' ' ')
CECB_SRCS=$(find "$CECB" -name "*.c" ! -name "cecb_main.c" | tr '\n' ' ')

EXPORTED='["_ts_dskini","_ts_copy","_ts_read","_ts_dir","_ts_kill","_ts_free","_ts_rename","_ts_fstat","_ts_os9_dir","_ts_os9_copy","_ts_os9_del","_ts_os9_free","_ts_os9_id"]'

emcc \
    toolshed_wrapper.c \
    $LIBDECB_SRCS \
    $LIBRBF_SRCS \
    $LIBCECB_SRCS \
    $LIBCOCO_SRCS \
    $LIBNATIVE_SRCS \
    $LIBMISC_SRCS \
    $LIBSYS_SRCS \
    $LIBTOOLSHED_SRCS \
    $DECB_SRCS \
    $OS9_SRCS \
    $CECB_SRCS \
    -I"$INCLUDE" \
    -o toolshed.js \
    -s EXPORTED_FUNCTIONS="$EXPORTED" \
    -s EXPORTED_RUNTIME_METHODS='["FS","ccall","cwrap"]' \
    -s MODULARIZE=1 \
    -s EXPORT_NAME='ToolshedModule' \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s FORCE_FILESYSTEM=1 \
    -s EXIT_RUNTIME=0 \
    -s INVOKE_RUN=0 \
    -O2

echo "Done. Output: toolshed.js + toolshed.wasm"
