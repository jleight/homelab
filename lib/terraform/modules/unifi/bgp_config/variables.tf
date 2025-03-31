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
    asn   = number
    peers = set(string)
  }))
}
