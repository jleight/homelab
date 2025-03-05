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
