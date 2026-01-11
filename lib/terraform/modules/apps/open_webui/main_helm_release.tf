resource "kubernetes_namespace_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    name = "open-webui"
  }
}

resource "random_password" "openai_api_key" {
  count = local.enabled ? 1 : 0

  length  = 32
  special = false
}

resource "helm_release" "this" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = local.name
  repository = var.open_webui.repository
  chart      = var.open_webui.chart
  version    = var.open_webui.version

  set = [
    for k, v in {
      "openaiBaseApiUrl"                            = "http://fwd01.leightha.us:1234/v1"
      "openaiApiKey"                                = random_password.openai_api_key[0].result
      "image.tag"                                   = "main"
      "image.pullPolicy"                            = "Always"
      "ollama.enabled"                              = false
      "persistence.accessModes[0]"                  = "ReadWriteMany"
      "persistence.storageClass"                    = var.data_storage_class
      "extraEnvVars[0].name"                        = "DATABASE_TYPE"
      "extraEnvVars[0].value"                       = "postgresql"
      "extraEnvVars[1].name"                        = "DATABASE_USER"
      "extraEnvVars[1].value"                       = local.postgres_username
      "extraEnvVars[2].name"                        = "DATABASE_PASSWORD"
      "extraEnvVars[2].valueFrom.secretKeyRef.name" = local.postgres_secret
      "extraEnvVars[2].valueFrom.secretKeyRef.key"  = "password"
      "extraEnvVars[3].name"                        = "DATABASE_HOST"
      "extraEnvVars[3].value"                       = "${local.name}-db.${local.namespace}.svc.cluster.local"
      "extraEnvVars[4].name"                        = "DATABASE_NAME"
      "extraEnvVars[4].value"                       = "app"
    } : { name = k, value = v }
  ]
}
