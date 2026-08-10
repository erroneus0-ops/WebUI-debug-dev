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

#include <stdio.h>
#include <stdint.h>

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

_Bool wasm_ui_prepare_machine(struct machine_config *mc);
_Bool wasm_ui_prepare_cartridge(struct cart_config *cc);

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

// Debug/monitor interface -- direct CPU register and memory access, for a
// future monitor/debugger page. Not part of upstream XRoar as of 1.11.

uint8_t wasm_read_byte(int addr);
void wasm_write_byte(int addr, int value);
uint16_t wasm_get_pc(void);
uint8_t wasm_get_cc(void);
uint8_t wasm_get_a(void);
uint8_t wasm_get_b(void);
uint16_t wasm_get_x(void);
uint16_t wasm_get_y(void);
uint16_t wasm_get_s(void);
uint8_t wasm_get_dp(void);
uint16_t wasm_get_u(void);

void wasm_set_pc(int value);
void wasm_set_cc(int value);
void wasm_set_a(int value);
void wasm_set_b(int value);
void wasm_set_dp(int value);
void wasm_set_x(int value);
void wasm_set_y(int value);
void wasm_set_u(int value);
void wasm_set_s(int value);

// Pause/resume/step. wasm_get_stop_reason(): 0 = running, 1 = breakpoint
// hit, 2 = user pause/step. wasm_get_stop_address() is only meaningful
// after a breakpoint stop (-1 otherwise).

void wasm_pause(void);
void wasm_resume(void);
int wasm_is_paused(void);
void wasm_step(void);
int wasm_get_stop_reason(void);
int wasm_get_stop_address(void);

// Plain address breakpoints. wasm_set_breakpoint() returns a slot index
// (>= 0) on success, -1 on failure (no machine yet, or table full).
// NOTE: watchpoints are intentionally not exposed here -- see the large
// comment above the debugger support block in wasm.c for why.

int wasm_set_breakpoint(int addr);
void wasm_clear_breakpoint(int addr);

#endif

#endif
