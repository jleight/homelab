module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image         = var.searxng.image
  image_version = var.searxng.version

  port         = 8080
  service_port = 8080

  # Routed on whichever gateway gateway_refs names -- the private one, so the
  # UI is LAN-only. Open WebUI still reaches it over cluster DNS rather than
  # going back out through the gateway. This must not land on a public gateway:
  # an internet-reachable SearXNG is an open proxy.
  subdomain = var.searxng.subdomain
  path      = var.searxng.path

  gateway_refs   = var.gateway_refs
  gateway_domain = var.gateway_domain

  # SearXNG reads SEARXNG_PORT/SEARXNG_BIND_ADDRESS as plain values; Kubernetes'
  # SVCNAME_* service links would set SEARXNG_PORT=tcp://... and break startup.
  enable_service_links = false

  # SEARXNG_BASE_URL sets the absolute URLs SearXNG generates -- opensearch
  # descriptors, the "add to browser" flow, result links -- so it has to be the
  # name the browser used, not the cluster-internal Service.
  env = {
    SEARXNG_BASE_URL = local.public_url
  }

  env_from_secrets = [kubernetes_secret_v1.this[0].metadata[0].name]

  # Rolls the pods when settings.yml changes; SearXNG only reads it at startup.
  pod_annotations = {
    "checksum/config" = sha256(kubernetes_config_map_v1.this[0].data["settings.yml"])
    "checksum/secret" = sha256(jsonencode(kubernetes_secret_v1.this[0].data))
  }

  volumes_from_config_maps = local.enabled ? {
    config = kubernetes_config_map_v1.this[0].metadata[0].name
  } : {}

  volume_mounts = [
    {
      name       = "config"
      mount_path = "/etc/searxng/settings.yml"
      sub_path   = "settings.yml"
      read_only  = true
    }
  ]
}
