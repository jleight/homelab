inputs = {
  environment = "prod"

  k8s_cluster = {
    domain    = "leightha.us"
    subdomain = "kube"

    nodes = {
      eq14_1 = {
        name              = "prod-01"
        install_disk      = "/dev/nvme0n1"
        storage_disk      = "/dev/nvme1n1"
        network_interface = "enp1s0"
        mac_address       = "e8:ff:1e:d9:6f:a3"
        ipv4_offset       = 0
      }
      eq14_2 = {
        name              = "prod-02"
        install_disk      = "/dev/nvme1n1"
        storage_disk      = "/dev/nvme0n1"
        network_interface = "enp1s0"
        mac_address       = "e8:ff:1e:d9:72:e7"
        ipv4_offset       = 1
      }
      eq14_3 = {
        name              = "prod-03"
        install_disk      = "/dev/nvme1n1"
        storage_disk      = "/dev/nvme0n1"
        network_interface = "enp1s0"
        mac_address       = "e8:ff:1e:d9:65:f3"
        ipv4_offset       = 2
      }
    }

    openebs      = { version = "v4.2.0" }
    csi_smb      = { version = "v1.17.0" }
    external_dns = { version = "1.15.2" }
    # cert_manager = { version = "v1.17.1", issuer = "letsencrypt-staging" }
    # httpbin      = { count = 1 }
  }
}
