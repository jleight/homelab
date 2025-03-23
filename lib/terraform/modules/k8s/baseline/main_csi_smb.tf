locals {
  csi_smb_version = try(var.k8s_cluster.csi_smb.version, null)
  csi_smb_enabled = local.enabled && local.csi_smb_version != null

  csi_smb_namespace        = local.csi_smb_enabled ? var.k8s_cluster.csi_smb.namespace : ""
  csi_smb_create_namespace = local.csi_smb_enabled && !contains(local.default_k8s_namespaces, local.csi_smb_namespace)
}

resource "kubernetes_namespace" "csi_smb" {
  count = local.csi_smb_create_namespace ? 1 : 0

  metadata {
    name = local.csi_smb_namespace
  }
}

resource "helm_release" "csi_smb" {
  count = local.csi_smb_enabled ? 1 : 0

  namespace  = local.csi_smb_namespace
  name       = "csi-driver-smb"
  repository = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts"
  chart      = "csi-driver-smb"
  version    = local.csi_smb_version

  depends_on = [
    helm_release.cilium,
    kubernetes_namespace.csi_smb
  ]
}

resource "kubernetes_secret" "csi_smb_nas02_credentials" {
  count = local.csi_smb_enabled ? 1 : 0

  metadata {
    namespace = local.csi_smb_namespace
    name      = "smb-nas02-credentials"
  }

  data = {
    username = local.nas02.username
    password = local.nas02.password
  }

  depends_on = [
    kubernetes_namespace.csi_smb
  ]
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
    "source"                                          = "${local.nas02.url}/Kubernetes"
    "subDir"                                          = "${module.this.id}/$${pvc.metadata.namespace}/$${pvc.metadata.name}"
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
