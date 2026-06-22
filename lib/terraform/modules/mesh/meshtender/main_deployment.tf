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
        image_pull_secrets {
          name = kubernetes_secret_v1.registry[0].metadata[0].name
        }

        container {
          name = local.name

          image             = local.bootstrap_image
          image_pull_policy = "IfNotPresent"

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.app[0].metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.app[0].metadata[0].name
            }
          }

          port {
            container_port = local.port
          }

          readiness_probe {
            http_get {
              path = "/"
              port = local.port
            }

            initial_delay_seconds = 3
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/"
              port = local.port
            }

            initial_delay_seconds = 10
            period_seconds        = 20
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }

            limits = {
              memory = "256Mi"
            }
          }
        }
      }
    }
  }

  # CI owns the running image tag via `kubectl set image`; Terraform only sets
  # the bootstrap image at creation and never reconciles it afterwards.
  lifecycle {
    ignore_changes = [
      spec[0].template[0].spec[0].container[0].image
    ]
  }
}
