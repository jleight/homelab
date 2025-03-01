data "http" "kgateway_crds" {
  count = local.enabled ? 1 : 0

  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.kgateway_crds_version}/standard-install.yaml"
}

locals {
  kgateway_crds_yaml = local.enabled ? data.http.kgateway_crds[0].response_body : null
}

resource "kubectl_manifest" "kgateway_crds" {
  count = local.enabled ? 1 : 0

  yaml_body = local.kgateway_crds_yaml
}

resource "helm_release" "kgateway" {
  count = local.enabled ? 1 : 0

  name       = "kgateway"
  repository = "oci://ghcr.io/kgateway-dev/charts"
  chart      = "kgateway"
  version    = var.kgateway_version

  create_namespace = true
  namespace        = "kgateway-system"
}
