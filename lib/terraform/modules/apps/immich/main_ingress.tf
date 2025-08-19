resource "kubectl_manifest" "ingress_public_tunnel_binding" {
  count = local.ingress_public_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "networking.cfargotunnel.com/v1alpha1"
    kind       = "TunnelBinding"

    metadata = {
      name = local.name
    }

    tunnelRef = {
      kind = var.tunnel_kind
      name = var.tunnel_name
    }

    subjects = [
      {
        name = local.service_name
        spec = {
          target = "http://${local.service_name}.${local.namespace}.svc.cluster.local:${local.port}"
          fqdn   = "${var.immich.subdomain}.${var.gateway_domain}"
        }
      }
    ]
  })
}

resource "kubectl_manifest" "ingress_private_http_route" {
  count = local.ingress_private_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      namespace = local.namespace
      name      = local.name
    }

    spec = {
      parentRefs = [
        {
          namespace   = var.gateway_namespace
          name        = var.gateway_name
          sectionName = var.gateway_section
        }
      ]
      hostnames = [
        "${var.immich.subdomain}.${var.gateway_domain}"
      ]
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
              name = local.service_name
              port = local.port
            }
          ]
        }
      ]
    }
  })
}
