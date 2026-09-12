from sqlalchemy.engine import make_url

from app.core.config import Settings


def validate_database_url(settings: Settings) -> None:
    """Fail closed on unsafe production database transport configuration."""
    if settings.environment.strip().lower() not in {"prod", "production"}:
        return

    url = make_url(settings.database_url)

    if not url.drivername.startswith("postgresql"):
        raise RuntimeError("Production DATABASE_URL must use PostgreSQL")

    sslmode = url.query.get("sslmode")
    channel_binding = url.query.get("channel_binding")

    if sslmode in {"verify-ca", "verify-full"}:
        return

    if sslmode == "require" and channel_binding == "require":
        return

    raise RuntimeError(
        "Production DATABASE_URL must use sslmode=verify-full/verify-ca "
        "or sslmode=require with channel_binding=require"
    )
