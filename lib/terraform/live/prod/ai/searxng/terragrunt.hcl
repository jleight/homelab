terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//ai/searxng"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

dependency "namespace" {
  config_path = "../namespace"
}

inputs = {
  component = "searxng"

  namespace = dependency.namespace.outputs.name

  gateway_refs   = dependency.k8s_ingress.outputs.private_https_refs
  gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain
}
