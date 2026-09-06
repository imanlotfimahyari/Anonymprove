from uuid import UUID

from pydantic import BaseModel, ConfigDict
from pydantic.alias_generators import to_camel


class ApiModel(BaseModel):
    model_config = ConfigDict(alias_generator=to_camel, populate_by_name=True)


class SessionResponse(ApiModel):
    session_token: str
    alias: str
    group_id: UUID


class ProfileResponse(ApiModel):
    alias: str
    group_id: UUID
