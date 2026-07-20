/*
 * makewav_wrapper.c -- Emscripten WASM wrapper for makewav
 */
#include <stdio.h>
#include <emscripten.h>

extern int makewav_main(int argc, char **argv);

EMSCRIPTEN_KEEPALIVE
const char *makewav_version(void)
{
    return "makewav from Toolshed " TOOLSHED_VERSION;
}

EMSCRIPTEN_KEEPALIVE
int makewav_run(const char *srcpath, const char *dstpath)
{
    char *argv[] = { "makewav", (char *)srcpath, (char *)dstpath, NULL };
    return makewav_main(3, argv);
}
