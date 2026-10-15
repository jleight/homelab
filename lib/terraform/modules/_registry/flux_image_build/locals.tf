locals {
  secret_name = "registry"

  is_source = var.credentials != null

  dockerconfigjson = !local.enabled ? null : local.is_source ? jsonencode({
    auths = {
      (var.credentials.host) = {
        username = var.credentials.username
        password = var.credentials.password
        auth     = base64encode("${var.credentials.username}:${var.credentials.password}")
      }
    }
  }) : data.kubernetes_secret_v1.source[0].data[".dockerconfigjson"]

  # The host is not secret, and consumers build image names from it.
  registry_host = local.enabled ? nonsensitive(one(keys(jsondecode(local.dockerconfigjson).auths))) : null
}
