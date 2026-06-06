# Z-Wave network security keys (128-bit each). Generated once and held in
# Terraform state, then written into settings.json via the managed Secret —
# replacing whatever zwave-js-ui auto-generated. These MUST stay stable:
# changing them would orphan every securely-included device and force a
# re-include. Safe to (re)generate now only because nothing is paired yet.
resource "random_id" "zwave_key" {
  for_each = local.enabled ? toset(["S0_Legacy", "S2_Unauthenticated", "S2_Authenticated", "S2_AccessControl"]) : []

  byte_length = 16
}

# Z-Wave Long Range uses its own S2 keys (no S0, no Unauthenticated).
resource "random_id" "zwave_key_lr" {
  for_each = local.enabled ? toset(["S2_Authenticated", "S2_AccessControl"]) : []

  byte_length = 16
}
