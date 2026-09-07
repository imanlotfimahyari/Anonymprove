# 0005 - Group-scoped custom questionnaires

## Status

Accepted for M4A.

## Context

The M2 feedback engine used one built-in questionnaire. M4 needs group members to define structured
questionnaires while preserving historical meaning, anonymous response storage, and the existing
minimum-response privacy threshold.

## Decision

Custom questionnaires are scoped to one group and have a creator. They move through
`draft -> published`.

Draft questionnaires can be replaced by their creator. Published questionnaires are immutable.
Further edits start a new draft version that keeps the same stable slug and increments `version`.
Existing feedback rounds continue to reference the exact questionnaire row they were created with.

The built-in `core-feedback-v1` remains global and published.

Supported custom block types are:

- `scale`
- `single_choice`
- `multiple_choice`
- `short_text`
- `long_text`
- `description` (informational; never stores an answer)

The legacy built-in `text` kind remains supported for backward compatibility.

Choice labels are stored in `question_options`. Anonymous answers retain the existing `answers`
row, while selected choices are stored in `answer_choice_options`. Neither table contains user
identity, claim identity, or response-credential identity.

A published questionnaire must contain at least one answerable question. Feedback rounds may use a
published global questionnaire or a published questionnaire belonging to their own group, never a
draft or a questionnaire from another group.

## Privacy boundary

Custom free-text prompts can ask respondents to reveal identifying information. Schema-level
unlinkability cannot prevent self-identification inside answer content. The Flutter builder must
therefore warn authors not to request names, initials, addresses, unique events, or other identifying
details.

The M2 limitation also remains: a privileged infrastructure operator may correlate requests or
database timing. M4 does not claim cryptographic anonymity.

## Consequences

- Questionnaire meaning is stable for historical rounds.
- Mixed question types are normalized rather than encoded in JSON or comma-separated strings.
- Multiple-choice result counts may exceed response count because one response can select several
  options.
- Group authorization protects questionnaire definitions, while anonymous response submission still
  uses only `X-Response-Token`.
