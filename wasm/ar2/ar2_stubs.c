/*
 * ar2_stubs.c -- stubs for ar2 WASM build
 * pflinit, strucmp defined in ar2_compat.h (included via -include flag)
 * set_fstat_stub: the real implementation called via set_fstat macro
 */
#include <sys/types.h>
#include "ar2_compat.h"

/* ftruncate stub -- delete cleanup impaired but other ops work */
int ftruncate(int fd, off_t length) { return 0; }

/* set_fstat_stub -- called via set_fstat macro with cast int->char* */
void set_fstat_stub(char *pn, void *fs) { }
