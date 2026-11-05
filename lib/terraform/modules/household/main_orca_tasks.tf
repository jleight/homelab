locals {
  orca_tasks_domain = "${var.orca_tasks.subdomain}.${var.orca_tasks.gateway_domain}"
  orca_tasks_db     = module.database_cluster.databases["orcatasks"]

  orca_tasks_database_url = join("", [
    "postgresql://${local.orca_tasks_db.username}:${urlencode(module.database_cluster.passwords["orcatasks"])}",
    "@${module.database_cluster.host}:${module.database_cluster.port}/${local.orca_tasks_db.database}",
    "?sslmode=require"
  ])
}

module "ipam" {
  source = "../_registry/ipam"

  environment = local.environment
}

# Encrypts TOTP secrets. Losing it only means resetting each account.
resource "random_bytes" "orca_tasks_secret_key" {
  length = 32
}

resource "kubernetes_secret_v1" "orca_tasks" {
  metadata {
    namespace = module.namespace.name
    name      = "orca-tasks"
  }

  data = {
    database-url = local.orca_tasks_database_url
    secret-key   = random_bytes.orca_tasks_secret_key.base64
  }
}

# Values Flux substitutes into the manifests before applying them.
resource "kubernetes_config_map_v1" "orca_tasks_subst" {
  metadata {
    namespace = module.namespace.name
    name      = "orca-tasks-subst"
  }

  data = {
    attachments_storage_class = var.orca_tasks.attachments_storage_class
    gateway_parent_refs       = jsonencode(var.orca_tasks.gateway_refs)
    domain                    = local.orca_tasks_domain
    secret_name               = kubernetes_secret_v1.orca_tasks.metadata[0].name
    secret_checksum           = "sha256:${sha256(jsonencode(kubernetes_secret_v1.orca_tasks.data))}"

    # Cilium's Envoy connects to backends from each node's ingress IP, which
    # comes out of the pod CIDR.
    trusted_proxies = module.ipam.resources.pods
  }
}
