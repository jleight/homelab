resource "kubernetes_deployment_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = local.name

    labels = local.labels
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = local.match_labels
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        service_account_name = local.service_account_name
        host_network         = var.host_network

        dynamic "init_container" {
          for_each = var.init_containers

          content {
            name = init_container.value.name

            image             = coalesce(init_container.value.image, local.image)
            image_pull_policy = "IfNotPresent"

            command = init_container.value.command

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

          port {
            container_port = var.port
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
