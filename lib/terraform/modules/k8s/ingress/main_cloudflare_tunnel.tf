resource "kubernetes_secret" "cloudflare_credentials" {
  count = local.cloudflare_enabled ? 1 : 0

  metadata {
    namespace = local.cloudflare_namespace
    name      = "credentials"
  }

  data = {
    CLOUDFLARE_API_TOKEN = var.cloudflare_api_token
  }

  depends_on = [kubectl_manifest.cloudflare]
}

resource "kubectl_manifest" "cloudflare_tunnel" {
  count = local.cloudflare_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "networking.cfargotunnel.com/v1alpha1"
    kind       = "ClusterTunnel"

    metadata = {
      name = "tunnel-${local.stack}-${local.environment}"
    }

    spec = {
      size = 2

      newTunnel = {
        name = "tunnel-${local.stack}-${local.environment}"
      }

      cloudflare = {
        accountId = var.cloudflare_account_id
        domain    = var.k8s_cluster_domain
        secret    = try(one(kubernetes_secret.cloudflare_credentials[0].metadata).name, null)
      }
    }
  })

  depends_on = [kubernetes_secret.cloudflare_credentials]
}
