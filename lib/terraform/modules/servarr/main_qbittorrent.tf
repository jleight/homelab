locals {
  qbittorrent_config = templatefile(
    "${path.module}/etc/qBittorrent.conf.tftpl",
    {
      username      = random_pet.qbittorrent_username.id
      password_salt = random_bytes.qbittorrent_salt.base64
      password_key  = data.pbkdf2_key.qbittorrent.key
    }
  )

  # Flood talks to qBittorrent over localhost, since they share the pod.
  qbittorrent_flood_env = {
    FLOOD_OPTION_baseuri = var.qbittorrent.path
    FLOOD_OPTION_port    = "3000"
    FLOOD_OPTION_auth    = "none"
    FLOOD_OPTION_qburl   = "http://127.0.0.1:8080"
    FLOOD_OPTION_qbuser  = random_pet.qbittorrent_username.id
  }
}

resource "random_pet" "qbittorrent_username" {}

resource "random_password" "qbittorrent_password" {
  length = 32
}

resource "random_bytes" "qbittorrent_salt" {
  length = 16
}

data "pbkdf2_key" "qbittorrent" {
  password      = random_password.qbittorrent_password.result
  salt          = random_bytes.qbittorrent_salt.base64
  hash_function = "sha512"
}

resource "kubernetes_config_map_v1" "qbittorrent_config" {
  metadata {
    namespace = module.namespace.name
    name      = "qbittorrent-config"
  }

  data = {
    "qBittorrent.conf" = local.qbittorrent_config
  }
}

resource "kubernetes_config_map_v1" "qbittorrent_flood_env" {
  metadata {
    namespace = module.namespace.name
    name      = "qbittorrent-flood-env"
  }

  data = local.qbittorrent_flood_env
}

resource "kubernetes_secret_v1" "qbittorrent_flood" {
  metadata {
    namespace = module.namespace.name
    name      = "qbittorrent-flood"
  }

  data = {
    FLOOD_OPTION_qbpass = random_password.qbittorrent_password.result
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "qbittorrent_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "qbittorrent-subst"
  }

  data = {
    data_storage_class  = var.data_storage_class
    media_storage_class = var.media_storage_class
    gateway_parent_refs = jsonencode(var.gateway_refs)
    domain              = local.media_domain
    path                = var.qbittorrent.path
    # The password is in the config too, as its PBKDF2 key.
    config_checksum = "sha256:${sha256(join("\n", [local.qbittorrent_config, jsonencode(local.qbittorrent_flood_env)]))}"
  }
}
