resource "helm_release" "this" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = local.name
  repository = var.immich.repository
  chart      = var.immich.chart
  version    = var.immich.version

  set = [
    for k, v in {
      "image.tag"                                                = var.immich.immich_server.version
      "immich.persistence.library.existingClaim"                 = local.media_pvc_name
      "server.persistence.library.subPath"                       = "photos"
      "env.DB_HOSTNAME"                                          = "${local.name}-db-rw.${local.namespace}.svc.cluster.local"
      "env.DB_USERNAME"                                          = local.postgres_username
      "env.DB_DATABASE_NAME"                                     = "app"
      "env.DB_PASSWORD.secretKeyRef.name"                        = local.postgres_secret
      "env.DB_PASSWORD.secretKeyRef.key"                         = "password"
      "postgresql.global.postgresql.auth.existingSecret"         = local.postgres_secret
      "redis.enabled"                                            = true
      "machine-learning.image.tag"                               = "${var.immich.immich_server.version}-openvino"
      "machine-learning.resources.limits.gpu\\.intel\\.com/i915" = "1"
      "machine-learning.persistence.cache.type"                  = "pvc"
      "machine-learning.persistence.cache.existingClaim"         = local.media_pvc_name
      "machine-learning.persistence.cache.subPath"               = "photos/cache"
    } : { name = k, value = v }
  ]
}
