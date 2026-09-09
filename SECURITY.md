# Security policy

Anonymprove handles privacy-sensitive feedback. Security and privacy regressions should be treated as product defects, not only as infrastructure defects.

The project is currently **pre-beta** and is not yet a production service.

## Reporting

Do not publish suspected vulnerabilities, credentials, private feedback, join codes, response credentials, or personally identifying test data in a public issue.

Report security-sensitive findings to the maintainer through a private channel. Use synthetic data when creating reproductions, tests, screenshots, or examples.

## Current privacy boundary

The current implementation separates identity/eligibility from anonymous response storage:

- user identity and group membership establish whether a person may participate;
- a credential claim records eligibility for a feedback round;
- a separate single-use response credential authorizes submission;
- anonymous response records do not contain a responder/user identifier;
- answers reference the anonymous response and questionnaire data, not the responder identity;
- results are gated by round state and minimum-response thresholds.

This is **logical/schema-level unlinkability**, not cryptographic anonymity.

A sufficiently privileged infrastructure or database operator may still correlate identity and feedback using timing, logs, request metadata, network metadata, backups, traces, or other operational side channels. Protection from a malicious infrastructure operator is not currently a security guarantee.

## Secret and sensitive-data handling

- Never commit JWT signing keys, passwords, API keys, OAuth credentials, private keys, production connection strings, signing keys, or real response credentials.
- Local secrets belong in `.env`, which is ignored by Git.
- CI/CD and deployment secrets must use the platform's encrypted secret mechanism.
- Application logs must not contain authorization headers, bearer tokens, response credentials, join codes, or raw feedback bodies.
- Do not use real user feedback, credentials, or personal data as test fixtures.
- Free-text feedback must be treated as potentially identifying even when account identifiers are absent.

## Privacy-sensitive changes

Changes that affect any of the following require explicit review against `docs/security/threat-model.md`:

- identity or session handling;
- group membership and eligibility;
- credential claiming or consumption;
- anonymous response or answer storage;
- result aggregation or minimum-response thresholds;
- logging, tracing, analytics, or request metadata;
- free-text collection;
- data export, retention, or deletion.

Do not introduce a direct responder/user foreign key on anonymous responses or answers.

Do not merge identity/session authentication into the anonymous submission endpoint without redesigning and documenting the privacy model.

## Abuse and operational limitations

The current milestones do not yet provide the complete M7 abuse/privacy-hardening layer. Rate limiting, abuse controls, moderation safeguards, retention policy, and production observability review remain future work.

Minimum-response thresholds reduce small-group deanonymization risk but do not prevent contextual, timing, or stylometric identification.

## Android release security

Android support through M5 is for development and testing. The current release build configuration is not a production signing/release process.

Before external/store distribution:

- configure a dedicated protected release signing key;
- keep signing material outside the repository;
- remove development-only signing assumptions;
- review production API transport/configuration;
- complete the privacy and abuse-hardening milestone.
