resource "helm_release" "this" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = local.name
  repository = var.forgejo.repository
  chart      = var.forgejo.chart
  version    = var.forgejo.version

  dynamic "set" {
    for_each = {
      "gitea.admin.existingSecret"                     = local.admin_user_secret
      "gitea.config.database.DB_TYPE"                  = "postgres"
      "gitea.config.indexer.ISSUE_INDEXER_TYPE"        = "bleve"
      "gitea.config.indexer.REPO_INDEXER_ENABLED"      = true
      "gitea.config.repository.ENABLE_PUSH_CREATE_ORG" = true
      "gitea.config.server.DOMAIN"                     = local.hostname
      "gitea.config.server.ROOT_URL"                   = "https://${local.hostname}"
      "persistence.create"                             = false
      "persistence.claimName"                          = local.data_pvc_name
      "redis-cluster.enabled"                          = false
      "redis.enabled"                                  = true
      "redis.architecture"                             = "standalone"
      "redis.master.persistence.existingClaim"         = local.data_pvc_name
      "redis.master.persistence.subPath"               = "redis"
      "postgresql-ha.enabled"                          = false
      "postgresql.enabled"                             = true
      "postgresql.primary.persistence.existingClaim"   = local.data_pvc_name
      "postgresql.primary.persistence.subPath"         = "pgsql"
    }

    content {
      name  = set.key
      value = set.value
    }
  }
}
