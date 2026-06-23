terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//sdr/audioplayer"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "trunk_recorder" {
  config_path = "../trunk_recorder"
}

dependency "k8s_storage" {
  config_path = "../../k8s/storage"
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

inputs = {
  component = "audioplayer"

  namespace = dependency.namespace.outputs.namespace

  media_storage_class = dependency.k8s_storage.outputs.media_storage_class_name

  gateway_refs   = dependency.k8s_ingress.outputs.private_https_refs
  gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain

  systems = dependency.trunk_recorder.outputs.systems
}
