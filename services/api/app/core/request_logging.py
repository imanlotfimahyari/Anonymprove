import logging
from time import monotonic

from starlette.types import ASGIApp, Message, Receive, Scope, Send

REQUEST_LOGGER_NAME = "privacy_feedback.request"

# These routes sit directly on the anonymity boundary. Even metadata-only
# per-request logs would create an avoidable timing-correlation side channel.
_SUPPRESSED_ROUTE_PATHS = {
    "/api/v1/feedback-rounds/{round_id}/credentials",
    "/api/v1/feedback-rounds/{round_id}/responses",
}

logger = logging.getLogger(REQUEST_LOGGER_NAME)


def configure_privacy_logging() -> None:
    """Configure the application-owned privacy logging policy."""
    logger.setLevel(logging.INFO)

    # Uvicorn's default access log contains client address and raw request path.
    # Disable it so privacy-sensitive endpoints are not reintroduced through
    # infrastructure-style request logs inside this process.
    logging.getLogger("uvicorn.access").disabled = True


class SafeRequestLoggingMiddleware:
    """Log only low-sensitivity request metadata.

    The middleware never logs headers, query strings, request/response bodies,
    client addresses, authenticated user IDs, join codes, bearer tokens, or
    response credentials.
    """

    def __init__(self, app: ASGIApp, enabled: bool = True) -> None:
        self.app = app
        self.enabled = enabled

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http" or not self.enabled:
            await self.app(scope, receive, send)
            return

        started_at = monotonic()
        status_code = 500

        async def send_wrapper(message: Message) -> None:
            nonlocal status_code
            if message["type"] == "http.response.start":
                status_code = int(message["status"])
            await send(message)

        try:
            await self.app(scope, receive, send_wrapper)
        finally:
            route = scope.get("route")
            route_path = getattr(route, "path", "<unmatched>")

            if route_path not in _SUPPRESSED_ROUTE_PATHS:
                duration_ms = max(0, round((monotonic() - started_at) * 1000))
                logger.info(
                    "request method=%s route=%s status=%d duration_ms=%d",
                    scope.get("method", "UNKNOWN"),
                    route_path,
                    status_code,
                    duration_ms,
                )
