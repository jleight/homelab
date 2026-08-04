resource "random_password" "beacon_user" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "beacon_user" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-beacon-user"
  }

  data = {
    username = local.beacon_username
    password = local.beacon_password
  }
}

resource "kubectl_manifest" "beacon_db" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = local.namespace
      name      = "beacon"
    }

    spec = {
      cluster = {
        name = local.name
      }

      name   = "beacon"
      ensure = "present"
      owner  = local.beacon_username
    }
  })
}

output "beacon_username" {
  value = local.beacon_username
}

output "beacon_password" {
  value     = local.beacon_password
  sensitive = true
}
