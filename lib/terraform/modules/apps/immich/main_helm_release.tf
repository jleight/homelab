locals {
  cmcm = "controllers.main.containers.main"
}

resource "helm_release" "this" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = local.name
  repository = var.immich.repository
  chart      = var.immich.chart
  version    = var.immich.version

  set = [
    for k, v in {
      "${local.cmcm}.image.tag"                                                = var.immich.immich_server.version
      "${local.cmcm}.env.REDIS_HOSTNAME"                                       = "${local.name}-cache.${local.namespace}.svc.cluster.local"
      "immich.persistence.library.existingClaim"                               = local.media_pvc_name
      "server.${local.cmcm}.env.DB_HOSTNAME"                                   = "${local.name}-db-rw.${local.namespace}.svc.cluster.local"
      "server.${local.cmcm}.env.DB_USERNAME"                                   = local.postgres_username
      "server.${local.cmcm}.env.DB_DATABASE_NAME"                              = "app"
      "server.${local.cmcm}.env.DB_PASSWORD.secretKeyRef.name"                 = local.postgres_secret
      "server.${local.cmcm}.env.DB_PASSWORD.secretKeyRef.key"                  = "password"
      "server.persistence.data.advancedMounts.main.main.0.subPath"             = "photos"
      "machine-learning.${local.cmcm}.image.tag"                               = "${var.immich.immich_server.version}-openvino"
      "machine-learning.${local.cmcm}.resources.limits.gpu\\.intel\\.com/i915" = "1"
      "machine-learning.persistence.cache.type"                                = "persistentVolumeClaim"
      "machine-learning.persistence.cache.existingClaim"                       = local.media_pvc_name
      "machine-learning.persistence.cache.advancedMounts.main.main.0.subPath"  = "photos/cache"
    } : { name = k, value = v }
  ]
}
