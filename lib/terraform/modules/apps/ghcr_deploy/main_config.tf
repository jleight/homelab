# Code and allowlist travel together: the service is a single stdlib-only file,
# so a ConfigMap and a stock Python image replace an image build entirely.
resource "kubernetes_config_map_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.name
  }

  data = {
    "ghcr_deploy.py" = local.code
    "targets.json"   = local.targets_json
  }
}
