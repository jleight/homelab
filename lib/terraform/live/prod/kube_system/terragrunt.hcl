terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//kube_system"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../k8s/flux"]
}

inputs = {
  stack = "kube-system"
}
