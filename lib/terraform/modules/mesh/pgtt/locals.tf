locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  hostname = "${var.pgtt.subdomain}.${var.gateway_domain}"

  database_url = "postgres://${var.db_username}:${var.db_password}@${var.db_host}:${var.db_port}/pgtt?sslmode=disable"

  internal_users = local.enabled ? {
    for u in var.internal_users : u => random_password.user[u].result
  } : {}

  ws_port     = 8080
  tcp_port    = 1883
  health_port = 8081

  match_labels = {
    "app.kubernetes.io/name"     = local.name
    "app.kubernetes.io/instance" = local.name
  }

  labels = merge(
    local.match_labels,
    {
      "app.kubernetes.io/component"  = local.name
      "app.kubernetes.io/part-of"    = local.stack
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  )

  trusted_proxies = join(",", concat(
    [
      module.ipam.nodes.v4_cidr,
      module.ipam.nodes.v6_cidr
    ],
    [
      module.ipam.resources.pods,
      module.ipam.resources.services
    ]
  ))
}
