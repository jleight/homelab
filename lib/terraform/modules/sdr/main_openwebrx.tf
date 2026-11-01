locals {
  openwebrx_hostname = "${var.openwebrx.subdomain}.${var.openwebrx.gateway_domain}"
}
resource "random_pet" "openwebrx_admin_user" {}

resource "random_password" "openwebrx_admin_user" {
  length = 32
}

resource "onepassword_item" "openwebrx_admin_user" {
  title    = "OpenWebRX+"
  category = "login"
  vault    = data.onepassword_vault.this.uuid

  username = random_pet.openwebrx_admin_user.id
  password = random_password.openwebrx_admin_user.result
  url      = "https://${local.openwebrx_hostname}"
}

resource "kubernetes_secret_v1" "openwebrx_admin_user" {
  metadata {
    namespace = module.namespace.name
    name      = "openwebrx-admin-user"
  }

  data = {
    username = random_pet.openwebrx_admin_user.id
    password = random_password.openwebrx_admin_user.result
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "openwebrx_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "openwebrx-subst"
  }

  data = {
    data_storage_class  = var.openwebrx.data_storage_class
    gateway_parent_refs = jsonencode(var.openwebrx.gateway_refs)
    domain              = local.openwebrx_hostname
    admin_user_secret   = kubernetes_secret_v1.openwebrx_admin_user.metadata[0].name
  }
}
