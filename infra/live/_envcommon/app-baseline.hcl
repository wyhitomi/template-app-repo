# Shared configuration for the app-baseline unit across all environments.
# Per-env overrides live in infra/live/<env>/app-baseline/terragrunt.hcl.
terraform {
  source = "${get_repo_root()}/infra/terraform/modules/app-baseline"
}

inputs = {
  log_retention_days = 30
}
