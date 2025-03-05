locals {
  httpbin       = local.enabled && var.k8s_cluster.httpbin > 0
  httpbin_count = local.httpbin ? var.k8s_cluster.httpbin : 0

  httpbin_namespace = local.httpbin ? one(kubernetes_namespace.httpbin[0].metadata).name : null
}

resource "kubernetes_namespace" "httpbin" {
  count = local.httpbin ? 1 : 0

  metadata {
    name = "httpbin-test"
  }
}

resource "kubernetes_service_account" "httpbin" {
  count = local.httpbin_count

  metadata {
    namespace = local.httpbin_namespace
    name      = "httpbin-v${count.index + 1}"
  }
}

resource "kubernetes_service" "httpbin" {
  count = local.httpbin_count

  metadata {
    namespace = local.httpbin_namespace
    name      = "httpbin-v${count.index + 1}"

    labels = {
      app     = "httpbin"
      service = "httpbin-v${count.index + 1}"
    }
  }

  spec {
    port {
      name        = "http"
      port        = 8000
      target_port = 80
    }

    selector = {
      app     = "httpbin"
      version = "v${count.index + 1}"
    }
  }
}

resource "kubernetes_deployment" "httpbin" {
  count = local.httpbin_count

  metadata {
    namespace = local.httpbin_namespace
    name      = "httpbin-v${count.index + 1}"
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
          app     = "httpbin"
          version = "v${count.index + 1}"
        }
      }

      spec {
        service_account_name = one(kubernetes_service_account.httpbin[count.index].metadata).name

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
}

resource "kubectl_manifest" "httpbin_httproute" {
  count = local.httpbin ? 1 : 0

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
          namespace = local.cilium_namespace
          name      = local.cilium_gateway_name
        }
      ]
      hostnames = [
        "httpbin.${var.k8s_cluster.subdomain}.${var.k8s_cluster.domain}"
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
              name = "httpbin-v1"
              port = 8000
            }
          ]
        }
      ]
    }
  })
}
