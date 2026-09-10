from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import Field, model_validator

from app.schemas.common import ApiModel


class QuestionOptionSummary(ApiModel):
    id: UUID
    label: str
    position: int


class QuestionSummary(ApiModel):
    id: UUID
    key: str
    prompt: str
    kind: str
    position: int
    required: bool
    min_score: int | None
    max_score: int | None
    options: list[QuestionOptionSummary] = Field(default_factory=list)


class QuestionnaireSummary(ApiModel):
    id: UUID
    group_id: UUID | None
    created_by_user_id: UUID | None
    slug: str
    name: str
    description: str | None
    version: int
    status: str
    questions: list[QuestionSummary]


class CreateFeedbackRoundRequest(ApiModel):
    questionnaire_slug: str | None = Field(
        default=None,
        min_length=2,
        max_length=64,
    )
    questionnaire_id: UUID | None = None
    round_type: Literal["individual_feedback", "group_health"] = "individual_feedback"
    min_responses: int = Field(default=3, ge=3, le=10)

    @model_validator(mode="after")
    def only_one_questionnaire_selector(
        self,
    ) -> "CreateFeedbackRoundRequest":
        if self.questionnaire_slug is not None and self.questionnaire_id is not None:
            raise ValueError("Choose questionnaireSlug or questionnaireId, not both")
        return self


class FeedbackRoundSummary(ApiModel):
    id: UUID
    group_id: UUID
    subject_user_id: UUID | None
    created_by_user_id: UUID
    questionnaire_id: UUID
    questionnaire_slug: str
    round_type: Literal["individual_feedback", "group_health"]
    status: str
    min_responses: int
    created_at: datetime
    opened_at: datetime | None
    closed_at: datetime | None


class FeedbackRoundDetail(FeedbackRoundSummary):
    questions: list[QuestionSummary]


class ResponseCredentialResponse(ApiModel):
    response_token: str


class AnswerSubmission(ApiModel):
    question_id: UUID
    score: int | None = Field(default=None, ge=1, le=10)
    text: str | None = Field(default=None, max_length=1000)
    option_ids: list[UUID] | None = Field(default=None, max_length=20)


class SubmitFeedbackRequest(ApiModel):
    answers: list[AnswerSubmission] = Field(min_length=1, max_length=30)


class ScaleQuestionResult(ApiModel):
    question_id: UUID
    key: str
    prompt: str
    average: float | None
    distribution: dict[str, int]


class TextQuestionResult(ApiModel):
    question_id: UUID
    key: str
    prompt: str
    comments: list[str]


class ChoiceOptionResult(ApiModel):
    option_id: UUID
    label: str
    count: int


class ChoiceQuestionResult(ApiModel):
    question_id: UUID
    key: str
    prompt: str
    kind: str
    options: list[ChoiceOptionResult]


class FeedbackResults(ApiModel):
    round_id: UUID
    response_count: int
    scale_results: list[ScaleQuestionResult]
    text_results: list[TextQuestionResult]
    choice_results: list[ChoiceQuestionResult] = Field(default_factory=list)
