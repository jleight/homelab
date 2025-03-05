locals {
  cilium_enabled = local.enabled && var.k8s_cluster.cilium != null

  cilium_chart_version = local.cilium_enabled ? var.k8s_cluster.cilium.chart : null

  cilium_replace_proxy = local.cilium_enabled && var.k8s_cluster.cilium.replace_proxy
  cilium_gateway       = local.cilium_enabled && var.k8s_cluster.cilium.gateway
  cilium_bgp           = local.cilium_enabled && var.k8s_cluster.cilium.bgp
}

resource "helm_release" "cilium" {
  count = local.cilium_enabled ? 1 : 0

  namespace  = "kube-system"
  name       = "cilium"
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = local.cilium_chart_version

  dynamic "set" {
    for_each = concat(
      [
        {
          name  = "ipam.mode"
          value = "kubernetes"
        },
        {
          name  = "kubeProxyReplacement"
          value = local.cilium_replace_proxy
        },
        {
          name  = "cgroup.autoMount.enabled"
          value = false
        },
        {
          name  = "cgroup.hostRoot"
          value = "/sys/fs/cgroup"
        },
        {
          name  = "bpf.hostLegacyRouting"
          value = true
        }
      ],
      local.cilium_replace_proxy ? [
        {
          name  = "k8sServiceHost"
          value = "localhost"
        },
        {
          name  = "k8sServicePort"
          value = 7445
        }
      ] : [],
      local.cilium_gateway ? [
        {
          name  = "gatewayAPI.enabled"
          value = true
        },
        {
          name  = "gatewayAPI.enableAlpn"
          value = true
        },
        {
          name  = "gatewayAPI.enableAppProtocol"
          value = true
        }
      ] : [],
      local.cilium_bgp ? [
        {
          name  = "bgpControlPlane.enabled"
          value = true
        }
      ] : []
    )
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  dynamic "set_list" {
    for_each = [
      {
        name  = "securityContext.capabilities.ciliumAgent"
        value = ["CHOWN", "KILL", "NET_ADMIN", "NET_RAW", "IPC_LOCK", "SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "FOWNER", "SETGID", "SETUID"]
      },
      {
        name  = "securityContext.capabilities.cleanCiliumState"
        value = ["NET_ADMIN", "SYS_ADMIN", "SYS_RESOURCE"]
      }
    ]
    content {
      name  = set_list.value.name
      value = set_list.value.value
    }
  }

  depends_on = [kubectl_manifest.kgateway_crds]

  provisioner "local-exec" {
    command     = "${path.module}/lib/restart-cilium-unmanaged.sh"
    interpreter = ["bash"]

    environment = {
      KUBECONFIG = local.cluster_kubeconfig_file
    }
  }
}
