variable "environment" {
  description = "The name of the environment."
  type        = string
}

locals {
  lan = {
    v4_cidr   = "192.168.1.0/24"
    v6_cidr   = "2600:4041:65e8:f900::/64"
    v6_prefix = "2600:4041:65e8:f900:"
  }

  nodes = {
    dev = {
      v4_cidr   = "192.168.1.208/28"
      v6_cidr   = local.lan.v6_cidr
      v6_prefix = local.lan.v6_prefix
    }

    prod = {
      v4_cidr   = "192.168.1.224/28"
      v6_cidr   = local.lan.v6_cidr
      v6_prefix = local.lan.v6_prefix
    }

    static = {
      v4_cidr   = "192.168.1.240/28"
      v6_cidr   = local.lan.v6_cidr
      v6_prefix = local.lan.v6_prefix
    }
  }

  resource_base = "10.92.0.0/14"

  resources = {
    dev = {
      pods           = cidrsubnet(local.resource_base, 4, 0)
      services       = cidrsubnet(local.resource_base, 4, 1)
      load_balancers = cidrsubnet(local.resource_base, 4, 2)
    }

    prod = {
      pods           = cidrsubnet(local.resource_base, 4, 4)
      services       = cidrsubnet(local.resource_base, 4, 5)
      load_balancers = cidrsubnet(local.resource_base, 4, 6)
    }

    static = {
      pods           = cidrsubnet(local.resource_base, 4, 8)
      services       = cidrsubnet(local.resource_base, 4, 9)
      load_balancers = cidrsubnet(local.resource_base, 4, 10)
    }
  }
}

output "lan" {
  value = local.lan
}

output "nodes" {
  value = local.nodes[var.environment]
}

output "resources" {
  value = local.resources[var.environment]
}
