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
- beta branch: `feature/m8-deployment-beta`;
- root directory: `services/api`;
- language/runtime: Docker;
- Docker build context: `.`;
- Dockerfile: `./Dockerfile`;
- region: Frankfurt (EU Central);
- compute: Free;
- health check: `/health/ready`;
- auto-deploy: on commit;
- public beta API: `https://anonymprove-api-beta.onrender.com`.

After M8 is merged, production tracking should move from the feature branch to
`main`.

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

The real Neon beta database was validated with the dry-run path before any
scheduled deletion is enabled.

Scheduling the purge is an M8 operational task.

## Flutter Web / Cloudflare Pages

The Flutter client receives its API endpoint at compile time through:

```text
--dart-define=API_BASE_URL=https://anonymprove-api-beta.onrender.com
```

M8D deploys the static Flutter Web output to Cloudflare Pages.

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

Before external beta use, M8E must explicitly review:

- Render request/platform metadata and retention;
- Cloudflare request/analytics settings;
- Neon connection/logging metadata;
- provider access controls;
- secrets and operator permissions;
- backup retention;
- shared/edge abuse controls;
- scheduled credential-metadata cleanup;
- TLS and custom-domain configuration.

Do not describe the hosted system as cryptographically anonymous.
