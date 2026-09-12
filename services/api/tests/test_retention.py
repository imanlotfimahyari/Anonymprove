from datetime import UTC, datetime, timedelta
from uuid import UUID

from fastapi.testclient import TestClient
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.retention import purge_closed_round_credential_metadata
from app.models.feedback import (
    AnonymousResponse,
    Answer,
    CredentialClaim,
    FeedbackRound,
    ResponseCredential,
)


def _user(client: TestClient) -> dict[str, str]:
    response = client.post("/api/v1/users/session")
    assert response.status_code == 201
    return response.json()


def _auth(user: dict[str, str]) -> dict[str, str]:
    return {"Authorization": f"Bearer {user['sessionToken']}"}


def test_purge_removes_credential_metadata_but_keeps_anonymous_feedback(
    client: TestClient,
    db: Session,
) -> None:
    owner = _user(client)
    members = [_user(client) for _ in range(3)]

    group = client.post(
        "/api/v1/groups",
        headers=_auth(owner),
        json={"name": "Retention Group"},
    ).json()

    for member in members:
        joined = client.post(
            "/api/v1/groups/join",
            headers=_auth(member),
            json={"joinCode": group["joinCode"]},
        )
        assert joined.status_code == 200

    created_round = client.post(
        f"/api/v1/groups/{group['id']}/feedback-rounds",
        headers=_auth(owner),
        json={"minResponses": 3},
    )
    assert created_round.status_code == 201
    round_ = created_round.json()

    opened = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/open",
        headers=_auth(owner),
    )
    assert opened.status_code == 200

    detail = client.get(
        f"/api/v1/feedback-rounds/{round_['id']}",
        headers=_auth(members[0]),
    )
    assert detail.status_code == 200

    claim = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/credentials",
        headers=_auth(members[0]),
    )
    assert claim.status_code == 201

    answers = [
        {"questionId": question["id"], "score": 4}
        for question in detail.json()["questions"]
        if question["kind"] == "scale"
    ]
    submitted = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/responses",
        headers={"X-Response-Token": claim.json()["responseToken"]},
        json={"answers": answers},
    )
    assert submitted.status_code == 201

    round_id = UUID(round_["id"])
    persisted_round = db.get(FeedbackRound, round_id)
    assert persisted_round is not None
    persisted_round.status = "closed"
    persisted_round.closed_at = datetime.now(UTC) - timedelta(days=31)
    db.commit()

    assert (
        db.scalar(
            select(func.count())
            .select_from(CredentialClaim)
            .where(CredentialClaim.round_id == round_id)
        )
        == 1
    )
    assert (
        db.scalar(
            select(func.count())
            .select_from(ResponseCredential)
            .where(ResponseCredential.round_id == round_id)
        )
        == 1
    )
    anonymous_before = db.scalar(
        select(func.count())
        .select_from(AnonymousResponse)
        .where(AnonymousResponse.round_id == round_id)
    )
    answer_before = db.scalar(select(func.count()).select_from(Answer))

    result = purge_closed_round_credential_metadata(
        db,
        older_than=datetime.now(UTC) - timedelta(days=30),
    )
    db.commit()

    assert result.credential_claims_deleted == 1
    assert result.response_credentials_deleted == 1
    assert (
        db.scalar(
            select(func.count())
            .select_from(CredentialClaim)
            .where(CredentialClaim.round_id == round_id)
        )
        == 0
    )
    assert (
        db.scalar(
            select(func.count())
            .select_from(ResponseCredential)
            .where(ResponseCredential.round_id == round_id)
        )
        == 0
    )
    assert (
        db.scalar(
            select(func.count())
            .select_from(AnonymousResponse)
            .where(AnonymousResponse.round_id == round_id)
        )
        == anonymous_before
    )
    assert db.scalar(select(func.count()).select_from(Answer)) == answer_before
