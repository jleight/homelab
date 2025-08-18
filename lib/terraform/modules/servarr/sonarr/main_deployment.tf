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

        init_container {
          name = "sonarr-config"

          image             = "${var.sonarr.image}:${var.sonarr.version}"
          image_pull_policy = "IfNotPresent"

          command = [
            "/bin/sh",
            "-c",
            "cp /config/config.xml /data/config.xml"
          ]

          volume_mount {
            name       = "config"
            mount_path = "/config/config.xml"
            sub_path   = "config.xml"
            read_only  = true
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }
        }

        container {
          name = "sonarr"

          image             = "${var.sonarr.image}:${var.sonarr.version}"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = local.port
          }

          volume_mount {
            name       = "data"
            mount_path = "/config"
          }

          volume_mount {
            name       = "media"
            mount_path = "/tv"
            sub_path   = "shows"
          }

          volume_mount {
            name       = "media"
            mount_path = "/downloads"
            sub_path   = "unsorted"
          }
        }

        volume {
          name = "config"

          secret {
            secret_name = local.config_secret_name
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
