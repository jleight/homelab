inputs = {
  environment = "dev"

  k8s_cluster_domain    = "leightha.us"
  k8s_cluster_subdomain = "kube-dev"
  k8s_cluster_ip_offset = -7

  k8s_cluster_nodes = {
    "talos-dev-01" = {
      mac_address = "52:54:00:13:8b:c2"
    }
    "talos-dev-02" = {
      mac_address = "52:54:00:c0:47:de"
    }
    "talos-dev-03" = {
      mac_address = "52:54:00:ea:d8:cb"
    }
  }

  kgateway_crds_version = "v1.2.1"
  kgateway_version      = "v2.0.0-main"
}
