locals {
  openebs_test_enabled = local.openebs_enabled && var.k8s_storage.openebs_test != null
}

resource "kubernetes_namespace" "openebs_test" {
  count = local.openebs_test_enabled ? 1 : 0

  metadata {
    name = "openebs-test"
  }
}

resource "kubernetes_persistent_volume_claim" "openebs_test" {
  count = local.openebs_test_enabled ? 1 : 0

  metadata {
    namespace = try(one(kubernetes_namespace.openebs_test[0].metadata).name, null)
    name      = "openebs-test"
  }

  spec {
    storage_class_name = try(one(kubernetes_storage_class.openebs[0].metadata).name, null)

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    access_modes = [
      "ReadWriteOnce"
    ]
  }

  depends_on = [helm_release.openebs]
}

resource "kubernetes_pod" "openebs_test" {
  count = local.openebs_test_enabled ? 1 : 0

  metadata {
    namespace = try(one(kubernetes_namespace.openebs_test[0].metadata).name, null)
    name      = "fio"
  }

  spec {
    container {
      name              = "fio"
      image             = "${var.k8s_storage.openebs_test.image}:${var.k8s_storage.openebs_test.version}"
      image_pull_policy = "IfNotPresent"

      args = ["sleep", "1000000"]

      volume_mount {
        name       = "test"
        mount_path = "/volume"
      }
    }

    volume {
      name = "test"

      persistent_volume_claim {
        # don't reference the claim name via terraform because the claim will
        # stay in a pending state and the pod will never get created
        claim_name = "openebs-test"
      }
    }
  }
}
