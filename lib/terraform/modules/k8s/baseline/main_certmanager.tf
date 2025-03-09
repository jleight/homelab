locals {
  certmanager_version = try(var.k8s_cluster.cert_manager.version, null)
  certmanager_enabled = local.enabled && local.certmanager_version != null

  certmanager_namespace        = local.certmanager_enabled ? var.k8s_cluster.cert_manager.namespace : ""
  certmanager_create_namespace = local.certmanager_enabled && !contains(local.default_k8s_namespaces, local.certmanager_namespace)

  certmanager_issuer = local.certmanager_enabled ? var.k8s_cluster.cert_manager.issuer : null

  certmanager_cloudflare_secret = local.certmanager_enabled ? one(kubernetes_secret.certmanager_cloudflare_api_token[0].metadata).name : null
}

resource "kubernetes_namespace" "certmanager" {
  count = local.certmanager_create_namespace ? 1 : 0

  metadata {
    name = local.certmanager_namespace
  }
}

resource "helm_release" "certmanager" {
  count = local.certmanager_enabled ? 1 : 0

  namespace  = local.certmanager_namespace
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = local.certmanager_version

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

  depends_on = [
    helm_release.cilium,
    kubernetes_namespace.certmanager
  ]
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

  depends_on = [kubernetes_namespace.certmanager]
}

resource "kubectl_manifest" "certmanager_issuer_test" {
  count = local.certmanager_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      namespace = local.certmanager_namespace
      name      = "selfsigned-test"
    }

    spec = {
      selfSigned = {}
    }
  })

  depends_on = [helm_release.certmanager]
}

resource "kubectl_manifest" "certmanager_issuer_staging" {
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

  depends_on = [helm_release.certmanager]
}

resource "kubectl_manifest" "certmanager_issuer_production" {
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

  depends_on = [helm_release.certmanager]
}
