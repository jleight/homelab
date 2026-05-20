locals {
  vernemq_auth_match_labels = {
    "app.kubernetes.io/name"     = local.vernemq_auth_name
    "app.kubernetes.io/instance" = local.vernemq_auth_name
  }

  vernemq_auth_labels = merge(
    local.vernemq_auth_match_labels,
    {
      "app.kubernetes.io/component"  = "vernemq-auth"
      "app.kubernetes.io/part-of"    = local.stack
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  )
}

# The Python code lives next to the .tf files and is rendered into a ConfigMap.
# Editing the script and re-running terraform restarts the pod with the new
# code — no image rebuild, no registry.
resource "kubernetes_config_map_v1" "vernemq_auth_code" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.vernemq_auth_name}-code"

    labels = local.vernemq_auth_labels
  }

  data = {
    "auth.py" = file("${path.module}/files/vernemq_auth.py")
  }
}

resource "kubernetes_secret_v1" "vernemq_auth_internal" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.vernemq_auth_name}-internal"

    labels = local.vernemq_auth_labels
  }

  data = {
    username = local.vernemq_internal_user
    password = local.vernemq_internal_pass
  }
}

resource "kubernetes_deployment_v1" "vernemq_auth" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.vernemq_auth_name

    labels = local.vernemq_auth_labels
  }

  spec {
    replicas = 1

    selector {
      match_labels = local.vernemq_auth_match_labels
    }

    template {
      metadata {
        labels = local.vernemq_auth_labels

        annotations = {
          # Restart the pod whenever the script changes so terraform applies
          # show up immediately instead of waiting for the next eviction.
          "checksum/code" = sha256(file("${path.module}/files/vernemq_auth.py"))
        }
      }

      spec {
        container {
          name = "auth"

          image             = "${var.core_scope.vernemq.auth.image}:${var.core_scope.vernemq.auth.version}"
          image_pull_policy = "IfNotPresent"

          # Stock python:slim has no deps preinstalled. Install once at startup
          # then exec the script. Pod restarts are rare; the ~3s warmup is fine.
          command = ["sh", "-c"]
          args = [
            "pip install --quiet --root-user-action=ignore pyjwt cryptography && exec python /app/auth.py"
          ]

          port {
            name           = "http"
            container_port = local.vernemq_auth_port
          }

          env {
            name = "INTERNAL_USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.vernemq_auth_internal[0].metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "INTERNAL_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.vernemq_auth_internal[0].metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name  = "EXPECTED_AUDIENCE"
            value = local.vernemq_public_host
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
            name = kubernetes_config_map_v1.vernemq_auth_code[0].metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "vernemq_auth" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.vernemq_auth_name

    labels = local.vernemq_auth_labels
  }

  spec {
    port {
      name        = "http"
      port        = local.vernemq_auth_port
      target_port = "http"
    }

    selector = local.vernemq_auth_match_labels
  }
}
