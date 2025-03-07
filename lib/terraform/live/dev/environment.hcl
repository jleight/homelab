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

    kubelet_cert_approver = { version = "v0.9.0" }
    metrics_server        = { version = "v0.7.2" }
    csi_smb               = { version = "v1.17.0" }
    gateway               = { version = "v1.2.1" }
    cilium                = { version = "1.17.1" }
    cert_manager          = { version = "v1.17.1", issuer = "letsencrypt-staging" }
    external_dns          = { version = "1.15.2" }
    httpbin               = { count = 1 }
  }
}
