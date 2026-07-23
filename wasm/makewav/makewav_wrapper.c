/*
 * makewav_wrapper.c -- Emscripten WASM wrapper for makewav
 *
 * makewav usage: makewav [options] input-file
 *   -c    input has DECB header
 *   -r    raw binary (no S-record)
 *   -k    output CAS instead of WAV
 *   -o<f> output filename (default: file.wav)
 */
#include <stdio.h>
#include <string.h>
#include <emscripten.h>

extern int makewav_main(int argc, char **argv);

EMSCRIPTEN_KEEPALIVE
const char *makewav_version(void)
{
    return "makewav from Toolshed " TOOLSHED_VERSION;
}

/* Convert a DECB binary to WAV -- build 20260720_223511 */
EMSCRIPTEN_KEEPALIVE
int makewav_run(const char *srcpath, const char *dstpath) /* v2-with-c-flag */
{
    char out_arg[256];
    snprintf(out_arg, sizeof(out_arg), "-o%s", dstpath);
    char *argv[] = { "makewav", "-c", "-r", out_arg, (char *)srcpath, NULL };
    return makewav_main(5, argv);
}

/* Convert a DECB binary to CAS format */
EMSCRIPTEN_KEEPALIVE
int makewav_run_cas(const char *srcpath, const char *dstpath)
{
    char out_arg[256];
    snprintf(out_arg, sizeof(out_arg), "-o%s", dstpath);
    char *argv[] = { "makewav", "-r", "-k", "-s9600", out_arg, (char *)srcpath, NULL };
    return makewav_main(6, argv);
}

/* Convert raw binary to WAV */
EMSCRIPTEN_KEEPALIVE
int makewav_run_raw(const char *srcpath, const char *dstpath)
{
    char out_arg[256];
    snprintf(out_arg, sizeof(out_arg), "-o%s", dstpath);
    char *argv[] = { "makewav", "-r", "-s9600", out_arg, (char *)srcpath, NULL };
    return makewav_main(5, argv);
}
