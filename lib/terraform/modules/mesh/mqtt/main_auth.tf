resource "random_password" "user" {
  for_each = local.enabled ? toset(var.internal_users) : []

  length  = 32
  special = false
}

resource "kubernetes_config_map_v1" "auth_code" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.auth_name}-code"

    labels = local.auth_labels
  }

  data = {
    "auth.py" = file("${path.module}/files/vernemq_auth.py")
  }
}

resource "kubernetes_secret_v1" "auth_internal" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.auth_name}-internal"

    labels = local.auth_labels
  }

  data = {
    users = local.internal_users_json
  }
}

resource "kubernetes_deployment_v1" "auth" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.auth_name

    labels = local.auth_labels
  }

  spec {
    # Two replicas so rolling the webhook doesn't deny CONNECTs. The webhook is
    # stateless — a JWT check plus the static INTERNAL_USERS map — so any pod can
    # answer any hook.
    replicas = 2

    # maxUnavailable 0 keeps both pods serving until a replacement is ready,
    # which is what makes the INTERNAL_USERS rollout below a no-downtime change.
    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = 0
        max_surge       = 1
      }
    }

    selector {
      match_labels = local.auth_match_labels
    }

    template {
      metadata {
        labels = local.auth_labels

        annotations = {
          "checksum/code" = sha256(file("${path.module}/files/vernemq_auth.py"))

          # INTERNAL_USERS arrives as a secretKeyRef env var, which the script
          # reads once at startup — adding a user or rotating a password has no
          # effect until the pods restart. Hash the map in so Terraform rolls
          # them for us.
          "checksum/internal-users" = sha256(local.internal_users_json)
        }
      }

      spec {
        container {
          name = "auth"

          image             = "${var.mqtt.auth.image}:${var.mqtt.auth.version}"
          image_pull_policy = "IfNotPresent"

          command = ["sh", "-c"]
          args = [
            "pip install --quiet --root-user-action=ignore cryptography && exec python -u /app/auth.py"
          ]

          port {
            name           = "http"
            container_port = local.auth_port
          }

          env {
            name = "INTERNAL_USERS"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.auth_internal[0].metadata[0].name
                key  = "users"
              }
            }
          }

          env {
            name  = "EXPECTED_AUDIENCES"
            value = join(",", var.gateway_hostnames)
          }

          volume_mount {
            name       = "code"
            mount_path = "/app"
            read_only  = true
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = "http"
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = "http"
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }
        }

        volume {
          name = "code"

          config_map {
            name = kubernetes_config_map_v1.auth_code[0].metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "auth" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.auth_name

    labels = local.auth_labels
  }

  spec {
    port {
      name        = "http"
      port        = local.auth_port
      target_port = "http"
    }

    selector = local.auth_match_labels
  }
}
