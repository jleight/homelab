variable "network" {
  description = "Settings for the home network."
  type = object({
    interface    = string
    gateway_ipv4 = string
    gateway_ipv6 = string
    gateway_as   = number
    nameservers  = set(string)
  })
}

variable "peer_groups" {
  description = "List of autonomous systems to peer with."
  type = list(object({
    name  = string
    as    = number
    peers = set(string)
  }))

  default = [
    {
      name  = "k8s-cluster-dev"
      as    = 65010
      peers = ["192.168.1.208", "192.168.1.209", "192.168.1.210"]
    },
    {
      name  = "k8s-cluster-prod"
      as    = 65020
      peers = ["192.168.1.224", "192.168.1.225", "192.168.1.226"]
    }
  ]
}
