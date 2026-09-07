# 0003 - Feedback rounds and anonymous response boundary

## Status

Accepted for M2.

## Context

M1 introduced persistent users, groups, and memberships. M2 needs to let a group member request
constructive feedback about themselves while preventing stored feedback content from being directly
linked to the member who submitted it.

The MVP needs practical privacy properties without introducing blind signatures, zero-knowledge
proofs, or a separate anonymity service yet.

## Decision

A feedback round belongs to one group, has the requesting user as its subject, references a versioned
questionnaire, and moves through `draft -> open -> closed`.

Eligibility and anonymous content are deliberately separated:

- `credential_claims` records that a group member claimed one response opportunity for a round.
  It contains `round_id` and `user_id`, but no credential identifier.
- `response_credentials` stores only `round_id`, a one-way hash of a high-entropy response token,
  and whether the token has been used. It has no `user_id` and no foreign key to a claim.
- `anonymous_responses` stores `round_id` and submission time only. It has no `user_id`, claim ID,
  or credential ID.
- `answers` attach only to an anonymous response and questionnaire question.

A response submission uses `X-Response-Token` and does not require or consume the user's JWT.
The response token is single-use.

The round subject cannot claim a response credential. An open round must have at least as many
eligible non-subject group members as its configured minimum response threshold.

Results are available only to the round subject, only after the round is closed, and only when the
minimum response threshold is met. Scale answers are returned as per-question aggregates. Free-text
comments are returned separately and are not grouped into per-response records. Their result order
does not preserve submission order.

The built-in `core-feedback-v1` questionnaire contains seven required 1-5 behavioral questions and
one optional short improvement comment. The free-text prompt asks respondents to avoid names or
identifying details.

## Privacy boundary

This design provides **logical unlinkability in the application schema**, not cryptographic
anonymity. A privileged database or infrastructure operator could potentially correlate credential
claim and credential creation through transaction timing, database logs, request logs, or other
operational metadata.

M2 therefore must not be described as providing mathematically guaranteed anonymity. A later
milestone can strengthen this boundary with separate services, batching, blinded credentials, or
other cryptographic techniques if the product requires a stronger threat model.

## Consequences

- One eligible member can claim at most one response opportunity per round.
- Losing an issued response token means it cannot be reissued in M2 without weakening the current
  separation model.
- Raw response bundles are never exposed by the results API.
- Minimum threshold defaults to 3 and is configurable from 3 to 10.
- Questionnaire versions remain immutable references for rounds already created.
