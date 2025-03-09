locals {
  certmanager_test_enabled = local.certmanager_enabled && try(var.k8s_cluster.cert_manager.test, false)

  certmanager_test_namespace        = local.certmanager_test_enabled ? var.k8s_cluster.cert_manager.test_namespace : ""
  certmanager_test_create_namespace = local.certmanager_test_enabled && !contains(local.default_k8s_namespaces, local.certmanager_test_namespace)
}

resource "kubernetes_namespace" "certmanager_test" {
  count = local.certmanager_test_create_namespace ? 1 : 0

  metadata {
    name = local.certmanager_test_namespace
  }
}

resource "kubectl_manifest" "certmanager_test_certificate" {
  count = local.certmanager_test_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      namespace = local.certmanager_test_namespace
      name      = "selfsigned-test"
    }

    spec = {
      issuerRef = {
        name = "selfsigned-test"
      }
      dnsNames   = ["example.com"]
      secretName = "selfsigned-test"
    }
  })

  depends_on = [
    kubectl_manifest.certmanager_issuer_test,
    kubernetes_namespace.certmanager_test
  ]
}
