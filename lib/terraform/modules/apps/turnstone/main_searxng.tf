# SearxNG — self-hosted metasearch backing the server nodes' web_search tool.
# Internal-only (ClusterIP, no ingress): nodes reach it at local.searxng_url and
# no external user touches its UI. The bundled config below mounts on top of
# SearxNG's upstream defaults (use_default_settings keeps the full engine mix):
# it enables the JSON format the web_search API requires (a stock SearxNG ships
# HTML-only and 403s format=json — the most common new-deployment failure) and
# leaves the limiter off (the limiter needs a Valkey/Redis and would 429 the
# nodes' own internal requests).

resource "kubernetes_config_map_v1" "searxng" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.searxng_name
  }

  data = {
    "settings.yml" = <<-YAML
      use_default_settings: true

      server:
        # Fixed and intentionally NOT secret: this instance is cluster-internal,
        # serves no UI to end users, and runs no image_proxy or sessions, so the
        # secret_key has no security role here.
        secret_key: "turnstone-bundled-searxng-not-secret"
        # Off by default — the limiter needs a Valkey/Redis and would 429 the
        # nodes' own internal requests.
        limiter: false
        public_instance: false

      search:
        # `json` is REQUIRED for the API — a stock SearxNG ships html-only and
        # returns 403 for format=json, which the web_search tool calls.
        formats:
          - html
          - json
    YAML
  }
}

module "searxng" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace     = local.namespace
  name          = local.searxng_name
  app_component = local.searxng_name

  image         = var.turnstone.searxng.image
  image_version = var.turnstone.searxng.version

  port         = 8080
  service_port = 8080

  # Internal only — the nodes reach it via cluster DNS, never a front door.
  ingress_enabled = false

  # SearxNG reads SEARXNG_PORT/SEARXNG_BIND_ADDRESS as plain values; Kubernetes'
  # SVCNAME_* service links would set SEARXNG_PORT=tcp://… and break startup.
  enable_service_links = false

  volumes_from_config_maps = local.enabled ? {
    config = kubernetes_config_map_v1.searxng[0].metadata[0].name
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
