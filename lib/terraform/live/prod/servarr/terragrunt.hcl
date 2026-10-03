terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//servarr"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_storage" {
  config_path = "../k8s/storage"
}

dependency "k8s_ingress" {
  config_path = "../k8s/ingress"
}

inputs = {
  stack = "servarr"

  database_storage_class   = dependency.k8s_storage.outputs.app_data_storage_class_name
  data_storage_class       = dependency.k8s_storage.outputs.app_data_storage_class_name
  media_storage_class      = dependency.k8s_storage.outputs.media_storage_class_name
  incomplete_storage_class = dependency.k8s_storage.outputs.ephemeral_storage_class_name

  gateway_refs   = dependency.k8s_ingress.outputs.private_https_refs
  gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain

  sabnzbd = {
    servers = {
      frugal_main = {
        secret_name = "Frugal Main"
        priority    = 0
        connections = 75
      }
      frugal_alt = {
        secret_name = "Frugal Alt"
        priority    = 1
        connections = 30
      }
      frugal_bonus = {
        secret_name = "Frugal Bonus"
        priority    = 2
        connections = 50
      }
      block_news = {
        secret_name = "Block News"
        priority    = 3
        connections = 50
      }
    }
  }
}
