resource "kubectl_manifest" "ingress" {
  for_each = local.enabled ? var.reverse_proxy.services : {}

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      namespace = local.namespace
      name      = replace(each.key, "_", "-")
    }

    spec = {
      parentRefs = [
        {
          namespace   = var.gateway_namespace
          name        = each.value.public ? var.public_gateway_name : var.private_gateway_name
          sectionName = var.gateway_section
        }
      ]
      hostnames = [
        "${each.value.frontend_subdomain}.${var.gateway_domain}"
      ]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = each.value.frontend_path
              }
            }
          ]
          backendRefs = [
            {
              name = module.app.service_name
              port = 8080
            }
          ]
        }
      ]
    }
  })
}
