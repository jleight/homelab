locals {
  gateway_version = try(var.k8s_cluster.gateway.version, null)
  gateway_enabled = local.enabled && local.gateway_version != null

  gateway_namespace        = local.gateway_enabled ? var.k8s_cluster.gateway.namespace : ""
  gateway_create_namespace = local.gateway_enabled && !contains(local.default_k8s_namespaces, local.gateway_namespace)

  gateway_name = local.gateway_enabled ? "gateway" : null

  gateway_install       = local.gateway_enabled ? var.k8s_cluster.gateway.install : null
  gateway_lb_pool_start = local.gateway_enabled ? cidrhost(module.ipam.resources.load_balancers, 1) : null
  gateway_lb_pool_stop  = local.gateway_enabled ? cidrhost(module.ipam.resources.load_balancers, -2) : null

  gateway_crds_url = format(
    "https://github.com/kubernetes-sigs/gateway-api/releases/download/%s/%s-install.yaml",
    local.gateway_version,
    local.gateway_install
  )

  gateway_crds_manifest = local.gateway_enabled ? data.http.gateway_crds[0].response_body : null
  gateway_crd_manifests = local.gateway_enabled ? data.kubectl_file_documents.gateway_crds[0].manifests : {}
}

data "http" "gateway_crds" {
  count = local.gateway_enabled ? 1 : 0

  url = local.gateway_crds_url
}

data "kubectl_file_documents" "gateway_crds" {
  count = local.gateway_enabled ? 1 : 0

  content = local.gateway_crds_manifest
}

resource "kubectl_manifest" "gateway_crds" {
  for_each = local.gateway_crd_manifests

  yaml_body = each.value
}

resource "kubernetes_namespace" "gateway" {
  count = local.gateway_create_namespace ? 1 : 0

  metadata {
    name = local.gateway_namespace
  }
}

resource "kubectl_manifest" "gateway_lb_pool" {
  count = local.gateway_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumLoadBalancerIPPool"

    metadata = {
      name = "gateway"
    }

    spec = {
      blocks = [
        {
          start = local.gateway_lb_pool_start
          stop  = local.gateway_lb_pool_stop
        }
      ]
    }
  })

  depends_on = [helm_release.cilium]
}

resource "kubectl_manifest" "gateway_gateway" {
  count = local.gateway_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"

    metadata = {
      namespace = local.gateway_namespace
      name      = local.gateway_name

      annotations = local.certmanager_enabled ? {
        "cert-manager.io/cluster-issuer" = local.certmanager_issuer
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
            hostname = "*.${var.k8s_cluster.domain}"
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
            hostname = "*.${var.k8s_cluster.domain}"
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

  depends_on = [
    helm_release.certmanager,
    kubernetes_namespace.gateway
  ]
}
