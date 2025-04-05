locals {
  tailscale_enabled = local.enabled && var.k8s_ingress.tailscale.enabled
}

resource "kubernetes_namespace" "tailscale" {
  count = local.tailscale_enabled ? 1 : 0

  metadata {
    name = "tailscale"

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "kubernetes_secret" "tailscale_operator_oauth" {
  count = local.tailscale_enabled ? 1 : 0

  metadata {
    namespace = try(one(kubernetes_namespace.tailscale[0].metadata).name, null)
    name      = "operator-oauth"
  }

  data = {
    client_id     = var.tailscale_operator_client_id
    client_secret = var.tailscale_operator_client_secret
  }
}

resource "helm_release" "tailscale" {
  count = local.tailscale_enabled ? 1 : 0

  namespace  = try(one(kubernetes_namespace.tailscale[0].metadata).name, null)
  name       = "tailscale-operator"
  repository = var.k8s_ingress.tailscale.repository
  chart      = var.k8s_ingress.tailscale.chart
  version    = var.k8s_ingress.tailscale.version

  set {
    name  = "operatorConfig.hostname"
    value = "tailscale-operator-${local.stack}-${local.environment}"
  }

  set {
    name  = "apiServerProxyConfig.mode"
    value = true
    type  = "string"
  }

  depends_on = [kubernetes_secret.tailscale_operator_oauth]
}
