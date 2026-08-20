Title: Peephole optimizer silently deletes non-redundant STA ,X+ (auto-increment) stores

## Summary

The peephole optimizer's dead-store elimination pass appears to treat
consecutive `STA ,X+` instructions inside an inline `BEGIN ASM...END ASM`
block as redundant repeated stores to the *same* address, and silently
comments most of them out of the generated assembly. It doesn't seem to
account for the fact that `,X+` auto-increments X on every execution --
so each store is actually writing to a *different* address, and isn't
redundant at all. The result is correct-looking BASIC that silently
writes far less data than intended, with no warning or error at all.

## Environment

- ugBASIC v1.18.1 (built from source)
- Target: coco (Motorola 6809)
- Host: Ubuntu 24.04
- Invocation: `ugbc.coco -W -C /path/to/asm6809 -b /path/to/decb -o out.dsk -O dsk source.bas`

## Minimal reproduction

```basic
PMODE 4, 1
CLS
BEGIN ASM
    LDX BITMAPADDRESS
    LDA #$9F
    STA ,X+
    STA ,X+
    STA ,X+
    STA ,X+
    STA ,X+
END ASM
DO
LOOP
```

Compiling this and inspecting the generated `.asm` output (via
`ugbc.coco source.bas source.asm`, no `-o`/`-O` needed to see this) shows:

```
	LDA #$9F
; peephole(1): r531 (STORE*,STORE*)->(STORE*)
;	STA ,X+
; peephole(1): r531 (STORE*,STORE*)->(STORE*)
;	STA ,X+
; peephole(1): r531 (STORE*,STORE*)->(STORE*)
;	STA ,X+
; peephole(1): r531 (STORE*,STORE*)->(STORE*)
;	STA ,X+
	STA ,X+
```

Four of the five `STA ,X+` instructions get commented out of the actual
assembled output. Only the last one survives. There's no warning that
this happened -- the program compiles cleanly and "works," it just
silently writes 1 byte where 5 were intended.

## Impact

This will affect *any* inline-assembly loop pattern that stores a
repeated or identical value through an auto-incrementing addressing
mode (`,X+`, `,Y+`, `,U+`, `,S+`, and presumably the corresponding
16-bit `++` forms) -- a completely standard, common pattern for filling
memory with a repeated byte, or writing several bytes in sequence where
some happen to share the same value. Anyone hitting this would see
"my inline assembly compiles fine but doesn't write what I told it to,"
with no error to point at the actual cause.

## Workaround found

Passing `-p 0` (disable peephole optimization entirely) avoids the bug
-- confirmed all five `STA ,X+` instructions survive uncommented with
that flag. Obviously not a real fix since it disables optimization
project-wide, but confirms the peephole pass specifically is where this
goes wrong.

## Suggested direction (not a demand, just what stood out reading the diff)

The peephole rule matching `(STORE*,STORE*)->(STORE*)` looks like it's
pattern-matching on the store *mnemonic* without checking whether the
addressing mode includes auto-increment/auto-decrement, which is the
actual thing that makes two consecutive stores non-redundant even when
the source register value hasn't changed in between.

## A related feature request, while I'm here

Separately from fixing the bug itself: right now the only way to avoid
this is `-p 0`, which disables peephole optimization for the *entire*
program. Checked the parser (`ugbc.y`) directly -- inline assembly from
`BEGIN ASM...END ASM` gets emitted via the exact same `outline1()` call
used for all compiler-generated code, with no flag or marker
distinguishing "this came from a manual ASM block, leave it alone."

A scoped way to protect just an inline ASM block from the optimizer --
something like a `NO OPTIMIZE` / `#pragma`-style directive bracketing
just that block, rather than an all-or-nothing global flag -- would
let people keep the benefit of peephole optimization on ugBASIC's own
generated code while trusting that hand-written inline assembly
executes exactly as written. Given hand-written inline assembly is
usually there *specifically* because the person needed precise control
over what executes, silently rewriting it seems like exactly the case
such a directive should exist to prevent.

Happy to provide the full generated .asm, a full CI log, or test
further if useful -- found this while building a small test program
during a from-scratch port of an existing CoCo BASIC game, not
something I went looking for.
