resource "kubernetes_config_map_v1" "app" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-config"

    labels = local.labels
  }

  data = {
    PGTT_WS_ADDR     = ":${local.ws_port}"
    PGTT_TCP_ADDR    = ":${local.tcp_port}"
    PGTT_HEALTH_ADDR = ":${local.health_port}"

    # JWT audiences accepted from external MeshCore publishers: pgtt's own
    # hostname plus any extras (e.g. the existing VerneMQ hostnames) so a device
    # can reach pgtt whether its token targets the old host or the new one.
    EXPECTED_AUDIENCES = join(",", concat([local.hostname], var.expected_audiences))

    # The gateway's Envoy ingress endpoint (pod CIDR) is the connecting peer;
    # trust it (plus node/service ranges) so X-Forwarded-For is honored and the
    # real client IP is logged instead of the LB's.
    PGTT_TRUSTED_PROXIES = local.trusted_proxies
  }
}
