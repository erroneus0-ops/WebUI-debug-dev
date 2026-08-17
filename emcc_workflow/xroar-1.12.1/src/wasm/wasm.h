/** \file
 *
 *  \brief WebAssembly (emscripten) support.
 *
 *  \copyright Copyright 2019-2025 Ciaran Anscomb
 *
 *  \licenseblock This file is part of XRoar, a Dragon/Tandy CoCo emulator.
 *
 *  XRoar is free software; you can redistribute it and/or modify it under the
 *  terms of the GNU General Public License as published by the Free Software
 *  Foundation, either version 3 of the License, or (at your option) any later
 *  version.
 *
 *  See COPYING.GPL for redistribution conditions.
 *
 *  \endlicenseblock
 */

#ifdef HAVE_WASM

#ifndef XROAR_WASM_H_
#define XROAR_WASM_H_

#include <stdint.h>
#include <stdio.h>

#include "sdl2/common.h"

struct machine_config;
struct cart_config;

struct ui_wasm_interface {
	struct ui_sdl2_interface ui_sdl2_interface;

	// Top level messenger client id
	int msgr_client_id;

	double last_t;
	double tickerr;
};

// Initialisation - called by main().

void wasm_init(int argc, char **argv);

// Create virtual joystick.

void wasm_js_init(void);

// Fetch a file.  Locks the file to prevent simultaneous fetch attempts.  Won't
// re-fetch the same file (whether or not it succeeded).

void wasm_wget(const char *file);

// Try to ensure all ROM images required for a machine or cartridge are
// available.  Returns true if all ROMs are present, or at least a download has
// been attempted.  If any weren't already downloaded, submits wasm_wget()
// requests and returns false.

bool wasm_ui_prepare_machine(struct machine_config *mc);
bool wasm_ui_prepare_cartridge(struct cart_config *cc);

// Queue simple value-only message as an event

void wasm_queue_message_value_event(int tag, int value);

// UI message wrappers

void wasm_set_int(const char *tag_name, int value);
void wasm_set_float(const char *tag_name, float value);
void wasm_set_joystick_port(int port, int value);
void wasm_set_joystick_by_name(int port, const char *name);

void wasm_reset_tv_input(void);

// Browser interfaces to certain functions

void wasm_set_machine_cart(const char *machine, const char *cart, const char *cart_rom, const char *cart_rom2);
void wasm_load_file(const char *filename, int type, int drive);
void wasm_queue_basic(const char *string);
void wasm_resize(int w, int h);
void wasm_vdrive_flush(void);

// Direct memory read/write -- see the comment above these in wasm.c
// for why this taps the exact same mechanism GDB itself uses.
uint8_t wasm_read_byte(int addr);
void wasm_write_byte(int addr, int value);

// Debugger support -- see the large comment above these functions in
// wasm.c for the reasoning (generic register access via 1.12.1's
// debug_target framework rather than one function per register; why
// watchpoints aren't exposed yet).

int wasm_register_by_name(const char *name);
int wasm_register_count(void);
const char *wasm_register_name(int regno);
uint32_t wasm_get_register(int regno);
void wasm_set_register(int regno, uint32_t value);

void wasm_pause(void);
void wasm_resume(void);
int wasm_is_paused(void);
void wasm_step(void);
int wasm_get_stop_reason(void);
int wasm_get_stop_address(void);

void wasm_set_auto_refresh(int enabled);
int wasm_get_auto_refresh(void);
void *wasm_dump_memory(int addr, int length);
void wasm_free_dump_buffer(void *buf);

void wasm_set_breakpoint(int addr);
void wasm_clear_breakpoint(int addr);

// See the comments above these definitions in wasm.c.
int wasm_get_watchpoint_was_read(void);
void wasm_set_watchpoint(int addr_start, int addr_end, int watch_reads, int watch_writes);
void wasm_clear_watchpoint(int addr_start, int addr_end, int watch_reads, int watch_writes);

// Returns the currently-configured machine's tv_standard
// (TV_PAL=0, TV_NTSC=1, TV_PAL_M=2, per machine.h) -- this is an
// emulator-level configuration choice, not a hardware register, so
// unlike EXT/CSS/GM it can't be read via a memory-mapped address at
// all. Confirmed directly (via measuring real screenshots pixel by
// pixel) that NTSC and PAL render the active screen area at
// genuinely different heights -- 6.82% taller for NTSC, width
// unchanged -- so the character-dump tool needs this to render the
// correct proportions for whichever standard is actually running.
int wasm_get_tv_standard(void);

#endif

#endif
