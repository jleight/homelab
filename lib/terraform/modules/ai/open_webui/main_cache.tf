# Open WebUI coordinates websocket sessions and cached app state through Redis
# whenever WEBSOCKET_MANAGER is "redis". At a single replica the in-memory
# manager would do, but wiring the external one now means scaling out is a
# replica-count change rather than a re-plumbing -- and Dragonfly's operator is
# already running cluster-wide for immich.
resource "kubectl_manifest" "cache" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "dragonflydb.io/v1alpha1"
    kind       = "Dragonfly"

    metadata = {
      namespace = var.namespace
      name      = local.cache_name
    }

    spec = {
      replicas = var.open_webui.cache_replicas
    }
  })
}
