terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//web"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_ingress" {
  config_path = "../k8s/ingress"
}

dependency "social" {
  config_path = "../social"
}

inputs = {
  stack = "web"

  apex = {
    apex_gateway_refs = dependency.k8s_ingress.outputs.public_apex_refs
    www_gateway_refs  = dependency.k8s_ingress.outputs.public_https_refs
    gateway_domain    = dependency.k8s_ingress.outputs.load_balancer_domain

    redirect_hostname = "jleight.com"

    matrix_client_base_url = dependency.social.outputs.matrix_client_base_url
  }
}
