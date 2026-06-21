# A dedicated Forgejo "ci" bot user owns the registry credentials used by
# pipelines to push/pull images. Keeping it separate from the human admin
# account limits the blast radius if its credentials leak.
resource "random_password" "ci_user" {
  count = local.enabled ? 1 : 0

  length      = 32
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
}

resource "gitea_user" "ci" {
  count = local.enabled ? 1 : 0

  username   = local.ci_username
  login_name = local.ci_username
  email      = "ci@${local.registry_host}"
  password   = local.ci_password

  must_change_password = false
  admin                = false
}

# OAuth2 application that Woodpecker uses for "login with Forgejo" and webhooks.
# Owned by the admin account the gitea provider authenticates as.
resource "gitea_oauth2_app" "woodpecker" {
  count = local.enabled ? 1 : 0

  name = "Woodpecker CI"

  redirect_uris = [
    "https://${local.hostname}/authorize"
  ]

  confidential_client = true
}
