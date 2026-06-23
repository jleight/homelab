terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//mesh/corescope"
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
  component = "core-scope"

  namespace = dependency.namespace.outputs.namespace

  data_storage_class   = dependency.k8s_storage.outputs.app_data_local_storage_class_name
  backup_storage_class = dependency.k8s_storage.outputs.backups_storage_class_name

  gateway_refs      = dependency.k8s_ingress.outputs.public_corescope_refs
  gateway_hostnames = dependency.k8s_ingress.outputs.public_corescope_hostnames

  vernemq_host     = dependency.mqtt.outputs.host
  vernemq_username = dependency.mqtt.outputs.users.core_scope.username
  vernemq_password = dependency.mqtt.outputs.users.core_scope.password
}
