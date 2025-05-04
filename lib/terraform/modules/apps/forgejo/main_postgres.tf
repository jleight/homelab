resource "random_pet" "postgres_user" {
  count = local.enabled ? 1 : 0
}

resource "random_password" "postgres_user" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret" "postgres" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-postgres"
  }

  data = {
    username = local.postgres_username
    password = local.postgres_password
  }
}

resource "kubectl_manifest" "postgres" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"

    metadata = {
      namespace = local.namespace
      name      = "${local.name}-db"
    }

    spec = {
      instances = 2

      primaryUpdateStrategy = "unsupervised"

      storage = {
        storageClass = var.data_storage_class
        size         = "1Gi"
      }

      bootstrap = {
        initdb = {
          owner = local.postgres_username
          secret = {
            name = local.postgres_secret
          }
        }
      }
    }
  })
}
