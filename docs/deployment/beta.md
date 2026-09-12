# Beta deployment plan

This document defines the M8 beta deployment baseline. It contains no
production credentials.

## Target layout

```text
Cloudflare Pages
  Flutter Web
      |
      | HTTPS
      v
Render Frankfurt
  FastAPI
      |
      | encrypted PostgreSQL connection
      v
Neon eu-central-1
  PostgreSQL
```

The Android client will use the same public HTTPS API endpoint.

## API container contract

The API image starts through `services/api/start.sh`.

At startup it:

1. applies Alembic migrations;
2. starts Uvicorn;
3. binds to `0.0.0.0`;
4. reads the listening port from `PORT`, defaulting to `8000`;
5. keeps Uvicorn access/server/date headers disabled as defined by the M7
   privacy-hardening policy.

The image health check reads `PORT` and calls `/health/ready`.

For the beta, run a single API instance. Migration-on-start is deliberately
simple for one replica. Before horizontal scale-out, move schema migration to a
dedicated release/migration job so multiple replicas cannot race on startup.

## Render API deployment

The beta API is deployed as a Render Web Service:

- repository: `imanlotfimahyari/Anonymprove`;
- deployment branch: `main`;
- root directory: `services/api`;
- language/runtime: Docker;
- Docker build context: `.`;
- Dockerfile: `./Dockerfile`;
- region: Frankfurt (EU Central);
- compute: Free;
- health check: `/health/ready`;
- auto-deploy: on commit;
- public beta API: `https://anonymprove-api-beta.onrender.com`.

The Docker image runs as the non-root `appuser`.

Use `deploy/render/api.env.example` as the non-secret environment-variable
checklist.

Configure these values in Render's Environment page and never commit them:

- `JWT_SECRET`;
- `DATABASE_URL`.

Production startup is intentionally fail-closed if `CORS_ORIGINS` or
`TRUSTED_HOSTS` contains an unsafe wildcard configuration.

Render supplies the `PORT` environment variable automatically. The image uses
that value without a provider-specific start-command override.

The free Render instance may spin down after inactivity. Cold-start latency is
acceptable for the pre-beta environment but must be considered during testing.

## Neon database

The beta PostgreSQL database is hosted by Neon in AWS Europe Central 1
(Frankfurt / `eu-central-1`).

The application currently uses the direct Neon endpoint rather than the pooled
endpoint because the single beta container also executes Alembic migrations at
startup.

The production connection URL is validated before migrations/application use.
Accepted PostgreSQL transport policies are:

```text
sslmode=verify-full
sslmode=verify-ca
```

or the Neon console style:

```text
sslmode=require&channel_binding=require
```

Client-side TLS was verified through the Psycopg/libpq connection used by the
application.

The SQLAlchemy engine uses `pool_pre_ping` and a bounded connection recycle
interval (`DATABASE_POOL_RECYCLE_SECONDS`, default 300 seconds).

## Health and readiness

The API exposes:

```text
/health/live
/health/ready
```

`/health/live` proves the API process is alive.

`/health/ready` performs a minimal database query and is the hosted service
health check.

The public beta readiness endpoint is:

```text
https://anonymprove-api-beta.onrender.com/health/ready
```

Production API documentation/OpenAPI endpoints remain disabled.

## Credential-metadata retention

The cleanup command supports a safe preview:

```text
python -m app.maintenance --dry-run
```

The actual purge remains:

```text
python -m app.maintenance
```

The real Neon beta database was validated with the dry-run path before
scheduled deletion was enabled.

For the beta, GitHub Actions runs the maintenance workflow daily at 03:17 UTC:

```text
.github/workflows/retention-maintenance.yml
```

The workflow first executes a dry run and then performs the purge. Its Neon
database URL is stored only as the repository secret `BETA_DATABASE_URL`.

## Flutter Web / Cloudflare Pages

The Flutter client receives its API endpoint at compile time through:

```text
--dart-define=API_BASE_URL=https://anonymprove-api-beta.onrender.com
```

The static Flutter Web output is deployed to Cloudflare Pages.

The intended static output is:

```text
apps/client/build/web
```

No API credential is required in the Flutter Web application. The API base URL
is public configuration, not a secret.

The beta frontend is deployed at:

```text
https://anonymprove-web-beta.pages.dev
```

Render `CORS_ORIGINS` is configured to that exact HTTPS origin.

## Cloudflare Pages deployment

The Flutter Web beta is deployed as a Cloudflare Pages Direct Upload project:

- project: `anonymprove-web-beta`;
- production branch metadata: `main`;
- public URL: `https://anonymprove-web-beta.pages.dev`;
- build output: `apps/client/build/web`;
- API endpoint compiled into the Web bundle:
  `https://anonymprove-api-beta.onrender.com`.

Build:

```text
flutter build web --release --dart-define=API_BASE_URL=https://anonymprove-api-beta.onrender.com
```

Deploy:

```text
npx wrangler@latest pages deploy apps/client/build/web --project-name=anonymprove-web-beta --branch=main
```

The Pages hostname is public configuration and is the exact browser origin
allowed by Render CORS.

## Privacy boundary during deployment

The in-application M7 controls do not automatically govern provider-generated
metadata.

The M8 provider-boundary review is recorded in
`docs/security/m8-provider-review.md`.

The application does not control all provider-generated metadata. Render,
Cloudflare, Neon, and GitHub may process operational metadata required to run
their services. Database backup/recovery systems may also retain deleted data
for some period outside the live database.

The beta therefore continues to claim only logical/schema-level unlinkability,
not cryptographic anonymity.

## Live beta validation

The M8 release candidate was validated against the public deployment:

- `GET /health/live` returned `200` with `{"status":"ok"}`;
- `GET /health/ready` returned `200` with `{"status":"ready"}`;
- `/docs` returned `404` in production;
- `/openapi.json` returned `404` in production;
- a CORS preflight from `https://anonymprove-web-beta.pages.dev` to the
  session endpoint returned the exact allowed origin;
- security middleware returned `Cache-Control: no-store`,
  `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`,
  `Referrer-Policy: no-referrer`, and the configured `Permissions-Policy`;
- the public Flutter Web beta loaded and could reach the hosted API.

A `HEAD` request to `/health/live` returns `405` because the health route is
defined for `GET`; the security middleware still applies its response headers.

## Android beta release

Android release builds use a private upload keystore configured locally through
`apps/client/android/key.properties`.

The keystore and passwords are not committed. The release App Bundle was
verified with `jarsigner`, and the embedded signer SHA-256 fingerprint matched
the private upload-keystore certificate.

The application ID remains:

```text
io.github.imanlotfimahyari.anonymprove
```

The Android release build points to the same public HTTPS API endpoint as the
Web beta.
