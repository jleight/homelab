data "http" "kubelet_cert_approver_manifest" {
  count = local.enabled ? 1 : 0

  url = format(
    var.k8s_baseline.kubelet_cert_approver.url_format,
    var.k8s_baseline.kubelet_cert_approver.repository,
    var.k8s_baseline.kubelet_cert_approver.version
  )
}

data "kubectl_file_documents" "kubelet_cert_approver" {
  count = local.enabled ? 1 : 0

  content = try(data.http.kubelet_cert_approver_manifest[0].response_body, null)
}

resource "kubectl_manifest" "kubelet_cert_approver" {
  for_each = local.enabled ? data.kubectl_file_documents.kubelet_cert_approver[0].manifests : {}

  yaml_body = each.value
}
