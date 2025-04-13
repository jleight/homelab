resource "kubernetes_config_map" "config" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = local.namespace
    name      = "${local.name}-config"

    labels = local.labels
  }

  data = {
    "config"     = templatefile("${path.module}/etc/smokeping.tftpl", var.smokeping)
    "ssmtp.conf" = templatefile("${path.module}/etc/ssmtp.tftpl", var.smokeping)
  }
}
