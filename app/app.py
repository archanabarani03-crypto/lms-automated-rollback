
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

VERSION = os.getenv("APP_VERSION", "unknown")
FAIL_HEALTH = os.getenv("FAIL_HEALTH", "false").lower() == "true"


class LMSHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            if FAIL_HEALTH:
                self.send_response(500)
                self.end_headers()
                self.wfile.write(b"UNHEALTHY")
                return

            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK")
            return

        if self.path == "/":
            status = 500 if FAIL_HEALTH else 200
            self.send_response(status)
            self.send_header("Content-Type", "text/html")
            self.end_headers()
            body = (
                f"<html><body><h1>LMS Demo</h1>"
                f"<p>Version: {VERSION}</p></body></html>"
            )
            self.wfile.write(body.encode())
            return

        self.send_response(404)
        self.end_headers()

    def log_message(self, fmt, *args):
        print(f"{self.client_address[0]} - {fmt % args}", flush=True)


if __name__ == "__main__":
    server = HTTPServer(("0.0.0.0", 8080), LMSHandler)
    print(f"LMS version {VERSION} starting on port 8080", flush=True)
    server.serve_forever()
