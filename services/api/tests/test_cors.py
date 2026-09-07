from fastapi.testclient import TestClient


def test_local_flutter_web_origin_is_allowed(client: TestClient) -> None:
    response = client.options(
        "/api/v1/users/session",
        headers={
            "Origin": "http://127.0.0.1:8080",
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "content-type",
        },
    )

    assert response.status_code == 200
    assert response.headers["access-control-allow-origin"] == "http://127.0.0.1:8080"


def test_response_token_header_is_allowed_for_flutter_web(client: TestClient) -> None:
    response = client.options(
        "/api/v1/feedback-rounds/00000000-0000-0000-0000-000000000000/responses",
        headers={
            "Origin": "http://127.0.0.1:8080",
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "content-type,x-response-token",
        },
    )

    assert response.status_code == 200
    allowed_headers = response.headers["access-control-allow-headers"].lower()
    assert "x-response-token" in allowed_headers
