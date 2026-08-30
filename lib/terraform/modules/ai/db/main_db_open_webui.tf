resource "random_password" "open_webui_user" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "open_webui_user" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-open-webui-user"
  }

  data = {
    username = local.open_webui_username
    password = local.open_webui_password
  }
}

resource "kubectl_manifest" "open_webui_db" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = local.namespace
      name      = "openwebui"
    }

    spec = {
      cluster = {
        name = local.name
      }

      name   = "openwebui"
      ensure = "present"
      owner  = local.open_webui_username

      # Open WebUI keeps its application data and its RAG vectors in the same
      # database, and only ever runs `CREATE EXTENSION vector` from inside an
      # `IF NOT EXISTS` guard. `vector` is not a trusted extension, so the
      # owning role could not create it anyway; the operator does it as
      # superuser and the app's guard then short-circuits. The cluster's
      # default CNPG image already ships pgvector (0.8.4).
      extensions = [
        {
          name   = "vector"
          ensure = "present"
        }
      ]
    }
  })
}

output "open_webui_username" {
  value = local.open_webui_username
}

output "open_webui_password" {
  value     = local.open_webui_password
  sensitive = true
}
