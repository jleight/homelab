resource "chaptarr_remote_path_mapping" "sabnzbd" {
  count = local.enabled ? 1 : 0

  host        = var.sabnzbd_service_name
  remote_path = "/downloads/unsorted/"
  local_path  = "/downloads/"

  test_before_apply = false
}

resource "chaptarr_remote_path_mapping" "qbittorrent" {
  count = local.enabled ? 1 : 0

  host        = var.qbittorrent_service_name
  remote_path = "/media/unsorted/"
  local_path  = "/downloads/"

  test_before_apply = false
}
