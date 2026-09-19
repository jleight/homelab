resource "kubectl_manifest" "this" {
  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"

    metadata = {
      namespace = var.namespace
      name      = local.cluster_name
    }

    spec = {
      instances = var.instances

      primaryUpdateStrategy = "unsupervised"

      storage = {
        storageClass = var.data_storage_class
        size         = var.storage
      }

      bootstrap = {
        initdb = {
          owner = "app"
          secret = {
            name = kubernetes_secret_v1.credentials["app"].metadata[0].name
          }
        }
      }

      managed = {
        roles = [
          for k, v in var.managed_databases : {
            name   = k
            ensure = "present"
            login  = true
            passwordSecret = {
              name = kubernetes_secret_v1.credentials[k].metadata[0].name
            }
          }
        ]
      }
    }
  })
}
