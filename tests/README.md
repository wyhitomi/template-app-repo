# Out-of-process test suites

| Suite | Path | Runs against | Trigger |
|-------|------|--------------|---------|
| Unit | `app/tests/` | in-process code | every PR + `main` (CI) |
| Integration | `tests/integration/` | running stack (`docker compose`) | merge to `main` |
| E2E | `tests/e2e/` | running stack, full user journeys | merge to `main` |
| Performance | `tests/performance/` | running stack, k6 load profile | merge to `main` |

All suites read `BASE_URL` (default `http://localhost:8080`), so the same tests
can target a deployed environment:

```bash
make test-e2e BASE_URL=https://dev.example.com
```

The sample suites use only the Python standard library. Swap them for your
stack's tooling (pytest, Playwright, Cypress, Testcontainers…) and keep the
`make` targets as the stable interface used by CI.
