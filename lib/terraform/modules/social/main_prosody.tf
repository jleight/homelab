locals {
  prosody_domain = "${var.prosody.subdomain}.${var.prosody.gateway_domain}"
}

resource "random_password" "prosody_admin" {
  count = local.enabled ? 1 : 0

  length  = 32
  special = false
}

resource "kubernetes_config_map_v1" "prosody" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "prosody-config"
  }

  data = {
    data_storage_class = var.prosody.data_storage_class
    domain             = local.prosody_domain
    admin_jid          = "${var.prosody.admin_username}@${local.prosody_domain}"
  }
}

resource "kubernetes_secret_v1" "prosody_admin" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "prosody-admin"
  }

  data = {
    username = var.prosody.admin_username
    password = random_password.prosody_admin[0].result
  }
}

data "onepassword_vault" "this" {
  count = local.enabled ? 1 : 0

  name = var.vault
}

resource "onepassword_item" "prosody_admin" {
  count = local.enabled ? 1 : 0

  vault    = data.onepassword_vault.this[0].uuid
  title    = var.prosody.admin_item
  category = "login"

  username = var.prosody.admin_username
  password = random_password.prosody_admin[0].result
}
