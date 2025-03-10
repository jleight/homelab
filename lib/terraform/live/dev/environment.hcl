inputs = {
  environment = "dev"

  k8s_cluster = {
    domain    = "leightha.us"
    subdomain = "kube-dev"

    nodes = {
      vm_1 = {
        name              = "dev-01"
        install_disk      = "/dev/vda"
        storage_disk      = "/dev/disk/by-id/virtio-vdisk2"
        network_interface = "ens2"
        mac_address       = "52:54:00:13:8b:c2"
        ip_offset         = 0
      }
      vm_2 = {
        name              = "dev-02"
        install_disk      = "/dev/vda"
        storage_disk      = "/dev/disk/by-id/virtio-vdisk2"
        network_interface = "ens2"
        mac_address       = "52:54:00:c0:47:de"
        ip_offset         = 1
      }
      vm_3 = {
        name              = "dev-03"
        install_disk      = "/dev/vda"
        storage_disk      = "/dev/disk/by-id/virtio-vdisk2"
        network_interface = "ens2"
        mac_address       = "52:54:00:ea:d8:cb"
        ip_offset         = 2
      }
    }

    openebs      = { version = "v4.2.0" }
    csi_smb      = { version = "v1.17.0" }
    external_dns = { version = "1.15.2" }
    # cert_manager = { version = "v1.17.1", issuer = "letsencrypt-staging" }
    # httpbin      = { count = 1 }
  }
}
