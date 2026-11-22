"""VerneMQ webhook auth sidecar.

VerneMQ's vmq_webhooks plugin POSTs to this service on every CONNECT, PUBLISH,
and SUBSCRIBE. Each hook gets its own endpoint path.

External publishers authenticate with:
  username = "v1_<hex-ed25519-pubkey>"
  password = <jwt signed by the matching private key, alg=EdDSA>

The internal listener (used by CoreScope to subscribe) bypasses the JWT path
via a fixed username/password pair injected through the environment.

Third-party (external) users also use a username/password pair, with
per-user permissions:
  read  -> may subscribe under meshcore/
  write -> list of MQTT topic filters the user may publish to (and subscribe to)
Anything not granted is denied.
"""

import base64
import binascii
import json
import logging
import os
import sys
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PublicKey

USERNAME_PREFIX = "v1_"
# Map of {username: password} for internal callers that bypass the JWT path.
# Each in-cluster service (e.g. CoreScope) gets its own entry so they can be
# rotated independently.
INTERNAL_USERS = json.loads(os.environ["INTERNAL_USERS"])
# Map of {username: {"password": str, "read": bool, "write": [filter, ...]}}
# for third-party users.
EXTERNAL_USERS = json.loads(os.environ["EXTERNAL_USERS"])
# Filters an external user with `read` may subscribe to.
READ_FILTERS = ["meshcore/#"]
# Comma-separated list — clients may set their `audience` to any of these and
# the JWT will be accepted. Lets us serve the same broker under multiple
# public hostnames (e.g. leightha.us and wnymeshcore.org).
EXPECTED_AUDIENCES = {a.strip() for a in os.environ["EXPECTED_AUDIENCES"].split(",") if a.strip()}

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


def _b64url_decode(data: str) -> bytes:
    # JWT base64url with padding stripped — add it back.
    pad = "=" * (-len(data) % 4)
    return base64.urlsafe_b64decode(data + pad)


def verify_jwt(pubkey_hex: str, token: str) -> str | None:
    """Verify a MeshCore-style JWT.

    Differs from RFC 7519 / PyJWT in three ways:
      - header `alg` is "Ed25519" instead of "EdDSA"
      - signature is hex-encoded (uppercase) instead of base64url
      - payload includes a `publicKey` claim that should match the username
    """
    try:
        header_b64, payload_b64, signature_hex = token.split(".")
    except ValueError:
        return "jwt malformed (not three parts)"

    try:
        header = json.loads(_b64url_decode(header_b64))
        payload = json.loads(_b64url_decode(payload_b64))
    except (ValueError, binascii.Error, UnicodeDecodeError) as exc:
        return f"jwt decode error: {exc}"

    if header.get("alg") != "Ed25519":
        return f"jwt alg mismatch: got {header.get('alg')!r}"

    try:
        signature = bytes.fromhex(signature_hex)
    except ValueError:
        return "jwt signature not hex"

    signing_input = f"{header_b64}.{payload_b64}".encode("utf-8")
    try:
        Ed25519PublicKey.from_public_bytes(bytes.fromhex(pubkey_hex)).verify(
            signature, signing_input
        )
    except InvalidSignature:
        return "jwt signature invalid"
    except Exception as exc:
        return f"jwt verify error: {exc.__class__.__name__}: {exc}"

    exp = payload.get("exp")
    if not isinstance(exp, (int, float)) or time.time() >= exp:
        return "jwt expired"

    aud = payload.get("audience") or payload.get("aud")
    if aud not in EXPECTED_AUDIENCES:
        return f"jwt audience mismatch: got {aud!r}, want one of {sorted(EXPECTED_AUDIENCES)!r}"

    # Payload's publicKey (uppercase hex) must match the username's pubkey.
    claim_pub = (payload.get("publicKey") or "").lower()
    if claim_pub and claim_pub != pubkey_hex.lower():
        return "jwt publicKey claim does not match username"

    return None


def covers(allowed: str, requested: str) -> bool:
    """True if every topic matched by `requested` is matched by `allowed`.

    Both are MQTT topic filters; a publish topic is just a filter without
    wildcards. `$share/...` requests never match since no grant starts with `$`.
    """
    a = allowed.split("/")
    r = requested.split("/")
    for i, level in enumerate(a):
        if level == "#":
            return True
        if i >= len(r) or r[i] == "#":
            return False
        if level == "+":
            continue
        if level != r[i]:
            return False
    return len(r) == len(a)


def write_filters(username: str) -> list[str]:
    return EXTERNAL_USERS[username].get("write") or []


def read_filters(username: str) -> list[str]:
    # Users can always read back what they're allowed to write.
    base = READ_FILTERS if EXTERNAL_USERS[username].get("read") else []
    return base + write_filters(username)


def ok():
    return 200, {"result": "ok"}


def deny(reason):
    # vmq_webhooks treats any non-"ok" result as a deny.
    return 200, {"result": {"error": reason}}


def handle_register(body, peer):
    username = body.get("username") or ""
    password = body.get("password") or ""
    client_id = body.get("client_id") or ""

    if username in INTERNAL_USERS:
        if password == INTERNAL_USERS[username]:
            log.info("register ok: internal user=%s client_id=%s peer=%s", username, client_id, peer)
            return ok()
        log.warning("register deny: internal user=%s bad password client_id=%s peer=%s", username, client_id, peer)
        return deny("bad internal credentials")

    if username in EXTERNAL_USERS:
        if password == EXTERNAL_USERS[username]["password"]:
            log.info("register ok: external user=%s client_id=%s peer=%s", username, client_id, peer)
            return ok()
        log.warning("register deny: external user=%s bad password client_id=%s peer=%s", username, client_id, peer)
        return deny("bad external credentials")

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

    if username in INTERNAL_USERS:
        return ok()

    if username in EXTERNAL_USERS:
        if any(covers(f, topic) for f in write_filters(username)):
            return ok()
        log.warning("publish deny: external user=%s topic=%s client_id=%s", username, topic, client_id)
        return deny("topic not allowed for user")

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

    if username in INTERNAL_USERS:
        log.info("subscribe ok: internal user=%s topics=%s client_id=%s", username, topics, client_id)
        return ok()

    if username in EXTERNAL_USERS:
        # Each entry is {"topic": ..., "qos": ...}. Deny the whole request if any
        # filter isn't fully covered by a grant — that also rules out bare `#`,
        # leading wildcards, and $share/ shared subscriptions.
        allowed = read_filters(username)
        filters = [t.get("topic") or "" for t in topics]
        if filters and all(any(covers(a, f) for a in allowed) for f in filters):
            log.info("subscribe ok: external user=%s topics=%s client_id=%s", username, filters, client_id)
            return ok()
        log.warning("subscribe deny: external user=%s topics=%s client_id=%s", username, filters, client_id)
        return deny("topic not allowed for user")

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
    log.info(
        "listening on :8080 (audiences=%s, internal_users=%s, external_users=%s)",
        sorted(EXPECTED_AUDIENCES),
        sorted(INTERNAL_USERS),
        {u: {"read": read_filters(u), "write": write_filters(u)} for u in sorted(EXTERNAL_USERS)},
    )
    HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
