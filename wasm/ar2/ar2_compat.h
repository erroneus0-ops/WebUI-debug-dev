/* ar2_compat.h -- compatibility for Emscripten WASM build
 * Included before ar.h via -include flag
 * IMPORTANT: do not redefine types declared in ar.h
 */
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

/* set_fstat -- called with fileno(fp) cast issue, stub it via macro
 * ar.h defines FILDES struct -- we just make the call a no-op */
#define set_fstat(pn, fs)  ((void)0)

#endif
