locals {
  cert_manager_enabled = local.enabled && var.k8s_ingress.cert_manager.enabled
}

resource "kubernetes_namespace_v1" "cert_manager" {
  count = local.cert_manager_enabled ? 1 : 0

  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_secret_v1" "cert_manager_cloudflare_api_token" {
  count = local.cert_manager_enabled ? 1 : 0

  metadata {
    namespace = try(one(kubernetes_namespace_v1.cert_manager[0].metadata).name, null)
    name      = "cloudflare-api-token"
  }

  data = {
    api_token = var.cloudflare_api_token
  }
}

resource "kubernetes_secret_v1" "cert_manager_lets_encrypt" {
  count = local.cert_manager_enabled && var.lets_encrypt_private_key != null ? 1 : 0

  metadata {
    namespace = try(one(kubernetes_namespace_v1.cert_manager[0].metadata).name, null)
    name      = "lets-encrypt"
  }

  data = {
    "tls.key" = var.lets_encrypt_private_key
  }
}

resource "helm_release" "cert_manager" {
  count = local.cert_manager_enabled ? 1 : 0

  namespace  = try(one(kubernetes_namespace_v1.cert_manager[0].metadata).name, null)
  name       = "cert-manager"
  repository = var.k8s_ingress.cert_manager.repository
  chart      = var.k8s_ingress.cert_manager.chart
  version    = var.k8s_ingress.cert_manager.version

  set = [
    for k, v in {
      "crds.enabled"            = true
      "config.apiVersion"       = "controller.config.cert-manager.io/v1alpha1"
      "config.kind"             = "ControllerConfiguration"
      "config.enableGatewayAPI" = true

      # Skip the authoritative-NS walk in the DNS-01 self-check and query
      # public recursors directly. The walk gets stuck in long backoffs when
      # an intermediate lookup blips, leaving challenges pending for many
      # minutes even after the TXT record has fully propagated.
      "extraArgs[0]" = "--dns01-recursive-nameservers=1.1.1.1:53\\,8.8.8.8:53"
      "extraArgs[1]" = "--dns01-recursive-nameservers-only"
    } : { name = k, value = v }
  ]

  depends_on = [
    kubernetes_secret_v1.cert_manager_cloudflare_api_token,
    kubernetes_secret_v1.cert_manager_lets_encrypt
  ]
}

resource "kubectl_manifest" "cert_manager_issuer_self_signed" {
  count = local.cert_manager_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      namespace = try(one(kubernetes_namespace_v1.cert_manager[0].metadata).name, null)
      name      = "self-signed"
    }

    spec = {
      selfSigned = {}
    }
  })

  depends_on = [helm_release.cert_manager]
}

resource "kubectl_manifest" "cert_manager_issuer_lets_encrypt" {
  count = local.cert_manager_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      namespace = try(one(kubernetes_namespace_v1.cert_manager[0].metadata).name, null)
      name      = "lets-encrypt"
    }

    spec = {
      acme = {
        server = var.lets_encrypt_url
        email  = var.lets_encrypt_email

        privateKeySecretRef = {
          name = "lets-encrypt"
        }

        solvers = [
          {
            dns01 = {
              # Follow CNAMEs from `_acme-challenge.<name>` so we can issue
              # certs for delegated domains: the owner CNAMEs their challenge
              # name into a zone we control, and the TXT lands here.
              cnameStrategy = "Follow"

              cloudflare = {
                apiTokenSecretRef = {
                  name = try(one(kubernetes_secret_v1.cert_manager_cloudflare_api_token[0].metadata).name, null)
                  key  = "api_token"
                }
              }
            }
          }
        ]
      }
    }
  })

  depends_on = [helm_release.cert_manager]
}
