locals {
  qbittorrent_username = local.enabled ? random_pet.qbittorrent[0].id : ""
  qbittorrent_password = local.enabled ? random_password.qbittorrent[0].result : ""
  qbittorrent_salt     = local.enabled ? random_bytes.qbittorrent_salt[0].base64 : ""
  qbittorrent_pwkey    = local.enabled ? data.pbkdf2_key.qbittorrent[0].key : ""

  qbittorrent_config = local.enabled ? templatefile(
    "${path.module}/etc/qBittorrent.tftpl",
    {
      username      = local.qbittorrent_username
      password_salt = local.qbittorrent_salt
      password_key  = local.qbittorrent_pwkey
    }
  ) : ""

  flood_options = {
    baseuri = local.path
    port    = local.port
    auth    = "none"
    qburl   = "http://127.0.0.1:8080"
    qbuser  = local.qbittorrent_username
  }

  flood_secrets = {
    qbpass = local.qbittorrent_password
  }
}

resource "random_pet" "qbittorrent" {
  count = local.enabled ? 1 : 0
}

resource "random_password" "qbittorrent" {
  count = local.enabled ? 1 : 0

  length = 32
}

resource "random_bytes" "qbittorrent_salt" {
  count = local.enabled ? 1 : 0

  length = 16
}

data "pbkdf2_key" "qbittorrent" {
  count = local.enabled ? 1 : 0

  password      = local.qbittorrent_password
  salt          = local.qbittorrent_salt
  hash_function = "sha512"
}

resource "kubernetes_config_map" "config" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-config"

    labels = local.labels
  }

  data = {
    "qBittorrent.conf" = local.qbittorrent_config
  }
}

resource "kubernetes_config_map" "flood_env" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-flood-env"
  }

  data = {
    for k, v in local.flood_options : "FLOOD_OPTION_${k}" => v
  }
}

resource "kubernetes_secret" "flood" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-flood-secrets"
  }

  data = {
    for k, v in local.flood_secrets : "FLOOD_OPTION_${k}" => v
  }
}
