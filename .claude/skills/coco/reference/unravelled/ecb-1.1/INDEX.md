# Extended Color BASIC 1.1 -- listing index

ROM image: $8000-$9FFF, SHA-1 `ad927fb4f30746d820cb8b860ebb585e7f095dea`.
Chunks are split only at named-label boundaries (a routine is never cut mid-way), ~260 lines max.
To find an address: pick the chunk whose range contains it. To find a label: `grep` ../SYMBOLS.txt.

| File | Range | Named entry points |
|---|---|---|
| ecb_8000-8285.asm | $8000-$8285 | EXBAS, XBWMST, XVEC3 |
| ecb_8286-847F.asm | $8286-$847F | XVEC8, XVEC18, XVEC20, XVEC23, COS, TAN, ATN, LOG |
| ecb_8480-8532.asm | $8480-$8532 | SQR, EXP, FIX |
| ecb_8533-86BD.asm | $8533-$86BD | EDIT, TRON, TROFF, POS |
| ecb_86BE-8870.asm | $86BE-$8870 | VARPTR, STRING, INSTR, XVEC19, XVEC15 |
| ecb_8871-8A08.asm | $8871-$8A08 | DEF, XVEC17, XIRQSV, TIMER, DEL |
| ecb_8A09-8BDC.asm | $8A09-$8BDC | RENUM |
| ecb_8BDD-8CF0.asm | $8BDD-$8CF0 | HEXDOL, DLOAD, $ AMBLE. THE PREAMBLE CONTAINS A BLOCK LENGTH AND A LOAD ADDRESS SO |
| ecb_8CF1-8E8F.asm | $8CF1-$8E8F | XVEC4, $ READ A CHARACTER FROM THE RS 232 INPUT PORT. |
| ecb_8E90-9022.asm | $8E90-$9022 | XVEC9 |
| ecb_9023-91D7.asm | $9023-$91D7 | - |
| ecb_91D8-9338.asm | $91D8-$9338 | - |
| ecb_9339-93BA.asm | $9339-$93BA | PPOINT, PSET, PRESET |
| ecb_93BB-9545.asm | $93BB-$9545 | LINE, PCLS |
| ecb_9546-968A.asm | $9546-$968A | COLOR, PMOD, SCREEN |
| ecb_968B-9757.asm | $968B-$9757 | PCLEAR, PCOPY, GET |
| ecb_9758-98EB.asm | $9758-$98EB | PUT |
| ecb_98EC-9A21.asm | $98EC-$9A21 | PAINT |
| ecb_9A22-9BAB.asm | $9A22-$9BAB | PLAY |
| ecb_9BAC-9CB5.asm | $9BAC-$9CB5 | - |
| ecb_9CB6-9E9C.asm | $9CB6-$9E9C | DRAW |
| ecb_9E9D-9FFF.asm | $9E9D-$9FFF | CIRCLE |
