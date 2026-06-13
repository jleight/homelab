module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = local.namespace

  image               = var.zigbee2mqtt.image
  image_version       = var.zigbee2mqtt.version
  deployment_strategy = "Recreate"

  port = 8080

  subdomain = var.zigbee2mqtt.subdomain
  path      = var.zigbee2mqtt.path

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section
  gateway_domain    = var.gateway_domain

  # Roll the pod (re-running the merge init) whenever the managed config changes.
  pod_annotations = {
    "checksum/config" = sha256(local.config_yaml)
  }

  init_containers = [
    {
      name        = "merge-config"
      image       = "${var.zigbee2mqtt.yq.image}:${var.zigbee2mqtt.yq.version}"
      run_as_user = 0

      command = [
        "sh",
        "-c",
        "f=/app/data/configuration.yaml; [ -f \"$f\" ] || echo '{}' > \"$f\"; yq -i '. *= load(\"/managed/configuration.yaml\")' \"$f\""
      ]

      volume_mounts = [
        {
          name       = "data"
          mount_path = "/app/data"
        },
        {
          name       = "managed-config"
          mount_path = "/managed"
          read_only  = true
        }
      ]
    }
  ]

  resource_limits = {
    (var.zigbee2mqtt.device_resource) = "1"
  }

  # The Terraform-managed config (local.config) is mounted read-only from a
  # ConfigMap; an init container deep-merges it into the persisted
  # configuration.yaml so our keys win while Z2M-owned runtime state
  # (network_key, pan_id, devices) is preserved. This is the single source of
  # truth for config — env overrides aren't used because some keys (notably
  # `onboarding`) aren't env-settable, so a merged file keeps everything
  # consistent.
  volumes_from_config_maps = {
    "managed-config" = kubernetes_config_map_v1.config[0].metadata[0].name
  }

  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
    }
  }

  volume_mounts = [
    {
      name       = "data"
      mount_path = "/app/data"
    }
  ]
}
