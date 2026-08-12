/* xroar_version_report.c
 *
 * NOT part of XRoar's own source. A small, standalone companion program,
 * written by us, that reports the version string XRoar was built with.
 * Compiled separately from xroar.wasm itself -- this exists so the main
 * XRoar build can stay 100% pure, unmodified upstream source, while still
 * giving the page a way to query the version at runtime.
 *
 * Reads PACKAGE_TEXT from the same generated config.h produced when
 * configuring the real xroar source, so this always reports whatever
 * version that build actually was -- not a hardcoded string that could
 * drift out of sync.
 *
 * XROAR_BUILD_TAG (optional, passed via -DXROAR_BUILD_TAG=... on the
 * custom/debug-enabled build only, never on the stock build): appended
 * to the reported version using SemVer's build-metadata convention
 * (the "+something" suffix, e.g. "1.12.1+debug-exports"), so the
 * version report actually reflects reality -- a stock build genuinely
 * is stock XRoar and reports exactly "1.12.1"; a custom build has
 * real, non-upstream additions and says so, rather than both reporting
 * the identical bare version string regardless of what's actually in
 * the binary. See the discussion this was built for: reporting "1.12.1"
 * for a build with added functions isn't a rounding error, it's
 * answering the version question wrong on purpose.
 */

#include <emscripten.h>
#include "config.h"

#ifdef XROAR_BUILD_TAG
#define XROAR_STRINGIFY(s) XROAR_STRINGIFY2(s)
#define XROAR_STRINGIFY2(s) #s
#define XROAR_BUILD_TAG_SUFFIX "+" XROAR_STRINGIFY(XROAR_BUILD_TAG)
#else
#define XROAR_BUILD_TAG_SUFFIX ""
#endif

EMSCRIPTEN_KEEPALIVE
const char *xroar_version_report_get_version(void) {
	return PACKAGE_TEXT XROAR_BUILD_TAG_SUFFIX;
}

int main(void) {
	return 0;
}
