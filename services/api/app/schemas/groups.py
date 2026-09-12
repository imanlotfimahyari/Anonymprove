from datetime import datetime
from uuid import UUID

from pydantic import Field, field_validator

from app.schemas.common import ApiModel


class CreateGroupRequest(ApiModel):
    name: str = Field(min_length=2, max_length=80)

    @field_validator("name")
    @classmethod
    def normalize_name(cls, value: str) -> str:
        normalized = " ".join(value.split())
        if len(normalized) < 2:
            raise ValueError("Group name must contain at least 2 non-whitespace characters")
        return normalized


class JoinGroupRequest(ApiModel):
    join_code: str = Field(min_length=8, max_length=64)


class GroupSummary(ApiModel):
    id: UUID
    name: str
    role: str
    created_at: datetime


class GroupCreatedResponse(GroupSummary):
    join_code: str


class GroupJoinCodeResponse(ApiModel):
    join_code: str
