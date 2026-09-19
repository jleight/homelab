module "namespace" {
  source  = "../../_registry/flux_managed_namespace"
  context = local.context

  name     = "flux-system"
  part_of  = "flux"
  instance = "flux-system"
}
