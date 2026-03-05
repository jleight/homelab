resource "kubectl_manifest" "ingress" {
  count = local.enabled && var.ingress_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      namespace = var.namespace
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
      hostnames = var.subdomain == null ? [] : [
        local.hostname
      ]
      rules = concat(
        [
          {
            matches = [
              {
                path = {
                  type  = "PathPrefix"
                  value = var.path
                }
              }
            ]
            backendRefs = [
              {
                name = local.service_name
                port = var.service_port
              }
            ]
          }
        ],
        var.ingress_extra_rules
      )
    }
  })
}
