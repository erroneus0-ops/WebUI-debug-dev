/*
 * toolshed_wrapper.c -- Emscripten WASM wrapper for toolshed decb operations
 *
 * Exports:
 *
 *   int ts_dskini(const char *diskpath, int tracks)
 *   int ts_copy(const char *srcpath, const char *dstpath, int file_type, int data_type)
 *   int ts_dir(const char *diskpath, const char *outpath)
 *   int ts_kill(const char *pathlist)
 *
 * Pathlist format (toolshed convention):
 *   Native file:  "/path/to/file.bin"
 *   DECB file:    "/path/to/disk.dsk,FILENAME.BIN:0"
 *
 * All paths are virtual filesystem paths under Emscripten.
 * The disk image must be pre-populated in the virtual FS before calling.
 *
 * Compile with build.sh
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <emscripten.h>

#include "decbpath.h"
#include "nativepath.h"
#include "cocotypes.h"

/* ------------------------------------------------------------------ */
/* dskini                                                               */
/* ------------------------------------------------------------------ */

EMSCRIPTEN_KEEPALIVE
int ts_dskini(const char *diskpath, int tracks)
{
    if (tracks != 35 && tracks != 40 && tracks != 80)
        tracks = 35;

    return (int)_decb_dskini(
        (char *)diskpath,
        tracks,
        NULL,   /* no disk name */
        1,      /* 1 HDB drive */
        256,    /* bytes per sector */
        0       /* not skitzo */
    );
}

/* ------------------------------------------------------------------ */
/* copy -- copy a native file into a DECB disk image                   */
/* ------------------------------------------------------------------ */

EMSCRIPTEN_KEEPALIVE
int ts_copy(const char *srcpath, const char *dstpathlist,
            int file_type, int data_type)
{
    /*
     * srcpath:     native path in virtual FS, e.g. "/in.bin"
     * dstpathlist: DECB pathlist, e.g. "/disk.dsk,HELLO.BIN:0"
     * file_type:   0=BASIC, 1=BASIC data, 2=ML program, 3=text
     * data_type:   0=binary, 0xFF=ASCII
     */

    char *argv[] = {
        "decb",
        "-2",           /* file type ML program */
        "-b",           /* binary data type */
        (char *)srcpath,
        (char *)dstpathlist,
        NULL
    };

    /* Build argv based on file_type and data_type */
    char ft_arg[4] = {'-', '0' + (file_type >= 0 ? file_type : 2), '\0'};
    char dt_arg[3] = {'-', data_type == 0xFF ? 'a' : 'b', '\0'};

    char *argv2[6];
    int argc = 0;
    argv2[argc++] = "decb";
    argv2[argc++] = ft_arg;
    argv2[argc++] = dt_arg;
    argv2[argc++] = (char *)srcpath;
    argv2[argc++] = (char *)dstpathlist;
    argv2[argc] = NULL;

    extern int decbcopy(int argc, char **argv);
    return decbcopy(argc, argv2);
}

/* ------------------------------------------------------------------ */
/* dir -- list directory of a DECB disk image                          */
/* ------------------------------------------------------------------ */

EMSCRIPTEN_KEEPALIVE
int ts_dir(const char *diskpath, const char *outpath)
{
    /*
     * Lists the directory of diskpath to a file at outpath.
     * Format: one entry per line, CSV: name,ext,type,data_type,size
     */
    decb_path_id path;
    decb_dir_entry entry;
    error_code ec;
    FILE *out;

    /* Open the disk image directory */
    char pathlist[512];
    snprintf(pathlist, sizeof(pathlist), "%s,:0", diskpath);

    ec = _decb_open(&path, pathlist, FAM_DIR | FAM_READ);
    if (ec != 0)
        return (int)ec;

    out = fopen(outpath, "w");
    if (!out) {
        _decb_close(path);
        return -1;
    }

    fprintf(out, "name,ext,type,ascii,first_granule,size\n");

    while (_decb_readdir(path, &entry) == 0) {
        /* Skip deleted (0x00) and end-of-directory (0xFF) entries */
        if (entry.filename[0] == 0x00 || entry.filename[0] == 0xFF)
            continue;

        /* Extract name (8 bytes, space padded) */
        char name[9], ext[4];
        int i;
        for (i = 7; i >= 0 && entry.filename[i] == ' '; i--);
        strncpy(name, (char *)entry.filename, i + 1);
        name[i + 1] = '\0';

        for (i = 2; i >= 0 && entry.file_extension[i] == ' '; i--);
        strncpy(ext, (char *)entry.file_extension, i + 1);
        ext[i + 1] = '\0';

        int last_sector_bytes = (entry.last_sector_size[0] << 8) |
                                 entry.last_sector_size[1];

        fprintf(out, "%s,%s,%d,%d,%d,%d\n",
                name, ext,
                entry.file_type,
                entry.ascii_flag,
                entry.first_granule,
                last_sector_bytes);
    }

    fclose(out);
    _decb_close(path);
    return 0;
}

/* ------------------------------------------------------------------ */
/* kill -- delete a file from a DECB disk image                        */
/* ------------------------------------------------------------------ */

EMSCRIPTEN_KEEPALIVE
int ts_kill(const char *pathlist)
{
    return (int)_decb_kill((char *)pathlist);
}
