/* ar2_compat.h -- compatibility declarations for Emscripten WASM build */
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

/* set_fstat type fix -- ar.c passes fileno(fp) as char* */
#define set_fstat(pn, fs) set_fstat_stub((char*)(intptr_t)(pn), (fs))

#endif
