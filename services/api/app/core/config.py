from functools import lru_cache

from pydantic import Field, SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    environment: str = "local"
    jwt_secret: SecretStr
    jwt_ttl_minutes: int = Field(default=60, ge=5, le=1440)
    jwt_algorithm: str = "HS256"
    database_url: str
    cors_origins: str = "http://127.0.0.1:8080,http://localhost:8080"
    rate_limit_enabled: bool = True
    rate_limit_window_seconds: int = Field(default=60, ge=1, le=3600)
    rate_limit_join_max_requests: int = Field(default=10, ge=1)
    rate_limit_group_create_max_requests: int = Field(default=5, ge=1)
    rate_limit_round_create_max_requests: int = Field(default=10, ge=1)
    rate_limit_credential_claim_max_requests: int = Field(default=5, ge=1)
    request_logging_enabled: bool = True
    credential_metadata_retention_days: int = Field(default=30, ge=1, le=365)

    @property
    def cors_origin_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()
