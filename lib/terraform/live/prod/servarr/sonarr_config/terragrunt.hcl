terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//servarr/sonarr_config"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "sonarr" {
  config_path = "../sonarr"
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
  component = "sonarr-config"

  namespace = dependency.namespace.outputs.name

  sonarr_service_name = dependency.sonarr.outputs.service_name
  sonarr_api_key      = dependency.sonarr.outputs.api_key

  sabnzbd_service_name = dependency.sabnzbd.outputs.service_name
  sabnzbd_api_key      = dependency.sabnzbd.outputs.api_key

  qbittorrent_service_name = dependency.qbittorrent.outputs.service_name
  qbittorrent_username     = dependency.qbittorrent.outputs.username
  qbittorrent_password     = dependency.qbittorrent.outputs.password

  plex_namespace    = dependency.plex.outputs.namespace
  plex_service_name = dependency.plex.outputs.service_name
  plex_port         = dependency.plex.outputs.port
}
