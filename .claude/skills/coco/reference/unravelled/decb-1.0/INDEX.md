# Disk Extended Color BASIC 1.0 -- listing index

ROM image: $C000-$DFFF, SHA-1 `04115be3f97952b9d9310b52f806d04f80b40d03`.
Chunks are split only at named-label boundaries (a routine is never cut mid-way), ~260 lines max.
To find an address: pick the chunk whose range contains it. To find a label: `grep` ../SYMBOLS.txt.

| File | Range | Named entry points |
|---|---|---|
| decb10_C000-C0D3.asm | $C000-$C0D3 | DOSBAS, DCNVEC, DSKVAR |
| decb10_C0D4-C299.asm | $C0D4-$C299 | DKWMST, DVEC17, BASEXT, DEFEXT, DATEXT, BINEXT |
| decb10_C29A-C425.asm | $C29A-$C425 | DVEC22 |
| decb10_C426-C58E.asm | $C426-$C58E | DVEC0 |
| decb10_C58F-C6C1.asm | $C58F-$C6C1 | DVEC4, DVEC12 |
| decb10_C6C2-C85F.asm | $C6C2-$C85F | KILL, DVEC5, DVEC6, DVEC1, DVEC2, DVEC11 |
| decb10_C860-CA4A.asm | $C860-$CA4A | DVEC14, SAVE, MERGE, DVEC18, LOAD, DVEC13, DVEC7 |
| decb10_CA4B-CBCE.asm | $CA4B-$CBCE | DVEC8, DVEC3 |
| decb10_CBCF-CD5A.asm | $CBCF-$CD5A | DIR, DVEC10, CVN, MKN, LOC |
| decb10_CD5B-CF3E.asm | $CD5B-$CF3E | LOF, FREE, DRIVE, DVEC15, DXCVEC, DXIVEC |
| decb10_CF3F-D07F.asm | $CF3F-$D07F | RENAME, WRITE, FIELD, RSET, LSET |
| decb10_D080-D174.asm | $D080-$D174 | FILES, UNLOAD |
| decb10_D175-D2CB.asm | $D175-$D2CB | BACKUP |
| decb10_D2CC-D473.asm | $D2CC-$D473 | COPY, DSKI |
| decb10_D474-D66B.asm | $D474-$D66B | DSKO, DSKINI, VERIFY |
| decb10_D66C-D7DC.asm | $D66C-$D7DC | DSKCON, DNMISV, DIRQSV |
