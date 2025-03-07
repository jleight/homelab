locals {
  metrics_server_version = try(var.k8s_cluster.metrics_server.version, null)
  metrics_server_enabled = local.enabled && local.metrics_server_version != null

  metrics_server_manifest_url = format(
    "https://github.com/kubernetes-sigs/metrics-server/releases/download/%s/components.yaml",
    local.metrics_server_version
  )

  metrics_server_manifest  = local.enabled ? data.http.metrics_server_manifest[0].response_body : null
  metrics_server_manifests = local.enabled ? data.kubectl_file_documents.metrics_server[0].manifests : {}
}

data "http" "metrics_server_manifest" {
  count = local.metrics_server_enabled ? 1 : 0

  url = local.metrics_server_manifest_url
}

data "kubectl_file_documents" "metrics_server" {
  count = local.metrics_server_enabled ? 1 : 0

  content = local.metrics_server_manifest
}

resource "kubectl_manifest" "metrics_server" {
  for_each = local.metrics_server_manifests

  yaml_body = each.value
}
