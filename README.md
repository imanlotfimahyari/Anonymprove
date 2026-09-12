# Anonymprove

Anonymprove is a cross-platform application for voluntary, constructive, privacy-preserving feedback and group-health assessment.

The product is intended for self-improvement and group awareness, not for ranking people. Feedback should focus on observable behavior and actionable improvement rather than personal worth, popularity, or social scoring.

## Status

Current milestone: **M7 — privacy and abuse hardening completed**

Next milestone: **M8 — deployment and beta**

The project is currently **pre-beta** and intended for development/testing rather than production use.

Implemented through M7:

- PostgreSQL-backed users, groups, and memberships
- private session-based identity
- group creation and high-entropy join codes
- feedback rounds with minimum-response privacy thresholds
- eligibility checks separated from anonymous feedback submission
- single-use response credentials
- built-in structured feedback questionnaire
- group-scoped custom questionnaires
- questionnaire draft, publish, and versioning lifecycle
- scale, single-choice, multiple-choice, short-text, long-text, and description question types
- aggregated feedback results
- Flutter Web client
- Flutter Android client
- Android/Web cross-platform feedback flow
- anonymous group-health assessments
- group-health-specific built-in questionnaire
- creator-inclusive group-health participation
- thresholded group-wide aggregate results
- longitudinal group-health history with per-dimension changes
- process-local abuse rate limits on identity-side sensitive operations
- privacy-safe request logging with anonymity-boundary routes suppressed
- join-code rotation and revocation
- closed-round credential-metadata retention controls
- production host/CORS validation and conservative security headers
- API, Flutter, Docker, and Android build checks in CI

## Core privacy model

The central design principle is:

```text
identity establishes eligibility
            |
            v
   response credential
            |
            v
anonymous submission carries no user identity
```

Identity/group membership and anonymous feedback storage are deliberately separated.

The current schema records which user claimed eligibility for a round, but anonymous response records do not contain a responder/user identifier. Response credentials are stored separately and consumed when feedback is submitted.

This provides **logical/schema-level unlinkability**, not cryptographic anonymity. A sufficiently privileged database or infrastructure operator may still be able to infer relationships using operational metadata such as timing, logs, request metadata, or other side channels.

See `docs/security/threat-model.md`, `docs/security/m7-review.md`, `docs/security/data-retention.md`, and `SECURITY.md`.

## Architecture

```text
              Flutter client
          Web              Android
            \                /
             \              /
                  HTTP/S
                    |
          FastAPI modular monolith
                    |
                PostgreSQL
```

The application intentionally remains a modular monolith.

Kubernetes, blockchain, AI/LLMs, Redis, Kafka, and microservices are out of scope unless a concrete requirement justifies them.

## Repository layout

```text
apps/
  client/
    lib/                    Flutter application
    web/                    Web runner
    android/                Android runner
    test/                   Flutter tests

services/
  api/
    app/                    FastAPI application
    alembic/                Database migrations
    tests/                  API tests

docs/
  architecture/             Architecture decisions
  security/                 Privacy and threat-model notes

.github/
  workflows/                CI workflows

compose.yaml                Local PostgreSQL + API stack
```

## Backend development

Requirements:

- Python 3.12+
- PostgreSQL, or Docker for the local stack

Create and activate a virtual environment:

```bash
python -m venv .venv
```

Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

Install the API and development dependencies:

```bash
python -m pip install -e "services/api[dev]"
```

Create a local environment file from the template and replace the placeholders.

Linux/macOS:

```bash
cp .env.example .env
```

Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

Do not commit `.env`.

### Run with Docker Compose

From the repository root:

```bash
docker compose up --build
```

The API applies Alembic migrations before starting.

Liveness endpoint:

```text
http://127.0.0.1:8000/health/live
```

OpenAPI / Swagger UI:

```text
http://127.0.0.1:8000/docs
```

## Flutter development

The supported client targets through M6 are **Web and Android**.

Install dependencies:

```bash
cd apps/client
flutter pub get
```

Run static analysis and tests:

```bash
flutter analyze
flutter test --coverage
```

### Run Web

With the API running locally:

```bash
flutter run \
  -d web-server \
  --web-hostname 127.0.0.1 \
  --web-port 8080 \
  --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Open:

```text
http://127.0.0.1:8080
```

### Run Android emulator

Android Emulator uses `10.0.2.2` to reach services running on the host machine:

```bash
flutter run \
  -d emulator-5554 \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

The exact device ID may differ:

```bash
flutter devices
```

Build a debug APK:

```bash
flutter build apk --debug
```

The Android application ID is:

```text
io.github.imanlotfimahyari.anonymprove
```

The current release-signing configuration is development-only. Do not treat current Android builds as production/store releases.

## Functional feedback flows

### Individual feedback

```text
create private session
        |
create or join group
        |
choose built-in or custom questionnaire
        |
create individual-feedback round
        |
subject opens round
        |
other eligible members claim response credentials
        |
feedback submitted with response credential only
        |
subject closes round
        |
minimum response threshold enforced
        |
aggregated results shown to the subject
```

### Group health

```text
create or join group
        |
start group-health assessment
        |
creator opens assessment
        |
all eligible members, including creator,
claim one response credential
        |
answers submitted without session identity
        |
creator closes assessment
        |
minimum response threshold enforced
        |
aggregated results shown to current group members
        |
completed assessments contribute aggregate-only history
```

The current privacy floor is at least **3 responses**.

For individual feedback, those responses must come from eligible members other than the subject.

For group health, all group members are eligible, including the assessment creator. Group-health assessments therefore require at least three eligible group members in total.

## Questionnaires

Anonymprove includes built-in questionnaires for individual constructive feedback and group-health assessment, and supports group-specific custom questionnaires.

Supported question types:

- scale
- single choice
- multiple choice
- short text
- long text
- description/information

Custom questionnaires use a versioned lifecycle:

```text
draft
  |
publish
  |
published version is immutable
  |
create a new version for later changes
```

Existing feedback rounds retain the questionnaire version with which they were created.

## Quality gates

Pull requests and pushes to `main` run:

- Ruff linting
- Ruff formatting checks
- Alembic migrations against PostgreSQL
- Pytest with coverage
- Python dependency vulnerability audit
- backend Docker image build
- Flutter dependency resolution
- Flutter static analysis
- Flutter widget tests
- Android debug APK build

For the main local checks:

```bash
make check
```

`make check` covers API lint/test/audit, Flutter analysis/tests, Android debug build, and backend Docker image build. Database migration validation still requires a configured/running PostgreSQL instance and can be run separately with:

```bash
make migrate-api
```

## Privacy principles

1. Feedback recipients must not receive responder identities.
2. Identity is used to establish eligibility, not stored on anonymous response records.
3. Anonymous submission uses a response credential rather than the user's session bearer token.
4. Bearer tokens, response credentials, join codes, and raw feedback bodies must not be written to application logs.
5. Results require minimum-response thresholds to reduce social deanonymization.
6. Free text must be treated as potentially identifying.
7. Privacy-boundary changes require explicit threat-model review.
8. The project does not claim cryptographic or mathematically provable anonymity.

## Roadmap

- **M0 — Foundation** ✅
  Repository structure, FastAPI/Flutter scaffolding, CI, tests, and initial threat model.

- **M1 — Persistent identity and groups** ✅
  PostgreSQL, users, groups, memberships, migrations, and join codes.

- **M2 — Anonymous feedback engine** ✅
  Feedback rounds, eligibility checks, response credentials, anonymous submission, and response thresholds.

- **M3 — Functional Flutter Web client** ✅
  End-to-end Web workflow and client/API integration.

- **M4 — Custom questionnaires** ✅
  Questionnaire builder, multiple question types, publishing, versioning, dynamic forms, and aggregate results.

- **M5 — Android support** ✅
  Android runner, application identity, emulator networking, APK build, Android lifecycle regression coverage, and Android/Web validation.

- **M6 — Group-health mode** ✅
  Anonymous group-level assessment, creator-inclusive participation, thresholded group results, and aggregate longitudinal history.

- **M7 — Privacy and abuse hardening** ✅
  Abuse-rate boundaries, privacy-safe logging, join-code lifecycle, credential-metadata retention, runtime HTTP hardening, and threat-model review.

- **M8 — Deployment and beta**
  Hosted deployment, production configuration, observability, release process, and early-user validation.
