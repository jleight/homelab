# Observer firmware, served read-only from the NAS at firmware.<root host>.
# Builds are published straight to the share outside the cluster; the share
# lands at Backups/<storage stack>/<namespace>/<claim name>.
locals {
  firmware_name = "${local.name}-firmware"
  firmware_port = 8080

  firmware_match_labels = {
    "app.kubernetes.io/name"     = local.firmware_name
    "app.kubernetes.io/instance" = local.firmware_name
  }

  firmware_labels = merge(
    local.firmware_match_labels,
    {
      "app.kubernetes.io/component"  = local.firmware_name
      "app.kubernetes.io/part-of"    = local.stack
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  )

  firmware_nginx_conf = file("${path.module}/files/firmware.conf")
}

resource "kubernetes_persistent_volume_claim_v1" "firmware" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.firmware_name

    labels = local.firmware_labels
  }

  spec {
    storage_class_name = var.firmware_storage_class
    access_modes       = ["ReadWriteMany"]

    resources {
      requests = {
        # Nominal: SMB ignores it.
        storage = "10Gi"
      }
    }
  }
}

resource "kubernetes_config_map_v1" "firmware" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.firmware_name}-nginx"

    labels = local.firmware_labels
  }

  data = {
    "default.conf" = local.firmware_nginx_conf
  }
}

resource "kubernetes_deployment_v1" "firmware" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.firmware_name

    labels = local.firmware_labels
  }

  spec {
    replicas = var.meshtender.firmware.replicas

    selector {
      match_labels = local.firmware_match_labels
    }

    template {
      metadata {
        labels = local.firmware_labels

        # subPath mounts never see ConfigMap updates; roll the pods instead.
        annotations = {
          "checksum/config" = sha256(local.firmware_nginx_conf)
        }
      }

      spec {
        enable_service_links = false

        security_context {
          run_as_non_root = true

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        container {
          name = "nginx"

          image             = "${var.meshtender.firmware.nginx.image}:${var.meshtender.firmware.nginx.version}"
          image_pull_policy = "IfNotPresent"

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = true

            capabilities {
              drop = ["ALL"]
            }
          }

          port {
            name           = "http"
            container_port = local.firmware_port
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/nginx/conf.d/default.conf"
            sub_path   = "default.conf"
            read_only  = true
          }

          volume_mount {
            name       = "firmware"
            mount_path = "/srv/firmware"
            read_only  = true
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = "http"
            }

            period_seconds = 10
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = "http"
            }

            period_seconds = 30
          }

          resources {
            requests = {
              cpu    = "5m"
              memory = "16Mi"
            }

            limits = {
              memory = "64Mi"
            }
          }
        }

        volume {
          name = "config"

          config_map {
            name = kubernetes_config_map_v1.firmware[0].metadata[0].name
          }
        }

        volume {
          name = "firmware"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.firmware[0].metadata[0].name
            read_only  = true
          }
        }

        volume {
          name = "tmp"

          empty_dir {}
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "firmware" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.firmware_name

    labels = local.firmware_labels
  }

  spec {
    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }

    selector = local.firmware_match_labels
  }
}

resource "kubectl_manifest" "firmware_ingress" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      namespace = local.namespace
      name      = local.firmware_name

      # Proxied through Cloudflare: observer nodes fetch over HTTP/1.0, which the
      # gateway's Envoy rejects (426) with no knob to allow it. Cloudflare's edge
      # accepts it and talks HTTP/1.1 to the origin.
      annotations = {
        "external-dns.alpha.kubernetes.io/cloudflare-proxied" = "true"
      }
    }

    # HTTPS via the app's listeners (the *.meshtender.com one serves this host),
    # plus a dedicated plain-HTTP listener: Cloudflare pulls from the origin with
    # the visitor's scheme, so HTTP requests arrive on :80 and must not hit the
    # gateway's catch-all https redirect.
    spec = {
      parentRefs = concat(var.gateway_refs, var.firmware_http_gateway_refs)
      hostnames  = [var.meshtender.hosts.firmware]
      rules = [
        {
          backendRefs = [
            {
              name = kubernetes_service_v1.firmware[0].metadata[0].name
              port = 80
            }
          ]
        }
      ]
    }
  })
}
