resource "sonarr_download_client_sabnzbd" "k8s" {
  count = local.enabled ? 1 : 0

  name     = "SABnzbd"
  enable   = true
  priority = 1

  host    = var.sabnzbd_service_name
  port    = 80
  api_key = var.sabnzbd_api_key

  remove_completed_downloads = true
  remove_failed_downloads    = true
}

resource "sonarr_download_client_qbittorrent" "k8s" {
  count = local.enabled ? 1 : 0

  name     = "qBittorrent"
  enable   = true
  priority = 2

  host     = var.qbittorrent_service_name
  port     = 8080
  username = var.qbittorrent_username
  password = var.qbittorrent_password
}
