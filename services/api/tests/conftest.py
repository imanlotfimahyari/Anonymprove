import os

import pytest
from fastapi.testclient import TestClient

os.environ.setdefault("JWT_SECRET", "test-only-secret-not-for-production-0123456789")

from app.main import app  # noqa: E402


@pytest.fixture
def client() -> TestClient:
    return TestClient(app)
