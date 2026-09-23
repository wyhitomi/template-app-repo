# Architecture Decision Records

An ADR captures **one** significant decision, its context and its consequences.
ADRs are immutable once accepted: to change a decision, write a new ADR that
supersedes the old one and update the old one's status.

## Process

1. Copy [`0000-template.md`](0000-template.md) to `NNNN-short-title.md` (next number).
2. Open a PR with status `Proposed`. Discussion happens in the PR.
3. On merge, set status to `Accepted` (or `Rejected`, which is still worth keeping).

## Log

| # | Title | Status | Date |
|---|-------|--------|------|
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | Accepted | 2026-09-23 |
| [0002](0002-build-once-promote-immutable-images.md) | Build once, promote immutable images | Accepted | 2026-09-23 |
| [0003](0003-terragrunt-per-environment-layout.md) | Terragrunt per-environment layout | Accepted | 2026-09-23 |
