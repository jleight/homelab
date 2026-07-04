locals {
  kubeconfig_file = "${var.env_directory}/${local.environment}/.kubeconfig"

  name      = local.component
  namespace = var.namespace

  web_port = 8000

  hostname = "${var.pymc.subdomain}.${var.gateway_domain}"

  # SQLite lives in the data dir; Litestream streams its WAL to the NAS-backed
  # backup PVC. The restore initContainer reads the same path so a fresh PVC
  # (e.g. after recreating it on another node) seeds from the latest replica.
  sqlite_path = "/var/lib/openhop_repeater/repeater.db"
  backup_path = "/backup/pymc"

  litestream_config = yamlencode({
    dbs = [
      {
        path = local.sqlite_path
        replicas = [
          {
            type                     = "file"
            path                     = local.backup_path
            retention                = "168h"
            retention-check-interval = "1h"
            sync-interval            = "1s"
          }
        ]
      }
    ]
  })

  # Secrets from the "pyMC - Admin" 1Password item. The identity key is stored
  # already base64-encoded in the "private key b64" field, exactly the form pymc's
  # `identity_key: !!binary` expects — so it drops straight into the rendered
  # overrides with no conversion.
  admin_password = local.enabled ? try(data.onepassword_item.admin[0].password, "") : ""

  identity_key_b64 = local.enabled ? try(one(flatten([
    for section in data.onepassword_item.admin[0].section :
    [for field in section.field : field.value if lower(field.label) == "private key b64"]
  ])), "") : ""

  # Each companion's TCP port: base + its position in the list. Appending keeps
  # existing companions' ports stable.
  companion_ports = {
    for i, c in var.pymc.companions : c.name => var.pymc.companion_port_base + i
  }

  companions_hostname = coalesce(var.pymc.companions_hostname, "${local.name}-companions-${local.environment}")

  # Room-server credentials from the per-server 1Password items: guest password
  # from the standard `password` field, admin password from the "admin password"
  # custom field.
  room_server_guest_passwords = {
    for name, item in data.onepassword_item.room_server : name => item.password
  }

  room_server_admin_passwords = {
    for name, item in data.onepassword_item.room_server : name => one(flatten([
      for section in item.section :
      [for field in section.field : field.value if lower(field.label) == "admin password"]
    ]))
  }

  # The additional identities pymc manages. identity_key is hex here (the app
  # does bytes.fromhex), so unlike the repeater's own key these encode cleanly
  # via yamlencode — no template needed.
  identities = {
    room_servers = local.enabled ? [
      for rs in var.pymc.room_servers : {
        name         = rs.name
        identity_key = random_id.room_server_identity[rs.name].hex
        type         = "room_server"
        settings = merge(
          {
            node_name      = coalesce(rs.node_name, rs.name)
            admin_password = local.room_server_admin_passwords[rs.name]
            guest_password = local.room_server_guest_passwords[rs.name]
          },
          rs.latitude == null ? {} : { latitude = rs.latitude },
          rs.longitude == null ? {} : { longitude = rs.longitude },
        )
      }
    ] : []

    companions = local.enabled ? [
      for c in var.pymc.companions : {
        name         = c.name
        identity_key = random_id.companion_identity[c.name].hex
        type         = "companion"
        settings = {
          node_name    = coalesce(c.node_name, c.name)
          tcp_port     = local.companion_ports[c.name]
          bind_address = "0.0.0.0"
        }
      }
    ] : []
  }

  identities_yaml = (length(local.identities.companions) + length(local.identities.room_servers)) > 0 ? yamlencode({ identities = local.identities }) : ""

  # The image installs its package into the repeater user's home; we run as root
  # (to open the root-owned serial device node), so HOME must point there for
  # `python3 -m repeater.main` to resolve the user site-packages.
  home_dir = "/home/repeater"

  # The subset of config.yaml that Terraform owns. The init container deep-merges
  # it over the live config every start, so these keys are always enforced while
  # everything else stays app/user-owned (and the app's own entrypoint backfills
  # any missing defaults from its bundled config.yaml.example). The repeater's own
  # !!binary identity key needs the template; the rest (incl. the hex-keyed
  # identities) is plain YAML appended as a second top-level block.
  overrides_rendered = join("\n", compact([
    templatefile("${path.module}/etc/overrides.yaml.tftpl", {
      serial_port      = var.pymc.serial_port
      baud_rate        = var.pymc.baud_rate
      admin_password   = local.admin_password
      identity_key_b64 = local.identity_key_b64
      storage_dir      = dirname(local.sqlite_path)
    }),
    local.identities_yaml,
  ]))

  # Pod-roll trigger on the non-secret structural config (secrets come from
  # 1Password and rotate rarely; `kubectl rollout restart` picks those up).
  config_checksum = sha256(jsonencode({
    serial_port = var.pymc.serial_port
    baud_rate   = var.pymc.baud_rate
    companions  = local.companion_ports
    room_servers = [
      for rs in var.pymc.room_servers : {
        name      = rs.name
        node_name = coalesce(rs.node_name, rs.name)
        latitude  = rs.latitude
        longitude = rs.longitude
      }
    ]
  }))

  match_labels = {
    "app.kubernetes.io/name"     = local.name
    "app.kubernetes.io/instance" = local.name
  }

  labels = merge(
    local.match_labels,
    {
      "app.kubernetes.io/version"    = var.pymc.version
      "app.kubernetes.io/component"  = local.name
      "app.kubernetes.io/part-of"    = local.stack
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  )
}
