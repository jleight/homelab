resource "kubectl_manifest" "database" {
  for_each = local.databases

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
        owner  = each.value.owner
      },
      length(each.value.extensions) > 0 ? {
        extensions = [
          for name in each.value.extensions : merge(
            {
              name   = name
              ensure = "present"
            },
            # Pinning the version is what upgrades an extension in place when its image changes.
            contains(keys(var.extension_images), name) ? {
              version = var.extension_images[name].version
            } : {}
          )
        ]
      } : {}
    )
  })
}
