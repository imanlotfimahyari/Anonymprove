from collections.abc import Generator
from functools import lru_cache

from sqlalchemy import Engine, create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.config import get_settings
from app.core.database_security import validate_database_url


@lru_cache
def get_engine() -> Engine:
    settings = get_settings()
    validate_database_url(settings)
    database_url = settings.database_url
    kwargs: dict[str, object] = {"pool_pre_ping": True}

    if database_url == "sqlite+pysqlite:///:memory:":
        kwargs.update(
            connect_args={"check_same_thread": False},
            poolclass=StaticPool,
        )
    else:
        kwargs["pool_recycle"] = settings.database_pool_recycle_seconds

    return create_engine(database_url, **kwargs)


@lru_cache
def get_session_factory() -> sessionmaker[Session]:
    return sessionmaker(bind=get_engine(), expire_on_commit=False)


def get_db() -> Generator[Session, None, None]:
    with get_session_factory()() as session:
        yield session
