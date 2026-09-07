"""Add feedback rounds and anonymous response storage.

Revision ID: 20260907_0002
Revises: 20260906_0001
Create Date: 2026-09-07
"""

from collections.abc import Sequence
from uuid import UUID

import sqlalchemy as sa

from alembic import op

revision: str = "20260907_0002"
down_revision: str | None = "20260906_0001"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

CORE_QUESTIONNAIRE_ID = UUID("d81af293-59b8-461a-8b72-769909ba5a2e")
CORE_QUESTIONS = (
    (
        UUID("424f3385-8c31-46f8-806d-306e45d3aac2"),
        "communication",
        "Communicates clearly and honestly.",
        "scale",
        1,
        True,
        1,
        5,
    ),
    (
        UUID("b7e9cd8d-f5bf-416d-9744-9b9c9e27fefb"),
        "listening",
        "Listens carefully and makes others feel heard.",
        "scale",
        2,
        True,
        1,
        5,
    ),
    (
        UUID("73c96b3f-11ae-48e9-b59e-34f6de68e896"),
        "reliability",
        "Follows through on commitments and can be relied on.",
        "scale",
        3,
        True,
        1,
        5,
    ),
    (
        UUID("20a943bf-b4b1-4f77-b91a-7741df150277"),
        "empathy",
        "Shows empathy and considers other people's feelings.",
        "scale",
        4,
        True,
        1,
        5,
    ),
    (
        UUID("5c942383-d284-44a7-bc86-98d3415812dd"),
        "boundaries",
        "Respects personal boundaries and differences.",
        "scale",
        5,
        True,
        1,
        5,
    ),
    (
        UUID("e6226044-371a-447c-acdc-8cde5a7d17bd"),
        "conflict",
        "Handles disagreement without humiliation, threats, or unnecessary escalation.",
        "scale",
        6,
        True,
        1,
        5,
    ),
    (
        UUID("1ae392f1-33a9-47d1-848d-4a3f77c8af5c"),
        "supportiveness",
        "Is supportive without creating pressure, exclusion, or unhealthy dependence.",
        "scale",
        7,
        True,
        1,
        5,
    ),
    (
        UUID("80669c7b-8cbf-440c-8abf-ea613e23676b"),
        "improvement",
        "What is one thing I could do differently to improve our interactions? "
        "Avoid names or identifying details.",
        "text",
        8,
        False,
        None,
        None,
    ),
)


def upgrade() -> None:
    op.create_table(
        "questionnaires",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("slug", sa.String(length=64), nullable=False),
        sa.Column("name", sa.String(length=120), nullable=False),
        sa.Column("version", sa.Integer(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("slug", "version", name="uq_questionnaires_slug_version"),
    )
    op.create_index("ix_questionnaires_slug", "questionnaires", ["slug"], unique=False)

    op.create_table(
        "questions",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("questionnaire_id", sa.Uuid(), nullable=False),
        sa.Column("key", sa.String(length=64), nullable=False),
        sa.Column("prompt", sa.String(length=240), nullable=False),
        sa.Column("kind", sa.String(length=16), nullable=False),
        sa.Column("position", sa.Integer(), nullable=False),
        sa.Column("required", sa.Boolean(), nullable=False),
        sa.Column("min_score", sa.SmallInteger(), nullable=True),
        sa.Column("max_score", sa.SmallInteger(), nullable=True),
        sa.CheckConstraint("kind IN ('scale', 'text')", name="ck_questions_kind"),
        sa.ForeignKeyConstraint(["questionnaire_id"], ["questionnaires.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("questionnaire_id", "key", name="uq_questions_questionnaire_key"),
        sa.UniqueConstraint(
            "questionnaire_id", "position", name="uq_questions_questionnaire_position"
        ),
    )
    op.create_index(
        "ix_questions_questionnaire_id", "questions", ["questionnaire_id"], unique=False
    )

    op.create_table(
        "feedback_rounds",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("group_id", sa.Uuid(), nullable=False),
        sa.Column("subject_user_id", sa.Uuid(), nullable=False),
        sa.Column("questionnaire_id", sa.Uuid(), nullable=False),
        sa.Column("status", sa.String(length=16), nullable=False),
        sa.Column("min_responses", sa.SmallInteger(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.Column("opened_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("closed_at", sa.DateTime(timezone=True), nullable=True),
        sa.CheckConstraint(
            "status IN ('draft', 'open', 'closed')", name="ck_feedback_rounds_status"
        ),
        sa.CheckConstraint(
            "min_responses >= 3 AND min_responses <= 10",
            name="ck_feedback_rounds_min_responses",
        ),
        sa.ForeignKeyConstraint(["group_id"], ["groups.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["questionnaire_id"], ["questionnaires.id"], ondelete="RESTRICT"),
        sa.ForeignKeyConstraint(["subject_user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_feedback_rounds_group_id", "feedback_rounds", ["group_id"], unique=False)
    op.create_index(
        "ix_feedback_rounds_questionnaire_id",
        "feedback_rounds",
        ["questionnaire_id"],
        unique=False,
    )
    op.create_index(
        "ix_feedback_rounds_subject_user_id",
        "feedback_rounds",
        ["subject_user_id"],
        unique=False,
    )

    op.create_table(
        "credential_claims",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("round_id", sa.Uuid(), nullable=False),
        sa.Column("user_id", sa.Uuid(), nullable=False),
        sa.Column(
            "claimed_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["round_id"], ["feedback_rounds.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("round_id", "user_id", name="uq_credential_claims_round_user"),
    )
    op.create_index(
        "ix_credential_claims_round_id", "credential_claims", ["round_id"], unique=False
    )
    op.create_index("ix_credential_claims_user_id", "credential_claims", ["user_id"], unique=False)

    op.create_table(
        "response_credentials",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("round_id", sa.Uuid(), nullable=False),
        sa.Column("token_hash", sa.String(length=64), nullable=False),
        sa.Column("used_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["round_id"], ["feedback_rounds.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("token_hash"),
    )
    op.create_index(
        "ix_response_credentials_round_id", "response_credentials", ["round_id"], unique=False
    )

    op.create_table(
        "anonymous_responses",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("round_id", sa.Uuid(), nullable=False),
        sa.Column(
            "submitted_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["round_id"], ["feedback_rounds.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_anonymous_responses_round_id", "anonymous_responses", ["round_id"], unique=False
    )

    op.create_table(
        "answers",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("response_id", sa.Uuid(), nullable=False),
        sa.Column("question_id", sa.Uuid(), nullable=False),
        sa.Column("score", sa.SmallInteger(), nullable=True),
        sa.Column("text_value", sa.Text(), nullable=True),
        sa.CheckConstraint(
            "(score IS NOT NULL AND text_value IS NULL) OR "
            "(score IS NULL AND text_value IS NOT NULL)",
            name="ck_answers_exactly_one_value",
        ),
        sa.ForeignKeyConstraint(["question_id"], ["questions.id"], ondelete="RESTRICT"),
        sa.ForeignKeyConstraint(["response_id"], ["anonymous_responses.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("response_id", "question_id", name="uq_answers_response_question"),
    )
    op.create_index("ix_answers_question_id", "answers", ["question_id"], unique=False)
    op.create_index("ix_answers_response_id", "answers", ["response_id"], unique=False)

    questionnaire_table = sa.table(
        "questionnaires",
        sa.column("id", sa.Uuid()),
        sa.column("slug", sa.String()),
        sa.column("name", sa.String()),
        sa.column("version", sa.Integer()),
    )
    question_table = sa.table(
        "questions",
        sa.column("id", sa.Uuid()),
        sa.column("questionnaire_id", sa.Uuid()),
        sa.column("key", sa.String()),
        sa.column("prompt", sa.String()),
        sa.column("kind", sa.String()),
        sa.column("position", sa.Integer()),
        sa.column("required", sa.Boolean()),
        sa.column("min_score", sa.SmallInteger()),
        sa.column("max_score", sa.SmallInteger()),
    )

    op.bulk_insert(
        questionnaire_table,
        [
            {
                "id": CORE_QUESTIONNAIRE_ID,
                "slug": "core-feedback-v1",
                "name": "Core constructive feedback",
                "version": 1,
            }
        ],
    )
    op.bulk_insert(
        question_table,
        [
            {
                "id": question_id,
                "questionnaire_id": CORE_QUESTIONNAIRE_ID,
                "key": key,
                "prompt": prompt,
                "kind": kind,
                "position": position,
                "required": required,
                "min_score": min_score,
                "max_score": max_score,
            }
            for (
                question_id,
                key,
                prompt,
                kind,
                position,
                required,
                min_score,
                max_score,
            ) in CORE_QUESTIONS
        ],
    )


def downgrade() -> None:
    op.drop_index("ix_answers_response_id", table_name="answers")
    op.drop_index("ix_answers_question_id", table_name="answers")
    op.drop_table("answers")
    op.drop_index("ix_anonymous_responses_round_id", table_name="anonymous_responses")
    op.drop_table("anonymous_responses")
    op.drop_index("ix_response_credentials_round_id", table_name="response_credentials")
    op.drop_table("response_credentials")
    op.drop_index("ix_credential_claims_user_id", table_name="credential_claims")
    op.drop_index("ix_credential_claims_round_id", table_name="credential_claims")
    op.drop_table("credential_claims")
    op.drop_index("ix_feedback_rounds_subject_user_id", table_name="feedback_rounds")
    op.drop_index("ix_feedback_rounds_questionnaire_id", table_name="feedback_rounds")
    op.drop_index("ix_feedback_rounds_group_id", table_name="feedback_rounds")
    op.drop_table("feedback_rounds")
    op.drop_index("ix_questions_questionnaire_id", table_name="questions")
    op.drop_table("questions")
    op.drop_index("ix_questionnaires_slug", table_name="questionnaires")
    op.drop_table("questionnaires")
