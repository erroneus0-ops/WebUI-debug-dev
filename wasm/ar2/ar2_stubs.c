/*
 * ar2_stubs.c -- stub for ftruncate in ar2
 * ftruncate used only for delete operations.
 * Without it, deletes don't clean up properly but other ops work fine.
 */
#include <sys/types.h>
int ftruncate(int fd, off_t length) { return 0; }

/* pflinit -- OS-9 path list initialization, stub for WASM */
void pflinit(void) { }

/* strucmp -- case-insensitive string compare, OS-9 specific */
#include <string.h>
#include <ctype.h>
int strucmp(const char *s1, const char *s2) {
    while (*s1 && *s2) {
        int d = tolower((unsigned char)*s1) - tolower((unsigned char)*s2);
        if (d) return d;
        s1++; s2++;
    }
    return tolower((unsigned char)*s1) - tolower((unsigned char)*s2);
}

/* set_fstat -- sets file status; in ar2 called with fileno(fp) as char*
   This is a type mismatch in the original -- stub it safely */
void set_fstat(char *pn, void *fs) { }
