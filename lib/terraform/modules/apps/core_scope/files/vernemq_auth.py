"""VerneMQ webhook auth sidecar.

VerneMQ's vmq_webhooks plugin POSTs to this service on every CONNECT, PUBLISH,
and SUBSCRIBE. Each hook gets its own endpoint path.

External publishers authenticate with:
  username = "v1_<hex-ed25519-pubkey>"
  password = <jwt signed by the matching private key, alg=EdDSA>

The internal listener (used by CoreScope to subscribe) bypasses the JWT path
via a fixed username/password pair injected through the environment.
"""

import json
import os
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

import jwt
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PublicKey

USERNAME_PREFIX = "v1_"
INTERNAL_USERNAME = os.environ["INTERNAL_USERNAME"]
INTERNAL_PASSWORD = os.environ["INTERNAL_PASSWORD"]
EXPECTED_AUDIENCE = os.environ["EXPECTED_AUDIENCE"]


def extract_pubkey(username: str) -> str | None:
    if not username.startswith(USERNAME_PREFIX):
        return None
    hex_key = username[len(USERNAME_PREFIX):]
    if len(hex_key) != 64:
        return None
    try:
        bytes.fromhex(hex_key)
    except ValueError:
        return None
    return hex_key


def verify_jwt(pubkey_hex: str, token: str) -> bool:
    try:
        pubkey = Ed25519PublicKey.from_public_bytes(bytes.fromhex(pubkey_hex))
        jwt.decode(token, pubkey, algorithms=["EdDSA"], audience=EXPECTED_AUDIENCE)
        return True
    except Exception:
        return False


def ok():
    return 200, {"result": "ok"}


def deny(reason):
    # vmq_webhooks treats any non-"ok" result as a deny.
    return 200, {"result": {"error": reason}}


def handle_register(body):
    username = body.get("username") or ""
    password = body.get("password") or ""

    if username == INTERNAL_USERNAME:
        return ok() if password == INTERNAL_PASSWORD else deny("bad internal credentials")

    pubkey = extract_pubkey(username)
    if pubkey is None:
        return deny("invalid username format")
    if not verify_jwt(pubkey, password):
        return deny("invalid jwt")
    return ok()


def handle_publish(body):
    username = body.get("username") or ""
    topic = body.get("topic") or ""

    if username == INTERNAL_USERNAME:
        return ok()

    pubkey = extract_pubkey(username)
    if pubkey is None:
        return deny("invalid username format")

    # External publishers may only push to topics that contain their own
    # pubkey hex somewhere in the topic path. The actual topic convention
    # (e.g. meshcore/<region>/<pubkey>/...) is up to the publisher, but
    # this prevents one publisher from injecting data under another's slot.
    if topic.startswith("meshcore/") and pubkey in topic:
        return ok()
    return deny("topic not allowed for this key")


def handle_subscribe(body):
    # Only the internal subscriber (CoreScope) should ever subscribe.
    username = body.get("username") or ""
    if username == INTERNAL_USERNAME:
        return ok()
    return deny("subscribe denied")


ROUTES = {
    "/auth/register": handle_register,
    "/auth/publish": handle_publish,
    "/auth/subscribe": handle_subscribe,
}


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        handler = ROUTES.get(self.path)
        if handler is None:
            self.send_response(404)
            self.end_headers()
            return

        try:
            length = int(self.headers.get("Content-Length", 0))
            body = json.loads(self.rfile.read(length) or b"{}")
        except Exception:
            status, payload = deny("bad request")
        else:
            status, payload = handler(body)

        data = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        # Used as liveness/readiness probe target.
        if self.path == "/healthz":
            self.send_response(200)
            self.end_headers()
            return
        self.send_response(404)
        self.end_headers()

    def log_message(self, fmt, *args):
        sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
