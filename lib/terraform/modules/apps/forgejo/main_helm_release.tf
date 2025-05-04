resource "helm_release" "this" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = local.name
  repository = var.forgejo.repository
  chart      = var.forgejo.chart
  version    = var.forgejo.version

  dynamic "set" {
    for_each = {
      "gitea.additionalConfigFromEnvs[0].name"                        = "FORGEJO__DATABASE__PASSWD"
      "gitea.additionalConfigFromEnvs[0].valueFrom.secretKeyRef.key"  = "password"
      "gitea.additionalConfigFromEnvs[0].valueFrom.secretKeyRef.name" = local.postgres_secret
      "gitea.admin.existingSecret"                                    = local.admin_user_secret
      "gitea.config.database.DB_TYPE"                                 = "postgres"
      "gitea.config.database.HOST"                                    = "${local.name}-db-rw.${local.namespace}.svc.cluster.local:5432"
      "gitea.config.database.NAME"                                    = "app"
      "gitea.config.database.SCHEMA"                                  = "public"
      "gitea.config.database.USER"                                    = local.postgres_username
      "gitea.config.indexer.ISSUE_INDEXER_TYPE"                       = "bleve"
      "gitea.config.indexer.REPO_INDEXER_ENABLED"                     = true
      "gitea.config.repository.ENABLE_PUSH_CREATE_ORG"                = true
      "gitea.config.server.DOMAIN"                                    = local.hostname
      "gitea.config.server.ROOT_URL"                                  = "https://${local.hostname}"
      "persistence.storageClass"                                      = var.data_storage_class
      "postgresql-ha.enabled"                                         = false
      "postgresql.enabled"                                            = false
      "redis-cluster.enabled"                                         = false
      "redis.architecture"                                            = "standalone"
      "redis.enabled"                                                 = true
      "redis.master.persistence.enabled"                              = false
    }

    content {
      name  = set.key
      value = set.value
    }
  }
}
