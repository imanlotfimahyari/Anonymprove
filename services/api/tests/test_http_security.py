import pytest
from fastapi.testclient import TestClient

from app.core.config import Settings
from app.core.http_security import validate_runtime_security
from app.main import create_app


def _settings(**overrides: object) -> Settings:
    values: dict[str, object] = {
        "environment": "local",
        "jwt_secret": "test-runtime-secret-with-at-least-32-characters",
        "database_url": "sqlite+pysqlite:///:memory:",
        "cors_origins": "http://127.0.0.1:8080",
        "trusted_hosts": "*",
    }
    values.update(overrides)
    return Settings(**values)


def test_security_headers_are_added(client: TestClient) -> None:
    response = client.get("/health/live")

    assert response.status_code == 200
    assert response.headers["cache-control"] == "no-store"
    assert response.headers["x-content-type-options"] == "nosniff"
    assert response.headers["x-frame-options"] == "DENY"
    assert response.headers["referrer-policy"] == "no-referrer"
    assert response.headers["cross-origin-resource-policy"] == "same-site"


def test_production_rejects_wildcard_cors() -> None:
    settings = _settings(
        environment="production",
        cors_origins="*",
        trusted_hosts="api.example.test",
    )

    with pytest.raises(RuntimeError, match="CORS_ORIGINS"):
        validate_runtime_security(settings)


def test_production_rejects_wildcard_trusted_hosts() -> None:
    settings = _settings(
        environment="production",
        cors_origins="https://app.example.test",
        trusted_hosts="*",
    )

    with pytest.raises(RuntimeError, match="TRUSTED_HOSTS"):
        validate_runtime_security(settings)


def test_production_disables_api_docs() -> None:
    settings = _settings(
        environment="production",
        cors_origins="https://app.example.test",
        trusted_hosts="api.example.test",
    )
    app = create_app(settings)
    client = TestClient(app, base_url="https://api.example.test")

    assert client.get("/docs").status_code == 404
    assert client.get("/redoc").status_code == 404
    assert client.get("/openapi.json").status_code == 404


def test_trusted_host_middleware_rejects_unlisted_host() -> None:
    settings = _settings(trusted_hosts="api.example.test")
    app = create_app(settings)
    client = TestClient(app, base_url="https://wrong.example.test")

    response = client.get("/health/live")

    assert response.status_code == 400
