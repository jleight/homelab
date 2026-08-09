terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//apps/ghcr_deploy"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_ingress" {
  config_path = "../../k8s/ingress"
}

inputs = {
  component = "ghcr-deploy"

  gateway_refs   = dependency.k8s_ingress.outputs.public_https_refs
  gateway_domain = dependency.k8s_ingress.outputs.load_balancer_domain
}
