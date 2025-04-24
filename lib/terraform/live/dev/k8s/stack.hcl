inputs = {
  stack = "k8s"

  k8s_cluster = {
    domain    = "leighthaus.dev"
    subdomain = "kube"

    nodes = {
      vm_1 = {
        name              = "dev-01"
        schematic_id      = "613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245"
        install_disk      = "/dev/vda"
        storage_disk      = "/dev/disk/by-id/virtio-vdisk2"
        network_interface = "ens2"
        mac_address       = "52:54:00:a8:9c:79"
        ipv4_offset       = 20
      }
      vm_2 = {
        name              = "dev-02"
        schematic_id      = "613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245"
        install_disk      = "/dev/vda"
        storage_disk      = "/dev/disk/by-id/virtio-vdisk2"
        network_interface = "ens2"
        mac_address       = "52:54:00:91:1b:56"
        ipv4_offset       = 21
      }
      vm_3 = {
        name              = "dev-03"
        schematic_id      = "613e1592b2da41ae5e265e8789429f22e121aab91cb4deb6bc3c0b6262961245"
        install_disk      = "/dev/vda"
        storage_disk      = "/dev/disk/by-id/virtio-vdisk2"
        network_interface = "ens2"
        mac_address       = "52:54:00:07:ae:f2"
        ipv4_offset       = 22
      }
    }
  }

  k8s_baseline = {
    kubelet_cert_approver = {
      renovate   = "github-tags"
      repository = "alex1989hu/kubelet-serving-cert-approver"
      version    = "v0.9.1"
      url_format = "https://raw.githubusercontent.com/%s/refs/tags/%s/deploy/standalone-install.yaml"
    }

    gateway_crds = {
      renovate   = "github-tags"
      repository = "kubernetes-sigs/gateway-api"
      version    = "v1.2.1"
      url_format = "https://github.com/%s/releases/download/%s/experimental-install.yaml"
    }

    cilium = {
      renovate   = "helm"
      repository = "https://helm.cilium.io"
      chart      = "cilium"
      version    = "1.17.3"
    }
  }

  k8s_monitoring = {
    metrics_server = {
      renovate   = "helm"
      repository = "https://kubernetes-sigs.github.io/metrics-server"
      chart      = "metrics-server"
      version    = "v3.12.2"
    }

    prometheus = {
      renovate   = "helm"
      repository = "https://prometheus-community.github.io/helm-charts"
      chart      = "kube-prometheus-stack"
      version    = "70.7.0"
    }
  }

  k8s_storage = {
    longhorn = {
      renovate   = "helm"
      repository = "https://charts.longhorn.io"
      chart      = "longhorn"
      version    = "1.8.1"
    }

    openebs = {
      renovate   = "helm"
      repository = "https://openebs.github.io/openebs"
      chart      = "openebs"
      version    = "v4.2.0"
      enabled    = false
    }

    csi_smb = {
      renovate   = "helm"
      repository = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts"
      chart      = "csi-driver-smb"
      version    = "v1.17.0"
    }
  }

  k8s_ingress = {
    tailscale = {
      renovate   = "helm"
      repository = "https://pkgs.tailscale.com/helmcharts"
      chart      = "tailscale-operator"
      version    = "v1.82.0"
    }

    cloudflare = {
      renovate   = "github-tags"
      repository = "adyanth/cloudflare-operator"
      version    = "v0.11.1"
      url_format = "https://github.com/%s/config/default?ref=%s"
    }

    external_dns = {
      renovate   = "helm"
      repository = "https://kubernetes-sigs.github.io/external-dns"
      chart      = "external-dns"
      version    = "1.16.1"
    }

    cert_manager = {
      renovate   = "helm"
      repository = "https://charts.jetstack.io"
      chart      = "cert-manager"
      version    = "v1.17.1"
    }

    cert_manager_test = {
      enabled = true
    }

    load_balancer = {
      bgp_asn = 65010
    }
  }
}
