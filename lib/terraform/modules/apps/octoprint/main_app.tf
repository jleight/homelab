module "app" {
  source  = "../../_registry/app_deployment"
  context = local.context

  namespace = local.namespace

  image         = var.octoprint.image
  image_version = var.octoprint.version

  port = 5000

  # The printer is a single generic-device-plugin device. Recreate the pod on
  # update (tear down old before new) so the device frees up — a RollingUpdate
  # surge pod could never acquire the still-held device and would deadlock.
  deployment_strategy = "Recreate"

  # OctoPrint's entrypoint reads OCTOPRINT_PORT for its --port flag, which
  # collides with the Service-link env var Kubernetes injects for the
  # same-named `octoprint` Service. Disable service links to avoid the clash.
  enable_service_links = false

  subdomain = var.octoprint.subdomain
  path      = var.octoprint.path

  gateway_namespace = var.gateway_namespace
  gateway_name      = var.gateway_name
  gateway_section   = var.gateway_section
  gateway_domain    = var.gateway_domain

  # Requesting the device-plugin resource is what makes the scheduler place this
  # pod on the node with the printer attached, and what mounts /dev/ttyACM0 into
  # the container with the right cgroup permissions. Kubernetes mirrors
  # extended-resource limits into requests automatically.
  resource_limits = {
    (var.octoprint.device_resource) = "1"
  }

  persistent_volume_claims = {
    data = {
      storage_class = var.data_storage_class
      storage_size  = var.octoprint.storage_size
    }
  }

  volume_mounts = [
    {
      name       = "data"
      mount_path = "/octoprint"
    }
  ]
}
