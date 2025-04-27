resource "kubectl_manifest" "ingress" {
  count = local.enabled ? 1 : 0

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
          namespace = var.gateway_namespace
          name      = var.gateway_name
        }
      ]
      hostnames = [
        local.hostname
      ]
      rules = [
        {
          matches = [
            {
              path = {
                type  = "Exact"
                value = local.path
              }
            }
          ]
          filters = [
            {
              type = "RequestRedirect"
              requestRedirect = {
                path = {
                  type            = "ReplaceFullPath"
                  replaceFullPath = "${local.path}/"
                }
                statusCode = 302
              }
            }
          ]
        },
        {
          matches = [
            {
              path = {
                type  = "PathPrefix"
                value = "${local.path}/"
              }
            }
          ]
          backendRefs = [
            {
              name = local.service_name
              port = 80
            }
          ]
        }
      ]
    }
  })
}
