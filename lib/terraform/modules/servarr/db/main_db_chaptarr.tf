resource "random_password" "chaptarr_user" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "chaptarr_user" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-chaptarr-user"
  }

  data = {
    username = local.chaptarr_username
    password = local.chaptarr_password
  }
}

resource "kubectl_manifest" "chaptarr_main_db" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = local.namespace
      name      = local.chaptarr_main_db
    }

    spec = {
      cluster = {
        name = local.name
      }

      name   = local.chaptarr_main_db
      ensure = "present"
      owner  = local.chaptarr_username
    }
  })
}

resource "kubectl_manifest" "chaptarr_log_db" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = local.namespace
      name      = local.chaptarr_log_db
    }

    spec = {
      cluster = {
        name = local.name
      }

      name   = local.chaptarr_log_db
      ensure = "present"
      owner  = local.chaptarr_username
    }
  })
}

resource "kubectl_manifest" "chaptarr_cache_db" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = local.namespace
      name      = local.chaptarr_cache_db
    }

    spec = {
      cluster = {
        name = local.name
      }

      name   = local.chaptarr_cache_db
      ensure = "present"
      owner  = local.chaptarr_username
    }
  })
}

output "chaptarr_username" {
  value = local.chaptarr_username
}

output "chaptarr_password" {
  value     = local.chaptarr_password
  sensitive = true
}

output "chaptarr_main_db" {
  value = local.chaptarr_main_db
}

output "chaptarr_log_db" {
  value = local.chaptarr_log_db
}

output "chaptarr_cache_db" {
  value = local.chaptarr_cache_db
}
