variable "sudo_password" {
  description = "The sudo password for this machine."
  type        = string
  sensitive   = true
}

variable "dot_kube_directory" {
  description = "Path to your .kube directory."
  type        = string
}

variable "network_interface" {
  description = "The network interface that accesses the home network."
  type        = string
}

variable "network_subnet" {
  description = "The IP subnet for the home network."
  type        = string
}

variable "k8s_cluster_ip_offset" {
  description = "The IP address offset for the Kubernetes cluster based on `network_subnet`."
  type        = number
}

variable "k8s_cluster_domain" {
  description = "The domain of the Kubernetes cluster."
  type        = string
}

variable "k8s_cluster_subdomain" {
  description = "The subdomain of the Kubernetes cluster."
  type        = string
}

variable "k8s_cluster_nodes" {
  description = "The nodes of the Kubernetes cluster."
  type = map(object({
    mac_address = string
  }))
}
