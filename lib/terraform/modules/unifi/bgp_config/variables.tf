variable "network" {
  description = "Settings for the home network."
  type = object({
    interface   = string
    nameservers = set(string)
    gateway_as  = number
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
