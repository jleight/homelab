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

dependency "ghcr_deploy" {
  config_path = "../../apps/ghcr_deploy"
}

inputs = {
  component = "meshtender"

  namespace = dependency.namespace.outputs.namespace

  data_storage_class = dependency.k8s_storage.outputs.app_data_storage_class_name

  gateway_refs = dependency.k8s_ingress.outputs.public_meshtender_refs

  ghcr_deploy_service_account_name      = dependency.ghcr_deploy.outputs.service_account_name
  ghcr_deploy_service_account_namespace = dependency.ghcr_deploy.outputs.service_account_namespace
}
