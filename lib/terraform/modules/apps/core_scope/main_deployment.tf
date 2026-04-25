resource "kubernetes_deployment_v1" "this" {
  count = local.enabled ? 1 : 0

  # strict-local Longhorn pins the replica; only one pod can mount the DB.
  wait_for_rollout = true

  metadata {
    namespace = local.namespace
    name      = local.name

    labels = local.labels
  }

  spec {
    replicas = 1

    # Recreate — the data PVC is RWO and the replica is strict-local to one
    # node, so a RollingUpdate deadlocks on the old pod holding the volume.
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = local.match_labels
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        container {
          name = "core-scope"

          image             = "${var.core_scope.image}:${var.core_scope.version}"
          image_pull_policy = "IfNotPresent"

          env {
            name  = "DISABLE_CADDY"
            value = tostring(var.core_scope.disable_caddy)
          }

          env {
            name  = "DISABLE_MOSQUITTO"
            value = tostring(var.core_scope.disable_mosquitto)
          }

          port {
            container_port = local.port
          }

          volume_mount {
            name       = "data"
            mount_path = "/app/data"
          }

          volume_mount {
            name       = "config"
            mount_path = "/app/data/config.json"
            sub_path   = "config.json"
            read_only  = true
          }
        }

        # Litestream streams the SQLite WAL to the SMB-backed backup PVC.
        container {
          name = "litestream"

          image             = "${var.core_scope.litestream.image}:${var.core_scope.litestream.version}"
          image_pull_policy = "IfNotPresent"

          args = ["replicate", "-config", "/etc/litestream.yml"]

          volume_mount {
            name       = "data"
            mount_path = "/app/data"
          }

          volume_mount {
            name       = "backup"
            mount_path = "/backup"
          }

          volume_mount {
            name       = "litestream-config"
            mount_path = "/etc/litestream.yml"
            sub_path   = "litestream.yml"
            read_only  = true
          }
        }

        volume {
          name = "data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.data[0].metadata[0].name
          }
        }

        volume {
          name = "backup"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.backup[0].metadata[0].name
          }
        }

        volume {
          name = "litestream-config"

          config_map {
            name = kubernetes_config_map_v1.litestream[0].metadata[0].name
          }
        }

        volume {
          name = "config"

          secret {
            secret_name = kubernetes_secret_v1.config[0].metadata[0].name
          }
        }
      }
    }
  }
}
