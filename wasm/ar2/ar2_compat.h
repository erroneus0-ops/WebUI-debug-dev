/* ar2_compat.h -- compatibility for Emscripten WASM build */
#ifndef AR2_COMPAT_H
#define AR2_COMPAT_H

#include <string.h>
#include <ctype.h>

/* pflinit -- OS-9 path list init, no-op in WASM */
static inline void pflinit(void) { }

/* strucmp -- case-insensitive string compare */
static inline int strucmp(const char *s1, const char *s2) {
    while (*s1 && *s2) {
        int d = tolower((unsigned char)*s1) - tolower((unsigned char)*s2);
        if (d) return d;
        s1++; s2++;
    }
    return tolower((unsigned char)*s1) - tolower((unsigned char)*s2);
}

/* set_fstat -- stub, ignores arguments (called with fileno() which is int not char*) */
#define FILDES void
static inline void set_fstat(char *pn, FILDES *fs) { (void)pn; (void)fs; }

#endif
