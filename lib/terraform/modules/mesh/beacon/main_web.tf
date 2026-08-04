module "web" {
  source  = "../../_registry/app_deployment"
  context = local.context

  name          = local.web_name
  app_component = local.web_name

  namespace = local.namespace

  image         = var.beacon.beacon_web.image
  image_version = var.beacon.beacon_web.version

  replicas = 2

  # Caddy inside the image serves the built bundle on :80.
  port = local.web_port

  subdomain = var.beacon.subdomain

  gateway_refs   = var.gateway_refs
  gateway_domain = var.gateway_domain

  # /api/v1 and /ws on this same hostname go to the server instead of the
  # bundle. Gateway API matches by path specificity rather than rule order, so
  # these win over the frontend's "/" rule without any ordering games.
  ingress_extra_rules = local.api_rules

  # The image bakes __VITE_*__ placeholders into the JS bundle and its
  # entrypoint seds the real values in at startup, so a config change is just a
  # pod roll — no rebuild.
  env = local.web_env

  resource_requests = {
    cpu    = "25m"
    memory = "32Mi"
  }

  resource_limits = {
    memory = "128Mi"
  }
}
