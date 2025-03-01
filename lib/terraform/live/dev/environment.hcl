inputs = {
  environment = "dev"

  k8s_cluster = {
    domain    = "leightha.us"
    subdomain = "kube-dev"
    ip_offset = -7

    nodes = {
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

    kgateway = { crds = "v1.2.1", chart = "v2.0.0-main" }
  }
}
