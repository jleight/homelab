terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//unifi/bgp_config"
}

include {
  path = find_in_parent_folders("root.hcl")
}

dependency "k8s_cluster_dev" {
  config_path = "../../../dev/k8s/cluster"
}

dependency "k8s_ingress_dev" {
  config_path = "../../../dev/k8s/ingress"
}

dependency "k8s_cluster_prod" {
  config_path = "../../../prod/k8s/cluster"
}

dependency "k8s_ingress_prod" {
  config_path = "../../../prod/k8s/ingress"
}

inputs = {
  component = "bgp_config"

  peer_groups = [
    {
      name  = "k8s-cluster-dev"
      asn   = dependency.k8s_ingress_dev.outputs.bgp_asn
      peers = dependency.k8s_cluster_dev.outputs.node_ipv4s
    },
    {
      name  = "k8s-cluster-prod"
      asn   = dependency.k8s_ingress_prod.outputs.bgp_asn
      peers = dependency.k8s_cluster_prod.outputs.node_ipv4s
    }
  ]
}
