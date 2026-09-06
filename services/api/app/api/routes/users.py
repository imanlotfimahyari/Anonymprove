from dataclasses import dataclass
from uuid import UUID, uuid4

from fastapi import APIRouter, Depends, HTTPException, status

from app.core.config import Settings, get_settings
from app.core.security import Principal, create_access_token, get_current_principal
from app.schemas.users import ProfileResponse, SessionResponse

router = APIRouter(prefix="/api/v1/users", tags=["users"])


@dataclass(frozen=True, slots=True)
class SessionState:
    alias: str
    group_id: UUID


# M0 only. Persistent identity/group storage is introduced in M1.
_sessions: dict[UUID, SessionState] = {}


@router.post("/session", response_model=SessionResponse, status_code=status.HTTP_201_CREATED)
def create_session(settings: Settings = Depends(get_settings)) -> SessionResponse:
    user_id = uuid4()
    group_id = uuid4()
    alias = f"User-{str(user_id)[:8]}"

    principal = Principal(user_id=user_id, group_id=group_id)
    _sessions[user_id] = SessionState(alias=alias, group_id=group_id)

    return SessionResponse(
        session_token=create_access_token(principal, settings),
        alias=alias,
        group_id=group_id,
    )


@router.get("/me", response_model=ProfileResponse)
def get_me(principal: Principal = Depends(get_current_principal)) -> ProfileResponse:
    state = _sessions.get(principal.user_id)
    if state is None or state.group_id != principal.group_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Session not found",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return ProfileResponse(alias=state.alias, group_id=state.group_id)
