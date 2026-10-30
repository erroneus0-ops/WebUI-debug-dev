# Headless XRoar test rig

Runs BASIC (and machine code it loads) in a real XRoar, with no window, and
prints what ended up on the text screen. Used to verify the `$FFDE`/`$FFDF`
fix (PR #4).

## Build XRoar headless (Linux)

From a copy of `emcc_workflow/xroar-1.12.1-pristine`:

```
touch aclocal.m4; sleep 1; touch configure; sleep 1
find . -name Makefile.in -exec touch {} +   # copying breaks autotools timestamps
sed -i 's/as_fn_error $? "Could not find a valid OpenGL implementation"[^;]*/: /' configure
./configure --without-x --without-gtk3 --without-gtk2 --without-gtkgl --without-sdl3 \
  --without-sdl2 --without-alsa --without-oss --without-pulse --without-jack \
  --without-evdev --without-joydev --without-sndfile --enable-trace
make -j8          # src/xroar is built; the docs step may fail, ignore it
```

## Use

```
XROAR=/path/to/src/xroar tools/xroar_headless/run_test.sh test.bas coco2bus
```

The test program prints `ZQX` (a marker) at the top of a cleared screen,
prints its results, then runs `POKE &H7FF0,57:EXEC &H7FF0`. The trap
`pc=0x7ff0` snapshots the machine there and `screen.py` reads the screen
back out of the snapshot.

## Gotchas found the hard way

- Trap addresses need `0x`: `pc=7FF0` is read as decimal. (A bare
  `write=3F00` fired during BASIC's startup memory test.)
- Don't trap on a *write* to a RAM mailbox: BASIC's cold start writes
  everywhere. Trap on *executing* an address nothing else runs.
- `coco2bus` is a 64K CoCo 2 with Disk BASIC 1.1 attached by default.
- In ROM mode XRoar (like the real SAM) sends writes to `$8000+` to the
  ROM, so they don't stick. That's the test for "are we in all-RAM mode?".
