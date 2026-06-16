# audioplayer.php — a no-database web player that browses Trunk Recorder's
# recording tree directly. A stock php:apache image serves the vendored script;
# the Media share (read-only) and a generated config.json are mounted in. No
# state of its own.
module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image         = var.audioplayer.image
  image_version = var.audioplayer.version

  port         = 80
  service_port = 80

  subdomain = var.audioplayer.subdomain

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section
  gateway_domain    = var.gateway_domain

  env = {
    TZ = var.audioplayer.timezone
  }

  pod_annotations = {
    "checksum/config" = sha256(jsonencode(local.config_files))
  }

  volumes_from_config_maps = {
    config = local.config_cm
  }

  # The recordings live on the Media SMB share under `radio` (where Trunk
  # Recorder writes them); mount read-only so the player can only read.
  persistent_volume_claims = {
    media = {
      storage_class = var.media_storage_class
      storage_size  = "10Ti"
      access_modes  = ["ReadWriteMany"]
    }
  }

  volume_mounts = concat(
    [
      {
        name       = "config"
        mount_path = "/var/www/html/index.php"
        sub_path   = "index.php"
        read_only  = true
      },
      {
        name       = "config"
        mount_path = "/var/www/configs/config.json"
        sub_path   = "config.json"
        read_only  = true
      },
      {
        name       = "config"
        mount_path = "/usr/local/etc/php/conf.d/zz-audioplayer.ini"
        sub_path   = "php.ini"
        read_only  = true
      }
    ],
    [
      for s in var.systems :
      {
        name       = "config"
        mount_path = "/var/www/configs/${s.short_name}-talkgroups.csv"
        sub_path   = "${s.short_name}-talkgroups.csv"
        read_only  = true
      }
    ],
    [
      {
        name       = "media"
        mount_path = "/var/www/html/media"
        sub_path   = "radio"
        read_only  = true
      }
    ]
  )
}
