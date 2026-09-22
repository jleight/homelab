terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//ai"
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

dependencies {
  paths = ["../apps/dragonflydb"]
}

inputs = {
  stack = "ai"

  database_storage_class = dependency.k8s_storage.outputs.app_data_storage_class_name

  lemonade = {
    url = "http://fwd01.leightha.us:8000"
  }

  searxng = {
    gateway_refs   = dependency.k8s_ingress.outputs.private_https_refs
    gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain
  }

  open_webui = {
    data_storage_class    = dependency.k8s_storage.outputs.app_data_storage_class_name
    uploads_storage_class = dependency.k8s_storage.outputs.backups_storage_class_name
    gateway_refs          = dependency.k8s_ingress.outputs.public_https_refs
    gateway_domain        = dependency.k8s_ingress.outputs.load_balancer_domain
  }

  turnstone = {
    gateway_refs   = dependency.k8s_ingress.outputs.private_https_refs
    gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain
  }
}
