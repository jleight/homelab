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
      parentRefs = var.gateway_refs
      hostnames  = local.hostnames
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
              name = kubernetes_service_v1.this[0].metadata[0].name
              port = 80
            }
          ]
        }
      ]
    }
  })
}
