import pytest
from pydantic import SecretStr

from app.core.config import Settings
from app.core.database_security import validate_database_url


def _settings(database_url: str, *, environment: str = "production") -> Settings:
    return Settings(
        environment=environment,
        jwt_secret=SecretStr("test-runtime-secret-with-at-least-32-characters"),
        database_url=database_url,
        cors_origins="https://app.example.test",
        trusted_hosts="api.example.test",
    )


def test_local_database_url_is_not_restricted() -> None:
    settings = _settings(
        "sqlite+pysqlite:///:memory:",
        environment="local",
    )

    validate_database_url(settings)


def test_production_requires_postgresql() -> None:
    settings = _settings("sqlite+pysqlite:///:memory:")

    with pytest.raises(RuntimeError, match="must use PostgreSQL"):
        validate_database_url(settings)


def test_production_accepts_verify_full() -> None:
    settings = _settings("postgresql+psycopg://user:pw@db.example.test/app?sslmode=verify-full")

    validate_database_url(settings)


def test_production_accepts_neon_style_channel_binding() -> None:
    settings = _settings(
        "postgresql+psycopg://user:pw@ep-example-pooler.eu-central-1.aws.neon.tech/app"
        "?sslmode=require&channel_binding=require"
    )

    validate_database_url(settings)


@pytest.mark.parametrize(
    "database_url",
    [
        "postgresql+psycopg://user:pw@db.example.test/app",
        "postgresql+psycopg://user:pw@db.example.test/app?sslmode=disable",
        "postgresql+psycopg://user:pw@db.example.test/app?sslmode=require",
    ],
)
def test_production_rejects_weak_database_transport(database_url: str) -> None:
    settings = _settings(database_url)

    with pytest.raises(RuntimeError, match="Production DATABASE_URL"):
        validate_database_url(settings)
