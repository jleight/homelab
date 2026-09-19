resource "kubectl_manifest" "this" {
  count = local.create ? 1 : 0

  server_side_apply = true

  yaml_body = yamlencode({
    apiVersion = "source.toolkit.fluxcd.io/v1"
    kind       = "GitRepository"

    metadata = {
      namespace = local.namespace
      name      = local.name
    }

    spec = {
      interval = "1h"
      url      = local.url

      ref = {
        branch = local.branch
      }

      secretRef = {
        name = local.name
      }
    }
  })
}
