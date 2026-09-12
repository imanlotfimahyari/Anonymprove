from uuid import UUID

from fastapi.testclient import TestClient
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.models.feedback import AnonymousResponse, Answer, CredentialClaim, ResponseCredential


def _user(client: TestClient) -> dict[str, str]:
    response = client.post("/api/v1/users/session")
    assert response.status_code == 201
    return response.json()


def _auth(user: dict[str, str]) -> dict[str, str]:
    return {"Authorization": f"Bearer {user['sessionToken']}"}


def _group_with_members(
    client: TestClient, member_count: int = 3
) -> tuple[dict[str, str], list[dict[str, str]], dict[str, str]]:
    owner = _user(client)
    group = client.post(
        "/api/v1/groups", headers=_auth(owner), json={"name": "Feedback Friends"}
    ).json()
    members: list[dict[str, str]] = []
    for _ in range(member_count):
        member = _user(client)
        join = client.post(
            "/api/v1/groups/join",
            headers=_auth(member),
            json={"joinCode": group["joinCode"]},
        )
        assert join.status_code == 200
        members.append(member)
    return owner, members, group


def _round(
    client: TestClient,
    owner: dict[str, str],
    group: dict[str, str],
    min_responses: int = 3,
) -> dict[str, object]:
    response = client.post(
        f"/api/v1/groups/{group['id']}/feedback-rounds",
        headers=_auth(owner),
        json={"minResponses": min_responses},
    )
    assert response.status_code == 201
    return response.json()


def _group_health_round(
    client: TestClient,
    creator: dict[str, str],
    group: dict[str, str],
    min_responses: int = 3,
) -> dict[str, object]:
    response = client.post(
        f"/api/v1/groups/{group['id']}/feedback-rounds",
        headers=_auth(creator),
        json={
            "roundType": "group_health",
            "minResponses": min_responses,
        },
    )

    assert response.status_code == 201
    return response.json()


def _open(client: TestClient, owner: dict[str, str], round_: dict[str, object]) -> None:
    response = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/open",
        headers=_auth(owner),
    )
    assert response.status_code == 200


def _detail(
    client: TestClient, user: dict[str, str], round_: dict[str, object]
) -> dict[str, object]:
    response = client.get(f"/api/v1/feedback-rounds/{round_['id']}", headers=_auth(user))
    assert response.status_code == 200
    return response.json()


def _answers(
    detail: dict[str, object], score: int, comment: str | None = None
) -> list[dict[str, object]]:
    answers: list[dict[str, object]] = []
    for question in detail["questions"]:
        if question["kind"] == "scale":
            answers.append({"questionId": question["id"], "score": score})
        elif comment is not None:
            answers.append({"questionId": question["id"], "text": comment})
    return answers


def _claim(client: TestClient, member: dict[str, str], round_: dict[str, object]) -> str:
    response = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/credentials",
        headers=_auth(member),
    )
    assert response.status_code == 201
    return response.json()["responseToken"]


def _submit(
    client: TestClient,
    round_: dict[str, object],
    token: str,
    answers: list[dict[str, object]],
) -> None:
    response = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/responses",
        headers={"X-Response-Token": token},
        json={"answers": answers},
    )
    assert response.status_code == 201


def test_core_questionnaire_is_available_to_authenticated_user(client: TestClient) -> None:
    user = _user(client)
    response = client.get("/api/v1/questionnaires/core-feedback-v1", headers=_auth(user))
    assert response.status_code == 200
    body = response.json()
    assert body["version"] == 1
    assert len(body["questions"]) == 8
    assert body["questions"][0]["kind"] == "scale"
    assert body["questions"][-1]["kind"] == "text"


def test_core_group_health_questionnaire_is_available(
    client: TestClient,
) -> None:
    user = _user(client)

    response = client.get(
        "/api/v1/questionnaires/core-group-health-v1",
        headers=_auth(user),
    )

    assert response.status_code == 200

    body = response.json()

    assert body["slug"] == "core-group-health-v1"
    assert body["version"] == 1
    assert body["status"] == "published"
    assert len(body["questions"]) == 8

    assert body["questions"][0]["key"] == "communication"
    assert body["questions"][0]["kind"] == "scale"
    assert body["questions"][-1]["key"] == "improvement"
    assert body["questions"][-1]["kind"] == "text"


def test_unknown_questionnaire_is_rejected(client: TestClient) -> None:
    user = _user(client)
    response = client.get("/api/v1/questionnaires/unknown", headers=_auth(user))
    assert response.status_code == 404


def test_member_can_create_list_and_read_draft_round(client: TestClient) -> None:
    owner, members, group = _group_with_members(client)
    round_ = _round(client, owner, group)
    assert round_["status"] == "draft"
    assert round_["subjectUserId"] == owner["userId"]

    listed = client.get(
        f"/api/v1/groups/{group['id']}/feedback-rounds",
        headers=_auth(members[0]),
    )
    assert listed.status_code == 200
    assert listed.json()[0]["id"] == round_["id"]

    detail = _detail(client, members[0], round_)
    assert len(detail["questions"]) == 8


def test_outsider_cannot_create_or_read_round(client: TestClient) -> None:
    owner, _, group = _group_with_members(client)
    outsider = _user(client)
    create = client.post(
        f"/api/v1/groups/{group['id']}/feedback-rounds",
        headers=_auth(outsider),
        json={},
    )
    assert create.status_code == 404

    round_ = _round(client, owner, group)
    read = client.get(f"/api/v1/feedback-rounds/{round_['id']}", headers=_auth(outsider))
    assert read.status_code == 404


def test_round_cannot_open_below_threshold(client: TestClient) -> None:
    owner, _, group = _group_with_members(client, member_count=2)
    round_ = _round(client, owner, group)
    response = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/open",
        headers=_auth(owner),
    )
    assert response.status_code == 409


def test_only_subject_can_open_round(client: TestClient) -> None:
    owner, members, group = _group_with_members(client)
    round_ = _round(client, owner, group)
    response = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/open",
        headers=_auth(members[0]),
    )
    assert response.status_code == 404


def test_round_cannot_be_opened_twice(client: TestClient) -> None:
    owner, _, group = _group_with_members(client)
    round_ = _round(client, owner, group)
    _open(client, owner, round_)
    response = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/open",
        headers=_auth(owner),
    )
    assert response.status_code == 409


def test_subject_cannot_claim_response_credential(client: TestClient) -> None:
    owner, _, group = _group_with_members(client)
    round_ = _round(client, owner, group)
    _open(client, owner, round_)
    response = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/credentials",
        headers=_auth(owner),
    )
    assert response.status_code == 403


def test_credential_cannot_be_claimed_before_open(client: TestClient) -> None:
    owner, members, group = _group_with_members(client)
    round_ = _round(client, owner, group)
    response = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/credentials",
        headers=_auth(members[0]),
    )
    assert response.status_code == 409


def test_member_can_claim_only_one_credential(client: TestClient) -> None:
    owner, members, group = _group_with_members(client)
    round_ = _round(client, owner, group)
    _open(client, owner, round_)
    _claim(client, members[0], round_)
    response = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/credentials",
        headers=_auth(members[0]),
    )
    assert response.status_code == 409


def test_claim_and_anonymous_credential_have_no_database_relationship(
    client: TestClient, db: Session
) -> None:
    owner, members, group = _group_with_members(client)
    round_ = _round(client, owner, group)
    _open(client, owner, round_)
    _claim(client, members[0], round_)

    claim = db.scalar(select(CredentialClaim))
    credential = db.scalar(select(ResponseCredential))
    assert claim is not None
    assert credential is not None
    assert claim.user_id == UUID(members[0]["userId"])
    assert not hasattr(credential, "user_id")
    assert not hasattr(credential, "claim_id")


def test_valid_credential_submits_response_without_user_identity(
    client: TestClient, db: Session
) -> None:
    owner, members, group = _group_with_members(client)
    round_ = _round(client, owner, group)
    _open(client, owner, round_)
    detail = _detail(client, members[0], round_)
    token = _claim(client, members[0], round_)
    _submit(client, round_, token, _answers(detail, 4, "Be more patient."))

    response = db.scalar(select(AnonymousResponse))
    answer = db.scalar(select(Answer))
    assert response is not None
    assert answer is not None
    assert not hasattr(response, "user_id")
    assert not hasattr(response, "credential_id")
    assert not hasattr(answer, "user_id")


def test_invalid_or_reused_credential_is_rejected(client: TestClient) -> None:
    owner, members, group = _group_with_members(client)
    round_ = _round(client, owner, group)
    _open(client, owner, round_)
    detail = _detail(client, members[0], round_)
    answers = _answers(detail, 4)

    invalid = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/responses",
        headers={"X-Response-Token": "x" * 43},
        json={"answers": answers},
    )
    assert invalid.status_code == 401

    token = _claim(client, members[0], round_)
    _submit(client, round_, token, answers)
    reused = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/responses",
        headers={"X-Response-Token": token},
        json={"answers": answers},
    )
    assert reused.status_code == 409


def test_submission_requires_all_required_questions(client: TestClient) -> None:
    owner, members, group = _group_with_members(client)
    round_ = _round(client, owner, group)
    _open(client, owner, round_)
    detail = _detail(client, members[0], round_)
    token = _claim(client, members[0], round_)
    answers = _answers(detail, 3)[:-1]
    response = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/responses",
        headers={"X-Response-Token": token},
        json={"answers": answers},
    )
    assert response.status_code == 422


def test_submission_rejects_duplicate_and_wrong_answer_types(client: TestClient) -> None:
    owner, members, group = _group_with_members(client)
    round_ = _round(client, owner, group)
    _open(client, owner, round_)
    detail = _detail(client, members[0], round_)
    token = _claim(client, members[0], round_)
    answers = _answers(detail, 3)
    answers.append(answers[0])
    duplicate = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/responses",
        headers={"X-Response-Token": token},
        json={"answers": answers},
    )
    assert duplicate.status_code == 422

    text_question = detail["questions"][-1]
    wrong_text = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/responses",
        headers={"X-Response-Token": token},
        json={"answers": _answers(detail, 3) + [{"questionId": text_question["id"], "score": 3}]},
    )
    assert wrong_text.status_code == 422


def test_results_are_thresholded_and_aggregated(client: TestClient) -> None:
    owner, members, group = _group_with_members(client)
    round_ = _round(client, owner, group)
    _open(client, owner, round_)
    detail = _detail(client, members[0], round_)

    for index, member in enumerate(members):
        token = _claim(client, member, round_)
        _submit(
            client,
            round_,
            token,
            _answers(detail, index + 3, f"Comment {index + 1}"),
        )

    before_close = client.get(
        f"/api/v1/feedback-rounds/{round_['id']}/results",
        headers=_auth(owner),
    )
    assert before_close.status_code == 409

    close = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/close",
        headers=_auth(owner),
    )
    assert close.status_code == 200

    results = client.get(
        f"/api/v1/feedback-rounds/{round_['id']}/results",
        headers=_auth(owner),
    )
    assert results.status_code == 200
    body = results.json()
    assert body["responseCount"] == 3
    assert body["scaleResults"][0]["average"] == 4.0
    assert body["scaleResults"][0]["distribution"] == {
        "1": 0,
        "2": 0,
        "3": 1,
        "4": 1,
        "5": 1,
    }
    assert body["textResults"][0]["comments"] == ["Comment 1", "Comment 2", "Comment 3"]
    assert "responses" not in body


def test_results_remain_hidden_when_closed_below_threshold(client: TestClient) -> None:
    owner, members, group = _group_with_members(client)
    round_ = _round(client, owner, group)
    _open(client, owner, round_)
    detail = _detail(client, members[0], round_)
    token = _claim(client, members[0], round_)
    _submit(client, round_, token, _answers(detail, 4))

    client.post(f"/api/v1/feedback-rounds/{round_['id']}/close", headers=_auth(owner))
    results = client.get(
        f"/api/v1/feedback-rounds/{round_['id']}/results",
        headers=_auth(owner),
    )
    assert results.status_code == 409
    assert results.json()["detail"] == "Minimum response threshold not met"


def test_non_subject_cannot_close_or_read_results(client: TestClient) -> None:
    owner, members, group = _group_with_members(client)
    round_ = _round(client, owner, group)
    _open(client, owner, round_)
    close = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/close",
        headers=_auth(members[0]),
    )
    assert close.status_code == 404
    results = client.get(
        f"/api/v1/feedback-rounds/{round_['id']}/results",
        headers=_auth(members[0]),
    )
    assert results.status_code == 404


def test_group_health_round_uses_group_health_questionnaire(
    client: TestClient,
) -> None:
    owner, _, group = _group_with_members(
        client,
        member_count=2,
    )

    round_ = _group_health_round(
        client,
        owner,
        group,
    )

    assert round_["roundType"] == "group_health"
    assert round_["subjectUserId"] is None
    assert round_["createdByUserId"] == owner["userId"]
    assert round_["questionnaireSlug"] == "core-group-health-v1"


def test_group_health_round_can_open_with_three_total_members(
    client: TestClient,
) -> None:
    owner, _, group = _group_with_members(
        client,
        member_count=2,
    )

    round_ = _group_health_round(
        client,
        owner,
        group,
    )

    response = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/open",
        headers=_auth(owner),
    )

    assert response.status_code == 200
    assert response.json()["status"] == "open"


def test_group_health_creator_can_claim_response_credential(
    client: TestClient,
) -> None:
    owner, _, group = _group_with_members(
        client,
        member_count=2,
    )

    round_ = _group_health_round(
        client,
        owner,
        group,
    )

    _open(client, owner, round_)

    response = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/credentials",
        headers=_auth(owner),
    )

    assert response.status_code == 201
    assert response.json()["responseToken"]


def test_only_group_health_creator_can_manage_round(
    client: TestClient,
) -> None:
    owner, members, group = _group_with_members(
        client,
        member_count=2,
    )

    round_ = _group_health_round(
        client,
        owner,
        group,
    )

    unauthorized_open = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/open",
        headers=_auth(members[0]),
    )

    assert unauthorized_open.status_code == 404

    _open(client, owner, round_)

    unauthorized_close = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/close",
        headers=_auth(members[0]),
    )

    assert unauthorized_close.status_code == 404


def test_group_health_results_are_available_to_group_members(
    client: TestClient,
) -> None:
    owner, members, group = _group_with_members(
        client,
        member_count=2,
    )

    participants = [owner, *members]

    round_ = _group_health_round(
        client,
        owner,
        group,
    )

    _open(client, owner, round_)

    detail = _detail(
        client,
        owner,
        round_,
    )

    for index, participant in enumerate(
        participants,
        start=1,
    ):
        token = _claim(
            client,
            participant,
            round_,
        )

        _submit(
            client,
            round_,
            token,
            _answers(
                detail,
                3 + (index % 2),
                f"Group improvement {index}.",
            ),
        )

    close = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/close",
        headers=_auth(owner),
    )

    assert close.status_code == 200

    for participant in participants:
        results = client.get(
            f"/api/v1/feedback-rounds/{round_['id']}/results",
            headers=_auth(participant),
        )

        assert results.status_code == 200
        assert results.json()["responseCount"] == 3

    outsider = _user(client)

    outsider_results = client.get(
        f"/api/v1/feedback-rounds/{round_['id']}/results",
        headers=_auth(outsider),
    )

    assert outsider_results.status_code == 404


def test_feedback_round_creation_is_rate_limited(client: TestClient) -> None:
    settings = get_settings()
    owner, _, group = _group_with_members(client, member_count=0)

    for _ in range(settings.rate_limit_round_create_max_requests):
        response = client.post(
            f"/api/v1/groups/{group['id']}/feedback-rounds",
            headers=_auth(owner),
            json={"minResponses": 3},
        )
        assert response.status_code == 201

    blocked = client.post(
        f"/api/v1/groups/{group['id']}/feedback-rounds",
        headers=_auth(owner),
        json={"minResponses": 3},
    )

    assert blocked.status_code == 429
    assert int(blocked.headers["Retry-After"]) >= 1


def test_response_credential_claim_attempts_are_rate_limited(
    client: TestClient,
) -> None:
    settings = get_settings()
    owner, members, group = _group_with_members(client)
    round_ = _round(client, owner, group)
    _open(client, owner, round_)

    endpoint = f"/api/v1/feedback-rounds/{round_['id']}/credentials"
    headers = _auth(members[0])

    first = client.post(endpoint, headers=headers)
    assert first.status_code == 201

    for _ in range(settings.rate_limit_credential_claim_max_requests - 1):
        duplicate = client.post(endpoint, headers=headers)
        assert duplicate.status_code == 409

    blocked = client.post(endpoint, headers=headers)

    assert blocked.status_code == 429
    assert int(blocked.headers["Retry-After"]) >= 1
