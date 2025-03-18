inputs = {
  environment = "dev"

  k8s_cluster = {
    domain    = "leighthaus.dev"
    subdomain = "kube"

    nodes = {
      vm_1 = {
        name              = "dev-01"
        install_disk      = "/dev/vda"
        storage_disk      = "/dev/disk/by-id/virtio-vdisk2"
        network_interface = "ens2"
        mac_address       = "52:54:00:a8:9c:79"
        ipv4_offset       = 0
      }
      vm_2 = {
        name              = "dev-02"
        install_disk      = "/dev/vda"
        storage_disk      = "/dev/disk/by-id/virtio-vdisk2"
        network_interface = "ens2"
        mac_address       = "52:54:00:91:1b:56"
        ipv4_offset       = 1
      }
      vm_3 = {
        name              = "dev-03"
        install_disk      = "/dev/vda"
        storage_disk      = "/dev/disk/by-id/virtio-vdisk2"
        network_interface = "ens2"
        mac_address       = "52:54:00:07:ae:f2"
        ipv4_offset       = 2
      }
    }

    kubelet_cert_approver = {
      # renovate: source=github-tags package=alex1989hu/kubelet-serving-cert-approver
      version = "v0.9.0"
    }

    metrics_server = {
      # renovate: source=helm package=metrics-server registry=https://kubernetes-sigs.github.io/metrics-server
      version = "v3.12.2"
    }

    gateway = {
      # renovate: source=github-tags package=kubernetes-sigs/gateway-api
      version = "v1.2.1"
    }

    cilium = {
      # renovate: source=helm package=cilium registry=https://helm.cilium.io
      version = "1.17.2"
      bgp_as  = 65010
    }

    openebs = {
      # renovate: source=helm package=openebs registry=https://openebs.github.io/openebs
      version = "v4.2.0"
    }

    csi_smb = {
      # renovate: source=helm package=csi-driver-smb registry=https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts
      version = "v1.17.0"
    }

    external_dns = {
      # renovate: source=helm package=external-dns registry=https://kubernetes-sigs.github.io/external-dns
      version = "1.15.2"
    }

    # cert_manager = {
    #   version = "v1.17.1"
    #   issuer  = "letsencrypt-staging"
    # }

    # httpbin = {
    #   count = 1
    # }
  }
}
