locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = local.enabled ? kubernetes_namespace.this[0].metadata[0].name : null

  match_labels = {
    "app.kubernetes.io/name"     = local.name
    "app.kubernetes.io/instance" = local.name
  }

  labels = merge(
    local.match_labels,
    {
      "app.kubernetes.io/version"    = var.trakr.version
      "app.kubernetes.io/component"  = "trakr"
      "app.kubernetes.io/part-of"    = local.name
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  )

  port     = 3000
  hostname = "${var.trakr.subdomain}.${var.gateway_domain}"
  path     = var.trakr.path

  postgres_secret   = local.enabled ? kubernetes_secret.postgres[0].metadata[0].name : null
  postgres_username = local.enabled ? random_pet.postgres_user[0].id : null
  postgres_password = local.enabled ? random_password.postgres_user[0].result : null

  service_account_name = local.enabled ? kubernetes_service_account.this[0].metadata[0].name : null
  service_name         = local.enabled ? kubernetes_service.this[0].metadata[0].name : null
}
