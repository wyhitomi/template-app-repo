# Contributing

## Setup

```bash
make setup     # installs pre-commit hooks (pre-commit + commit-msg)
make up        # local stack
```

## Branches & commits

- Branch from `main`: `feat/<topic>`, `fix/<topic>`, `chore/<topic>`, `docs/<topic>`.
- [Conventional Commits](https://www.conventionalcommits.org): `feat(api): add X`, `fix: handle Y`, `feat!: breaking change`.
- Keep PRs small and focused; one logical change per PR.

## Pull requests

- Fill in the PR template; link the issue.
- `make lint` and `make test` must pass locally.
- Green CI (`ci-ok`) and at least one approval from CODEOWNERS are required to merge.
- Squash-merge; the PR title becomes the commit message.

## Decisions

- Architecturally significant decision → add an [ADR](docs/adr/).
- Cross-team or costly-to-reverse proposal → open an [RFC](docs/rfc/) first.

## Releases

Maintainers tag `vMAJOR.MINOR.PATCH` on `main` following [SemVer](https://semver.org).
The tag promotes the already-tested image to production after approval.
