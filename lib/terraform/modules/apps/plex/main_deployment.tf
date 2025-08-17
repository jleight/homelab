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
        container {
          name = "plex"

          image             = "${var.plex.image}:${var.plex.version}"
          image_pull_policy = "IfNotPresent"

          resources {
            limits = {
              "gpu.intel.com/i915" = "1"
            }
          }

          env {
            name  = "VERSION"
            value = "latest"
          }

          env {
            name = "PLEX_CLAIM"

            value_from {
              secret_key_ref {
                name = local.claim_secret_name
                key  = "claim"
              }
            }
          }

          port {
            container_port = local.port
          }

          volume_mount {
            name       = "config"
            mount_path = "/config"
          }

          volume_mount {
            name       = "transcode"
            mount_path = "/transcode"
          }

          volume_mount {
            name       = "media"
            mount_path = "/media"
          }
        }

        volume {
          name = "config"

          persistent_volume_claim {
            claim_name = local.config_pvc_name
          }
        }

        volume {
          name = "transcode"

          empty_dir {}
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
