terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//apps/homebridge"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_storage" {
  config_path = "../../k8s/storage"
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

inputs = {
  component = "homebridge"

  data_storage_class = dependency.k8s_storage.outputs.app_data_storage_class_name

  gateway_namespace = dependency.k8s_ingress.outputs.load_balancer_namespace
  gateway_name      = dependency.k8s_ingress.outputs.load_balancer_name
  gateway_section   = dependency.k8s_ingress.outputs.load_balancer_section
  gateway_domain    = dependency.k8s_ingress.outputs.load_balancer_domain
}
