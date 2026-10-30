# Unravelled converter

Regenerates `.claude/skills/coco/reference/unravelled/` from `Unravelled II.xls`,
verifying every byte and label against genuine ROM images.

Requirements: Python 3 with `xlrd` (`pip install xlrd`), and ROM images built from
https://github.com/stahta01/coco_roms (`make` there builds them and checks their
SHA-1 against MAME's known-good hashes). The ROMs are used only for verification
and are not committed here.

```
git clone https://github.com/stahta01/coco_roms && make -C coco_roms
export UNRAV_XLS="../Exploring-6809-Assembly/documentation/reference/Unravelled II.xls"
export UNRAV_ROMS=coco_roms
export UNRAV_OUT=.claude/skills/coco/reference/unravelled
python3 tools/unravelled/build.py && python3 tools/unravelled/readme.py
```

`build.py` prints any byte corrections, label moves, and remaining
label/reference disagreements (should be none). `readme.py` writes the output
folder's README, including the verification tables. Intermediate JSON files go
to `UNRAV_WORK` (default: the current directory).
