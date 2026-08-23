inputs = {
  stack = "ai"

  bifrost = {
    renovate = "docker"
    image    = "maximhq/bifrost"
    version  = "v1.6.11"

    lemonade = {
      url = "http://fwd01.leightha.us:8000"
    }
  }
}
