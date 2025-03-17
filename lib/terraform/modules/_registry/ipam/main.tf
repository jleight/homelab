variable "environment" {
  description = "The name of the environment."
  type        = string
}

locals {
  cidr_v4 = {
    dev    = "192.168.1.208/28"
    prod   = "192.168.1.224/28"
    static = "192.168.1.240/28"
  }

  cidr_v6 = {
    dev    = "2600:4041:65e8:f900::1/64"
    prod   = "2600:4041:65e8:f900::1/64"
    static = "2600:4041:65e8:f900::1/64"
  }

  prefix_v6 = {
    dev    = "2600:4041:65e8:f900:"
    prod   = "2600:4041:65e8:f900:"
    static = "2600:4041:65e8:f900:"
  }
}

output "cidr_v4" {
  value = local.cidr_v4[var.environment]
}

output "cidr_v6" {
  value = local.cidr_v6[var.environment]
}

output "prefix_v6" {
  value = local.prefix_v6[var.environment]
}
