locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  port = 8789

  books_mount_path = "/books"

  config_secret_name = local.enabled ? kubernetes_secret_v1.config[0].metadata[0].name : null

  # The Deployment mounts the config Secret by name, so rewriting its contents
  # leaves the pod spec untouched and nothing rolls — and the init container
  # that seeds /config/config.xml onto the data PVC only runs at pod start, so
  # the app keeps serving the copy it made when it last started. Hashing the
  # rendered config into a pod annotation forces a rollout when it changes.
  config_checksum = local.enabled ? nonsensitive(sha256(kubernetes_secret_v1.config[0].data["config.xml"])) : null
}
