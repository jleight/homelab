output "bgp_asn" {
  description = "The BGP ASN for the cluster."
  value       = var.k8s_ingress.load_balancer.bgp_asn
}
