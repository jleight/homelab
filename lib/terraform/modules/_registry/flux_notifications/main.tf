resource "kubernetes_secret_v1" "matrix" {
  count = local.enabled ? 1 : 0

  metadata {
    namespace = var.namespace
    name      = "matrix-notifications"
  }

  data = {
    token = local.matrix_access_token
  }
}

resource "kubectl_manifest" "matrix" {
  count = local.enabled ? 1 : 0

  server_side_apply = true

  yaml_body = yamlencode({
    apiVersion = "notification.toolkit.fluxcd.io/v1beta3"
    kind       = "Provider"

    metadata = {
      namespace = var.namespace
      name      = "matrix"
    }

    spec = {
      type    = "matrix"
      address = local.matrix_homeserver_url
      channel = local.matrix_room_id

      secretRef = {
        name = kubernetes_secret_v1.matrix[0].metadata[0].name
      }
    }
  })
}

resource "kubectl_manifest" "failures" {
  count = local.enabled ? 1 : 0

  server_side_apply = true

  yaml_body = yamlencode({
    apiVersion = "notification.toolkit.fluxcd.io/v1beta3"
    kind       = "Alert"

    metadata = {
      namespace = var.namespace
      name      = "failures"
    }

    spec = {
      providerRef = {
        name = kubectl_manifest.matrix[0].name
      }

      eventSeverity = "error"
      eventSources  = [for kind in var.failure_event_sources : { kind = kind, name = "*" }]
      exclusionList = var.failure_exclusions
    }
  })
}

resource "kubectl_manifest" "updates" {
  count = local.enabled ? 1 : 0

  server_side_apply = true

  yaml_body = yamlencode({
    apiVersion = "notification.toolkit.fluxcd.io/v1beta3"
    kind       = "Alert"

    metadata = {
      namespace = var.namespace
      name      = "updates"
    }

    spec = {
      providerRef = {
        name = kubectl_manifest.matrix[0].name
      }

      eventSeverity = "info"
      eventSources  = [for kind in var.update_event_sources : { kind = kind, name = "*" }]
      inclusionList = var.update_inclusions
    }
  })
}
