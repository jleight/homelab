locals {
  kubelet_cert_approver_version = try(var.k8s_cluster.kubelet_cert_approver.version, null)
  kubelet_cert_approver_enabled = local.enabled && local.kubelet_cert_approver_version != null

  kubelet_cert_approver_manifest_url = format(
    "https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/refs/tags/%s/deploy/standalone-install.yaml",
    local.kubelet_cert_approver_version
  )

  kubelet_cert_approver_manifest  = local.enabled ? data.http.kubelet_cert_approver_manifest[0].response_body : null
  kubelet_cert_approver_manifests = local.enabled ? data.kubectl_file_documents.kubelet_cert_approver[0].manifests : {}
}

data "http" "kubelet_cert_approver_manifest" {
  count = local.kubelet_cert_approver_enabled ? 1 : 0

  url = local.kubelet_cert_approver_manifest_url
}

data "kubectl_file_documents" "kubelet_cert_approver" {
  count = local.kubelet_cert_approver_enabled ? 1 : 0

  content = local.kubelet_cert_approver_manifest
}

resource "kubectl_manifest" "kubelet_cert_approver" {
  for_each = local.kubelet_cert_approver_manifests

  yaml_body = each.value
}
