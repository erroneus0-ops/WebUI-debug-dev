# Reading the Unravelled listings

The listings live in `unravelled/`. Their line format, lookup method and
verification are described in `unravelled/README.md`; in short:

```
ADDR  OBJECT BYTES      LABEL    OP    OPERAND             ; COMMENT
A000  A1 CB             POLCAT   FDB   KEYIN               ; GET A KEYSTROKE
```

Address `$A000`, label `POLCAT`, `FDB KEYIN` (a jump-vector-table entry
holding the address of the real `KEYIN` routine, `$A1CB`), and the book's
comment. Addresses and bytes are hex without `$`.

## Common mnemonics/directives you'll see

- **`ORG`** — sets the assembly origin address for what follows.
- **`EQU`** — defines a named constant (not an address the CPU executes
  from — a label used elsewhere in the source, resolved at assemble
  time).
- **`FDB`** — "form double byte": a 2-byte data value, most often used
  for jump-vector tables (a label whose "instruction" is just the target
  address of the real routine).
- **`RMB`** — "reserve memory bytes": declares N bytes of uninitialized
  storage at this label (this is how zero-page variables are declared,
  not actual code).
- **`SETDP`** — sets the assembler's Direct Page assumption for
  optimizing subsequent instructions to use 1-byte instead of 2-byte
  addressing (see the Direct Page note in `6809-techniques.md`).
- **`FCB` / `FCC`** — form constant byte(s) / form constant characters
  (string data).
- **`<` / `>` operand prefixes** — force direct-page or extended
  addressing respectively.
- Standard 6809 mnemonics otherwise (`LDA`, `STA`, `JSR`, `BEQ`, `PSHS`,
  `PULS`, etc.) — behave exactly as the 6809 ISA defines.

## Routine, symbol and difference files

- `unravelled/routines-*.txt` — one named routine per line: registers
  modified, address, plain-English description. Usually the right first
  stop for "which ROM routine does X".
- `unravelled/SYMBOLS.txt` — every label in all listings and memory maps,
  one per line with address, kind and defining file. Use `grep`.
- `unravelled/tables/differences-*.txt` — deltas between ROM revisions
  (e.g. CB 1.0 vs 1.2). Check these before assuming a routine's address or
  behavior is stable across every ROM version; see the T1-lowercase-hack
  note in `basic-interpreter.md` for why this matters in practice (the
  well-known `&H95AC` poke breaks across revisions for exactly this reason).
