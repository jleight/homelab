resource "kubectl_manifest" "database" {
  for_each = var.managed_databases

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = var.namespace
      name      = each.key
    }

    spec = merge(
      {
        cluster = {
          name = kubectl_manifest.this.name
        }

        name   = each.key
        ensure = "present"
        owner  = each.key
      },
      length(each.value.extensions) > 0 ? {
        extensions = [
          for name in each.value.extensions : {
            name   = name
            ensure = "present"
          }
        ]
      } : {}
    )
  })
}
