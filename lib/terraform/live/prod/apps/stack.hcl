inputs = {
  stack = "apps"

  isponsorblocktv = {
    renovate = "docker"
    image    = "dmunozv04/isponsorblocktv"
    version  = "v2.4.0"

    devices = [
      {
        name      = "Apple TV 4K"
        screen_id = "1m9u0bfoh4um94gm2r994bhdt5"
      }
    ]
  }
}
