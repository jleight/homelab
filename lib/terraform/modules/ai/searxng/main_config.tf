# The same shape as the SearXNG bundled in apps/turnstone, and for the same two
# reasons: a stock SearXNG ships HTML-only and answers format=json with a 403,
# and its limiter needs a Valkey/Redis and would 429 in-cluster callers that all
# arrive from one pod IP. This mounts on top of the upstream defaults, so
# use_default_settings keeps the full engine mix.
resource "kubernetes_config_map_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = local.name
  }

  data = {
    "settings.yml" = yamlencode({
      use_default_settings = true

      server = {
        # The limiter needs a Valkey/Redis, and it would 429 Open WebUI, whose
        # searches all arrive from one pod IP. The UI is reachable only from the
        # LAN through the private gateway, so there is no anonymous traffic for
        # it to shed.
        limiter         = false
        public_instance = false
      }

      search = {
        # `json` is REQUIRED -- it is what Open WebUI's search_searxng() asks
        # for, and its absence is the usual new-deployment failure.
        formats = [
          "html",
          "json"
        ]

        safe_search = var.searxng.safe_search
      }
    })
  }
}
