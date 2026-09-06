# ADR 0001 — Initial application architecture

## Status

Accepted for M0.

## Context

The product needs a cross-platform client, authenticated group membership, anonymous feedback, and later aggregate group-health assessments. The principal engineering risk is privacy semantics rather than compute scale.

## Decision

Use:

- Flutter for the shared Android/Web client code, while retaining compatibility with iOS and Windows.
- FastAPI/Python as a modular-monolith backend.
- PostgreSQL beginning in M1 for persistent users/groups and later voting/feedback records.
- Docker for reproducible local/API builds.
- GitHub Actions for CI.

Do not introduce Kubernetes, blockchain, AI/LLMs, Redis, Kafka, or microservices without a demonstrated requirement.

## Privacy boundary

Identity/eligibility and anonymous-response data will be separate logical domains even while they live in one deployable backend. A later hardening milestone may split those domains physically if the threat model requires it.

No feedback response table should contain a direct `user_id` identifying its author.

## Consequences

### Positive

- Low operational cost and small initial attack surface.
- One UI codebase across target platforms.
- Straightforward local development and CI.
- Architecture can evolve without prematurely paying distributed-systems complexity.

### Trade-offs

- M0 in-memory sessions are deliberately non-persistent.
- Server operators are trusted in early milestones; cryptographic anonymity is not claimed.
- iOS builds still require macOS/Xcode even though the application code is shared.
