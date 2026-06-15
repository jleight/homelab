terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//sdr/rtl_tcp"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

inputs = {
  component = "rtl-tcp"

  namespace = dependency.namespace.outputs.namespace

  gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain
}
