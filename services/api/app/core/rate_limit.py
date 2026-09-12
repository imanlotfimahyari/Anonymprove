from collections.abc import Callable
from dataclasses import dataclass
from math import ceil
from threading import Lock
from time import monotonic

from fastapi import HTTPException, status


@dataclass(slots=True)
class _Bucket:
    started_at: float
    requests: int
    max_requests: int
    window_seconds: int


class InMemoryRateLimiter:
    """Process-local abuse-control baseline.

    Keys use authenticated application identifiers only. This limiter does not
    collect or store client IP addresses, join codes, bearer tokens, or response
    credentials. Multi-process/edge enforcement remains a production concern.
    """

    def __init__(self, clock: Callable[[], float] = monotonic) -> None:
        self._clock = clock
        self._lock = Lock()
        self._buckets: dict[tuple[str, str], _Bucket] = {}

    def reset(self) -> None:
        with self._lock:
            self._buckets.clear()

    def check(
        self,
        *,
        scope: str,
        subject: str,
        max_requests: int,
        window_seconds: int,
    ) -> None:
        if max_requests < 1:
            raise ValueError("max_requests must be positive")
        if window_seconds < 1:
            raise ValueError("window_seconds must be positive")

        now = self._clock()
        key = (scope, subject)

        with self._lock:
            expired = [
                bucket_key
                for bucket_key, bucket in self._buckets.items()
                if now >= bucket.started_at + bucket.window_seconds
            ]
            for bucket_key in expired:
                self._buckets.pop(bucket_key, None)

            bucket = self._buckets.get(key)
            if (
                bucket is None
                or bucket.max_requests != max_requests
                or bucket.window_seconds != window_seconds
            ):
                self._buckets[key] = _Bucket(
                    started_at=now,
                    requests=1,
                    max_requests=max_requests,
                    window_seconds=window_seconds,
                )
                return

            if bucket.requests >= max_requests:
                retry_after = max(
                    1,
                    ceil(bucket.started_at + bucket.window_seconds - now),
                )
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail="Too many requests",
                    headers={"Retry-After": str(retry_after)},
                )

            bucket.requests += 1


rate_limiter = InMemoryRateLimiter()


def enforce_rate_limit(
    *,
    enabled: bool,
    scope: str,
    subject: str,
    max_requests: int,
    window_seconds: int,
) -> None:
    if not enabled:
        return

    rate_limiter.check(
        scope=scope,
        subject=subject,
        max_requests=max_requests,
        window_seconds=window_seconds,
    )
