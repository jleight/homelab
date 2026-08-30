locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name = local.component

  internal_url = "http://${local.name}.${var.namespace}.svc.cluster.local:8080"

  hostname   = "${var.searxng.subdomain}.${var.gateway_domain}"
  public_url = "https://${local.hostname}"

  secret_key = local.enabled ? random_password.secret_key[0].result : null
}
