inputs = {
  stack = "ai"

  anything_llm = {
    renovate = "docker"
    image    = "mintplexlabs/anythingllm"
    version  = "pg-1.16.0"
  }

  bifrost = {
    renovate = "docker"
    image    = "maximhq/bifrost"
    version  = "v2.0.0"

    lemonade = {
      url = "http://fwd01.leightha.us:8000"
    }
  }
}
