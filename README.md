# Privacy-preserving feedback platform

A cross-platform application for voluntary, constructive, anonymous feedback and group-health assessment.

## Status

This repository is at **M0 — foundation**. The current implementation intentionally keeps the product surface small while establishing testable application and CI boundaries.

The API currently provides:

- `GET /health/live` — liveness endpoint.
- `POST /api/v1/users/session` — temporary anonymous-session bootstrap for development.
- `GET /api/v1/users/me` — validates the bearer token and returns the current temporary profile.

The temporary session store is in memory. It is **not production persistence** and is expected to be replaced by PostgreSQL-backed identity/group models in M1.

## Architecture

```text
Flutter client (Android / Web first; iOS / Windows compatible)
                         |
                      HTTPS
                         |
                 FastAPI modular monolith
                         |
                  PostgreSQL (M1)
```

The first production architecture will remain a modular monolith. Kubernetes, blockchain, AI/LLMs, Redis, Kafka, and microservices are deliberately out of scope until there is a concrete requirement for them.

## Repository layout

```text
apps/
  client/                 Flutter application source
services/
  api/                    FastAPI backend
docs/
  architecture/           Architecture decisions
  security/               Privacy and threat-model notes
.github/
  workflows/              CI workflows
```

## Backend development

Requirements: Python 3.12+.

```bash
python -m venv .venv
source .venv/bin/activate        # Windows PowerShell: .venv\\Scripts\\Activate.ps1
python -m pip install -e "services/api[dev]"
```

Create a local environment file from the template and replace all placeholders:

```bash
cp .env.example .env
```

Run the API:

```bash
cd services/api
uvicorn app.main:app --reload
```

OpenAPI is available locally at `/docs`.

## Docker

After creating `.env`:

```bash
docker compose up --build
```

## Flutter development

The committed Flutter code contains the application package and tests. Generate the platform runners once on a development machine with Flutter installed:

```bash
cd apps/client
flutter create --platforms=android,web,windows,ios --project-name privacy_feedback_app .
flutter pub get
flutter analyze
flutter test
```

The initial delivery priority is Android and Web. iOS can use the same Flutter application code but requires macOS/Xcode for normal iOS builds.

## Quality gates

Pull requests and pushes to `main` run:

- Ruff linting and formatting checks.
- Pytest with coverage.
- Python dependency vulnerability audit.
- Backend Docker image build.
- Flutter dependency resolution, static analysis, and widget tests.

Run the same checks locally before opening a PR:

```bash
make check
```

## Privacy principles

1. Feedback recipients must not receive responder identities.
2. Eligibility and anonymous-response data must become separate trust domains before real feedback is stored.
3. Bearer tokens, credentials, and feedback bodies must not be written to application logs.
4. Results should use minimum-response thresholds and delayed aggregation to reduce social deanonymization.
5. M0 does **not** claim cryptographic anonymity. See `docs/security/threat-model.md`.

## Roadmap

- **M0:** repository, API/client scaffolding, tests, CI, threat model.
- **M1:** persistent users, groups, invitations, PostgreSQL migrations.
- **M2:** feedback rounds and structured questionnaires.
- **M3:** separated eligibility/anonymous-response credentials and aggregation thresholds.
- **M4:** group-health assessments and longitudinal results.
- **M5:** moderation, abuse controls, privacy hardening, deployment.
