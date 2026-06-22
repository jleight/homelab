resource "kubernetes_config_map_v1" "app" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-config"

    labels = local.labels
  }

  data = {
    MESHTENDER_ADDR = ":${local.port}"

    # WebAuthn relying party. RP ID is the registrable apex so passkeys are valid
    # across every subdomain; origins are the hosts ceremonies run from (auth + app).
    MESHTENDER_RP_ID     = var.meshtender.hosts.root
    MESHTENDER_RP_NAME   = var.meshtender.rp_name
    MESHTENDER_RP_ORIGIN = local.rp_origins

    # Split-host topology, all served by the one binary on :8080. TLS terminates
    # at the gateway, so MESHTENDER_TLS_CERT/KEY are intentionally unset.
    MESHTENDER_ROOT_HOST    = var.meshtender.hosts.root
    MESHTENDER_WWW_HOST     = var.meshtender.hosts.www
    MESHTENDER_AUTH_HOST    = var.meshtender.hosts.auth
    MESHTENDER_PRIMARY_HOST = var.meshtender.hosts.primary
  }
}
