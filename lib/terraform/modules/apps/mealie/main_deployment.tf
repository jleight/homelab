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

          image             = "${var.mealie.image}:${var.mealie.version}"
          image_pull_policy = "IfNotPresent"

          env {
            name  = "BASE_URL"
            value = local.hostname
          }

          env {
            name  = "ALLOW_SIGNUP"
            value = var.mealie.allow_signup
          }

          env {
            name  = "DB_ENGINE"
            value = "postgres"
          }

          env {
            name  = "POSTGRES_SERVER"
            value = "${local.name}-db-rw.${local.namespace}.svc.cluster.local"
          }

          env {
            name  = "POSTGRES_PORT"
            value = "5432"
          }

          env {
            name  = "POSTGRES_DB"
            value = "app"
          }

          env {
            name  = "POSTGRES_USER"
            value = local.postgres_username
          }

          env {
            name = "POSTGRES_PASSWORD"

            value_from {
              secret_key_ref {
                name = local.postgres_secret
                key  = "password"
              }
            }
          }

          port {
            container_port = local.port
          }

          volume_mount {
            name       = "data"
            mount_path = "/app/data"
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
