locals {
  cloudflare_enabled = local.enabled && var.k8s_ingress.cloudflare.enabled

  cloudflare_namespace = "cloudflare-operator-system"

  url = format(
    var.k8s_ingress.cloudflare.url_format,
    var.k8s_ingress.cloudflare.repository,
    var.k8s_ingress.cloudflare.version
  )
}

data "kubectl_kustomize_documents" "cloudflare" {
  count = local.cloudflare_enabled ? 1 : 0

  target = local.url
}

resource "kubectl_manifest" "cloudflare" {
  count = local.cloudflare_enabled ? length(data.kubectl_kustomize_documents.cloudflare[0].documents) : 0

  yaml_body = local.cloudflare_enabled ? data.kubectl_kustomize_documents.cloudflare[0].documents[count.index] : null
}
