module "namespace" {
  source  = "../_registry/flux_managed_namespace"
  context = local.context

  vault = var.vault

  # The linuxserver images start as root and drop to PUID/PGID through s6.
  pod_security_enforcement = "baseline"
}

# The namespace predates this stack, so adopt it instead of creating it.
import {
  to = module.namespace.kubernetes_namespace_v1.this[0]
  id = "servarr"
}
