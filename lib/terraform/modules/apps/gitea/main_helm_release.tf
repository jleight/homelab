resource "helm_release" "this" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = local.name
  repository = var.gitea.repository
  chart      = var.gitea.chart
  version    = var.gitea.version

  dynamic "set" {
    for_each = {
      "gitea.admin.existingSecret"                   = local.admin_user_secret
      "gitea.config.database.DB_TYPE"                = "postgres"
      "gitea.config.indexer.ISSUE_INDEXER_TYPE"      = "bleve"
      "gitea.config.indexer.REPO_INDEXER_ENABLED"    = true
      "persistence.create"                           = false
      "persistence.claimName"                        = local.data_pvc_name
      "redis-cluster.enabled"                        = false
      "redis.enabled"                                = true
      "redis.architecture"                           = "standalone"
      "redis.master.persistence.existingClaim"       = local.data_pvc_name
      "redis.master.persistence.subPath"             = "redis"
      "postgresql-ha.enabled"                        = false
      "postgresql.enabled"                           = true
      "postgresql.primary.persistence.existingClaim" = local.data_pvc_name
      "postgresql.primary.persistence.subPath"       = "pgsql"
      "deployment.env[0].name"                       = "GITEA__SERVER__DOMAIN"
      "deployment.env[0].value"                      = local.hostname
      "deployment.env[1].name"                       = "GITEA__SERVER__ROOT_URL"
      "deployment.env[1].value"                      = "https://${local.hostname}"
    }

    content {
      name  = set.key
      value = set.value
    }
  }
}
