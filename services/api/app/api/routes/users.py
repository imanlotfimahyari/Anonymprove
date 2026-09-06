from uuid import uuid4

from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user
from app.core.config import Settings, get_settings
from app.core.security import create_access_token
from app.db.session import get_db
from app.models.identity import User
from app.schemas.users import ProfileResponse, SessionResponse

router = APIRouter(prefix="/api/v1/users", tags=["users"])


@router.post("/session", response_model=SessionResponse, status_code=status.HTTP_201_CREATED)
def create_session(
    db: Session = Depends(get_db),
    settings: Settings = Depends(get_settings),
) -> SessionResponse:
    user_id = uuid4()
    user = User(id=user_id, alias=f"User-{str(user_id)[:8]}")
    db.add(user)
    db.commit()
    db.refresh(user)

    return SessionResponse(
        session_token=create_access_token(user.id, settings),
        user_id=user.id,
        alias=user.alias,
    )


@router.get("/me", response_model=ProfileResponse)
def get_me(user: User = Depends(get_current_user)) -> ProfileResponse:
    return ProfileResponse(user_id=user.id, alias=user.alias)
