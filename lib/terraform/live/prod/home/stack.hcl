inputs = {
  stack = "home"

  esphome = {
    renovate = "docker"
    image    = "ghcr.io/esphome/esphome"
    version  = "2026.8"
  }

  home_assistant = {
    renovate = "docker"
    image    = "ghcr.io/home-assistant/home-assistant"
    version  = "2026.9.0"

    yq = {
      renovate = "docker"
      image    = "docker.io/mikefarah/yq"
      version  = "4.53.6"
    }
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
    version    = "2.2.0"
  }

  zigbee2mqtt = {
    renovate = "docker"
    image    = "ghcr.io/koenkk/zigbee2mqtt"
    version  = "2.13.0"

    yq = {
      renovate = "docker"
      image    = "docker.io/mikefarah/yq"
      version  = "4.53.6"
    }
  }

  zwave_js_ui = {
    renovate = "docker"
    image    = "ghcr.io/zwave-js/zwave-js-ui"
    version  = "11.23.0"

    yq = {
      renovate = "docker"
      image    = "docker.io/mikefarah/yq"
      version  = "4.53.6"
    }
  }
}
