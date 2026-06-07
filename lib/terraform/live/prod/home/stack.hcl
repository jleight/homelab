inputs = {
  stack = "home"

  esphome = {
    renovate = "docker"
    image    = "ghcr.io/esphome/esphome"
    version  = "2026.5"
  }

  matter_server = {
    renovate = "docker"
    image    = "ghcr.io/matter-js/python-matter-server"
    version  = "8.1.2"
  }

  mqtt = {
    renovate   = "helm"
    repository = "https://vernemq.github.io/docker-vernemq"
    chart      = "vernemq"
    version    = "2.1.2"
  }

  zigbee2mqtt = {
    renovate = "docker"
    image    = "ghcr.io/koenkk/zigbee2mqtt"
    version  = "2.11.0"

    yq = {
      renovate = "docker"
      image    = "docker.io/mikefarah/yq"
      version  = "4.53.3"
    }
  }

  zwave_js_ui = {
    renovate = "docker"
    image    = "ghcr.io/zwave-js/zwave-js-ui"
    version  = "11.19.1"

    yq = {
      renovate = "docker"
      image    = "docker.io/mikefarah/yq"
      version  = "4.53.3"
    }
  }
}
