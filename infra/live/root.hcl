# -----------------------------------------------------------------------------
# Root Terragrunt configuration, included by every unit under infra/live/<env>/.
# Provides: remote state, provider generation and common inputs.
# -----------------------------------------------------------------------------
locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  app_name       = "template-app"
  environment    = local.env_vars.locals.environment
  aws_region     = local.env_vars.locals.aws_region
  aws_account_id = local.env_vars.locals.aws_account_id

  common_tags = {
    Application = local.app_name
    Environment = local.environment
    ManagedBy   = "terragrunt"
    Repository  = "template-app-repo"
  }
}

# One state bucket per account/env; native S3 locking (no DynamoDB needed).
remote_state {
  backend = "s3"
  config = {
    bucket       = "${local.app_name}-tfstate-${local.aws_account_id}-${local.aws_region}"
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = local.aws_region
    encrypt      = true
    use_lockfile = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "aws" {
      region              = "${local.aws_region}"
      allowed_account_ids = ["${local.aws_account_id}"]

      default_tags {
        tags = ${jsonencode(local.common_tags)}
      }
    }
  EOF
}

inputs = {
  name        = local.app_name
  environment = local.environment
  tags        = local.common_tags
}
