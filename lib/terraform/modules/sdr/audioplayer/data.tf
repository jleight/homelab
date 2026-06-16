# Fetch audioplayer.php from upstream rather than vendoring it. Tracks master;
# pin to a commit SHA in the URL if you want it frozen. The patches below are
# guarded by a precondition (main_config.tf) so an upstream change to the lines
# we rewrite fails the apply loudly instead of silently mis-patching.
data "http" "audioplayer" {
  count = local.enabled ? 1 : 0

  url = var.audioplayer.script_url
}
