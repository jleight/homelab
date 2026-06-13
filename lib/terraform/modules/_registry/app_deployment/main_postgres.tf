resource "random_pet" "postgres_username" {
  count = local.enabled && var.postgres_enabled ? 1 : 0
}

resource "random_password" "postgres_password" {
  count = local.enabled && var.postgres_enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "postgres" {
  count = local.enabled && var.postgres_enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = "${local.name}-postgres"
  }

  data = merge(
    {
      username = local.postgres_username
      password = local.postgres_password
      url      = local.postgres_url
    },
    var.postgres_extra_secret_data
  )
}

resource "kubectl_manifest" "postgres" {
  count = local.enabled && var.postgres_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"

    metadata = {
      namespace = var.namespace
      name      = "${local.name}-db"
    }

    spec = merge(
      {
        instances = var.postgres_instances

        primaryUpdateStrategy = "unsupervised"

        storage = {
          storageClass = var.postgres_storage_class
          size         = var.postgres_storage_size
        }

        bootstrap = {
          initdb = merge(
            {
              owner = local.postgres_username
              secret = {
                name = local.postgres_secret_name
              }
            },
            length(var.postgres_post_init_sql) > 0 ? {
              postInitSQL = var.postgres_post_init_sql
            } : {}
          )
        }
      },
      var.postgres_image_name != null ? {
        imageName = var.postgres_image_name
      } : {},
      length(var.postgres_shared_preload_libraries) > 0 ? {
        postgresql = {
          shared_preload_libraries = var.postgres_shared_preload_libraries
        }
      } : {}
    )
  })
}
