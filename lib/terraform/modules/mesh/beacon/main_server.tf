module "server" {
  source  = "../../_registry/app_deployment"
  context = local.context

  # Both deployables live in this module, so the names are explicit rather than
  # defaulted from the component.
  name          = local.server_name
  app_component = local.server_name

  namespace = local.namespace

  image         = var.beacon.beacon_server.image
  image_version = var.beacon.beacon_server.version

  # Pinned at 1: Beacon's ingest workers use fixed MQTT client IDs
  # ("beacon-mqtt1"/"beacon-mqtt2"), so a second replica would take over the
  # broker session and the two pods would kick each other off in a loop.
  replicas = 1

  port = local.server_port

  # No hostname of its own — the browser reaches the API through the frontend's
  # hostname (see main_web.tf), which keeps it same-origin.
  ingress_enabled = false

  # Roll the pod whenever the seeded config changes: Beacon reads config.yaml
  # once at startup and seeds regions/IATAs/scopes from it.
  pod_annotations = {
    "checksum/config" = sha256(local.config_yaml)
  }

  env = {
    LISTEN_ADDR = ":${local.server_port}"
    CONFIG_PATH = local.config_path
  }

  env_from_secrets = local.enabled ? [local.secret_name] : []

  volumes_from_config_maps = local.enabled ? {
    config = local.config_map_name
  } : {}

  volume_mounts = [
    {
      name       = "config"
      mount_path = local.config_path
      sub_path   = "config.yaml"
      read_only  = true
    }
  ]

  resource_requests = {
    cpu    = "100m"
    memory = "128Mi"
  }

  resource_limits = {
    memory = "512Mi"
  }
}
