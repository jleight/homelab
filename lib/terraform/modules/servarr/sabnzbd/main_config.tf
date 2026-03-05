locals {
  sabnzbd_config = local.enabled ? templatefile(
    "${path.module}/etc/sabnzbd.ini.tftpl",
    {
      api_key = random_bytes.api_key[0].hex
      nzb_key = random_bytes.nzb_key[0].hex

      url_service = module.app.service_name
      url_host    = "${var.sabnzbd.subdomain}.${var.gateway_domain}"
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

resource "kubernetes_secret_v1" "config" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = "${local.component}-config"
  }

  data = {
    "sabnzbd.ini" = local.sabnzbd_config
  }
}
