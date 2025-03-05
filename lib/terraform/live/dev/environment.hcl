inputs = {
  environment = "dev"

  k8s_cluster = {
    domain    = "leightha.us"
    subdomain = "kube-dev"

    nodes = {
      vm_1 = {
        name              = "dev-01"
        disk              = "/dev/vda"
        network_interface = "ens2"
        mac_address       = "52:54:00:13:8b:c2"
        ip_offset         = 0
      }
      vm_2 = {
        name              = "dev-02"
        disk              = "/dev/vda"
        network_interface = "ens2"
        mac_address       = "52:54:00:c0:47:de"
        ip_offset         = 1
      }
      vm_3 = {
        name              = "dev-03"
        disk              = "/dev/vda"
        network_interface = "ens2"
        mac_address       = "52:54:00:ea:d8:cb"
        ip_offset         = 2
      }
    }

    cilium = { chart = "1.17.1" }
  }
}
