resource "kubectl_manifest" "ingress_http" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      namespace = local.namespace
      name      = local.name
    }

    spec = {
      parentRefs = var.gateway_refs
      hostnames  = [local.hostname]
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
              name = "${local.name}-server"
              port = 80
            }
          ]
        }
      ]
    }
  })
}
