# 0003. Terragrunt per-environment layout

- **Status:** Accepted
- **Date:** 2026-09-23

## Context

We need the same infrastructure in `dev`, `stg` and `prd` with isolated state,
different sizing, and without copy-pasting Terraform.

## Decision

- Reusable, versioned Terraform **modules** in `infra/terraform/modules/`.
- Terragrunt **live** tree `infra/live/<env>/<unit>/` with a shared `root.hcl`
  (remote state, provider) and `_envcommon/` for config shared across envs.
- One cloud account and one state bucket per environment; native S3 locking.
- Promotion: PR → dev, `main` → stg, tag → prd (see delivery pipeline).

## Consequences

- **Positive:** DRY, blast radius limited to one env, env differences are explicit and small.
- **Negative:** Terragrunt is an extra tool to learn and pin.
