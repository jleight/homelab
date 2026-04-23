locals {
  namespace = local.enabled ? kubernetes_namespace_v1.this[0].metadata[0].name : null
  name      = local.component

  secret_name = local.enabled ? kubernetes_secret_v1.this[0].metadata[0].name : null

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

resource "kubernetes_namespace_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    name = "isponsorblocktv"
  }
}

resource "kubernetes_secret_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-config"

    labels = local.labels
  }

  data = {
    "config.json" = jsonencode({
      devices = [
        {
          name      = "Apple TV 4K"
          screen_id = var.youtube_screen_id_apple_tv_4k
        }
      ]
      apikey              = var.isponsorblocktv.api_key
      skip_categories     = var.isponsorblocktv.skip_categories
      channel_whitelist   = var.isponsorblocktv.channel_whitelist
      skip_count_tracking = var.isponsorblocktv.skip_count_tracking
      mute_ads            = var.isponsorblocktv.mute_ads
      skip_ads            = var.isponsorblocktv.skip_ads
      minimum_skip_length = var.isponsorblocktv.minimum_skip_length
      auto_play           = var.isponsorblocktv.auto_play
      join_name           = var.isponsorblocktv.join_name
    })
  }

  depends_on = [kubernetes_namespace_v1.this]
}

resource "kubernetes_deployment_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.name

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

          secret {
            secret_name = local.secret_name
          }
        }
      }
    }
  }

  depends_on = [kubernetes_secret_v1.this]
}
