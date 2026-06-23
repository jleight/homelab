terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//mesh/meshbug"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "mqtt" {
  config_path = "../mqtt"
}

dependency "k8s_storage" {
  config_path = "../../k8s/storage"
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

inputs = {
  component = "mesh-bug"

  namespace = dependency.namespace.outputs.namespace

  data_storage_class = dependency.k8s_storage.outputs.app_data_storage_class_name

  gateway_refs   = dependency.k8s_ingress.outputs.public_https_refs
  gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain

  vernemq_host     = dependency.mqtt.outputs.host
  vernemq_username = dependency.mqtt.outputs.users.mesh_bug.username
  vernemq_password = dependency.mqtt.outputs.users.mesh_bug.password
}
