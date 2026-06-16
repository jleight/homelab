# The fetched-and-patched audioplayer.php (served as index.php), the config.json
# it reads, and a labelled talkgroup file per system. A change rolls the pod via
# the annotation hash in main_app.tf.
resource "kubernetes_config_map_v1" "config" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = "${local.name}-config"
  }

  data = local.config_files

  # Fail loudly if upstream changes the lines we rewrite, rather than shipping a
  # silently-mispatched script (e.g. wrong base dir → broken audio URLs).
  lifecycle {
    precondition {
      condition = alltrue([
        strcontains(local.script_raw, "date_default_timezone_set('America/New_York')"),
        strcontains(local.script_raw, "$base_directory_name = '/home/trunkrecorder';"),
        strcontains(local.script_raw, "'./../configs/config.json'"),
      ])
      error_message = "audioplayer.php upstream changed: a line patched by replace() in locals.tf was not found. Review and update the patches."
    }
  }
}
