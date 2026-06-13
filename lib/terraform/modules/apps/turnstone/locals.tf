locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = local.enabled ? kubernetes_namespace_v1.this[0].metadata[0].name : null

  console_name = "console"
  server_name  = "server"
  searxng_name = "searxng"

  console_url = "http://${local.console_name}.${local.namespace}.svc.cluster.local:8090"
  searxng_url = "http://${local.searxng_name}.${local.namespace}.svc.cluster.local:8080"

  jwt_secret      = local.enabled ? random_password.jwt[0].result : ""
  jwt_secret_name = local.enabled ? kubernetes_secret_v1.auth[0].metadata[0].name : null
}
