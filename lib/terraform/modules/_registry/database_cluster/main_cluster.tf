resource "kubectl_manifest" "this" {
  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"

    metadata = {
      namespace = var.namespace
      name      = local.cluster_name
    }

    spec = merge(
      {
        instances = var.instances

        primaryUpdateStrategy = "unsupervised"

        # Default 180s waits for long-lived clients to disconnect before a
        # switchover, refusing new connections the whole time (e.g. node drains).
        smartShutdownTimeout = 15

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
      },
      # Only clusters that use either get the block, so the others see no diff.
      length(var.extension_images) > 0 || length(var.shared_preload_libraries) > 0 ? {
        postgresql = {
          shared_preload_libraries = var.shared_preload_libraries

          extensions = [
            for name, ext in var.extension_images : merge(
              {
                name  = name
                image = { reference = ext.image }
              },
              ext.dynamic_library_path != null ? {
                dynamic_library_path = ext.dynamic_library_path
              } : {},
              ext.extension_control_path != null ? {
                extension_control_path = ext.extension_control_path
              } : {}
            )
          ]
        }
      } : {}
    )
  })
}
