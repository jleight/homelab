terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//unifi/bgp_config"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_cluster_dev" {
  config_path = "../../../dev/k8s/cluster"
}

dependency "k8s_cluster_prod" {
  config_path = "../../../dev/k8s/cluster"
}

inputs = {
  component = "bgp_config"

  peer_groups = [
    for g in [
      dependency.k8s_cluster_dev.outputs.peer_group,
      dependency.k8s_cluster_prod.outputs.peer_group
    ] : g if g != null
  ]
}
