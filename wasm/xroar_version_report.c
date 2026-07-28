/* xroar_version_report.c
 *
 * NOT part of XRoar's own source. A small, standalone companion program,
 * written by us, that reports the version string XRoar was built with.
 * Compiled separately from xroar.wasm itself -- this exists so the main
 * XRoar build can stay 100% pure, unmodified upstream source, while still
 * giving the page a way to query the version at runtime.
 *
 * Reads PACKAGE_TEXT from the same generated config.h produced when
 * configuring the real xroar-1.12.1 source, so this always reports
 * whatever version that build actually was -- not a hardcoded string
 * that could drift out of sync.
 */

#include <emscripten.h>
#include "config.h"

EMSCRIPTEN_KEEPALIVE
const char *xroar_version_report_get_version(void) {
	return PACKAGE_TEXT;
}

int main(void) {
	return 0;
}
