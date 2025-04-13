output "bgp_asn" {
  description = "The BGP ASN for the cluster."
  value       = var.k8s_ingress.load_balancer.bgp_asn
}

output "load_balancer_namespace" {
  value = local.load_balancer_namespace
}

output "load_balancer_name" {
  value = local.load_balancer_name
}

output "load_balancer_domain" {
  value = local.load_balancer_domain
}
