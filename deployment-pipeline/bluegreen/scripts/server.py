#!/usr/bin/env python3
"""KijaniKiosk API simulator for the blue/green lab.

Serves GET /health -> {"status":"ok","version":APP_VERSION,"env":DEPLOY_ENV}
Version and environment come from systemd (EnvironmentFile), so the same code
runs as v1.3.0 on blue and v1.4.0 on green.
"""
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

VERSION = os.environ.get("APP_VERSION", "unknown")
ENV = os.environ.get("DEPLOY_ENV", "unknown")
PORT = int(os.environ.get("PORT", "3000"))


class Handler(BaseHTTPRequestHandler):
    def _send(self, code, payload):
        body = json.dumps(payload).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = self.path.split("?", 1)[0]
        if path == "/health":
            self._send(200, {"status": "ok", "version": VERSION, "env": ENV})
        elif path.startswith("/payments"):
            self._send(200, {"result": "accepted", "version": VERSION})
        else:
            self._send(404, {"error": "not found"})

    def log_message(self, fmt, *args):  # goes to journald
        print("%s %s" % (self.address_string(), fmt % args), flush=True)


if __name__ == "__main__":
    print(f"kk-api {ENV} {VERSION} listening on 127.0.0.1:{PORT}", flush=True)
    ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
