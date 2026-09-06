# Security policy

## Reporting

Do not publish suspected vulnerabilities, credentials, private feedback, or personally identifying test data in a public issue.

Use synthetic data in tests and examples.

## Secret handling

- Never commit JWT signing keys, passwords, API keys, OAuth credentials, private keys, or production connection strings.
- Local secrets belong in `.env`, which is ignored by Git.
- CI/CD secrets must use the repository's encrypted secret mechanism when production deployments are introduced.
- Application logs must not contain authorization headers, bearer tokens, anonymous-response credentials, or raw feedback bodies.

## Privacy-sensitive changes

Changes that connect identity/group membership to feedback storage require explicit threat-model review. The long-term design must avoid storing a direct author identity on anonymous responses.
