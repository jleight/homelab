module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = var.namespace

  image         = var.audiobookshelf.image
  image_version = var.audiobookshelf.version

  port = 80

  subdomain = var.audiobookshelf.subdomain
  path      = var.audiobookshelf.path

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section
  gateway_domain    = var.gateway_domain

  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
    }
    media = {
      storage_class = var.media_storage_class
      storage_size  = "10Ti"
    }
  }

  volume_mounts = [
    {
      name       = "data"
      mount_path = "/config"
      sub_path   = "config"
    },
    {
      name       = "data"
      mount_path = "/metadata"
      sub_path   = "metadata"
    },
    {
      name       = "media"
      mount_path = "/books"
      sub_path   = "books"
    },
    {
      name       = "media"
      mount_path = "/podcasts"
      sub_path   = "podcasts"
    }
  ]
}
