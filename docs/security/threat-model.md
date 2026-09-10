# Privacy and threat model

## Product objective

Anonymprove supports voluntary constructive feedback about individuals and
anonymous assessment of group dynamics while reducing the risk that feedback
recipients or ordinary group members can identify individual responders.

The product is intended for self-improvement and group awareness, not ranking,
social scoring, psychological diagnosis, or determining personal worth.

## Current privacy architecture

The central boundary is:

```text
authenticated identity
        |
        | establishes group membership and eligibility
        v
credential claim
        |
        | issues a separate single-use response credential
        v
anonymous submission
        |
        | carries the response credential, not the user session token
        v
anonymous response + answers
```

Identity and eligibility records are deliberately separated from anonymous
response storage.

A credential claim records that a user exercised their eligibility for a round.
The issued response credential is stored separately and does not contain a user
identifier.

Anonymous responses and answers do not contain a responder/user identifier.

This provides logical/schema-level unlinkability. It is not cryptographic or
mathematically provable anonymity.

## Round types

### Individual feedback

An individual-feedback round has a subject.

- the creator is the subject;
- the subject cannot claim a response credential;
- other eligible group members may respond;
- at least three responses are required;
- aggregated results are available to the subject after the round is closed and
  the threshold is met.

### Group health

A group-health round has no individual subject.

- the round creator controls opening and closing;
- all current group members, including the creator, are eligible to respond;
- at least three responses are required;
- aggregated results are available to current group members after the round is
  closed and the threshold is met;
- longitudinal history compares only aggregated dimension-level results from
  completed assessments.

Group-health history must never introduce responder-level linkage or attempt to
infer which member produced a change between assessments.

## Security and privacy properties to preserve

1. Only eligible group members may claim participation in a round.
2. A member may claim at most one response credential for a round.
3. Anonymous submission must not require or send the authenticated user session.
4. Anonymous response and answer records must not contain responder/user
   identifiers.
5. Feedback consumers must not receive an identity-to-response mapping.
6. Results must remain unavailable until the round is closed and the configured
   minimum-response threshold is satisfied.
7. Group-health results must be visible only to current members of that group.
8. Individual-feedback results must remain visible only to the round subject.
9. Raw bearer tokens, response credentials, join codes, and raw feedback bodies
   must not be written to application logs.
10. Free text must be treated as potentially identifying.
11. Historical or trend views must operate only on aggregate data and must not
    reconstruct respondent-level information.

## Trust assumptions

The application currently trusts the backend, database, deployment environment,
and privileged operators.

A sufficiently privileged infrastructure or database operator may be able to
correlate eligibility activity and anonymous submissions using timing,
connection metadata, request metadata, logs, traces, backups, database access,
or other operational side channels.

Protection from a malicious infrastructure operator is therefore not a current
security guarantee.

The current model also does not hide the fact that a user claimed eligibility
for a round. It separates that fact from the stored anonymous response.

## Primary threats

### Direct identity linkage

Adding a responder/user foreign key to anonymous responses, answers, or answer
choices would defeat the intended privacy boundary.

Control: identity remains confined to membership and credential-claim records.

### Authentication leakage into submission

Sending the user's bearer token together with an anonymous response would give
the backend a direct request-level identity linkage.

Control: anonymous submission uses only the response credential. Regression
tests verify that the Authorization header is absent.

### Duplicate participation

A participant could otherwise submit multiple responses and influence
aggregates.

Control: credential claims are unique per user and round, and response
credentials are single use.

### Small-group deanonymization

Very small response sets make inference easier.

Control: the current privacy floor is three responses before results may be
released.

This reduces risk but does not eliminate contextual inference.

### Timing correlation

An observer may correlate a credential claim with a submission occurring soon
afterward.

Current status: not cryptographically prevented.

Mitigations for later review may include operational log minimization,
aggregation, delayed processing, or stronger anonymous credential protocols if
the product threat model requires them.

### Free-text identification

Writing style, names, events, quotes, or highly specific details may identify a
responder.

Control: the UI warns users not to include names or identifying details.

This is guidance, not a complete technical guarantee.

### Group-health longitudinal inference

Repeated assessments may make changes more interpretable, especially when group
membership changes between rounds.

Control: history displays only aggregate results and explicitly avoids an
overall group-health score or respondent-level trend reconstruction.

### Unauthorized result access

A non-member must not obtain group-health results, and non-subject members must
not obtain individual-feedback results.

Control: result authorization depends on round type and current group
membership/subject identity.

### Logging and observability leakage

Headers, request bodies, tokens, tracing baggage, IP metadata, or verbose access
logs can undermine schema-level unlinkability.

Current requirement: application logs must not contain bearer tokens, response
credentials, join codes, or raw feedback bodies.

A full production observability review remains part of hardening.

### Abuse of anonymity

Anonymous text can be used for harassment, coercion, retaliation, or targeted
abuse.

Current status: structured questions and privacy warnings reduce risk, but M7
must address rate limiting, abuse controls, reporting/moderation safeguards,
retention, and operational controls.

## Data model invariants

The following relationships are intentional:

```text
CredentialClaim
    round_id
    user_id

ResponseCredential
    round_id
    token_hash
    used_at

AnonymousResponse
    round_id
    submitted_at

Answer
    response_id
    question_id
    value fields
```

The following relationships must not be introduced without redesigning the
privacy model:

```text
AnonymousResponse -> user_id
Answer            -> user_id
AnswerChoice       -> user_id
ResponseCredential -> user_id
```

The application therefore knows who was eligible and who claimed eligibility,
but anonymous feedback storage does not record which response belongs to which
person.

## Current non-goals

- zero-knowledge proofs;
- blind signatures;
- mix networks;
- cryptographically unlinkable anonymous credentials;
- blockchain-backed auditability;
- protection from a malicious infrastructure/database operator;
- automated psychological diagnosis;
- AI-based inference about individual responders.

## Required M7 review

Before production/beta exposure, review:

- rate limiting and abuse controls;
- logging and tracing configuration;
- reverse-proxy/access-log metadata;
- data retention and deletion;
- backup/privacy implications;
- session and join-code lifecycle;
- free-text safeguards;
- operational access controls;
- production transport security;
- Android release signing;
- whether the logical unlinkability model is sufficient for the intended user
  population and threat model.
