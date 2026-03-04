resource "kubernetes_config_map_v1" "config" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-config"
  }

  data = {
    "config"     = templatefile("${path.module}/etc/smokeping.tftpl", var.smokeping)
    "ssmtp.conf" = templatefile("${path.module}/etc/ssmtp.tftpl", var.smokeping)
  }
}
