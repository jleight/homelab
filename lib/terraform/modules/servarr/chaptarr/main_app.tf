module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image         = var.chaptarr.image
  image_version = var.chaptarr.version

  port = local.port

  subdomain = var.chaptarr.subdomain
  path      = var.chaptarr.path

  gateway_refs   = var.gateway_refs
  gateway_domain = var.gateway_domain

  pod_annotations = {
    "checksum/config" = local.config_checksum
  }

  env = {
    PUID = tostring(var.chaptarr.puid)
    PGID = tostring(var.chaptarr.pgid)
  }

  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
    }
    media = {
      storage_class = var.media_storage_class
      storage_size  = "10Ti"
    }
  }

  init_containers = [
    {
      name = "chaptarr-config"

      # Chaptarr's entrypoint chowns /config and the files it creates itself
      # (*.db, logs, MediaCover, Backups) but never config.xml, so a root-owned
      # copy here leaves the app — running as PUID:PGID — unable to open it.
      command = [
        "/bin/sh",
        "-c",
        "cp /config/config.xml /data/config.xml && chown ${var.chaptarr.puid}:${var.chaptarr.pgid} /data/config.xml"
      ]
      volume_mounts = [
        {
          name       = "config"
          mount_path = "/config/config.xml"
          sub_path   = "config.xml"
          read_only  = true
        },
        {
          name       = "data"
          mount_path = "/data"
        }
      ]
    }
  ]

  volumes_from_secrets = {
    config = local.config_secret_name
  }

  volume_mounts = [
    {
      name       = "data"
      mount_path = "/config"
    },
    {
      name       = "media"
      mount_path = local.books_mount_path
      sub_path   = "books"
    },
    {
      name       = "media"
      mount_path = "/downloads"
      sub_path   = "unsorted"
    }
  ]
}
