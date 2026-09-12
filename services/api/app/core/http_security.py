from starlette.types import ASGIApp, Message, Receive, Scope, Send

from app.core.config import Settings


def validate_runtime_security(settings: Settings) -> None:
    """Fail closed on unsafe production HTTP configuration."""
    if settings.environment.strip().lower() not in {"prod", "production"}:
        return

    if "*" in settings.cors_origin_list:
        raise RuntimeError("Production CORS_ORIGINS must not contain '*'")

    if "*" in settings.trusted_host_list:
        raise RuntimeError("Production TRUSTED_HOSTS must be explicit")


class SecurityHeadersMiddleware:
    """Add conservative browser-facing headers without inspecting request data."""

    def __init__(self, app: ASGIApp, enabled: bool = True) -> None:
        self.app = app
        self.enabled = enabled

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] != "http" or not self.enabled:
            await self.app(scope, receive, send)
            return

        async def send_wrapper(message: Message) -> None:
            if message["type"] == "http.response.start":
                headers = list(message.get("headers", []))
                existing = {key.lower() for key, _ in headers}

                additions = {
                    b"cache-control": b"no-store",
                    b"x-content-type-options": b"nosniff",
                    b"x-frame-options": b"DENY",
                    b"referrer-policy": b"no-referrer",
                    b"permissions-policy": b"camera=(), microphone=(), geolocation=()",
                    b"cross-origin-resource-policy": b"same-site",
                }
                for key, value in additions.items():
                    if key not in existing:
                        headers.append((key, value))

                message["headers"] = headers

            await send(message)

        await self.app(scope, receive, send_wrapper)
