"""Minimal, dependency-free HTTP service used to exercise the template pipelines.

Endpoints:
  GET /healthz        liveness probe
  GET /readyz         readiness probe
  GET /api/v1/hello   sample business endpoint (?name=...)
"""

from __future__ import annotations

import json
import logging
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

from app import __version__

log = logging.getLogger("app")


def greet(name: str | None) -> dict[str, str]:
    return {"message": f"Hello, {name or 'world'}!"}


class Handler(BaseHTTPRequestHandler):
    server_version = f"template-app/{__version__}"

    def _send_json(self, status: int, payload: dict) -> None:
        body = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:  # noqa: N802 (stdlib naming)
        url = urlparse(self.path)
        if url.path in ("/healthz", "/readyz"):
            self._send_json(200, {"status": "ok", "version": __version__})
        elif url.path == "/api/v1/hello":
            name = parse_qs(url.query).get("name", [None])[0]
            self._send_json(200, greet(name))
        else:
            self._send_json(404, {"error": "not found"})

    def log_message(self, fmt: str, *args) -> None:
        log.info("%s - %s", self.address_string(), fmt % args)


def main() -> None:
    logging.basicConfig(
        level=os.getenv("LOG_LEVEL", "info").upper(),
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
    )
    port = int(os.getenv("APP_PORT", "8080"))
    server = ThreadingHTTPServer(("0.0.0.0", port), Handler)  # noqa: S104
    log.info("listening on :%d (env=%s)", port, os.getenv("APP_ENV", "local"))
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
