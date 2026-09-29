data "onepassword_vault" "this" {
  name = var.vault
}

data "onepassword_item" "github_proxy_token" {
  vault = data.onepassword_vault.this.uuid
  title = var.github_proxy.token_item
}
