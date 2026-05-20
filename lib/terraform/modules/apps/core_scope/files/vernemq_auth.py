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
import logging
import os
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

import jwt
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PublicKey

USERNAME_PREFIX = "v1_"
INTERNAL_USERNAME = os.environ["INTERNAL_USERNAME"]
INTERNAL_PASSWORD = os.environ["INTERNAL_PASSWORD"]
EXPECTED_AUDIENCE = os.environ["EXPECTED_AUDIENCE"]

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
    stream=sys.stderr,
)
log = logging.getLogger("vernemq-auth")


def short(pubkey: str | None) -> str:
    if not pubkey:
        return "?"
    return pubkey[:8]


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


def verify_jwt(pubkey_hex: str, token: str) -> str | None:
    try:
        pubkey = Ed25519PublicKey.from_public_bytes(bytes.fromhex(pubkey_hex))
        jwt.decode(token, pubkey, algorithms=["EdDSA"], audience=EXPECTED_AUDIENCE)
        return None
    except jwt.ExpiredSignatureError:
        return "jwt expired"
    except jwt.InvalidAudienceError:
        return "jwt audience mismatch"
    except jwt.InvalidSignatureError:
        return "jwt signature invalid"
    except jwt.DecodeError as exc:
        return f"jwt decode error: {exc}"
    except Exception as exc:
        return f"jwt error: {exc.__class__.__name__}: {exc}"


def ok():
    return 200, {"result": "ok"}


def deny(reason):
    # vmq_webhooks treats any non-"ok" result as a deny.
    return 200, {"result": {"error": reason}}


def handle_register(body, peer):
    username = body.get("username") or ""
    password = body.get("password") or ""
    client_id = body.get("client_id") or ""

    if username == INTERNAL_USERNAME:
        if password == INTERNAL_PASSWORD:
            log.info("register ok: internal user client_id=%s peer=%s", client_id, peer)
            return ok()
        log.warning("register deny: internal user bad password client_id=%s peer=%s", client_id, peer)
        return deny("bad internal credentials")

    pubkey = extract_pubkey(username)
    if pubkey is None:
        log.warning(
            "register deny: bad username format username=%r client_id=%s peer=%s",
            username, client_id, peer,
        )
        return deny("invalid username format")

    err = verify_jwt(pubkey, password)
    if err is not None:
        log.warning(
            "register deny: %s pubkey=%s client_id=%s peer=%s",
            err, short(pubkey), client_id, peer,
        )
        return deny(err)

    log.info("register ok: pubkey=%s client_id=%s peer=%s", short(pubkey), client_id, peer)
    return ok()


def handle_publish(body, peer):
    username = body.get("username") or ""
    topic = body.get("topic") or ""
    client_id = body.get("client_id") or ""
    qos = body.get("qos")

    if username == INTERNAL_USERNAME:
        return ok()

    pubkey = extract_pubkey(username)
    if pubkey is None:
        log.warning(
            "publish deny: bad username format username=%r topic=%s client_id=%s",
            username, topic, client_id,
        )
        return deny("invalid username format")

    # External publishers may only push to topics that contain their own
    # pubkey hex somewhere in the topic path. The actual topic convention
    # (e.g. meshcore/<region>/<pubkey>/...) is up to the publisher, but
    # this prevents one publisher from injecting data under another's slot.
    if topic.startswith("meshcore/") and pubkey in topic:
        log.info(
            "publish ok: pubkey=%s topic=%s qos=%s client_id=%s",
            short(pubkey), topic, qos, client_id,
        )
        return ok()

    log.warning(
        "publish deny: topic not allowed pubkey=%s topic=%s client_id=%s",
        short(pubkey), topic, client_id,
    )
    return deny("topic not allowed for this key")


def handle_subscribe(body, peer):
    username = body.get("username") or ""
    client_id = body.get("client_id") or ""
    topics = body.get("topics") or []

    if username == INTERNAL_USERNAME:
        log.info("subscribe ok: internal user topics=%s client_id=%s", topics, client_id)
        return ok()

    pubkey = extract_pubkey(username)
    log.warning(
        "subscribe deny: external clients may not subscribe pubkey=%s topics=%s client_id=%s",
        short(pubkey), topics, client_id,
    )
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
            log.warning("404 POST %s from %s", self.path, self.client_address[0])
            return

        try:
            length = int(self.headers.get("Content-Length", 0))
            body = json.loads(self.rfile.read(length) or b"{}")
        except Exception as exc:
            log.warning("bad request to %s from %s: %s", self.path, self.client_address[0], exc)
            status, payload = deny("bad request")
        else:
            peer = "%s:%s" % (body.get("peer_addr") or "?", body.get("peer_port") or "?")
            status, payload = handler(body, peer)

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
        # Silence the built-in access log entirely — we emit structured logs
        # from each handler instead, and probe traffic on /healthz would
        # otherwise dominate the output.
        return


if __name__ == "__main__":
    log.info("listening on :8080 (audience=%s)", EXPECTED_AUDIENCE)
    HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
