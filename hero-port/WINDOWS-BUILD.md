# Windows build workflow (via WSL2)

A from-source build of ugBASIC's `coco` toolchain plus real XRoar, on
Windows, using the exact same commands verified against a real Linux
sandbox throughout this project's development. This gets you the actual
latest source (including any fix not yet in an official IDE release),
rather than whatever the last packaged Windows release happened to
include.

## Why WSL2 rather than a native Windows build

ugBASIC's build system (Makefiles, autotools for `asm6809`) and its
dependencies (`bison`, `flex`, `libpng`, `libgtk-3`, `libsdl2`, ...) are
all Unix-first. WSL2 gives you a real Linux kernel and environment
inside Windows -- not an emulation layer -- so every command below is
literally the same one used (and verified) on a real Linux box, not a
Windows-specific reinterpretation that might behave differently.

## 1. Install WSL2 + Ubuntu

In an elevated (Administrator) PowerShell or Command Prompt:

```
wsl --install
```

This installs WSL2 with Ubuntu by default on a fresh Windows 10/11
install. Reboot if prompted, then open the "Ubuntu" app from the Start
menu to finish first-time setup (creates a Linux username/password,
separate from your Windows login).

All the commands below run *inside* that Ubuntu window, not in
PowerShell/CMD.

## 2. Install build dependencies

```bash
sudo apt-get update
sudo apt-get install -y build-essential bison flex libpng-dev \
    libgtk-3-dev libasound2-dev libsdl2-dev libx11-dev pkg-config zip \
    markdown libfuse-dev autoconf automake libtool texinfo xxd
```

(`markdown`, `libfuse-dev`, `texinfo`, and `xxd` are each individually
non-obvious dependencies discovered the hard way while setting up this
project's own CI -- see `.github/workflows/hero-port-build-and-test.yml`
and this project's commit history for the specifics of why each one is
needed.)

## 3. Clone ugBASIC + the two submodules the coco toolchain needs

```bash
git clone https://github.com/spotlessmind1975/ugbasic.git
cd ugbasic
git submodule update --init --depth 1 modules/asm6809 modules/toolshed
```

## 4. Build

```bash
make target=coco toolchain
make target=coco compiler
```

`asm6809` gets built but not installed anywhere by ugBASIC's own build
system -- install it explicitly so `ugbc.coco` can find it regardless of
your current directory:

```bash
sudo cp modules/asm6809/src/asm6809 /usr/local/bin/
```

`decb` (the DECB disk-image tool, from the `toolshed` submodule) *does*
get installed automatically to `/usr/local/bin` as part of the
`toolchain` build step above.

## 5. Verify

```bash
./ugbc/exe/ugbc.coco -V
```

Should print `1.18.1` (or whatever the current version is at the time
you build). To check which exact source revision you're on:

```bash
git log -1 --format="%H %ad" --date=short
```

## 6. Compiling a program

```bash
./ugbc/exe/ugbc.coco -W -C /usr/local/bin/asm6809 -b /usr/local/bin/decb \
    -o /path/to/output.dsk -O dsk /path/to/source.bas
```

The `-C`/`-b` flags are not optional in practice -- `ugbc.coco`'s
default discovery for `asm6809`/`decb` is a working-directory-relative
path trick that only works if invoked from ugBASIC's own repo root.
`-W` shows real warnings/errors instead of nothing (a `.bas` file can
compile "successfully" while silently doing the wrong thing without
this flag -- see this project's `hero-port/upstream-reports/` for
several real examples).

**Known, currently-relevant compiler bugs when writing your own `.bas`
files** (all found and reported during this project, see
`hero-port/upstream-reports/` for full detail on each):
- Identifiers must start with a lowercase letter, or they fail to
  parse at all (regardless of whether they resemble a keyword).
- Chaining more than ~15 string concatenation (`+`) operations in one
  expression silently corrupts the result, with no error at all.
- Procedure parameters that aren't given an explicit type default to a
  16-bit word; reading one with an 8-bit register load (`LDB`) silently
  reads the wrong byte -- declare small parameters `AS BYTE` explicitly.
- Compiling with peephole optimization active (`-p 16`, the default)
  can silently replace a procedure-local value computed from a
  parameter with a hardcoded placeholder, when called more than once
  with different arguments. Confirmed fixed for the specific
  auto-increment-store case in the revision dated 2026-08-21 or later
  (see issue #1247); a related-but-distinct locals-inlining issue may
  still need `-p 0` as a workaround -- check the upstream-reports
  folder for the current state before assuming either way.

## 7. Getting files back out to Windows

WSL2's Linux filesystem is reachable from Windows Explorer at
`\\wsl$\Ubuntu\home\<your-linux-username>\...`, or from inside WSL,
your Windows drives are mounted at `/mnt/c/`, `/mnt/d/`, etc. Easiest
round-trip: compile inside WSL, then copy the output `.dsk` to
somewhere under `/mnt/c/Users/<you>/...` so it shows up directly in
your normal Windows folders for use with an emulator.

## 8. Running the result: XRoar

Real XRoar ships an official prebuilt Windows package --
https://www.6809.org.uk/xroar/ -- no WSL involvement needed for this
part. Grab the Windows `.zip`, unzip it, and place your ROM images
(`bas13.rom`, `extbas11.rom`, `disk11.rom` -- see `hero-port/README.md`
for where this project's copies came from and their provenance) in the
same folder as `xroar.exe`, or in `Documents/XRoar/roms`.

To boot a compiled disk with the RS-DOS controller active:

```
xroar.exe -machine coco2b -cart rsdos -load-fd0 path\to\output.dsk
```

A note on VCC: if you already have VCC set up (e.g. for CoCoSDC/SDCX
work), be aware this project's entire SG12 investigation was verified
specifically against XRoar's 6847 emulation, in detail, over many
iterations. VCC's accuracy for this particular undocumented hardware
quirk hasn't been checked the same way -- worth confirming before
trusting VCC for anything SG12-specific, rather than assuming parity.

## 9. Staying up to date

Since this pulls directly from ugBASIC's `main` branch rather than a
tagged release, re-running `git pull` (or a fresh `git clone`) inside
the `ugbasic` folder followed by `make target=coco compiler` picks up
new fixes as soon as they're pushed -- exactly how the fix for issue
#1247 was confirmed during this project, the same day it landed.
