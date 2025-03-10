locals {
  openebs_version = try(var.k8s_cluster.openebs.version, null)
  openebs_enabled = local.enabled && local.openebs_version != null

  openebs_namespace        = local.openebs_enabled ? var.k8s_cluster.openebs.namespace : ""
  openebs_create_namespace = local.openebs_enabled && !contains(local.default_k8s_namespaces, local.openebs_namespace)
}

resource "kubernetes_namespace" "openebs" {
  count = local.openebs_create_namespace ? 1 : 0

  metadata {
    name = local.openebs_namespace
  }
}

resource "helm_release" "openebs" {
  count = local.openebs_enabled ? 1 : 0

  namespace  = local.openebs_namespace
  name       = "openebs"
  repository = "https://openebs.github.io/openebs"
  chart      = "openebs"
  version    = local.openebs_version

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
      }
    ]

    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  depends_on = [
    helm_release.cilium,
    kubernetes_namespace.openebs
  ]
}

resource "kubectl_manifest" "openebs_diskpool" {
  for_each = local.openebs_enabled ? var.k8s_cluster.nodes : {}

  yaml_body = yamlencode({
    apiVersion = "openebs.io/v1beta2"
    kind       = "DiskPool"

    metadata = {
      namespace = local.openebs_namespace
      name      = "ephemeral-${each.value.name}"
    }

    spec = {
      node  = each.value.name
      disks = ["uring://${each.value.storage_disk}"]
    }
  })
}

resource "kubernetes_storage_class" "openebs" {
  count = local.openebs_enabled ? var.k8s_cluster.openebs.max_replicas : 0

  metadata {
    name = "mayastor-${count.index}"
  }

  storage_provisioner = "io.openebs.csi-mayastor"

  volume_binding_mode    = "Immediate"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true

  parameters = {
    fsType   = "xfs"
    protocol = "nvmf"
    thin     = true
    repl     = count.index + 1
  }
}
