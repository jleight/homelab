terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//servarr/chaptarr_config"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "chaptarr" {
  config_path = "../chaptarr"
}

dependency "sabnzbd" {
  config_path = "../sabnzbd"
}

dependency "qbittorrent" {
  config_path = "../qbittorrent"
}

inputs = {
  component = "chaptarr-config"

  namespace = dependency.namespace.outputs.name

  chaptarr_service_name = dependency.chaptarr.outputs.service_name
  chaptarr_api_key      = dependency.chaptarr.outputs.api_key
  chaptarr_url_base     = dependency.chaptarr.outputs.url_base

  books_path = dependency.chaptarr.outputs.books_path

  sabnzbd_service_name = dependency.sabnzbd.outputs.service_name
  sabnzbd_api_key      = dependency.sabnzbd.outputs.api_key

  qbittorrent_service_name = dependency.qbittorrent.outputs.service_name
  qbittorrent_username     = dependency.qbittorrent.outputs.username
  qbittorrent_password     = dependency.qbittorrent.outputs.password
}
