from datetime import UTC, datetime, timedelta
from uuid import uuid4

import jwt
from fastapi.testclient import TestClient

from app.core.config import get_settings


def test_create_session_and_get_profile(client: TestClient) -> None:
    session_response = client.post("/api/v1/users/session")

    assert session_response.status_code == 201
    body = session_response.json()
    assert body["alias"].startswith("User-")
    assert body["sessionToken"]
    assert body["groupId"]

    profile_response = client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {body['sessionToken']}"},
    )

    assert profile_response.status_code == 200
    assert profile_response.json() == {
        "alias": body["alias"],
        "groupId": body["groupId"],
    }


def test_profile_requires_bearer_token(client: TestClient) -> None:
    response = client.get("/api/v1/users/me")

    assert response.status_code == 401
    assert response.json()["detail"] == "Missing bearer token"


def test_profile_rejects_invalid_token(client: TestClient) -> None:
    response = client.get(
        "/api/v1/users/me",
        headers={"Authorization": "Bearer not-a-valid-token"},
    )

    assert response.status_code == 401
    assert response.json()["detail"] == "Invalid token"


def test_profile_rejects_expired_token(client: TestClient) -> None:
    settings = get_settings()
    now = datetime.now(UTC)
    token = jwt.encode(
        {
            "sub": str(uuid4()),
            "groupId": str(uuid4()),
            "iat": now - timedelta(minutes=2),
            "exp": now - timedelta(minutes=1),
        },
        settings.jwt_secret.get_secret_value(),
        algorithm=settings.jwt_algorithm,
    )

    response = client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 401
    assert response.json()["detail"] == "Session expired"


def test_profile_rejects_signed_token_without_server_session(client: TestClient) -> None:
    settings = get_settings()
    now = datetime.now(UTC)
    token = jwt.encode(
        {
            "sub": str(uuid4()),
            "groupId": str(uuid4()),
            "iat": now,
            "exp": now + timedelta(minutes=5),
        },
        settings.jwt_secret.get_secret_value(),
        algorithm=settings.jwt_algorithm,
    )

    response = client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {token}"},
    )

    assert response.status_code == 401
    assert response.json()["detail"] == "Session not found"
