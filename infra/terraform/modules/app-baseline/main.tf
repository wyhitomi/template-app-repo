# Baseline cloud resources every service needs. Extend or replace with your
# own modules (network, database, cluster, queues...).

locals {
  prefix = "${var.name}-${var.environment}"
  tags   = merge(var.tags, { Module = "app-baseline" })
}

resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${local.prefix}-"
  force_destroy = var.force_destroy
  tags          = local.tags
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/app/${local.prefix}"
  retention_in_days = var.log_retention_days
  tags              = local.tags
}
