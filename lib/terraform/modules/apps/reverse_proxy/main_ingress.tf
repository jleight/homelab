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
      parentRefs = each.value.public ? var.public_https_refs : var.private_https_refs
      hostnames  = ["${each.value.frontend_subdomain}.${var.gateway_domain}"]
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
