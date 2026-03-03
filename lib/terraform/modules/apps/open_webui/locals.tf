locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = local.enabled ? kubernetes_namespace_v1.this[0].metadata[0].name : null

  port     = 80
  hostname = "${var.open_webui.subdomain}.${var.gateway_domain}"
  path     = var.open_webui.path

  postgres_secret   = local.enabled ? kubernetes_secret_v1.postgres[0].metadata[0].name : null
  postgres_username = local.enabled ? random_pet.postgres_user[0].id : null
  postgres_password = local.enabled ? random_password.postgres_user[0].result : null

  service_name = local.enabled ? local.name : null
}
