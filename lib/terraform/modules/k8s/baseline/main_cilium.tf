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

      # L2 announcements (ARP) let a service VIP that lives inside the node VLAN
      # be answered directly on the wire, so the router treats it as a local
      # host. Used by the node-VLAN load balancer pool (see k8s/ingress). The
      # feature leans on Lease objects for per-IP leader election, so Cilium
      # asks that the client rate limit be sized up to absorb the extra API
      # traffic; the values below are generous headroom for the handful of
      # L2 services we run.
      "l2announcements.enabled"  = true
      "k8sClientRateLimit.qps"   = 30
      "k8sClientRateLimit.burst" = 60
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
