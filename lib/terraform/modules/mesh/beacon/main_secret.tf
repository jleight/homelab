# Postgres DSN and broker credentials. Everything Beacon reads from the
# environment is a credential, so it all lives here rather than in a ConfigMap.
resource "kubernetes_secret_v1" "app" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-secrets"
  }

  data = merge(
    {
      POSTGRES_DSN = local.database_url
    },
    local.brokers
  )
}
