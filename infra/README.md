# Infrastructure

```text
infra/
├── terraform/modules/        # Reusable modules (pure Terraform, no env knowledge)
│   └── app-baseline/
├── live/                     # Terragrunt: WHAT is deployed WHERE
│   ├── root.hcl              # remote state, provider, common inputs
│   ├── _envcommon/           # unit config shared by all envs
│   ├── dev/  env.hcl + <unit>/terragrunt.hcl
│   ├── stg/
│   └── prd/
└── deploy/helm/app/          # Kubernetes deployment chart + values-<env>.yaml
```

## Conventions

- **Modules** are environment-agnostic; all differences are inputs.
- **One unit = one state file.** Add a unit by creating `live/_envcommon/<unit>.hcl`
  and `live/<env>/<unit>/terragrunt.hcl` in each env.
- **Isolation:** one cloud account + state bucket per environment (`env.hcl`).
- **Versions** of terraform/terragrunt/tflint/helm are pinned in `/.tool-versions`.
- **Cloud:** AWS is the reference. To switch, change the provider/backend in
  `root.hcl`, the module resources, and `.github/actions/cloud-auth`.

## Usage

```bash
make tf-validate ENV=dev
make tf-plan     ENV=stg
make tf-apply    ENV=prd   # normally only CI does this, on a release tag
make deploy-diff ENV=stg IMAGE_TAG=sha-<commit>   # render Helm manifests
```

## Bootstrap (once per account)

1. Create the state bucket `template-app-tfstate-<account>-<region>` (versioned, encrypted),
   or let Terragrunt create it on first run with admin credentials.
2. Create the GitHub OIDC provider and roles:
   - plan role (read-only) → trust `repo:OWNER/REPO:pull_request` and `ref:refs/heads/main`
   - apply/deploy roles → trust `repo:OWNER/REPO:environment:<env>`
3. Put role ARNs in GitHub (see `docs/architecture/delivery-pipeline.md`).
