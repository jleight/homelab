terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//sdr/rtl_tcp"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "namespace" {
  config_path = "../namespace"
}

# Ordering only: the Tailscale operator (installed in k8s/ingress) must exist
# before the loadBalancerClass=tailscale Service can be reconciled.
dependencies {
  paths = ["../../k8s/ingress"]
}

inputs = {
  component = "rtl-tcp"

  namespace = dependency.namespace.outputs.namespace
}
