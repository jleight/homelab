module "namespace" {
  source  = "../_registry/flux_managed_namespace"
  context = local.context

  vault = var.vault

  # Prosody needs "baseline" because it starts as root and then drops to a
  # non-root user.
  pod_security_enforcement = "baseline"
}
