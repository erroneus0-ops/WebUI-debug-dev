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

#include "top-config.h"

// Comment this out for debugging
#define WASM_DEBUG(...)

#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <emscripten.h>

#include "array.h"
#include "sds.h"
#include "slist.h"
#include "xalloc.h"

#include "auto_kbd.h"
#include "cart.h"
#include "debug.h"
#include "events.h"
#include "fs.h"
#include "hkbd.h"
#include "joystick.h"
#include "logging.h"
#include "vo.h"
#include "machine.h"
#include "romlist.h"
#include "vdisk.h"
#include "vdrive.h"
#include "xconfig.h"
#include "xroar.h"

// Currently tied to SDL2, as we need to poll SDL events.  Refactor soon...
#include <SDL.h>
#include "sdl2/common.h"
#include "wasm/wasm.h"

#ifndef WASM_DEBUG
#define WASM_DEBUG(...) LOG_PRINT(__VA_ARGS__)
#endif

// Functions prefixed wasm_ui_ are called from UI to interact with the browser
// environment.  Other functions prefixed wasm_ are exported and called from
// the JavaScript support code.

// Flag pending downloads.  Emulator will not run while waiting for files.
static int wasm_waiting_files = 0;

// Debugger pause state, checked once per frame in wasm_ui_run() below.
static int wasm_debug_paused = 0;
static int wasm_debug_stop_reason = 0;   // 0 = running, 1 = breakpoint hit, 2 = user pause/step, 3 = watchpoint hit
static int wasm_debug_stop_address = -1; // address of last breakpoint hit, -1 if not applicable
static int wasm_debug_watchpoint_was_read = -1; // -1 = n/a, 0 = write, 1 = read -- real value from bp_check_watchpoints, not a dummy

// Whether wasm_step()/wasm_bp_hit() force a screen repaint. Defaults on
// (matches the behavior added just before this), but toggleable --
// sometimes not repainting between steps is the actually correct thing
// to want: it lets you inspect memory directly (via wasm_dump_memory
// below) to confirm writes happened exactly as expected, independent
// of whatever the display would show, rather than the display's own
// vsync-driven redraw silently doing the "confirmation" for you.
static int wasm_debug_auto_refresh = 1;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

static void *ui_wasm_new(void *cfg);
static void wasm_ui_run(void *);

struct ui_module ui_wasm_module = {
	.common = { .name = "wasm", .description = "WebAssembly SDL2 UI",
		.new = ui_wasm_new,
	},
	.joystick_module_list = sdl_js_modlist,
};

static void wasm_update_machine_menu(void *sptr);
static void wasm_update_cartridge_menu(void *sptr);
static void wasm_update_joystick_menus(void *sptr);
static void wasm_update_radio_menu_from_enum(const char *menu, struct xconfig_enum *xc_enum);

static void wasm_ui_state_notify(void *, int tag, void *smsg);

static void *ui_wasm_new(void *cfg) {
	struct ui_cfg *ui_cfg = cfg;

	struct ui_wasm_interface *uiwasm = (struct ui_wasm_interface *)ui_sdl_allocate(sizeof(*uiwasm));
	if (!uiwasm) {
		return NULL;
	}
	*uiwasm = (struct ui_wasm_interface){0};
	struct ui_sdl2_interface *uisdl2 = &uiwasm->ui_sdl2_interface;
	ui_sdl_init(uisdl2, ui_cfg);
	struct ui_interface *ui = &uisdl2->ui_interface;
	ui->run = DELEGATE_AS0(void, wasm_ui_run, uiwasm);
	ui->update_machine_menu = DELEGATE_AS0(void, wasm_update_machine_menu, uiwasm);
	ui->update_cartridge_menu = DELEGATE_AS0(void, wasm_update_cartridge_menu, uiwasm);
	ui->update_joystick_menus = DELEGATE_AS0(void, wasm_update_joystick_menus, uiwasm);

	// Register with messenger
	uiwasm->msgr_client_id = messenger_client_register();

	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_machine, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_cartridge, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_tape_input_filename, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_tape_playing, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_disk_data, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_disk_drive_info, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_hd_filename, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_fullscreen, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_cmp_fs, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_cmp_fsc, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_cmp_system, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_monochrome, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_cmp_colour_killer, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_ccr, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_picture, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_ntsc_scaling, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_tv_input, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_vdg_inverse, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_brightness, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_contrast, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_saturation, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_hue, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_gain, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));
	ui_messenger_join_group(uiwasm->msgr_client_id, ui_tag_joystick_port, MESSENGER_NOTIFY_DELEGATE(wasm_ui_state_notify, uiwasm));

	if (!sdl_vo_init(uisdl2)) {
		free(uiwasm);
		return NULL;
	}

	wasm_update_radio_menu_from_enum("cmp_fs", vo_render_fs_list);
	wasm_update_radio_menu_from_enum("cmp_fsc", vo_render_fsc_list);
	wasm_update_radio_menu_from_enum("cmp_system", vo_render_system_list);
	wasm_update_radio_menu_from_enum("ccr", vo_cmp_ccr_list);
	wasm_update_radio_menu_from_enum("picture", vo_viewport_list);
	wasm_update_radio_menu_from_enum("tv_input", machine_tv_input_list);
	wasm_update_machine_menu(uiwasm);
	wasm_update_cartridge_menu(uiwasm);
	wasm_update_joystick_menus(uiwasm);

	return uiwasm;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// Finish the initialisation started in main().  We point the browser to a
// temporary handler that waits for file transfers to complete before finishing
// initialisation.  This then transfers control to wasm_ui_run().

static struct {
	int argc;
	char **argv;
} init_info;

static void start_init(void *);
static void finish_init(void *);

void wasm_init(int argc, char **argv) {
	init_info.argc = argc;
	init_info.argv = argv;
	emscripten_set_main_loop_arg(start_init, NULL, 0, 0);
}

static void start_init(void *sptr) {
	(void)sptr;
	struct ui_interface *ui = xroar_init(init_info.argc, init_info.argv);
	emscripten_cancel_main_loop();
	if (!ui) {
		exit(EXIT_FAILURE);
	}
	emscripten_set_main_loop_arg(finish_init, ui, 0, 0);
}

static void finish_init(void *sptr) {
	struct ui_wasm_interface *uiwasm = sptr;
	struct ui_sdl2_interface *uisdl2 = &uiwasm->ui_sdl2_interface;
	struct ui_interface *ui = &uisdl2->ui_interface;

	// We'll be called by the browser repeatedly, but we don't want to do
	// anything until all file transfers have completed.
	if (wasm_waiting_files) {
		return;
	}

	// During initialisation, the UI event list is used to reschedule
	// things that failed due to needing incomplete file transfers.
	// Process it without checking against scheduled time.
	while (UI_EVENT_LIST->events) {
		event_dispatch_next(UI_EVENT_LIST);
	}

	// Running the events could lead to more waiting...
	if (wasm_waiting_files) {
		return;
	}

	// Everything done, finish up initialisation and repoint the emscripten
	// main loop to the UI's run() delegate.
	xroar_init_finish();
	EM_ASM( ui_done_initialising(); );
	emscripten_cancel_main_loop();
	emscripten_set_main_loop_arg(ui->run.func, ui->run.sptr, 0, 0);

	// Record current time so the first "real" call has a reference point.
	uiwasm->last_t = emscripten_get_now();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// The WebAssembly main "loop" - really called once per frame by the browser.
// For normal operation, we calculate elapsed time since the last frame and run
// the emulation for that long.  If we're waiting on downloads though, we just
// immediately return control to the emscripten environment to handle the
// asynchronous messaging until everything is ready.

static void wasm_ui_run(void *sptr) {
	struct ui_wasm_interface *uiwasm = sptr;

	// Calculate time delta since last call in milliseconds.
	double t = emscripten_get_now();
	double dt = t - uiwasm->last_t;
	uiwasm->last_t = t;

	// Try and head off insane situations:
	if (dt < 0. || dt > 400.) {
		return;
	}

	// Don't run the emulator while there are pending downloads.
	if (wasm_waiting_files) {
		return;
	}

	// Poll SDL events (need to refactor this).
	run_sdl_event_loop(global_uisdl2);

	// Don't advance emulation while paused for debugging (breakpoint hit,
	// explicit pause, or mid-step-and-hold). Reset tickerr rather than
	// letting it accumulate, so resuming doesn't burst-run a backlog of
	// "missed" time in one go.
	if (wasm_debug_paused) {
		uiwasm->tickerr = 0;
		return;
	}

	// Calculate number of ticks to run based on time delta.
	uiwasm->tickerr += ((double)EVENT_TICK_RATE / 1000.) * dt;
	int nticks = (int)(uiwasm->tickerr + 0.5);
	event_ticks last_tick = event_current_tick;

	// Run emulator.
	xroar_run(nticks);

	// Record time offset based on actual number of ticks run.
	int dtick = event_current_tick - last_tick;
	uiwasm->tickerr -= (double)dtick;
}

// Wasm event handler relays information to web page handlers.

static void wasm_ui_state_notify(void *sptr, int tag, void *smsg) {
	struct ui_wasm_interface *uiwasm = sptr;
	(void)uiwasm;
	struct ui_state_message *uimsg = smsg;
	int value = uimsg->value;
	const void *data = uimsg->data;
	WASM_DEBUG("wasm_ui_state_notify(tag=%d, value=%d)\n", tag, value);

	switch (tag) {

	// Hardware

	case ui_tag_machine:
		EM_ASM_({ ui_menu_select($0, $1); }, "machine", value);
		break;

	case ui_tag_cartridge:
		EM_ASM_({ ui_menu_select($0, $1); }, "cart", value);
		break;

	// Tape

	case ui_tag_tape_input_filename:
		{
			char *fn = data ? xstrdup((const char *)data) : NULL;
			char *bn = fn ? basename(fn) : NULL;
			EM_ASM_({ ui_update_tape_input_filename($0); }, bn);
			free(fn);
		}
		break;

	case ui_tag_tape_playing:
		EM_ASM_({ ui_update_tape_playing($0); }, value);
		break;

	// Disk

	case ui_tag_disk_data:
		{
			const struct vdisk *disk = data;
			if (disk) {
				char *fn = disk->filename ? xstrdup(disk->filename) : NULL;
				char *bn = fn ? basename(fn) : NULL;
				EM_ASM_({ ui_update_disk_info($0, $1, $2, $3, $4, $5); }, value, bn, disk->write_back, disk->write_protect, disk->num_cylinders, disk->num_heads);
				free(fn);
			} else {
				EM_ASM_({ ui_update_disk_info($0, null, 0, 0, -1, 0); }, value);
			}
		}
		break;

	case ui_tag_disk_drive_info:
		{
			const struct vdrive_info *vi = data;
			unsigned d = vi->drive + 1;
			unsigned c = vi->cylinder;
			unsigned h = vi->head;
			char string[16];
			snprintf(string, sizeof(string), "Dr %01u Tr %02u He %01u", d, c, h);
			EM_ASM_({ ui_set_html($0, $1); }, "drive_info", string);
		}
		break;

	case ui_tag_hd_filename:
		{
			int hd = value;
			const char *filename = data;
			EM_ASM_({ ui_update_hd_filename($0, $1); }, hd, filename);
		}
		break;

	// Video

	case ui_tag_fullscreen:
		EM_ASM_({ ui_set_fullscreen($0); }, value);
		xroar.vo_interface->is_fullscreen = value;
		break;

	case ui_tag_cmp_fs:
		EM_ASM_({ ui_menu_select($0, $1); }, "cmp_fs", value);
		break;

	case ui_tag_cmp_fsc:
		EM_ASM_({ ui_menu_select($0, $1); }, "cmp_fsc", value);
		break;

	case ui_tag_cmp_system:
		EM_ASM_({ ui_menu_select($0, $1); }, "cmp_system", value);
		break;

	case ui_tag_monochrome:
		EM_ASM_({ ui_set_checkbox($0, $1); }, "monochrome", value);
		break;

	case ui_tag_cmp_colour_killer:
		EM_ASM_({ ui_set_checkbox($0, $1); }, "cmp_colour_killer", value);
		break;

	case ui_tag_ccr:
		EM_ASM_({ ui_menu_select($0, $1); }, "ccr", value);
		break;

	case ui_tag_picture:
		EM_ASM_({ ui_menu_select($0, $1); }, "picture", value);
		break;

	case ui_tag_ntsc_scaling:
		EM_ASM_({ ui_set_checkbox($0, $1); }, "ntsc_scaling", value);
		break;

	case ui_tag_tv_input:
		EM_ASM_({ ui_menu_select($0, $1); }, "tv_input", value);
		break;

	case ui_tag_vdg_inverse:
		EM_ASM_({ ui_set_checkbox($0, $1); }, "vdg_inverse", value);
		break;

	case ui_tag_brightness:
		EM_ASM_({ ui_set_value($0, $1); }, "brightness", value);
		break;

	case ui_tag_contrast:
		EM_ASM_({ ui_set_value($0, $1); }, "contrast", value);
		break;

	case ui_tag_saturation:
		EM_ASM_({ ui_set_value($0, $1); }, "saturation", value);
		break;

	case ui_tag_hue:
		EM_ASM_({ ui_set_value($0, $1); }, "hue", value);
		break;

	case ui_tag_gain:
		EM_ASM_({ ui_set_value($0, $1); }, "gain", *(float *)data);
		break;

	// Joysticks

	case ui_tag_joystick_port:
		if (value == 0) {
			EM_ASM_({ ui_menu_select($0, $1); }, "right-joystick", (intptr_t)data);
		} else if (value == 1) {
			EM_ASM_({ ui_menu_select($0, $1); }, "left-joystick", (intptr_t)data);
		}
		break;

	default:
		break;
	}
}

static void wasm_update_machine_menu(void *sptr) {
	struct ui_wasm_interface *uiwasm = sptr;
	(void)uiwasm;

	// Get list of machine configs
	struct slist *mcl = machine_config_list();
	// Note: this list is not a copy, so does not need freeing

	// Remove old entries
	EM_ASM_({ ui_menu_clear($0); }, "machine");

	// Add new entries
	for (struct slist *iter = mcl; iter; iter = iter->next) {
		struct machine_config *mc = iter->data;
		EM_ASM_({ ui_menu_add($0, $1, $2); }, "machine", mc->description, mc->id);
	}
	if (xroar.machine_config) {
		EM_ASM_({ ui_menu_select($0, $1); }, "machine", xroar.machine_config->id);
	}
}

static void wasm_update_cartridge_menu(void *sptr) {
	struct ui_wasm_interface *uiwasm = sptr;
	(void)uiwasm;

	// Get list of cart configs
	struct slist *ccl = NULL;
	if (xroar.machine) {
		const struct machine_partdb_entry *mpe = (const struct machine_partdb_entry *)xroar.machine->part.partdb;
		const char *cart_arch = mpe->cart_arch;
		ccl = cart_config_list_is_a(cart_arch);
	}

	// Remove old entries
	EM_ASM_({ ui_menu_clear($0); }, "cart");

	// Add new entries
	EM_ASM_({ ui_menu_add($0, $1, $2); }, "cart", "None", 0);
	for (struct slist *iter = ccl; iter; iter = iter->next) {
		struct cart_config *cc = iter->data;
		EM_ASM_({ ui_menu_add($0, $1, $2); }, "cart", cc->description, cc->id);
	}
	slist_free(ccl);
}

static void wasm_update_joystick_menus(void *sptr) {
	struct ui_wasm_interface *uiwasm = sptr;
	(void)uiwasm;

	// Get list of joystick configs
	struct slist *jcl = joystick_config_list();
	// Note: this list is not a copy, so does not need freeing

	// Remove old entries
	EM_ASM_({ ui_menu_clear($0); }, "right-joystick");
	EM_ASM_({ ui_menu_clear($0); }, "left-joystick");

	// Add new entries
	EM_ASM_({ ui_menu_add($0, $1, $2); }, "right-joystick", "None", 0);
	EM_ASM_({ ui_menu_add($0, $1, $2); }, "left-joystick", "None", 0);
	for (struct slist *iter = jcl; iter; iter = iter->next) {
		struct joystick_config *jc = iter->data;
		EM_ASM_({ ui_menu_add($0, $1, $2); }, "right-joystick", jc->description, jc->id);
		EM_ASM_({ ui_menu_add($0, $1, $2); }, "left-joystick", jc->description, jc->id);
	}
}

static void wasm_update_radio_menu_from_enum(const char *menu, struct xconfig_enum *xc_enum) {
	// Remove old entries
	EM_ASM_({ ui_menu_clear($0); }, menu);

	// Add new entries
	while (xc_enum->name) {
		if (!xc_enum->description) {
			++xc_enum;
			continue;
		}
		const char *label = xc_enum->description;
		int value = xc_enum->value;
		EM_ASM_({ ui_menu_add($0, $1, $2); }, menu, label, value);
		++xc_enum;
	}
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

static int mkdir_recursive(const char *pathname) {
	// Ensure the destination directory exists.  Fine for MEMFS in the
	// sandbox, just don't use this anywhere important, I've barely given
	// it more than a few seconds of thought.
	if (!pathname) {
		return -1;
	}
	char *path = xstrdup(pathname);
	char *dir = path;
	for (char *x = dir; *x; ) {
		while (*x == '/')
			++x;
		while (*x && *x != '/')
			++x;
		char old = *x;
		*x = 0;
		// Skip attempt to create if already exists as directory
		struct stat statbuf;
		if (stat(dir, &statbuf) == 0) {
			if (statbuf.st_mode & S_IFDIR) {
				*x = old;
				continue;
			}
		}
		// Anything we still can't deal with is a hard fail
		if (mkdir(dir, 0700) == -1) {
			free(path);
			return -1;
		}
		*x = old;
	}
	free(path);
	return 0;
}

static sds rehomed_path(const char *root, const char *file) {
	char *dirc = xstrdup(file);
	char *basec = xstrdup(file);
	char *dir = dirname(dirc);
	char *base = basename(basec);

	sds newfile = sdsnew(root);
	newfile = sdscat(newfile, "/");
	newfile = sdscat(newfile, dir);

	// Ensure rehomed directory exists
	if (mkdir_recursive(newfile) < 0) {
		sdsfree(newfile);
		free(basec);
		free(dirc);
		return NULL;
	}

	newfile = sdscat(newfile, "/");
	newfile = sdscat(newfile, base);
	free(basec);
	free(dirc);
	return newfile;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// Called from xroar_ui_set_machine() once everything is ready.  This bodges
// around the fact that switching to RGB while a CoCo 3 is not selected won't
// "take" (coco3.c overrides the value).

static int want_tv_input = -1;

void wasm_reset_tv_input(void) {
	if (want_tv_input >= 0) {
		ui_update_state(-1, ui_tag_tv_input, want_tv_input, NULL);
		want_tv_input = -1;
	}
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// File fetching.  Locks files to prevent multiple attempts to fetch the same
// file.  This half-baked approach to file locking is probably fine for our
// purposes.  It seems to work :)

static bool lock_fetch(const char *file) {
	WASM_DEBUG("lock_fetch(%s)\n", file);
	sds lockfile = rehomed_path("/.lock", file);
	int fd = open(lockfile, O_CREAT|O_EXCL|O_WRONLY, 0666);
	sdsfree(lockfile);
	if (fd == -1) {
		return 0;
	}
	close(fd);
	wasm_waiting_files++;
	WASM_DEBUG("lock_fetch(): %d waiting files\n", wasm_waiting_files);
	return 1;
}

static void unlock_fetch(const char *file) {
	WASM_DEBUG("unlock_fetch(%s)\n", file);
	sds lockfile = rehomed_path("/.lock", file);
	int fd = open(lockfile, O_RDONLY);
	if (fd == -1) {
		WASM_DEBUG("unlock_fetch() failed: invalid fd\n");
		perror(NULL);
		sdsfree(lockfile);
		return;
	}
	close(fd);
	unlink(lockfile);
	sdsfree(lockfile);
	wasm_waiting_files--;
	WASM_DEBUG("unlock_fetch(): %d waiting files remaining\n", wasm_waiting_files);
}

static void wasm_onload(const char *file) {
	WASM_DEBUG("wasm_onload(%s)\n", file);
	unlock_fetch(file);
}

static void wasm_onerror(const char *file) {
	LOG_WARN("Error fetching '%s'\n", file);
	unlock_fetch(file);
	// Create failure tracking file
	sds failfile = rehomed_path("/.fail", file);
	if (failfile) {
		FILE *fd;
		if ((fd = fopen(failfile, "w"))) {
			WASM_DEBUG("wasm_onerror(): created: %s\n", failfile);
			fclose(fd);
		}
	}
	sdsfree(failfile);
}

// Fetch a file.  Locks the file to prevent simultaneous fetch attempts.  Won't
// re-fetch the same file (whether or not it succeeded).

void wasm_wget(const char *file) {
	if (!file || *file == 0) {
		WASM_DEBUG("wasm_wget: NULL: ignoring\n");
		return;
	}

	if (!lock_fetch(file)) {
		// Couldn't lock file - either it's already being downloaded,
		// or there was an error.  Either way, just bail.
		WASM_DEBUG("wasm_wget: %s: file locked\n", file);
		return;
	}

	sds failfile = rehomed_path("/.fail", file);
	if (!failfile) {
		LOG_ERROR("wasm_wget: %s: failed to create fail tracking\n", file);
		unlock_fetch(file);
		return;
	}

	FILE *fd;
	if ((fd = fopen(failfile, "r"))) {
		WASM_DEBUG("wasm_wget: %s: not re-attempting failed download\n", file);
		fclose(fd);
		sdsfree(failfile);
		unlock_fetch(file);
		return;
	}
	sdsfree(failfile);

	// Ensure the destination directory exists.  Fine for MEMFS in the
	// sandbox, just don't use this anywhere important, I've barely given
	// it more than a few seconds of thought.
	char *dirc = xstrdup(file);
	char *dir = dirname(dirc);
	if (mkdir_recursive(dir) < 0) {
		WASM_DEBUG("wasm_wget: %s: failed to create destination dir: %s\n", file, dir);
		perror(dir);
		free(dirc);
		unlock_fetch(file);
		return;
	}
	free(dirc);

	if ((fd = fopen(file, "rb"))) {
		// File already exists - no need to fetch, so unlock
		// and return.
		WASM_DEBUG("wasm_wget: %s: not re-downloading\n", file);
		fclose(fd);
		unlock_fetch(file);
		return;
	}

	// Submit fetch.  Callbacks will unlock the fetch when done.  The more
	// full-featured Emscripten wget function would allow us to display
	// progress bars, etc., but nothing we'll ever fetch is really large
	// enough to justify that.
	WASM_DEBUG("wasm_wget: %s: submitting call to emscripten_async_wget\n", file);
	emscripten_async_wget(file, file, wasm_onload, wasm_onerror);
}

// Lookup ROM in romlist before trying to fetch it.

static void wasm_wget_rom(const char *rom) {
	WASM_DEBUG("wasm_wget_rom(%s)\n", rom);
	char *tmp;
	if ((tmp = romlist_find(rom))) {
		wasm_wget(tmp);
	} else {
		WASM_DEBUG("wasm_wget_rom(%s): not found\n", rom);
	}
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// Try to ensure all ROM images required for a machine or cartridge are
// available.  Returns true if all ROMs are present, or at least a download has
// been attempted.  If any weren't already downloaded, submits wasm_wget()
// requests and returns false.

bool wasm_ui_prepare_machine(struct machine_config *mc) {
	if (!mc) {
		return 1;
	}
	WASM_DEBUG("wasm_ui_prepare_machine(%s)\n", mc->name);
	if (mc->bas_rom) {
		wasm_wget_rom(mc->bas_rom);
	}
	if (mc->extbas_rom) {
		wasm_wget_rom(mc->extbas_rom);
	}
	if (mc->altbas_rom) {
		wasm_wget_rom(mc->altbas_rom);
	}
	if (mc->ext_charset_rom) {
		wasm_wget_rom(mc->ext_charset_rom);
	}
	if (wasm_waiting_files == 0) {
		return 1;
	}
	return 0;
}

bool wasm_ui_prepare_cartridge(struct cart_config *cc) {
	if (!cc) {
		return 1;
	}
	WASM_DEBUG("wasm_ui_prepare_cartridge(%s)\n", cc->name);
	if (cc->rom) {
		wasm_wget_rom(cc->rom);
	}
	if (cc->rom2) {
		wasm_wget_rom(cc->rom2);
	}
	if (wasm_waiting_files == 0) {
		return 1;
	}
	return 0;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// Queue simple value-only message as an event

struct wasm_message_value {
	int tag;
	int value;
};

static void do_message_value_event(void *sptr) {
	struct wasm_message_value *mv = sptr;
	int tag = mv->tag;
	int value = mv->value;
	free(mv);
	ui_update_state(-1, tag, value, NULL);
}

void wasm_queue_message_value_event(int tag, int value) {
	struct wasm_message_value *mv = xmalloc(sizeof(*mv));
	mv->tag = tag;
	mv->value = value;
	event_queue_auto(UI_EVENT_LIST, DELEGATE_AS0(void, do_message_value_event, mv), 1);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// UI message wrappers

const struct {
	const char *tag_name;
	int tag;
} name_to_tag[] = {
	{ "machine", ui_tag_machine },
	{ "cartridge", ui_tag_cartridge },
	{ "tape_playing", ui_tag_tape_playing },
	{ "cmp_fs", ui_tag_cmp_fs },
	{ "cmp_fsc", ui_tag_cmp_fsc },
	{ "cmp_system", ui_tag_cmp_system },
	{ "monochrome", ui_tag_monochrome },
	{ "cmp_colour_killer", ui_tag_cmp_colour_killer },
	{ "ccr", ui_tag_ccr },
	{ "picture", ui_tag_picture },
	{ "ntsc_scaling", ui_tag_ntsc_scaling },
	{ "tv_input", ui_tag_tv_input },
	{ "fullscreen", ui_tag_fullscreen },
	{ "vdg_inverse", ui_tag_vdg_inverse },
	{ "brightness", ui_tag_brightness },
	{ "contrast", ui_tag_contrast },
	{ "saturation", ui_tag_saturation },
	{ "hue", ui_tag_hue },
	{ "gain", ui_tag_gain },
};

static int ui_tag_from_name(const char *tag_name) {
	if (!tag_name) {
		return -1;
	}
	for (size_t i = 0; i < ARRAY_N_ELEMENTS(name_to_tag); ++i) {
		if (0 == strcmp(tag_name, name_to_tag[i].tag_name)) {
			return name_to_tag[i].tag;
		}
	}
	return -1;
}

void wasm_set_int(const char *tag_name, int value) {
	int tag = ui_tag_from_name(tag_name);
	if (tag < 0) {
		return;
	}
	if (tag == ui_tag_tv_input) {
		want_tv_input = value;
	}
	ui_update_state(-1, tag, value, NULL);
}

void wasm_set_float(const char *tag_name, float value) {
	int tag = ui_tag_from_name(tag_name);
	if (tag < 0) {
		return;
	}
	ui_update_state(-1, tag, 0, &value);
}

void wasm_set_joystick_port(int port, int value) {
	ui_update_state(-1, ui_tag_joystick_port, port, (void *)(intptr_t)value);
}

void wasm_set_joystick_by_name(int port, const char *name) {
	struct joystick_config *jc = joystick_config_by_name(name);
	wasm_set_joystick_port(port, jc ? jc->id : 0);
}

void wasm_gamepad_connected(int index) {
	SDL_Event event;
	event.cdevice.type = SDL_CONTROLLERDEVICEADDED;
	event.cdevice.which = index;
	SDL_PushEvent(&event);
}

void wasm_gamepad_disconnected(int index) {
	SDL_Event event;
	event.cdevice.type = SDL_CONTROLLERDEVICEREMOVED;
	event.cdevice.which = index;
	SDL_PushEvent(&event);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// Helper while loading software from the browser - prepare a specific machine
// with a specific default cartridge.

void wasm_set_machine_cart(const char *machine, const char *cart,
			   const char *cart_rom, const char *cart_rom2) {
	WASM_DEBUG("wasm_set_machine_cart(%s, %s, %s, %s)\n", machine, cart ? cart : "[none]", cart_rom ? cart_rom : "[none]", cart_rom2 ? cart_rom2 : "[none]");
	struct machine_config *mc = machine_config_by_name(machine);
	ui_update_state(-1, ui_tag_machine, mc ? mc->id : 0, NULL);
	struct cart_config *cc = cart_config_by_name(cart);
	if (cc) {
		if (cart_rom) {
			free(cc->rom);
			cc->rom = NULL;
			cc->rom = xstrdup(cart_rom);
		}
		free(cc->rom2);
		cc->rom2 = NULL;
		if (cart_rom2) {
			cc->rom2 = xstrdup(cart_rom2);
		}
	}
	ui_update_state(-1, ui_tag_cartridge, cc ? cc->id : 0, NULL);
	xroar_hard_reset();
	return;
}

// Load (and optionally autorun) file from web

enum wasm_load_file_type {
	wasm_load_file_type_load = 0,
	wasm_load_file_type_run = 1,
	wasm_load_file_type_tape = 2,
	wasm_load_file_type_disk = 3,
	wasm_load_file_type_text = 4,
	wasm_load_file_type_hd = 5,
};

struct wasm_event_load_file {
	char *filename;
	enum wasm_load_file_type type;
	int drive;
};

static void do_wasm_load_file(void *sptr) {
	struct wasm_event_load_file *ev = sptr;
	WASM_DEBUG("do_wasm_load_file(type=%d, file=%s)\n", ev->type, ev->filename);
	switch (ev->type) {
	case wasm_load_file_type_load:
	case wasm_load_file_type_run:
		xroar_load_file_by_type(ev->filename, ev->type);
		break;
	case wasm_load_file_type_tape:
		xroar_insert_input_tape_file(ev->filename);
		break;
	case wasm_load_file_type_disk:
		xroar_insert_disk_file(ev->drive, ev->filename);
		break;
	case wasm_load_file_type_text:
		ak_type_file(xroar.auto_kbd, ev->filename);
		ak_parse_type_string(xroar.auto_kbd, "\\r");
		break;
	case wasm_load_file_type_hd:
		xroar_insert_hd_file(ev->drive, ev->filename);
		break;
	}
	free(ev->filename);
	free(ev);
}

void wasm_load_file(const char *filename, int type, int drive) {
	WASM_DEBUG("wasm_load_file(filename=%s, type=%d, drive=%d)\n", filename, type, drive);
	struct wasm_event_load_file *ev = xmalloc(sizeof(*ev));
	ev->filename = xstrdup(filename);
	ev->type = type;
	ev->drive = drive;
	wasm_wget(filename);
	event_queue_auto(UI_EVENT_LIST, DELEGATE_AS0(void, do_wasm_load_file, ev), 1);
}

// Submit BASIC commands

static void do_wasm_queue_basic(void *sptr) {
	char *text = sptr;
	WASM_DEBUG("do_wasm_queue_basic(%s)\n", text);
	ak_parse_type_string(xroar.auto_kbd, text);
	free(text);
}

void wasm_queue_basic(const char *string) {
	char *text = xstrdup(string);
	WASM_DEBUG("wasm_queue_basic(%s): queueing do_wasm_queue_basic()\n", string);
	event_queue_auto(UI_EVENT_LIST, DELEGATE_AS0(void, do_wasm_queue_basic, text), 1);
}

// Keyboard interface

void wasm_scan_press(int code) {
	hk_scan_press(code);
}

void wasm_scan_release(int code) {
	hk_scan_release(code);
}

// Update window size.  Browser handles knowing what size things should be,
// then informs us here.

void wasm_resize(int w, int h) {
	WASM_DEBUG("wasm_resize(%d, %d)\n", w, h);
	if (global_uisdl2 && global_uisdl2->vo_window) {
		SDL_SetWindowSize(global_uisdl2->vo_window, w, h);
	}
}

// Insert new disk in drive, only if one is not present!

void wasm_new_disk(int drive) {
	if (drive < 0 || drive > 3) {
		return;
	}
	if (vdrive_disk_in_drive(xroar.vdrive_interface, drive)) {
		return;
	}
	struct vdisk *new_disk = vdisk_new(VDISK_TRACK_LENGTH_DD300);
	if (new_disk) {
		char name[12];
		snprintf(name, sizeof(name), "drive%d.dmk", drive);
		new_disk->filetype = FILETYPE_DMK;
		new_disk->filename = xstrdup(name);
		new_disk->write_back = 1;
		new_disk->new_disk = 1;
		new_disk->dirty = 1;
		vdrive_insert_disk(xroar.vdrive_interface, drive, new_disk);
		ui_update_state(-1, ui_tag_disk_data, drive, new_disk);
		ui_update_state(-1, ui_tag_disk_write_enable, 1, (void *)(intptr_t)drive);
		ui_update_state(-1, ui_tag_disk_write_back, 1, (void *)(intptr_t)drive);
		vdisk_unref(new_disk);
	}
}

// Flush changes to disk images (before offering up to download)

void wasm_vdrive_flush(void) {
	vdrive_flush(xroar.vdrive_interface);
}

// Direct memory read/write, ported from the original pre-debugger-work
// wasm_read_byte()/wasm_write_byte() (still present, unmodified, in the
// now-retired 1.11-based emcc_workflow/xroar/ tree). Confirmed directly
// against gdb.c: machine->read_byte()/write_byte() is the exact same
// function XRoar's own GDB target calls for memory packets ('m'/'M') --
// not a parallel mechanism, the same one.

uint8_t wasm_read_byte(int addr) {
	if (!xroar.machine) return 0;
	return xroar.machine->read_byte(xroar.machine, addr & 0xffff, 0);
}

void wasm_write_byte(int addr, int value) {
	if (!xroar.machine) return;
	xroar.machine->write_byte(xroar.machine, addr & 0xffff, value & 0xff);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Debugger support: pause/resume/step, generic register read+write via
// 1.12.1's new debug_target framework, and plain address breakpoints via
// the new machine->debug.add_breakpoint()/remove_breakpoint() API.
//
// Registers are NOT exposed as one hand-written wasm_get_x()/wasm_set_x()
// pair per register (that was the 1.11-era approach). 1.12.1 introduced
// debug.c/debug.h: a generic, name-and-index-addressable register table
// (see mc6809.c's feature_regs[]) that both this code and XRoar's own GDB
// target read from. Duplicating that table here as a second, hand-written
// copy is exactly the "second parser waiting to disagree with the first
// one" problem -- so this wraps debug_get_register()/debug_set_register()/
// debug_register_by_name() generically instead. It automatically covers
// every register Ciaran has defined (currently cc, a, b, dp, x, y, u, s,
// pc for the 6809 core -- confirmed directly in mc6809.c), and picks up
// anything he adds later without this file needing to change.
//
// Pause: a plain flag checked once per frame in wasm_ui_run() above,
// gating the call to xroar_run(). Not built on gdb.c's pthread-condvar
// pause model -- that needs WANT_GDB_TARGET (pthreads), which this WASM
// build doesn't enable, and blocking the browser's one JS thread on a
// condvar would freeze the tab rather than pause the emulator anyway.
//
// Step: calls the existing machine->single_step(), the same primitive
// XRoar's own GDB target uses per single-step request. Runs exactly one
// instruction and returns; doesn't touch cpu->halt, so it's safe
// regardless of the pause flag.
//
// Breakpoints: machine->debug.add_breakpoint()/remove_breakpoint() are
// unconditionally compiled (confirmed directly in coco3.c -- no
// WANT_GDB_TARGET guard on these two, unlike watchpoints below).
//
// Watchpoints: an earlier pass through this session concluded they
// weren't usable, because bp_check_watchpoints()'s call site in
// coco3.c's cpu_cycle() is wrapped in #ifdef WANT_GDB_TARGET. That
// was checking the wrong file for this build's actual machine type --
// the boot log says "[part:coco]", not "[part:coco3]", meaning this
// build actually runs dragon.c's cpu_cycle() (coco.c is a thin
// wrapper reusing it), where the equivalent call is completely
// unconditional: "bp_check_watchpoints(&md->watchpoint_set, RnW, A);"
// with no #ifdef around it at all, confirmed directly. Already running
// every cycle in this build -- see wasm_set_watchpoint()/
// wasm_clear_watchpoint() below, which expose it with no source patch
// needed.

// Look up a register's index by name ("pc", "cc", "a", "b", "dp", "x",
// "y", "u", "s", or anything else Ciaran's debug_target defines). Returns
// -1 if not found or no machine/target yet.

int wasm_register_by_name(const char *name) {
	if (!xroar.machine || !xroar.machine->debug.target || !name) {
		return -1;
	}
	return debug_register_by_name(xroar.machine->debug.target, name);
}

// Total number of registers the current machine's debug target exposes
// (CPU core plus any other parts added, e.g. GIME/PIA on the CoCo3).

int wasm_register_count(void) {
	if (!xroar.machine || !xroar.machine->debug.target) {
		return 0;
	}
	return (int)xroar.machine->debug.target->nregs;
}

// Register name by index, for JS to enumerate all available registers
// without hardcoding a name list that could drift from Ciaran's table.
// Returns an empty string (not NULL) for an out-of-range index, since
// this crosses back to JS as a 'string' return.

const char *wasm_register_name(int regno) {
	struct debug_target *target = xroar.machine ? xroar.machine->debug.target : NULL;
	if (!target || regno < 0 || (unsigned)regno >= target->nregs) {
		return "";
	}
	return target->reg[regno]->name;
}

uint32_t wasm_get_register(int regno) {
	if (!xroar.machine || !xroar.machine->debug.target) {
		return 0;
	}
	return debug_get_register(xroar.machine->debug.target, regno);
}

void wasm_set_register(int regno, uint32_t value) {
	if (!xroar.machine || !xroar.machine->debug.target) {
		return;
	}
	debug_set_register(xroar.machine->debug.target, regno, value);
}

void wasm_pause(void) {
	wasm_debug_paused = 1;
	wasm_debug_stop_reason = 2;
	wasm_debug_stop_address = -1;
}

void wasm_resume(void) {
	wasm_debug_paused = 0;
	wasm_debug_stop_reason = 0;
	wasm_debug_stop_address = -1;
}

int wasm_is_paused(void) {
	return wasm_debug_paused;
}

int wasm_get_stop_reason(void) {
	return wasm_debug_stop_reason;
}

int wasm_get_stop_address(void) {
	return wasm_debug_stop_address;
}

void wasm_set_auto_refresh(int enabled) {
	wasm_debug_auto_refresh = enabled ? 1 : 0;
}

int wasm_get_auto_refresh(void) {
	return wasm_debug_auto_refresh;
}

// Read `length` bytes of live machine memory starting at `addr` into a
// freshly malloc'd buffer, returning a pointer JS can read directly via
// Module.HEAPU8.subarray(ptr, ptr+length) -- avoids one ccall per byte
// for anything more than a trivial range, unlike looping
// wasm_read_byte() from JS. Caller must free the result via
// wasm_free_dump_buffer() once done reading it, or it leaks.
//
// This exists specifically so memory contents can be verified directly
// -- independent of whatever the display happens to show, which is
// exactly the point when auto-refresh is turned off (see
// wasm_set_auto_refresh above): confirm a write actually happened by
// reading the bytes themselves, not by trusting a screen redraw to
// have shown it.

void *wasm_dump_memory(int addr, int length) {
	if (!xroar.machine || length <= 0) {
		return NULL;
	}
	uint8_t *buf = malloc((size_t)length);
	if (!buf) {
		return NULL;
	}
	unsigned a = (unsigned)addr & 0xffff;
	for (int i = 0; i < length; i++) {
		buf[i] = xroar.machine->read_byte(xroar.machine, (a + i) & 0xffff, 0);
	}
	return buf;
}

void wasm_free_dump_buffer(void *buf) {
	free(buf);
}

// Execute exactly one instruction, then remain paused so JS can inspect
// state before deciding to step again or resume.

void wasm_step(void) {
	if (!xroar.machine || !xroar.machine->single_step) {
		return;
	}
	xroar.machine->single_step(xroar.machine);
	wasm_debug_paused = 1;
	wasm_debug_stop_reason = 2;
	wasm_debug_stop_address = -1;
	// Confirmed by real testing: without this, stepping through a
	// program that writes to screen memory character-by-character
	// showed nothing changing at all, then the whole result appeared
	// at once the moment Resume let a normal frame run. Cause,
	// confirmed by reading xroar.c directly: the canvas is normally
	// repainted only on vsync (once per emulated video frame) --
	// single_step() bypasses that whole per-frame pipeline entirely, so
	// nothing ever triggers a repaint between steps even though the
	// actual memory writes are happening correctly at each one.
	// vo_refresh() is XRoar's own existing, purpose-built answer to
	// exactly this -- its own comment in vo.h says "useful while
	// single-stepping, where the usual render functions won't be
	// called". xroar_run() already calls this itself, but only for the
	// GDB-target's stopped state (machine_run_state_stopped), which
	// this WASM build's own pause/step mechanism runs entirely outside
	// of -- so it needs calling directly here instead.
	if (wasm_debug_auto_refresh && xroar.vo_interface) {
		vo_refresh(xroar.vo_interface);
	}
}

// Breakpoint handler. The (bool, uint32) signature is shared with
// watchpoint handlers by machine.h's delegate type; for a breakpoint the
// bool is always passed as true by bp_instruction_hook() (confirmed
// directly in breakpoint.c) and carries no meaning here.

static void wasm_bp_hit(void *sptr, _Bool dummy, uint32_t addr) {
	(void)sptr;
	(void)dummy;
	// Was missing entirely -- this only ever set wasm_debug_paused,
	// which correctly blocks *future* animation frames from calling
	// xroar_run() again, but does nothing to stop the CPU's *current*,
	// already-in-progress run call for this frame's cycle budget. One
	// frame's worth of cycles is easily enough to finish a whole small
	// test program, so the breakpoint would fire and log correctly
	// every time it was reached, then execution would just continue to
	// completion within the same frame, never actually appearing to
	// pause at all -- confirmed directly: a real test hit the same
	// breakpoint 6 times in a single burst (matching a 6-character
	// loop) with no pause ever visible.
	//
	// machine->signal() is the correct, generic, machine-level primitive
	// for this -- confirmed by reading coco3_signal()'s actual
	// implementation, which does exactly cpu->running = 0 internally.
	// Using this instead of reaching into struct MC6809 directly
	// (which is what the now-abandoned 1.11-era port did) keeps this
	// consistent with everything else in this file going through the
	// machine-level generic interface rather than CPU internals.
	if (xroar.machine && xroar.machine->signal) {
		xroar.machine->signal(xroar.machine, 5);  // SIGTRAP -- conventional "stopped at a breakpoint" value, matches what gdb.c itself passes for the same situation
	}
	wasm_debug_paused = 1;
	wasm_debug_stop_reason = 1;
	wasm_debug_stop_address = (int)addr;
	// Same reasoning as wasm_step() above -- a breakpoint firing stops
	// the CPU mid-frame, before that frame's own vsync/draw ever
	// happens, so without this the screen would still show whatever it
	// last looked like before the breakpoint, not the state at the
	// moment execution actually stopped.
	if (wasm_debug_auto_refresh && xroar.vo_interface) {
		vo_refresh(xroar.vo_interface);
	}
	EM_ASM({
		if (typeof wasm_on_debug_stop === 'function') {
			wasm_on_debug_stop($0, $1);
		}
	}, wasm_debug_stop_reason, (int)addr);
}

void wasm_set_breakpoint(int addr) {
	if (!xroar.machine || !xroar.machine->debug.add_breakpoint) {
		return;
	}
	xroar.machine->debug.add_breakpoint(
		xroar.machine, (uint32_t)addr & 0xffff,
		DELEGATE_AS2(void, bool, uint32, wasm_bp_hit, NULL));
}

void wasm_clear_breakpoint(int addr) {
	if (!xroar.machine || !xroar.machine->debug.remove_breakpoint) {
		return;
	}
	xroar.machine->debug.remove_breakpoint(
		xroar.machine, (int32_t)((uint32_t)addr & 0xffff),
		DELEGATE_AS2(void, bool, uint32, wasm_bp_hit, NULL));
}

// Watchpoints -- confirmed workable tonight after re-checking the
// actual machine type this WASM build uses. The earlier conclusion
// that watchpoints were blocked (bp_check_watchpoints's call site
// wrapped in #ifdef WANT_GDB_TARGET) was checking coco3.c, the wrong
// file -- this build's actual machine type ("[part:coco]" in the boot
// log, not "[part:coco3]") runs dragon.c's cpu_cycle() instead, where
// that same call is completely unconditional: "bp_check_watchpoints(
// &md->watchpoint_set, RnW, A);" with no #ifdef around it at all.
// Already running, every cycle, in the current build -- this just
// exposes what's already there, no source patch needed, unlike the
// SAM/PIA register work.
//
// Unlike breakpoints, the handler here receives a REAL, meaningful
// RnW value (confirmed directly in breakpoint.h:
// "DELEGATE_CALL(iter->handler, RnW, A);", not a dummy like
// wasm_bp_hit's second parameter) -- worth actually exposing whether
// a hit was a read or a write, not discarding it.

static void wasm_wp_hit(void *sptr, _Bool RnW, uint32_t addr) {
	(void)sptr;
	if (xroar.machine && xroar.machine->signal) {
		xroar.machine->signal(xroar.machine, 5);
	}
	wasm_debug_paused = 1;
	wasm_debug_stop_reason = 3;
	wasm_debug_stop_address = (int)addr;
	wasm_debug_watchpoint_was_read = RnW ? 1 : 0;
	if (wasm_debug_auto_refresh && xroar.vo_interface) {
		vo_refresh(xroar.vo_interface);
	}
	EM_ASM({
		if (typeof wasm_on_debug_stop === 'function') {
			wasm_on_debug_stop($0, $1);
		}
	}, wasm_debug_stop_reason, (int)addr);
}

int wasm_get_watchpoint_was_read(void) {
	return wasm_debug_watchpoint_was_read;
}

// Watchpoints are stored in two separate lists internally, one for
// reads and one for writes (confirmed in breakpoint.h:
// "set->list[RnW]") -- watching both directions on the same range
// genuinely means registering twice, not a single call with a
// combined flag. watch_reads/watch_writes are independent 0/1 flags
// for exactly that reason, not an enum.

void wasm_set_watchpoint(int addr_start, int addr_end, int watch_reads, int watch_writes) {
	if (!xroar.machine || !xroar.machine->debug.add_watchpoint) {
		return;
	}
	uint32_t as = (uint32_t)addr_start & 0xffff;
	uint32_t ae = (uint32_t)addr_end & 0xffff;
	if (watch_reads) {
		xroar.machine->debug.add_watchpoint(
			xroar.machine, 1, as, ae,
			DELEGATE_AS2(void, bool, uint32, wasm_wp_hit, NULL));
	}
	if (watch_writes) {
		xroar.machine->debug.add_watchpoint(
			xroar.machine, 0, as, ae,
			DELEGATE_AS2(void, bool, uint32, wasm_wp_hit, NULL));
	}
}

void wasm_clear_watchpoint(int addr_start, int addr_end, int watch_reads, int watch_writes) {
	if (!xroar.machine || !xroar.machine->debug.remove_watchpoint) {
		return;
	}
	int32_t as = (int32_t)((uint32_t)addr_start & 0xffff);
	uint32_t ae = (uint32_t)addr_end & 0xffff;
	if (watch_reads) {
		xroar.machine->debug.remove_watchpoint(
			xroar.machine, 1, as, ae,
			DELEGATE_AS2(void, bool, uint32, wasm_wp_hit, NULL));
	}
	if (watch_writes) {
		xroar.machine->debug.remove_watchpoint(
			xroar.machine, 0, as, ae,
			DELEGATE_AS2(void, bool, uint32, wasm_wp_hit, NULL));
	}
}

// See the comment above the declaration in wasm.h. -1 if no machine
// is currently configured at all, matching the defensive-check
// pattern already used throughout this file rather than assuming
// xroar.machine/->config are always non-NULL.
int wasm_get_tv_standard(void) {
	if (!xroar.machine || !xroar.machine->config) {
		return -1;
	}
	return xroar.machine->config->tv_standard;
}
