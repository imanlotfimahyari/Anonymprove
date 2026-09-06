# Initial privacy and threat model

## Product objective

Allow a person to request constructive feedback and allow a group to assess its own dynamics while reducing the risk that a feedback recipient can identify individual responders.

## Security/privacy properties to preserve

1. Only eligible group members may participate in a feedback round.
2. One member should not be able to submit multiple responses to the same round.
3. Recipients and ordinary group members should not receive a mapping from responder identity to response.
4. Raw bearer tokens and anonymous-response credentials must never be logged.
5. Feedback results should be released only after an appropriate response threshold and/or round closure.
6. Free text must be treated as potentially identifying even when account identifiers are absent.

## M0 trust assumptions

M0 does **not** provide cryptographic anonymity.

The backend operator can currently observe authentication traffic and the application has not yet implemented an anonymous ballot/response domain. The temporary user session endpoint exists only to establish API structure and CI.

## Primary threats for future milestones

- Direct database linkage between identity and feedback.
- Timing correlation between login activity and response submission.
- Logging of request bodies, tokens, IP-derived metadata, or tracing baggage.
- Small-group deanonymization.
- Stylometric or contextual identification from free-text feedback.
- Duplicate submissions / Sybil participation.
- Harassment enabled by unrestricted anonymous text.
- An administrator modifying or selectively deleting responses.

## Required controls before real feedback storage

- Separate identity/eligibility records from anonymous response records.
- Single-use anonymous participation credentials.
- Minimum group and response thresholds.
- Delayed/aggregated result publication.
- Explicit log redaction and observability review.
- Abuse reporting, rate limits, and structured-question defaults.
- Data retention/deletion policy.

## Non-goals for M0

- Zero-knowledge proofs.
- Blind signatures.
- Blockchain-backed auditability.
- Protection from a malicious infrastructure operator.
- Automated AI moderation or psychological diagnosis.
