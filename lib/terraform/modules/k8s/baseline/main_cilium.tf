resource "helm_release" "cilium" {
  count = local.enabled ? 1 : 0

  namespace  = "kube-system"
  name       = "cilium"
  repository = var.k8s_baseline.cilium.repository
  chart      = var.k8s_baseline.cilium.chart
  version    = var.k8s_baseline.cilium.version

  set = [
    for k, v in {
      "ipam.mode"                    = "kubernetes"
      "cgroup.autoMount.enabled"     = false
      "cgroup.hostRoot"              = "/sys/fs/cgroup"
      "bpf.hostLegacyRouting"        = true
      "kubeProxyReplacement"         = true
      "k8sServiceHost"               = "localhost"
      "k8sServicePort"               = 7445
      "gatewayAPI.enabled"           = true
      "gatewayAPI.enableAlpn"        = true
      "gatewayAPI.enableAppProtocol" = true
      "bgpControlPlane.enabled"      = true
      "socketLB.hostNamespaceOnly"   = true
    } : { name = k, value = v }
  ]

  set_list = [
    for k, v in {
      "securityContext.capabilities.ciliumAgent"      = ["CHOWN", "KILL", "NET_ADMIN", "NET_RAW", "IPC_LOCK", "SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "FOWNER", "SETGID", "SETUID"]
      "securityContext.capabilities.cleanCiliumState" = ["NET_ADMIN", "SYS_ADMIN", "SYS_RESOURCE"]
    } : { name = k, value = v }
  ]

  depends_on = [kubectl_manifest.gateway_crds]

  provisioner "local-exec" {
    command     = "${path.module}/lib/restart-cilium-unmanaged.sh"
    interpreter = ["bash"]

    environment = {
      KUBECONFIG = local.kubeconfig_file
    }
  }
}
