import os

import pytest
from fastapi.testclient import TestClient

os.environ.setdefault("JWT_SECRET", "test-only-secret-not-for-production-0123456789")
os.environ.setdefault("DATABASE_URL", "sqlite+pysqlite:///:memory:")

from app.db.base import Base  # noqa: E402
from app.db.session import get_engine  # noqa: E402
from app.main import app  # noqa: E402
from app.models import identity  # noqa: E402,F401


@pytest.fixture(autouse=True)
def reset_database() -> None:
    engine = get_engine()
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)


@pytest.fixture
def client() -> TestClient:
    return TestClient(app)
