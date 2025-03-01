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

variable "k8s_cluster" {
  description = "Settings for the Kubernetes cluster."
  type = object({
    domain    = string
    subdomain = string
    ip_offset = number
    nodes = map(object({
      mac_address = string
    }))
    kgateway = optional(object({
      crds  = string
      chart = string
    }))
  })
}
