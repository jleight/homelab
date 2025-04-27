resource "kubernetes_deployment" "this" {
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
        service_account_name = local.service_account_name

        container {
          name = "qbittorrent"

          image             = "${var.qbittorrent.image}:${var.qbittorrent.version}"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = local.qbittorrent_port
          }

          volume_mount {
            name       = "config"
            mount_path = "/config/qBittorrent/qBittorrent.conf"
            sub_path   = "qBittorrent.conf"
            read_only  = true
          }

          volume_mount {
            name       = "data"
            mount_path = "/config/qBittorrent"
          }

          volume_mount {
            name       = "media"
            mount_path = "/media"
          }
        }

        container {
          name = "flood"

          image             = "${var.flood.image}:${var.flood.version}"
          image_pull_policy = "IfNotPresent"

          env_from {
            config_map_ref {
              name = local.flood_env_cm_name
            }
          }

          env_from {
            secret_ref {
              name = local.flood_secret_name
            }
          }

          port {
            container_port = local.flood_port
          }
        }

        volume {
          name = "config"

          config_map {
            name = local.config_cm_name
          }
        }

        volume {
          name = "data"

          persistent_volume_claim {
            claim_name = local.data_pvc_name
          }
        }

        volume {
          name = "media"

          persistent_volume_claim {
            claim_name = local.media_pvc_name
          }
        }
      }
    }
  }
}
