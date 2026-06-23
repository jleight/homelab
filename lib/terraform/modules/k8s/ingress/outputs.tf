output "bgp_asn" {
  description = "The BGP ASN for the cluster."
  value       = var.k8s_ingress.load_balancer.bgp_asn
}

output "load_balancer_namespace" {
  value = local.load_balancer_namespace
}

output "load_balancer_domain" {
  value = local.load_balancer_domain
}

# Fully-formed Gateway API parentRefs, one list per attachment role. Splat
# directly into an HTTPRoute's spec.parentRefs — consumers never assemble
# {namespace, name, sectionName} or know which gateways/listeners back a role.
# The public_* roles fan out across every public gateway (just public-lb today)
# and, for the per-app groups, every listener in the group.

output "public_https_refs" {
  description = "Public wildcard *.<domain> HTTPS listener(s)."
  value       = local.public_refs_by_role.https
}

output "public_plex_refs" {
  description = "Public Plex listener (HTTP :32400)."
  value       = local.public_refs_by_role.plex
}

output "public_corescope_refs" {
  description = "Public CoreScope app listeners (mesh.<domain> + map.wnymeshcore.org)."
  value       = local.public_refs_by_role.corescope
}

# Companion hostname lists for the routes whose served hostnames come from the
# listener set (parentRefs fan out across gateways; hostnames do not).
output "public_corescope_hostnames" {
  description = "Hostnames the CoreScope HTTPRoute serves."
  value       = [for l in local.public_lb_app_listeners : l.hostname]
}

output "public_mqtt_hostnames" {
  description = "Hostnames the VerneMQ WSS HTTPRoute serves."
  value       = [for l in local.public_lb_mqtt_listeners : l.hostname]
}

output "public_mqtt_refs" {
  description = "Public VerneMQ MQTT-over-WSS listeners."
  value       = local.public_refs_by_role.mqtt
}

output "public_meshtender_refs" {
  description = "Public MeshTender listeners (apex + wildcard)."
  value       = local.public_refs_by_role.meshtender
}

output "private_https_refs" {
  description = "private-lb wildcard HTTPS listener (LAN-only)."
  value       = local.private_https_refs
}
