locals {
  csi_smb_enabled = local.enabled && var.k8s_storage.csi_smb.enabled
}

resource "helm_release" "csi_smb" {
  count = local.csi_smb_enabled ? 1 : 0

  namespace  = "kube-system"
  name       = "csi-driver-smb"
  repository = var.k8s_storage.csi_smb.repository
  chart      = var.k8s_storage.csi_smb.chart
  version    = var.k8s_storage.csi_smb.version
}

resource "kubernetes_secret" "csi_smb_nas02_credentials" {
  count = local.csi_smb_enabled ? 1 : 0

  metadata {
    namespace = try(helm_release.csi_smb[0].namespace)
    name      = "smb-nas02-credentials"
  }

  data = {
    username = var.smb_nas02_username
    password = var.smb_nas02_password
  }
}

resource "kubernetes_storage_class" "csi_smb_nas02_kubernetes" {
  count = local.csi_smb_enabled ? 1 : 0

  metadata {
    name = "smb-nas02-kubernetes"
  }

  storage_provisioner = "smb.csi.k8s.io"

  volume_binding_mode    = "Immediate"
  reclaim_policy         = "Retain"
  allow_volume_expansion = true

  parameters = {
    "source"                                          = "${var.smb_nas02_url}/Kubernetes"
    "subDir"                                          = "${local.stack}-${local.environment}/$${pvc.metadata.namespace}/$${pvc.metadata.name}"
    "onDelete"                                        = "delete"
    "csi.storage.k8s.io/provisioner-secret-namespace" = try(one(kubernetes_secret.csi_smb_nas02_credentials[0].metadata).namespace, null)
    "csi.storage.k8s.io/provisioner-secret-name"      = try(one(kubernetes_secret.csi_smb_nas02_credentials[0].metadata).name, null)
    "csi.storage.k8s.io/node-stage-secret-namespace"  = try(one(kubernetes_secret.csi_smb_nas02_credentials[0].metadata).namespace, null)
    "csi.storage.k8s.io/node-stage-secret-name"       = try(one(kubernetes_secret.csi_smb_nas02_credentials[0].metadata).name, null)
  }

  mount_options = [
    "dir_mode=0777",
    "file_mode=0777"
  ]
}
