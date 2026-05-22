locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  port     = 80
  hostname = "${var.mesh_bug.subdomain}.${var.gateway_domain}"
  path     = var.mesh_bug.path

  postgres_database = "app"
  postgres_host     = "${local.name}-db-rw.${local.namespace}.svc.cluster.local"
  postgres_secret   = local.enabled ? kubernetes_secret_v1.postgres[0].metadata[0].name : null
  postgres_username = local.enabled ? random_pet.postgres_user[0].id : null
  postgres_password = local.enabled ? random_password.postgres_user[0].result : null

  postgres_dsn = local.enabled ? "postgres://${local.postgres_username}:${local.postgres_password}@${local.postgres_host}:5432/${local.postgres_database}?sslmode=disable" : null

  service_name = local.enabled ? local.name : null

  brokers = [
    {
      name           = "vernemq"
      url            = "mqtt://${var.vernemq_host}:1883"
      topicPrefix    = "meshcore/"
      existingSecret = local.enabled ? kubernetes_secret_v1.broker_vernemq[0].metadata[0].name : null
      usernameKey    = "username"
      passwordKey    = "password"
    }
  ]
}
