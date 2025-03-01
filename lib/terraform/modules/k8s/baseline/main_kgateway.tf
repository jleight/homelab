locals {
  kgateway_enabled   = local.enabled && var.k8s_cluster_baseline.kgateway != null
  kgateway_crds_yaml = local.kgateway_enabled ? data.http.kgateway_crds[0].response_body : null
}

data "http" "kgateway_crds" {
  count = local.kgateway_enabled ? 1 : 0

  url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.k8s_cluster_baseline.kgateway.crds_version}/standard-install.yaml"
}

resource "kubectl_manifest" "kgateway_crds" {
  count = local.kgateway_enabled ? 1 : 0

  yaml_body = local.kgateway_crds_yaml
}

resource "helm_release" "kgateway" {
  count = local.kgateway_enabled ? 1 : 0

  name       = "kgateway"
  repository = "oci://ghcr.io/kgateway-dev/charts"
  chart      = "kgateway"
  version    = var.k8s_cluster_baseline.kgateway.service_version

  create_namespace = true
  namespace        = "kgateway-system"

  depends_on = [kubectl_manifest.kgateway_crds]
}
