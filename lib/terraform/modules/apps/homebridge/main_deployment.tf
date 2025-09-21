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
        host_network         = var.homebridge.host_network

        container {
          name = local.name

          image             = "${var.homebridge.image}:${var.homebridge.version}"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = local.port
          }

          volume_mount {
            name       = "data"
            mount_path = "/homebridge"
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
