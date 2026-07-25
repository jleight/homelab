resource "kubernetes_secret_v1" "app" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-secrets"

    labels = local.labels
  }

  data = {
    DATABASE_URL = local.database_url

    # username => password map, matching the JSON shape pgtt expects. Empty map
    # yields "{}", which pgtt accepts (no internal users).
    INTERNAL_USERS = jsonencode(local.internal_users)
  }
}
