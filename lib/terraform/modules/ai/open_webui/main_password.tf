# Open WebUI creates its first admin from WEBUI_ADMIN_EMAIL/PASSWORD on startup
# when no users exist, then flips ui.enable_signup off in the database. Without
# it the first person to reach the login page gets to register -- and signup
# defaults to on. Generate the password, stash it in 1Password for the human,
# and hand it to the pod through the Secret.
#
# special = false keeps it typeable in a browser prompt.
resource "random_password" "admin_password" {
  count = local.enabled ? 1 : 0

  length  = 32
  special = false
}

resource "onepassword_item" "this" {
  count = local.enabled ? 1 : 0

  title    = "Open WebUI"
  category = "login"
  vault    = local.vault_uuid

  username = var.open_webui.admin_email
  password = local.admin_password
  url      = "https://${local.hostname}"
}
