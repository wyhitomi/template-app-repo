# 0002. Build once, promote immutable images

- **Status:** Accepted
- **Date:** 2026-09-23

## Context

Rebuilding per environment makes what runs in production differ from what was
tested (different base layers, dependencies, build flags).

## Decision

CI builds a single image per commit tagged `sha-<commit>`. Post-merge tests,
`stg` and `prd` all use that image. Releases re-tag the existing image as
`vX.Y.Z` (`docker buildx imagetools create`) and never rebuild.
Environment differences live only in configuration (Helm values, env vars).

## Consequences

- **Positive:** what was tested is exactly what ships; fast releases; easy rollback to any `sha-*`.
- **Negative:** configuration must never be baked into images.
- **Follow-ups:** consider signing images (cosign) and verifying signatures at admission.
