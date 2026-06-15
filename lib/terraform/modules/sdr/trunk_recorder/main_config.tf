# config.json and each system's channelFile, mounted into /app. A change here
# doesn't roll the pod on its own, so the Deployment carries a hash of the same
# content in a pod annotation (see main_app.tf) to force a rollout.
resource "kubernetes_config_map_v1" "config" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = "${local.name}-config"
  }

  data = local.config_files
}
