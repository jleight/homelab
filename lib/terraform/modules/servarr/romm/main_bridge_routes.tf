# The bridge is served under `${var.romm.bridge.path}` on RomM's own hostname.
# The bridge routes on root-relative paths, so both routes strip the prefix with
# a URLRewrite filter before forwarding.
locals {
  bridge_rewrite_filter = {
    type = "URLRewrite"
    urlRewrite = {
      path = {
        type               = "ReplacePrefixMatch"
        replacePrefixMatch = "/"
      }
    }
  }

  bridge_route_rule = {
    matches = [
      {
        path = {
          type  = "PathPrefix"
          value = var.romm.bridge.path
        }
      }
    ]
    filters = [local.bridge_rewrite_filter]
    backendRefs = [
      {
        name = module.bridge.service_name
        port = local.bridge_service_port
      }
    ]
  }
}

# HTTPS: shares RomM's vhost on the gateway's TLS section. The bridge's longer
# path prefix takes precedence over RomM's `/` route for `${path}` requests.
resource "kubectl_manifest" "bridge_https_ingress" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      namespace = var.namespace
      name      = "${local.bridge_name}-https"
    }

    spec = {
      parentRefs = [
        {
          namespace   = var.gateway_namespace
          name        = var.gateway_name
          sectionName = var.gateway_section
        }
      ]
      hostnames = [module.app.hostname]
      rules     = [local.bridge_route_rule]
    }
  })
}

# HTTP: the bridge path is served in plain HTTP (some clients can't do HTTPS);
# everything else on this host falls through to the redirect rule, so RomM
# itself still forwards to HTTPS.
resource "kubectl_manifest" "bridge_http_ingress" {
  count = local.enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      namespace = var.namespace
      name      = "${local.bridge_name}-http"
    }

    spec = {
      parentRefs = [
        {
          namespace   = var.gateway_namespace
          name        = var.gateway_name
          sectionName = "http"
        }
      ]
      hostnames = [module.app.hostname]
      rules = [
        local.bridge_route_rule,
        {
          filters = [
            {
              type = "RequestRedirect"
              requestRedirect = {
                scheme = "https"
              }
            }
          ]
        }
      ]
    }
  })
}
