locals {
  certmanager_test_enabled = local.certmanager_enabled && var.k8s_cluster.cert_manager.test

  certmanager_test_namespace = local.certmanager_test_enabled ? one(kubernetes_namespace.certmanager_test[0].metadata).name : null
}

resource "kubernetes_namespace" "certmanager_test" {
  count = local.certmanager_test_enabled ? 1 : 0

  metadata {
    name = "cert-manager-test"
  }
}

resource "kubectl_manifest" "certmanager_test_issuer" {
  count = local.certmanager_test_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Issuer"
    metadata = {
      namespace = local.certmanager_test_namespace
      name      = "test-selfsigned"
    }
    spec = {
      selfSigned = {}
    }
  })
}

resource "kubectl_manifest" "certmanager_test_certificate" {
  count = local.certmanager_test_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      namespace = local.certmanager_test_namespace
      name      = "selfsigned-cert"
    }
    spec = {
      dnsNames   = ["httpbin.${var.k8s_cluster.subdomain}.${var.k8s_cluster.domain}"]
      secretName = "selfsigned-cert-tls"
      issuerRef = {
        name = "test-selfsigned"
      }
    }
  })

  depends_on = [kubectl_manifest.certmanager_test_issuer]
}
