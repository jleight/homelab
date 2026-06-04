# Terraform-managed config overrides, deep-merged on top of the live config at
# startup. A Secret (not a ConfigMap) so it can also carry sensitive keys (e.g.
# an admin password) later without exposing them in plain ConfigMaps.
resource "kubernetes_secret_v1" "overrides" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-overrides"

    labels = local.labels
  }

  data = {
    # Complete TF-owned overrides fragment (radio/kiss + admin password + the
    # !!binary identity key) deep-merged into config.yaml by the init container.
    "overrides.yaml" = local.overrides_rendered
  }
}

resource "kubernetes_config_map_v1" "litestream" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-litestream"

    labels = local.labels
  }

  data = {
    "litestream.yml" = local.litestream_config
  }
}
