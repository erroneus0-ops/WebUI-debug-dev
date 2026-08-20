Title: POKE fails to compile at all for coco target (silent failure, only "WARNING W001" printed)

## Summary

`POKE` appears to be completely broken for the `coco` target in v1.18.1.
Even the simplest possible program using it fails to compile, with no
real error message -- just a spurious warning and a silent exit(1).

## Environment

- ugBASIC v1.18.1 (built from source, commit at time of testing)
- Target: coco (Motorola 6809)
- Host: Ubuntu 24.04 (also reproduced in GitHub Actions ubuntu-latest)
- Invocation: `ugbc.coco -W -C /path/to/asm6809 -b /path/to/decb -o out.dsk -O dsk source.bas`

## Minimal reproduction

This is the entire program:

```basic
POKE 4096, 9
DO
LOOP
```

Result:

```
WARNING W001 - Multiplication could loose precision Ttmp2 Ttmp3 at 1 column 13 (14)
```

Exit code 1. No `.dsk`/`.bin`/`.asm` output produced at all (confirmed
by generating the `.asm` output directly instead of a full `.dsk` --
the `.asm` file is created but is 0 bytes).

## What I tried to isolate it

- Decimal vs hex address (`POKE 4096, 9` vs `POKE &H1000, 9`): both fail
  identically.
- Low memory address vs hardware I/O range (`POKE 4096, 9` vs
  `POKE 65436, 9`): both fail identically -- this isn't specific to any
  particular address range.
- With `PMODE`/`CLS` before it vs completely alone as the only
  statement in the program: both fail identically.
- Disabling peephole optimization entirely (`-p 0`): no change, still
  fails the same way.

So it isn't the address value, isn't specific to I/O-space addresses,
and isn't related to the peephole optimizer. Every `POKE` statement I
tried failed with the exact same warning-then-silent-exit pattern.

## Expected behavior

Either `POKE` compiles successfully (as it does on other targets, and
as it presumably used to on `coco`), or if there's a genuine
correctness concern the compiler is trying to warn about, it should
produce a clear, actionable error message rather than exiting silently
after printing only a warning.

## Workaround found

Inline 6809 assembly (`BEGIN ASM ... END ASM`) works fine as a
substitute for direct hardware register writes, since it's passed
straight through to asm6809 rather than going through whatever
BASIC-level code generation path is broken for `POKE`. Just flagging
this in case it's useful context for narrowing down where the bug is
(sounds like it's specific to `POKE`'s own codegen, not assembly
output or the assembler itself).

Happy to provide more detail, a full CI log, or test further if useful
-- this came up while working on a from-scratch port of an existing
CoCo BASIC game, and I wanted to report it cleanly rather than just
route around it silently.
