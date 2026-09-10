resource "b2_bucket" "terraform_state" {
  bucket_name = var.terraform_state_bucket_name
  bucket_type = "allPrivate"

  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "b2_bucket" "k8s_prod_backup" {
  bucket_name = var.k8s_prod_backup_bucket_name
  bucket_type = "allPrivate"

  default_server_side_encryption {
    algorithm = "AES256"
    mode      = "SSE-B2"
  }

  # B2 hides deleted files rather than removing them and bills for the hidden
  # versions indefinitely, so a sync target needs this or it only ever grows --
  # longhorn retention prunes tens of thousands of blocks at a time. Cancelling
  # unfinished large files cleans up the multipart uploads that an interrupted
  # sync leaves behind, which are billed the same way.
  lifecycle_rules {
    file_name_prefix                                       = ""
    days_from_hiding_to_deleting                           = 1
    days_from_starting_to_canceling_unfinished_large_files = 1
  }

  lifecycle {
    prevent_destroy = true
  }
}
