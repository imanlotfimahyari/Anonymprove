"""Add custom questionnaires and mixed answer types.

Revision ID: 20260907_0003
Revises: 20260907_0002
Create Date: 2026-09-07
"""

from collections.abc import Sequence

import sqlalchemy as sa

from alembic import op

revision: str = "20260907_0003"
down_revision: str | None = "20260907_0002"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.add_column("questionnaires", sa.Column("group_id", sa.Uuid(), nullable=True))
    op.add_column("questionnaires", sa.Column("created_by_user_id", sa.Uuid(), nullable=True))
    op.add_column("questionnaires", sa.Column("description", sa.Text(), nullable=True))
    op.add_column(
        "questionnaires",
        sa.Column(
            "status",
            sa.String(length=16),
            nullable=False,
            server_default=sa.text("'published'"),
        ),
    )
    op.create_foreign_key(
        "fk_questionnaires_group_id_groups",
        "questionnaires",
        "groups",
        ["group_id"],
        ["id"],
        ondelete="CASCADE",
    )
    op.create_foreign_key(
        "fk_questionnaires_created_by_user_id_users",
        "questionnaires",
        "users",
        ["created_by_user_id"],
        ["id"],
        ondelete="SET NULL",
    )
    op.create_index("ix_questionnaires_group_id", "questionnaires", ["group_id"], unique=False)
    op.create_index(
        "ix_questionnaires_created_by_user_id",
        "questionnaires",
        ["created_by_user_id"],
        unique=False,
    )
    op.create_check_constraint(
        "ck_questionnaires_status",
        "questionnaires",
        "status IN ('draft', 'published')",
    )

    op.alter_column(
        "questions",
        "prompt",
        existing_type=sa.String(length=240),
        type_=sa.String(length=500),
        existing_nullable=False,
    )
    op.alter_column(
        "questions",
        "kind",
        existing_type=sa.String(length=16),
        type_=sa.String(length=24),
        existing_nullable=False,
    )
    op.drop_constraint("ck_questions_kind", "questions", type_="check")
    op.create_check_constraint(
        "ck_questions_kind",
        "questions",
        "kind IN ('scale', 'text', 'single_choice', 'multiple_choice', "
        "'short_text', 'long_text', 'description')",
    )

    op.create_table(
        "question_options",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("question_id", sa.Uuid(), nullable=False),
        sa.Column("label", sa.String(length=160), nullable=False),
        sa.Column("position", sa.Integer(), nullable=False),
        sa.ForeignKeyConstraint(["question_id"], ["questions.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "question_id", "position", name="uq_question_options_question_position"
        ),
    )
    op.create_index("ix_question_options_question_id", "question_options", ["question_id"])

    op.drop_constraint("ck_answers_exactly_one_value", "answers", type_="check")
    op.create_check_constraint(
        "ck_answers_at_most_one_scalar_value",
        "answers",
        "NOT (score IS NOT NULL AND text_value IS NOT NULL)",
    )
    op.create_table(
        "answer_choice_options",
        sa.Column("answer_id", sa.Uuid(), nullable=False),
        sa.Column("option_id", sa.Uuid(), nullable=False),
        sa.ForeignKeyConstraint(["answer_id"], ["answers.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["option_id"], ["question_options.id"], ondelete="RESTRICT"),
        sa.PrimaryKeyConstraint("answer_id", "option_id"),
    )
    op.create_index("ix_answer_choice_options_option_id", "answer_choice_options", ["option_id"])

    op.execute(
        "UPDATE questionnaires SET description = "
        "'Built-in constructive self-improvement feedback questionnaire.' "
        "WHERE slug = 'core-feedback-v1' AND version = 1"
    )


def downgrade() -> None:
    op.execute(
        "DELETE FROM feedback_rounds WHERE questionnaire_id IN "
        "(SELECT id FROM questionnaires WHERE group_id IS NOT NULL)"
    )
    op.execute("DELETE FROM questionnaires WHERE group_id IS NOT NULL")

    op.drop_index("ix_answer_choice_options_option_id", table_name="answer_choice_options")
    op.drop_table("answer_choice_options")
    op.drop_constraint("ck_answers_at_most_one_scalar_value", "answers", type_="check")
    op.execute("DELETE FROM answers WHERE score IS NULL AND text_value IS NULL")
    op.create_check_constraint(
        "ck_answers_exactly_one_value",
        "answers",
        "(score IS NOT NULL AND text_value IS NULL) OR (score IS NULL AND text_value IS NOT NULL)",
    )

    op.drop_index("ix_question_options_question_id", table_name="question_options")
    op.drop_table("question_options")

    op.drop_constraint("ck_questions_kind", "questions", type_="check")
    op.create_check_constraint("ck_questions_kind", "questions", "kind IN ('scale', 'text')")
    op.alter_column(
        "questions",
        "kind",
        existing_type=sa.String(length=24),
        type_=sa.String(length=16),
        existing_nullable=False,
    )
    op.alter_column(
        "questions",
        "prompt",
        existing_type=sa.String(length=500),
        type_=sa.String(length=240),
        existing_nullable=False,
    )

    op.drop_constraint("ck_questionnaires_status", "questionnaires", type_="check")
    op.drop_index("ix_questionnaires_created_by_user_id", table_name="questionnaires")
    op.drop_index("ix_questionnaires_group_id", table_name="questionnaires")
    op.drop_constraint(
        "fk_questionnaires_created_by_user_id_users", "questionnaires", type_="foreignkey"
    )
    op.drop_constraint("fk_questionnaires_group_id_groups", "questionnaires", type_="foreignkey")
    op.drop_column("questionnaires", "status")
    op.drop_column("questionnaires", "description")
    op.drop_column("questionnaires", "created_by_user_id")
    op.drop_column("questionnaires", "group_id")
