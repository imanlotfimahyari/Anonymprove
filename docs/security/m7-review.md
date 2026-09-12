# M7 privacy and abuse hardening review

M7 establishes a practical privacy and abuse-control baseline for Anonymprove
before hosted beta work begins. It does not change the core anonymity claim:
the system provides logical/schema-level unlinkability, not cryptographic
anonymity.

## Controls completed

### Abuse boundaries

The API applies configurable, process-local fixed-window rate limits to:

- group join attempts;
- group creation;
- feedback-round creation;
- response-credential claims.

Anonymous response submission is intentionally not keyed to authenticated
identity. Response credentials remain single use.

Known limitations:

- counters are local to one API process;
- multiple workers do not share counters;
- a determined actor can create new sessions and partially evade per-user
  limits;
- production edge/shared enforcement remains a deployment concern.

### Logging and request metadata

Uvicorn access logging is disabled by the application/container startup policy.

The application-owned request logger records only low-sensitivity metadata:
method, normalized route template, status, and duration. It does not log
headers, query strings, bodies, client addresses, user IDs, join codes, bearer
tokens, or response credentials.

Credential-claim and anonymous-response submission routes are excluded from
per-request application logging to reduce timing-correlation metadata.

This does not control logs produced by a future CDN, reverse proxy, load
balancer, host, network sensor, database, or cloud platform. M8 deployment must
review those layers separately.

### Join-code lifecycle

Group join codes remain high-entropy values whose plaintext is returned only at
creation or rotation. The database stores only their SHA-256 hashes.

Group owners can rotate or revoke join codes. Rotation immediately invalidates
the previous code; revocation prevents new joins until a new code is created.

### Sessions

Sessions are signed JWTs with bounded configurable lifetime. Expired tokens are
rejected.

There is currently no refresh-token mechanism, persisted session table, or
per-token revocation list. A token remains valid until expiry unless the signing
secret is rotated.

### Credential-metadata retention

Closed rounds older than the configured retention period can have
`CredentialClaim` and `ResponseCredential` records purged.

The purge deliberately leaves anonymous responses and answers intact. It does
not create an identity-to-response mapping.

The purge command is explicit rather than automatically scheduled. M8 must
schedule it and define backup retention.

See `data-retention.md`.

### Production HTTP defaults

When `ENVIRONMENT=production`:

- wildcard CORS origins are rejected;
- wildcard trusted hosts are rejected;
- OpenAPI/Swagger/ReDoc endpoints are disabled.

The API also adds conservative browser security headers and suppresses Uvicorn
`Server` and `Date` headers in the project container startup.

TLS termination and proxy trust semantics remain M8 deployment responsibilities.

### Free-text and moderation

Free text remains potentially identifying and can be abused. The product
currently relies on structured questionnaires, minimum-response thresholds,
round control, and UI guidance against names or identifying details.

M7 does not provide automated content moderation, blocking, abuse-report queues,
or a moderator console. Those capabilities should be added only when product
requirements and operator responsibilities are defined; they must not weaken
the anonymity boundary.

## Core privacy invariant re-reviewed

The M7 changes preserve:

```text
identity establishes eligibility
            |
            v
   response credential
            |
            v
anonymous submission carries no user identity
```

In particular:

- anonymous response and answer rows still contain no responder/user ID;
- `ResponseCredential` still contains no user ID;
- the anonymous submission endpoint still uses `X-Response-Token`, not bearer
  authentication;
- identity-bearing claim metadata can be aged out without deleting anonymous
  feedback;
- new rate limiting does not attach authenticated identity to anonymous
  submissions.

## Residual risks accepted for pre-beta

The following are explicitly not solved by M7:

- timing and network-level correlation by privileged infrastructure operators;
- shared/distributed abuse enforcement across API replicas;
- session revocation before JWT expiry;
- cryptographically unlinkable anonymous credentials;
- contextual or stylometric identification from free text;
- backup deletion guarantees;
- reverse-proxy/CDN/load-balancer logging policy;
- automated moderation/reporting workflows;
- production TLS termination and certificate policy;
- production Android signing and store release controls.

## M7 conclusion

M7 is sufficient as the application's in-repository privacy/abuse-hardening
baseline for proceeding to M8 deployment and beta preparation.

It is not, by itself, a production security certification or a guarantee of
cryptographic anonymity. M8 must preserve these controls while defining the
external infrastructure, TLS, access logging, backup retention, scheduled
maintenance, observability, secret management, and release-signing policies.
