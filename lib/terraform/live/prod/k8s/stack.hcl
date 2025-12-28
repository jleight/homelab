locals {
  schematic_id_eq14 = "0751f1135eff2bc906854a62cc450c94f3dc65428d42110fc7998db8959dd5e5" # iscsi-tools, util-linux-tools, i915
  schematic_id_fw16 = "65cf8364cd0de4cf7b851dc7067a2db83d0ba04f11d8635c6cd3334be6ffb825" # iscsi-tools, util-linux-tools, amd-ucode, amdgpu
}

inputs = {
  stack = "k8s"

  k8s_cluster = {
    domain    = "leightha.us"
    subdomain = "kube"

    nodes = {
      eq14_1 = {
        name              = "prod-01"
        schematic_id      = local.schematic_id_eq14
        install_disk      = "/dev/disk/by-id/nvme-NVME_SSD_512GB_20241220100125"
        storage_disk      = "/dev/disk/by-id/nvme-Timetec_35TTFP6PCIE-1TB_TY241207B1T1365"
        network_interface = "enp1s0"
        mac_address       = "e8:ff:1e:d9:6f:a3"
        vlan_id           = 3
        ipv4_offset       = 20
      }
      eq14_2 = {
        name              = "prod-02"
        schematic_id      = local.schematic_id_eq14
        install_disk      = "/dev/disk/by-id/nvme-NVME_SSD_512GB_20241220100051"
        storage_disk      = "/dev/disk/by-id/nvme-Timetec_MS10_QS241217B1T2814"
        network_interface = "enp1s0"
        mac_address       = "e8:ff:1e:d9:72:e7"
        vlan_id           = 3
        ipv4_offset       = 21
      }
      eq14_3 = {
        name              = "prod-03"
        schematic_id      = local.schematic_id_eq14
        install_disk      = "/dev/disk/by-id/nvme-NVME_SSD_512GB_20241220101351"
        storage_disk      = "/dev/disk/by-id/nvme-Timetec_MS10_QS241217B1T2617"
        network_interface = "enp1s0"
        mac_address       = "e8:ff:1e:d9:65:f3"
        vlan_id           = 3
        ipv4_offset       = 22
      }
      fw16_1 = {
        enabled           = false
        name              = "prod-04"
        schematic_id      = local.schematic_id_fw16
        install_disk      = "/dev/nvme0n1"
        network_interface = "enp196s0f3u1"
        mac_address       = "9c:bf:0d:00:58:50"
        vlan_id           = 3
        ipv4_offset       = 23
      }
    }
  }

  k8s_baseline = {
    kubelet_cert_approver = {
      renovate   = "github-tags"
      repository = "alex1989hu/kubelet-serving-cert-approver"
      version    = "v0.10.1"
      url_format = "https://raw.githubusercontent.com/%s/refs/tags/%s/deploy/standalone-install.yaml"
    }

    gateway_crds = {
      renovate   = "github-tags"
      repository = "kubernetes-sigs/gateway-api"
      version    = "v1.4.1"
      url_format = "https://github.com/%s/releases/download/%s/experimental-install.yaml"
    }

    cilium = {
      renovate   = "helm"
      repository = "https://helm.cilium.io"
      chart      = "cilium"
      version    = "1.18.4"
    }

    node_feature_discovery = {
      renovate = "docker"
      image    = "registry.k8s.io/nfd/charts/node-feature-discovery"
      version  = "0.18.3"

      # ^ hack for renovate to support oci://
      repository = "oci://registry.k8s.io/nfd/charts"
      chart      = "node-feature-discovery"
    }

    amd_gpu = {
      renovate   = "helm"
      repository = "https://rocm.github.io/k8s-device-plugin"
      chart      = "amd-gpu"
      version    = "0.20.0"
    }

    intel_gpu = {
      renovate   = "helm"
      repository = "https://intel.github.io/helm-charts"
      chart      = "intel-device-plugins-operator"
      version    = "0.34.1"
    }
  }

  k8s_monitoring = {
    metrics_server = {
      renovate   = "helm"
      repository = "https://kubernetes-sigs.github.io/metrics-server"
      chart      = "metrics-server"
      version    = "3.13.0"
    }

    prometheus = {
      renovate   = "helm"
      repository = "https://prometheus-community.github.io/helm-charts"
      chart      = "kube-prometheus-stack"
      version    = "80.8.0"
    }
  }

  k8s_storage = {
    longhorn = {
      renovate   = "helm"
      repository = "https://charts.longhorn.io"
      chart      = "longhorn"
      version    = "1.10.1"
    }

    csi_smb = {
      renovate   = "helm"
      repository = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts"
      chart      = "csi-driver-smb"
      version    = "1.19.1"
    }
  }

  k8s_ingress = {
    tailscale = {
      renovate   = "helm"
      repository = "https://pkgs.tailscale.com/helmcharts"
      chart      = "tailscale-operator"
      version    = "1.92.4"
    }

    cloudflare = {
      renovate   = "github-tags"
      repository = "adyanth/cloudflare-operator"
      version    = "v0.13.1"
      url_format = "https://github.com/%s/config/default?ref=%s"
    }

    external_dns = {
      renovate   = "helm"
      repository = "https://kubernetes-sigs.github.io/external-dns"
      chart      = "external-dns"
      version    = "1.19.0"
    }

    cert_manager = {
      renovate   = "helm"
      repository = "https://charts.jetstack.io"
      chart      = "cert-manager"
      version    = "v1.19.2"
    }

    cert_manager_test = {
      enabled = true
    }

    load_balancer = {
      bgp_asn = 65020
    }
  }
}
