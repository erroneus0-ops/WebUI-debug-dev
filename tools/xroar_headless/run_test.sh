#!/bin/bash
# Run a BASIC program in headless XRoar and dump the 32x16 text screen.
# usage: run_test.sh PROGRAM.bas [machine] [extra xroar args...]
# The program must print a line containing ZQX first and end with:
#     POKE &H7FF0,57:EXEC &H7FF0
# (an RTS at $7FF0 that nothing else executes; the trap snapshots there).
set -e
XROAR=${XROAR:-xroar}; ROMS=${ROMPATH:-$(dirname "$0")/../../wasm}
PROG=$1; MACH=${2:-coco2bus}; shift; shift || true
SNA=$(mktemp --suffix=.sna); rm -f "$SNA"
timeout 120 "$XROAR" -ui null -ao null -rompath "$ROMS" -default-machine "$MACH" \
  -load-text "$PROG" -trap pc=0x7ff0 -trap-snap "$SNA" -trap-timeout 1 -timeout 60 "$@" >/dev/null 2>&1 || true
python3 "$(dirname "$0")/screen.py" "$SNA"
