resource "kubernetes_deployment_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = local.name

    labels = local.workload_labels
  }

  spec {
    replicas = var.replicas

    # Recreate tears the old pod down before starting the new one. Required for
    # apps that hold a single exclusive resource (e.g. a generic-device-plugin
    # device): the default RollingUpdate surges a second pod that can never
    # acquire the still-held device, deadlocking the rollout.
    dynamic "strategy" {
      for_each = var.deployment_strategy == "Recreate" ? [1] : []

      content {
        type = "Recreate"
      }
    }

    selector {
      match_labels = local.match_labels
    }

    template {
      metadata {
        labels      = local.workload_labels
        annotations = var.pod_annotations
      }

      spec {
        service_account_name = local.service_account_name
        host_network         = var.host_network
        enable_service_links = var.enable_service_links

        # A hostNetwork pod otherwise inherits the node's resolver and can't
        # resolve *.svc.cluster.local — ClusterFirstWithHostNet keeps cluster DNS
        # (external names still resolve via the upstream forwarder). Default to
        # it whenever host networking is on; overridable via dns_policy.
        dns_policy = coalesce(var.dns_policy, var.host_network ? "ClusterFirstWithHostNet" : "ClusterFirst")

        dynamic "security_context" {
          for_each = var.fs_group != null || var.run_as_user != null || var.run_as_non_root != null ? [1] : []

          content {
            fs_group        = var.fs_group
            run_as_user     = var.run_as_user
            run_as_non_root = var.run_as_non_root
          }
        }

        dynamic "init_container" {
          for_each = var.init_containers

          content {
            name = init_container.value.name

            image             = coalesce(init_container.value.image, local.image)
            image_pull_policy = "IfNotPresent"

            command = init_container.value.command

            dynamic "security_context" {
              for_each = init_container.value.run_as_user != null ? [1] : []

              content {
                run_as_user = init_container.value.run_as_user
              }
            }

            dynamic "volume_mount" {
              for_each = init_container.value.volume_mounts

              content {
                name       = volume_mount.value.name
                mount_path = volume_mount.value.mount_path
                sub_path   = volume_mount.value.sub_path
                read_only  = volume_mount.value.read_only
              }
            }
          }
        }

        container {
          name = local.name

          image             = local.image
          image_pull_policy = "IfNotPresent"

          # Overrides the image ENTRYPOINT. Null leaves it intact.
          command = length(var.command) > 0 ? var.command : null

          # Overrides the image CMD (not the entrypoint). When set, it fully
          # replaces the image's default args, so callers must include any
          # defaults they still need. Null leaves the image CMD intact.
          args = length(var.args) > 0 ? var.args : null

          dynamic "env" {
            for_each = var.env

            content {
              name  = env.key
              value = env.value
            }
          }

          dynamic "env" {
            for_each = var.secret_env

            content {
              name = env.key

              value_from {
                secret_key_ref {
                  name = env.value.secret_name
                  key  = env.value.key
                }
              }
            }
          }

          dynamic "env" {
            for_each = local.postgres_env

            content {
              name  = env.key
              value = env.value
            }
          }

          dynamic "env" {
            for_each = var.postgres_enabled ? var.postgres_secret_env_vars : {}

            content {
              name = env.key

              value_from {
                secret_key_ref {
                  name = local.postgres_secret_name
                  key  = env.value
                }
              }
            }
          }

          dynamic "env_from" {
            for_each = var.env_from_config_maps

            content {
              config_map_ref {
                name = env_from.value
              }
            }
          }

          dynamic "env_from" {
            for_each = var.env_from_secrets

            content {
              secret_ref {
                name = env_from.value
              }
            }
          }

          dynamic "resources" {
            for_each = length(var.resource_limits) > 0 || length(var.resource_requests) > 0 ? [1] : []

            content {
              limits   = length(var.resource_limits) > 0 ? var.resource_limits : null
              requests = length(var.resource_requests) > 0 ? var.resource_requests : null
            }
          }

          dynamic "port" {
            for_each = var.port != null ? [var.port] : []

            content {
              container_port = port.value
            }
          }

          dynamic "volume_mount" {
            for_each = var.volume_mounts

            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.mount_path
              sub_path   = volume_mount.value.sub_path
              read_only  = volume_mount.value.read_only
            }
          }
        }

        dynamic "container" {
          for_each = var.extra_containers

          content {
            name = container.value.name

            image             = container.value.image
            image_pull_policy = "IfNotPresent"

            dynamic "env" {
              for_each = container.value.env

              content {
                name  = env.key
                value = env.value
              }
            }

            dynamic "env_from" {
              for_each = container.value.env_from_config_maps

              content {
                config_map_ref {
                  name = env_from.value
                }
              }
            }

            dynamic "env_from" {
              for_each = container.value.env_from_secrets

              content {
                secret_ref {
                  name = env_from.value
                }
              }
            }

            dynamic "port" {
              for_each = container.value.port != null ? [container.value.port] : []

              content {
                container_port = port.value
              }
            }

            dynamic "volume_mount" {
              for_each = container.value.volume_mounts

              content {
                name       = volume_mount.value.name
                mount_path = volume_mount.value.mount_path
                sub_path   = volume_mount.value.sub_path
                read_only  = volume_mount.value.read_only
              }
            }
          }
        }

        dynamic "volume" {
          for_each = kubernetes_persistent_volume_claim_v1.this

          content {
            name = volume.key

            persistent_volume_claim {
              claim_name = volume.value.metadata[0].name
            }
          }
        }

        dynamic "volume" {
          for_each = var.volumes_from_pvcs

          content {
            name = volume.key

            persistent_volume_claim {
              claim_name = volume.value
            }
          }
        }

        dynamic "volume" {
          for_each = var.volumes_from_config_maps

          content {
            name = volume.key

            config_map {
              name = volume.value
            }
          }
        }

        dynamic "volume" {
          for_each = var.volumes_from_secrets

          content {
            name = volume.key

            secret {
              secret_name = volume.value
            }
          }
        }

        dynamic "volume" {
          for_each = var.volumes_empty_dir

          content {
            name = volume.value

            empty_dir {}
          }
        }
      }
    }
  }
}
