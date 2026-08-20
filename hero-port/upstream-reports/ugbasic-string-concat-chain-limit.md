Title: Chaining >~15 string concatenations in one expression silently corrupts the result

## Summary

Building a string from more than about 15 chained `+` concatenation
operations in a single expression produces a string whose `STRPTR()`
address is no longer usable -- reading from it (e.g. via inline
assembly) silently returns garbage/nothing, with no compile error, no
runtime error, nothing. The program just behaves as if the string were
never written.

Confirmed via direct bisection: it's specifically the *number of
chained concatenation operations*, not the final string length -- a
20-character string built from 3 concatenations of 5-character literal
substrings works fine, while a 20-character string built from 19
concatenations of single-character `CHR$()` calls does not.

## Environment

- ugBASIC v1.18.1 (built from source)
- Target: coco (Motorola 6809)
- Host: Ubuntu 24.04
- Invocation: `ugbc.coco -W -C /path/to/asm6809 -b /path/to/decb -o out.dsk -O dsk source.bas`

## Minimal reproduction

Working (15 chained terms):

```basic
PMODE 4, 1
CLS
topbotdata$ = CHR$(159)+CHR$(159)+CHR$(159)+CHR$(159)+CHR$(159)+ _
              CHR$(159)+CHR$(159)+CHR$(159)+CHR$(159)+CHR$(159)+ _
              CHR$(159)+CHR$(159)+CHR$(159)+CHR$(159)+CHR$(159)
topbotaddr = STRPTR(topbotdata$)
BEGIN ASM
    LDX BITMAPADDRESS
    LDU _topbotaddr
    LDB #15
copyloop
    LDA ,U+
    STA ,X+
    DECB
    BNE copyloop
END ASM
DO
LOOP
```

This correctly writes 15 bytes of `$9F` to the screen (confirmed visually
in XRoar, and by the fact that a subsequent semigraphics-mode flip
renders a clean solid-colour bar).

Broken (16 chained terms -- same pattern, one more `CHR$(159)+`):

```basic
PMODE 4, 1
CLS
topbotdata$ = CHR$(159)+CHR$(159)+CHR$(159)+CHR$(159)+CHR$(159)+ _
              CHR$(159)+CHR$(159)+CHR$(159)+CHR$(159)+CHR$(159)+ _
              CHR$(159)+CHR$(159)+CHR$(159)+CHR$(159)+CHR$(159)+ _
              CHR$(159)
topbotaddr = STRPTR(topbotdata$)
BEGIN ASM
    LDX BITMAPADDRESS
    LDU _topbotaddr
    LDB #16
copyloop
    LDA ,U+
    STA ,X+
    DECB
    BNE copyloop
END ASM
DO
LOOP
```

This compiles cleanly and runs with no error, but writes nothing
usable -- the destination memory doesn't reflect the intended byte
pattern at all.

Also confirmed NOT broken (same final length, fewer chained ops):

```basic
topbotdata$ = "AAAAA" + "AAAAA" + "AAAAA" + "AAAAA"   ' 20 chars, 3 concatenations -- works fine
```

## Impact

Anyone building a longer string via repeated single-character (or
otherwise granular) concatenation -- a natural way to build a byte
pattern for graphics/sound/data purposes when the individual values
aren't representable as a plain string literal -- will silently get a
corrupted or unusable result with zero indication anything went wrong.
This is a particularly nasty class of bug because there's no error
message at all, at compile time or runtime, to point at the actual
cause.

## Workaround found

Keep any single chained-concatenation expression to no more than ~14-15
`+` operations. For longer strings, either:
- build them from fewer, larger literal substrings (if the content
  allows it), or
- if all the bytes are actually identical (e.g. a solid-colour fill),
  skip the long string entirely -- store just one byte and read it
  repeatedly via a non-incrementing source address (`LDA ,U` instead of
  `LDA ,U+`) while only the destination pointer advances.

Found this while building a small test program during a from-scratch
port of an existing CoCo BASIC game -- happy to provide more detail,
the full generated .asm for either case, or test further if useful.
