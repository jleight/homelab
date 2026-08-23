# AnythingLLM's single-user mode gates the whole UI behind one password read
# from AUTH_TOKEN. Generate it, stash it in 1Password for the human, and hand
# it to the pod through the Secret. Turning on multi-user mode is done in the
# UI afterwards and takes over from this.
#
# special = false keeps it typeable in a browser prompt.
resource "random_password" "password" {
  count = local.enabled ? 1 : 0

  length  = 32
  special = false
}

resource "onepassword_item" "this" {
  count = local.enabled ? 1 : 0

  title    = "AnythingLLM"
  category = "login"
  vault    = local.vault_uuid

  password = local.password
  url      = "https://${local.hostname}"
}
