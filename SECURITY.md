# Security policy

## Reporting a vulnerability

**Do not open a public issue.** Report privately via
[GitHub Security Advisories](https://github.com/OWNER/REPO/security/advisories/new)
or email `security@example.com`.

We aim to acknowledge within 2 business days and to provide a remediation plan
within 10 business days.

## Supported versions

Only the latest release deployed to production receives security fixes.

## Built-in controls

- Secret scanning in pre-commit (gitleaks) and GitHub secret scanning.
- Container image scanning (Trivy) in CI; IaC scanning (Trivy config) in the infra pipeline.
- SBOM and build provenance attached to every image.
- OIDC federation to the cloud; no long-lived credentials in GitHub.
- Production changes require approval through GitHub Environments.
