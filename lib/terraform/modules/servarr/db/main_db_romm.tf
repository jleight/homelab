resource "random_password" "romm_user" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "romm_user" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-romm-user"
  }

  data = {
    username = local.romm_username
    password = local.romm_password
  }
}

resource "kubectl_manifest" "romm_db" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = local.namespace
      name      = "romm"
    }

    spec = {
      cluster = {
        name = local.name
      }

      name   = "romm"
      ensure = "present"
      owner  = local.romm_username
    }
  })
}

output "romm_username" {
  value = local.romm_username
}

output "romm_password" {
  value     = local.romm_password
  sensitive = true
}
