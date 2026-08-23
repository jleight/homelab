resource "random_password" "anything_llm_user" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "anything_llm_user" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-anything-llm-user"
  }

  data = {
    username = local.anything_llm_username
    password = local.anything_llm_password
  }
}

resource "kubectl_manifest" "anything_llm_db" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = local.namespace
      name      = "anythingllm"
    }

    spec = {
      cluster = {
        name = local.name
      }

      name   = "anythingllm"
      ensure = "present"
      owner  = local.anything_llm_username

      # AnythingLLM's `pg` image stores both its application data and its
      # vectors in Postgres, and expects pgvector to already exist -- it does
      # not create the extension itself. `vector` is not a trusted extension,
      # so the owning role cannot create it either; the operator does it as
      # superuser. The cluster's default CNPG image already ships pgvector
      # (0.8.4), so no custom imageName is needed.
      extensions = [
        {
          name   = "vector"
          ensure = "present"
        }
      ]
    }
  })
}

output "anything_llm_username" {
  value = local.anything_llm_username
}

output "anything_llm_password" {
  value     = local.anything_llm_password
  sensitive = true
}
