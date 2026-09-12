import pytest
from fastapi import HTTPException

from app.core.rate_limit import InMemoryRateLimiter, enforce_rate_limit


def test_limiter_blocks_then_recovers_after_window() -> None:
    now = [100.0]
    limiter = InMemoryRateLimiter(clock=lambda: now[0])

    limiter.check(
        scope="test",
        subject="user-1",
        max_requests=2,
        window_seconds=60,
    )
    limiter.check(
        scope="test",
        subject="user-1",
        max_requests=2,
        window_seconds=60,
    )

    with pytest.raises(HTTPException) as error:
        limiter.check(
            scope="test",
            subject="user-1",
            max_requests=2,
            window_seconds=60,
        )

    assert error.value.status_code == 429
    assert error.value.headers == {"Retry-After": "60"}

    now[0] = 160.0

    limiter.check(
        scope="test",
        subject="user-1",
        max_requests=2,
        window_seconds=60,
    )


def test_disabled_rate_limit_does_not_consume_a_bucket() -> None:
    enforce_rate_limit(
        enabled=False,
        scope="test",
        subject="user-1",
        max_requests=1,
        window_seconds=60,
    )
