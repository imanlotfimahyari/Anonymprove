from fastapi import FastAPI

from app.api.routes import feedback, groups, health, users


def create_app() -> FastAPI:
    application = FastAPI(
        title="Privacy Feedback API",
        version="0.3.0",
        description="Backend for voluntary, privacy-preserving constructive feedback.",
    )
    application.include_router(health.router)
    application.include_router(users.router)
    application.include_router(groups.router)
    application.include_router(feedback.router)
    return application


app = create_app()
