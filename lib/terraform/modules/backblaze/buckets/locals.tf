locals {
  # s3_api_url looks like https://s3.us-west-001.backblazeb2.com, and the region
  # is the middle label. Clients that speak s3 need it separately from the URL.
  s3_region = one(regex("^https://s3\\.([^.]+)\\.", data.b2_account_info.current.s3_api_url))
}
