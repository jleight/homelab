# audioplayer.php — a no-database web player that browses Trunk Recorder's
# recording tree. A stock php:apache image serves our vendored script. The Media
# share's `radio` folder is mounted read-only (recordings + audio serving), and
# `radio/_audioplayer` on the same share is mounted read-write for the per-day
# JSON summaries the script caches. A generated config.json is mounted in. No
# database.
module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image         = var.audioplayer.image
  image_version = var.audioplayer.version

  port         = 80
  service_port = 80

  subdomain = var.audioplayer.subdomain

  gateway_refs   = var.gateway_refs
  gateway_domain = var.gateway_domain

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
      },
      # Same Media share, the `radio/_audioplayer` folder mounted read-write:
      # where the script caches its per-day summaries, kept alongside the
      # recordings under `radio` (the `_` prefix sorts it out of the way of the
      # date directories, which the scanner only ever addresses by exact path so
      # it's never mistaken for a system). Survives pod restarts; self-heals if a
      # summary is missing.
      {
        name       = "media"
        mount_path = "/var/www/index"
        sub_path   = "radio/_audioplayer"
        read_only  = false
      }
    ]
  )
}
