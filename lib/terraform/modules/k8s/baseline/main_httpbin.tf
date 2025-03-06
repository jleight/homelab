locals {
  httpbin_count   = try(var.k8s_cluster.httpbin.count, 0)
  httpbin_enabled = local.enabled && local.httpbin_count > 0

  httpbin_namespace        = local.httpbin_enabled ? var.k8s_cluster.httpbin.namespace : ""
  httpbin_create_namespace = local.httpbin_enabled && !contains(local.default_k8s_namespaces, local.httpbin_namespace)
}

resource "kubernetes_namespace" "httpbin" {
  count = local.httpbin_create_namespace ? 1 : 0

  metadata {
    name = local.httpbin_namespace
  }
}

resource "kubernetes_service_account" "httpbin" {
  count = local.httpbin_count

  metadata {
    namespace = local.httpbin_namespace
    name      = "httpbin-${count.index}"
  }

  depends_on = [kubernetes_namespace.httpbin]
}

resource "kubernetes_service" "httpbin" {
  count = local.httpbin_count

  metadata {
    namespace = local.httpbin_namespace
    name      = "httpbin-${count.index}"

    labels = {
      app     = "httpbin"
      service = "httpbin-${count.index}"
    }
  }

  spec {
    port {
      name        = "http"
      port        = 8000
      target_port = 80
    }

    selector = {
      app      = "httpbin"
      instance = count.index
    }
  }

  depends_on = [kubernetes_namespace.httpbin]
}

resource "kubernetes_deployment" "httpbin" {
  count = local.httpbin_count

  metadata {
    namespace = local.httpbin_namespace
    name      = "httpbin-${count.index}"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "httpbin"
      }
    }

    template {
      metadata {
        labels = {
          app      = "httpbin"
          instance = count.index
        }
      }

      spec {
        service_account_name = local.httpbin_enabled ? one(kubernetes_service_account.httpbin[count.index].metadata).name : null

        container {
          name = "httpbin"

          image             = "docker.io/kennethreitz/httpbin"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 80
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.httpbin]
}

resource "kubectl_manifest" "httpbin_httproute" {
  count = local.httpbin_enabled && local.gateway_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      namespace = local.httpbin_namespace
      name      = "http-route"
    }

    spec = {
      parentRefs = [
        {
          namespace = local.gateway_namespace
          name      = local.gateway_name
        }
      ]
      hostnames = [
        "httpbin.${var.k8s_cluster.domain}"
      ]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "/get"
              }
            }
          ]
          backendRefs = [
            {
              name = "httpbin-0"
              port = 8000
            }
          ]
        }
      ]
    }
  })

  depends_on = [
    helm_release.cilium,
    kubernetes_namespace.httpbin
  ]
}
