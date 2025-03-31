locals {
  external_dns_enabled = local.enabled && var.k8s_ingress.external_dns.enabled
}

resource "kubernetes_namespace" "external_dns" {
  count = local.external_dns_enabled ? 1 : 0

  metadata {
    name = "external-dns"
  }
}

resource "kubernetes_secret" "external_dns_cloudflare_api_token" {
  count = local.external_dns_enabled ? 1 : 0

  metadata {
    namespace = try(one(kubernetes_namespace.external_dns[0].metadata).name, null)
    name      = "cloudflare-api-token"
  }

  data = {
    api_token = var.cloudflare_api_token
  }
}

resource "helm_release" "external_dns" {
  count = local.external_dns_enabled ? 1 : 0

  namespace  = try(one(kubernetes_namespace.external_dns[0].metadata).name, null)
  name       = "external-dns"
  repository = var.k8s_ingress.external_dns.repository
  chart      = var.k8s_ingress.external_dns.chart
  version    = var.k8s_ingress.external_dns.version

  dynamic "set" {
    for_each = [
      {
        name  = "provider.name"
        value = "cloudflare"
      },
      {
        name  = "env[0].name"
        value = "CF_API_TOKEN"
      },
      {
        name  = "env[0].valueFrom.secretKeyRef.name"
        value = "cloudflare-api-token"
      },
      {
        name  = "env[0].valueFrom.secretKeyRef.key"
        value = "api_token"
      }
    ]

    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  set_list {
    name = "sources"
    value = [
      "gateway-grpcroute",
      "gateway-httproute",
      "gateway-tcproute",
      "gateway-tlsroute",
      "gateway-udproute",
      "ingress",
      "service"
    ]
  }

  depends_on = [kubernetes_secret.external_dns_cloudflare_api_token]
}
