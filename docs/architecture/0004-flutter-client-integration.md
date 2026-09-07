# 0004 - Flutter MVP client and browser API boundary

## Status

Accepted for M3.

## Context

M0-M2 established the FastAPI/PostgreSQL backend, persistent group membership, and the anonymous
feedback-round boundary. The product now needs a usable Flutter client, with Flutter Web as the first
runtime target.

The browser runs the Flutter development server on a different origin from the local FastAPI server,
so the API must explicitly permit the development origin and the headers used by the feedback flow.

## Decision

M3 adds a dependency-light Flutter client using `package:http` and Material widgets. It does not add
a state-management framework, routing package, local database, or account persistence yet.

The API base URL is supplied through `--dart-define=API_BASE_URL=...` and defaults to
`http://127.0.0.1:8000` for local web development.

The client supports:

- creating a temporary session identity;
- creating, joining, and listing groups;
- creating and listing feedback rounds;
- opening and closing a user's own round;
- answering another member's open round;
- viewing thresholded aggregate results.

The anonymous submission boundary from M2 is preserved in the client:

1. The authenticated session is used to claim a one-time response credential.
2. The response token is retained only in the feedback form's in-memory state.
3. The feedback submission sends `X-Response-Token` and deliberately omits `Authorization`.
4. The response token is cleared after a successful submission.

The API enables CORS only for configured origins. The local defaults are
`http://127.0.0.1:8080` and `http://localhost:8080`. Allowed headers are limited to the headers the
client requires, including `X-Response-Token`.

## Consequences

- Flutter Web can call the local API without a wildcard CORS policy.
- A client regression test protects the no-bearer-token submission invariant.
- Session identity is still temporary and held only in memory; refreshing the page creates a new
  client state and there is no account recovery in M3.
- A claimed response token can still be lost if the page is closed before submission. M3 minimizes
  this window by claiming the credential only when the validated form is submitted and retaining it
  across retry attempts while the form remains open.
- Secure persisted authentication, deep links, production API discovery, and stronger anonymity
  mechanisms remain future milestones.
