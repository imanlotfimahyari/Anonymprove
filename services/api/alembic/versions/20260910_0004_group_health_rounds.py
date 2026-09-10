"""Add group-health round semantics and built-in questionnaire.

Revision ID: 20260910_0004
Revises: 20260907_0003
Create Date: 2026-09-10
"""

from collections.abc import Sequence
from uuid import UUID

import sqlalchemy as sa

from alembic import op

revision: str = "20260910_0004"
down_revision: str | None = "20260907_0003"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


GROUP_HEALTH_QUESTIONNAIRE_ID = UUID("f0c4aac5-9c32-4331-a701-606d3fe94b6d")

GROUP_HEALTH_QUESTIONS = (
    (
        UUID("510b27e9-8ff8-48ec-81ad-abc60374e026"),
        "communication",
        "People in this group communicate important things clearly and honestly.",
        "scale",
        1,
        True,
        1,
        5,
    ),
    (
        UUID("b3d75e30-e172-4d30-bcee-737ac793722d"),
        "listening",
        "People listen to each other and different views can be expressed.",
        "scale",
        2,
        True,
        1,
        5,
    ),
    (
        UUID("4910f797-7bd8-4b81-b242-0a336b38606b"),
        "safety",
        "People can disagree without ridicule, threats, or retaliation.",
        "scale",
        3,
        True,
        1,
        5,
    ),
    (
        UUID("a2d8d3c2-baf4-4096-bdf6-1c1166f9efb9"),
        "reliability",
        "People generally follow through on commitments to the group.",
        "scale",
        4,
        True,
        1,
        5,
    ),
    (
        UUID("25c69b61-d4e8-45a7-b62f-d942c6b76043"),
        "support",
        "People help each other when support is reasonably needed.",
        "scale",
        5,
        True,
        1,
        5,
    ),
    (
        UUID("d5124215-8dc3-44fd-a175-aab5868495ca"),
        "conflict",
        "Problems and disagreements are handled constructively.",
        "scale",
        6,
        True,
        1,
        5,
    ),
    (
        UUID("5fa31a08-46e6-4dd1-a55f-23ab38d88f16"),
        "boundaries",
        "Personal boundaries and differences are respected.",
        "scale",
        7,
        True,
        1,
        5,
    ),
    (
        UUID("1780f421-e610-4eb9-aada-62a822fe6b9c"),
        "improvement",
        "What is one thing this group could improve? Avoid names or identifying details.",
        "text",
        8,
        False,
        None,
        None,
    ),
)


def upgrade() -> None:
    op.add_column(
        "feedback_rounds",
        sa.Column(
            "round_type",
            sa.String(length=24),
            nullable=False,
            server_default=sa.text("'individual_feedback'"),
        ),
    )

    op.add_column(
        "feedback_rounds",
        sa.Column(
            "created_by_user_id",
            sa.Uuid(),
            nullable=True,
        ),
    )

    # All pre-M6 rounds were created by their subject.
    op.execute("UPDATE feedback_rounds SET created_by_user_id = subject_user_id")

    op.alter_column(
        "feedback_rounds",
        "created_by_user_id",
        existing_type=sa.Uuid(),
        nullable=False,
    )

    op.create_foreign_key(
        "fk_feedback_rounds_created_by_user_id_users",
        "feedback_rounds",
        "users",
        ["created_by_user_id"],
        ["id"],
        ondelete="CASCADE",
    )

    op.create_index(
        "ix_feedback_rounds_created_by_user_id",
        "feedback_rounds",
        ["created_by_user_id"],
        unique=False,
    )

    op.alter_column(
        "feedback_rounds",
        "subject_user_id",
        existing_type=sa.Uuid(),
        nullable=True,
    )

    op.create_check_constraint(
        "ck_feedback_rounds_round_type",
        "feedback_rounds",
        "round_type IN ('individual_feedback', 'group_health')",
    )

    op.create_check_constraint(
        "ck_feedback_rounds_subject_semantics",
        "feedback_rounds",
        "("
        "round_type = 'individual_feedback' AND subject_user_id IS NOT NULL"
        ") OR ("
        "round_type = 'group_health' AND subject_user_id IS NULL"
        ")",
    )

    questionnaires = sa.table(
        "questionnaires",
        sa.column("id", sa.Uuid()),
        sa.column("group_id", sa.Uuid()),
        sa.column("created_by_user_id", sa.Uuid()),
        sa.column("slug", sa.String()),
        sa.column("name", sa.String()),
        sa.column("description", sa.Text()),
        sa.column("version", sa.Integer()),
        sa.column("status", sa.String()),
    )

    op.bulk_insert(
        questionnaires,
        [
            {
                "id": GROUP_HEALTH_QUESTIONNAIRE_ID,
                "group_id": None,
                "created_by_user_id": None,
                "slug": "core-group-health-v1",
                "name": "Core group health",
                "description": ("Built-in anonymous questionnaire for assessing group dynamics."),
                "version": 1,
                "status": "published",
            }
        ],
    )

    questions = sa.table(
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
        questions,
        [
            {
                "id": question_id,
                "questionnaire_id": GROUP_HEALTH_QUESTIONNAIRE_ID,
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
            ) in GROUP_HEALTH_QUESTIONS
        ],
    )


def downgrade() -> None:
    op.execute("DELETE FROM feedback_rounds WHERE round_type = 'group_health'")

    feedback_rounds = sa.table(
        "feedback_rounds",
        sa.column("questionnaire_id", sa.Uuid()),
    )

    questionnaires = sa.table(
        "questionnaires",
        sa.column("id", sa.Uuid()),
    )

    op.execute(
        feedback_rounds.delete().where(
            feedback_rounds.c.questionnaire_id == GROUP_HEALTH_QUESTIONNAIRE_ID
        )
    )

    op.execute(questionnaires.delete().where(questionnaires.c.id == GROUP_HEALTH_QUESTIONNAIRE_ID))
    op.drop_constraint(
        "ck_feedback_rounds_subject_semantics",
        "feedback_rounds",
        type_="check",
    )

    op.drop_constraint(
        "ck_feedback_rounds_round_type",
        "feedback_rounds",
        type_="check",
    )

    op.alter_column(
        "feedback_rounds",
        "subject_user_id",
        existing_type=sa.Uuid(),
        nullable=False,
    )

    op.drop_index(
        "ix_feedback_rounds_created_by_user_id",
        table_name="feedback_rounds",
    )

    op.drop_constraint(
        "fk_feedback_rounds_created_by_user_id_users",
        "feedback_rounds",
        type_="foreignkey",
    )

    op.drop_column(
        "feedback_rounds",
        "created_by_user_id",
    )

    op.drop_column(
        "feedback_rounds",
        "round_type",
    )
