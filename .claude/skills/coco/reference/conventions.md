# Reading the disassembly CSVs

The `xls-conversion/` tree preserves the original "Color BASIC
Unravelled"-style spreadsheet layout as plain CSV, one row per source
line. Columns vary slightly by tab, but the common pattern in the big
listing tabs (`CB 1.2`, `ECB 1.1`, `SECB`, `DECB 1.1`, `DECB 1.0`) is:

| Col (0-indexed) | Meaning |
|---|---|
| 0 | Line number in the original listing |
| 1 | (usually blank) |
| 2 | **Address**, hex, no `$` prefix (e.g. `A000`) — used for chunk indexing |
| 3-4 | Raw assembled opcode bytes |
| 5-9 | (varies by tab) |
| 10 | Label (if this line defines one) |
| 11 | Mnemonic (`ORG`, `FDB`, `EQU`, `JMP`, `LDA`, ...) |
| 12 | Operand |
| 13 | Comment (original author's own annotation, often the most useful field) |

Example row:
```
0002,,A000,A1,CB,,,,,POLCAT,FDB,KEYIN,GET A KEYSTROKE
```
Line 2, address `$A000`, label `POLCAT`, `FDB KEYIN` (a jump-vector-table
entry pointing at the real `KEYIN` routine), comment "GET A KEYSTROKE".

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
- Standard 6809 mnemonics otherwise (`LDA`, `STA`, `JSR`, `BEQ`, `PSHS`,
  `PULS`, etc.) — behave exactly as the 6809 ISA defines.

## The `Routines <ROM>` / `Symbols <ROM>` tabs

Much smaller than the full listings and usually the right first stop:

- `routines-*.csv` — plain-English one-line descriptions of named
  routines, with their entry address. Multi-line descriptions wrap across
  adjacent rows (see the sample in `SKILL.md`'s hardware-io intro).
- `symbols-*.csv` (ECB/SECB/DECB only) — flat name→address symbol table,
  laid out in multiple name/address column pairs per row (dense format,
  not one symbol per row) — useful for a quick "what address is this
  label" or "what label is at this address" check before opening a full
  listing chunk.

## The `Differences <ROM>` tabs

Document specific deltas between ROM revisions (e.g. `Differences CB
1.0` vs `1.1`) — check these before assuming a routine's address or
behavior is stable across every ROM version; see the T1-lowercase-hack
note in `basic-interpreter.md` for why this matters in practice (the
well-known `&H95AC` poke breaks across revisions for exactly this
reason).
