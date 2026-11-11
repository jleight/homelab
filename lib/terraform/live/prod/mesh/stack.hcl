inputs = {
  stack = "mesh"

  core_scope = {
    renovate = "docker"
    image    = "ghcr.io/kpa-clawbot/corescope"
    version  = "v3.17.0"

    default_region = "BUF"

    regions = {
      "BUF" = "Buffalo"
      "ROC" = "Rochester"
      "YKF" = "Breslau"
      "YLK" = "Barrie"
      "YTR" = "Trenton"
      "YYZ" = "Toronto"
    }

    hash_regions = [
      "#east",
      "#na",
      "#northeast",
      "#onny",
      "#us",
      "#us-ny",
      "#us-ny-buf",
      "#us-ny-wny",
      "#wny"
    ]

    map_defaults = {
      center = [43.01, -78.77]
      zoom   = 10
    }

    channel_keys = {
      "Public" = "8b3387e9c5cdea6ac9e5edbaa115cd72"
    }

    hash_channels = [
      "#bbq",
      "#east",
      "#emergency",
      "#na",
      "#northeast",
      "#ny",
      "#onny",
      "#test",
      "#us",
      "#wardriving",
      "#weather",
      "#wny",
      "#xerobot"
    ]

    litestream = {
      renovate = "docker"
      image    = "litestream/litestream"
      version  = "0.5.18"
    }
  }

  mqtt = {
    renovate   = "helm"
    repository = "https://vernemq.github.io/docker-vernemq"
    chart      = "vernemq"
    version    = "2.2.1"

    auth = {
      renovate = "docker"
      image    = "python"
      version  = "3.15-slim"
    }
  }

  meshtender = {
    image = "ghcr.io/meshtender/meshtender"
    tag   = "main"

    replicas = 2

    hosts = {
      root    = "meshtender.com"
      www     = "www.meshtender.com"
      auth    = "auth.meshtender.com"
      primary = "app.meshtender.com"
    }

    mail = {
      from     = "MeshTender <support@mail.meshtender.com>"
      reply_to = "MeshTender Support <support@meshtender.com>"
    }
  }
}
