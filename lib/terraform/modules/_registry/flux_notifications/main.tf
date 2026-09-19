data "onepassword_vault" "this" {
  count = local.enabled ? 1 : 0

  name = var.vault
}

data "onepassword_item" "discord" {
  count = local.enabled ? 1 : 0

  vault = data.onepassword_vault.this[0].uuid
  title = var.item
}

resource "kubernetes_secret_v1" "discord" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = "discord-notifications"
  }

  data = {
    address = "${data.onepassword_item.discord[0].url}/${data.onepassword_item.discord[0].password}"
  }
}
