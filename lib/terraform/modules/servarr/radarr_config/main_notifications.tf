resource "radarr_notification_plex" "this" {
  count = local.enabled ? 1 : 0

  name = "Plex Media Server"

  host       = "${var.plex_namespace}.${var.plex_service_name}.svc.cluster.local"
  port       = var.plex_port
  auth_token = local.enabled ? data.onepassword_item.plex[0].credential : ""

  on_download                      = true
  on_upgrade                       = true
  on_rename                        = true
  on_movie_delete                  = true
  on_movie_file_delete             = true
  on_movie_file_delete_for_upgrade = true

  update_library = true
}
