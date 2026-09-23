# Module: `app-baseline`

Baseline resources for a service: a private, versioned, KMS-encrypted S3
bucket and a CloudWatch log group. It exists mainly to show the module ↔
Terragrunt wiring. Replace or extend it with your real modules.

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `name` | `string` | n/a | Application name / prefix |
| `environment` | `string` | n/a | `dev`, `stg` or `prd` |
| `log_retention_days` | `number` | `30` | Log retention |
| `force_destroy` | `bool` | `false` | Allow non-empty bucket deletion |
| `tags` | `map(string)` | `{}` | Extra tags |

## Outputs

| Name | Description |
|------|-------------|
| `artifacts_bucket` | Bucket name |
| `log_group_name` | Log group name |
