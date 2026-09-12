from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.trustedhost import TrustedHostMiddleware

from app.api.routes import feedback, groups, health, questionnaires, users
from app.core.config import get_settings
from app.core.http_security import SecurityHeadersMiddleware, validate_runtime_security
from app.core.request_logging import (
    SafeRequestLoggingMiddleware,
    configure_privacy_logging,
)


def create_app(settings=None) -> FastAPI:
    settings = settings or get_settings()
    validate_runtime_security(settings)
    configure_privacy_logging()
    production = settings.environment.strip().lower() in {"prod", "production"}
    application = FastAPI(
        title="Privacy Feedback API",
        version="0.7.0",
        description="Backend for voluntary, privacy-preserving constructive feedback.",
        docs_url=None if production else "/docs",
        redoc_url=None if production else "/redoc",
        openapi_url=None if production else "/openapi.json",
    )
    application.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origin_list,
        allow_credentials=False,
        allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        allow_headers=["Authorization", "Content-Type", "X-Response-Token"],
        expose_headers=["Retry-After"],
    )
    application.add_middleware(
        TrustedHostMiddleware,
        allowed_hosts=settings.trusted_host_list,
    )
    application.add_middleware(
        SafeRequestLoggingMiddleware,
        enabled=settings.request_logging_enabled,
    )
    application.add_middleware(
        SecurityHeadersMiddleware,
        enabled=settings.security_headers_enabled,
    )
    application.include_router(health.router)
    application.include_router(users.router)
    application.include_router(groups.router)
    application.include_router(questionnaires.router)
    application.include_router(feedback.router)
    return application


app = create_app()
