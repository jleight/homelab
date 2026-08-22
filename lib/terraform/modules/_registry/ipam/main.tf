variable "environment" {
  description = "The name of the environment."
  type        = string
}

locals {
  lan = {
    v4_cidr    = "192.168.1.0/24"
    v6_cidr    = "2600:4041:65fc:4a00::/64"
    v6_prefix  = "2600:4041:65fc:4a00:"
    v4_gateway = "192.168.1.1"
    v6_gateway = "fe80::76ac:b9ff:fe45:8146"
  }

  nodes = {
    dev = {
      v4_cidr    = "192.168.2.0/24"
      v6_cidr    = "2600:4041:65fc:4a01::/64"
      v6_prefix  = "2600:4041:65fc:4a01:"
      v4_gateway = "192.168.2.1"
      v6_gateway = "fe80::76ac:b9ff:fe45:8146"
    }

    prod = {
      v4_cidr    = "192.168.3.0/24"
      v6_cidr    = "2600:4041:65fc:4a02::/64"
      v6_prefix  = "2600:4041:65fc:4a02:"
      v4_gateway = "192.168.3.1"
      v6_gateway = "fe80::76ac:b9ff:fe45:8146"
    }
  }

  resources_base = "10.92.0.0/14"

  resources = {
    dev = {
      pods     = cidrsubnet(local.resources_base, 4, 0)
      services = cidrsubnet(local.resources_base, 4, 1)
    }

    prod = {
      pods     = cidrsubnet(local.resources_base, 4, 4)
      services = cidrsubnet(local.resources_base, 4, 5)
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

output "load_balancers" {
  value = {
    v4_cidr = cidrsubnet(lookup(local.nodes, var.environment, {}).v4_cidr, 4, 15)
  }
}
