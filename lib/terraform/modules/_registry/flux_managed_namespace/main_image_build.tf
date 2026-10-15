module "image_build" {
  source  = "../flux_image_build"
  context = local.context

  namespace = local.namespace
}
