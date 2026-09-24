locals {
  load_balancer_enabled = local.enabled && var.k8s_ingress.load_balancer.enabled

  load_balancer_namespace    = local.load_balancer_enabled ? kubernetes_namespace_v1.load_balancer[0].metadata[0].name : ""
  private_load_balancer_name = local.load_balancer_enabled ? "private-lb" : ""
  public_load_balancer_name  = local.load_balancer_enabled ? "public-lb" : ""

  load_balancer_domain = local.load_balancer_enabled ? var.k8s_cluster_domain : ""

  # One cert for the zone: the bare domain plus `*.<domain>`. Both gateways'
  # wildcard listeners and public-lb's apex listener share it.
  zone_certificate_secret = "wildcard-${replace(local.load_balancer_domain, ".", "-")}"

  # Hostnames the `*.<domain>` wildcard listener can't serve, keyed by listener
  # name: the bare domain, names more than one label deep, and other domains.
  # Each gets an HTTPS listener, and cert-manager-gateway-shim issues a cert per listener from the gateway's
  # `cert-manager.io/cluster-issuer` annotation. Delegated domains rely on
  # `cnameStrategy: Follow` on the issuer (see main_cert_manager.tf).
  public_lb_hosts = local.load_balancer_enabled ? {
    "https-apex"                = local.load_balancer_domain
    "https-map-wny"             = "map.wnymeshcore.org"
    "https-mqtt"                = "mqtt.mesh.${local.load_balancer_domain}"
    "https-mqtt-map-wny"        = "mqtt.map.wnymeshcore.org"
    "https-meshtender"          = "meshtender.com"
    "https-meshtender-wildcard" = "*.meshtender.com"
  } : {}

  # The hostnames each app serves on public-lb. Anything not in
  # public_lb_hosts is served by the wildcard `https` listener.
  #
  # MeshTender's apex is its canonical origin (WebAuthn RP) and must stay
  # first; the wildcard covers per-organization subdomains (which redirect to
  # the apex).
  public_lb_apps = {
    apex       = [local.load_balancer_domain]
    corescope  = ["mesh.${local.load_balancer_domain}", "map.wnymeshcore.org"]
    meshtender = ["meshtender.com", "*.meshtender.com"]
    mqtt       = ["mqtt.mesh.${local.load_balancer_domain}", "mqtt.map.wnymeshcore.org"]
  }

  public_lb_host_sections = { for section, hostname in local.public_lb_hosts : hostname => section }

  # Fully-formed Gateway API parentRefs per app, plus `https` for the wildcard.
  # Consumers splat these straight into an HTTPRoute's spec.parentRefs, so
  # adding/removing a listener is a producer-only change.
  public_refs_by_role = merge(
    {
      https = ["https"]
    },
    {
      for app, hostnames in local.public_lb_apps : app => [
        for hostname in hostnames : lookup(local.public_lb_host_sections, hostname, "https")
      ]
    }
  )
  public_refs = {
    for role, sections in local.public_refs_by_role : role => [
      for section in(local.load_balancer_enabled ? sections : []) : {
        namespace   = local.load_balancer_namespace
        name        = local.public_load_balancer_name
        sectionName = section
      }
    ]
  }

  private_https_refs = local.load_balancer_enabled ? [
    {
      namespace   = local.load_balancer_namespace
      name        = local.private_load_balancer_name
      sectionName = "https"
    }
  ] : []

  # public-lb's listener set: a catch-all HTTP listener, the wildcard HTTPS
  # listener, then an HTTPS listener per host.
  public_lb_listeners = concat(
    [
      # No hostname, so it matches every host and the https redirect covers
      # public_lb_hosts too. Only the redirect route (Same namespace) attaches,
      # and with no hostname on either side external-dns derives no records.
      {
        name     = "http"
        protocol = "HTTP"
        port     = 80
        allowedRoutes = {
          namespaces = {
            from = "Same"
          }
        }
      },
      {
        name     = "https"
        protocol = "HTTPS"
        port     = 443
        hostname = "*.${local.load_balancer_domain}"
        allowedRoutes = {
          namespaces = {
            from = "All"
          }
        }
        tls = {
          mode = "Terminate"
          certificateRefs = [
            {
              kind = "Secret"
              name = local.zone_certificate_secret
            }
          ]
        }
      }
    ],
    [
      for section, hostname in local.public_lb_hosts : {
        name     = section
        protocol = "HTTPS"
        port     = 443
        hostname = hostname
        allowedRoutes = {
          namespaces = {
            from = "All"
          }
        }
        tls = {
          mode = "Terminate"
          certificateRefs = [
            {
              kind = "Secret"
              # Strip any leading "*." so an apex listener and its wildcard
              # share one Secret. The gateway-shim then issues a single cert
              # with both SANs (e.g. meshtender.com + *.meshtender.com),
              # avoiding two separate DNS-01 challenges deadlocking on the
              # same _acme-challenge record. Also keeps "*" out of the name.
              # Our own zone apex uses the explicit zone cert instead.
              name = (
                hostname == local.load_balancer_domain
                ? local.zone_certificate_secret
                : replace(trimprefix(hostname, "*."), ".", "-")
              )
            }
          ]
        }
      }
    ]
  )
}

resource "kubernetes_namespace_v1" "load_balancer" {
  count = local.load_balancer_enabled ? 1 : 0

  metadata {
    name = "load-balancer"
  }
}

# Explicit rather than gateway-shim-issued: the shim builds a Certificate from
# the listeners of the one gateway that owns it, but this Secret is shared by
# both gateways, and only public-lb has the apex listener.
resource "kubectl_manifest" "load_balancer_zone_certificate" {
  count = local.load_balancer_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      namespace = local.load_balancer_namespace
      name      = local.zone_certificate_secret
    }

    spec = {
      issuerRef = {
        group = "cert-manager.io"
        kind  = "ClusterIssuer"
        name  = "lets-encrypt"
      }
      dnsNames = [
        local.load_balancer_domain,
        "*.${local.load_balancer_domain}"
      ]
      secretName = local.zone_certificate_secret
    }
  })

  depends_on = [kubectl_manifest.cert_manager_issuer_lets_encrypt]
}

resource "kubectl_manifest" "load_balancer_private" {
  count = local.load_balancer_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"

    metadata = {
      namespace = local.load_balancer_namespace
      name      = local.private_load_balancer_name
    }

    spec = {
      # Node-VLAN class (externalTrafficPolicy: Local) + L2 announcement, same
      # as public-lb. LAN-only (no port-forward), but pinned anyway so the whole
      # vlan /28 layout is declared and predictable. io.cilium/bgp=false keeps
      # the node-VLAN VIP off BGP (it's reached via the connected node subnet).
      gatewayClassName = "cilium-vlan"

      infrastructure = {
        labels = {
          "lb-pool"       = "vlan"
          "io.cilium/bgp" = "false"
        }
        annotations = {
          "io.cilium/lb-ipam-ips" = local.vlan_lb_ips.private
        }
      }

      listeners = [
        {
          name     = "http"
          protocol = "HTTP"
          port     = 80
          hostname = "*.${local.load_balancer_domain}"
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
        },
        {
          name     = "https"
          protocol = "HTTPS"
          port     = 443
          hostname = "*.${local.load_balancer_domain}"
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
          }
          tls = {
            mode = "Terminate"
            certificateRefs = [
              {
                kind = "Secret"
                name = local.zone_certificate_secret
              }
            ]
          }
        }
      ]
    }
  })

  depends_on = [
    kubectl_manifest.load_balancer_vlan_class,
    kubectl_manifest.load_balancer_vlan_pool
  ]
}

resource "kubectl_manifest" "load_balancer_public" {
  count = local.load_balancer_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"

    metadata = {
      namespace = local.load_balancer_namespace
      name      = local.public_load_balancer_name

      annotations = {
        "external-dns.alpha.kubernetes.io/target" = var.ddns_host
        "cert-manager.io/cluster-issuer"          = "lets-encrypt"
      }
    }

    spec = {
      # Node-VLAN class (externalTrafficPolicy: Local) + L2. The pinned VIP is
      # the router's port-forward target; io.cilium/bgp=false keeps that
      # node-VLAN /32 off BGP (reached via the connected node subnet, not a
      # route). external-dns still points the public records at the DDNS host.
      gatewayClassName = "cilium-vlan"

      infrastructure = {
        labels = {
          "lb-pool"       = "vlan"
          "io.cilium/bgp" = "false"
        }
        annotations = {
          "io.cilium/lb-ipam-ips" = local.vlan_lb_ips.public
        }
      }

      listeners = local.public_lb_listeners
    }
  })

  depends_on = [
    kubectl_manifest.load_balancer_vlan_class,
    kubectl_manifest.load_balancer_vlan_pool
  ]
}

resource "kubectl_manifest" "load_balancer_private_http_to_https" {
  count = local.load_balancer_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      namespace = local.load_balancer_namespace
      name      = "private-http-to-https"
    }

    spec = {
      parentRefs = [
        {
          namespace   = local.load_balancer_namespace
          name        = local.private_load_balancer_name
          sectionName = "http"
        }
      ]
      rules = [
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

resource "kubectl_manifest" "load_balancer_public_http_to_https" {
  count = local.load_balancer_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "HTTPRoute"

    metadata = {
      namespace = local.load_balancer_namespace
      name      = "public-http-to-https"
    }

    spec = {
      parentRefs = [
        {
          namespace   = local.load_balancer_namespace
          name        = local.public_load_balancer_name
          sectionName = "http"
        }
      ]
      rules = [
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
