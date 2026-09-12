# M8 provider-boundary privacy review

This document records the hosted-beta privacy boundary for M8.

## Scope

The public beta uses:

- Cloudflare Pages for the Flutter Web client;
- Render in Frankfurt for the FastAPI service;
- Neon in `eu-central-1` for PostgreSQL;
- GitHub Actions for CI and scheduled credential-metadata maintenance.

These providers operate outside the application's database schema and request
handling code. Their infrastructure may necessarily process operational
metadata.

## Privacy claim

Anonymprove provides **logical/schema-level unlinkability** between identity-side
eligibility and stored anonymous responses.

It does **not** claim cryptographic anonymity.

A sufficiently privileged infrastructure or database operator may still infer
relationships using timing, connection metadata, provider logs, backups,
request metadata, or other side channels.

## Application logging boundary

The API disables Uvicorn access logs in the hosted container and uses
privacy-safe application logging.

Application logging intentionally avoids request bodies, authorization headers,
join codes, response credentials, client addresses, and user identifiers.
Credential-claim and anonymous-response submission routes are additionally
suppressed from per-request application logging to reduce timing correlation.

These controls do not remove metadata produced independently by hosting or edge
providers.

## Render

The beta API uses one Render Web Service instance.

Runtime secrets are configured through Render environment variables and are not
stored in the repository. The public host is restricted through
`TRUSTED_HOSTS`, and browser CORS is restricted to the exact Cloudflare Pages
origin.

The application cannot guarantee deletion or suppression of metadata maintained
by Render's platform or edge infrastructure.

The current in-process abuse-rate counters are suitable only for the single
beta instance. They are not a distributed rate-limit system and would not be
shared across horizontally scaled API replicas.

## Cloudflare Pages

The Flutter Web bundle contains only public runtime configuration such as the
API base URL. It contains no API secret or database credential.

Cloudflare remains an infrastructure boundary that can observe normal edge
request metadata. Optional analytics or additional telemetry must not be enabled
without a separate privacy review.

## Neon PostgreSQL

The API connects to Neon over an encrypted PostgreSQL connection. The live
database stores identity-side participation metadata separately from anonymous
response records.

Credential claims and response-credential rows for sufficiently old closed
rounds are deleted by the retention maintenance job.

Deletion from the live database does not imply immediate deletion from every
backup, recovery, replication, or provider-operated storage layer. Provider
recovery systems therefore remain part of the residual privacy risk.

## GitHub Actions maintenance

`.github/workflows/retention-maintenance.yml` runs the credential-metadata
maintenance job daily.

The workflow:

1. checks out the repository;
2. installs the API runtime dependencies;
3. creates an ephemeral JWT setting required by application configuration;
4. reads the database URL from the `BETA_DATABASE_URL` repository secret;
5. runs the retention dry run;
6. performs the purge.

The database secret must never be printed, committed, placed in workflow source,
or exposed through diagnostic output.

## Secrets and operator access

The beta depends on privileged operator accounts for Render, Neon, Cloudflare,
and GitHub.

Those accounts can affect the privacy boundary even when application code is
correct. Account access should therefore remain limited, protected with strong
authentication, and reviewed before adding collaborators.

Any accidental exposure of a database URL, JWT signing secret, keystore
password, or other credential requires rotation.

## Android signing

The Android upload keystore is stored outside the repository. Its passwords are
stored only locally by the operator.

`apps/client/android/key.properties`, JKS files, and keystore files remain
gitignored. The release App Bundle signer was verified against the upload
keystore certificate.

The upload key is an operational release credential, not part of the feedback
anonymity design.

## Residual risks accepted for beta

The following remain accepted beta limitations:

- provider-generated request and connection metadata;
- timing-correlation risk across identity-side and anonymous-side actions;
- provider backup/recovery retention outside live-row deletion;
- privileged operator access;
- process-local rather than shared/distributed rate limiting;
- free-text answers that may identify their author through content;
- beta-service availability and cold-start behavior.

These limitations must remain visible in product and security documentation.
