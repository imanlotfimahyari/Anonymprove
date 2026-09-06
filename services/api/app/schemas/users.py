from uuid import UUID

from app.schemas.common import ApiModel


class SessionResponse(ApiModel):
    session_token: str
    user_id: UUID
    alias: str


class ProfileResponse(ApiModel):
    user_id: UUID
    alias: str
