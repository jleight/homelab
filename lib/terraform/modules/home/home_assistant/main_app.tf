module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = local.namespace

  # Roll the pod (re-running the merge) whenever the managed overlay changes.
  pod_annotations = {
    "checksum/config-overlay" = sha256(local.config_overlay)
  }

  image               = var.home_assistant.image
  image_version       = var.home_assistant.version
  deployment_strategy = "Recreate"

  port         = 8123
  host_network = true

  subdomain = var.home_assistant.subdomain
  path      = var.home_assistant.path

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section
  gateway_domain    = var.gateway_domain

  init_containers = [
    {
      name        = "merge-config"
      image       = "${var.home_assistant.yq.image}:${var.home_assistant.yq.version}"
      run_as_user = 0

      command = [
        "sh", "-c",
        "f=/config/configuration.yaml; [ -f \"$f\" ] || printf 'default_config:\\n' > \"$f\"; yq -i '. *= load(\"/managed/overlay.yaml\")' \"$f\""
      ]

      volume_mounts = [
        {
          name       = "config"
          mount_path = "/config"
        },
        {
          name       = "config-overlay"
          mount_path = "/managed"
          read_only  = true
        }
      ]
    }
  ]

  # Broker coordinates threaded through from the mqtt module's outputs (not a
  # hardcoded service DNS name). Reference them from configuration.yaml, e.g.:
  #   mqtt:
  #     broker: !env_var HASS_MQTT_HOST
  #     port: !env_var HASS_MQTT_PORT
  env = {
    HASS_MQTT_HOST = var.mqtt_host
    HASS_MQTT_PORT = tostring(var.mqtt_port)
  }

  # Recorder runs on a CNPG Postgres cluster (home-assistant-db) rather than the
  # default write-heavy SQLite, which corrupts on replicated Longhorn. The
  # connection string is injected as HASS_RECORDER_DB_URL, and the init
  # container below guarantees configuration.yaml references it (see locals).
  postgres_enabled       = true
  postgres_storage_class = var.data_storage_class
  postgres_storage_size  = "10Gi"
  use_postgresql_url     = true

  postgres_secret_env_vars = {
    HASS_RECORDER_DB_URL = "url"
  }

  # Deep-merge the Terraform-managed overlay (local.config_overlay) into
  # /config/configuration.yaml before HA starts, so the recorder always points
  # at Postgres regardless of what config is present (fresh, or restored from a
  # HAOS backup that defaults to SQLite). yq preserves the rest of the file,
  # including comments and HA's !secret/!include tags. Runs as root because
  # /config is root-owned (HA runs as root) and the yq image defaults to uid 1000.
  volumes_from_config_maps = {
    "config-overlay" = kubernetes_config_map_v1.config_overlay[0].metadata[0].name
  }

  # /config holds the entity/device registry, automations, dashboards and
  # secrets — a single modest volume. No write-heavy SQLite lives here (the
  # recorder is on Postgres), so the standard replicated class is fine.
  #
  # backups is the SMB share on nas02 mounted at /config/backups (where HA
  # writes its backups), so scheduled backups land off-cluster and HA stops
  # complaining about missing backups. Capacity is nominal — SMB ignores it.
  persistent_volume_claims = {
    config = {
      storage_class = var.data_storage_class
      storage_size  = "5Gi"
    }
    backups = {
      storage_class = var.backups_storage_class
      storage_size  = "50Gi"
    }
  }

  volume_mounts = [
    {
      name       = "config"
      mount_path = "/config"
    },
    {
      name       = "backups"
      mount_path = "/config/backups"
    }
  ]
}
