resource "kubectl_manifest" "database" {
  for_each = var.managed_databases

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = var.namespace
      name      = each.key
    }

    spec = {
      cluster = {
        name = kubectl_manifest.this.name
      }

      name   = each.key
      ensure = "present"
      owner  = each.key
    }
  })
}
