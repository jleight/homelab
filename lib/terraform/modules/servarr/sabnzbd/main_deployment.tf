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
          name = "sabnzbd-config"

          image             = "${var.sabnzbd.image}:${var.sabnzbd.version}"
          image_pull_policy = "IfNotPresent"

          command = [
            "/bin/sh",
            "-c",
            "cp /secret/sabnzbd.ini /config/sabnzbd.ini"
          ]

          volume_mount {
            name       = "secret"
            mount_path = "/secret/sabnzbd.ini"
            sub_path   = "sabnzbd.ini"
            read_only  = true
          }

          volume_mount {
            name       = "config"
            mount_path = "/config"
          }
        }

        container {
          name = "sabnzbd"

          image             = "${var.sabnzbd.image}:${var.sabnzbd.version}"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = local.port
          }

          volume_mount {
            name       = "config"
            mount_path = "/config"
          }

          volume_mount {
            name       = "temp"
            mount_path = "/config/logs"
            sub_path   = "logs"
          }

          volume_mount {
            name       = "temp"
            mount_path = "/downloads/incomplete"
            sub_path   = "incomplete"
          }

          volume_mount {
            name       = "media"
            mount_path = "/downloads/unsorted"
            sub_path   = "unsorted"
          }
        }

        volume {
          name = "secret"

          secret {
            secret_name = local.config_secret_name
          }
        }

        volume {
          name = "config"

          persistent_volume_claim {
            claim_name = local.config_pvc_name
          }
        }

        volume {
          name = "media"

          persistent_volume_claim {
            claim_name = local.media_pvc_name
          }
        }

        volume {
          name = "temp"

          empty_dir {}
        }
      }
    }
  }
}
