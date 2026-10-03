data "onepassword_item" "usenet" {
  for_each = toset([for k, v in var.sabnzbd.servers : v.secret_name])

  vault = data.onepassword_vault.this.uuid
  title = "Usenet - ${each.value}"
}

locals {
  # Rendered whole and copied over /config/sabnzbd.ini by an init container on
  # every start.
  sabnzbd_config = templatefile(
    "${path.module}/etc/sabnzbd.ini.tftpl",
    {
      api_key = random_bytes.sabnzbd_api_key.hex
      nzb_key = random_bytes.sabnzbd_nzb_key.hex

      url_service = "sabnzbd"
      url_host    = local.media_domain
      url_path    = var.sabnzbd.path

      download_dir = "/downloads/incomplete"
      complete_dir = "/downloads/unsorted"

      servers = {
        for k, v in var.sabnzbd.servers : k => {
          host        = data.onepassword_item.usenet[v.secret_name].url
          port        = v.port
          username    = data.onepassword_item.usenet[v.secret_name].username
          password    = data.onepassword_item.usenet[v.secret_name].password
          connections = v.connections
          ssl         = v.ssl
          ssl_verify  = v.ssl_verify
          enabled     = v.enabled ? 1 : 0
          priority    = v.priority
        }
      }
    }
  )
}

resource "random_bytes" "sabnzbd_api_key" {
  length = 16
}

resource "random_bytes" "sabnzbd_nzb_key" {
  length = 16
}

resource "kubernetes_secret_v1" "sabnzbd_config" {
  metadata {
    namespace = module.namespace.name
    name      = "sabnzbd-config"
  }

  data = {
    "sabnzbd.ini" = local.sabnzbd_config
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "sabnzbd_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "sabnzbd-subst"
  }

  data = {
    data_storage_class       = var.data_storage_class
    media_storage_class      = var.media_storage_class
    incomplete_storage_class = var.incomplete_storage_class
    gateway_parent_refs      = jsonencode(var.gateway_refs)
    domain                   = local.media_domain
    path                     = var.sabnzbd.path
    config_secret            = kubernetes_secret_v1.sabnzbd_config.metadata[0].name
    config_checksum          = "sha256:${nonsensitive(sha256(local.sabnzbd_config))}"
  }
}
