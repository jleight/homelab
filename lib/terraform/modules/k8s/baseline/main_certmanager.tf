locals {
  certmanager_enabled = local.enabled && var.k8s_cluster.cert_manager != null

  certmanager_version = local.certmanager_enabled ? var.k8s_cluster.cert_manager.chart : null

  certmanager_namespace         = local.certmanager_enabled ? helm_release.certmanager[0].namespace : null
  certmanager_cloudflare_secret = local.certmanager_enabled ? one(kubernetes_secret.certmanager_cloudflare_api_token[0].metadata).name : null
  certmanager_staging_issuer    = local.certmanager_enabled ? kubectl_manifest.certmanager_cluster_issuer_staging[0].name : null
  certmanager_production_issuer = local.certmanager_enabled ? kubectl_manifest.certmanager_cluster_issuer_production[0].name : null
}

resource "helm_release" "certmanager" {
  count = local.certmanager_enabled ? 1 : 0

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = local.certmanager_version

  create_namespace = true
  namespace        = "cert-manager"

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

resource "kubernetes_secret" "certmanager_cloudflare_api_token" {
  count = local.certmanager_enabled ? 1 : 0

  metadata {
    namespace = local.certmanager_namespace
    name      = "cloudflare-api-token"
  }

  data = {
    apiToken = local.cloudflare_api_token
  }
}

resource "kubectl_manifest" "certmanager_cluster_issuer_staging" {
  count = local.certmanager_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      namespace = local.certmanager_namespace
      name      = "letsencrypt-staging"
    }

    spec = {
      acme = {
        server = local.lets_encrypt.staging.server
        email  = local.lets_encrypt.staging.email

        privateKeySecretRef = {
          name = "letsencrypt-staging"
        }

        solvers = [
          {
            selector = {}
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = local.certmanager_cloudflare_secret
                  key  = "apiToken"
                }
              }
            }
          }
        ]
      }
    }
  })
}

resource "kubectl_manifest" "certmanager_cluster_issuer_production" {
  count = local.certmanager_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      namespace = local.certmanager_namespace
      name      = "letsencrypt-production"
    }

    spec = {
      acme = {
        server = local.lets_encrypt.production.server
        email  = local.lets_encrypt.production.email

        privateKeySecretRef = {
          name = "letsencrypt-production"
        }

        solvers = [
          {
            selector = {}
            dns01 = {
              cloudflare = {
                apiTokenSecretRef = {
                  name = local.certmanager_cloudflare_secret
                  key  = "apiToken"
                }
              }
            }
          }
        ]
      }
    }
  })
}
