from datetime import datetime
from uuid import UUID, uuid4

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    DateTime,
    ForeignKey,
    Integer,
    SmallInteger,
    String,
    Text,
    UniqueConstraint,
    Uuid,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Questionnaire(Base):
    __tablename__ = "questionnaires"
    __table_args__ = (
        UniqueConstraint("slug", "version", name="uq_questionnaires_slug_version"),
        CheckConstraint("status IN ('draft', 'published')", name="ck_questionnaires_status"),
    )

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    group_id: Mapped[UUID | None] = mapped_column(
        ForeignKey("groups.id", ondelete="CASCADE"), nullable=True, index=True
    )
    created_by_user_id: Mapped[UUID | None] = mapped_column(
        ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True
    )
    slug: Mapped[str] = mapped_column(String(64), nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    version: Mapped[int] = mapped_column(Integer, nullable=False)
    status: Mapped[str] = mapped_column(String(16), nullable=False, default="published")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )


class Question(Base):
    __tablename__ = "questions"
    __table_args__ = (
        UniqueConstraint("questionnaire_id", "key", name="uq_questions_questionnaire_key"),
        UniqueConstraint(
            "questionnaire_id", "position", name="uq_questions_questionnaire_position"
        ),
        CheckConstraint(
            "kind IN ('scale', 'text', 'single_choice', 'multiple_choice', "
            "'short_text', 'long_text', 'description')",
            name="ck_questions_kind",
        ),
    )

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    questionnaire_id: Mapped[UUID] = mapped_column(
        ForeignKey("questionnaires.id", ondelete="CASCADE"), nullable=False, index=True
    )
    key: Mapped[str] = mapped_column(String(64), nullable=False)
    prompt: Mapped[str] = mapped_column(String(500), nullable=False)
    kind: Mapped[str] = mapped_column(String(24), nullable=False)
    position: Mapped[int] = mapped_column(Integer, nullable=False)
    required: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    min_score: Mapped[int | None] = mapped_column(SmallInteger, nullable=True)
    max_score: Mapped[int | None] = mapped_column(SmallInteger, nullable=True)


class QuestionOption(Base):
    __tablename__ = "question_options"
    __table_args__ = (
        UniqueConstraint("question_id", "position", name="uq_question_options_question_position"),
    )

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    question_id: Mapped[UUID] = mapped_column(
        ForeignKey("questions.id", ondelete="CASCADE"), nullable=False, index=True
    )
    label: Mapped[str] = mapped_column(String(160), nullable=False)
    position: Mapped[int] = mapped_column(Integer, nullable=False)


class FeedbackRound(Base):
    __tablename__ = "feedback_rounds"
    __table_args__ = (
        CheckConstraint(
            "status IN ('draft', 'open', 'closed')",
            name="ck_feedback_rounds_status",
        ),
        CheckConstraint(
            "min_responses >= 3 AND min_responses <= 10",
            name="ck_feedback_rounds_min_responses",
        ),
        CheckConstraint(
            "round_type IN ('individual_feedback', 'group_health')",
            name="ck_feedback_rounds_round_type",
        ),
        CheckConstraint(
            "("
            "round_type = 'individual_feedback' AND subject_user_id IS NOT NULL"
            ") OR ("
            "round_type = 'group_health' AND subject_user_id IS NULL"
            ")",
            name="ck_feedback_rounds_subject_semantics",
        ),
    )

    id: Mapped[UUID] = mapped_column(
        Uuid(as_uuid=True),
        primary_key=True,
        default=uuid4,
    )
    group_id: Mapped[UUID] = mapped_column(
        ForeignKey("groups.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    subject_user_id: Mapped[UUID | None] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=True,
        index=True,
    )
    created_by_user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    questionnaire_id: Mapped[UUID] = mapped_column(
        ForeignKey("questionnaires.id", ondelete="RESTRICT"),
        nullable=False,
        index=True,
    )
    round_type: Mapped[str] = mapped_column(
        String(24),
        nullable=False,
        default="individual_feedback",
    )
    status: Mapped[str] = mapped_column(
        String(16),
        nullable=False,
        default="draft",
    )
    min_responses: Mapped[int] = mapped_column(
        SmallInteger,
        nullable=False,
        default=3,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        nullable=False,
        server_default=func.now(),
    )
    opened_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )
    closed_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )


class CredentialClaim(Base):
    __tablename__ = "credential_claims"
    __table_args__ = (
        UniqueConstraint("round_id", "user_id", name="uq_credential_claims_round_user"),
    )

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    round_id: Mapped[UUID] = mapped_column(
        ForeignKey("feedback_rounds.id", ondelete="CASCADE"), nullable=False, index=True
    )
    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    claimed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )


class ResponseCredential(Base):
    __tablename__ = "response_credentials"

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    round_id: Mapped[UUID] = mapped_column(
        ForeignKey("feedback_rounds.id", ondelete="CASCADE"), nullable=False, index=True
    )
    token_hash: Mapped[str] = mapped_column(String(64), nullable=False, unique=True)
    used_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class AnonymousResponse(Base):
    __tablename__ = "anonymous_responses"

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    round_id: Mapped[UUID] = mapped_column(
        ForeignKey("feedback_rounds.id", ondelete="CASCADE"), nullable=False, index=True
    )
    submitted_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )


class Answer(Base):
    __tablename__ = "answers"
    __table_args__ = (
        UniqueConstraint("response_id", "question_id", name="uq_answers_response_question"),
        CheckConstraint(
            "NOT (score IS NOT NULL AND text_value IS NOT NULL)",
            name="ck_answers_at_most_one_scalar_value",
        ),
    )

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    response_id: Mapped[UUID] = mapped_column(
        ForeignKey("anonymous_responses.id", ondelete="CASCADE"), nullable=False, index=True
    )
    question_id: Mapped[UUID] = mapped_column(
        ForeignKey("questions.id", ondelete="RESTRICT"), nullable=False, index=True
    )
    score: Mapped[int | None] = mapped_column(SmallInteger, nullable=True)
    text_value: Mapped[str | None] = mapped_column(Text, nullable=True)


class AnswerChoiceOption(Base):
    __tablename__ = "answer_choice_options"

    answer_id: Mapped[UUID] = mapped_column(
        ForeignKey("answers.id", ondelete="CASCADE"), primary_key=True
    )
    option_id: Mapped[UUID] = mapped_column(
        ForeignKey("question_options.id", ondelete="RESTRICT"), primary_key=True, index=True
    )
