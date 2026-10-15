terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//k8s/flux"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_storage" {
  config_path = "../storage"
}

dependency "k8s_ingress" {
  config_path = "../ingress"
}

inputs = {
  component = "flux"

  backups_storage_class = dependency.k8s_storage.outputs.backups_storage_class_name

  gateway_refs   = dependency.k8s_ingress.outputs.private_https_refs
  gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain
}
