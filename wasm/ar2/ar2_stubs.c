/*
 * ar2_stubs.c -- stub for ftruncate in ar2
 * ftruncate used only for delete operations.
 * Without it, deletes don't clean up properly but other ops work fine.
 */
#include <sys/types.h>
int ftruncate(int fd, off_t length) { return 0; }
