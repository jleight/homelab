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
          name = "audiobookshelf"

          image             = "${var.audiobookshelf.image}:${var.audiobookshelf.version}"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = local.port
          }

          volume_mount {
            name       = "data"
            mount_path = "/config"
            sub_path   = "config"
          }

          volume_mount {
            name       = "data"
            mount_path = "/metadata"
            sub_path   = "metadata"
          }

          volume_mount {
            name       = "media"
            mount_path = "/books"
            sub_path   = "books"
          }

          volume_mount {
            name       = "media"
            mount_path = "/podcasts"
            sub_path   = "podcasts"
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
