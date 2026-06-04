# Generated 32-byte identity keys for each companion and room server, keyed by
# name so they stay stable as the lists are reordered. pymc reads these as hex
# (bytes.fromhex), unlike the repeater's own !!binary key.
resource "random_id" "companion_identity" {
  for_each = local.enabled ? { for c in var.pymc.companions : c.name => c } : {}

  byte_length = 32
}

resource "random_id" "room_server_identity" {
  for_each = local.enabled ? { for rs in var.pymc.room_servers : rs.name => rs } : {}

  byte_length = 32
}
