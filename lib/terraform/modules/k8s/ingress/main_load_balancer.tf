locals {
  load_balancer_enabled = local.enabled && var.k8s_ingress.load_balancer.enabled

  load_balancer_namespace = local.enabled ? kubernetes_namespace.load_balancer[0].metadata[0].name : ""
  load_balancer_name      = local.enabled ? "load-balancer" : ""
  load_balancer_domain    = local.enabled ? var.k8s_cluster_domain : ""
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
      namespace = local.load_balancer_namespace
      name      = local.load_balancer_name

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
            hostname = "*.${local.load_balancer_domain}"
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
            hostname = "*.${local.load_balancer_domain}"
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
                  name = "wildcard-${replace(local.load_balancer_domain, ".", "-")}"
                }
              ]
            }
          }
        ] : []
      )
    }
  })
}
