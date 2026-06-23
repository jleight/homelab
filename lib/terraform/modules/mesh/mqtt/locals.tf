locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  vernemq_name    = local.name
  vernemq_host    = "${local.vernemq_name}.${local.namespace}.svc.cluster.local"
  vernemq_ws_port = 8080

  auth_name = "${local.name}-auth"
  auth_port = 8080

  # Username -> generated password. Both the in-cluster CoreScope subscriber
  # and external in-cluster consumers (e.g. MeshBug) authenticate against
  # entries in this map; the webhook short-circuits the JWT path for them.
  internal_users = local.enabled ? {
    for u in var.internal_users : u => random_password.user[u].result
  } : {}

  internal_users_json = jsonencode(local.internal_users)

  auth_match_labels = {
    "app.kubernetes.io/name"     = local.auth_name
    "app.kubernetes.io/instance" = local.auth_name
  }

  auth_labels = merge(
    local.auth_match_labels,
    {
      "app.kubernetes.io/component"  = "mqtt-auth"
      "app.kubernetes.io/part-of"    = local.stack
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  )
}
