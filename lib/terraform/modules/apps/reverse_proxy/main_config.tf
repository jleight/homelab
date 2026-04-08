resource "kubernetes_config_map_v1" "nginx" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-config"
  }

  data = {
    "nginx.conf" = templatefile(
      "${path.module}/etc/nginx.conf.tftpl",
      {
        services = var.reverse_proxy.services
        domain   = var.gateway_domain
      }
    )
  }
}
