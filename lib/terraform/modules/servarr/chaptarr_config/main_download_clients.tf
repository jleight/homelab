resource "chaptarr_download_client" "sabnzbd" {
  count = local.enabled ? 1 : 0

  name     = "SABnzbd"
  enable   = true
  priority = 1

  implementation  = "Sabnzbd"
  config_contract = "SabnzbdSettings"
  protocol        = "usenet"

  copy_unmanaged_downloads   = false
  remove_completed_downloads = true
  remove_failed_downloads    = true

  test_on_apply = true

  field_values_json = jsonencode({
    host     = var.sabnzbd_service_name
    port     = 80
    useSsl   = false
    urlBase  = null
    username = null

    audiobookCategory = ""
    ebookCategory     = ""
    musicCategory     = ""

    recentTvPriority = -100
    olderTvPriority  = -100
  })

  secret_fields = {
    apiKey = var.sabnzbd_api_key
  }
}

resource "chaptarr_download_client" "qbittorrent" {
  count = local.enabled ? 1 : 0

  name     = "qBittorrent"
  enable   = true
  priority = 2

  implementation  = "QBittorrent"
  config_contract = "QBittorrentSettings"
  protocol        = "torrent"

  copy_unmanaged_downloads   = false
  remove_completed_downloads = false
  remove_failed_downloads    = false

  test_on_apply = true

  field_values_json = jsonencode({
    host     = var.qbittorrent_service_name
    port     = 8080
    useSsl   = false
    urlBase  = null
    username = var.qbittorrent_username

    audiobookCategory         = "chaptarr"
    ebookCategory             = "chaptarr"
    audiobookImportedCategory = null
    ebookImportedCategory     = null
    musicCategory             = "chaptarr"
    musicImportedCategory     = null

    recentTvPriority = 0
    olderTvPriority  = 0
    initialState     = 0
    sequentialOrder  = false
    firstAndLast     = false
    contentLayout    = 0
  })

  secret_fields = {
    password = var.qbittorrent_password
  }
}
