locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  port = 8080

  # Host roles. The HTTPRoute serves all of them (apex via its own listener, the
  # subdomains via the wildcard listener).
  hostnames = [
    var.meshtender.hosts.root,
    var.meshtender.hosts.www,
    var.meshtender.hosts.auth,
    var.meshtender.hosts.primary
  ]

  # WebAuthn ceremonies run on the auth and app hosts (comma-separated origins).
  rp_origins = "https://${var.meshtender.hosts.auth},https://${var.meshtender.hosts.primary}"

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

  # Bootstrap image used only at Deployment creation. CI owns the running tag
  # thereafter via `kubectl set image` (the image field is ignore_changes'd), so
  # this must match the repo the .woodpecker pipeline pushes to.
  bootstrap_image = "${var.meshtender.image}:${var.meshtender.commit}"

  postgres_secret   = local.enabled ? kubernetes_secret_v1.postgres[0].metadata[0].name : null
  postgres_username = local.enabled ? random_pet.postgres_user[0].id : null
  postgres_password = local.enabled ? random_password.postgres_user[0].result : null

  postgres_datasource = local.enabled ? "postgres://${local.postgres_username}:${local.postgres_password}@${local.name}-db-rw.${local.namespace}.svc.cluster.local:5432/app?sslmode=require" : null

  master_key = local.enabled ? random_id.master_key[0].hex : null
}
