terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//apps/mesh_bug"
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

dependency "core_scope" {
  config_path = "../core_scope"
}

inputs = {
  component = "meshbug"

  data_storage_class = dependency.k8s_storage.outputs.app_data_storage_class_name

  gateway_namespace = dependency.k8s_ingress.outputs.load_balancer_namespace
  gateway_name      = dependency.k8s_ingress.outputs.public_load_balancer_name
  gateway_section   = "https"
  gateway_domain    = dependency.k8s_ingress.outputs.load_balancer_domain

  vernemq_host     = dependency.core_scope.outputs.vernemq_host
  vernemq_username = dependency.core_scope.outputs.vernemq_meshbug_username
  vernemq_password = dependency.core_scope.outputs.vernemq_meshbug_password
}
