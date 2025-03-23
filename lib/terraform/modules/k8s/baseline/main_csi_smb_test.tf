locals {
  csi_smb_test_enabled = try(var.k8s_cluster.csi_smb.test, false)

  csi_smb_test_namespace        = local.csi_smb_test_enabled ? var.k8s_cluster.csi_smb.test_namespace : ""
  csi_smb_test_create_namespace = local.csi_smb_test_enabled && !contains(local.default_k8s_namespaces, local.csi_smb_test_namespace)
}

resource "kubernetes_namespace" "csi_smb_test" {
  count = local.csi_smb_test_create_namespace ? 1 : 0

  metadata {
    name = local.csi_smb_test_namespace
  }
}

resource "kubernetes_persistent_volume_claim" "csi_smb_test_ms" {
  count = local.csi_smb_test_enabled ? 1 : 0

  metadata {
    namespace = local.csi_smb_test_namespace
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

  depends_on = [
    helm_release.csi_smb,
    kubernetes_namespace.csi_smb_test
  ]
}

resource "kubernetes_pod" "csi_smb_test" {
  count = local.csi_smb_test_enabled ? 1 : 0

  metadata {
    namespace = local.csi_smb_test_namespace
    name      = "nginx"
  }

  spec {
    container {
      name  = "nginx"
      image = "nginx:1.27-alpine"

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
        claim_name = try(one(kubernetes_persistent_volume_claim.csi_smb_test_ms[0].metadata).name, null)
      }
    }
  }

  depends_on = [
    helm_release.csi_smb,
    kubernetes_namespace.csi_smb_test
  ]
}
