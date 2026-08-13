resource "random_uuid" "api_key" {
  count = local.enabled ? 1 : 0
}

resource "kubernetes_secret_v1" "config" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = "${local.component}-config"
  }

  data = {
    "config.xml" = templatefile(
      "${path.module}/etc/config.xml.tftpl",
      {
        port    = local.port
        path    = trimprefix(var.chaptarr.path, "/")
        auth    = var.chaptarr.auth
        api_key = local.enabled ? replace(random_uuid.api_key[0].result, "-", "") : ""

        db_host     = var.db_host
        db_port     = var.db_port
        db_username = var.db_username
        db_password = var.db_password

        db_main_name  = var.db_main_name
        db_log_name   = var.db_log_name
        db_cache_name = var.db_cache_name
      }
    )
  }
}
