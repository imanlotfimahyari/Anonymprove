# Data retention and lifecycle

This document records the current M7 lifecycle and retention behavior.

## Sessions

User sessions are JWTs with an expiration time controlled by `JWT_TTL_MINUTES`.
Expired JWTs are rejected by the API. No refresh token is persisted.

Session expiration does **not** delete the user row. Persistent user identity is
still required for group membership and round authorization.

## Group join codes

Only a SHA-256 hash of a group join code is stored.

The group owner can:

- rotate the join code, immediately invalidating the previous code;
- revoke the join code, preventing new joins;
- rotate again after revocation to enable joining with a new code.

Plaintext join codes are returned only when a group is created or when its code
is rotated. They cannot be recovered from the database.

## Credential metadata

`CredentialClaim` contains identity-bearing participation metadata.
`ResponseCredential` contains a credential hash but no user identifier.

For closed rounds older than `CREDENTIAL_METADATA_RETENTION_DAYS` (default:
30 days), the maintenance command can remove both tables' records:

```text
python -m app.maintenance
```

The purge intentionally does **not** delete:

- anonymous responses;
- answers;
- aggregated-result source data.

Deleting claim and credential metadata therefore reduces retained
identity-adjacent data without creating or requiring an identity-to-response
mapping.

The maintenance command is not automatically scheduled by the application.
Production deployment must run it on an appropriate schedule.

## Anonymous feedback

Anonymous responses and answers are currently retained until the associated
group/round is deleted by future product lifecycle functionality. M7 does not
silently introduce an automatic anonymous-feedback deletion policy because that
would affect user-visible history and group-health trends.

## Backups

Database backups may retain data beyond live-database deletion. Production
backup retention and deletion guarantees must be defined as part of deployment
hardening.
