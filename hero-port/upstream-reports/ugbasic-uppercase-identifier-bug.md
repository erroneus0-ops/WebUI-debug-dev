Title: Identifiers starting with an uppercase letter fail to parse at all (not just keyword-prefix collisions)

## Summary

Any identifier whose *first character* is uppercase fails to parse,
regardless of whether the identifier resembles a real keyword or not.
This is broader than it might first appear: it's not specifically
about keyword-prefix collisions (like `ANDX` colliding with `AND`) --
a totally arbitrary uppercase-first identifier with zero keyword
resemblance (`K`, `QRSTUV`) fails exactly the same way. The only thing
that matters is the case of the *first character*; everything after
it can be any case.

ugBASIC's own manual examples are consistent with this (every example
I've found uses a lowercase-first variable name: `address`,
`executable`, `x`, `xx`), so this might be an intentional rule rather
than a bug -- but if so, it isn't stated anywhere I could find, and
the error message doesn't hint at the real cause at all.

## Environment

- ugBASIC v1.18.1 (built from source)
- Target: coco (Motorola 6809), though this looks target-independent
- Invocation: `ugbc.coco -W source.bas source.asm`

## Minimal reproduction

Fails (uppercase-first, single letter, no keyword resemblance):

```basic
K = 5
PRINT K
```
```
*** ERROR: syntax error, unexpected K, expecting end of file at 1 column 1 (2)
```

Fails (uppercase-first, longer, no keyword resemblance at all):

```basic
QRSTUV = 5
PRINT QRSTUV
```
```
*** ERROR: syntax error, unexpected Q, expecting end of file at 1 column 1 (2)
```

Fails (uppercase-first, keyword as a literal prefix -- the case I found
first, which made me initially think this was specifically about
keyword-prefix collisions):

```basic
DIM ANDX AS INTEGER
```
```
*** ERROR: syntax error, unexpected AND, expecting identifier (name) at 3 column 4 (23)
```

Works fine (lowercase-first, rest of identifier any case):

```basic
kx = 5
PRINT kx
```
compiles cleanly, as does `kX = 5` (lowercase first letter, uppercase
everywhere else).

So the actual rule, as best I can tell from testing rather than
documentation: **the first character of an identifier must be
lowercase.** Whether the rest of the identifier resembles a keyword,
or is entirely uppercase, or mixed case, doesn't matter once that
first-character condition is met.

## Impact

For anyone porting or adapting existing BASIC source that uses
all-uppercase variable names (extremely common in classic 8-bit BASIC
-- single/double letter names like `A`, `PX`, `L1` are everywhere),
every single variable name needs to be changed to start with a
lowercase letter. That's a mechanical, low-risk fix once you know
about it, but the error message gives no indication that identifier
casing is the actual problem -- it just names either an unrelated
keyword (`unexpected AND`) or the identifier's own first letter
(`unexpected K`) with no mention of casing rules at all, so the real
cause is very non-obvious the first time someone hits it.

## Workaround found

Start every identifier with a lowercase letter. This matches the
convention already used throughout ugBASIC's own manual examples, so
it may be working as intended -- if so, this report is really asking
for a clearer error message (something like "identifiers must start
with a lowercase letter" would have saved a fair amount of isolation
testing) rather than a behavior change.

Found this while trying to declare an IMAGE-typed variable for
GET/PUT during a from-scratch port of an existing CoCo BASIC game,
whose original source uses exclusively uppercase variable names --
happy to test further or provide more detail if useful.

