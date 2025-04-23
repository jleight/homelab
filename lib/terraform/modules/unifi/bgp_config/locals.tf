locals {
  prefix = [
    "! -*- bgp -*-",
    "!",
    "hostname $UDMP_HOSTNAME",
    "password zebra",
    "frr defaults traditional",
    "log file stdout",
    "!",
    "router bgp ${var.network.gateway_as}",
    "  bgp ebgp-requires-policy",
    "  bgp router-id ${module.ipam.lan.v4_gateway}",
    "  maximum-paths 4",
    "  !"
  ]

  neighbor_setups = flatten([
    for g in var.peer_groups : concat(
      [
        "neighbor ${g.name} peer-group",
        "neighbor ${g.name} remote-as ${g.asn}",
        "neighbor ${g.name} activate",
        "neighbor ${g.name} soft-reconfiguration inbound"
      ],
      [
        for p in g.peers :
        "neighbor ${p} peer-group ${g.name}"
      ]
    )
  ])

  address_family = [
    "address-family ipv4 unicast",
    "  redistribute connected"
  ]

  neighbor_activations = flatten([
    for g in var.peer_groups : [
      "  neighbor ${g.name} activate",
      "  neighbor ${g.name} route-map ALLOW-ALL in",
      "  neighbor ${g.name} route-map ALLOW-ALL out",
      "  neighbor ${g.name} next-hop-self"
    ]
  ])

  suffix = [
    "  exit-address-family",
    "  !",
    "route-map ALLOW-ALL permit 10",
    "!",
    "line vty",
    "!"
  ]

  config = join(
    "\n",
    local.prefix,
    [for l in local.neighbor_setups : "  ${l}"],
    local.address_family,
    local.neighbor_activations,
    local.suffix
  )
}
