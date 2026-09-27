resource "kubectl_manifest" "this" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"

    metadata = {
      namespace = local.namespace
      name      = local.name
    }

    spec = {
      instances = 2

      primaryUpdateStrategy = "unsupervised"

      storage = {
        storageClass = var.data_storage_class
        size         = "5Gi"
      }

      bootstrap = {
        initdb = {
          owner = local.admin_username
          secret = {
            name = local.admin_secret
          }
        }
      }

      managed = {
        roles = [
          {
            name   = local.pgtt_username
            ensure = "present"
            login  = true
            passwordSecret = {
              name = local.pgtt_secret
            }
          }
        ]
      }
    }
  })
}
