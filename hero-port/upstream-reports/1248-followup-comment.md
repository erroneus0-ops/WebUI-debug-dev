Hi Marco, thank you for looking into this and for the attached repro!

I think I can explain the discrepancy -- and I owe you a correction on
my original report, since the root cause is narrower (and different)
than what I described.

I compared your generated `bug1248.asm` against a fresh build on my
end, and the two match closely -- both show `_Ttmp1`/`_Ttmp2`/`_Ttmp3`
involved in exactly the same way, with your build's peephole optimizer
cleanly collapsing them down to `STB [_Ttmp1]`. So the code generation
itself isn't actually different between our environments.

What *is* different: I was always invoking the compiler with `-W`
(to see warnings/errors -- a habit from testing many things this
session). Testing the exact same source file with and without that
flag:

```
=== WITH -W ===
exit: 1
WARNING W001 - Multiplication could loose precision Ttmp2 Ttmp3 at 1 column 13 (14)

=== WITHOUT -W ===
exit: 0
```

Without `-W`, the file compiles cleanly all the way through to a real,
bootable `.dsk` -- confirmed. So `POKE` itself isn't broken on coco at
all. The actual bug is: **the `-W` flag causes a fatal compile failure
specifically when warning W001 would fire for this statement**, rather
than just displaying the warning and continuing (which is presumably
the intended behavior of `-W` everywhere else).

That also explains why you didn't see the issue -- if your test
invocation didn't happen to include `-W`, you'd never hit this at all,
and everything I'm seeing on your side confirms that.

Sorry for the noise from the original, mis-diagnosed report title --
happy to have this one re-titled/re-scoped if that's useful on your
end, something like "`-W` causes a fatal error (instead of just
displaying a warning) when W001 fires for POKE" would be more accurate
to what's actually going on. Let me know if a fresh, narrower repro
would help.
