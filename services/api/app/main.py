from fastapi import FastAPI

from app.api.routes import groups, health, users


def create_app() -> FastAPI:
    application = FastAPI(
        title="Privacy Feedback API",
        version="0.2.0",
        description="Backend foundation for voluntary, privacy-preserving feedback.",
    )
    application.include_router(health.router)
    application.include_router(users.router)
    application.include_router(groups.router)
    return application


app = create_app()
