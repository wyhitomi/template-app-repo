# template-app

<!-- Badges: replace OWNER/REPO -->
[![CI](https://github.com/OWNER/REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/ci.yml)
[![CD](https://github.com/OWNER/REPO/actions/workflows/cd.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/cd.yml)
[![Infrastructure](https://github.com/OWNER/REPO/actions/workflows/infra.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/infra.yml)

_One sentence: what this service does and for whom._

> [!TIP]
> **Using this template?** Click **Use this template**, clone, then run
> `./scripts/bootstrap.sh <app-name> <github-owner>/<repo>` and follow
> [Template setup](#template-setup). Delete this tip afterwards.

## Table of contents

- [Overview](#overview)
- [Quick start](#quick-start)
- [Repository layout](#repository-layout)
- [Development workflow](#development-workflow)
- [Testing](#testing)
- [CI/CD & environments](#cicd--environments)
- [Infrastructure](#infrastructure)
- [Configuration](#configuration)
- [Operations](#operations)
- [Template setup](#template-setup)
- [Contributing](#contributing)

## Overview

<Describe the problem, the main capabilities and the key users. Link the
[architecture overview](docs/architecture/README.md).>

| | |
|---|---|
| **Owner** | @OWNER/app-team |
| **Runtime** | Container on Kubernetes (Helm) |
| **Environments** | `dev` · `stg` · `prd` |
| **SLO** | 99.9% availability, p95 < 300 ms |
| **Runbook** | `docs/architecture/` <link> |

## Quick start

Prerequisites: Docker (with Compose v2), GNU Make, Python 3.12+, and
[pre-commit](https://pre-commit.com). Tool versions for IaC live in
[`.tool-versions`](.tool-versions) (`mise install` / `asdf install`).

```bash
make setup   # git hooks + .env
make up      # build & run the stack -> http://localhost:8080/healthz
make test    # unit tests
make help    # every available target
```

## Repository layout

```text
.
├── app/                      # Application source, unit tests, Dockerfile
├── tests/                    # integration / e2e / performance (k6) suites
├── infra/
│   ├── terraform/modules/    # Reusable Terraform modules
│   ├── live/{dev,stg,prd}/   # Terragrunt: one folder per environment
│   └── deploy/helm/app/      # Helm chart + values-<env>.yaml
├── docs/
│   ├── architecture/         # How the system works today
│   ├── adr/                  # Architecture Decision Records
│   └── rfc/                  # Proposals under discussion
├── scripts/                  # Helper scripts (bootstrap, ...)
├── .github/
│   ├── workflows/            # ci, post-merge-tests, infra, cd (+ reusable _*.yml)
│   ├── actions/              # Composite actions (setup-tools, cloud-auth)
│   └── ISSUE_TEMPLATE/       # Bug / feature / tech-debt forms
├── docker-compose.yml        # Local + CI test stack
├── Makefile                  # Single interface for humans and CI
└── .pre-commit-config.yaml   # Lint, format, security hooks
```

## Development workflow

1. Create a branch from `main` (`feat/...`, `fix/...`).
2. Commit using [Conventional Commits](https://www.conventionalcommits.org) (enforced by a hook).
3. Open a PR; CI runs and a green build auto-deploys to **dev**.
4. After review + merge, post-merge suites run and the build is promoted to **stg**.
5. Tag a release (`git tag v1.2.3 && git push --tags`) to promote to **prd** (requires approval).

Significant decisions → [ADR](docs/adr/). Larger proposals → [RFC](docs/rfc/).

## Testing

| Command | What |
|---------|------|
| `make test` | Unit tests |
| `make up && make test-integration` | Integration tests against the local stack |
| `make up && make test-e2e` | End-to-end journeys |
| `make up && make test-perf` | k6 load test with SLO thresholds |
| `make test-e2e BASE_URL=https://...` | Any suite against a deployed env |

## CI/CD & environments

| Event | Infra (`infra.yml`) | App (`cd.yml`) |
|-------|---------------------|----------------|
| Pull request | plan + apply **dev** | deploy **dev** |
| Merge to `main` | plan + apply **stg** | post-merge tests → deploy **stg** |
| Tag `vX.Y.Z` | plan + apply **prd** (approval) | promote image → deploy **prd** (approval) |

Details, required secrets/variables and diagrams: [delivery pipeline](docs/architecture/delivery-pipeline.md).

## Infrastructure

```bash
make tf-plan  ENV=dev
make tf-apply ENV=dev
make deploy   ENV=dev IMAGE_TAG=sha-<commit>
```

See [infra/README.md](infra/README.md).

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `APP_PORT` | `8080` | HTTP port |
| `APP_ENV` | `local` | `local`, `dev`, `stg`, `prd` |
| `LOG_LEVEL` | `info` | `debug`, `info`, `warning`, `error` |

Copy `.env.example` to `.env` for local overrides. Never commit secrets.

## Operations

- **Health:** `GET /healthz` (liveness), `GET /readyz` (readiness)
- **Dashboards / alerts:** <links>
- **Rollback:** re-run CD with a previous `image-tag`, or `make rollback ENV=<env>`
- **On-call:** <link>

## Template setup

After creating a repo from this template:

1. `./scripts/bootstrap.sh <app-name> <owner>/<repo>`: renames placeholders.
2. Replace the sample app in `app/` with your stack; keep the `make` targets (`build`, `test`, `image`) as the contract CI calls.
3. Create GitHub Environments `dev`, `stg`, `prd` and variables as listed in the [delivery pipeline doc](docs/architecture/delivery-pipeline.md#required-github-configuration).
4. Set account IDs/regions in `infra/live/<env>/env.hcl` and create the state buckets.
5. Protect `main` (required check: `ci-ok`) and restrict `v*` tags.
6. Update `CODEOWNERS`, this README and `docs/architecture/README.md`.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md).
