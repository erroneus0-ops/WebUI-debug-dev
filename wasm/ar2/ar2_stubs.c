/*
 * ar2_stubs.c -- stubs for ar2 WASM build
 */
#include <sys/types.h>

/* ftruncate stub -- delete cleanup impaired but other ops work */
int ftruncate(int fd, off_t length) { return 0; }

/* set_fstat -- stub implementation matching ar.h declaration
   Called with fileno(fp) as first arg (int cast to char*)
   We just ignore both arguments safely */
void set_fstat(char *pn, void *fs) { (void)pn; (void)fs; }
