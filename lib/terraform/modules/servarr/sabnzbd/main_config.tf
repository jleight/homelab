locals {
  sabnzbd_config = local.enabled ? templatefile(
    "${path.module}/etc/sabnzbd.ini.tftpl",
    {
      api_key = random_bytes.api_key[0].hex
      nzb_key = random_bytes.nzb_key[0].hex

      url_service = local.service_name
      url_host    = local.hostname
      url_path    = local.path

      download_dir = "/media/incomplete"
      complete_dir = "/media/unsorted"

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
  ) : ""
}

resource "random_bytes" "api_key" {
  count = local.enabled ? 1 : 0

  length = 16
}

resource "random_bytes" "nzb_key" {
  count = local.enabled ? 1 : 0

  length = 16
}

resource "kubernetes_secret" "config" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-config"

    labels = local.labels
  }

  data = {
    "sabnzbd.ini" = local.sabnzbd_config
  }
}
