module "namespace" {
  source  = "../_registry/flux_managed_namespace"
  context = local.context

  vault = var.vault

  # The device plugins are DaemonSets that mount host devices, and cilium,
  # longhorn and csi-driver-smb share the namespace.
  pod_security_enforcement = "privileged"
}

# K8s automatically creates the kube-system namespace, so we have to
# import it instead of creating it.
import {
  to = module.namespace.kubernetes_namespace_v1.this[0]
  id = "kube-system"
}
