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
          name = local.name

          image             = "${var.smokeping.image}:${var.smokeping.version}"
          image_pull_policy = "IfNotPresent"

          env {
            name  = "TZ"
            value = var.smokeping.time_zone
          }

          port {
            container_port = 80
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/smokeping/config"
            sub_path   = "config"
            read_only  = true
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
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
      }
    }
  }
}
