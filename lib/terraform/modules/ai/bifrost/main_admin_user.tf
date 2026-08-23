# Bifrost's dashboard and management API are protected by a single admin
# username/password read from the environment at startup. Generate both, stash
# them in 1Password (alongside the service URL) for the human to retrieve, and
# hand them to the pod via the Kubernetes Secret.
#
# These are also the credentials for creating virtual keys -- the tokens callers
# authenticate with are made by hand in the dashboard, not by Terraform.
resource "random_pet" "admin_user" {
  count = local.enabled ? 1 : 0
}

resource "random_password" "admin_user" {
  count = local.enabled ? 1 : 0

  length = 32
}

resource "onepassword_item" "admin_user" {
  count = local.enabled ? 1 : 0

  title    = "Bifrost"
  category = "login"
  vault    = local.vault_uuid

  username = local.admin_user_username
  password = local.admin_user_password
  url      = "https://${local.hostname}"
}
