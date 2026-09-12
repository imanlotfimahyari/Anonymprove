import os

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

os.environ.setdefault("JWT_SECRET", "test-only-secret-not-for-production-0123456789")
os.environ.setdefault("DATABASE_URL", "sqlite+pysqlite:///:memory:")

from app.core.rate_limit import rate_limiter  # noqa: E402
from app.db.base import Base  # noqa: E402
from app.db.seeds import (  # noqa: E402
    seed_core_group_health_questionnaire,
    seed_core_questionnaire,
)
from app.db.session import get_engine, get_session_factory  # noqa: E402
from app.main import app  # noqa: E402
from app.models import feedback, identity  # noqa: E402,F401


@pytest.fixture(autouse=True)
def reset_database() -> None:
    rate_limiter.reset()
    engine = get_engine()
    Base.metadata.drop_all(engine)
    Base.metadata.create_all(engine)
    with get_session_factory()() as db:
        seed_core_questionnaire(db)
        seed_core_group_health_questionnaire(db)
        db.commit()


@pytest.fixture
def db() -> Session:
    with get_session_factory()() as session:
        yield session


@pytest.fixture
def client() -> TestClient:
    return TestClient(app)
