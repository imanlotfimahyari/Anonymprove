import logging

from fastapi.testclient import TestClient

from app.core.request_logging import REQUEST_LOGGER_NAME


def _create_user(client: TestClient) -> dict[str, str]:
    response = client.post("/api/v1/users/session")
    assert response.status_code == 201
    return response.json()


def _auth(session: dict[str, str]) -> dict[str, str]:
    return {"Authorization": f"Bearer {session['sessionToken']}"}


def test_safe_request_logging_omits_sensitive_values(
    client: TestClient,
    caplog,
) -> None:
    user = _create_user(client)

    caplog.clear()
    with caplog.at_level(logging.INFO, logger=REQUEST_LOGGER_NAME):
        response = client.post(
            "/api/v1/groups",
            headers=_auth(user),
            json={"name": "Private Logging Test Group"},
        )

    assert response.status_code == 201
    join_code = response.json()["joinCode"]

    messages = "\n".join(
        record.getMessage() for record in caplog.records if record.name == REQUEST_LOGGER_NAME
    )

    assert "method=POST" in messages
    assert "route=/api/v1/groups" in messages
    assert "status=201" in messages

    assert user["sessionToken"] not in messages
    assert join_code not in messages
    assert "Authorization" not in messages
    assert "Private Logging Test Group" not in messages
    assert "127.0.0.1" not in messages
    assert "testclient" not in messages


def test_unmatched_route_does_not_log_query_string(
    client: TestClient,
    caplog,
) -> None:
    query_marker = "query-marker-must-not-appear"

    caplog.clear()
    with caplog.at_level(logging.INFO, logger=REQUEST_LOGGER_NAME):
        response = client.get(
            f"/definitely-not-a-route?token={query_marker}",
        )

    assert response.status_code == 404

    messages = "\n".join(
        record.getMessage() for record in caplog.records if record.name == REQUEST_LOGGER_NAME
    )

    assert "route=<unmatched>" in messages
    assert query_marker not in messages
    assert "token=" not in messages
