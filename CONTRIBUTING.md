# Contributing

## Workflow

1. Branch from `main`.
2. Keep changes small and scoped to one concern.
3. Add or update tests for behavior changes.
4. Run `make check` where the required local toolchains are available.
5. Open a pull request and verify CI before merging.

Suggested branch prefixes:

- `feat/` — product functionality.
- `fix/` — defect corrections.
- `chore/` — tooling, CI, dependency, or repository maintenance.
- `docs/` — documentation-only changes.

## Python

Use Ruff for linting and formatting. Do not hand-format around Ruff.

```bash
ruff check --fix services/api
ruff format services/api
pytest services/api
```

## Flutter

```bash
cd apps/client
flutter pub get
flutter analyze
flutter test
```

## Security

Never use real user feedback, credentials, or personal data as fixtures. Privacy-boundary changes should update `docs/security/threat-model.md`.
