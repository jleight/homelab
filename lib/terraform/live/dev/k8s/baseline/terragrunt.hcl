terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//k8s/baseline"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "cluster" {
  config_path = "../cluster"
}

inputs = {
  component = "baseline"

  cluster_kubeconfig_file = dependency.cluster.outputs.kubeconfig_file
}
