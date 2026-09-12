from dataclasses import dataclass
from datetime import datetime

from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from app.models.feedback import CredentialClaim, FeedbackRound, ResponseCredential


@dataclass(frozen=True, slots=True)
class RetentionCandidateCounts:
    credential_claims: int
    response_credentials: int


@dataclass(frozen=True, slots=True)
class RetentionPurgeResult:
    credential_claims_deleted: int
    response_credentials_deleted: int


def _eligible_round_ids(older_than: datetime):
    return select(FeedbackRound.id).where(
        FeedbackRound.status == "closed",
        FeedbackRound.closed_at.is_not(None),
        FeedbackRound.closed_at < older_than,
    )


def count_closed_round_credential_metadata(
    db: Session,
    *,
    older_than: datetime,
) -> RetentionCandidateCounts:
    eligible_round_ids = _eligible_round_ids(older_than)

    claim_ids = select(CredentialClaim.id).where(CredentialClaim.round_id.in_(eligible_round_ids))
    credential_ids = select(ResponseCredential.id).where(
        ResponseCredential.round_id.in_(eligible_round_ids)
    )

    return RetentionCandidateCounts(
        credential_claims=len(db.scalars(claim_ids).all()),
        response_credentials=len(db.scalars(credential_ids).all()),
    )


def purge_closed_round_credential_metadata(
    db: Session,
    *,
    older_than: datetime,
) -> RetentionPurgeResult:
    """Delete identity-adjacent credential metadata for old closed rounds.

    Anonymous responses and answers are intentionally untouched.
    """
    eligible_round_ids = select(FeedbackRound.id).where(
        FeedbackRound.status == "closed",
        FeedbackRound.closed_at.is_not(None),
        FeedbackRound.closed_at < older_than,
    )

    claims_result = db.execute(
        delete(CredentialClaim)
        .where(CredentialClaim.round_id.in_(eligible_round_ids))
        .execution_options(synchronize_session=False)
    )
    credentials_result = db.execute(
        delete(ResponseCredential)
        .where(ResponseCredential.round_id.in_(eligible_round_ids))
        .execution_options(synchronize_session=False)
    )

    return RetentionPurgeResult(
        credential_claims_deleted=max(claims_result.rowcount or 0, 0),
        response_credentials_deleted=max(credentials_result.rowcount or 0, 0),
    )
