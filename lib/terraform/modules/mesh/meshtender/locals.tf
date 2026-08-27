locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  port = 8080

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

  # Bootstrap image used only at Deployment creation. The GHCR deploy webhook
  # owns the running image thereafter (the image field is ignore_changes'd), so
  # this must match the package and tag it tracks.
  bootstrap_image = "${var.meshtender.image}:${var.meshtender.tag}"

  postgres_secret   = local.enabled ? kubernetes_secret_v1.postgres[0].metadata[0].name : null
  postgres_username = local.enabled ? random_pet.postgres_user[0].id : null
  postgres_password = local.enabled ? random_password.postgres_user[0].result : null

  postgres_datasource = local.enabled ? "postgres://${local.postgres_username}:${local.postgres_password}@${local.name}-db-rw.${local.namespace}.svc.cluster.local:5432/app?sslmode=require" : null

  vault_uuid = local.enabled ? data.onepassword_vault.terraform[0].uuid : null

  master_key = local.enabled ? random_id.master_key[0].hex : null

  resend_api_key = local.enabled ? data.onepassword_item.resend[0].credential : null
  carto_key      = local.enabled ? data.onepassword_item.carto[0].credential : null

  # env_from means a ConfigMap/Secret edit alone never rolls the pods; checksum
  # both into the pod template so key rotations and host changes take effect.
  config_checksum = local.enabled ? sha256(jsonencode(kubernetes_config_map_v1.app[0].data)) : null
  secret_checksum = local.enabled ? nonsensitive(sha256(jsonencode(kubernetes_secret_v1.app[0].data))) : null

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

  # MeshTender sits behind the Cilium gateway, which proxies requests in via its
  # per-node Envoy ingress endpoint — an address in the pod CIDR. MeshTender only
  # honors X-Forwarded-For from a trusted source, so trust the node network (any
  # node it lands on) and the cluster pod/service CIDRs, all sourced from the IPAM
  # module rather than hardcoded. Mirrors home_assistant's trusted_proxies.
  trusted_proxies = join(",", concat(
    [
      module.ipam.nodes.v4_cidr,
      module.ipam.nodes.v6_cidr
    ],
    [
      module.ipam.resources.pods,
      module.ipam.resources.services
    ]
  ))
}
