# Contributing

## Workflow

1. Branch from the latest `main`.
2. Keep changes small and scoped to one concern.
3. Add or update tests for behavior changes and regressions.
4. Run the relevant local quality gates.
5. Open a pull request.
6. Verify GitHub Actions before merging.

Suggested branch prefixes:

- `feat/` — product functionality.
- `fix/` — defect corrections.
- `chore/` — tooling, CI, dependency, or repository maintenance.
- `docs/` — documentation-only changes.

Avoid committing generated build output, local environment files, IDE state, Gradle caches, credentials, or test data derived from real users.

## Local checks

When the required toolchains are available:

```bash
make check
```

This runs the main API and Flutter checks, builds the Android debug APK, audits Python dependencies, and builds the API container.

Database migrations require a configured/running PostgreSQL instance and can be applied separately:

```bash
make migrate-api
```

## Python / FastAPI

Use Ruff for linting and formatting. Do not hand-format around Ruff.

```bash
ruff check --fix services/api
ruff format services/api
pytest services/api
```

For schema changes:

1. add an Alembic migration;
2. verify the migration applies from the current `main` schema;
3. keep ORM models, API schemas, migrations, and tests consistent;
4. do not rewrite already-merged migration history merely to make a new change easier.

CI applies the migration chain to PostgreSQL before running API tests.

## Flutter

The currently supported client targets are Web and Android.

```bash
cd apps/client
flutter pub get
flutter analyze
flutter test --coverage
flutter build apk --debug
```

The Web and Android runners are committed to the repository. Do not run `flutter create` over the project as routine setup; it can rewrite platform configuration. If regeneration is genuinely required, inspect and commit only the intended diff.

Android emulator development against the local API should use `10.0.2.2` for the Windows/Linux/macOS host rather than `127.0.0.1` inside the emulator.

When fixing a platform-specific lifecycle or UI defect, add a widget/unit regression test where practical and still perform the relevant platform smoke test.

## Tests

Tests should use synthetic values only.

Do not place real:

- feedback;
- names or personal data;
- JWTs;
- join codes;
- response credentials;
- passwords;
- production URLs or connection strings

in fixtures, logs, screenshots, examples, or committed files.

## Security and privacy

The core privacy invariant is:

```text
identity proves eligibility
        !=
stored anonymous feedback identity
```

Anonymous submission must remain separate from normal user/session authentication.

Changes involving identity, eligibility, credential claims, response credentials, anonymous responses, answers, result thresholds, logs, tracing, or free text are privacy-sensitive.

For those changes:

1. review `SECURITY.md`;
2. review and update `docs/security/threat-model.md` when assumptions or guarantees change;
3. add tests for the privacy boundary;
4. avoid introducing direct identity fields or foreign keys into anonymous response/answer storage.

The project provides logical/schema-level unlinkability; do not describe it as cryptographic anonymity.

## Documentation

Update public documentation when a milestone changes the implemented architecture, supported platforms, setup procedure, privacy boundary, or quality gates.

In particular, keep `README.md`, `SECURITY.md`, this guide, and relevant files under `docs/` consistent with the code being merged.
