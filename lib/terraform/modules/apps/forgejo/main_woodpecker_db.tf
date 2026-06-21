# Dedicated role + database for Woodpecker CI, which shares this Postgres cluster.
# The role is declared on the Cluster (managed.roles, in main_postgres.tf); here we
# generate its credentials and create its database, owned by that role.
resource "random_pet" "woodpecker_postgres_user" {
  count = local.enabled ? 1 : 0
}

resource "random_password" "woodpecker_postgres_user" {
  count = local.enabled ? 1 : 0

  length  = 64
  special = false
}

resource "kubernetes_secret_v1" "woodpecker_postgres" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "woodpecker-postgres"
  }

  type = "kubernetes.io/basic-auth"

  data = {
    username = local.woodpecker_postgres_username
    password = local.woodpecker_postgres_password
  }
}

resource "kubectl_manifest" "woodpecker_database" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Database"

    metadata = {
      namespace = local.namespace
      name      = local.woodpecker_database
    }

    spec = {
      cluster = {
        name = "${local.name}-db"
      }
      name  = local.woodpecker_database
      owner = local.woodpecker_postgres_username
    }
  })

  depends_on = [kubectl_manifest.postgres]
}
