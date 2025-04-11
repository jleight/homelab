variable "prefix" {
  description = "The IPv6 prefix."
  type        = string
  default     = "fe80::"
}

variable "mac_address" {
  description = "The MAC address."
  type        = string
}

locals {
  split = split(":", var.mac_address)

  segment_1 = format("%s%s", local.split[0], local.split[1])
  segment_2 = format("%sff", local.split[2])
  segment_3 = format("fe%s", local.split[3])
  segment_4 = format("%s%s", local.split[4], local.split[5])

  segment_1_b10 = parseint(local.segment_1, 16)
  segment_1_b2  = format("%016b", local.segment_1_b10)

  segment_1_bit_6          = substr(local.segment_1_b2, 6, 1)
  segment_1_bit_6_inverted = local.segment_1_bit_6 == "0" ? "1" : "0"

  segment_1_b2_inverted = format(
    "%s%s%s",
    substr(local.segment_1_b2, 0, 6),
    local.segment_1_bit_6_inverted,
    substr(local.segment_1_b2, 7, 9)
  )

  segment_1_b10_inverted = parseint(local.segment_1_b2_inverted, 2)
  segment_1_inverted     = format("%x", local.segment_1_b10_inverted)

  slaac = format(
    "%s%s:%s:%s:%s",
    var.prefix,
    local.segment_1_inverted,
    local.segment_2,
    local.segment_3,
    local.segment_4
  )

  trimmed    = replace(local.slaac, "/:0{1,3}/", ":")
  compressed = replace(local.trimmed, "/^(.*?)(?::0)+(.*)$/", "$1::$2")
}

output "ip" {
  value = local.compressed
}
