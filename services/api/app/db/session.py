from collections.abc import Generator
from functools import lru_cache

from sqlalchemy import Engine, create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.config import get_settings


@lru_cache
def get_engine() -> Engine:
    database_url = get_settings().database_url
    kwargs: dict[str, object] = {"pool_pre_ping": True}

    if database_url == "sqlite+pysqlite:///:memory:":
        kwargs.update(
            connect_args={"check_same_thread": False},
            poolclass=StaticPool,
        )

    return create_engine(database_url, **kwargs)


@lru_cache
def get_session_factory() -> sessionmaker[Session]:
    return sessionmaker(bind=get_engine(), expire_on_commit=False)


def get_db() -> Generator[Session, None, None]:
    with get_session_factory()() as session:
        yield session
