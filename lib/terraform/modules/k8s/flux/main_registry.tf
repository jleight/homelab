# An image registry for images that ImageBuilds produce. It is published
# through the private gateway, so pods and the nodes' containerd reach it by the
# same name over TLS. flux_managed_namespace copies its credentials into every
# namespace Flux manages.
locals {
  registry_hostname = "${var.k8s_flux.registry.subdomain}.${var.gateway_domain}"
  registry_port     = 5000
  registry_username = "flux"

  registry_labels = {
    "app.kubernetes.io/name"    = "registry"
    "app.kubernetes.io/part-of" = "flux"
  }
}

resource "random_password" "registry" {
  count = local.enabled ? 1 : 0

  length  = 32
  special = false
}

resource "kubernetes_secret_v1" "registry_htpasswd" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "registry-htpasswd"
  }

  data = {
    htpasswd = "${local.registry_username}:${random_password.registry[0].bcrypt_hash}"
  }
}

resource "kubernetes_persistent_volume_claim_v1" "registry" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "registry"
  }

  spec {
    # Built images can always be rebuilt, so they live on nas02 rather than
    # taking Longhorn space and being backed up offsite with it.
    storage_class_name = var.backups_storage_class

    resources {
      requests = {
        storage = var.k8s_flux.registry.size
      }
    }

    access_modes = [
      "ReadWriteOnce"
    ]
  }
}

resource "kubernetes_deployment_v1" "registry" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "registry"

    labels = local.registry_labels
  }

  spec {
    replicas = 1

    # The volume is ReadWriteOnce, so a surged second pod could never mount it.
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = local.registry_labels
    }

    template {
      metadata {
        labels = local.registry_labels
      }

      spec {
        security_context {
          run_as_non_root = true
          run_as_user     = 65534
          run_as_group    = 65534
          fs_group        = 65534

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        container {
          name = "registry"

          image             = "${var.k8s_flux.registry.image}:${var.k8s_flux.registry.version}"
          image_pull_policy = "IfNotPresent"

          dynamic "env" {
            for_each = {
              REGISTRY_AUTH                = "htpasswd"
              REGISTRY_AUTH_HTPASSWD_REALM = "registry"
              REGISTRY_AUTH_HTPASSWD_PATH  = "/auth/htpasswd"

              # The gateway terminates TLS, so upload URLs must be built from
              # the public name rather than the plain-HTTP request.
              REGISTRY_HTTP_HOST = "https://${local.registry_hostname}"

              REGISTRY_STORAGE_DELETE_ENABLED = "true"
            }

            content {
              name  = env.key
              value = env.value
            }
          }

          port {
            name           = "http"
            container_port = local.registry_port
          }

          # /v2/ answers 401 without credentials; / is unauthenticated.
          readiness_probe {
            http_get {
              path = "/"
              port = "http"
            }

            period_seconds = 10
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "http"
            }

            initial_delay_seconds = 10
            period_seconds        = 20
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "64Mi"
            }

            limits = {
              memory = "256Mi"
            }
          }

          # runAsNonRoot is repeated from the pod: the provider sends false for
          # it when left unset here, which overrides the pod and fails the
          # namespace's restricted policy.
          security_context {
            run_as_non_root            = true
            allow_privilege_escalation = false
            read_only_root_filesystem  = true

            capabilities {
              drop = ["ALL"]
            }
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/registry"
          }

          volume_mount {
            name       = "auth"
            mount_path = "/auth"
            read_only  = true
          }

          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
          }
        }

        volume {
          name = "data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.registry[0].metadata[0].name
          }
        }

        volume {
          name = "auth"

          secret {
            secret_name = kubernetes_secret_v1.registry_htpasswd[0].metadata[0].name
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

resource "kubernetes_service_v1" "registry" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "registry"

    labels = local.registry_labels
  }

  spec {
    port {
      name        = "http"
      port        = local.registry_port
      target_port = "http"
    }

    selector = local.registry_labels
  }
}

resource "kubectl_manifest" "registry_route" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      namespace = local.namespace
      name      = "registry"
    }

    spec = {
      parentRefs = var.gateway_refs
      hostnames  = [local.registry_hostname]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/"
              }
            }
          ]
          backendRefs = [
            {
              name = kubernetes_service_v1.registry[0].metadata[0].name
              port = local.registry_port
            }
          ]
          # Envoy's 15s default would cut off large layer uploads.
          timeouts = {
            request = "300s"
          }
        }
      ]
    }
  })
}

# The FluxInstance's allow-egress policy only admits traffic from inside
# flux-system. The gateway's Envoy reaches the registry as Cilium's ingress
# identity, which no namespaceSelector matches, so this rule leaves the source
# open and relies on the registry's own authentication.
resource "kubernetes_network_policy_v1" "registry" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "allow-registry"
  }

  spec {
    pod_selector {
      match_labels = local.registry_labels
    }

    policy_types = ["Ingress"]

    ingress {
      ports {
        protocol = "TCP"
        port     = local.registry_port
      }
    }
  }

  depends_on = [kubectl_manifest.instance]
}

module "image_build" {
  source  = "../../_registry/flux_image_build"
  context = local.context

  namespace = local.namespace

  credentials = {
    host     = local.registry_hostname
    username = local.registry_username
    password = local.enabled ? random_password.registry[0].result : null
  }
}
