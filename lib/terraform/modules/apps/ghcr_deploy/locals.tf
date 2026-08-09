locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = local.enabled ? kubernetes_namespace_v1.this[0].metadata[0].name : null

  port = 8080

  hostname = "${var.ghcr_deploy.subdomain}.${var.gateway_domain}"

  code_file = "${path.module}/files/ghcr_deploy.py"
  code      = file(local.code_file)

  # Serialized allowlist, mounted next to the code. The service reads it once at
  # startup, so its checksum rolls the pod (see the pod annotations).
  targets_json = jsonencode(var.ghcr_deploy.targets)

  webhook_secret = local.enabled ? random_password.webhook[0].result : null

  vault_uuid = local.enabled ? data.onepassword_vault.terraform[0].uuid : null

  secret_name = local.enabled ? kubernetes_secret_v1.this[0].metadata[0].name : null
  config_name = local.enabled ? kubernetes_config_map_v1.this[0].metadata[0].name : null
}
