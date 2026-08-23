resource "random_password" "bifrost_user" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "bifrost_user" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-bifrost-user"
  }

  data = {
    username = local.bifrost_username
    password = local.bifrost_password
  }
}

resource "kubectl_manifest" "bifrost_db" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = local.namespace
      name      = "bifrost"
    }

    spec = {
      cluster = {
        name = local.name
      }

      name   = "bifrost"
      ensure = "present"
      owner  = local.bifrost_username
    }
  })
}

output "bifrost_username" {
  value = local.bifrost_username
}

output "bifrost_password" {
  value     = local.bifrost_password
  sensitive = true
}
