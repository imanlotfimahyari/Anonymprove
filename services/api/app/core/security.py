from datetime import UTC, datetime, timedelta
from uuid import UUID

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, ValidationError

from app.core.config import Settings, get_settings

bearer = HTTPBearer(auto_error=False)


class Principal(BaseModel):
    user_id: UUID
    group_id: UUID


def create_access_token(principal: Principal, settings: Settings) -> str:
    now = datetime.now(UTC)
    payload = {
        "sub": str(principal.user_id),
        "groupId": str(principal.group_id),
        "iat": now,
        "exp": now + timedelta(minutes=settings.jwt_ttl_minutes),
    }
    return jwt.encode(
        payload,
        settings.jwt_secret.get_secret_value(),
        algorithm=settings.jwt_algorithm,
    )


def _unauthorized(detail: str) -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail=detail,
        headers={"WWW-Authenticate": "Bearer"},
    )


def get_current_principal(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer),
    settings: Settings = Depends(get_settings),
) -> Principal:
    if credentials is None:
        raise _unauthorized("Missing bearer token")

    try:
        payload = jwt.decode(
            credentials.credentials,
            settings.jwt_secret.get_secret_value(),
            algorithms=[settings.jwt_algorithm],
        )
        return Principal(user_id=payload["sub"], group_id=payload["groupId"])
    except jwt.ExpiredSignatureError as exc:
        raise _unauthorized("Session expired") from exc
    except (jwt.InvalidTokenError, KeyError, ValidationError) as exc:
        raise _unauthorized("Invalid token") from exc
