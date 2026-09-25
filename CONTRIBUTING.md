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

Releases are automated by [release-please](https://github.com/googleapis/release-please)
(`.github/workflows/release-please.yml`). Every merge to `main` opens or updates a
**Release PR** with the next [SemVer](https://semver.org) version and the generated
`CHANGELOG.md`, derived from commit types: `feat` → minor, `fix`/`perf` → patch,
`!` or `BREAKING CHANGE:` → major (while `0.x`, breaking changes bump the minor).

Merging the Release PR tags `vMAJOR.MINOR.PATCH` and creates the GitHub Release; the tag
promotes the already-tested image to production after approval. Do not create `v*` tags
or edit released `CHANGELOG.md` sections by hand.
