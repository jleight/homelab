locals {
  searxng_domain = "${var.searxng.subdomain}.${var.searxng.gateway_domain}"
  searxng_url    = "http://searxng.${module.namespace.name}.svc.cluster.local:8080"

  lemonade_base_url = "${var.lemonade.url}/v1"

  open_webui_domain    = "${var.open_webui.subdomain}.${var.open_webui.gateway_domain}"
  open_webui_redis_url = "redis://open-webui-cache.${module.namespace.name}.svc.cluster.local:6379/0"
  open_webui_db        = module.database_cluster.databases["openwebui"]

  open_webui_database_url = join("", [
    "postgresql://${local.open_webui_db.username}:${module.database_cluster.passwords["openwebui"]}",
    "@${module.database_cluster.host}:${module.database_cluster.port}/${local.open_webui_db.database}",
    "?sslmode=require"
  ])

  turnstone_domain      = "${var.turnstone.subdomain}.${var.turnstone.gateway_domain}"
  turnstone_console_url = "http://turnstone-console.${module.namespace.name}.svc.cluster.local:8090"
  turnstone_db          = module.database_cluster.databases["turnstone"]

  turnstone_database_url = join("", [
    "postgresql+psycopg://${local.turnstone_db.username}:${module.database_cluster.passwords["turnstone"]}",
    "@${module.database_cluster.host}:${module.database_cluster.port}/${local.turnstone_db.database}"
  ])
}
