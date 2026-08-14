#!/usr/bin/env python3
"""
serve_writable.py -- drop-in replacement for `python -m http.server`
that also accepts writes to a small, fixed allowlist of paths.

Everything else behaves exactly like the normal read-only static
server (same directory-serving, same GET behavior) -- this only adds
a do_POST handler, and only for the specific paths listed below.

Motivated by the snapshot/disk-persistence feature discussion: XRoar
Online currently triggers a browser "Save As" dialog to save a
snapshot (see download_snapshot() in index_custom.html). Running this
instead of the stock http.server lets that same data be POSTed
straight to a file on disk with no dialog at all.

Usage: same as the stock server --
    python3 serve_writable.py [port]
(defaults to port 8000 if not given, matching the stock module's own default)
"""

import http.server
import socketserver
import os
import sys
import urllib.parse


class WritableHandler(http.server.SimpleHTTPRequestHandler):
    # Only these paths accept writes. Everything else gets a plain 403
    # rather than silently accepting an arbitrary path -- this is a
    # personal, localhost-only dev tool, but there's no reason to skip
    # a one-line allowlist check just because the stakes are low; it
    # closes off path-traversal entirely as a category rather than
    # relying on remembering to sanitize input correctly every time
    # this list grows.
    WRITABLE_PATHS = {'/save/snapshot.sna', '/save/disk.dsk'}

    def do_POST(self):
        path = urllib.parse.unquote(self.path)
        if path not in self.WRITABLE_PATHS:
            self.send_response(403)
            self.end_headers()
            self.wfile.write(b'Not in WRITABLE_PATHS allowlist')
            return

        length = int(self.headers.get('Content-Length', 0))
        data = self.rfile.read(length)

        # path is checked against the fixed allowlist above, never
        # built from arbitrary request input, so there's no
        # path-traversal risk here as written. If this ever grows to
        # accept a filename supplied by the request itself, that
        # string needs real sanitizing (reject '..', reject absolute
        # paths, etc.) before it touches the filesystem -- don't copy
        # this handler's current safety property forward without
        # re-adding an equivalent check.
        filename = path.lstrip('/')
        dirname = os.path.dirname(filename)
        if dirname:
            os.makedirs(dirname, exist_ok=True)
        with open(filename, 'wb') as f:
            f.write(data)

        self.send_response(200)
        self.end_headers()

    # Quiet down the default request logging just slightly -- still
    # logs everything, just doesn't need a separate log_error override
    # since 403s already get logged by the base class's normal path.


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
    with socketserver.TCPServer(("", port), WritableHandler) as httpd:
        print(f"Serving {os.getcwd()} at http://localhost:{port}")
        print(f"Write-enabled paths: {sorted(WritableHandler.WRITABLE_PATHS)}")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nStopped.")


if __name__ == '__main__':
    main()
