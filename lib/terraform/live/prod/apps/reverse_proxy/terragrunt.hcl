terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//apps/reverse_proxy"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

inputs = {
  component = "reverse-proxy"

  gateway_namespace    = dependency.k8s_ingress.outputs.load_balancer_namespace
  private_gateway_name = dependency.k8s_ingress.outputs.private_load_balancer_name
  public_gateway_name  = dependency.k8s_ingress.outputs.public_load_balancer_name
  gateway_section      = "https"
  gateway_domain       = dependency.k8s_ingress.outputs.load_balancer_domain
}
