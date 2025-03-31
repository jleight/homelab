locals {
  cert_manager_test_enabled = local.cert_manager_enabled && try(var.k8s_ingress.cert_manager_test.enabled, false)
}

resource "kubernetes_namespace" "cert_manager_test" {
  count = local.cert_manager_test_enabled ? 1 : 0

  metadata {
    name = "cert-manager-test"
  }
}

resource "kubectl_manifest" "cert_manager_test_certificate" {
  count = local.cert_manager_test_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      namespace = try(one(kubernetes_namespace.cert_manager_test[0].metadata).name, null)
      name      = "self-signed-test"
    }

    spec = {
      issuerRef = {
        name = "self-signed"
      }
      dnsNames   = [var.k8s_cluster_domain]
      secretName = "self-signed-test"
    }
  })

  depends_on = [helm_release.cert_manager]
}
