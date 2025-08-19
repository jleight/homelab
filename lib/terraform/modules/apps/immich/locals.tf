locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = local.enabled ? kubernetes_namespace.this[0].metadata[0].name : null

  port = 2283

  postgres_secret   = local.enabled ? kubernetes_secret.postgres[0].metadata[0].name : null
  postgres_username = local.enabled ? random_pet.postgres_user[0].id : null
  postgres_password = local.enabled ? random_password.postgres_user[0].result : null

  service_name   = local.enabled ? "${local.name}-server" : null
  media_pvc_name = local.enabled ? kubernetes_persistent_volume_claim.media[0].metadata[0].name : null

  ingress_public_enabled  = local.enabled && var.immich.ingress == "public"
  ingress_private_enabled = local.enabled && var.immich.ingress == "private"
}
