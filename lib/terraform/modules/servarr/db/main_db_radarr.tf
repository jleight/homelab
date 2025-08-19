resource "random_password" "radarr_user" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret" "radarr_user" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-radarr-user"
  }

  data = {
    username = local.radarr_username
    password = local.radarr_password
  }
}

resource "kubectl_manifest" "radarr_main_db" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = local.namespace
      name      = "radarr-main"
    }

    spec = {
      cluster = {
        name = local.name
      }

      name   = "radarr-main"
      ensure = "present"
      owner  = local.radarr_username
    }
  })
}

resource "kubectl_manifest" "radarr_log_db" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = local.namespace
      name      = "radarr-log"
    }

    spec = {
      cluster = {
        name = local.name
      }

      name   = "radarr-log"
      ensure = "present"
      owner  = local.radarr_username
    }
  })
}

output "radarr_username" {
  value = local.radarr_username
}

output "radarr_password" {
  value     = local.radarr_password
  sensitive = true
}
