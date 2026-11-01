module "namespace" {
  source  = "../_registry/flux_managed_namespace"
  context = local.context

  vault = var.vault

  # OpenWebRX's settings-merge init container runs as root to chown
  # settings.json back to the openwebrx user.
  pod_security_enforcement = "baseline"
}
