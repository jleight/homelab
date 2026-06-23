terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//mesh/meshtender"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "k8s_storage" {
  config_path = "../../k8s/storage"
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

dependency "woodpecker_ci" {
  config_path = "../../apps/woodpecker_ci"
}

inputs = {
  component = "meshtender"

  namespace = dependency.namespace.outputs.namespace

  data_storage_class = dependency.k8s_storage.outputs.app_data_storage_class_name

  gateway_refs = dependency.k8s_ingress.outputs.public_meshtender_refs

  registry_host     = dependency.woodpecker_ci.outputs.registry_host
  registry_username = dependency.woodpecker_ci.outputs.registry_username
  registry_password = dependency.woodpecker_ci.outputs.registry_password

  deployer_service_account_name      = dependency.woodpecker_ci.outputs.deployer_service_account_name
  deployer_service_account_namespace = dependency.woodpecker_ci.outputs.namespace
}
