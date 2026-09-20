module "namespace" {
  source  = "../_registry/flux_managed_namespace"
  context = local.context

  vault = var.vault

  # node-exporter is a DaemonSet with host mounts.
  pod_security_enforcement = "privileged"
}
