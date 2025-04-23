variable "environment" {
  description = "The name of the environment."
  type        = string
}

locals {
  lan = {
    v4_cidr    = "192.168.1.0/24"
    v6_cidr    = "2600:4041:65e8:f900::/64"
    v6_prefix  = "2600:4041:65e8:f900:"
    v4_gateway = "192.168.1.1"
    v6_gateway = "fe80::76ac:b9ff:fe45:8147"
  }

  nodes = {
    dev = {
      v4_cidr    = "192.168.2.0/24"
      v6_cidr    = "2600:4041:65e8:f901::/64"
      v6_prefix  = "2600:4041:65e8:f901:"
      v4_gateway = "192.168.2.1"
      v6_gateway = "fe80::76ac:b9ff:fe45:8147"
    }

    prod = {
      v4_cidr    = "192.168.3.0/24"
      v6_cidr    = "2600:4041:65e8:f902::/64"
      v6_prefix  = "2600:4041:65e8:f902:"
      v4_gateway = "192.168.3.1"
      v6_gateway = "fe80::76ac:b9ff:fe45:8147"
    }
  }

  resources_base = "10.92.0.0/14"

  resources = {
    dev = {
      pods           = cidrsubnet(local.resources_base, 4, 0)
      services       = cidrsubnet(local.resources_base, 4, 1)
      load_balancers = cidrsubnet(local.resources_base, 4, 2)
    }

    prod = {
      pods           = cidrsubnet(local.resources_base, 4, 4)
      services       = cidrsubnet(local.resources_base, 4, 5)
      load_balancers = cidrsubnet(local.resources_base, 4, 6)
    }
  }
}

output "lan" {
  value = local.lan
}

output "nodes" {
  value = lookup(local.nodes, var.environment, {})
}

output "resources" {
  value = lookup(local.resources, var.environment, {})
}
