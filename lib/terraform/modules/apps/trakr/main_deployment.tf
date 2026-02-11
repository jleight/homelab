resource "kubernetes_deployment" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.name

    labels = local.labels
  }

  spec {
    replicas = 2

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

          image             = "${var.trakr.image}:${var.trakr.version}"
          image_pull_policy = "IfNotPresent"

          env {
            name = "DATABASE_URL"

            value_from {
              secret_key_ref {
                name = local.postgres_secret
                key  = "url"
              }
            }
          }

          port {
            container_port = local.port
          }
        }
      }
    }
  }
}
