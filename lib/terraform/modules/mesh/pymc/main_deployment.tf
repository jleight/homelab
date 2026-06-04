resource "kubernetes_deployment_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = local.name

    labels = local.labels
  }

  spec {
    replicas = 1

    # One pod at a time: the single modem (one device-plugin unit per node) and
    # the single Litestream writer to the NAS replica must not overlap, so a
    # RollingUpdate's two concurrent pods would conflict.
    strategy {
      type = "Recreate"
    }

    selector {
      match_labels = local.match_labels
    }

    template {
      metadata {
        labels = local.labels

        annotations = {
          "checksum/config" = local.config_checksum
        }
      }

      spec {
        # Run as root so the app can open the serial device node, which the
        # device plugin injects as root:root 0600 (a non-root process can't open
        # it without CAP_DAC_OVERRIDE, which baseline Pod Security forbids adding;
        # root has it by default, so this keeps the namespace baseline-compliant).
        security_context {
          run_as_user  = 0
          run_as_group = 0
        }

        # Restore the SQLite DB from the Litestream replica on every start (the
        # data dir is an ephemeral emptyDir, so the DB is always absent at boot).
        # -if-replica-exists avoids failure on the first-ever deploy (empty NAS).
        init_container {
          name = "litestream-restore"

          image             = "${var.pymc.litestream.image}:${var.pymc.litestream.version}"
          image_pull_policy = "IfNotPresent"

          command = ["litestream"]
          args = [
            "restore",
            "-if-db-not-exists",
            "-if-replica-exists",
            "-o", local.sqlite_path,
            "file://${local.backup_path}",
          ]

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/pymc_repeater"
          }

          volume_mount {
            name       = "share"
            mount_path = "/backup"
            sub_path   = "backup"
          }
        }

        # Enforce the Terraform-owned overrides over the persisted config (on the
        # NAS share): deep-merge them so TF keys win every start while UI edits to
        # other keys persist. On the first-ever deploy there's no config yet, so
        # seed from the overrides and let the app's entrypoint backfill defaults
        # from its bundled config.yaml.example. Reuses the app image for yq.
        init_container {
          name = "config-merge"

          image             = "${var.pymc.image}:${var.pymc.version}"
          image_pull_policy = "IfNotPresent"

          command = ["/bin/sh", "-c"]
          args = [<<-EOT
            set -eu
            config=/etc/pymc_repeater/config.yaml
            if [ -s "$config" ]; then
              yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
                "$config" /overrides/overrides.yaml > /tmp/config.yaml
              mv /tmp/config.yaml "$config"
            else
              cp /overrides/overrides.yaml "$config"
            fi
          EOT
          ]

          volume_mount {
            name       = "share"
            mount_path = "/etc/pymc_repeater"
            sub_path   = "config"
          }

          volume_mount {
            name       = "overrides"
            mount_path = "/overrides"
            read_only  = true
          }
        }

        container {
          name = local.name

          image             = "${var.pymc.image}:${var.pymc.version}"
          image_pull_policy = "IfNotPresent"

          # Running as root, so point HOME at the repeater user's home where the
          # package was pip-installed (user site-packages).
          env {
            name  = "HOME"
            value = local.home_dir
          }

          # Requesting the device-plugin resource is what makes the scheduler
          # place this pod on a node that has a free modem. Kubernetes mirrors
          # extended-resource limits into requests automatically.
          resources {
            limits = {
              (var.pymc.device_resource) = "1"
            }
          }

          port {
            name           = "http"
            container_port = local.web_port
          }

          volume_mount {
            name       = "share"
            mount_path = "/etc/pymc_repeater"
            sub_path   = "config"
          }

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/pymc_repeater"
          }
        }

        # Streams the SQLite WAL to the NAS-backed backup PVC.
        container {
          name = "litestream"

          image             = "${var.pymc.litestream.image}:${var.pymc.litestream.version}"
          image_pull_policy = "IfNotPresent"

          args = ["replicate", "-config", "/etc/litestream.yml"]

          volume_mount {
            name       = "data"
            mount_path = "/var/lib/pymc_repeater"
          }

          volume_mount {
            name       = "share"
            mount_path = "/backup"
            sub_path   = "backup"
          }

          volume_mount {
            name       = "litestream-config"
            mount_path = "/etc/litestream.yml"
            sub_path   = "litestream.yml"
            read_only  = true
          }
        }

        # SQLite working copy — local only, restored from the NAS replica on start.
        volume {
          name = "data"

          empty_dir {}
        }

        # NAS share: config/ (persisted config.yaml) + backup/ (Litestream replica).
        volume {
          name = "share"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.share[0].metadata[0].name
          }
        }

        volume {
          name = "litestream-config"

          config_map {
            name = kubernetes_config_map_v1.litestream[0].metadata[0].name
          }
        }

        volume {
          name = "overrides"

          secret {
            secret_name = kubernetes_secret_v1.overrides[0].metadata[0].name
          }
        }
      }
    }
  }
}
