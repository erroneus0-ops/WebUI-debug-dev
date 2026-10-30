# FIXME FIRST: the Unravelled reference moved and changed format

**Read this before working in any of Daniel's CoCo repos** (`cocotools-wasm`,
`Exploring-6809-Assembly`, `SuperComm-disassembled`, or new ones).

## What changed (2026-10-30)

The CSV conversion of `Unravelled II.xls` that used to live in
`.claude/skills/coco/reference/xls-conversion/` (folders `listings/` and
`reference-tabs/`, files like `ecb_03000-03599.csv` and
`memory-map-decb.csv`) is **gone**. It was replaced by:

```
WebUI-debug-dev/.claude/skills/coco/reference/unravelled/
  README.md        <- read first: line format, lookup method, verification
  SYMBOLS.txt      <- every label, one per line: grep -w NAME SYMBOLS.txt
  cb-1.2/ ecb-1.1/ decb-1.0/ decb-1.1/ secb/   <- listings, chunked at routine boundaries
  memory-map-*.asm  routines-*.txt  tables/*.txt
```

Every byte and every referenced label in it was verified against genuine ROM
images, and errors in the spreadsheet were corrected. Prefer it over the PDFs
and over the `.xls`. The converter is in `tools/unravelled/`.

Inside WebUI-debug-dev, all references were already updated.

## Using the skills from another repo

The `coco` and `coco3` skills live in this repo's `.claude/skills/`. Claude
Code only sees a repo's own `.claude/skills/` when it runs in that repo, plus
your personal skills folder (`%USERPROFILE%\.claude\skills\` on Windows),
which it sees everywhere. Options, best first:

1. **Link them into your personal skills folder (recommended).** One copy,
   always current: a `git pull` here updates every project. In a Windows
   Command Prompt:
   ```
   mkdir "%USERPROFILE%\.claude\skills"
   mklink /J "%USERPROFILE%\.claude\skills\coco"  "C:\DATA\git\WebUI-debug-dev\.claude\skills\coco"
   mklink /J "%USERPROFILE%\.claude\skills\coco3" "C:\DATA\git\WebUI-debug-dev\.claude\skills\coco3"
   ```
   (`mklink /J` makes a directory junction; it needs no admin rights.)
2. **Copy** both folders into the other repo's `.claude/skills/`. Works, but
   the copies go stale when this one is improved.
3. **Point at it** from the other repo's notes (e.g. a line in its
   `CLAUDE.md`). Weakest: Claude only finds it if it reads that note.

## Known loose ends in the other repos (found 2026-10-30)

None of the other repos referenced the old CSV paths. These are what's left:

**Exploring-6809-Assembly**
- `BOOK_HANDOFF.md`, section "Unravelled Series -- OCR Conversion
  (PENDING)": this task is **done** for the BASIC ROMs, from a better source
  (the spreadsheet, verified against real ROMs) instead of OCR'd PDFs. Mark it
  done and point to `unravelled/` above. Only **OS-9 Level II Unravelled**
  remains unconverted; it isn't in the spreadsheet.
- Same section says *"Extended Color BASIC Unravelled (EXTBAS ROM -- includes
  SOUND at $A94B)"*. **Wrong:** `SOUND` at $A94B is in **Color BASIC**
  (`cb-1.2/cb_A910-AA19.asm`); $A94B is in the $A000-$BFFF Color BASIC ROM,
  and Extended BASIC is $8000-$9FFF.
- Its "Note for Claude" says to check "the Unravelled text files FIRST".
  Those text files are now `unravelled/` above; say so explicitly.

**SuperComm-disassembled**
- `CLAUDE_MANIFESTO.md` (around line 222) points to `BOOK_HANDOFF.md` for
  "the Unravelled series OCR-conversion idea". That file belongs to
  Exploring-6809-Assembly, and the idea is done; update or drop the mention.
- `TOOLS_HANDOFF.md` and `TOOLS_HANDOFF_.md` (the second looks like a stray
  duplicate) mention the BASIC token table in "Color BASIC Unravelled". Add
  that it is now searchable in `unravelled/` (`tables/` and the `cb-1.2`
  listing).

**cocotools-wasm**
- `TOOLS_HANDOFF.md` line ~135: same token-table mention as above.

## How to check a repo for stale references

From the repo root:

```
git grep -nIE "xls-conversion|reference-tabs|_[0-9]{5}-[0-9]{5}\.csv|memory-map-[a-z]+\.csv|routines-[a-z]+\.csv|Unravelled"
```

Every hit should either point at `unravelled/` or simply name the book.
