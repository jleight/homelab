output "bgp_asn" {
  description = "The BGP ASN for the cluster."
  value       = var.k8s_ingress.load_balancer.bgp_asn
}

output "load_balancer_namespace" {
  value = local.load_balancer_namespace
}

output "load_balancer_name" {
  value = "load-balancer"
}

output "private_load_balancer_name" {
  value = local.private_load_balancer_name
}

output "public_load_balancer_name" {
  value = local.public_load_balancer_name
}

output "public_load_balancer_app_listeners" {
  description = "List of {section, hostname} pairs the CoreScope app HTTPRoute should attach to."
  value       = local.public_lb_app_listeners
}

output "public_load_balancer_mqtt_listeners" {
  description = "List of {section, hostname} pairs the VerneMQ WSS HTTPRoute should attach to."
  value       = local.public_lb_mqtt_listeners
}

output "load_balancer_section" {
  value = local.load_balancer_section
}

output "load_balancer_domain" {
  value = local.load_balancer_domain
}
