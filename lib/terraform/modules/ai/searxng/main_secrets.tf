# Signs the preferences cookie and the session state SearXNG hands a browser.
# It had no security role while this was ClusterIP-only with no UI reaching a
# human; serving search.<domain> to a browser is what makes it matter. Supplied
# through SEARXNG_SECRET rather than settings.yml so it stays out of a
# ConfigMap: settings_defaults.py maps that env var onto server.secret_key
# after the file is loaded.
resource "random_password" "secret_key" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "this" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = local.name
  }

  data = {
    SEARXNG_SECRET = local.secret_key
  }
}
