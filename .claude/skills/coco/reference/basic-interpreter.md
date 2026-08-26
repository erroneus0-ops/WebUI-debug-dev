# Color BASIC interpreter internals

Distilled from `hero-port/COCO-BASIC-INTERNALS.md` in the main repo,
where the full test methodology and disassembly traces live. Everything
here was confirmed via real disassembly cross-checked with live tests in
XRoar, not inferred from behavior alone.

## The tokenizer (`CRUNCH`) — how it actually matches keywords

This explains a very common porting gotcha: **a variable name touching a
following keyword with no space gets silently swallowed.**
`IFX=YTHEN...` fails; `IFX=Y THEN...` works.

The tokenizer does **not** read a whole word and check it against a
keyword table afterward. It tries to match a known keyword starting at
every input position, and the moment one letter fails to begin a match,
it sets an "illegal token" flag (`V43` in the ROM's own labeling) that
stays set for the rest of that unbroken run of letters — meaning it never
even *attempts* keyword-matching again until it hits a non-letter
character (space, digit, operator) that clears the flag.

Real code, from `CRUNCH` (`$B821` in the CB 1.2 disassembly — see
`routines-cb.csv`), annotated. **`CRUNCH`'s actual entry point does more
than the tokenizer logic itself** — worth knowing before assuming this
routine is a clean, self-contained tokenizer:

```
LB821   JSR   RVEC23      ; HOOK INTO RAM -- CRUNCH's very first act is
                          ; calling a RAM hook vector (see memory-map.md's
                          ; RAM hook vector table), meaning tokenization
                          ; itself can be redirected by Extended/Disk
                          ; BASIC before any keyword-matching logic runs
LB824   LDX   CHARAD      ; get BASIC's input pointer address
LB826   LDU   #LINBUF     ; point U to line input buffer
LB829   CLR   V43        ; clear "illegal token" flag
LB82B   CLR   V44        ; clear DATA flag (a second, separate flag --
                          ; not traced further here, but distinct from V43)
LB82D   LDA   ,X+        ; get next input character
        ...
        TST   V43        ; already inside an illegal-token run?
        BEQ   LB844      ; no -- go try to match a keyword
        JSR   LB3A2      ; yes -- just check: still upper-case alpha?
        BCC   LB852      ; if so, copy it straight through, don't
                         ; even attempt a keyword match this time
...
LB8E6   COM   V43        ; SET the flag -- this letter matched no
                         ; keyword at all
```

Walking `IFX=YTHEN` through this: `IF` matches as a keyword. `X` matches
nothing — flag sets. `=` is non-alpha — flag clears. `Y` alone matches no
keyword — flag sets *again*. Because the flag is now set, `T`,`H`,`E`,`N`
are never even *tried* — they're copied straight through, still "inside"
the illegal-token run that started at `Y`. **A digit immediately before a
keyword doesn't have this problem**: `CRUNCH` explicitly excludes ASCII
digits from ever entering the illegal-token path (`CMPA #'0` / `CMPA
#'9'` checks in the same routine).

**Practical rule:** always leave a space between a variable reference and
a following keyword, and between any two adjacent keywords/identifiers in
general. Any single non-alpha character resets the flag cleanly.

## `ELSE` — it works fine, the earlier "it's flaky" belief was wrong

`ELSE` works completely reliably with any statement, and needs no
preceding `ELSEIF`. The cases that looked like `ELSE` failures
(`IFA=BTHENC=5ELSEC=6`) were actually the exact same keyword-boundary
tokenizer issue above, just also affecting `ELSE`. With a space at every
keyword boundary, `IF A=B THEN 30 ELSE C=6:PRINT "NO C=";C` (an
assignment after a bare `ELSE`, no `ELSEIF`) executes correctly.

One more confirmed detail from the `CRUNCH` trace: the tokenizer
automatically inserts a colon immediately before a recognized `ELSE`
token during compilation (`CMPB #$84` / `LDA #':'` in the real ROM code)
— which is *why* `ELSE <statement>` behaves like a fresh new statement:
internally it's already been turned into `:ELSE <statement>` before
execution ever sees it.

**Practical rule for porting:** use `ELSE` freely when it matches the
original source's structure — porting logic directly is more faithful
than rewriting into chains of separate `IF`s — just add explicit spaces
around every keyword (`IF`, `THEN`, `ELSE`, `ELSEIF`).

## RAM hook vectors and the T1-lowercase patch (a full worked example)

Starting at `$15E`, Color BASIC exposes 25 documented 3-byte `JMP`
vectors so Extended/Disk BASIC ROMs can redirect Color BASIC's own
behavior without patching the base ROM (see `memory-map.md`).

`$167` (decimal 359) is the `CONSOLE OUT` hook — the very first link in
the chain that runs on every character output. The full traced call
chain (via `Unravelled II.xls`, cross-tabs CB/ECB/SECB/DECB):

```
$167 (359)   CONSOLE OUT RAM hook -- originally JMP $CC1C
    |
    v
$CC1C  DVEC3 (Disk Extended Color BASIC 1.1)
       TST DEVNUM
       LBLE XVEC3          ; branch onward if not a disk file
       [... else: write byte to a disk FCB, unrelated to screen output]
    |
    v
$8273  XVEC3 (Extended Color BASIC 1.1)
       TST DEVNUM
       LBEQ L95AC          ; BRANCH IF SCREEN
       [... else: check DLOAD/cassette special cases]
    |
    v
$95AC  L95AC
       PSHS X,B,A
       LDX #SAM+8
       STA 10,X / STA $08,X / ...   ; reset SAM display page to $400
       STA $-02,X / ...             ; reset SAM's VDG to alpha-numeric mode
       LDA PIA1+2
       ANDA #$07           ; <-- clears bits 3-7, INCLUDING the T1 bit
       STA PIA1+2
       PULS A,B,X,PC
```

`POKE 359,57` writes `$39` (6809 `RTS`) over the very first byte of this
chain, so nothing downstream — including the `ANDA #$07` that stomps the
T1 lowercase-font bit — ever runs again, for any character output,
regardless of which ROM revision put what further down the chain.

This is why ordinary text still displays correctly even though the whole
chain is now skipped: the chain is purely a *defensive reset*, not the
actual character-drawing logic (which lives elsewhere, untouched).

**Why the older, widely-circulated `&H95AC` poke can fail:** `$95AC` is a
specific byte offset inside one particular ROM revision's own layout —
`359` is a documented, stable *structural* entry point that doesn't move
between revisions. Also, `$95AC` is genuine read-only ROM in normal
operation — poking it directly does nothing unless 64K/all-RAM mode is
already active (see `hardware-io.md`).

## Control codes: what `PRINT`/`CHR$` actually does with 0-31

Only two control codes in this range have any real effect at all:

- **`CHR$(8)` (backspace)** — erases exactly the *one* character
  immediately behind the current cursor position with a space.
- **`CHR$(13)` (carriage return)** — clears from the current cursor
  position to the end of the current screen line.

Every other value 0-31 is genuinely non-printing — confirmed by testing
each value in isolation on its own screen row (an earlier sweep across a
whole row conflated "no glyph" with "wiped by `CHR$(13)`'s side effect on
a later value in the same row" — worth remembering as a methodology
trap if re-verifying this kind of thing).

**Practical upshot:** any string built from raw byte values (not pure
literal text) can treat 0-31 as inert *except* 8 and 13, which must be
handled deliberately if they show up unintentionally.

**Runnable demonstration** (confirmed working, 2026-08-26) — builds a
full character map of the VDG's normal mode and shows the POKE-vs-PRINT
distinction side by side on one screen. The top half POKEs every byte
0-127 directly into screen RAM (no interpretation at all); the bottom
half PRINTs the same range via `CHR$()` (full control-code handling
applies). Values 128-255 are POKEd only, not printed, since printed
they're visually identical to their poke'd counterparts and wouldn't
fit both ranges on one screen:

```basic
CLS4:A=&H400:B=8*32:FORI=0TO127:POKEA+I,I:?@B+I,CHR$(I);:NEXT:FORI=128TO255:POKEA+I,I:NEXT
```

Run this and hex-dump `$0400` onward: the POKE'd region shows every
byte value 0-255 exactly as written, an unbroken 1:1 map from byte to
glyph. The PRINTed region (starting at `8*32=256` bytes in, i.e.
`$0500`) shows the same CHR$ values 0-127 sent through, but with visible
gaps and shifts exactly where `CHR$(8)` and `CHR$(13)` did their thing
(erasing/backspacing over what came before) — directly, visually
confirming the prose facts above rather than just stating them.

## PRINT translates ASCII into VDG screen codes -- POKE never does

This is a second, separate transformation from the control-code handling
above, and it's easy to conflate the two. Confirmed by walking the same
demo dump forward past the control-code range, into ordinary printable
characters: `PRINT`/`CHR$()` add a flat **`+$40`** offset to standard
ASCII before the byte ever reaches screen memory. `POKE` never does --
whatever byte value is poked is exactly what ends up in VIDRAM.

Worked example, confirmed against a real running game's actual memory
(`hero11.dsk`'s high-score screen, ASCII `'0'` = `$30` printed via a
plain `PRINT` of a literal `"000000"` string): the byte that actually
lands in screen memory is `$70`, not `$30` -- exactly `$30 + $40`. The
same offset holds across the whole printable range in the demo dump
above: space (`$20`) prints as `$60`, `'!'` (`$21`) prints as `$61`, and
so on, consistently.

**Practical upshot:** any code that needs to predict or interpret what
byte value actually ends up in screen memory from a `PRINT`ed string
(as opposed to a directly `POKE`d one) needs to add `$40` to the
character's plain ASCII value first. This is exactly why comparing a
POKE-based test against a real game's PRINT-based output byte-for-byte
can look "wrong" at first glance when it isn't -- the values are
supposed to differ by this fixed offset, and it's a real, confirmed
VDG/font-ROM encoding fact, not a bug or a mismatch to chase.
