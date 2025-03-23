locals {
  openebs_test_enabled = try(var.k8s_cluster.openebs.test, false)

  openebs_test_namespace        = local.openebs_test_enabled ? var.k8s_cluster.openebs.test_namespace : ""
  openebs_test_create_namespace = local.openebs_test_enabled && !contains(local.default_k8s_namespaces, local.openebs_test_namespace)
}

resource "kubernetes_namespace" "openebs_test" {
  count = local.openebs_test_create_namespace ? 1 : 0

  metadata {
    name = local.openebs_test_namespace
  }
}

resource "kubernetes_persistent_volume_claim" "openebs_test_ms" {
  count = local.openebs_test_enabled ? 1 : 0

  metadata {
    namespace = local.openebs_test_namespace
    name      = "ms-volume-claim"
  }

  spec {
    storage_class_name = local.openebs_test_enabled ? one(kubernetes_storage_class.openebs[0].metadata).name : null

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    access_modes = [
      "ReadWriteOnce"
    ]
  }

  depends_on = [
    helm_release.openebs,
    kubernetes_namespace.openebs_test
  ]
}

resource "kubernetes_pod" "openebs_test_fio" {
  count = local.openebs_test_enabled ? 1 : 0

  metadata {
    namespace = local.openebs_test_namespace
    name      = "fio"
  }

  spec {
    container {
      name  = "fio"
      image = "nixery.dev/shell/fio"

      args = [
        "sleep",
        "1000000"
      ]

      volume_mount {
        mount_path = "/volume"
        name       = "ms-volume"
      }
    }

    volume {
      name = "ms-volume"

      persistent_volume_claim {
        claim_name = "ms-volume-claim"
      }
    }
  }

  depends_on = [
    helm_release.openebs,
    kubernetes_namespace.openebs_test
  ]
}
