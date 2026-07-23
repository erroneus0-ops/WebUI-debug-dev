/*
 * native_stubs.c -- stub implementations for libnativegs/libnativess functions
 *
 * libnativegs.c and libnativess.c use path->fd->_fileno which is a glibc
 * internal not available in Emscripten libc. These stubs satisfy the linker.
 *
 * In our WASM build all paths are virtual filesystem paths -- native_gs/ss
 * functions are never called in practice. They return EOS_UNKSVC (unknown
 * service) to signal "not supported" if somehow reached.
 */

#include <sys/stat.h>
#include "nativepath.h"
#include "cocotypes.h"

#define EOS_UNKSVC 0x103  /* unknown service request */

error_code _native_gs_attr(native_path_id path, int *perms)
    { return EOS_UNKSVC; }

error_code _native_gs_eof(native_path_id path)
    { return EOS_UNKSVC; }

error_code _native_gs_fd(native_path_id path, struct stat *statbuf)
    { return EOS_UNKSVC; }

error_code _native_gs_fd_pathlist(char *pathlist, struct stat *statbuf)
    { return EOS_UNKSVC; }

error_code _native_gs_size(native_path_id path, u_int *size)
    { return EOS_UNKSVC; }

error_code _native_gs_size_pathlist(char *pathlist, u_int *size)
    { return EOS_UNKSVC; }

error_code _native_gs_pos(native_path_id path, u_int *pos)
    { return EOS_UNKSVC; }

error_code _native_ss_attr(native_path_id path, int perms)
    { return EOS_UNKSVC; }

error_code _native_ss_fd(native_path_id path, struct stat *statbuf)
    { return EOS_UNKSVC; }

error_code _native_ss_size(native_path_id path, int size)
    { return EOS_UNKSVC; }

/* _decb_srec_encode/_decb_srec_decode -- from libdecbsrec.c which uses
   digittoint (BSD extension not in Emscripten libc).
   S-record encode/decode used by cecb copy -s/-f flags.
   Stubs return error -- S-record conversion not supported in WASM. */
#include "cocotypes.h"

error_code _decb_srec_encode(unsigned char *in_buffer, int in_size,
                              char **out_buffer, u_int *out_size)
    { return -1; }

error_code _decb_srec_decode(unsigned char *in_buffer, int in_size,
                              unsigned char **out_buffer, u_int *out_size)
    { return -1; }
