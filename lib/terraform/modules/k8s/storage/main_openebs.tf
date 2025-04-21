locals {
  openebs_enabled = local.enabled && var.k8s_storage.openebs.enabled
}

resource "helm_release" "openebs" {
  count = local.openebs_enabled ? 1 : 0

  namespace        = "openebs"
  create_namespace = true
  name             = "openebs"
  repository       = var.k8s_storage.openebs.repository
  chart            = var.k8s_storage.openebs.chart
  version          = var.k8s_storage.openebs.version

  dynamic "set" {
    for_each = {
      "mayastor.csi.node.initContainers.enabled" = false
      "engines.local.lvm.enabled"                = false
      "engines.local.zfs.enabled"                = false
      "engines.replicated.mayastor.enabled"      = false
      "mayastor.io_engine.envcontext"            = "iova-mode=pa"
    }

    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "kubernetes_storage_class" "openebs" {
  count = local.openebs_enabled ? 1 : 0

  metadata {
    name = "openebs-storage"

    annotations = {
      "openebs.io/cas-type" = "local"
      "cas.openebs.io/config" = yamlencode([
        {
          name  = "StorageType"
          value = "hostpath"
        },
        {
          name  = "BasePath"
          value = "/var/mnt/storage"
        }
      ])
    }
  }

  storage_provisioner = "openebs.io/local"

  volume_binding_mode    = "WaitForFirstConsumer"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true

  depends_on = [helm_release.openebs]
}
