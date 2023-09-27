########################################################################################################################
# Locals
#

locals {}

########################################################################################################################
# AWS KMS
#

resource "aws_kms_key" "artifacts" {
  description             = "KMS key to encrypt domain artifacts/S3 bucket objects."
  deletion_window_in_days = 30
  tags = merge(
    {
      service = "kms"
    },
    local.common_tags
  )
}
resource "aws_kms_alias" "artifacts" {
  name          = "alias/artifacts_kms_key"
  target_key_id = aws_kms_key.artifacts.key_id
}

########################################################################################################################
# AWS S3
#

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.root_domain}-artifacts"
  force_destroy = false
  tags = merge(
    {
      service = "s3"
    },
    local.common_tags
  )
}

resource "aws_s3_bucket_ownership_controls" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "artifacts" {
  depends_on = [aws_s3_bucket_ownership_controls.artifacts]
  bucket     = aws_s3_bucket.artifacts.id
  acl        = "private"
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.artifacts.key_id
      sse_algorithm     = "aws:kms"
    }
  }
}
