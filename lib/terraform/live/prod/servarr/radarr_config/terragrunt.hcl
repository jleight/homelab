terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//servarr/radarr_config"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "radarr" {
  config_path = "../radarr"
}

dependency "sabnzbd" {
  config_path = "../sabnzbd"
}

dependency "qbittorrent" {
  config_path = "../qbittorrent"
}

dependency "plex" {
  config_path = "../../apps/plex"
}

inputs = {
  component = "radarr-config"

  namespace = dependency.namespace.outputs.name

  radarr_service_name = dependency.radarr.outputs.service_name
  radarr_api_key      = dependency.radarr.outputs.api_key

  sabnzbd_service_name = dependency.sabnzbd.outputs.service_name
  sabnzbd_api_key      = dependency.sabnzbd.outputs.api_key

  qbittorrent_service_name = dependency.qbittorrent.outputs.service_name
  qbittorrent_username     = dependency.qbittorrent.outputs.username
  qbittorrent_password     = dependency.qbittorrent.outputs.password

  plex_namespace    = dependency.plex.outputs.namespace
  plex_service_name = dependency.plex.outputs.service_name
  plex_port         = dependency.plex.outputs.port
}
