locals {
  longhorn_test_enabled = local.longhorn_enabled && var.k8s_storage.longhorn_test != null
}

resource "kubernetes_namespace" "longhorn_test" {
  count = local.longhorn_test_enabled ? 1 : 0

  metadata {
    name = "longhorn-test"
  }
}

resource "kubernetes_persistent_volume_claim" "longhorn_test" {
  count = local.longhorn_test_enabled ? 1 : 0

  metadata {
    namespace = try(one(kubernetes_namespace.longhorn_test[0].metadata).name, null)
    name      = "longhorn-test"
  }

  spec {
    storage_class_name = try(one(kubernetes_storage_class.longhorn_appdata[0].metadata).name, null)

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    access_modes = [
      "ReadWriteOnce"
    ]
  }

  depends_on = [helm_release.longhorn]
}

resource "kubernetes_pod" "longhorn_test" {
  count = local.longhorn_test_enabled ? 1 : 0

  metadata {
    namespace = try(one(kubernetes_namespace.longhorn_test[0].metadata).name, null)
    name      = "nginx"
  }

  spec {
    container {
      name              = "nginx"
      image             = "${var.k8s_storage.longhorn_test.image}:${var.k8s_storage.longhorn_test.version}"
      image_pull_policy = "IfNotPresent"

      port {
        name           = "http"
        container_port = 80
      }

      volume_mount {
        name       = "html"
        mount_path = "/usr/share/nginx/html"
      }
    }

    volume {
      name = "html"

      persistent_volume_claim {
        claim_name = try(one(kubernetes_persistent_volume_claim.longhorn_test[0].metadata).name, null)
      }
    }
  }
}
