# The shared secret GitHub signs deliveries with. It is the only thing standing
# between the internet and a Deployment patch, so it is generated here rather
# than hand-picked, and mirrored into 1Password because the human has to paste
# the same value into the repository's webhook settings.
resource "random_password" "webhook" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "onepassword_item" "webhook" {
  count = local.enabled ? 1 : 0

  title    = "GHCR Deploy - Webhook Secret"
  category = "password"
  vault    = local.vault_uuid

  password = local.webhook_secret
  url      = "https://${local.hostname}${var.ghcr_deploy.webhook_path}"
}

resource "kubernetes_secret_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-secrets"
  }

  data = merge(
    {
      GHCR_DEPLOY_SECRET = local.webhook_secret
    },
    var.ghcr_deploy.ghcr_token == null ? {} : {
      GHCR_TOKEN = var.ghcr_deploy.ghcr_token
    }
  )
}
