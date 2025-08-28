data "http" "manifest" {
  count = local.enabled ? 1 : 0

  url = format(
    var.dragonflydb.url_format,
    var.dragonflydb.repository,
    var.dragonflydb.version
  )
}

data "kubectl_file_documents" "this" {
  count = local.enabled ? 1 : 0

  content = try(data.http.manifest[0].response_body, null)
}

resource "kubectl_manifest" "this" {
  for_each = local.enabled ? data.kubectl_file_documents.this[0].manifests : {}

  yaml_body = each.value
}
