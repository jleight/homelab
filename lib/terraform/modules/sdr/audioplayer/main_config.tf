# Our vendored audioplayer.php (served as index.php), the config.json it reads,
# and a labelled talkgroup file per system. A change rolls the pod via the
# annotation hash in main_app.tf.
resource "kubernetes_config_map_v1" "config" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = "${local.name}-config"
  }

  data = local.config_files
}
