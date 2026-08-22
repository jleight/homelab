"""GHCR package webhook -> Deployment image patcher.

GitHub cannot deliver webhooks for a container registry directly; it delivers a
`package` event from the *source repository* the package is linked to. This
listens for those, and for any package it has been explicitly told about, rolls
the matching Deployment onto the current digest of the tracked tag.

Deliberately stdlib-only. This is the one process in the cluster that is exposed
to the internet *and* holds write access to a Deployment, so it carries no
dependency supply chain, needs no build step, and ships as a single file mounted
from a ConfigMap into a stock python image.

Trust model:
  - Every request must carry a valid X-Hub-Signature-256 (HMAC-SHA256 of the raw
    body under the shared webhook secret). Without it nothing is parsed and
    nothing happens. This is the entire authorization story - there is no other
    caller and no other credential.
  - The payload is *only* used to identify which package moved. The tag we track
    and the digest we deploy are both resolved against the registry ourselves, so
    a replayed or malformed-but-signed delivery cannot pin an arbitrary image.
  - Targets are an explicit allowlist. A package that is not in it is ignored,
    and the ServiceAccount is bound only in the namespaces those targets live in.
"""

import hashlib
import hmac
import json
import os
import ssl
import sys
import time
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

# Manifest media types to accept when resolving a tag. A multi-arch image is an
# index/manifest-list; asking for only the v2 manifest types makes the registry
# 404 or 406 those, so list all four.
MANIFEST_ACCEPT = ", ".join(
    [
        "application/vnd.oci.image.index.v1+json",
        "application/vnd.oci.image.manifest.v1+json",
        "application/vnd.docker.distribution.manifest.list.v2+json",
        "application/vnd.docker.distribution.manifest.v2+json",
    ]
)

REGISTRY = "ghcr.io"

SA_DIR = "/var/run/secrets/kubernetes.io/serviceaccount"
SA_TOKEN_FILE = f"{SA_DIR}/token"
SA_CA_FILE = f"{SA_DIR}/ca.crt"

# A GitHub delivery body is a few KB; anything beyond this is not a real one and
# is refused before it is read into memory.
MAX_BODY_BYTES = 1 << 20

HTTP_TIMEOUT = 10


def log(message):
    print(f"{time.strftime('%Y-%m-%dT%H:%M:%S%z')} {message}", flush=True)


# ──────────────────────────────────────────────────────────────────────────────
# Registry
# ──────────────────────────────────────────────────────────────────────────────


def registry_token(repository):
    """Fetch a pull token for a repository.

    Anonymous works for public packages. A PAT (if configured) is presented as
    basic auth to the same token endpoint, which is what GHCR expects for private
    ones - the PAT is never sent to the manifest endpoint directly.
    """
    url = (
        f"https://{REGISTRY}/token"
        f"?service={REGISTRY}&scope=repository:{repository}:pull"
    )

    request = urllib.request.Request(url)

    pat = os.environ.get("GHCR_TOKEN")
    if pat:
        import base64

        basic = base64.b64encode(f"x:{pat}".encode()).decode()
        request.add_header("Authorization", f"Basic {basic}")

    try:
        with urllib.request.urlopen(request, timeout=HTTP_TIMEOUT) as response:
            return json.load(response)["token"]
    except urllib.error.HTTPError as error:
        # GHCR refuses to mint even an anonymous token for a package that is
        # private or absent, so this is where a visibility problem surfaces —
        # long before anything touches a manifest or the API server.
        hint = ""
        if error.code in (401, 403):
            hint = (
                " — package is private or does not exist"
                f"{'' if os.environ.get('GHCR_TOKEN') else '; no GHCR_TOKEN is configured'}"
            )
        raise RuntimeError(
            f"GHCR token request for {repository} failed: HTTP {error.code}{hint}"
        ) from error


def resolve_digest(repository, tag):
    """Return the current digest of repository:tag, e.g. "sha256:abc...".

    A HEAD against the manifest endpoint returns it in Docker-Content-Digest
    without transferring the manifest body.
    """
    token = registry_token(repository)

    request = urllib.request.Request(
        f"https://{REGISTRY}/v2/{repository}/manifests/{tag}",
        method="HEAD",
    )
    request.add_header("Authorization", f"Bearer {token}")
    request.add_header("Accept", MANIFEST_ACCEPT)

    try:
        with urllib.request.urlopen(request, timeout=HTTP_TIMEOUT) as response:
            digest = response.headers.get("Docker-Content-Digest")
    except urllib.error.HTTPError as error:
        detail = " — tag does not exist" if error.code == 404 else ""
        raise RuntimeError(
            f"GHCR manifest lookup for {repository}:{tag} failed: "
            f"HTTP {error.code}{detail}"
        ) from error

    if not digest:
        raise RuntimeError(f"{repository}:{tag} returned no Docker-Content-Digest")

    return digest


# ──────────────────────────────────────────────────────────────────────────────
# Kubernetes
# ──────────────────────────────────────────────────────────────────────────────


def k8s_request(method, path, body=None, content_type=None):
    host = os.environ["KUBERNETES_SERVICE_HOST"]
    port = os.environ.get("KUBERNETES_SERVICE_PORT", "443")

    # Projected ServiceAccount tokens are rotated in place, so read it per call
    # rather than caching it at startup.
    with open(SA_TOKEN_FILE) as handle:
        token = handle.read().strip()

    request = urllib.request.Request(
        f"https://{host}:{port}{path}",
        method=method,
        data=None if body is None else json.dumps(body).encode(),
    )
    request.add_header("Authorization", f"Bearer {token}")
    request.add_header("Accept", "application/json")
    if content_type:
        request.add_header("Content-Type", content_type)

    context = ssl.create_default_context(cafile=SA_CA_FILE)

    try:
        with urllib.request.urlopen(request, timeout=HTTP_TIMEOUT, context=context) as r:
            return json.load(r)
    except urllib.error.HTTPError as error:
        # 403 here means the ServiceAccount was never bound in that namespace,
        # which is a different fix from a registry problem — say so plainly.
        hint = " — ServiceAccount is not bound in this namespace" if error.code == 403 else ""
        raise RuntimeError(
            f"Kubernetes API {method} {path} failed: HTTP {error.code}{hint}"
        ) from error


def deployment_path(namespace, name):
    return f"/apis/apps/v1/namespaces/{namespace}/deployments/{name}"


def current_state(namespace, name, container, digest_env_var):
    """Return (image, digest_env_value) for one container of a Deployment.

    digest_env_value is None when the variable is not configured or not yet
    present on the container.
    """
    deployment = k8s_request("GET", deployment_path(namespace, name))

    containers = deployment["spec"]["template"]["spec"]["containers"]
    for spec in containers:
        if spec["name"] != container:
            continue

        value = None
        if digest_env_var:
            for entry in spec.get("env") or []:
                if entry.get("name") == digest_env_var:
                    value = entry.get("value")
                    break

        return spec["image"], value

    names = ", ".join(spec["name"] for spec in containers)
    raise RuntimeError(
        f"deployment {namespace}/{name} has no container {container!r} (has: {names})"
    )


def patch_image(namespace, name, container, image, digest_env_var=None, digest=None):
    """Strategic-merge the new image onto one container, leaving the rest alone.

    `env` carries a merge patch strategy keyed on `name`, so the digest variable
    is updated in place (or appended) without disturbing the container's other
    entries or its envFrom sources.
    """
    patch = {"name": container, "image": image}

    if digest_env_var:
        patch["env"] = [{"name": digest_env_var, "value": digest}]

    return k8s_request(
        "PATCH",
        deployment_path(namespace, name),
        body={"spec": {"template": {"spec": {"containers": [patch]}}}},
        content_type="application/strategic-merge-patch+json",
    )


# ──────────────────────────────────────────────────────────────────────────────
# Deploy
# ──────────────────────────────────────────────────────────────────────────────


def deploy(key, target):
    """Reconcile one target onto the current digest of its tracked tag.

    Pinning by digest rather than tag is what makes this both idempotent (a
    redelivery resolves the same digest and no-ops) and honest about what is
    running (the Deployment records exactly which build it is on).
    """
    repository = target["repository"]
    tag = target["tag"]

    digest = resolve_digest(repository, tag)

    # Tag *and* digest, matching what _registry/app_deployment emits and what
    # the Woodpecker CD path already puts on these Deployments. The digest is
    # what actually gets pulled; the tag survives only so the running build is
    # legible in kubectl/FreeLens.
    image = f"{REGISTRY}/{repository}:{tag}@{digest}"

    namespace = target["namespace"]
    name = target["deployment"]
    container = target["container"]

    # Optional: also surface the digest to the app itself, for builds that want
    # to report what they are running.
    digest_env_var = target.get("digest_env_var")

    running, running_digest_env = current_state(
        namespace, name, container, digest_env_var
    )

    # Both halves must already match — an image that is current but whose digest
    # variable was never populated (first rollout after enabling it) still needs
    # the patch.
    if running == image and (not digest_env_var or running_digest_env == digest):
        log(f"{key}: {namespace}/{name} already on {digest}, nothing to do")
        return "unchanged"

    patch_image(namespace, name, container, image, digest_env_var, digest)

    extra = f" ({digest_env_var}={digest})" if digest_env_var else ""
    log(f"{key}: patched {namespace}/{name} {running} -> {image}{extra}")
    return "patched"


# ──────────────────────────────────────────────────────────────────────────────
# HTTP
# ──────────────────────────────────────────────────────────────────────────────


class Handler(BaseHTTPRequestHandler):
    # Populated from main().
    secret = b""
    targets = {}
    webhook_path = "/webhook"

    protocol_version = "HTTP/1.1"

    def log_message(self, format, *args):
        # BaseHTTPRequestHandler logs to stderr in its own format; route through
        # log() so pod logs are uniform, and omit the client address (it is the
        # gateway's, never GitHub's).
        log(f"{self.command} {self.path} {format % args}")

    def drain_body(self, length):
        """Consume an unread request body so a keep-alive connection stays in sync.

        Any early return that answers before reading rfile leaves the body sitting
        in the socket, and the next request line is then parsed out of those bytes
        ("Bad HTTP/0.9 request type"). An oversized body is not worth reading just
        to discard, so drop the connection instead of draining it.
        """
        if length <= 0:
            return

        if length > MAX_BODY_BYTES:
            self.close_connection = True
            return

        self.rfile.read(length)

    def respond(self, status, payload):
        body = json.dumps(payload).encode()

        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/healthz":
            self.respond(200, {"status": "ok"})
        else:
            self.respond(404, {"error": "not found"})

    def do_POST(self):
        # Parsed before the path check so both early returns below can drain the
        # body; a header that is not an integer is just a bad length.
        try:
            length = int(self.headers.get("Content-Length") or 0)
        except ValueError:
            self.close_connection = True
            self.respond(400, {"error": "bad content-length"})
            return

        if self.path != self.webhook_path:
            self.drain_body(length)
            self.respond(404, {"error": "not found"})
            return

        if length <= 0 or length > MAX_BODY_BYTES:
            self.drain_body(length)
            self.respond(400, {"error": "bad content-length"})
            return

        body = self.rfile.read(length)

        # Signature first: nothing below this line runs for an unsigned caller.
        signature = self.headers.get("X-Hub-Signature-256", "")
        expected = "sha256=" + hmac.new(self.secret, body, hashlib.sha256).hexdigest()
        if not hmac.compare_digest(signature, expected):
            log("rejected delivery with bad or missing signature")
            self.respond(401, {"error": "bad signature"})
            return

        event = self.headers.get("X-GitHub-Event", "")
        if event == "ping":
            self.respond(200, {"status": "pong"})
            return

        if event != "package":
            self.respond(202, {"status": "ignored", "reason": f"event {event}"})
            return

        try:
            payload = json.loads(body)
        except json.JSONDecodeError:
            self.respond(400, {"error": "malformed json"})
            return

        action = payload.get("action")
        if action not in ("published", "updated"):
            self.respond(202, {"status": "ignored", "reason": f"action {action}"})
            return

        package = payload.get("package") or {}
        owner = (package.get("namespace") or "").lower()
        name = (package.get("name") or "").lower()
        key = f"{owner}/{name}"

        target = self.targets.get(key)
        if target is None:
            log(f"ignoring {key}: not a configured target")
            self.respond(202, {"status": "ignored", "reason": "unknown package"})
            return

        try:
            result = deploy(key, target)
        except Exception as error:  # noqa: BLE001 - report, let GitHub redeliver
            log(f"{key}: deploy failed: {type(error).__name__}: {error}")
            self.respond(500, {"error": "deploy failed"})
            return

        self.respond(202, {"status": result, "package": key})


def main():
    secret = os.environ.get("GHCR_DEPLOY_SECRET", "")
    if not secret:
        sys.exit("GHCR_DEPLOY_SECRET is required")

    with open(os.environ.get("GHCR_DEPLOY_TARGETS", "/etc/ghcr-deploy/targets.json")) as f:
        targets = json.load(f)

    Handler.secret = secret.encode()
    Handler.targets = targets
    Handler.webhook_path = os.environ.get("GHCR_DEPLOY_PATH", "/webhook")

    port = int(os.environ.get("GHCR_DEPLOY_PORT", "8080"))

    log(f"listening on :{port}{Handler.webhook_path} for {len(targets)} target(s)")
    for key, target in sorted(targets.items()):
        log(f"  {key}:{target['tag']} -> {target['namespace']}/{target['deployment']}")

    ThreadingHTTPServer(("", port), Handler).serve_forever()


if __name__ == "__main__":
    main()
