data "http" "gateway_crds_manifest" {
  count = local.enabled ? 1 : 0

  url = format(
    var.k8s_baseline.gateway_crds.url_format,
    var.k8s_baseline.gateway_crds.repository,
    var.k8s_baseline.gateway_crds.version
  )
}

data "kubectl_file_documents" "gateway_crds" {
  count = local.enabled ? 1 : 0

  content = try(data.http.gateway_crds_manifest[0].response_body, null)
}

resource "kubectl_manifest" "gateway_crds" {
  for_each = local.enabled ? data.kubectl_file_documents.gateway_crds[0].manifests : {}

  server_side_apply = true

  yaml_body = each.value
}
