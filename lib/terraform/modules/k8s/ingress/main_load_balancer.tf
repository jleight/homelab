locals {
  load_balancer_enabled = local.enabled && var.k8s_ingress.load_balancer.enabled

  load_balancer_namespace    = local.load_balancer_enabled ? kubernetes_namespace_v1.load_balancer[0].metadata[0].name : ""
  private_load_balancer_name = local.load_balancer_enabled ? "private-lb" : ""
  public_load_balancer_name  = local.load_balancer_enabled ? "public-lb" : ""

  load_balancer_section = local.load_balancer_enabled ? (local.cert_manager_enabled ? "https" : "http") : ""
  load_balancer_domain  = local.load_balancer_enabled ? var.k8s_cluster_domain : ""

  # Public-facing gateways every public route attaches to. A list so the refs
  # below fan out cleanly if we ever add another, but today it's just public-lb
  # (node-VLAN/L2, converted in place — no separate gateway).
  public_gateway_names = compact([
    local.public_load_balancer_name
  ])

  # Per-host HTTPS listeners on public-lb. The standard `https` listener uses
  # the `*.leightha.us` wildcard, which only covers one label deep — anything
  # with more labels (e.g. `mqtt.mesh.leightha.us`) or in a different domain
  # (e.g. `map.wnymeshcore.org`) needs its own listener with its own cert.
  # cert-manager-gateway-shim auto-issues a Certificate per listener from the
  # gateway's `cert-manager.io/cluster-issuer` annotation; delegated domains
  # rely on `cnameStrategy: Follow` on the issuer (see main_cert_manager.tf).
  public_lb_app_listeners = local.load_balancer_enabled ? [
    {
      section  = "https"
      hostname = "mesh.${local.load_balancer_domain}"
    },
    {
      section  = "https-map-wny"
      hostname = "map.wnymeshcore.org"
    },
  ] : []

  public_lb_mqtt_listeners = local.load_balancer_enabled ? [
    {
      section  = "https-mqtt"
      hostname = "mqtt.mesh.${local.load_balancer_domain}"
    },
    {
      section  = "https-mqtt-map-wny"
      hostname = "mqtt.map.wnymeshcore.org"
    },
  ] : []

  # MeshTender lives on its own apex domain (not a leightha.us subdomain), so it
  # needs dedicated listeners + certs, separate from the CoreScope app listeners.
  # The apex is the canonical origin (WebAuthn RP) and must stay first; the
  # wildcard covers per-organization subdomains (which redirect to the apex).
  public_lb_meshtender_listeners = local.load_balancer_enabled ? [
    {
      section  = "https-meshtender"
      hostname = "meshtender.com"
    },
    {
      section  = "https-meshtender-wildcard"
      hostname = "*.meshtender.com"
    },
  ] : []

  # All explicit-host listeners that need to be added to the public-lb spec
  # (the wildcard `https` listener already exists separately).
  public_lb_extra_listeners = [
    for l in concat(
      local.public_lb_app_listeners,
      local.public_lb_mqtt_listeners,
      local.public_lb_meshtender_listeners
    ) : l if l.section != "https"
  ]

  # Fully-formed Gateway API parentRefs, grouped by attachment role and already
  # fanned out across every public gateway (and, for the per-app groups, every
  # listener in the group). Consumers splat these straight into an HTTPRoute's
  # spec.parentRefs and never need to know gateway names or section names — so
  # adding/removing a gateway or listener is a producer-only change.
  public_refs_by_role = {
    for role, sections in {
      https      = [local.load_balancer_section]
      plex       = ["plex"]
      corescope  = [for l in local.public_lb_app_listeners : l.section]
      mqtt       = [for l in local.public_lb_mqtt_listeners : l.section]
      meshtender = [for l in local.public_lb_meshtender_listeners : l.section]
      } : role => flatten([
        for name in local.public_gateway_names : [
          for section in sections : {
            namespace   = local.load_balancer_namespace
            name        = name
            sectionName = section
          }
        ]
    ])
  }

  private_https_refs = local.load_balancer_enabled ? [
    {
      namespace   = local.load_balancer_namespace
      name        = local.private_load_balancer_name
      sectionName = local.load_balancer_section
    }
  ] : []

  # public-lb's listener set, extracted for readability (it's a large block).
  public_lb_listeners = concat(
    [
      {
        name     = "http"
        protocol = "HTTP"
        port     = 80
        hostname = "*.${local.load_balancer_domain}"
        allowedRoutes = {
          namespaces = {
            from = local.cert_manager_enabled ? "Same" : "All"
          }
        }
      },
      {
        name     = "plex"
        protocol = "HTTP"
        port     = 32400
        allowedRoutes = {
          namespaces = {
            from = "All"
          }
        }
      }
    ],
    local.cert_manager_enabled ? concat(
      [
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
                name = "wildcard-${replace(local.load_balancer_domain, ".", "-")}"
              }
            ]
          }
        }
      ],
      # Explicit-host listeners for names that aren't covered by the
      # wildcard cert (three-label leightha.us names, delegated domains).
      [
        for l in local.public_lb_extra_listeners : {
          name     = l.section
          protocol = "HTTPS"
          port     = 443
          hostname = l.hostname
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
                name = replace(trimprefix(l.hostname, "*."), ".", "-")
              }
            ]
          }
        }
      ]
    ) : []
  )
}

resource "kubernetes_namespace_v1" "load_balancer" {
  count = local.load_balancer_enabled ? 1 : 0

  metadata {
    name = "load-balancer"
  }
}

resource "kubectl_manifest" "load_balancer_private" {
  count = local.load_balancer_enabled ? 1 : 0

  yaml_body = yamlencode({
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"

    metadata = {
      namespace = local.load_balancer_namespace
      name      = local.private_load_balancer_name

      annotations = local.cert_manager_enabled ? {
        "cert-manager.io/cluster-issuer" = "lets-encrypt"
      } : {}
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

      listeners = concat(
        [
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
          }
        ],
        local.cert_manager_enabled ? [
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
                  name = "wildcard-${replace(local.load_balancer_domain, ".", "-")}"
                }
              ]
            }
          }
        ] : []
      )
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

      annotations = merge(
        {
          "external-dns.alpha.kubernetes.io/target" = var.ddns_host
        },
        local.cert_manager_enabled ? {
          "cert-manager.io/cluster-issuer" = "lets-encrypt"
        } : {},
      )
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
  count = local.load_balancer_enabled && local.cert_manager_enabled ? 1 : 0

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
  count = local.load_balancer_enabled && local.cert_manager_enabled ? 1 : 0

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
