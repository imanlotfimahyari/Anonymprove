from typing import Literal

from pydantic import Field, field_validator, model_validator

from app.schemas.common import ApiModel

QuestionKind = Literal[
    "scale",
    "single_choice",
    "multiple_choice",
    "short_text",
    "long_text",
    "description",
]


class QuestionnaireQuestionInput(ApiModel):
    prompt: str = Field(min_length=1, max_length=500)
    kind: QuestionKind
    required: bool = True
    min_score: int | None = Field(default=None, ge=1, le=10)
    max_score: int | None = Field(default=None, ge=1, le=10)
    options: list[str] = Field(default_factory=list, max_length=20)

    @field_validator("prompt")
    @classmethod
    def normalize_prompt(cls, value: str) -> str:
        normalized = " ".join(value.split())
        if not normalized:
            raise ValueError("Question prompt cannot be blank")
        return normalized

    @field_validator("options")
    @classmethod
    def normalize_options(cls, values: list[str]) -> list[str]:
        normalized = [" ".join(value.split()) for value in values]
        if any(not value for value in normalized):
            raise ValueError("Choice labels cannot be blank")
        if len(set(normalized)) != len(normalized):
            raise ValueError("Choice labels must be unique")
        if any(len(value) > 160 for value in normalized):
            raise ValueError("Choice labels must be 160 characters or fewer")
        return normalized

    @model_validator(mode="after")
    def validate_kind_configuration(self) -> "QuestionnaireQuestionInput":
        if self.kind == "scale":
            self.min_score = 1 if self.min_score is None else self.min_score
            self.max_score = 5 if self.max_score is None else self.max_score
            if self.min_score >= self.max_score:
                raise ValueError("Scale minimum must be lower than maximum")
            if self.options:
                raise ValueError("Scale questions cannot define choice options")
            return self

        if self.kind in {"single_choice", "multiple_choice"}:
            if self.min_score is not None or self.max_score is not None:
                raise ValueError("Choice questions cannot define a score range")
            if len(self.options) < 2:
                raise ValueError("Choice questions require at least two options")
            return self

        if self.min_score is not None or self.max_score is not None or self.options:
            raise ValueError("Text and description blocks cannot define scores or options")
        if self.kind == "description":
            self.required = False
        return self


class QuestionnaireUpsertRequest(ApiModel):
    name: str = Field(min_length=2, max_length=120)
    description: str | None = Field(default=None, max_length=1000)
    questions: list[QuestionnaireQuestionInput] = Field(min_length=1, max_length=30)

    @field_validator("name")
    @classmethod
    def normalize_name(cls, value: str) -> str:
        normalized = " ".join(value.split())
        if len(normalized) < 2:
            raise ValueError("Questionnaire name must contain at least 2 characters")
        return normalized

    @field_validator("description")
    @classmethod
    def normalize_description(cls, value: str | None) -> str | None:
        if value is None:
            return None
        normalized = value.strip()
        return normalized or None
