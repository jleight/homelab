locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  hostname      = "${var.woodpecker_ci.subdomain}.${var.gateway_domain}"
  registry_host = trimprefix(var.forgejo_url, "https://")

  postgres_datasource = "postgres://${var.postgres_username}:${var.postgres_password}@${var.postgres_host}:5432/${var.postgres_database}?sslmode=disable"

  ci_username = "ci"
  ci_password = local.enabled ? random_password.ci_user[0].result : null

  oauth_client_id     = local.enabled ? gitea_oauth2_app.woodpecker[0].client_id : null
  oauth_client_secret = local.enabled ? gitea_oauth2_app.woodpecker[0].client_secret : null

  forge_secret_name    = local.enabled ? kubernetes_secret_v1.forge[0].metadata[0].name : null
  registry_secret_name = local.enabled ? kubernetes_secret_v1.registry[0].metadata[0].name : null

  deployer_service_account = local.enabled ? kubernetes_service_account_v1.deployer[0].metadata[0].name : null
}
