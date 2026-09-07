from fastapi.testclient import TestClient
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.feedback import AnswerChoiceOption


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
        "/api/v1/groups", headers=_auth(owner), json={"name": "Questionnaire Friends"}
    ).json()
    members: list[dict[str, str]] = []
    for _ in range(member_count):
        member = _user(client)
        joined = client.post(
            "/api/v1/groups/join",
            headers=_auth(member),
            json={"joinCode": group["joinCode"]},
        )
        assert joined.status_code == 200
        members.append(member)
    return owner, members, group


def _payload() -> dict[str, object]:
    return {
        "name": "Communication check-in",
        "description": "Focus on recent observable interactions.",
        "questions": [
            {
                "kind": "description",
                "prompt": "Do not include names or identifying details in text answers.",
            },
            {
                "kind": "scale",
                "prompt": "Communicates clearly.",
                "required": True,
                "minScore": 1,
                "maxScore": 5,
            },
            {
                "kind": "single_choice",
                "prompt": "How are disagreements usually handled?",
                "options": ["Constructively", "Avoided", "Escalated"],
            },
            {
                "kind": "multiple_choice",
                "prompt": "Which strengths do you notice?",
                "options": ["Listening", "Reliability", "Empathy"],
            },
            {
                "kind": "short_text",
                "prompt": "One improvement suggestion?",
                "required": False,
            },
        ],
    }


def _create_questionnaire(
    client: TestClient, owner: dict[str, str], group: dict[str, str]
) -> dict[str, object]:
    response = client.post(
        f"/api/v1/groups/{group['id']}/questionnaires",
        headers=_auth(owner),
        json=_payload(),
    )
    assert response.status_code == 201
    return response.json()


def test_group_member_can_create_and_publish_mixed_questionnaire(client: TestClient) -> None:
    owner, members, group = _group_with_members(client)
    questionnaire = _create_questionnaire(client, owner, group)
    assert questionnaire["status"] == "draft"
    assert questionnaire["groupId"] == group["id"]
    assert [question["kind"] for question in questionnaire["questions"]] == [
        "description",
        "scale",
        "single_choice",
        "multiple_choice",
        "short_text",
    ]
    assert len(questionnaire["questions"][2]["options"]) == 3

    listed = client.get(
        f"/api/v1/groups/{group['id']}/questionnaires",
        headers=_auth(members[0]),
    )
    assert listed.status_code == 200
    assert any(item["slug"] == "core-feedback-v1" for item in listed.json())
    assert any(item["id"] == questionnaire["id"] for item in listed.json())

    published = client.post(
        f"/api/v1/groups/{group['id']}/questionnaires/{questionnaire['id']}/publish",
        headers=_auth(owner),
    )
    assert published.status_code == 200
    assert published.json()["status"] == "published"


def test_questionnaire_authorization_and_immutability(client: TestClient) -> None:
    owner, members, group = _group_with_members(client)
    questionnaire = _create_questionnaire(client, owner, group)

    other_update = client.put(
        f"/api/v1/groups/{group['id']}/questionnaires/{questionnaire['id']}",
        headers=_auth(members[0]),
        json=_payload(),
    )
    assert other_update.status_code == 403

    outsider = _user(client)
    outsider_list = client.get(
        f"/api/v1/groups/{group['id']}/questionnaires",
        headers=_auth(outsider),
    )
    assert outsider_list.status_code == 404

    publish = client.post(
        f"/api/v1/groups/{group['id']}/questionnaires/{questionnaire['id']}/publish",
        headers=_auth(owner),
    )
    assert publish.status_code == 200

    immutable = client.put(
        f"/api/v1/groups/{group['id']}/questionnaires/{questionnaire['id']}",
        headers=_auth(owner),
        json=_payload(),
    )
    assert immutable.status_code == 409


def test_published_questionnaire_can_create_new_draft_version(client: TestClient) -> None:
    owner, _, group = _group_with_members(client)
    questionnaire = _create_questionnaire(client, owner, group)
    client.post(
        f"/api/v1/groups/{group['id']}/questionnaires/{questionnaire['id']}/publish",
        headers=_auth(owner),
    )

    version = client.post(
        f"/api/v1/groups/{group['id']}/questionnaires/{questionnaire['id']}/versions",
        headers=_auth(owner),
    )
    assert version.status_code == 201
    body = version.json()
    assert body["status"] == "draft"
    assert body["version"] == 2
    assert body["slug"] == questionnaire["slug"]
    assert len(body["questions"]) == len(questionnaire["questions"])


def test_draft_questionnaire_cannot_be_used_for_feedback_round(client: TestClient) -> None:
    owner, _, group = _group_with_members(client)
    questionnaire = _create_questionnaire(client, owner, group)
    response = client.post(
        f"/api/v1/groups/{group['id']}/feedback-rounds",
        headers=_auth(owner),
        json={"questionnaireId": questionnaire["id"], "minResponses": 3},
    )
    assert response.status_code == 404


def test_mixed_questionnaire_submission_and_results_are_anonymous(
    client: TestClient, db: Session
) -> None:
    owner, members, group = _group_with_members(client)
    questionnaire = _create_questionnaire(client, owner, group)
    published = client.post(
        f"/api/v1/groups/{group['id']}/questionnaires/{questionnaire['id']}/publish",
        headers=_auth(owner),
    ).json()

    round_response = client.post(
        f"/api/v1/groups/{group['id']}/feedback-rounds",
        headers=_auth(owner),
        json={"questionnaireId": published["id"], "minResponses": 3},
    )
    assert round_response.status_code == 201
    round_ = round_response.json()
    opened = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/open",
        headers=_auth(owner),
    )
    assert opened.status_code == 200

    detail = client.get(f"/api/v1/feedback-rounds/{round_['id']}", headers=_auth(members[0])).json()
    questions = {question["kind"]: question for question in detail["questions"]}
    single_options = questions["single_choice"]["options"]
    multiple_options = questions["multiple_choice"]["options"]

    scores = [3, 4, 5]
    for index, member in enumerate(members):
        credential = client.post(
            f"/api/v1/feedback-rounds/{round_['id']}/credentials",
            headers=_auth(member),
        )
        assert credential.status_code == 201
        token = credential.json()["responseToken"]
        answers = [
            {"questionId": questions["scale"]["id"], "score": scores[index]},
            {
                "questionId": questions["single_choice"]["id"],
                "optionIds": [single_options[index % 2]["id"]],
            },
            {
                "questionId": questions["multiple_choice"]["id"],
                "optionIds": [
                    multiple_options[0]["id"],
                    multiple_options[(index % 2) + 1]["id"],
                ],
            },
            {
                "questionId": questions["short_text"]["id"],
                "text": f"Suggestion {index + 1}",
            },
        ]
        submitted = client.post(
            f"/api/v1/feedback-rounds/{round_['id']}/responses",
            headers={"X-Response-Token": token},
            json={"answers": answers},
        )
        assert submitted.status_code == 201

    selection = db.scalar(select(AnswerChoiceOption))
    assert selection is not None
    assert not hasattr(selection, "user_id")

    closed = client.post(
        f"/api/v1/feedback-rounds/{round_['id']}/close",
        headers=_auth(owner),
    )
    assert closed.status_code == 200
    results = client.get(
        f"/api/v1/feedback-rounds/{round_['id']}/results",
        headers=_auth(owner),
    )
    assert results.status_code == 200
    body = results.json()
    assert body["responseCount"] == 3
    assert body["scaleResults"][0]["average"] == 4.0
    assert body["textResults"][0]["comments"] == [
        "Suggestion 1",
        "Suggestion 2",
        "Suggestion 3",
    ]
    assert len(body["choiceResults"]) == 2
    single_counts = [item["count"] for item in body["choiceResults"][0]["options"]]
    assert single_counts == [2, 1, 0]
    multiple_counts = [item["count"] for item in body["choiceResults"][1]["options"]]
    assert multiple_counts == [3, 2, 1]
