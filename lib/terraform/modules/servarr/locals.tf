locals {
  # The *arrs, SABnzbd and qBittorrent share one hostname, each under its own
  # path.
  media_domain = "${var.media_subdomain}.${var.gateway_domain}"

  db_host = module.database_cluster.host
  db_port = module.database_cluster.port
}
