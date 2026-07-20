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
/* Uses _decb_* functions directly to avoid libcoco dependency          */
/* ------------------------------------------------------------------ */

EMSCRIPTEN_KEEPALIVE
int ts_copy(const char *srcpath, const char *dstpathlist,
            int file_type, int data_type)
{
    /*
     * srcpath:     native path in virtual FS, e.g. "/in.bin"
     * dstpathlist: DECB pathlist, e.g. "/disk.dsk,HELLO.BIN:0"
     * file_type:   0=BASIC, 1=BASIC data, 2=ML program, 3=text
     * data_type:   0=binary, 0xFF=ASCII (-1 = auto-detect from content)
     */

    FILE *src;
    decb_path_id dst;
    error_code ec;
    unsigned char *buffer;
    long file_size;
    u_int write_size;

    /* Read source file into buffer */
    src = fopen(srcpath, "rb");
    if (!src) return -1;

    fseek(src, 0, SEEK_END);
    file_size = ftell(src);
    fseek(src, 0, SEEK_SET);

    if (file_size <= 0) { fclose(src); return -1; }

    buffer = (unsigned char *)malloc(file_size);
    if (!buffer) { fclose(src); return -1; }

    if (fread(buffer, 1, file_size, src) != (size_t)file_size) {
        free(buffer); fclose(src); return -1;
    }
    fclose(src);

    /* Auto-detect file type from DECB binary header if not specified */
    if (file_type < 0) file_type = 2;  /* default: ML program */
    if (data_type < 0) data_type = 0;  /* default: binary */

    /* Create new file on DECB disk image */
    ec = _decb_create(&dst, (char *)dstpathlist,
                      FAM_WRITE,
                      file_type >= 0 ? file_type : 2,
                      data_type >= 0 ? data_type : 0);
    if (ec != 0) { free(buffer); return (int)ec; }

    /* Write data */
    write_size = (u_int)file_size;
    ec = _decb_write(dst, buffer, &write_size);
    free(buffer);

    if (ec == 0) {
        /* Set file type and data type */
        decb_file_stat fstat;
        _decb_gs_fd(dst, &fstat);
        fstat.file_type = (u_char)file_type;
        fstat.data_type = (u_char)data_type;
        _decb_ss_fd(dst, &fstat);
    }

    _decb_close(dst);
    return (int)ec;
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
