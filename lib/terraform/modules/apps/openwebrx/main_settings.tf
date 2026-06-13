# The curated settings fragment (local.settings_seed) is mounted into the init
# container, which deep-merges it over /var/lib/openwebrx/settings.json before
# OpenWebRX starts. Changing this ConfigMap alone won't restart the pod, so the
# Deployment carries a hash of the same content in a pod annotation (see
# main_app.tf) to force a rollout — and re-merge — whenever it changes.
resource "kubernetes_config_map_v1" "settings_seed" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-settings-seed"
  }

  data = {
    "settings.json" = jsonencode(local.settings_seed)
  }
}
