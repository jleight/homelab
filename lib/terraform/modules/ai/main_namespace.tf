module "namespace" {
  source  = "../_registry/flux_managed_namespace"
  context = local.context

  vault = var.vault

  # Open WebUI's image starts as root before dropping privileges, and SearXNG's
  # entrypoint rewrites its settings before exec'ing uwsgi.
  pod_security_enforcement = "baseline"
}
