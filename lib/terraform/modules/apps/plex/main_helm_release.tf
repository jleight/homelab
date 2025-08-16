locals {
  affinity_prefix = "affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution[0]"
}

resource "helm_release" "this" {
  count = local.enabled ? 1 : 0

  namespace  = local.namespace
  name       = local.name
  repository = var.plex.repository
  chart      = var.plex.chart
  version    = var.plex.version

  set = [
    for k, v in {
      "image.tag"                                       = var.plex.plex_image.version
      "pms.storageClassName"                            = var.data_storage_class
      "pms.claimSecret.name"                            = local.claim_secret_name
      "pms.claimSecret.key"                             = "claim"
      "pms.claimSecret.value"                           = "true" # bug in helm chart
      "extraVolumes[0].name"                            = "media"
      "extraVolumes[0].persistentVolumeClaim.claimName" = local.media_pvc_name
      "extraVolumeMounts[0].name"                       = "media"
      "extraVolumeMounts[0].mountPath"                  = "/media"

      "${local.affinity_prefix}.weight"                                   = "1"
      "${local.affinity_prefix}.preference.matchExpressions[0].key"       = "kubernetes.io/hostname"
      "${local.affinity_prefix}.preference.matchExpressions[0].operator"  = "In"
      "${local.affinity_prefix}.preference.matchExpressions[0].values[0]" = var.plex.node_name
    } : { name = k, value = v }
  ]
}
