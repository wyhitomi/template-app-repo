# 0004. Automate releases with release-please

- **Status:** Accepted
- **Date:** 2026-09-25
- **Deciders:** @maintainers
- **Related:** [0002](0002-build-once-promote-immutable-images.md)

## Context

Production releases were cut by a maintainer creating a `vX.Y.Z` tag on `main`.
Choosing the version and writing `CHANGELOG.md` was manual and easy to forget,
even though every commit on `main` already follows Conventional Commits.

## Decision

We will use [release-please](https://github.com/googleapis/release-please) on every
push to `main`. It maintains a Release PR with the next SemVer version and changelog;
merging it creates the `vX.Y.Z` tag and GitHub Release, which triggers the existing
prd promotion. It runs with a GitHub App token so that its PR and tag trigger CI and CD.

## Options considered

| Option | Pros | Cons |
|--------|------|------|
| release-please (chosen) | Version + changelog from commits; release is a reviewable PR; no extra runtime | Needs a GitHub App (or PAT) for downstream triggers |
| semantic-release | Fully automatic | Releases on every merge, no review step; Node toolchain |
| Manual tags | No setup | Error-prone versioning, changelog drifts |

## Consequences

- **Positive:** consistent SemVer, generated changelog, prd release is a single PR merge.
- **Negative / trade-offs:** one GitHub App to create and rotate; commit messages now drive versions.
- **Follow-ups:** allow the app to create `v*` tags in the tag ruleset.
