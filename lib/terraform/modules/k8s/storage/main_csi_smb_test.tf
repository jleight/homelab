locals {
  csi_smb_test_enabled = local.csi_smb_enabled && var.k8s_storage.csi_smb_test != null
}

resource "kubernetes_namespace" "csi_smb_test" {
  count = local.csi_smb_test_enabled ? 1 : 0

  metadata {
    name = "csi-smb-test"
  }
}

resource "kubernetes_persistent_volume_claim" "csi_smb_test" {
  count = local.csi_smb_test_enabled ? 1 : 0

  metadata {
    namespace = try(one(kubernetes_namespace.csi_smb_test[0].metadata).name, null)
    name      = "csi-smb-test"
  }

  spec {
    storage_class_name = try(one(kubernetes_storage_class.csi_smb_nas02_kubernetes[0].metadata).name, null)

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    access_modes = [
      "ReadWriteOnce"
    ]
  }

  depends_on = [helm_release.csi_smb]
}

resource "kubernetes_pod" "csi_smb_test" {
  count = local.csi_smb_test_enabled ? 1 : 0

  metadata {
    namespace = try(one(kubernetes_namespace.csi_smb_test[0].metadata).name, null)
    name      = "nginx"
  }

  spec {
    container {
      name              = "nginx"
      image             = "${var.k8s_storage.csi_smb_test.image}:${var.k8s_storage.csi_smb_test.version}"
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
        claim_name = try(one(kubernetes_persistent_volume_claim.csi_smb_test[0].metadata).name, null)
      }
    }
  }
}
