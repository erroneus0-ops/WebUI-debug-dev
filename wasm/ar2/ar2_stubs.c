/*
 * ar2_stubs.c -- minimal stubs for ar2 WASM build
 * set_fstat is provided by arsup.c
 */
#include <sys/types.h>

/* ftruncate stub -- delete cleanup impaired but other ops work */
int ftruncate(int fd, off_t length) { return 0; }
