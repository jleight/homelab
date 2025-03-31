locals {
  cert_manager_enabled = local.enabled && var.k8s_ingress.cert_manager.enabled
}

resource "helm_release" "cert_manager" {
  count = local.cert_manager_enabled ? 1 : 0

  namespace        = "cert-manager"
  create_namespace = true
  name             = "cert-manager"
  repository       = var.k8s_ingress.cert_manager.repository
  chart            = var.k8s_ingress.cert_manager.chart
  version          = var.k8s_ingress.cert_manager.version

  dynamic "set" {
    for_each = [
      {
        name  = "crds.enabled"
        value = true
      },
      {
        name  = "config.apiVersion"
        value = "controller.config.cert-manager.io/v1alpha1"
      },
      {
        name  = "config.kind"
        value = "ControllerConfiguration"
      },
      {
        name  = "config.enableGatewayAPI"
        value = true
      }
    ]

    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}

resource "kubernetes_secret" "cert_manager_cloudflare_api_token" {
  count = local.cert_manager_enabled ? 1 : 0

  metadata {
    namespace = try(one(helm_release.cert_manager[0].metadata).name, null)
    name      = "cloudflare-api-token"
  }

  data = {
    api_token = var.cloudflare_api_token
  }

  depends_on = [helm_release.cert_manager]
}

resource "kubernetes_secret" "cert_manager_lets_encrypt" {
  count = local.cert_manager_enabled && var.lets_encrypt_private_key != null ? 1 : 0

  metadata {
    namespace = try(one(helm_release.cert_manager[0].metadata).name, null)
    name      = "lets-encrypt"
  }

  data = {
    "tls.key" = var.lets_encrypt_private_key
  }

  depends_on = [helm_release.cert_manager]
}

resource "kubectl_manifest" "cert_manager_issuer_self_signed" {
  count = local.cert_manager_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      namespace = try(one(helm_release.cert_manager[0].metadata).name, null)
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
      namespace = try(one(helm_release.cert_manager[0].metadata).name, null)
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
              cloudflare = {
                apiTokenSecretRef = {
                  name = try(one(kubernetes_secret.cert_manager_cloudflare_api_token[0].metadata).name, null)
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
