inputs = {
  stack = "ai"

  bifrost = {
    renovate = "docker"
    image    = "maximhq/bifrost"
    version  = "v2.0.0"

    lemonade = {
      url = "http://fwd01.leightha.us:8000"
    }
  }

  open_webui = {
    renovate = "docker"
    image    = "ghcr.io/open-webui/open-webui"
    version  = "v0.11.1"
  }

  searxng = {
    renovate = "docker"
    image    = "docker.io/searxng/searxng"
    version  = "2026.8.29-d226b78bc"
  }
}
