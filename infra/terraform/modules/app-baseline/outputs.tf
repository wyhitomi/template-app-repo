output "artifacts_bucket" {
  description = "Name of the artifacts bucket."
  value       = aws_s3_bucket.artifacts.bucket
}

output "log_group_name" {
  description = "CloudWatch log group for the application."
  value       = aws_cloudwatch_log_group.app.name
}
