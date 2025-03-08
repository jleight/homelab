locals {
  cilium_version = try(var.k8s_cluster.cilium.version, null)
  cilium_enabled = local.enabled && local.cilium_version != null

  cilium_namespace        = local.cilium_enabled ? var.k8s_cluster.cilium.namespace : ""
  cilium_create_namespace = local.cilium_enabled && !contains(local.default_k8s_namespaces, local.cilium_namespace)
}

resource "kubernetes_namespace" "cilium" {
  count = local.cilium_create_namespace ? 1 : 0

  metadata {
    name = local.cilium_namespace
  }
}

resource "helm_release" "cilium" {
  count = local.cilium_enabled ? 1 : 0

  namespace  = local.cilium_namespace
  name       = "cilium"
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = local.cilium_version

  dynamic "set" {
    for_each = concat(
      [
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
        }
      ],
      local.cilium_enabled && var.k8s_cluster.cilium.replace_proxy ? [
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
        }
      ] : [],
      local.gateway_enabled ? [
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
      local.cilium_enabled && var.k8s_cluster.cilium.bgp ? [
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

  depends_on = [
    kubectl_manifest.gateway_crds,
    kubernetes_namespace.cilium
  ]

  provisioner "local-exec" {
    command     = "${path.module}/lib/restart-cilium-unmanaged.sh"
    interpreter = ["bash"]

    environment = {
      KUBECONFIG = local.kubeconfig_file
    }
  }
}
