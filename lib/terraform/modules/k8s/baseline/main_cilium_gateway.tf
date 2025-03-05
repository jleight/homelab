locals {
  cilium_gateway_crd_url_paths = local.cilium_gateway ? toset([
    "standard/gateway.networking.k8s.io_gatewayclasses.yaml",
    "standard/gateway.networking.k8s.io_gateways.yaml",
    "standard/gateway.networking.k8s.io_httproutes.yaml",
    "standard/gateway.networking.k8s.io_referencegrants.yaml",
    "standard/gateway.networking.k8s.io_grpcroutes.yaml",
    "experimental/gateway.networking.k8s.io_tlsroutes.yaml"
  ]) : []

  cilium_gateway_crd_yaml = local.cilium_gateway ? {
    for p in local.cilium_gateway_crd_url_paths : p => data.http.cilium_gateway_crd[p].response_body
  } : {}

  cilium_gateway_name = local.cilium_gateway ? kubectl_manifest.cilium_gateway[0].name : null
}

data "http" "cilium_gateway_crd" {
  for_each = local.cilium_gateway_crd_url_paths

  url = "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.0/config/crd/${each.value}"
}

resource "kubectl_manifest" "cilium_gateway_crd" {
  for_each = local.cilium_gateway_crd_yaml

  yaml_body = each.value
}

resource "kubectl_manifest" "cilium_gateway_lb_pool" {
  count = local.cilium_gateway ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumLoadBalancerIPPool"

    metadata = {
      name = "gateway"
    }

    spec = {
      blocks = [
        {
          start = "10.245.0.1"
          stop  = "10.245.0.254"
        }
      ]
    }
  })

  depends_on = [helm_release.cilium]
}

resource "kubectl_manifest" "cilium_gateway" {
  count = local.cilium_gateway ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"

    metadata = {
      namespace = local.cilium_namespace
      name      = "gateway"

      annotations = local.certmanager_enabled ? {
        "cert-manager.io/cluster-issuer" = local.certmanager_production_issuer
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
            hostname = "*.${var.k8s_cluster.subdomain}.${var.k8s_cluster.domain}"
            allowedRoutes = {
              namespaces = {
                from = "All"
              }
            }
          }
        ],
        local.certmanager_enabled ? [
          {
            name     = "https"
            protocol = "HTTPS"
            port     = 443
            hostname = "*.${var.k8s_cluster.subdomain}.${var.k8s_cluster.domain}"
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
                  name = "wildcard-${replace(var.k8s_cluster.domain, ".", "-")}"
                }
              ]
            }
          }
        ] : []
      )
    }
  })
}
