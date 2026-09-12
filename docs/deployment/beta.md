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
Koyeb FRA
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

The image health check also reads `PORT` and calls `/health/live`.

For the beta, run a single API instance. Migration-on-start is deliberately
simple for one replica. Before horizontal scale-out, move schema migration to a
dedicated release/migration job so multiple replicas cannot race on startup.

## Koyeb API settings

Use a Git-driven Dockerfile deployment:

- repository: `imanlotfimahyari/Anonymprove`;
- production branch: `main`;
- work directory: `services/api`;
- Dockerfile: `Dockerfile`;
- region: Frankfurt (`fra`);
- service type: Web;
- exposed port: `8000`;
- protocol: HTTP;
- route: `/`;
- health check: HTTP `/health/ready` on port `8000`;
- replicas for beta: `1`.

The Docker image itself runs as the non-root `appuser`.

Use `deploy/koyeb/api.env.example` as the non-secret environment-variable
checklist.

Configure these values as provider secrets:

- `JWT_SECRET`;
- `DATABASE_URL`.

Do not put either value in Git, screenshots, issue text, PR descriptions, or
chat messages.

Production startup is intentionally fail-closed if `CORS_ORIGINS` or
`TRUSTED_HOSTS` contains a wildcard.

## Neon database

M8B will create the beta PostgreSQL database, validate TLS connection settings,
apply the migration chain, and test the credential-metadata retention command.

The database connection string must be stored only as the Koyeb
`DATABASE_URL` secret.

## Flutter Web / Cloudflare Pages

The Flutter client receives its API endpoint at compile time through:

```text
--dart-define=API_BASE_URL=https://<api-host>
```

Therefore the public Koyeb API hostname must exist before the production Web
bundle is built.

M8D will add the reproducible Cloudflare Pages deployment workflow after the
API endpoint is known. The intended static output is:

```text
apps/client/build/web
```

No API credential is required in the Flutter Web application. The API base URL
is public configuration, not a secret.

## Privacy boundary during deployment

The in-application M7 controls do not automatically govern provider-generated
metadata.

Before external beta use, M8E must explicitly review:

- Koyeb edge/request metadata and retention;
- Cloudflare request/analytics settings;
- Neon connection/logging metadata;
- provider access controls;
- secrets and operator permissions;
- backup retention;
- shared/edge abuse controls;
- scheduled credential-metadata cleanup;
- TLS and custom-domain configuration.

Do not describe the hosted system as cryptographically anonymous.

## M8B database transport and readiness

Production database configuration is validated before use.

Accepted production PostgreSQL transport policies are:

```text
sslmode=verify-full
sslmode=verify-ca
```

or the Neon console style:

```text
sslmode=require&channel_binding=require
```

A production URL without one of those policies fails closed before migrations or
application startup.

The SQLAlchemy engine uses `pool_pre_ping` and a bounded connection recycle
interval (`DATABASE_POOL_RECYCLE_SECONDS`, default 300 seconds) so stale
serverless database connections are replaced.

The API now exposes:

```text
/health/live
/health/ready
```

`/health/live` only proves the API process is alive. `/health/ready` performs a
minimal database query and should be used by the hosted service health check.

The credential-metadata cleanup command supports a safe preview:

```text
python -m app.maintenance --dry-run
```

and the actual purge remains:

```text
python -m app.maintenance
```

Run the dry-run before enabling any scheduled purge.
