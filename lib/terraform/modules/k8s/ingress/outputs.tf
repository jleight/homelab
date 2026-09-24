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
  value       = local.public_refs.https
}

output "public_corescope_refs" {
  description = "Public CoreScope app listeners (mesh.<domain> + map.wnymeshcore.org)."
  value       = local.public_refs.corescope
}

# Companion hostname lists for the routes whose served hostnames come from the
# listener set (parentRefs fan out across gateways; hostnames do not).
output "public_corescope_hostnames" {
  description = "Hostnames the CoreScope HTTPRoute serves."
  value       = local.load_balancer_enabled ? local.public_lb_apps.corescope : []
}

output "public_mqtt_hostnames" {
  description = "Hostnames the VerneMQ WSS HTTPRoute serves."
  value       = local.load_balancer_enabled ? local.public_lb_apps.mqtt : []
}

output "public_mqtt_refs" {
  description = "Public VerneMQ MQTT-over-WSS listeners."
  value       = local.public_refs.mqtt
}

output "public_meshtender_refs" {
  description = "Public MeshTender listeners (apex + wildcard)."
  value       = local.public_refs.meshtender
}

output "public_apex_refs" {
  description = "Public zone-apex (<domain>) HTTPS listener(s)."
  value       = local.public_refs.apex
}

output "private_https_refs" {
  description = "private-lb wildcard HTTPS listener (LAN-only)."
  value       = local.private_https_refs
}
