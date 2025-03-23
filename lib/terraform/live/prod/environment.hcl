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

    kubelet_cert_approver = {
      # renovate: source=github-tags package=alex1989hu/kubelet-serving-cert-approver
      version = "v0.9.0"
    }

    metrics_server = {
      # renovate: source=helm package=metrics-server registry=https://kubernetes-sigs.github.io/metrics-server
      version = "v3.12.2"
    }

    prometheus = {
      # renovate: source=helm package=kube-prometheus-stack registry=https://prometheus-community.github.io/helm-charts
      version = "70.2.1"
    }

    gateway = {
      # renovate: source=github-tags package=kubernetes-sigs/gateway-api
      version = "v1.2.1"
    }

    cilium = {
      # renovate: source=helm package=cilium registry=https://helm.cilium.io
      version = "1.17.2"
      bgp_as  = 65020
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
      version = "1.16.0"
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
