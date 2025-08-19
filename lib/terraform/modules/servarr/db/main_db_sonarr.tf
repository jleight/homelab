resource "random_password" "sonarr_user" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret" "sonarr_user" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-sonarr-user"
  }

  data = {
    username = local.sonarr_username
    password = local.sonarr_password
  }
}

resource "kubectl_manifest" "sonarr_main_db" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = local.namespace
      name      = "sonarr-main"
    }

    spec = {
      cluster = {
        name = local.name
      }

      name   = "sonarr-main"
      ensure = "present"
      owner  = local.sonarr_username
    }
  })
}

resource "kubectl_manifest" "sonarr_log_db" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = local.namespace
      name      = "sonarr-log"
    }

    spec = {
      cluster = {
        name = local.name
      }

      name   = "sonarr-log"
      ensure = "present"
      owner  = local.sonarr_username
    }
  })
}

output "sonarr_username" {
  value = local.sonarr_username
}

output "sonarr_password" {
  value     = local.sonarr_password
  sensitive = true
}
