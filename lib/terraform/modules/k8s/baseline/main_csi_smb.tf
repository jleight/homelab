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
