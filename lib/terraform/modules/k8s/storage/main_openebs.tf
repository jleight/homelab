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
    for_each = [
      {
        name  = "mayastor.csi.node.initContainers.enabled"
        value = false
      },
      {
        name  = "engines.local.lvm.enabled"
        value = false
      },
      {
        name  = "engines.local.zfs.enabled"
        value = false
      },
      {
        name  = "engines.replicated.mayastor.enabled"
        value = false
      },
      {
        name  = "mayastor.io_engine.envcontext"
        value = "iova-mode=pa"
      }
    ]

    content {
      name  = set.value.name
      value = set.value.value
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
