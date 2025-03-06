locals {
  externaldns_version = try(var.k8s_cluster.external_dns.version, null)
  externaldns_enabled = local.enabled && local.externaldns_version != null

  externaldns_namespace        = local.externaldns_enabled ? var.k8s_cluster.external_dns.namespace : ""
  externaldns_create_namespace = local.externaldns_enabled && !contains(local.default_k8s_namespaces, local.externaldns_namespace)
}

resource "kubernetes_namespace" "externaldns" {
  count = local.externaldns_create_namespace ? 1 : 0

  metadata {
    name = local.externaldns_namespace
  }
}

resource "kubernetes_secret" "externaldns_cloudflare_api_token" {
  count = local.externaldns_enabled ? 1 : 0

  metadata {
    namespace = local.externaldns_namespace
    name      = "cloudflare-api-token"
  }

  data = {
    apiToken = local.cloudflare_api_token
  }

  depends_on = [kubernetes_namespace.externaldns]
}

resource "helm_release" "externaldns" {
  count = local.externaldns_enabled ? 1 : 0

  namespace  = local.externaldns_namespace
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  version    = local.externaldns_version

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
        value = "apiToken"
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

  depends_on = [kubernetes_secret.externaldns_cloudflare_api_token]
}
