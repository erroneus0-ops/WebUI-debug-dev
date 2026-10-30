# Disk Extended Color BASIC 1.1 -- listing index

ROM image: $C000-$DFFF, SHA-1 `10bdc5aa2d7d7f205f67b47b19003a4bd89defd1`.
Chunks are split only at named-label boundaries (a routine is never cut mid-way), ~260 lines max.
To find an address: pick the chunk whose range contains it. To find a label: `grep` ../SYMBOLS.txt.

| File | Range | Named entry points |
|---|---|---|
| decb11_C000-C0E6.asm | $C000-$C0E6 | DOSBAS, DCNVEC, DSKVAR, DSINIT, DOSVEC |
| decb11_C0E7-C2B1.asm | $C0E7-$C2B1 | DKWMST, DVEC17, BASEXT, DEFEXT, DATEXT, BINEXT |
| decb11_C2B2-C44A.asm | $C2B2-$C44A | DVEC22 |
| decb11_C44B-C5BB.asm | $C44B-$C5BB | DVEC0 |
| decb11_C5BC-C6EE.asm | $C5BC-$C6EE | DVEC4, DVEC12 |
| decb11_C6EF-C892.asm | $C6EF-$C892 | KILL, DVEC5, DVEC6, DVEC1 |
| decb11_C893-CA47.asm | $C893-$CA47 | DVEC2, DVEC11, DVEC20, DVEC14, SAVE, MERGE, DVEC18 |
| decb11_CA48-CC1B.asm | $CA48-$CC1B | LOAD, DVEC13, DVEC7, DVEC8 |
| decb11_CC1C-CE01.asm | $CC1C-$CE01 | DVEC3, DIR, DVEC10, CVN |
| decb11_CE02-CF67.asm | $CE02-$CF67 | MKN, LOC, LOF, FREE, DRIVE, DVEC15, DXCVEC, DXIVEC |
| decb11_CF68-D15B.asm | $CF68-$D15B | LCF568, RENAME, WRITE, FIELD, RSET, LSET |
| decb11_D15C-D261.asm | $D15C-$D261 | FILES, UNLOAD |
| decb11_D262-D3B8.asm | $D262-$D3B8 | BACKUP |
| decb11_D3B9-D561.asm | $D3B9-$D561 | COPY, DSKI |
| decb11_D562-D74D.asm | $D562-$D74D | DSKO, DSKINI, DOS |
| decb11_D74E-DF58.asm | $D74E-$DF58 | VERIFY, DSKCON, DNMISV, DIRQSV, DOSCOM, DOSINI, END |
