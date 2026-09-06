# ADR 0002: Persistent identity and group membership

## Status

Accepted for M1.

## Decision

M1 persists the identifiable domain in PostgreSQL using three tables:

- `users` — pseudonymous application identities.
- `groups` — friendship/feedback groups and a hash of the active join code.
- `group_members` — explicit user-to-group membership and role.

A JWT identifies only a user. Group authorization is resolved from `group_members` on each
request; no group ID is embedded in the token. A user may therefore belong to multiple groups.

The plaintext group join code is returned only when a group is created. The database stores a
SHA-256 digest, so a database read does not directly disclose join credentials.

## Privacy boundary

These tables are intentionally part of the **identifiable domain**. They answer who a user is and
which groups they are eligible to participate in.

Future anonymous feedback/ballot records must live behind a separate boundary and must not contain
`user_id` or `group_member_id` as an author link. Eligibility will later be converted into a
one-time anonymous credential before feedback submission.

## Consequences

- PostgreSQL becomes a required runtime dependency.
- Alembic owns schema migrations.
- M1 does not yet provide durable login recovery across devices; `/users/session` creates a new
  pseudonymous identity. Authentication/recovery is a later product decision.
- M1 does not implement feedback, scoring, moderation, or anonymous ballots.
