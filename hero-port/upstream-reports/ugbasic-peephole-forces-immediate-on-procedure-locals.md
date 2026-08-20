Title: Peephole "inlined" pass incorrectly forces immediate addressing on values computed fresh per procedure call

## Summary

Inside a `PROCEDURE`, a local variable assigned from a value that
depends on a parameter (e.g. `addr = STRPTR(data$)`, where `data$` is
itself a parameter) gets its *read* silently rewritten by the
peephole optimizer into a hardcoded immediate load, disconnected from
the actual store. In effect, the optimizer is imposing immediate
addressing on a value that is only ever valid as a genuine memory
read -- the whole reason the value exists is that it's recomputed
differently on every call.

This is not "the first call's value gets frozen forever" (which would
at least be a consistent, if wrong, behaviour) -- it's that the
*read* gets replaced with a fixed placeholder (`$0000` in every case
I've reproduced) while the *store* (the real, correct, per-call
computation) still executes, harmlessly, into a memory location
nothing ever reads again. The net effect is that the procedure
silently ignores the value it was just given and uses a constant zero
instead, for every single call, regardless of what was actually
passed or computed.

## Environment

- ugBASIC v1.18.1 (built from source)
- Target: coco (Motorola 6809)
- Invocation: `ugbc.coco -W source.bas source.asm`

## Minimal reproduction

```basic
PROCEDURE writerow[data$, col, startrow, numrows]
    addr = STRPTR(data$)
    ln = LEN(data$)
    BEGIN ASM
        LDX BITMAPADDRESS
        LDA #32
        LDB _writerow__startrow
        MUL
        LEAX D,X
        LDB _writerow__col
        ABX

        LDY _writerow__numrows
wrrow
        PSHS X,Y
        LDU _writerow_addr
        LDB _writerow_ln
wrbyte
        LDA ,U+
        STA ,X+
        DECB
        BNE wrbyte
        PULS X,Y
        LEAX 32,X
        LEAY -1,Y
        BNE wrrow
    END ASM
END PROCEDURE

PMODE 4, 1
CLS
yellowbyte$ = CHR$(159)
middata$ = CHR$(149) + "HIGH SCORE: 8675309" + CHR$(154)
writerow[yellowbyte$, 1, 0, 3]
writerow[middata$, 1, 6, 5]
DO
LOOP
```

Both calls compile and run, but produce garbage instead of the
intended output -- neither the solid fill nor the text renders
correctly (confirmed visually in XRoar: a single corrupted block
where two distinct, correctly-shaped rows should be).

Looking at the generated `.asm` explains why:

```
; peephole(16): inlined1
;	LDU _writerow_addr
	LDU #$0000
_writerow_addr equ *-2
```

The real instruction, `LDU _writerow_addr` (a genuine memory read of
the value computed one line earlier from the `data$` parameter), has
been commented out and replaced with `LDU #$0000` -- an immediate
load of a hardcoded placeholder. The `STD _writerow_addr` that
computes and stores the real, correct, per-call value earlier in the
procedure is left completely intact and still executes -- it's just
that nothing ever reads what it wrote anymore.

## What I confirmed while isolating this

- `DIM addr AS INTEGER` before the assignment does **not** prevent
  this -- the identical `inlined1` substitution appears whether or
  not the local is explicitly declared beforehand.
- Passing `-p 0` (disable peephole optimization entirely) **does**
  fix it -- with peephole off, the exact same source (still using
  `addr`/`ln` as procedure-local values, not parameters) produces
  correct output for both calls.
- This is a distinct issue from a separate bug I found while testing
  the same procedures: parameters that aren't given an explicit type
  default to a 16-bit word, and reading them with an 8-bit register
  load (`LDB`) silently reads the wrong (high) byte. That one is
  *not* fixed by `-p 0` and needs an explicit `AS BYTE` declaration
  instead -- flagging the distinction in case it's useful, since
  both surfaced from the same investigation and could otherwise get
  conflated.

## Impact

Any procedure that computes a local value from a parameter (an
extremely ordinary pattern -- "do something with the string/number I
was given") and is called more than once with different arguments
will silently get wrong behaviour on some or all calls, with no
error, no warning beyond the routine `peephole(16): inlined1` comment
in the generated assembly (which nothing surfaces to the BASIC
programmer at all). The bug is also inconsistent in *where* it fires
-- it depends on the peephole pass's local pattern-matching window,
not on any property of the program that would be obvious from the
BASIC source, which makes it especially hard to predict or notice
without inspecting generated assembly directly.

## Suggested direction

The peephole pass responsible for this optimization appears to
pattern-match on "a store immediately followed by a load of the same
location" and assume the loaded value can be replaced with a fixed
constant. That's only valid if the stored value is genuinely
compile-time-constant across every path that reaches the load -- and
a value derived from a procedure parameter is, by definition, not
that, since the entire point of a parameter is that it differs per
call. The pass seems to be missing a check for whether the value
being propagated actually originates from a parameter (or anything
else that varies at runtime) before treating it as safe to fold into
an immediate.

## Workaround found

`-p 0` (disable peephole optimization for the whole program), or
restructure so the value is passed in as a genuine parameter at each
call site rather than computed as a local inside the procedure body
(parameters appear to go through a different, correctly-working
code path -- self-modifying immediate-operand patching that does get
updated per call, confirmed by testing).

Found this while building small reusable procedures for a from-scratch
port of an existing CoCo BASIC game -- happy to test further, provide
more reproductions, or dig into the specific peephole rule if useful.
