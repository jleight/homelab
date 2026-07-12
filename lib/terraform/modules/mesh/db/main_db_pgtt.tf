resource "random_password" "pgtt_user" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "pgtt_user" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-pgtt-user"
  }

  data = {
    username = local.pgtt_username
    password = local.pgtt_password
  }
}

resource "kubectl_manifest" "pgtt_db" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = local.namespace
      name      = "pgtt"
    }

    spec = {
      cluster = {
        name = local.name
      }

      name   = "pgtt"
      ensure = "present"
      owner  = local.pgtt_username
    }
  })
}

output "pgtt_username" {
  value = local.pgtt_username
}

output "pgtt_password" {
  value     = local.pgtt_password
  sensitive = true
}
