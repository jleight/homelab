locals {
  load_balancer_enabled = local.enabled && var.k8s_ingress.load_balancer.enabled
}

resource "kubernetes_namespace" "load_balancer" {
  count = local.load_balancer_enabled ? 1 : 0

  metadata {
    name = "load-balancer"
  }
}

resource "kubectl_manifest" "load_balancer_pool" {
  count = local.load_balancer_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumLoadBalancerIPPool"

    metadata = {
      name = "gateway"
    }

    spec = {
      blocks = [
        {
          start = cidrhost(module.ipam.resources.load_balancers, 1)
          stop  = cidrhost(module.ipam.resources.load_balancers, -2)
        }
      ]
    }
  })
}

resource "kubectl_manifest" "load_balancer" {
  count = local.load_balancer_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"

    metadata = {
      namespace = try(one(kubernetes_namespace.load_balancer[0].metadata).name, null)
      name      = "load-balancer"

      annotations = local.cert_manager_enabled ? {
        "cert-manager.io/cluster-issuer" = "lets-encrypt"
      } : {}
    }

    spec = {
      gatewayClassName = "cilium"
      listeners = concat(
        [
          {
            name     = "http"
            protocol = "HTTP"
            port     = 80
            hostname = "*.${var.k8s_cluster_domain}"
            allowedRoutes = {
              namespaces = {
                from = "All"
              }
            }
          }
        ],
        local.cert_manager_enabled ? [
          {
            name     = "https"
            protocol = "HTTPS"
            port     = 443
            hostname = "*.${var.k8s_cluster_domain}"
            allowedRoutes = {
              namespaces = {
                from = "All"
              }
            }
            tls = {
              mode = "Terminate"
              certificateRefs = [
                {
                  kind = "Secret"
                  name = "wildcard-${replace(var.k8s_cluster_domain, ".", "-")}"
                }
              ]
            }
          }
        ] : []
      )
    }
  })
}
