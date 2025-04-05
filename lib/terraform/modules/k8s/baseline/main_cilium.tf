resource "helm_release" "cilium" {
  count = local.enabled ? 1 : 0

  namespace  = "kube-system"
  name       = "cilium"
  repository = var.k8s_baseline.cilium.repository
  chart      = var.k8s_baseline.cilium.chart
  version    = var.k8s_baseline.cilium.version

  dynamic "set" {
    for_each = [
      {
        name  = "ipam.mode"
        value = "kubernetes"
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
      },
      {
        name  = "kubeProxyReplacement"
        value = true
      },
      {
        name  = "k8sServiceHost"
        value = "localhost"
      },
      {
        name  = "k8sServicePort"
        value = 7445
      },
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
      },
      {
        name  = "bgpControlPlane.enabled"
        value = true
      },
      {
        name  = "socketLB.hostNamespaceOnly"
        value = true
      }
    ]

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

  depends_on = [kubectl_manifest.gateway_crds]

  provisioner "local-exec" {
    command     = "${path.module}/lib/restart-cilium-unmanaged.sh"
    interpreter = ["bash"]

    environment = {
      KUBECONFIG = local.kubeconfig_file
    }
  }
}
