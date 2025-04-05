locals {
  namespace = local.enabled ? kubernetes_namespace.this[0].metadata[0].name : null
  name      = "isponsorblocktv"

  config_map_name = local.enabled ? kubernetes_config_map.this[0].metadata[0].name : null

  match_labels = {
    "app.kubernetes.io/name"     = local.name
    "app.kubernetes.io/instance" = local.name
  }

  labels = merge(
    local.match_labels,
    {
      "app.kubernetes.io/version"    = var.isponsorblocktv.version
      "app.kubernetes.io/component"  = "blocker"
      "app.kubernetes.io/part-of"    = local.name
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  )
}

resource "kubernetes_namespace" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    name = "isponsorblocktv"
  }
}

resource "kubernetes_config_map" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "isponsorblocktv-config"

    labels = local.labels
  }

  data = {
    "config.json" = jsonencode({
      devices = [
        for i, d in var.isponsorblocktv.devices : merge(d, {
          offset = i
        })
      ]
      apikey              = var.isponsorblocktv.api_key
      skip_categories     = var.isponsorblocktv.skip_categories
      channel_whitelist   = var.isponsorblocktv.channel_whitelist
      skip_count_tracking = var.isponsorblocktv.skip_count_tracking
      mute_ads            = var.isponsorblocktv.mute_ads
      skip_ads            = var.isponsorblocktv.skip_ads
    })
  }

  depends_on = [kubernetes_namespace.this]
}

resource "kubernetes_deployment" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "isponsorblocktv"

    labels = local.labels
  }

  spec {
    replicas = 1

    selector {
      match_labels = local.match_labels
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        container {
          name = local.name

          image             = "${var.isponsorblocktv.image}:${var.isponsorblocktv.version}"
          image_pull_policy = "IfNotPresent"

          volume_mount {
            name       = "config"
            mount_path = "/app/data/config.json"
            sub_path   = "config.json"
            read_only  = true
          }
        }

        volume {
          name = "config"

          config_map {
            name = local.config_map_name
          }
        }
      }
    }
  }

  depends_on = [kubernetes_config_map.this]
}
