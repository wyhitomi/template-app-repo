include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "envcommon" {
  path   = "${get_repo_root()}/infra/live/_envcommon/app-baseline.hcl"
  expose = true
}

inputs = {
  log_retention_days = 30
  force_destroy      = true
}
