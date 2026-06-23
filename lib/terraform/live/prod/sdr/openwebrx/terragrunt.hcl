terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//sdr/openwebrx"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "rtl_tcp" {
  config_path = "../rtl_tcp"
}

dependency "k8s_storage" {
  config_path = "../../k8s/storage"
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

inputs = {
  component = "openwebrx"

  namespace = dependency.namespace.outputs.namespace

  data_storage_class = dependency.k8s_storage.outputs.app_data_storage_class_name

  gateway_refs   = dependency.k8s_ingress.outputs.private_https_refs
  gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain

  rtl_tcp_host = dependency.rtl_tcp.outputs.service_host
  rtl_tcp_port = dependency.rtl_tcp.outputs.service_port
}
