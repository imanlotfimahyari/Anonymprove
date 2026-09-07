from datetime import datetime
from uuid import UUID

from pydantic import Field

from app.schemas.common import ApiModel


class QuestionSummary(ApiModel):
    id: UUID
    key: str
    prompt: str
    kind: str
    position: int
    required: bool
    min_score: int | None
    max_score: int | None


class QuestionnaireSummary(ApiModel):
    id: UUID
    slug: str
    name: str
    version: int
    questions: list[QuestionSummary]


class CreateFeedbackRoundRequest(ApiModel):
    questionnaire_slug: str = Field(default="core-feedback-v1", min_length=2, max_length=64)
    min_responses: int = Field(default=3, ge=3, le=10)


class FeedbackRoundSummary(ApiModel):
    id: UUID
    group_id: UUID
    subject_user_id: UUID
    questionnaire_slug: str
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
    score: int | None = Field(default=None, ge=1, le=5)
    text: str | None = Field(default=None, max_length=500)


class SubmitFeedbackRequest(ApiModel):
    answers: list[AnswerSubmission] = Field(min_length=1, max_length=20)


class ScaleQuestionResult(ApiModel):
    question_id: UUID
    key: str
    prompt: str
    average: float
    distribution: dict[str, int]


class TextQuestionResult(ApiModel):
    question_id: UUID
    key: str
    prompt: str
    comments: list[str]


class FeedbackResults(ApiModel):
    round_id: UUID
    response_count: int
    scale_results: list[ScaleQuestionResult]
    text_results: list[TextQuestionResult]
