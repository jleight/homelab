locals {
  matrix_fields = local.enabled ? {
    for f in flatten(data.onepassword_item.matrix[0].section[*].field) : f.label => f.value
  } : {}

  matrix_homeserver_url = "http://synapse.social.svc.cluster.local:8008"
  matrix_access_token   = lookup(local.matrix_fields, "access token", null)

  matrix_room_id = try(
    nonsensitive(local.matrix_fields["room id"]),
    lookup(local.matrix_fields, "room id", null)
  )
}
