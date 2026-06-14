resource "kubernetes_secret_v1" "bridge" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = "${local.bridge_name}-auth"
  }

  data = {
    ROMM_API_TOKEN = local.romm_api_token
  }
}
